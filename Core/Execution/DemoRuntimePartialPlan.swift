import Foundation

public enum DemoRuntimePartialPlanError: Error, Equatable, Sendable {
    case subactionLimitExceeded(limit: Int, actual: Int)
    case refusedSubactionMutatedState(frameID: String)
}

public enum DemoRuntimePartialSubactionDisposition: String, Equatable, Sendable {
    case accepted
    case refused
}

public struct DemoRuntimePartialSubactionResult: Equatable, Sendable {
    public var frameID: String
    public var disposition: DemoRuntimePartialSubactionDisposition
    public var readbacks: [DemoActionReadback]
    public var finiteReason: String?
    public var observedToolCallCount: Int
    public var observedReadbackCount: Int
    public var stateMutation: Bool

    public init(
        frameID: String,
        disposition: DemoRuntimePartialSubactionDisposition,
        readbacks: [DemoActionReadback],
        finiteReason: String?,
        observedToolCallCount: Int,
        observedReadbackCount: Int,
        stateMutation: Bool
    ) {
        self.frameID = frameID
        self.disposition = disposition
        self.readbacks = readbacks
        self.finiteReason = finiteReason
        self.observedToolCallCount = observedToolCallCount
        self.observedReadbackCount = observedReadbackCount
        self.stateMutation = stateMutation
    }
}

public struct DemoRuntimePartialPlanResult: Equatable, Sendable {
    public var traceID: String
    public var subactions: [DemoRuntimePartialSubactionResult]

    public init(traceID: String, subactions: [DemoRuntimePartialSubactionResult]) {
        self.traceID = traceID
        self.subactions = subactions
    }

    public var acceptedReadbacks: [DemoActionReadback] {
        subactions.flatMap(\.readbacks)
    }

    public var hasAccepted: Bool {
        subactions.contains { $0.disposition == .accepted }
    }

    public var hasRefused: Bool {
        subactions.contains { $0.disposition == .refused }
    }
}

public struct DemoRuntimePartialPlan: Sendable {
    public static let maximumSubactionCount = 2

    public init() {}

    public static func isReviewed(_ frame: ToolCallFrame) -> Bool {
        frame.candidateSource == .fastPath || DDomainIRMap.irMapCompiled[frame.toolName] != nil
    }

    @MainActor
    public func execute(
        frames: [ToolCallFrame],
        store: DemoVehicleStateStore,
        pipeline: C3ExecutionPipeline,
        traceLogger: any TraceLogger,
        alignsFrameStateRevisionToStore: Bool
    ) throws -> DemoRuntimePartialPlanResult {
        guard frames.count <= Self.maximumSubactionCount else {
            throw DemoRuntimePartialPlanError.subactionLimitExceeded(
                limit: Self.maximumSubactionCount,
                actual: frames.count
            )
        }

        let traceID = frames.first?.traceID ?? UUID().uuidString
        var subactions: [DemoRuntimePartialSubactionResult] = []
        for candidate in frames {
            var frame = candidate
            frame.traceID = traceID
            if alignsFrameStateRevisionToStore {
                frame.stateRevision = store.currentRevision
            }

            let before = canonicalState(store)
            if let finiteReason = preflightFiniteReason(for: frame) {
                subactions.append(
                    try refusedSubaction(
                        frame: frame,
                        before: before,
                        finiteReason: finiteReason,
                        store: store,
                        traceID: traceID,
                        traceLogger: traceLogger
                    )
                )
                continue
            }

            do {
                let result = try pipeline.execute(frame, store: store, traceLogger: traceLogger)
                let after = canonicalState(store)
                let item = DemoRuntimePartialSubactionResult(
                    frameID: frame.id,
                    disposition: .accepted,
                    readbacks: result.readbacks,
                    finiteReason: nil,
                    observedToolCallCount: 1,
                    observedReadbackCount: result.readbacks.count,
                    stateMutation: before != after
                )
                record(item, traceID: traceID, traceLogger: traceLogger)
                subactions.append(item)
            } catch ToolExecutionError.guardDenied {
                subactions.append(
                    try refusedSubaction(
                        frame: frame,
                        before: before,
                        finiteReason: "safety_or_policy_refusal",
                        store: store,
                        traceID: traceID,
                        traceLogger: traceLogger
                    )
                )
            } catch ToolExecutionError.staleState {
                subactions.append(
                    try refusedSubaction(
                        frame: frame,
                        before: before,
                        finiteReason: "stale_state_revision",
                        store: store,
                        traceID: traceID,
                        traceLogger: traceLogger
                    )
                )
            } catch ToolExecutionError.semanticInvalid {
                subactions.append(
                    try refusedSubaction(
                        frame: frame,
                        before: before,
                        finiteReason: "unsupported_tool_plan",
                        store: store,
                        traceID: traceID,
                        traceLogger: traceLogger
                    )
                )
            } catch let ToolExecutionError.schemaInvalid(reason) {
                let finiteReason: String
                switch reason {
                case .missingField:
                    finiteReason = "clarify_missing_slot"
                default:
                    finiteReason = "unsupported_tool_plan"
                }
                subactions.append(
                    try refusedSubaction(
                        frame: frame,
                        before: before,
                        finiteReason: finiteReason,
                        store: store,
                        traceID: traceID,
                        traceLogger: traceLogger
                    )
                )
            }
        }

        return DemoRuntimePartialPlanResult(traceID: traceID, subactions: subactions)
    }

    private func preflightFiniteReason(for frame: ToolCallFrame) -> String? {
        guard frame.candidateSource != .fastPath else {
            return nil
        }
        guard DDomainMountedToolCatalog.mountedToolNames.contains(frame.toolName) else {
            return "unmounted_tool_name"
        }
        return nil
    }

    @MainActor
    private func refusedSubaction(
        frame: ToolCallFrame,
        before: [String],
        finiteReason: String,
        store: DemoVehicleStateStore,
        traceID: String,
        traceLogger: any TraceLogger
    ) throws -> DemoRuntimePartialSubactionResult {
        let after = canonicalState(store)
        guard before == after else {
            throw DemoRuntimePartialPlanError.refusedSubactionMutatedState(frameID: frame.id)
        }
        let item = DemoRuntimePartialSubactionResult(
            frameID: frame.id,
            disposition: .refused,
            readbacks: [],
            finiteReason: finiteReason,
            observedToolCallCount: 0,
            observedReadbackCount: 0,
            stateMutation: false
        )
        record(item, traceID: traceID, traceLogger: traceLogger)
        return item
    }

    @MainActor
    private func canonicalState(_ store: DemoVehicleStateStore) -> [String] {
        store.cells.map { "\($0.key)=\($0.actualValue)@\($0.revision)" }
    }

    private func record(
        _ item: DemoRuntimePartialSubactionResult,
        traceID: String,
        traceLogger: any TraceLogger
    ) {
        let message = "partial_subaction:\(item.frameID):\(item.disposition.rawValue):tool_call_count=\(item.observedToolCallCount):readback_count=\(item.observedReadbackCount):state_mutation=\(item.stateMutation)"
        let attributes = TraceAttributes(
            toolCallCount: item.observedToolCallCount,
            guardReason: item.finiteReason,
            readbackResult: item.disposition == .accepted ? .verified : .notApplicable,
            finiteReason: item.finiteReason
        )
        switch item.disposition {
        case .accepted:
            traceLogger.recordPlan(traceID: traceID, message: message, attributes: attributes)
        case .refused:
            traceLogger.recordGuard(traceID: traceID, message: message, attributes: attributes)
        }
    }
}
