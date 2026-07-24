import Darwin
import Foundation

@main
enum FrontstageRouteUIHarnessProbe {
    static func main() {
        do {
            _ = try FrontstageRouteUITestRunConfiguration(
                formalEnvironment: ProcessInfo.processInfo.environment
            )
            print("FRONTSTAGE_UI_HARNESS_CONFIG_OK")
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? "FRONTSTAGE_UI_HARNESS_UNKNOWN_ERROR"
            FileHandle.standardError.write(Data("\(message)\n".utf8))
            exit(EX_USAGE)
        }
    }
}
