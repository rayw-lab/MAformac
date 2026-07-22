import Foundation

public enum DemoRuntimePartialPlanError: Error, Equatable, Sendable {
    case subactionLimitExceeded(limit: Int, actual: Int)
    case atomicRollbackFailed
}

/// Bounded multi-frame execution policy.
/// Atomic rolls back the whole plan; partial isolates each reviewed subaction.
public enum DemoRuntimeAtomicityContract: String, Equatable, Sendable {
    case atomic = "atomic"
    case partial = "partial"
}

public enum DemoRuntimePartialSubactionDisposition: String, Equatable, Sendable {
    case accepted
    case refused
}

public struct DemoRuntimePartialSubactionResult: Equatable, Sendable {
    public var frameID: String
    public var disposition: DemoRuntimePartialSubactionDisposition
    public var readbacks: [DemoActionReadback]
    public var finiteReason: RuntimeFiniteReason?
    public var observedToolCallCount: Int
    public var observedReadbackCount: Int
    public var stateMutation: Bool
    /// Provenance-sourced mutation count for this subaction (§3.4).
    /// Only `.firstExecution` counts; `.alreadyStateNoop`/`.retryReplay` are zero.
    public var mutationCount: Int

    public init(
        frameID: String,
        disposition: DemoRuntimePartialSubactionDisposition,
        readbacks: [DemoActionReadback],
        finiteReason: RuntimeFiniteReason?,
        observedToolCallCount: Int,
        observedReadbackCount: Int,
        stateMutation: Bool,
        mutationCount: Int = 0
    ) {
        self.frameID = frameID
        self.disposition = disposition
        self.readbacks = readbacks
        self.finiteReason = finiteReason
        self.observedToolCallCount = observedToolCallCount
        self.observedReadbackCount = observedReadbackCount
        self.stateMutation = stateMutation
        self.mutationCount = mutationCount
    }
}

public struct DemoRuntimePartialPlanResult: Equatable, Sendable {
    public var traceID: String
    public var subactions: [DemoRuntimePartialSubactionResult]
    /// The atomicity contract governing this multi-frame execution.
    /// `.partial` preserves successful subactions while failed subactions roll back individually.
    public var atomicityContract: DemoRuntimeAtomicityContract

    public init(traceID: String, subactions: [DemoRuntimePartialSubactionResult], atomicityContract: DemoRuntimeAtomicityContract) {
        self.traceID = traceID
        self.subactions = subactions
        self.atomicityContract = atomicityContract
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

    /// Total mutation count across all accepted subactions (§3.4).
    public var mutationCount: Int {
        subactions.reduce(0) { $0 + $1.mutationCount }
    }
}

public struct DemoRuntimePartialPlan: Sendable {
    public static let maximumSubactionCount = 2

    private struct AtomicFrameExecutionFailure: Error {
        var frameID: String
        var finiteReason: RuntimeFiniteReason
    }

    public init() {}

    public static func isReviewed(_ frame: ToolCallFrame) -> Bool {
        frame.candidateSource == .fastPath || DDomainIRMap.irMapCompiled[frame.toolName] != nil
    }

    @MainActor
    public func execute(
        plan: RuntimePlan,
        store: DemoVehicleStateStore,
        pipeline: C3ExecutionPipeline,
        traceLogger: any TraceLogger,
        alignsFrameStateRevisionToStore: Bool
    ) throws -> DemoRuntimePartialPlanResult {
        let frames = plan.toolFrames
        guard frames.count == plan.frames.count else {
            throw RuntimePlanError.controlFrameMustBeSingle
        }
        guard frames.count <= Self.maximumSubactionCount else {
            throw DemoRuntimePartialPlanError.subactionLimitExceeded(
                limit: Self.maximumSubactionCount,
                actual: frames.count
            )
        }

        traceLogger.recordPlan(
            traceID: plan.traceID,
            message: "runtime_plan_policy:\(plan.executionPolicy.rawValue)",
            attributes: TraceAttributes(toolCallCount: frames.count)
        )
        switch plan.executionPolicy {
        case .atomic:
            return try executeAtomic(
                frames: frames,
                traceID: plan.traceID,
                store: store,
                pipeline: pipeline,
                traceLogger: traceLogger,
                alignsFrameStateRevisionToStore: alignsFrameStateRevisionToStore
            )
        case .partial:
            return try executePartial(
                frames: frames,
                traceID: plan.traceID,
                store: store,
                pipeline: pipeline,
                traceLogger: traceLogger,
                alignsFrameStateRevisionToStore: alignsFrameStateRevisionToStore
            )
        }
    }

