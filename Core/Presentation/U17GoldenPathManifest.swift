import Foundation

enum U17GoldenPathID: String, CaseIterable, Codable, Equatable, Sendable {
    case acSuccessDeepSpace = "uiue_g9b_ac_success_deep_space"
}

struct U17GoldenPathEntry: Equatable, Sendable {
    let id: U17GoldenPathID
    let snapshotPresetRawValue: String
    let themeRawValue: String
    let visualState: DemoVisualState
    let requiredAccessibilityIdentifiers: [String]
    let proofIntent: String

    var launchArguments: [String] {
        ["-goldenPathID", id.rawValue]
    }
}

enum U17GoldenPathManifest {
    static let allEntries: [U17GoldenPathEntry] = U17GoldenPathID.allCases.map(entry)

    static func entry(for id: U17GoldenPathID) -> U17GoldenPathEntry {
        switch id {
        case .acSuccessDeepSpace:
            return U17GoldenPathEntry(
                id: id,
                snapshotPresetRawValue: "cooling",
                themeRawValue: "deepSpace",
                visualState: .changing,
                requiredAccessibilityIdentifiers: [
                    "context-band",
                    "demo-orb",
                    "dialogue-stream",
                    "mic-dock-safe-area",
                    "vehicle-cards"
                ],
                proofIntent: "simulator_l0_runtime_truth"
            )
        }
    }
}
