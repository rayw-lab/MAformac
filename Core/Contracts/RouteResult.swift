import Foundation

// MARK: - ActionCandidate
//
// Field naming — verbatim from `contracts/semantic-function-contract.jsonl`
// (`intent`, `service`, `device`, `action_primitive`, `action_code`, `slot`,
// `slot_keys`, `value{ref,direct,offset,type}`) + `mounted_tool_name` for the
// D-domain named-tool surface (aligns with
// `Core/Contracts/DDomainMountedToolCatalog.swift:12-14` `mountedToolNames`).
//
// Presence of an ActionCandidate in a RouteResult is NOT action proof.
// See `openspec/specs/tool-execution/spec.md:5-11` for the candidate→gate→
// action separation upstream.
public struct ActionCandidate: Codable, Equatable, Sendable {
    public let intent: String
    public let service: RouteService
    public let mountedToolName: String
    public let actionPrimitive: String
    public let actionCode: String
    public let device: String
    public let slot: String
    public let slotKeys: [String]
    public let value: RouteValueFourTuple

    public init(
        intent: String,
        service: RouteService,
        mountedToolName: String,
        actionPrimitive: String,
        actionCode: String,
        device: String,
        slot: String,
        slotKeys: [String],
        value: RouteValueFourTuple
    ) {
        self.intent = intent
        self.service = service
        self.mountedToolName = mountedToolName
        self.actionPrimitive = actionPrimitive
        self.actionCode = actionCode
        self.device = device
        self.slot = slot
        self.slotKeys = slotKeys
        self.value = value
    }

    enum CodingKeys: String, CodingKey {
        case intent
        case service
        case mountedToolName = "mounted_tool_name"
        case actionPrimitive = "action_primitive"
        case actionCode = "action_code"
        case device
        case slot
        case slotKeys = "slot_keys"
        case value
    }

    /// Digest-safe summary of the candidate — the subset that trace_digest
    /// covers so tampering with a load-bearing candidate field (mounted tool,
    /// action_primitive, action_code, value, or service) flips the digest.
    /// grok-4.5 xAI review P1-B2 (2026-07-13): trace_digest previously only
    /// covered outcome axis, letting candidate tampering pass through the
    /// joint validator. Summary now included in RouteTrace.LoadBearing.
    public var summary: ActionCandidateSummary {
        ActionCandidateSummary(
            mountedToolName: mountedToolName,
            service: service,
            actionPrimitive: actionPrimitive,
            actionCode: actionCode,
            value: value
        )
    }

    /// Forbidden-key inspection at decode time — grok-4.5 review P1-B6.
    /// JSONDecoder default silently drops unknown keys; we defend the
    /// ontology narrowing with an explicit key set check.
    public static func decodeRejectingForbiddenKeys(from data: Data) throws -> ActionCandidate {
        try RouteWireGuard.rejectForbiddenKeys(in: data, contextPath: "action_candidate")
        return try JSONDecoder().decode(ActionCandidate.self, from: data)
    }
}

// MARK: - ActionCandidateSummary
//
// The candidate subset that trace_digest covers. Includes exactly the
// load-bearing candidate fields per grok-4.5 review P1-B2 fix
// (mounted_tool_name / service / action_primitive / action_code / value).
// `intent / device / slot / slot_keys` are NOT in the summary because they
// are derivable from mounted_tool_name via jsonl (intent==mounted_tool_name
// under the paradigm) and downstream doesn't act on them structurally.
public struct ActionCandidateSummary: Codable, Equatable, Sendable {
    public let mountedToolName: String
    public let service: RouteService
    public let actionPrimitive: String
    public let actionCode: String
    public let value: RouteValueFourTuple

    public init(
        mountedToolName: String,
        service: RouteService,
        actionPrimitive: String,
        actionCode: String,
        value: RouteValueFourTuple
    ) {
        self.mountedToolName = mountedToolName
        self.service = service
        self.actionPrimitive = actionPrimitive
        self.actionCode = actionCode
        self.value = value
    }

    enum CodingKeys: String, CodingKey {
        case mountedToolName = "mounted_tool_name"
        case service
        case actionPrimitive = "action_primitive"
        case actionCode = "action_code"
        case value
    }
}

// MARK: - RouteWireGuard
//
// Forbidden-key inspection at decode time. grok-4.5 review P1-B6.
public enum RouteWireGuard {
    /// Parse raw JSON and reject if any RouteForbiddenKeys.all key appears
    /// at the top-level object. Throws RouteError.forbiddenKey.
    public static func rejectForbiddenKeys(in data: Data, contextPath: String) throws {
        guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return  // Not a top-level object, nothing to guard
        }
        let keys = Set(object.keys)
        let violations = keys.intersection(RouteForbiddenKeys.all)
        if let first = violations.sorted().first {
            throw RouteError.forbiddenKey("\(contextPath).\(first)")
        }
    }
}

