import Foundation

public enum RuntimeTarget: String, Codable, Equatable, Sendable {
    case iosSim = "ios_sim"
    case mac
}

public enum RuntimeDestinationProbe {
    public struct Observation: Equatable, Sendable {
        public var runtimeTarget: RuntimeTarget
        public var stdoutMarker: String

        public init(runtimeTarget: RuntimeTarget, stdoutMarker: String) {
            self.runtimeTarget = runtimeTarget
            self.stdoutMarker = stdoutMarker
        }
    }

    public static func probe(environment: [String: String] = ProcessInfo.processInfo.environment) -> Observation {
        if environment["SIMULATOR_UDID"]?.isEmpty == false ||
            environment["SIMULATOR_DEVICE_NAME"]?.isEmpty == false {
            return Observation(runtimeTarget: .iosSim, stdoutMarker: "runtime_target=ios_sim")
        }
        return Observation(runtimeTarget: .mac, stdoutMarker: "runtime_target=mac")
    }

    public static func validate(receipt: RuntimeAdapterMountReceipt, against observation: Observation) throws {
        guard receipt.runtimeTarget == observation.runtimeTarget.rawValue else {
            throw RuntimeAdapterMountReceiptValidationError.runtimeTargetMismatch(
                expected: observation.runtimeTarget.rawValue,
                actual: receipt.runtimeTarget
            )
        }
    }

    public static func validate(stdoutArtifact url: URL, receipt: RuntimeAdapterMountReceipt) throws {
        let stdout = try String(contentsOf: url, encoding: .utf8)
        guard stdout.contains("runtime_target=\(receipt.runtimeTarget)") else {
            throw RuntimeAdapterMountReceiptValidationError.runtimeTargetMismatch(
                expected: receipt.runtimeTarget,
                actual: stdout.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }
    }
}
