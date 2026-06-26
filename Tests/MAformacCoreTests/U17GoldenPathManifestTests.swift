import XCTest
@testable import MAformacCore

final class U17GoldenPathManifestTests: XCTestCase {
    func testManifestCoversEveryGoldenPathIDExactlyOnce() {
        let entries = U17GoldenPathManifest.allEntries

        XCTAssertEqual(entries.map(\.id), U17GoldenPathID.allCases)
        XCTAssertEqual(Set(entries.map(\.id)), Set(U17GoldenPathID.allCases))
        XCTAssertEqual(entries.count, 1)
    }

    func testAcSuccessDeepSpaceEntryFreezesGoldenPathLaunchContract() {
        let entry = U17GoldenPathManifest.entry(for: .acSuccessDeepSpace)

        XCTAssertEqual(entry.id.rawValue, "uiue_g9b_ac_success_deep_space")
        XCTAssertEqual(entry.snapshotPresetRawValue, "cooling")
        XCTAssertEqual(entry.themeRawValue, "deepSpace")
        XCTAssertEqual(entry.visualState, .changing)
        XCTAssertEqual(entry.proofIntent, "simulator_l0_runtime_truth")
        XCTAssertEqual(entry.launchArguments, ["-goldenPathID", "uiue_g9b_ac_success_deep_space"])
    }

    func testGoldenPathRequiresCoreMainStageAccessibilityIdentifiers() {
        let entry = U17GoldenPathManifest.entry(for: .acSuccessDeepSpace)

        XCTAssertEqual(
            entry.requiredAccessibilityIdentifiers,
            [
                "context-band",
                "demo-orb",
                "dialogue-stream",
                "mic-dock-safe-area",
                "vehicle-cards"
            ]
        )
    }

    func testGoldenPathLaunchContractDoesNotRouteThroughForceStateOrGallery() {
        let args = U17GoldenPathManifest.entry(for: .acSuccessDeepSpace).launchArguments

        XCTAssertFalse(args.contains("-forceVisualState"))
        XCTAssertFalse(args.contains("-showGallery"))
        XCTAssertFalse(args.contains("-showDemoAllStates"))
    }

    func testGoldenPathManifestSourceDoesNotUseDefaultSwitchFallback() throws {
        let repoRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let source = try String(
            contentsOf: repoRoot.appendingPathComponent("Core/Presentation/U17GoldenPathManifest.swift"),
            encoding: .utf8
        )

        XCTAssertFalse(source.contains("default:"))
        XCTAssertFalse(source.contains("@unknown default"))
    }
}
