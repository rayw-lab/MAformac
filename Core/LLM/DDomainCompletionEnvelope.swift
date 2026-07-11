import Foundation

public struct DDomainCompletionEnvelope: Equatable, Sendable {
    public static let maximumContentBytes = 64 * 1024

    public let content: String
    public let finishReason: String
    public let stopReason: String
    public let toolCallCount: Int
    public let source: String

    public init(
        content: String,
        finishReason: String,
        stopReason: String,
        toolCallCount: Int,
        source: String
    ) {
        self.content = content
        self.finishReason = finishReason
        self.stopReason = stopReason
        self.toolCallCount = toolCallCount
        self.source = source
    }
}

public enum ToolPlanCardinalityPolicy: Equatable, Sendable {
    case exactlyOne
    case boundedReviewed(maximum: Int)

    func accepts(_ count: Int) -> Bool {
        switch self {
        case .exactlyOne:
            return count == 1
        case let .boundedReviewed(maximum):
            return maximum > 0 && count >= 1 && count <= maximum
        }
    }
}

public enum DDomainCompletionRejection: Error, Equatable, Sendable {
    case missingSource
    case unsupportedFinishReason(String)
    case missingStopReason
    case invalidDeclaredToolCallCount(Int)
    case contentTooLarge
    case invalidContentShape
    case invalidToolCallJSON(index: Int)
    case toolCallCountMismatch(declared: Int, parsed: Int)
    case cardinalityRejected(policy: ToolPlanCardinalityPolicy, actual: Int)
}
