public enum DDomainToolPlanFailure: Error, Equatable, Sendable {
    case parseFailed
    case nameRejected(String)
    case irUnclassified(String)
    case bridgeFailed(String)

    public var finiteReason: String {
        switch self {
        case .parseFailed:
            return "parse_failed"
        case .nameRejected:
            return "name_rejected"
        case .irUnclassified:
            return "ir_unclassified"
        case .bridgeFailed:
            return "bridge_failed"
        }
    }
}
