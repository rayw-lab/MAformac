import Foundation

/// Route-level RuntimeTurnReceipt v2 assembler (G6 / B08 / B10).
///
/// Lives **outside** `DemoRuntimeSessionRunner`. Call on MainActor after the
/// route result is known and before the next await suspension when possible.
@MainActor
public enum RuntimeTurnReceiptAssembler {
    public static let virtualReadbackKeyPrefix = "presentation."

    /// Assemble unique v2 receipt from turn identity + optional route result.
    /// When `routeResult` is nil, treats the turn as runner=0 containment refusal.
    public static func assemble(
        turn: FrontstageVoiceTurn,
        routeResult: DemoSliceRouteResult?,
        configuration: FrontstageRouteReceiptConfiguration,
        linkedPreviousTurnID: String? = nil,
        mountReceiptBodySHA256: String? = nil
    ) throws -> RuntimeTurnReceipt {
        let built = try buildEvidence(turn: turn, routeResult: routeResult)
        let catalogDigest = mountedCatalogDigest()
        let codeHead = configuration.sourceHeadSHA
            ?? C6Hash.sha256Hex(Data("local_unpinned_code_head".utf8))
        let mountDigest = mountReceiptBodySHA256
            ?? Self.mountReceiptBodySHA256(from: nil)
        let touchedDigest = touchedCellCanonicalSnapshotDigest(from: built.businessReadbacks)

        return RuntimeTurnReceipt(
            runID: configuration.runID,
            runNonce: configuration.runNonce,
            sourceHeadSHA: configuration.sourceHeadSHA,
            testedCheckoutSHA: configuration.sourceHeadSHA,
            sessionID: turn.sessionID,
            turnID: turn.turnID,
            eventID: built.eventID,
            sequence: turn.sequence,
            matrixID: built.matrixID,
            matrixSourceSHA256: DemoCapabilityMatrixCatalog.sourceSHA256,
            runtimeContractBundleDigest: DemoRuntimeContractBundleCatalog.runtimeContractBundleDigest,
            appExecutableSHA256: try RuntimeTurnReceipt.executableSHA256(),
            finalOutcome: built.finalOutcome,
            stateMutation: built.stateMutation,
            readbackCount: built.businessReadbacks.count,
            mountReceiptBodySHA256: mountDigest,
            codeHeadDigest: codeHead,
            mountedCatalogDigest: catalogDigest,
            touchedCellCanonicalSnapshotDigest: touchedDigest,
            linkedPreviousTurnID: linkedPreviousTurnID,
            actions: built.actions
        )
    }

    /// Assemble then atomically write with dual `isCurrent` guards (tmp + rename).
    @discardableResult
    public static func assembleAndWrite(
        turn: FrontstageVoiceTurn,
        routeResult: DemoSliceRouteResult?,
        configuration: FrontstageRouteReceiptConfiguration,
        isCurrent: () -> Bool,
        linkedPreviousTurnID: String? = nil,
        mountReceiptBodySHA256: String? = nil
    ) throws -> URL? {
        guard isCurrent() else { return nil }
        let receipt = try assemble(
            turn: turn,
            routeResult: routeResult,
            configuration: configuration,
            linkedPreviousTurnID: linkedPreviousTurnID,
            mountReceiptBodySHA256: mountReceiptBodySHA256
        )
        return try FrontstageRouteReceiptWriter.writeCurrent(
            receipt,
            configuration: configuration,
            isCurrent: isCurrent
        )
    }

    public static func isVirtualReadbackKey(_ key: String) -> Bool {
        key.hasPrefix(virtualReadbackKeyPrefix)
    }

    /// Fact-recomputable mount body digest (G6 knife2). Absent body uses stable sentinel.
    public static func mountReceiptBodySHA256(from body: Data?) -> String {
        guard let body else {
            return C6Hash.sha256Hex(Data("mount_receipt_absent".utf8))
        }
        return C6Hash.sha256Hex(body)
    }

    /// Fact-recomputable mounted catalog digest (G6 knife2). Independent of live store.
    public static func mountedCatalogDigest(
        catalog: DemoSliceAdmissionCatalog = DemoSliceAdmissionCatalog()
    ) -> String {
        catalog.catalogDigestSHA256
    }

