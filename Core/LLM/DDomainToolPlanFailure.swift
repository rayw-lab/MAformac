public enum DDomainToolPlanFailure: Error, Equatable, Sendable {
    case parseFailed
    case nameRejected(String)
    case irUnclassified(String)
    case bridgeFailed(String)

    public var finiteReason: RuntimeFiniteReason {
        switch self {
        case .parseFailed:
            return .unsupportedToolPlan
        case .nameRejected:
            return .nameRejected
        case .irUnclassified:
            return .unsupportedToolPlan
        case .bridgeFailed:
            return .unsupportedToolPlan
        }
    }

    public var decodeFailureKind: DDomainDecodeFailureKind {
        switch self {
        case .parseFailed:
            return .parseFailed
        case .nameRejected:
            return .nameRejected
        case .irUnclassified:
            return .irUnclassified
        case .bridgeFailed:
            return .bridgeFailed
        }
    }
}

public enum DDomainDecodeFailureKind: String, Codable, CaseIterable, Equatable, Sendable {
    case parseFailed = "parse_failed"
    case nameRejected = "name_rejected"
    case irUnclassified = "ir_unclassified"
    case bridgeFailed = "bridge_failed"
}
