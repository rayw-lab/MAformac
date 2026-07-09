import Foundation

/// T7d visual-swap feature flag.
///
/// Default is off. Commander can opt in after visual gates via launch argument or env:
/// `-visualSwap 1`, `-visualSwap true`, `UIUE_VISUAL_SWAP=1`, or `UIUE_VISUAL_SWAP=true`.
enum T7DVisualSwapFeature {
    static func isEnabled(
        arguments: [String] = ProcessInfo.processInfo.arguments,
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) -> Bool {
        if let raw = environment["UIUE_VISUAL_SWAP"] {
            return parse(raw)
        }
        if let index = arguments.firstIndex(of: "-visualSwap"),
           index + 1 < arguments.count {
            return parse(arguments[index + 1])
        }
        return arguments.contains("-enableVisualSwap")
    }

    private static func parse(_ raw: String) -> Bool {
        switch raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "1", "true", "yes", "on":
            return true
        default:
            return false
        }
    }
}