    /// Fact-recomputable touched-cell snapshot digest (G6 knife2).
    /// Multi-cell: key-sorted; excludes `presentation.*` virtual readbacks; trailing newline.
    public static func touchedCellCanonicalSnapshotDigest(
        from readbacks: [DemoActionReadback]
    ) -> String {
        let lines = readbacks
            .filter { !isVirtualReadbackKey($0.key) }
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.actualValue)@\($0.revision)" }
            .joined(separator: "\n")
        return C6Hash.sha256Hex(Data((lines + "\n").utf8))
    }

    // MARK: - Evidence build

    private struct BuiltEvidence {
        let finalOutcome: DemoRuntimeResult
        let stateMutation: Bool
        let eventID: String
        let matrixID: Int?
        let businessReadbacks: [DemoActionReadback]
        let actions: [RuntimeTurnActionEvidence]
    }

    private static func buildEvidence(
        turn: FrontstageVoiceTurn,
        routeResult: DemoSliceRouteResult?
    ) throws -> BuiltEvidence {
        guard let routeResult else {
            // runner=0 containment / GateCLI path: identity turn carries refusal.
            return BuiltEvidence(
                finalOutcome: turn.outcome.result,
                stateMutation: turn.stateMutation,
                eventID: turn.eventID,
                matrixID: nil,
                businessReadbacks: turn.readbacks.filter { !isVirtualReadbackKey($0.key) },
                actions: [
                    RuntimeTurnActionEvidence(
                        actionIndex: 0,
                        disposition: disposition(for: turn.outcome.result, stateMutation: turn.stateMutation),
                        failureReason: stableFailureReason(from: turn.outcome),
                        readback: nil,
                        isVirtualReadback: false
                    )
                ]
            )
        }

        if let execution = routeResult.execution {
            return buildExecution(execution, fallbackEventID: turn.eventID)
        }
        if let readOnly = routeResult.readOnly {
            return buildReadOnly(readOnly, fallbackEventID: turn.eventID)
        }
        if let rejection = routeResult.rejection {
            return buildRejection(rejection, turn: turn)
        }
        // Unreachable by DemoSliceRouteResult precondition; fail closed.
        return BuiltEvidence(
            finalOutcome: .runtimeError,
            stateMutation: false,
            eventID: turn.eventID,
            matrixID: nil,
            businessReadbacks: [],
            actions: [
                RuntimeTurnActionEvidence(
                    actionIndex: 0,
                    disposition: "error",
                    failureReason: "empty_route_result",
                    isVirtualReadback: false
                )
            ]
        )
    }

    private static func buildExecution(
        _ execution: DemoSliceExecution,
        fallbackEventID: String
    ) -> BuiltEvidence {
        let payload = execution.payload
        let frame = execution.admission.frame
        let entry = execution.admission.entry
        let allReadbacks = payload.readbacks
        let business = allReadbacks.filter { !isVirtualReadbackKey($0.key) }
        let mutation = payload.mutationCount > 0
        let primary = business.first ?? allReadbacks.first
        let virtual = primary.map { isVirtualReadbackKey($0.key) } ?? false
        let after = primary?.revision
        let before: Int? = {
            guard let after, mutation else { return after }
            return max(0, after - 1)
        }()
        let action = RuntimeTurnActionEvidence(
            actionIndex: 0,
            frameIdentity: frame.id,
            contractIdentity: entry.contractRowID,
            toolName: frame.toolName,
            deviceName: frame.device,
            actionName: frame.actionPrimitive,
            slotsIdentity: slotsIdentity(frame.slots),
            subjectType: entry.subject.type,
            subjectID: entry.subject.id,
            disposition: disposition(for: payload.outcome.result, stateMutation: mutation),
            failureReason: stableFailureReason(from: payload.outcome),
            policyDecision: nil,
            beforeRevision: mutation ? before : nil,
            afterRevision: mutation ? after : nil,
            readback: mutation ? primary : nil,
            replayRef: nil,
            isVirtualReadback: virtual
        )
        return BuiltEvidence(
            finalOutcome: payload.outcome.result,
            stateMutation: mutation,
            eventID: payload.eventID ?? fallbackEventID,
            matrixID: entry.matrixID,
            businessReadbacks: business,
            actions: [action]
        )
    }

    private static func buildReadOnly(
        _ readOnly: DemoSliceReadOnlyOutcome,
        fallbackEventID: String
    ) -> BuiltEvidence {
        let payload = readOnly.payload
        let allReadbacks = payload.readbacks
        let business = allReadbacks.filter { !isVirtualReadbackKey($0.key) }
        let virtualPrimary = allReadbacks.first { isVirtualReadbackKey($0.key) }
        let dispositionTag: String
        switch readOnly.classification {
        case .cancel:
            dispositionTag = payload.outcome.result == .cancelled ? "cancelled" : "no_op"
        case .stateQuery:
            dispositionTag = "state_query"
        case .capabilityQuery:
            dispositionTag = "capability_query"
        default:
            dispositionTag = disposition(for: payload.outcome.result, stateMutation: false)
        }
        let action = RuntimeTurnActionEvidence(
            actionIndex: 0,
            disposition: dispositionTag,
            failureReason: stableFailureReason(from: payload.outcome),
            beforeRevision: nil,
            afterRevision: nil,
            readback: virtualPrimary ?? business.first,
            isVirtualReadback: virtualPrimary != nil
        )
        return BuiltEvidence(
            finalOutcome: payload.outcome.result,
            stateMutation: false,
            eventID: payload.eventID ?? fallbackEventID,
            matrixID: nil,
            businessReadbacks: business,
            actions: [action]
        )
    }

    private static func buildRejection(
        _ rejection: DemoSliceAdmissionRejection,
        turn: FrontstageVoiceTurn
    ) -> BuiltEvidence {
        let outcome: DemoRuntimeResult
        switch rejection {
        case .clarifyMissingSlot:
            outcome = .clarifyMissingSlot
        case .valueOutOfRange, .blank:
            outcome = .refusalContractViolation
        case .notInCatalog, .conjunctionOrMultiIntent, .cancel:
            outcome = .refusalNoAvailableTool
        }
        // Range refusal must not be labeled as risk/policy refusal.
        let failure: String
        let policy: String?
        switch rejection {
        case .blank:
            failure = "blank"
            policy = nil
        case .notInCatalog:
            failure = "not_in_catalog"
            policy = nil
        case .valueOutOfRange(let actual, let allowed):
            failure = "value_out_of_range:\(actual):\(allowed.lowerBound)-\(allowed.upperBound)"
            policy = "range_refusal"
        case .clarifyMissingSlot:
            failure = "clarify_missing_slot"
            policy = nil
        case .conjunctionOrMultiIntent:
            failure = "conjunction_or_multi_intent"
            policy = nil
        case .cancel(let target):
            failure = target.map { "cancel_\($0)" } ?? "user_cancelled"
            policy = nil
        }
        let action = RuntimeTurnActionEvidence(
            actionIndex: 0,
            disposition: "refused",
            failureReason: failure,
            policyDecision: policy,
            beforeRevision: nil,
            afterRevision: nil,
            readback: nil,
            isVirtualReadback: false
        )
        return BuiltEvidence(
            finalOutcome: outcome,
            stateMutation: false,
            eventID: turn.eventID,
            matrixID: nil,
            businessReadbacks: [],
            actions: [action]
        )
    }

    private static func disposition(for result: DemoRuntimeResult, stateMutation: Bool) -> String {
        switch result {
        case .acceptedToolCall:
            return stateMutation ? "accepted" : "no_op"
        case .alreadyStateNoop, .noAction:
            return "no_op"
        case .cancelled:
            return "cancelled"
        case .stateQuery:
            return "state_query"
        case .capabilityQuery:
            return "capability_query"
        case .refusalNoAvailableTool, .refusalSafetyOrPolicy, .refusalContractViolation, .clarifyMissingSlot:
            return "refused"
        case .runtimeError, .interrupted, .partialAcceptPartialRefuse:
            return "error"
        }
    }

    private static func stableFailureReason(from outcome: DemoRuntimeOutcome) -> String? {
        guard let reason = outcome.reason?.trimmingCharacters(in: .whitespacesAndNewlines), !reason.isEmpty else {
            return nil
        }
        return reason
    }

    private static func slotsIdentity(_ slots: [String: String]) -> String {
        slots.keys.sorted().map { key in
            "\(key)=\(slots[key] ?? "")"
        }.joined(separator: "&")
    }

}