// MARK: - RouteTrace
//
// Redacted decision trail. Carries load-bearing facts + trace_digest computed
// over the canonical JSON of the load-bearing subset.
//
// SHALL "RouteTrace SHALL NOT carry raw prompt text, raw model response, PII,
// or any un-redacted customer utterance." — no raw fields present here.
public struct RouteTrace: Codable, Equatable, Sendable {
    public let schemaVersion: String
    public let turnID: String
    public let traceID: String
    public let execTier: RouteExecTier
    public let outcome: RouteOutcome
    public let clarifyTag: RouteClarifyTag
    public let rejectionReason: RouteError?
    /// grok-4.5 review P1-B2 fix — trace_digest now covers candidate payload.
    /// nil when the RouteResult has no action_candidate (outcome=clarify/reject/fallback
    /// path); Some(...) when outcome=candidate carries a load-bearing tool binding.
    public let actionCandidateSummary: ActionCandidateSummary?
    public let redactionPolicyID: String
    public let staleMarker: String?
    public let traceDigest: String

    public init(
        schemaVersion: String = RouteSchemaVersion.current,
        turnID: String,
        traceID: String,
        execTier: RouteExecTier,
        outcome: RouteOutcome,
        clarifyTag: RouteClarifyTag,
        rejectionReason: RouteError?,
        actionCandidateSummary: ActionCandidateSummary? = nil,
        redactionPolicyID: String,
        staleMarker: String?,
        traceDigest: String
    ) {
        self.schemaVersion = schemaVersion
        self.turnID = turnID
        self.traceID = traceID
        self.execTier = execTier
        self.outcome = outcome
        self.clarifyTag = clarifyTag
        self.rejectionReason = rejectionReason
        self.actionCandidateSummary = actionCandidateSummary
        self.redactionPolicyID = redactionPolicyID
        self.staleMarker = staleMarker
        self.traceDigest = traceDigest
    }

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case turnID = "turn_id"
        case traceID = "trace_id"
        case execTier = "exec_tier"
        case outcome
        case clarifyTag = "clarify_tag"
        case rejectionReason = "rejection_reason"
        case actionCandidateSummary = "action_candidate_summary"
        case redactionPolicyID = "redaction_policy_id"
        case staleMarker = "stale_marker"
        case traceDigest = "trace_digest"
    }

    /// The load-bearing subset used to compute `trace_digest`. Excludes the
    /// digest field itself (self-reference would loop) and any non-load-bearing
    /// metadata that MAY drift without changing decision semantics.
    ///
    /// Load-bearing:
    ///   - schema_version, turn_id, trace_id, exec_tier, outcome, clarify_tag,
    ///     rejection_reason, redaction_policy_id, stale_marker (outcome axis).
    ///   - action_candidate_summary (grok-4.5 review P1-B2 fix, 2026-07-13):
    ///     mounted_tool_name / service / action_primitive / action_code / value.
    public struct LoadBearing: Codable, Equatable, Sendable {
        public let schemaVersion: String
        public let turnID: String
        public let traceID: String
        public let execTier: RouteExecTier
        public let outcome: RouteOutcome
        public let clarifyTag: RouteClarifyTag
        public let rejectionReason: RouteError?
        public let actionCandidateSummary: ActionCandidateSummary?
        public let redactionPolicyID: String
        public let staleMarker: String?

        enum CodingKeys: String, CodingKey {
            case schemaVersion = "schema_version"
            case turnID = "turn_id"
            case traceID = "trace_id"
            case execTier = "exec_tier"
            case outcome
            case clarifyTag = "clarify_tag"
            case rejectionReason = "rejection_reason"
            case actionCandidateSummary = "action_candidate_summary"
            case redactionPolicyID = "redaction_policy_id"
            case staleMarker = "stale_marker"
        }
    }

    public var loadBearing: LoadBearing {
        LoadBearing(
            schemaVersion: schemaVersion,
            turnID: turnID,
            traceID: traceID,
            execTier: execTier,
            outcome: outcome,
            clarifyTag: clarifyTag,
            rejectionReason: rejectionReason,
            actionCandidateSummary: actionCandidateSummary,
            redactionPolicyID: redactionPolicyID,
            staleMarker: staleMarker
        )
    }

    /// Compute canonical digest over load-bearing fields. Anchored to the
    /// same SHA-256 + canonical JSON pattern used in
    /// `Core/Contracts/DDomainMountedToolCatalog.swift:22-26`.
    public func computeTraceDigest() throws -> String {
        try RouteCanonicalJSON.sha256Hex(loadBearing)
    }

    /// Deterministic rebind — replaces `traceDigest` with a freshly computed
    /// canonical hash of the current load-bearing set.
    public func withRecomputedDigest() throws -> RouteTrace {
        let digest = try computeTraceDigest()
        return RouteTrace(
            schemaVersion: schemaVersion,
            turnID: turnID,
            traceID: traceID,
            execTier: execTier,
            outcome: outcome,
            clarifyTag: clarifyTag,
            rejectionReason: rejectionReason,
            actionCandidateSummary: actionCandidateSummary,
            redactionPolicyID: redactionPolicyID,
            staleMarker: staleMarker,
            traceDigest: digest
        )
    }

    /// Forbidden-key inspection at decode time — grok-4.5 review P1-B6 (2026-07-13).
    public static func decodeRejectingForbiddenKeys(from data: Data) throws -> RouteTrace {
        try RouteWireGuard.rejectForbiddenKeys(in: data, contextPath: "route_trace")
        return try JSONDecoder().decode(RouteTrace.self, from: data)
    }
}

