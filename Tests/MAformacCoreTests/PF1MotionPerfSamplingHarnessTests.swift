import XCTest

final class PF1MotionPerfSamplingHarnessTests: XCTestCase {
    private var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func data(at path: String) throws -> Data {
        try Data(contentsOf: repoRoot.appendingPathComponent(path))
    }

    private func source(at path: String) throws -> String {
        try String(contentsOf: repoRoot.appendingPathComponent(path), encoding: .utf8)
    }

    func testPF1SamplingManifestPinsTwentyOnePointsAndBudgetTriplet() throws {
        let raw = try JSONSerialization.jsonObject(
            with: data(at: "Tools/checks/motion-perf-sampling-points.json")
        ) as? [String: Any]
        let manifest = try XCTUnwrap(raw)

        XCTAssertEqual(manifest["authority"] as? String, "D0G-035_sampling_method_only")

        let points = try XCTUnwrap(manifest["sampling_points"] as? [[String: Any]])
        XCTAssertEqual(points.count, 21)
        XCTAssertTrue(points.allSatisfy { $0["capture"] as? String == "pending_idle_window" })

        let ids = Set(points.compactMap { $0["id"] as? String })
        for required in [
            "card.waterfall.card_entrance",
            "card.waterfall.content_entrance",
            "energy_line.canvas_line_trim",
            "energy_line.orb_glow",
            "energy_line.card_pulse",
            "orb.particle_field_l0_72",
            "orb.particle_field_l1_48",
            "orb.particle_field_l2_24",
            "context_capsule.timeline_body",
            "context_capsule.vortex_layers",
            "context_capsule.canvas_fallback_layers"
        ] {
            XCTAssertTrue(ids.contains(required), "missing PF1 sampling point \(required)")
        }

        let budgets = try XCTUnwrap(manifest["budgets"] as? [[String: Any]])
        let byLevel = Dictionary(uniqueKeysWithValues: budgets.compactMap { item -> (String, [String: Any])? in
            guard let level = item["level"] as? String else { return nil }
            return (level, item)
        })

        XCTAssertEqual(byLevel["fullShowcase"]?["orb_particle_count"] as? Int, 72)
        XCTAssertEqual(byLevel["balancedDemo"]?["orb_particle_count"] as? Int, 48)
        XCTAssertEqual(byLevel["trainSafeStatic"]?["orb_particle_count"] as? Int, 24)
        XCTAssertEqual(byLevel["fullShowcase"]?["context_capsule_mode"] as? String, "animated")
        XCTAssertEqual(byLevel["balancedDemo"]?["context_capsule_mode"] as? String, "lowFPS")
        XCTAssertEqual(byLevel["trainSafeStatic"]?["context_capsule_mode"] as? String, "staticImage")
    }

    func testPF1SamplingScriptsExposeHeadlessAndXctracePaths() throws {
        let sample = try source(at: "Tools/checks/motion-perf-sample.sh")
        XCTAssertTrue(sample.contains("xcrun xctrace record"))
        XCTAssertTrue(sample.contains("PF1_RUN_XCTRACE"))
        XCTAssertTrue(sample.contains("pending_idle_window"))
        XCTAssertTrue(sample.contains("headless_manifest_ready"))

        let matrix = try source(at: "Tools/checks/motion-perf-budget-matrix.sh")
        XCTAssertTrue(matrix.contains("fullShowcase balancedDemo trainSafeStatic"))
        XCTAssertTrue(matrix.contains("headless_matrix_ready_gui_traces_pending_idle_window"))
    }
}
