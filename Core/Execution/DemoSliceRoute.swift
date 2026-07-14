import Foundation

public struct DemoSliceExecution: Equatable, Sendable {
    public let admission: DemoSliceAdmission
    public let payload: RuntimePresentationPayload
    public let runnerCallCount: Int

    public init(admission: DemoSliceAdmission, payload: RuntimePresentationPayload, runnerCallCount: Int) {
        self.admission = admission
        self.payload = payload
        self.runnerCallCount = runnerCallCount
    }
}

public struct DemoSliceRouteResult: Equatable, Sendable {
    public let execution: DemoSliceExecution?
    public let rejection: DemoSliceAdmissionRejection?

    public init(execution: DemoSliceExecution? = nil, rejection: DemoSliceAdmissionRejection? = nil) {
        precondition((execution == nil) != (rejection == nil))
        self.execution = execution
        self.rejection = rejection
    }
}

/// A narrow, text-only frontstage route. It owns exactly one runner and only
/// invokes it after the two-entry catalog has admitted the utterance.
@MainActor
public final class DemoSliceRoute {
    public let catalog: DemoSliceAdmissionCatalog
    private let runner: DemoRuntimeSessionRunner
    public private(set) var runnerCallCount = 0

    public init(
        store: DemoVehicleStateStore,
        traceLogger: any TraceLogger,
        speech: any SpeechSynthesisEngine,
        catalog: DemoSliceAdmissionCatalog = DemoSliceAdmissionCatalog()
    ) throws {
        self.catalog = catalog
        let bundle = DemoRuntimeContractBundle.singleCommandDemoDefault
        self.runner = DemoRuntimeSessionRunner(
            store: store,
            pipeline: try bundle.makePipeline(),
            traceLogger: traceLogger,
            speech: speech,
            planDecoder: { text in
                guard let admission = catalog.admission(for: text) else {
                    throw FastPathIntentError.noMatch(text)
                }
                return [admission.frame]
            }
        )
    }

    /// Unit/default helper surface. Invokes the runner without a production
    /// correlation provider (constructor default / nil). Not the App production surface.
    public func route(text: String) async throws -> DemoSliceRouteResult {
        try await routeBody(text: text, correlationProvider: nil)
    }

    /// App production surface: per-call non-optional correlation provider.
    public func route(
        text: String,
        correlationProvider: RuntimeSessionCorrelationProvider
    ) async throws -> DemoSliceRouteResult {
        try await routeBody(text: text, correlationProvider: correlationProvider)
    }

    private func routeBody(
        text: String,
        correlationProvider: RuntimeSessionCorrelationProvider?
    ) async throws -> DemoSliceRouteResult {
        guard let admission = catalog.admission(for: text) else {
            return DemoSliceRouteResult(rejection: catalog.rejection(for: text) ?? .notInCatalog)
        }
        runnerCallCount += 1
        let payload: RuntimePresentationPayload
        if let correlationProvider {
            payload = try await runner.run(text: text, correlationProvider: correlationProvider)
        } else {
            payload = try await runner.run(text: text)
        }
        return DemoSliceRouteResult(
            execution: DemoSliceExecution(
                admission: admission,
                payload: payload,
                runnerCallCount: runnerCallCount
            )
        )
    }
}