    @MainActor
    private func executePartial(
        frames: [ToolCallFrame],
        traceID: String,
        store: DemoVehicleStateStore,
        pipeline: C3ExecutionPipeline,
        traceLogger: any TraceLogger,
        alignsFrameStateRevisionToStore: Bool
    ) throws -> DemoRuntimePartialPlanResult {
        var items: [DemoRuntimePartialSubactionResult] = []
        items.reserveCapacity(frames.count)

        for candidate in frames {
            let frame = preparedFrame(
                candidate,
                traceID: traceID,
                stateRevision: alignsFrameStateRevisionToStore ? store.currentRevision : nil
            )
            let item: DemoRuntimePartialSubactionResult
            if let reason = preflightFiniteReason(for: frame) {
                item = refusedSubaction(frame: frame, finiteReason: reason)
            } else {
                let before = canonicalState(store)
                do {
                    let result = try pipeline.withAtomicRuntimeTransaction(store: store) {
                        try pipeline.execute(frame, store: store, traceLogger: traceLogger)
                    }
                    item = acceptedSubaction(
                        frame: frame,
                        result: result,
                        before: before,
                        store: store
                    )
                } catch C3ExecutionTransactionError.rollbackFailed {
                    throw DemoRuntimePartialPlanError.atomicRollbackFailed
                } catch {
                    item = refusedSubaction(frame: frame, finiteReason: finiteReason(for: error))
                }
            }
            record(item, traceID: traceID, traceLogger: traceLogger)
            items.append(item)
        }

        return DemoRuntimePartialPlanResult(
            traceID: traceID,
            subactions: items,
            atomicityContract: .partial
        )
    }


    @MainActor
    private func executeAtomic(
        frames: [ToolCallFrame],
        traceID: String,
        store: DemoVehicleStateStore,
        pipeline: C3ExecutionPipeline,
        traceLogger: any TraceLogger,
        alignsFrameStateRevisionToStore: Bool
    ) throws -> DemoRuntimePartialPlanResult {
        let scratch = DemoVehicleStateStore(cells: store.cells)
        var prepared: [ToolCallFrame] = []
        for candidate in frames {
            let frame = preparedFrame(
                candidate,
                traceID: traceID,
                stateRevision: alignsFrameStateRevisionToStore ? scratch.currentRevision : nil
            )
            if let reason = preflightFiniteReason(for: frame) {
                return atomicRefusal(
                    frames: frames,
                    traceID: traceID,
                    failingFrameID: frame.id,
                    finiteReason: reason,
                    traceLogger: traceLogger
                )
            }
            do {
                let preflight = try pipeline.preflight(frame, store: scratch)
                for transition in preflight.transitions {
                    _ = scratch.applyMockTransition(transition)
                }
                prepared.append(frame)
            } catch {
                return atomicRefusal(
                    frames: frames,
                    traceID: traceID,
                    failingFrameID: frame.id,
                    finiteReason: finiteReason(for: error),
                    traceLogger: traceLogger
                )
            }
        }

        do {
            let accepted = try pipeline.withAtomicRuntimeTransaction(store: store) {
                var items: [DemoRuntimePartialSubactionResult] = []
                for frame in prepared {
                    let before = canonicalState(store)
                    do {
                        let result = try pipeline.execute(frame, store: store, traceLogger: traceLogger)
                        items.append(
                            acceptedSubaction(
                                frame: frame,
                                result: result,
                                before: before,
                                store: store
                            )
                        )
                    } catch {
                        throw AtomicFrameExecutionFailure(
                            frameID: frame.id,
                            finiteReason: finiteReason(for: error)
                        )
                    }
                }
                return items
            }
            for item in accepted {
                record(item, traceID: traceID, traceLogger: traceLogger)
            }
            return DemoRuntimePartialPlanResult(
                traceID: traceID,
                subactions: accepted,
                atomicityContract: .atomic
            )
        } catch C3ExecutionTransactionError.rollbackFailed {
            throw DemoRuntimePartialPlanError.atomicRollbackFailed
        } catch let failure as AtomicFrameExecutionFailure {
            return atomicRefusal(
                frames: frames,
                traceID: traceID,
                failingFrameID: failure.frameID,
                finiteReason: failure.finiteReason,
                traceLogger: traceLogger
            )
        }
    }

