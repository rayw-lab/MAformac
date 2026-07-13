import XCTest
@testable import MAformacCore

final class RouteContractTests: XCTestCase {

    // MARK: - Helpers

    private func makeAirControlCandidate() -> ActionCandidate {
        ActionCandidate(
            intent: "open_ac_set_interface",
            service: .airControl,
            mountedToolName: "adjust_ac_temperature_to_number",
            actionPrimitive: "power_on",
            actionCode: "open_page",
            device: "ac_set_interface",
            slot: "none",
            slotKeys: [],
            value: RouteValueFourTuple()
        )
    }

    private func makeCarControlCandidate() -> ActionCandidate {
        ActionCandidate(
            intent: "open_window",
            service: .carControl,
            mountedToolName: "adjust_ac_temperature_to_number",
            actionPrimitive: "power_on",
            actionCode: "open_process_device",
            device: "window",
            slot: "none",
            slotKeys: [],
            value: RouteValueFourTuple()
        )
    }

    private func makeTrace(
        turnID: String = "turn-1",
        traceID: String = "trace-1",
        execTier: RouteExecTier = .L2,
        outcome: RouteOutcome = .candidate,
        clarifyTag: RouteClarifyTag = .implicit,
        rejectionReason: RouteError? = nil,
        actionCandidateSummary: ActionCandidateSummary? = nil,
        redactionPolicyID: String = "redaction_policy.v1",
        staleMarker: String? = nil
    ) throws -> RouteTrace {
        let placeholder = RouteTrace(
            turnID: turnID,
            traceID: traceID,
            execTier: execTier,
            outcome: outcome,
            clarifyTag: clarifyTag,
            rejectionReason: rejectionReason,
            actionCandidateSummary: actionCandidateSummary,
            redactionPolicyID: redactionPolicyID,
            staleMarker: staleMarker,
            traceDigest: ""
        )
        return try placeholder.withRecomputedDigest()
    }

    /// Convenience — build a trace whose actionCandidateSummary mirrors a
    /// given candidate so validate(_:trace:) can verify the joint digest.
    private func makeTraceMirroring(
        _ candidate: ActionCandidate?,
        turnID: String = "turn-1",
        traceID: String = "trace-1",
        execTier: RouteExecTier = .L2,
        outcome: RouteOutcome = .candidate,
        clarifyTag: RouteClarifyTag = .implicit,
        rejectionReason: RouteError? = nil
    ) throws -> RouteTrace {
        try makeTrace(
            turnID: turnID,
            traceID: traceID,
            execTier: execTier,
            outcome: outcome,
            clarifyTag: clarifyTag,
            rejectionReason: rejectionReason,
            actionCandidateSummary: candidate?.summary
        )
    }

    private func makeResult(
        turnID: String = "turn-1",
        traceID: String = "trace-1",
        execTier: RouteExecTier = .L2,
        outcome: RouteOutcome = .candidate,
        clarifyTag: RouteClarifyTag = .implicit,
        service: RouteService = .airControl,
        actionCandidate: ActionCandidate? = nil,
        rejectionReason: RouteError? = nil,
        traceDigest: String
    ) -> RouteResult {
        RouteResult(
            routeSchema: "route_schema.demo.v1",
            turnID: turnID,
            traceID: traceID,
            execTier: execTier,
            outcome: outcome,
            clarifyTag: clarifyTag,
            service: service,
            actionCandidate: actionCandidate,
            traceDigest: traceDigest,
            rejectionReason: rejectionReason
        )
    }

    // MARK: - Three-axis independence

    func testThreeAxisIndependentPositive() throws {
        let candidate = makeAirControlCandidate()
        let trace = try makeTraceMirroring(candidate,
            execTier: .L1, outcome: .candidate, clarifyTag: .explicit)
        let result = makeResult(
            execTier: .L1,
            outcome: .candidate,
            clarifyTag: .explicit,
            service: .airControl,
            actionCandidate: candidate,
            traceDigest: trace.traceDigest
        )
        XCTAssertNoThrow(try RouteContractValidator.validate(result, trace: trace))
    }

    func testExecTierAlphabetIsClosed() {
        let cases = RouteExecTier.allCases.map(\.rawValue).sorted()
        XCTAssertEqual(cases, ["L1", "L2", "L3", "L4", "L5"])
    }

    func testOutcomeAlphabetIsClosed() {
        let cases = RouteOutcome.allCases.map(\.rawValue).sorted()
        XCTAssertEqual(cases, ["candidate", "clarify", "fallback", "reject"])
    }

