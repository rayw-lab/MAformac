import XCTest
@testable import MAformacCore

final class T7EBContentViewAccessibilityCallsiteTests: XCTestCase {
    private var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func source(at path: String) throws -> String {
        try String(contentsOf: repoRoot.appendingPathComponent(path), encoding: .utf8)
    }

    private func section(in source: String, from start: String, until end: String) throws -> String {
        guard let startRange = source.range(of: start) else {
            XCTFail("missing section start: \(start)")
            return ""
        }
        let tail = source[startRange.lowerBound...]
        guard let endRange = tail.range(of: end) else { return String(tail) }
        return String(tail[..<endRange.lowerBound])
    }

    private func occurrenceCount(of needle: String, in source: String) -> Int {
        var count = 0
        var range = source.startIndex..<source.endIndex
        while let found = source.range(of: needle, range: range) {
            count += 1
            range = found.upperBound..<source.endIndex
        }
        return count
    }

    func testContentViewPassesRuntimeMotionBudgetToStageAndOrbSurfaces() throws {
        let source = try source(at: "App/ContentView.swift")

        XCTAssertTrue(source.contains("private var runtimeMotionBudget: PresentationMotionBudget"))
        XCTAssertTrue(source.contains("StageAtmosphereLayer(theme: theme, orbState: snapshot.orbState, motionBudget: runtimeMotionBudget)"))
        XCTAssertEqual(occurrenceCount(of: "motionBudget: runtimeMotionBudget", in: source), 3)
        XCTAssertTrue(source.contains("budget: runtimeMotionBudget"))
    }

    func testMAformacAppPassesSelectedMotionBudgetIntoContentView() throws {
        let source = try source(at: "App/MAformacApp.swift")

        XCTAssertTrue(source.contains("motionBudget: DebugLaunchArguments.motionBudget"))
        XCTAssertTrue(source.contains("motionBudget: .preset(.fullShowcase)"))
    }

    func testContentViewDiscreteWithAnimationCallsitesUseReduceMotionGuard() throws {
        let source = try source(at: "App/ContentView.swift")

        XCTAssertGreaterThanOrEqual(occurrenceCount(of: "MotionAnimationFactory.guarded(", in: source), 10)
        XCTAssertTrue(source.contains("withAnimation(MotionAnimationFactory.guarded(.snappy(duration: 0.32), reduceMotion: effectiveReduceMotion))"))
        XCTAssertTrue(source.contains("withAnimation(MotionAnimationFactory.guarded(.snappy(duration: 0.22), reduceMotion: effectiveReduceMotion))"))
        XCTAssertTrue(source.contains("withAnimation(MotionAnimationFactory.guarded(.snappy(duration: 0.32), reduceMotion: gridEffectiveReduceMotion))"))
    }

    func testExpandedFamilyCardCallsiteReceivesForceReduceMotion() throws {
        let source = try source(at: "App/ContentView.swift")
        let overlay = try section(in: source, from: "private func expandedOverlay", until: "private var expandedOverlayBackdrop")

        XCTAssertTrue(overlay.contains("ExpandedFamilyCard("))
        XCTAssertTrue(overlay.contains("forceReduceMotion: forceReduceMotion"))
    }

    func testReduceTransparencyFallbacksCoverContentViewMaterialSurfaces() throws {
        let source = try source(at: "App/ContentView.swift")

        let overlay = try section(in: source, from: "private var expandedOverlayBackdrop", until: "private func handleReset")
        XCTAssertTrue(overlay.contains("reduceTransparency"))
        XCTAssertTrue(overlay.contains("DesignTokens.reduceTransparencyBackdropFill"))
        XCTAssertTrue(overlay.contains(".fill(.ultraThinMaterial)"))

        let micDock = try section(in: source, from: "struct MicDock: View", until: "enum MicPermissionPreflightStatus")
        XCTAssertTrue(micDock.contains("@Environment(\\.accessibilityReduceTransparency)"))
        XCTAssertTrue(micDock.contains("DesignTokens.reduceTransparencyChromeFill"))
        XCTAssertTrue(micDock.contains(".background(.regularMaterial, in: Capsule())"))

        let card = try section(in: source, from: "struct VehicleStateCard: View", until: "struct ThermalRangeBar")
        XCTAssertTrue(card.contains("@Environment(\\.accessibilityReduceTransparency)"))
        XCTAssertTrue(card.contains("DesignTokens.reduceTransparencyCardFill"))
        XCTAssertTrue(card.contains(".fill(.regularMaterial)"))
    }
}
