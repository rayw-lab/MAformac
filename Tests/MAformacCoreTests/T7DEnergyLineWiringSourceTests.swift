import XCTest

final class T7DEnergyLineWiringSourceTests: XCTestCase {
    private var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func source(at path: String) throws -> String {
        try String(contentsOf: repoRoot.appendingPathComponent(path), encoding: .utf8)
    }

    func testContentViewWiresEnergyLineToT5RuntimeReadbackAndFeatureFlag() throws {
        let source = try source(at: "App/ContentView.swift")

        XCTAssertTrue(source.contains("visualSwapEnabled"))
        XCTAssertTrue(source.contains("EnergyLineFramePreferenceKey"))
        XCTAssertTrue(source.contains("energyLineOverlay(frames: frames)"))
        XCTAssertTrue(source.contains("RuntimeReadbackSignal.from(event: resolved)"))
        XCTAssertTrue(source.contains("T5PresentationEvent.runtime(snapshot: nextSnapshot, readbackID: readbackID)"))
        XCTAssertTrue(source.contains("energyLineTriggerToken += 1"))
        XCTAssertTrue(source.contains("readbackRuntimeID(readback)"))
        XCTAssertTrue(source.contains("RuntimeReadbackEventSequence.steps"))
        XCTAssertFalse(source.contains("plan.readbacks.last!"))
    }

    func testGeometryUsesAnchorsForOrbAndCards() throws {
        let content = try source(at: "App/ContentView.swift")
        let geometry = try source(at: "App/Motion/EnergyLineGeometry.swift")

        XCTAssertTrue(content.contains(".energyLineOrbAnchor()"))
        XCTAssertTrue(content.contains(".energyLineCardAnchor(family: display.familyCardID)"))
        XCTAssertTrue(geometry.contains("anchorPreference(key: EnergyLineFramePreferenceKey.self, value: .bounds)"))
        XCTAssertTrue(content.contains("proxy[orb]"))
        XCTAssertTrue(content.contains("proxy[target]"))
        XCTAssertFalse(content.contains("targetCardX"))
        XCTAssertFalse(content.contains("targetCardY"))
    }

    func testEnergyLineDoesNotIntroduceASecondHoverStateSource() throws {
        let geometry = try source(at: "App/Motion/EnergyLineGeometry.swift")
        let overlay = try source(at: "App/Motion/EnergyLineOverlay.swift")

        XCTAssertFalse(geometry.contains("onHover"))
        XCTAssertFalse(geometry.contains("isHovered"))
        XCTAssertFalse(overlay.contains("onHover"))
        XCTAssertFalse(overlay.contains("isHovered"))
    }
}
