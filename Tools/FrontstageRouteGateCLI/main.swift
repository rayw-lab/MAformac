import Foundation
import MAformacCore

let configuration = try FrontstageRouteReceiptConfiguration.environment(ProcessInfo.processInfo.environment)
let session = FrontstageVoiceSession()
let turn = try session.submitContainment(utterance: "frontstage route gate")
let receiptURL = try FrontstageRouteReceiptWriter.writeCurrent(turn, configuration: configuration, isCurrent: { true })
guard let receiptURL else {
    throw NSError(domain: "FrontstageRouteGateCLI", code: 1, userInfo: [NSLocalizedDescriptionKey: "current containment turn did not emit a receipt"])
}
print(receiptURL.path)