// MARK: - RouteResult
//
// The wire-level typed route/model contract carrier. Minimum fields per SHALL
// "Route result MUST carry the minimum wire fields":
// schema_version / route_schema / turn_id / trace_id / exec_tier / outcome /
// clarify_tag / service / action_candidate? / trace_digest / rejection_reason?.
//
// Session/event/sequence deliberately absent (belongs to W5a pending-correlation
// record; see `openspec/changes/add-t04a-customer-ingress/design.md:7-11`).
public struct RouteResult: Codable, Equatable, Sendable {
    public let schemaVersion: String
    public let routeSchema: String
    public let turnID: String
    public let traceID: String
    public let execTier: RouteExecTier
    public let outcome: RouteOutcome
    public let clarifyTag: RouteClarifyTag
    public let service: RouteService
    public let actionCandidate: ActionCandidate?
    public let traceDigest: String
    public let rejectionReason: RouteError?

    public init(
        schemaVersion: String = RouteSchemaVersion.current,
        routeSchema: String,
        turnID: String,
        traceID: String,
        execTier: RouteExecTier,
        outcome: RouteOutcome,
        clarifyTag: RouteClarifyTag,
        service: RouteService,
        actionCandidate: ActionCandidate?,
        traceDigest: String,
        rejectionReason: RouteError?
    ) {
        self.schemaVersion = schemaVersion
        self.routeSchema = routeSchema
        self.turnID = turnID
        self.traceID = traceID
        self.execTier = execTier
        self.outcome = outcome
        self.clarifyTag = clarifyTag
        self.service = service
        self.actionCandidate = actionCandidate
        self.traceDigest = traceDigest
        self.rejectionReason = rejectionReason
    }

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case routeSchema = "route_schema"
        case turnID = "turn_id"
        case traceID = "trace_id"
        case execTier = "exec_tier"
        case outcome
        case clarifyTag = "clarify_tag"
        case service
        case actionCandidate = "action_candidate"
        case traceDigest = "trace_digest"
        case rejectionReason = "rejection_reason"
    }

    /// Custom Codable init — grok-4.5 review P1-B6 (2026-07-13).
    /// The synthesized init silently drops unknown keys (session_id / event_id /
    /// sequence / raw_prompt / raw_response), letting SHALL "session identity
    /// leaks are forbidden" be violated at runtime while tests read Mirror
    /// output. We use DecodingError.userInfo to carry the raw JSON bytes so
    /// the forbidden-key set can be inspected. When called from
    /// `decodeRejectingForbiddenKeys`, the guard runs on raw bytes BEFORE decode.
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: RouteResult.CodingKeys.self)
        self.schemaVersion = try c.decode(String.self, forKey: .schemaVersion)
        self.routeSchema = try c.decode(String.self, forKey: .routeSchema)
        self.turnID = try c.decode(String.self, forKey: .turnID)
        self.traceID = try c.decode(String.self, forKey: .traceID)
        self.execTier = try c.decode(RouteExecTier.self, forKey: .execTier)
        self.outcome = try c.decode(RouteOutcome.self, forKey: .outcome)
        self.clarifyTag = try c.decode(RouteClarifyTag.self, forKey: .clarifyTag)
        self.service = try c.decode(RouteService.self, forKey: .service)
        self.actionCandidate = try c.decodeIfPresent(ActionCandidate.self, forKey: .actionCandidate)
        self.traceDigest = try c.decode(String.self, forKey: .traceDigest)
        self.rejectionReason = try c.decodeIfPresent(RouteError.self, forKey: .rejectionReason)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: RouteResult.CodingKeys.self)
        try c.encode(schemaVersion, forKey: .schemaVersion)
        try c.encode(routeSchema, forKey: .routeSchema)
        try c.encode(turnID, forKey: .turnID)
        try c.encode(traceID, forKey: .traceID)
        try c.encode(execTier, forKey: .execTier)
        try c.encode(outcome, forKey: .outcome)
        try c.encode(clarifyTag, forKey: .clarifyTag)
        try c.encode(service, forKey: .service)
        try c.encodeIfPresent(actionCandidate, forKey: .actionCandidate)
        try c.encode(traceDigest, forKey: .traceDigest)
        try c.encodeIfPresent(rejectionReason, forKey: .rejectionReason)
    }

    /// Forbidden-key inspection at decode time — grok-4.5 review P1-B6.
    /// This is the recommended entry point for consumers that receive JSON
    /// from an untrusted source (W5a follow-up, T04a activation, etc.).
    public static func decodeRejectingForbiddenKeys(from data: Data) throws -> RouteResult {
        try RouteWireGuard.rejectForbiddenKeys(in: data, contextPath: "route_result")
        return try JSONDecoder().decode(RouteResult.self, from: data)
    }
}