    func testClarifyTagAlphabetStrictJsonlAlignment() {
        // Two values only — matches jsonl row-level distribution
        // (explicit + implicit; runtime ambiguous/rejected/passthrough go through outcome / RouteError).
        let cases = RouteClarifyTag.allCases.map(\.rawValue).sorted()
        XCTAssertEqual(cases, ["explicit", "implicit"])
    }

    func testWidenedClarifyTagRejectedByDecode() throws {
        let json = """
        {
          "schema_version": "typed_route_contract.v1",
          "route_schema": "route_schema.demo.v1",
          "turn_id": "t1",
          "trace_id": "tr1",
          "exec_tier": "L2",
          "outcome": "clarify",
          "clarify_tag": "ambiguous",
          "service": "airControl",
          "action_candidate": null,
          "trace_digest": "0000000000000000000000000000000000000000000000000000000000000000",
          "rejection_reason": null
        }
        """.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(RouteResult.self, from: json))
    }

    func testUnknownExecTierFailsClosedOnDecode() throws {
        let json = """
        {
          "schema_version": "typed_route_contract.v1",
          "route_schema": "route_schema.demo.v1",
          "turn_id": "t1",
          "trace_id": "tr1",
          "exec_tier": "L9",
          "outcome": "candidate",
          "clarify_tag": "implicit",
          "service": "airControl",
          "action_candidate": null,
          "trace_digest": "0",
          "rejection_reason": null
        }
        """.data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(RouteResult.self, from: json))
    }

    // MARK: - Minimum wire fields / ontology narrowing

    func testCandidateOutcomeRequiresActionCandidate() throws {
        let trace = try makeTrace(outcome: .candidate)
        let result = makeResult(
            outcome: .candidate,
            actionCandidate: nil,
            traceDigest: trace.traceDigest
        )
        XCTAssertThrowsError(try RouteContractValidator.validate(result)) { error in
            guard case RouteError.illegalCombination = error else {
                return XCTFail("expected .illegalCombination, got \(error)")
            }
        }
    }

    func testRejectOutcomeRequiresRejectionReason() throws {
        let trace = try makeTrace(outcome: .reject, rejectionReason: nil)
        let result = makeResult(
            outcome: .reject,
            actionCandidate: nil,
            rejectionReason: nil,
            traceDigest: trace.traceDigest
        )
        XCTAssertThrowsError(try RouteContractValidator.validate(result)) { error in
            guard case RouteError.illegalCombination = error else {
                return XCTFail("expected .illegalCombination, got \(error)")
            }
        }
    }

    func testClarifyOutcomeForbidsRejectionReason() throws {
        let trace = try makeTrace(outcome: .clarify)
        let result = makeResult(
            outcome: .clarify,
            actionCandidate: nil,
            rejectionReason: .clarifyRequired(.implicit),
            traceDigest: trace.traceDigest
        )
        XCTAssertThrowsError(try RouteContractValidator.validate(result)) { error in
            guard case RouteError.illegalCombination = error else {
                return XCTFail("expected .illegalCombination, got \(error)")
            }
        }
    }

    func testRouteResultCodableRoundTrip() throws {
        let trace = try makeTrace(outcome: .candidate, clarifyTag: .explicit)
        let original = makeResult(
            outcome: .candidate,
            clarifyTag: .explicit,
            actionCandidate: makeAirControlCandidate(),
            traceDigest: trace.traceDigest
        )
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(RouteResult.self, from: encoded)
        XCTAssertEqual(original, decoded)
    }

    func testSessionIDLeakThroughForeignKeyRejected() throws {
        // Extra field session_id (from jsonl-adjacent world) SHALL NOT be tolerated:
        // Swift Codable with default init(from:) succeeds on extra fields, so we
        // rely on the JSON schema validator (Python fixture checker) + design.
        // Here we verify RouteResult itself DOES NOT expose session_id in any
        // codable path (compile-time guarantee: no such property).
        let mirror = Mirror(reflecting: RouteResult(
            routeSchema: "r",
            turnID: "t",
            traceID: "tr",
            execTier: .L2,
            outcome: .clarify,
            clarifyTag: .implicit,
            service: .airControl,
            actionCandidate: nil,
            traceDigest: String(repeating: "0", count: 64),
            rejectionReason: nil
        ))
        let names = mirror.children.compactMap { $0.label }
        XCTAssertFalse(names.contains("sessionID"))
        XCTAssertFalse(names.contains("eventID"))
        XCTAssertFalse(names.contains("sequence"))
    }

    // MARK: - Mounted D-domain tool binding

    func testUnmountedNameRejected() throws {
        let unmounted = ActionCandidate(
            intent: "raise_ac_temperature_by_exp",
            service: .airControl,
            mountedToolName: "raise_ac_temperature_by_exp",
            actionPrimitive: "increase_by_exp",
            actionCode: "increase_value_little",
            device: "ac_temperature",
            slot: "none",
            slotKeys: [],
            value: RouteValueFourTuple(
                ref: .CUR, direct: .plus,
                offset: .experiential(.LITTLE), type: .EXP
            )
        )
        let trace = try makeTrace(outcome: .candidate)
        let result = makeResult(
            outcome: .candidate,
            actionCandidate: unmounted,
            traceDigest: trace.traceDigest
        )
        XCTAssertThrowsError(try RouteContractValidator.validate(result)) { error in
            guard case RouteError.unmountedName(let name) = error else {
                return XCTFail("expected .unmountedName, got \(error)")
            }
            XCTAssertEqual(name, "raise_ac_temperature_by_exp")
        }
    }

    func testMountedToolBindingIsSSOTNotDuplicated() {
        // Live-cored: personaAvoidListToolNames is NOT mountedToolNames.
        // The validator consumes DDomainMountedToolCatalog.mountedToolNames only.
        XCTAssertEqual(
            DDomainMountedToolCatalog.mountedToolNames,
            ["adjust_ac_temperature_to_number"]
        )
        // personaAvoidListToolNames must not overlap with mountedToolNames.
        XCTAssertTrue(
            DDomainMountedToolCatalog.mountedToolNames
                .isDisjoint(with: DDomainMountedToolCatalog.personaAvoidListToolNames)
        )
    }

    // MARK: - Value four-tuple typed enums

    func testValueEmptyDecodesEachAxisEmpty() throws {
        let json = "{\"ref\":\"\",\"direct\":\"\",\"offset\":\"\",\"type\":\"\"}"
            .data(using: .utf8)!
        let value = try JSONDecoder().decode(RouteValueFourTuple.self, from: json)
        XCTAssertEqual(value.ref, .empty)
        XCTAssertEqual(value.direct, .empty)
        XCTAssertEqual(value.type, .empty)
        XCTAssertEqual(value.offset, .empty)
        XCTAssertTrue(value.isEmpty)
    }

    /// Bug 2 fix — decoder-level cross-field defense (belt + suspenders).
    /// Without the RouteValueFourTuple.init(from:) cross-field check, a payload
    /// with type=EXP + offset='WARM' would silently decode to
    /// .literal("WARM") and only the validator would catch it later.
    /// After the fix, the decoder itself throws.
    func testExpWithLiteralOffsetFailsAtDecoder() {
        let json = "{\"ref\":\"CUR\",\"direct\":\"+\",\"offset\":\"WARM\",\"type\":\"EXP\"}"
            .data(using: .utf8)!
        XCTAssertThrowsError(try JSONDecoder().decode(RouteValueFourTuple.self, from: json)) { error in
            guard case DecodingError.dataCorrupted(let ctx) = error else {
                return XCTFail("expected DecodingError.dataCorrupted, got \(error)")
            }
            XCTAssertTrue(
                ctx.debugDescription.contains("experiential"),
                "expected debug description to mention 'experiential', got: \(ctx.debugDescription)"
            )
        }
    }

    func testExpWithExperientialOffsetAccepted() throws {
        let value = RouteValueFourTuple(
            ref: .CUR, direct: .plus,
            offset: .experiential(.LITTLE), type: .EXP
        )
        let encoded = try JSONEncoder().encode(value)
        let decoded = try JSONDecoder().decode(RouteValueFourTuple.self, from: encoded)
        XCTAssertEqual(value, decoded)
    }

    func testExpWithLiteralOffsetFailsValidator() throws {
        let bad = ActionCandidate(
            intent: "raise_ac_temperature_by_exp",
            service: .airControl,
            mountedToolName: "adjust_ac_temperature_to_number",
            actionPrimitive: "increase_by_exp",
            actionCode: "increase_value_little",
            device: "ac_temperature",
            slot: "none",
            slotKeys: [],
            value: RouteValueFourTuple(
                ref: .CUR, direct: .plus,
                offset: .literal("WARM"), type: .EXP
            )
        )
        let trace = try makeTrace(outcome: .candidate)
        let result = makeResult(
            outcome: .candidate,
            actionCandidate: bad,
            traceDigest: trace.traceDigest
        )
        XCTAssertThrowsError(try RouteContractValidator.validate(result)) { error in
            guard case RouteError.unknownEnum(let field) = error else {
                return XCTFail("expected .unknownEnum, got \(error)")
            }
            XCTAssertEqual(field, "value.offset")
        }
    }

    func testValueFourTupleFieldNamesAreJsonlVerbatim() throws {
        // Verify canonical JSON keys match jsonl SSOT names exactly.
        let value = RouteValueFourTuple()
        let data = try RouteCanonicalJSON.encode(value)
        let s = String(data: data, encoding: .utf8)!
        XCTAssertEqual(s, "{\"direct\":\"\",\"offset\":\"\",\"ref\":\"\",\"type\":\"\"}")
    }

    // MARK: - Error enum coverage / precedence

    func testRouteErrorHasAllRequiredCases() {
        let errors: [RouteError] = [
            .riskR0Forbidden("_"),
            .illegalCombination("_"),
            .forbiddenKey("_"),
            .unmountedName("_"),
            .crossDomainMountedTool(
                tool: "_", boundService: .airControl, candidateService: .carControl
            ),
            .outOfCatalog("_"),
            .oldGeneration("_"),
            .staleSource("_"),
            .digestMismatch(expected: "_", actual: "_"),
            .schemaVersionMismatch(expected: "_", actual: "_"),
            .payloadInvalid("_"),
            .slotMissing("_"),
            .valueOutOfRange("_"),
            .unknownEnum("_"),
            .riskR1PreconditionUnmet("_"),
            .clarifyRequired(.implicit)
        ]
        // 16 cases unique via `code` — extended in grok-4.5 review P1 fix.
        let codes = Set(errors.map(\.code))
        XCTAssertEqual(codes.count, 16)
    }

    func testR0TakesPrecedenceOverR1() {
        let selected = RouteContractValidator.selectRejection(from: [
            .riskR1PreconditionUnmet("state precondition unmet"),
            .riskR0Forbidden("driving forbidden")
        ])
        guard case .riskR0Forbidden = selected else {
            return XCTFail("expected R0 selected over R1")
        }
    }

    func testRejectionPrecedenceIsTotalOrdered() {
        // Rank ordering matches SHALL enumeration.
        // Extended to 16 cases in the grok-4.5 review P1 fix commit
        // (added .forbiddenKey at rank 2, .crossDomainMountedTool at rank 4).
        let ranks = [
            RouteError.riskR0Forbidden("_").rank,
            RouteError.illegalCombination("_").rank,
            RouteError.forbiddenKey("_").rank,
            RouteError.unmountedName("_").rank,
            RouteError.crossDomainMountedTool(
                tool: "_", boundService: .airControl, candidateService: .carControl
            ).rank,
            RouteError.outOfCatalog("_").rank,
            RouteError.oldGeneration("_").rank,
            RouteError.staleSource("_").rank,
            RouteError.digestMismatch(expected: "_", actual: "_").rank,
            RouteError.schemaVersionMismatch(expected: "_", actual: "_").rank,
            RouteError.payloadInvalid("_").rank,
            RouteError.slotMissing("_").rank,
            RouteError.valueOutOfRange("_").rank,
            RouteError.unknownEnum("_").rank,
            RouteError.riskR1PreconditionUnmet("_").rank,
            RouteError.clarifyRequired(.implicit).rank
        ]
        XCTAssertEqual(ranks, Array(0...15))
    }

    func testRouteErrorCodableRoundTrip() throws {
        let cases: [RouteError] = [
            .riskR0Forbidden("driving forbidden"),
            .unmountedName("bad_tool"),
            .digestMismatch(expected: "aa", actual: "bb"),
            .clarifyRequired(.implicit),
            .valueOutOfRange("50%>range")
        ]
        for original in cases {
            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(RouteError.self, from: data)
            XCTAssertEqual(original, decoded)
        }
    }

    // MARK: - RouteTrace canonical digest

    func testDigestIsStableForIdenticalLoadBearing() throws {
        let a = try makeTrace(turnID: "t", traceID: "tr", execTier: .L2,
                              outcome: .candidate, clarifyTag: .implicit)
        let b = try makeTrace(turnID: "t", traceID: "tr", execTier: .L2,
                              outcome: .candidate, clarifyTag: .implicit)
        XCTAssertEqual(a.traceDigest, b.traceDigest)
    }

    func testDigestFlipsOnLoadBearingChange() throws {
        let a = try makeTrace(outcome: .candidate)
        let b = try makeTrace(outcome: .reject,
                              rejectionReason: .riskR0Forbidden("_"))
        XCTAssertNotEqual(a.traceDigest, b.traceDigest)
    }

    func testDigestMismatchBetweenResultAndTraceRejected() throws {
        // Candidate summary MUST match to get past the summary sync check
        // (which now runs before the digest check for a more specific error).
        let candidate = makeAirControlCandidate()
        let trace = try makeTraceMirroring(candidate, outcome: .candidate)
        // Deliberately wrong digest, matching summary.
        let wrong = String(repeating: "d", count: 64)
        let result = makeResult(
            outcome: .candidate,
            actionCandidate: candidate,
            traceDigest: wrong
        )
        XCTAssertThrowsError(try RouteContractValidator.validate(result, trace: trace)) { error in
            guard case RouteError.digestMismatch(let expected, let actual) = error else {
                return XCTFail("expected .digestMismatch, got \(error)")
            }
            XCTAssertEqual(expected, wrong)
            XCTAssertEqual(actual, trace.traceDigest)
        }
    }

    func testCanonicalJSONSortedKeysDeterministic() throws {
        let subject = RouteSubject(
            routeSchema: "s",
            turnID: "t",
            traceID: "tr",
            sourceIdentity: RouteSourceIdentity(
                matrixSourceSHA256: "aa",
                runtimeContractBundleDigest: "bb"
            ),
            sourceRevision: "rev1",
            staleMarker: nil,
            contractDigest: "cc"
        )
        let a = try RouteCanonicalJSON.sha256Hex(subject)
        let b = try RouteCanonicalJSON.sha256Hex(subject)
        XCTAssertEqual(a, b)
        // Load-bearing change flips digest.
        let subject2 = RouteSubject(
            routeSchema: "s",
            turnID: "t",
            traceID: "tr",
            sourceIdentity: RouteSourceIdentity(
                matrixSourceSHA256: "aa",
                runtimeContractBundleDigest: "bb"
            ),
            sourceRevision: "rev2",  // changed
            staleMarker: nil,
            contractDigest: "cc"
        )
        let c = try RouteCanonicalJSON.sha256Hex(subject2)
        XCTAssertNotEqual(a, c)
    }

    // MARK: - Fixture consumption

    private func fixtureURL(_ subdir: String, _ filename: String) -> URL? {
        // Fixtures live outside the test bundle at contracts/fixtures/typed-route-contract/.
        // Walk up from the test source file location.
        // XCTest runs with cwd = package root when invoked via `swift test`.
        let fm = FileManager.default
        let cwd = fm.currentDirectoryPath
        let path = "\(cwd)/contracts/fixtures/typed-route-contract/\(subdir)/\(filename)"
        return fm.fileExists(atPath: path) ? URL(fileURLWithPath: path) : nil
    }

    func testAirControlPositiveFixtureRoundTripAndValidator() throws {
        guard let url = fixtureURL("positive", "airControl_candidate.json") else {
            throw XCTSkip("fixture path not resolvable — cwd not package root")
        }
        let data = try Data(contentsOf: url)
        let root = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let routeResultData = try JSONSerialization.data(withJSONObject: root["route_result"]!)
        let result = try JSONDecoder().decode(RouteResult.self, from: routeResultData)

        // Reconstruct the trace and verify digest matches the fixture's pinned digest.
        // Load-bearing now includes action_candidate_summary (grok-4.5 review P1-B2 fix).
        let lb = root["route_trace_load_bearing"] as! [String: Any]
        let summaryDict = lb["action_candidate_summary"] as? [String: Any]
        var summary: ActionCandidateSummary? = nil
        if let summaryDict {
            let sumData = try JSONSerialization.data(withJSONObject: summaryDict)
            summary = try JSONDecoder().decode(ActionCandidateSummary.self, from: sumData)
        }
        let trace = RouteTrace(
            turnID: lb["turn_id"] as! String,
            traceID: lb["trace_id"] as! String,
            execTier: RouteExecTier(rawValue: lb["exec_tier"] as! String)!,
            outcome: RouteOutcome(rawValue: lb["outcome"] as! String)!,
            clarifyTag: RouteClarifyTag(rawValue: lb["clarify_tag"] as! String)!,
            rejectionReason: nil,
            actionCandidateSummary: summary,
            redactionPolicyID: lb["redaction_policy_id"] as! String,
            staleMarker: nil,
            traceDigest: ""
        )
        let recomputed = try trace.computeTraceDigest()
        XCTAssertEqual(recomputed, result.traceDigest,
                       "Swift-computed digest must equal pinned fixture digest")
        let boundTrace = try trace.withRecomputedDigest()
        XCTAssertNoThrow(try RouteContractValidator.validate(result, trace: boundTrace))
    }

    func testCarControlPositiveFixtureValidatorAccepts() throws {
        // carControl currently has no mounted D-domain tool
        // (mountedToolNames = {'adjust_ac_temperature_to_number'} airControl only),
        // so the positive route is outcome=clarify with action_candidate=null.
        // jsonl binding intent is preserved in _source.jsonl_binding.
        guard let url = fixtureURL("positive", "carControl_candidate.json") else {
            throw XCTSkip("fixture path not resolvable")
        }
        let data = try Data(contentsOf: url)
        let root = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let resultData = try JSONSerialization.data(withJSONObject: root["route_result"]!)
        let result = try JSONDecoder().decode(RouteResult.self, from: resultData)
        XCTAssertNoThrow(try RouteContractValidator.validate(result))
        XCTAssertEqual(result.service, .carControl)
        XCTAssertEqual(result.outcome, .clarify)
        XCTAssertNil(result.actionCandidate)
        let source = root["_source"] as! [String: Any]
        let binding = source["jsonl_binding"] as! [String: Any]
        XCTAssertEqual(binding["intent"] as? String, "open_window")
    }

    func testCmdPositiveFixtureValidatorAccepts() throws {
        // cmd same situation as carControl (see comment above).
        guard let url = fixtureURL("positive", "cmd_candidate.json") else {
            throw XCTSkip("fixture path not resolvable")
        }
        let data = try Data(contentsOf: url)
        let root = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let resultData = try JSONSerialization.data(withJSONObject: root["route_result"]!)
        let result = try JSONDecoder().decode(RouteResult.self, from: resultData)
        XCTAssertNoThrow(try RouteContractValidator.validate(result))
        XCTAssertEqual(result.service, .cmd)
        XCTAssertEqual(result.outcome, .clarify)
        XCTAssertNil(result.actionCandidate)
        let source = root["_source"] as! [String: Any]
        let binding = source["jsonl_binding"] as! [String: Any]
        XCTAssertEqual(binding["intent"] as? String, "open_bluetooth")
    }

    func testUnmountedToolFixtureRejected() throws {
        guard let url = fixtureURL("negative", "unmounted_tool_name.json") else {
            throw XCTSkip("fixture path not resolvable")
        }
        let data = try Data(contentsOf: url)
        let root = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let resultData = try JSONSerialization.data(withJSONObject: root["route_result"]!)
        let result = try JSONDecoder().decode(RouteResult.self, from: resultData)
        XCTAssertThrowsError(try RouteContractValidator.validate(result)) { error in
            guard case RouteError.unmountedName = error else {
                return XCTFail("expected .unmountedName, got \(error)")
            }
        }
    }

    func testIllegalCombinationFixtureRejected() throws {
        guard let url = fixtureURL("negative", "illegal_combination_candidate_without_action.json") else {
            throw XCTSkip("fixture path not resolvable")
        }
        let data = try Data(contentsOf: url)
        let root = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let resultData = try JSONSerialization.data(withJSONObject: root["route_result"]!)
        let result = try JSONDecoder().decode(RouteResult.self, from: resultData)
        XCTAssertThrowsError(try RouteContractValidator.validate(result)) { error in
            guard case RouteError.illegalCombination = error else {
                return XCTFail("expected .illegalCombination, got \(error)")
            }
        }
    }

    func testSchemaVersionDriftFixtureRejected() throws {
        guard let url = fixtureURL("negative", "schema_version_drift.json") else {
            throw XCTSkip("fixture path not resolvable")
        }
        let data = try Data(contentsOf: url)
        let root = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let resultData = try JSONSerialization.data(withJSONObject: root["route_result"]!)
        let result = try JSONDecoder().decode(RouteResult.self, from: resultData)
        XCTAssertThrowsError(try RouteContractValidator.validate(result)) { error in
            guard case RouteError.schemaVersionMismatch = error else {
                return XCTFail("expected .schemaVersionMismatch, got \(error)")
            }
        }
    }

    // MARK: - grok-4.5 xAI review P1 fixes — new tests

    /// P1-A2: kinship gate — service must match tool's jsonl-verified binding.
    func testCrossDomainMountedToolRejected() throws {
        // Construct a candidate with a mounted tool from airControl but
        // service=carControl. Existence check passes (tool IS mounted);
        // kinship gate must catch the cross-service violation.
        let badCandidate = ActionCandidate(
            intent: "adjust_ac_temperature_to_number",
            service: .carControl,  // wrong — tool binds to airControl per jsonl
            mountedToolName: "adjust_ac_temperature_to_number",
            actionPrimitive: "adjust_to_number",
            actionCode: "adjust_value_to_specific_value",
            device: "ac_temperature",
            slot: "adjustment_mode+temperature",
            slotKeys: ["adjustment_mode", "temperature"],
            value: RouteValueFourTuple()
        )
        let result = makeResult(
            outcome: .candidate,
            service: .carControl,  // must match candidate.service to pass the earlier check
            actionCandidate: badCandidate,
            traceDigest: String(repeating: "0", count: 64)
        )
        XCTAssertThrowsError(try RouteContractValidator.validate(result)) { error in
            guard case RouteError.crossDomainMountedTool(let tool, let bound, let cand) = error else {
                return XCTFail("expected .crossDomainMountedTool, got \(error)")
            }
            XCTAssertEqual(tool, "adjust_ac_temperature_to_number")
            XCTAssertEqual(bound, .airControl)
            XCTAssertEqual(cand, .carControl)
        }
    }

    func testCrossServiceMountBindingFixtureRejected() throws {
        guard let url = fixtureURL("negative", "cross_service_mount_binding.json") else {
            throw XCTSkip("fixture path not resolvable")
        }
        let data = try Data(contentsOf: url)
        let root = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let resultData = try JSONSerialization.data(withJSONObject: root["route_result"]!)
        let result = try JSONDecoder().decode(RouteResult.self, from: resultData)
        XCTAssertThrowsError(try RouteContractValidator.validate(result)) { error in
            guard case RouteError.crossDomainMountedTool = error else {
                return XCTFail("expected .crossDomainMountedTool, got \(error)")
            }
        }
    }

    /// P1-A2 invariant — every mounted tool has a service binding in the map.
    /// Guards against catalog expansion without updating the projection.
    func testMountedToolServiceMapCoversCatalog() {
        for tool in DDomainMountedToolCatalog.mountedToolNames {
            XCTAssertNotNil(
                MountedToolServiceMap.service(for: tool),
                "MountedToolServiceMap missing binding for mounted tool '\(tool)'. When catalog expands, update Core/Contracts/RouteContract.swift MountedToolServiceMap.bindings with the jsonl-verified service."
            )
        }
    }

    /// P1-B6: forbidden-key inspection at decode time.
    func testForbiddenKeySessionIdCaughtByDecodeGuard() {
        let json = """
        {
          "schema_version": "typed_route_contract.v1",
          "route_schema": "route_schema.demo.v1",
          "turn_id": "t1",
          "trace_id": "tr1",
          "exec_tier": "L2",
          "outcome": "clarify",
          "clarify_tag": "implicit",
          "service": "airControl",
          "action_candidate": null,
          "trace_digest": "0000000000000000000000000000000000000000000000000000000000000000",
          "rejection_reason": null,
          "session_id": "leaked-session-000001"
        }
        """.data(using: .utf8)!
        XCTAssertThrowsError(try RouteResult.decodeRejectingForbiddenKeys(from: json)) { error in
            guard case RouteError.forbiddenKey(let field) = error else {
                return XCTFail("expected .forbiddenKey, got \(error)")
            }
            XCTAssertTrue(field.contains("session_id"), "expected session_id in \(field)")
        }
    }

    func testForbiddenKeyEventIdCaughtByDecodeGuard() {
        let json = """
        {"schema_version":"typed_route_contract.v1","route_schema":"r","turn_id":"t","trace_id":"tr","exec_tier":"L2","outcome":"clarify","clarify_tag":"implicit","service":"airControl","action_candidate":null,"trace_digest":"0","rejection_reason":null,"event_id":"leak"}
        """.data(using: .utf8)!
        XCTAssertThrowsError(try RouteResult.decodeRejectingForbiddenKeys(from: json)) { error in
            guard case RouteError.forbiddenKey = error else {
                return XCTFail("expected .forbiddenKey, got \(error)")
            }
        }
    }

    func testForbiddenKeyRawPromptCaughtOnTrace() {
        let json = """
        {"schema_version":"typed_route_contract.v1","turn_id":"t","trace_id":"tr","exec_tier":"L2","outcome":"clarify","clarify_tag":"implicit","rejection_reason":null,"action_candidate_summary":null,"redaction_policy_id":"redaction_policy.v1","stale_marker":null,"trace_digest":"0","raw_prompt":"customer said hello"}
        """.data(using: .utf8)!
        XCTAssertThrowsError(try RouteTrace.decodeRejectingForbiddenKeys(from: json)) { error in
            guard case RouteError.forbiddenKey(let field) = error else {
                return XCTFail("expected .forbiddenKey, got \(error)")
            }
            XCTAssertTrue(field.contains("raw_prompt"))
        }
    }

    func testForbiddenKeyPassthroughForRouteSubject() {
        // RouteSubject also gets guarded — session_id must not appear.
        let json = """
        {"schema_version":"typed_route_contract.v1","route_schema":"r","turn_id":"t","trace_id":"tr","source_identity":{"matrix_source_sha256":"aa","runtime_contract_bundle_digest":"bb"},"source_revision":"rev1","stale_marker":null,"contract_digest":"cc","session_id":"leak"}
        """.data(using: .utf8)!
        XCTAssertThrowsError(try RouteSubject.decodeRejectingForbiddenKeys(from: json)) { error in
            guard case RouteError.forbiddenKey = error else {
                return XCTFail("expected .forbiddenKey, got \(error)")
            }
        }
    }

    /// P1-B2: trace_digest covers action_candidate payload — tampering flips digest.
    func testTraceDigestCoversMountedToolNameTampering() throws {
        let candidate = makeAirControlCandidate()
        let goodTrace = try makeTraceMirroring(candidate, outcome: .candidate)

        // Same result outcome-axis facts, but candidate mounted_tool_name
        // "tampered" — well, we can only tamper with an in-catalog tool, so
        // simulate by swapping to another summary. Use a fresh candidate
        // whose value four-tuple differs.
        let tamperedCandidate = ActionCandidate(
            intent: candidate.intent,
            service: candidate.service,
            mountedToolName: candidate.mountedToolName,
            actionPrimitive: candidate.actionPrimitive,
            actionCode: "adjust_position_value_to_specific_value", // tampered
            device: candidate.device,
            slot: candidate.slot,
            slotKeys: candidate.slotKeys,
            value: candidate.value
        )
        let tamperedTrace = try makeTraceMirroring(tamperedCandidate, outcome: .candidate)

        XCTAssertNotEqual(
            goodTrace.traceDigest, tamperedTrace.traceDigest,
            "trace_digest MUST flip when action_candidate.action_code is tampered"
        )
    }

    func testTraceDigestCoversValueFourTupleTampering() throws {
        let clean = makeAirControlCandidate()
        let tampered = ActionCandidate(
            intent: clean.intent,
            service: clean.service,
            mountedToolName: clean.mountedToolName,
            actionPrimitive: clean.actionPrimitive,
            actionCode: clean.actionCode,
            device: clean.device,
            slot: clean.slot,
            slotKeys: clean.slotKeys,
            value: RouteValueFourTuple(ref: .CUR, direct: .plus, offset: .literal("5"), type: .SPOT)
        )
        let a = try makeTraceMirroring(clean, outcome: .candidate)
        let b = try makeTraceMirroring(tampered, outcome: .candidate)
        XCTAssertNotEqual(a.traceDigest, b.traceDigest,
                          "trace_digest MUST flip when value four-tuple is tampered")
    }

    func testCandidateSummaryMismatchTrappedBeforeDigest() throws {
        let candidateA = makeAirControlCandidate()
        let candidateB = makeCarControlCandidate()  // different summary

        // Trace mirrors A, result carries B — summary mismatch fires.
        let trace = try makeTraceMirroring(candidateA, outcome: .candidate)
        let result = makeResult(
            outcome: .candidate,
            service: .airControl,
            actionCandidate: ActionCandidate(
                intent: "adjust_ac_temperature_to_number",
                service: .airControl,
                // Take mounted name from A (in-catalog) but summary fields from B.
                mountedToolName: candidateA.mountedToolName,
                actionPrimitive: "power_on",  // different from A's adjust_to_number
                actionCode: candidateB.actionCode,
                device: candidateA.device,
                slot: candidateA.slot,
                slotKeys: candidateA.slotKeys,
                value: candidateA.value
            ),
            traceDigest: trace.traceDigest
        )
        XCTAssertThrowsError(try RouteContractValidator.validate(result, trace: trace)) { error in
            guard case RouteError.illegalCombination(let msg) = error else {
                return XCTFail("expected .illegalCombination, got \(error)")
            }
            XCTAssertTrue(
                msg.contains("action_candidate.summary") || msg.contains("candidate_summary"),
                "expected mismatch reason to mention summary; got: \(msg)"
            )
        }
    }
}
