import Foundation

public final class FrontstageCustomerIngress {
    public typealias Validator = (FrontstageIngressRequest) -> FrontstageIngressRejection?

    private let session: FrontstageVoiceSession
    private let maximumUTF8Bytes: Int
    private let validator: Validator

    public var sessionID: String { session.sessionID }

    public init(
        session: FrontstageVoiceSession,
        maximumUTF8Bytes: Int = 4_096,
        validator: @escaping Validator = { _ in nil }
    ) {
        precondition(maximumUTF8Bytes > 0)
        self.session = session
        self.maximumUTF8Bytes = maximumUTF8Bytes
        self.validator = validator
    }

    public func submit(_ input: FrontstageIngressInput) -> FrontstageIngressResult {
        let request = session.issueIngressRequest(input)
        let trimmed = input.rawText?.trimmingCharacters(in: .whitespacesAndNewlines)
        let rejection: FrontstageIngressRejection?
        if input.rawText == nil {
            rejection = .unavailable
        } else if trimmed?.isEmpty != false {
            rejection = .blank
        } else if trimmed!.utf8.count > maximumUTF8Bytes {
            rejection = .oversize(maximumUTF8Bytes: maximumUTF8Bytes)
        } else {
            rejection = validator(request)
        }
        if let rejection {
            return .rejected(FrontstageIngressRejected(request: request, reason: rejection))
        }
        return .accepted(session.makeContainmentTurn(request: request, utterance: trimmed!))
    }
}