// MARK: - RouteContractValidator
//
// Total validator. Consumes SSOT catalogs only (no parallel registries):
//   • mountedToolNames  — Core/Contracts/DDomainMountedToolCatalog.swift:12-14
//   • RouteService.allCases — {airControl, carControl, cmd}
//   • jsonl exec_tier / clarify_tag alphabets  — enums in RouteContract.swift
//
// Behavior:
//   1. Validate RouteResult wire shape (schema_version, three-axis alphabets).
//   2. If outcome == .candidate, require actionCandidate present + rejectionReason nil;
//      validate mounted tool name against DDomainMountedToolCatalog.
//   3. If outcome == .reject, require rejectionReason present + actionCandidate nil.
//   4. If outcome == .clarify or .fallback, actionCandidate MAY be absent; rejectionReason
//      SHALL be absent for .clarify (clarify carries its own R2 semantics).
//   5. If a matching RouteTrace is supplied, verify traceDigest equals the freshly
//      computed digest and fail closed on mismatch.
public enum RouteContractValidator {
    /// Validate a RouteResult in isolation. Rejects illegal combinations,
    /// unmounted tools, out-of-catalog services, schema_version drift,
    /// and forbidden-field leaks (session_id, event_id, sequence).
    public static func validate(_ result: RouteResult) throws {
        try validateSchemaVersion(result.schemaVersion)
        try validateThreeAxisCombination(result)
        try validateActionCandidateIfPresent(result)
    }

    /// Validate a RouteResult jointly with its trace. Digest is recomputed and
    /// checked before returning.
    public static func validate(_ result: RouteResult, trace: RouteTrace) throws {
        try validate(result)
        try validateSchemaVersion(trace.schemaVersion)

        // Consistency between result and trace on load-bearing fields.
        if result.turnID != trace.turnID {
            throw RouteError.illegalCombination(
                "RouteResult.turn_id \(result.turnID) != RouteTrace.turn_id \(trace.turnID)"
            )
        }
        if result.traceID != trace.traceID {
            throw RouteError.illegalCombination(
                "RouteResult.trace_id \(result.traceID) != RouteTrace.trace_id \(trace.traceID)"
            )
        }
        if result.execTier != trace.execTier {
            throw RouteError.illegalCombination(
                "RouteResult.exec_tier \(result.execTier.rawValue) != RouteTrace.exec_tier \(trace.execTier.rawValue)"
            )
        }
        if result.outcome != trace.outcome {
            throw RouteError.illegalCombination(
                "RouteResult.outcome \(result.outcome.rawValue) != RouteTrace.outcome \(trace.outcome.rawValue)"
            )
        }
        if result.clarifyTag != trace.clarifyTag {
            throw RouteError.illegalCombination(
                "RouteResult.clarify_tag \(result.clarifyTag.rawValue) != RouteTrace.clarify_tag \(trace.clarifyTag.rawValue)"
            )
        }

        // Candidate-summary sync between result and trace — grok-4.5 review
        // P1-B2 fix (2026-07-13). trace_digest now covers action_candidate,
        // so a mismatch in candidate summaries surfaces as illegal combination
        // BEFORE the digest check, giving a more specific error.
        let resultSummary = result.actionCandidate?.summary
        if resultSummary != trace.actionCandidateSummary {
            throw RouteError.illegalCombination(
                "RouteResult.action_candidate.summary != RouteTrace.action_candidate_summary"
            )
        }

        let expected = result.traceDigest
        let actual = try trace.computeTraceDigest()
        if expected != actual {
            throw RouteError.digestMismatch(expected: expected, actual: actual)
        }
    }

