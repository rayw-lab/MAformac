import Foundation
import MAformacCore

@main
enum FrontstageRouteGateCLI {
    static func main() async throws {
        let configuration = try FrontstageRouteReceiptConfiguration.environment(ProcessInfo.processInfo.environment)
        let session = FrontstageVoiceSession()
        let turn = try session.submitContainment(utterance: "frontstage route gate")
        let receiptURL = try await MainActor.run {
            try RuntimeTurnReceiptAssembler.assembleAndWrite(
                turn: turn,
                routeResult: nil,
                configuration: configuration,
                isCurrent: { true }
            )
        }
        guard let receiptURL else {
            throw NSError(
                domain: "FrontstageRouteGateCLI",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "current containment turn did not emit a receipt"]
            )
        }
        print(receiptURL.path)
    }
}