    private func preparedFrame(
        _ candidate: ToolCallFrame,
        traceID: String,
        stateRevision: Int?
    ) -> ToolCallFrame {
        var frame = candidate
        frame.traceID = traceID
        if let stateRevision {
            frame.stateRevision = stateRevision
        }
        return frame
    }

    private func preflightFiniteReason(for frame: ToolCallFrame) -> RuntimeFiniteReason? {
        guard frame.candidateSource != .fastPath else {
            return nil
        }
        guard DDomainMountedToolCatalog.mountedToolNames.contains(frame.toolName) else {
            return .unmountedToolName
        }
        return nil
    }

    private func finiteReason(for error: Error) -> RuntimeFiniteReason {
        guard let executionError = error as? ToolExecutionError else {
            return .runtimeExecutionError
        }
        switch executionError {
        case .guardDenied:
            return .safetyOrPolicyRefusal
        case .staleState:
            return .staleStateRevision
        case .schemaInvalid(.missingField):
            return .clarifyMissingSlot
        case .schemaInvalid, .semanticInvalid, .noToolCall, .malformed, .thinkLeak:
            return .unsupportedToolPlan
        case .readbackMismatch:
            return .runtimeExecutionError
        }
    }

    @MainActor
    private func acceptedSubaction(
        frame: ToolCallFrame,
        result: C3ExecutionResult,
        before: [String],
        store: DemoVehicleStateStore
    ) -> DemoRuntimePartialSubactionResult {
        DemoRuntimePartialSubactionResult(
            frameID: frame.id,
            disposition: .accepted,
            readbacks: result.readbacks,
            finiteReason: nil,
            observedToolCallCount: 1,
            observedReadbackCount: result.readbacks.count,
            stateMutation: before != canonicalState(store),
            mutationCount: result.mutationCount
        )
    }

    private func refusedSubaction(
        frame: ToolCallFrame,
        finiteReason: RuntimeFiniteReason
    ) -> DemoRuntimePartialSubactionResult {
        DemoRuntimePartialSubactionResult(
            frameID: frame.id,
            disposition: .refused,
            readbacks: [],
            finiteReason: finiteReason,
            observedToolCallCount: 0,
            observedReadbackCount: 0,
            stateMutation: false
        )
    }

    private func atomicRefusal(
        frames: [ToolCallFrame],
        traceID: String,
        failingFrameID: String,
        finiteReason: RuntimeFiniteReason,
        traceLogger: any TraceLogger
    ) -> DemoRuntimePartialPlanResult {
        let subactions = frames.map { frame in
            DemoRuntimePartialSubactionResult(
                frameID: frame.id,
                disposition: .refused,
                readbacks: [],
                finiteReason: frame.id == failingFrameID ? finiteReason : .runtimeExecutionError,
                observedToolCallCount: 0,
                observedReadbackCount: 0,
                stateMutation: false
            )
        }
        for item in subactions {
            record(item, traceID: traceID, traceLogger: traceLogger)
        }
        return DemoRuntimePartialPlanResult(
            traceID: traceID,
            subactions: subactions,
            atomicityContract: .atomic
        )
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
            guardReason: item.finiteReason?.rawValue,
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