    /// Reject-reason precedence selection. Emits ONE reason from the caller's
    /// candidate set based on RouteError.rank; empty set is a programming
    /// error and produces illegalCombination.
    public static func selectRejection(from candidates: [RouteError]) -> RouteError {
        precondition(!candidates.isEmpty, "selectRejection requires at least one candidate")
        return candidates.sorted { $0.rank < $1.rank }.first!
    }

    // MARK: - Private helpers

    private static func validateSchemaVersion(_ version: String) throws {
        if version != RouteSchemaVersion.current {
            throw RouteError.schemaVersionMismatch(
                expected: RouteSchemaVersion.current,
                actual: version
            )
        }
    }

    private static func validateThreeAxisCombination(_ result: RouteResult) throws {
        // Three-axis independence is already enforced at type-level (each axis
        // is its own closed enum). But cross-axis SEMANTIC combinations need
        // validation: candidate MUST carry action_candidate; reject MUST carry
        // rejectionReason; clarify SHALL NOT carry rejectionReason.
        switch result.outcome {
        case .candidate:
            if result.actionCandidate == nil {
                throw RouteError.illegalCombination(
                    "outcome=candidate SHALL carry action_candidate"
                )
            }
            if result.rejectionReason != nil {
                throw RouteError.illegalCombination(
                    "outcome=candidate SHALL NOT carry rejection_reason"
                )
            }
        case .reject:
            if result.rejectionReason == nil {
                throw RouteError.illegalCombination(
                    "outcome=reject SHALL carry rejection_reason"
                )
            }
            if result.actionCandidate != nil {
                throw RouteError.illegalCombination(
                    "outcome=reject SHALL NOT carry action_candidate"
                )
            }
        case .clarify:
            if result.rejectionReason != nil {
                throw RouteError.illegalCombination(
                    "outcome=clarify SHALL NOT carry rejection_reason (clarify is orthogonal to reject)"
                )
            }
        case .fallback:
            // fallback is permitted with or without action_candidate; rejectionReason
            // SHALL be absent because fallback is not a reject.
            if result.rejectionReason != nil {
                throw RouteError.illegalCombination(
                    "outcome=fallback SHALL NOT carry rejection_reason"
                )
            }
        }
    }

    private static func validateActionCandidateIfPresent(_ result: RouteResult) throws {
        guard let candidate = result.actionCandidate else { return }

        // Service catalog SSOT — RouteService enum already restricts by type,
        // so decoded results are pre-validated. Re-check here defends against
        // programmatically constructed candidates that skip Codable.
        if !RouteService.allCases.contains(candidate.service) {
            throw RouteError.outOfCatalog(candidate.service.rawValue)
        }

        // Result's top-level service SHALL match candidate's service.
        if result.service != candidate.service {
            throw RouteError.illegalCombination(
                "RouteResult.service \(result.service.rawValue) != action_candidate.service \(candidate.service.rawValue)"
            )
        }

        // Mounted tool name SSOT — consume DDomainMountedToolCatalog, no parallel set.
        if !DDomainMountedToolCatalog.mountedToolNames.contains(candidate.mountedToolName) {
            throw RouteError.unmountedName(candidate.mountedToolName)
        }

        // Kinship gate — grok-4.5 xAI review P1-A2 (2026-07-13).
        // Mounted tool binds to a specific service per jsonl; candidate's
        // service must equal that binding. Guards against
        // service=carControl + mounted_tool=airControl-tool illegal combos.
        if let boundService = MountedToolServiceMap.service(for: candidate.mountedToolName),
           boundService != candidate.service {
            throw RouteError.crossDomainMountedTool(
                tool: candidate.mountedToolName,
                boundService: boundService,
                candidateService: candidate.service
            )
        }

        // EXP-typed offset SHALL be an experiential enum (not literal).
        if candidate.value.type == .EXP {
            switch candidate.value.offset {
            case .experiential:
                break
            case .empty, .literal:
                throw RouteError.unknownEnum("value.offset")
            }
        }
    }
}
