import Foundation

public enum FrontstageIngressSource: String, Equatable, Sendable {
    case text
    case voiceTranscript
    case shortcut
}

public struct FrontstageIngressInput: Equatable, Sendable {
    public let source: FrontstageIngressSource
    public let rawText: String?

    public init(source: FrontstageIngressSource, rawText: String?) {
        self.source = source
        self.rawText = rawText
    }
}

public struct FrontstageIngressRequest: Equatable, Sendable {
    public let source: FrontstageIngressSource
    public let rawText: String?
    public let sessionID: String
    public let sequence: Int
    public let turnID: String
    public let eventID: String
}

public enum FrontstageIngressRejection: Equatable, Sendable {
    case unavailable
    case blank
    case oversize(maximumUTF8Bytes: Int)
    case rejectedByValidator
}

public struct FrontstageIngressRejected: Equatable, Sendable {
    public let request: FrontstageIngressRequest
    public let reason: FrontstageIngressRejection
    public let stateMutation = false
    public let readbacks: [DemoActionReadback] = []
}

public enum FrontstageIngressResult: Equatable, Sendable {
    case accepted(FrontstageVoiceTurn)
    case rejected(FrontstageIngressRejected)
}
