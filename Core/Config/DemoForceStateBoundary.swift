import Foundation

public enum DemoForceStateIsolation: String, Codable, CaseIterable, Equatable, Sendable {
    case debug
    case demoMode = "demo_mode"
    case customerFacing = "customer_facing"
}

public enum ForceStateContextDimension: String, Codable, CaseIterable, Equatable, Sendable {
    case vehicleSpeed = "vehicle.speed"
    case vehicleGear = "vehicle.gear"
    case environmentWeather = "environment.weather"
    case environmentTimePeriod = "environment.time_period"
}

public struct DemoForceStateValue: Codable, Equatable, Sendable {
    public let dimension: ForceStateContextDimension
    public let value: String

    public init(dimension: ForceStateContextDimension, value: String) {
        self.dimension = dimension
        self.value = value
    }
}

public struct DemoForceStateContext: Equatable, Sendable {
    public let isolation: DemoForceStateIsolation
    public let provenanceEventID: String
    public let provenanceTraceID: String
    public let values: [DemoForceStateValue]
    public var proofClass: PresentationProofClass { .localUnit }

    init(
        isolation: DemoForceStateIsolation,
        provenanceEventID: String,
        provenanceTraceID: String,
        values: [DemoForceStateValue]
    ) {
        self.isolation = isolation
        self.provenanceEventID = provenanceEventID
        self.provenanceTraceID = provenanceTraceID
        self.values = values
    }
}

public enum DemoForceStateBoundaryError: Error, Equatable, Sendable {
    case demoOrDebugBuildUnavailable
    case unsupportedIsolation(DemoForceStateIsolation)
    case missingDemoHarnessProvenance
    case emptyContext
    case duplicateDimension(ForceStateContextDimension)
}

public struct DemoForceStateBuildIsolation: Sendable {
    public static var isDebugOrDemoMode: Bool {
        #if DEBUG || DEMO_MODE
        true
        #else
        false
        #endif
    }
}

public struct DemoForceStateBoundary: Sendable {
    public init() {}

    public func accept(
        isolation: DemoForceStateIsolation,
        event: DemoInteractionEvent,
        values: [DemoForceStateValue]
    ) throws -> DemoForceStateContext {
        guard DemoForceStateBuildIsolation.isDebugOrDemoMode else {
            throw DemoForceStateBoundaryError.demoOrDebugBuildUnavailable
        }

        guard isolation == .debug || isolation == .demoMode else {
            throw DemoForceStateBoundaryError.unsupportedIsolation(isolation)
        }

        guard event.source == .demoHarness,
              !event.eventID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let traceID = event.traceID?.trimmingCharacters(in: .whitespacesAndNewlines),
              !traceID.isEmpty else {
            throw DemoForceStateBoundaryError.missingDemoHarnessProvenance
        }

        guard !values.isEmpty else {
            throw DemoForceStateBoundaryError.emptyContext
        }

        var seenDimensions = Set<ForceStateContextDimension>()
        for value in values {
            guard seenDimensions.insert(value.dimension).inserted else {
                throw DemoForceStateBoundaryError.duplicateDimension(value.dimension)
            }
        }

        return DemoForceStateContext(
            isolation: isolation,
            provenanceEventID: event.eventID,
            provenanceTraceID: traceID,
            values: values
        )
    }
}
