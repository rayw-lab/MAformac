import XCTest
@testable import MAformacCore

final class T4MacInteractionContractTests: XCTestCase {
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
        guard let endRange = tail.range(of: end) else {
            return String(tail)
        }
        return String(tail[..<endRange.lowerBound])
    }

    func testVehicleCardsExposeMacHoverFocusWithoutMutatingBusinessState() throws {
        let source = try source(at: "App/ContentView.swift")
        let card = try section(in: source, from: "struct VehicleStateCard: View", until: "struct DeepSpaceBackground")

        XCTAssertTrue(card.contains(".onHover"))
        XCTAssertTrue(card.contains(".focusable(true)"))
        XCTAssertTrue(card.contains("@FocusState"))
        XCTAssertTrue(card.contains("hoverDwellNanoseconds"))
        XCTAssertTrue(card.contains("keyboard focus wins hover"))
        XCTAssertTrue(card.contains("display.visualState"))
        XCTAssertTrue(card.contains(".onChange(of: display.visualState)"))
        XCTAssertTrue(card.contains(".onChange(of: display.accessibilityKey)"))
        XCTAssertTrue(card.contains("resetHoverPresentation()"))
        XCTAssertTrue(card.contains("hoverTask = nil"))
        XCTAssertFalse(card.contains("display.visualState ="))
        XCTAssertFalse(card.contains("visualState ="))
    }

    func testVehicleCardClickPathOnlyExpandsFamilyAndDoesNotTriggerRuntimeOrVoice() throws {
        let source = try source(at: "App/ContentView.swift")
        let card = try section(in: source, from: "struct VehicleStateCard: View", until: "struct DeepSpaceBackground")

        XCTAssertTrue(card.contains("onTap(family)"))
        XCTAssertFalse(card.contains("speech."))
        XCTAssertFalse(card.contains("applyMockTransition"))
        XCTAssertFalse(card.contains("applyMockVoiceColdIntent"))
        XCTAssertFalse(card.contains("store."))
    }

    func testMicDockUsesMacPushToTalkMonitorAndDoesNotClickToggle() throws {
        let source = try source(at: "App/ContentView.swift")
        let mic = try section(in: source, from: "struct MicDock: View", until: "struct WaveformMark")

        XCTAssertTrue(mic.contains("MacPushToTalkKeyMonitor"))
        XCTAssertTrue(mic.contains("NSEvent.addLocalMonitorForEvents"))
        XCTAssertTrue(mic.contains("optionSpaceKeyCode"))
        XCTAssertTrue(mic.contains("escapeKeyCode"))
        XCTAssertTrue(mic.contains("drag-out/失焦 cancel"))
        XCTAssertTrue(mic.contains("@Environment(\\.scenePhase)"))
        XCTAssertTrue(mic.contains(".onChange(of: scenePhase)"))
        XCTAssertTrue(mic.contains("phase != .active"))
        XCTAssertTrue(mic.contains("isFocused = true"))
        XCTAssertTrue(mic.contains("isFocused = false"))
        XCTAssertTrue(mic.contains("permissionPreflightStatus"))
        XCTAssertFalse(mic.contains("Button(action: onMockVoiceSubmit)"))
        XCTAssertFalse(mic.contains(".onLongPressGesture"))
    }

    func testExpandedLayerIdentifierMatchesT4MacXCUITestExpectation() throws {
        let expanded = try source(at: "App/ExpandedFamilyCard.swift")
        let uiTest = try source(at: "MAformacIOSUITests/T4MacInteractionUITests.swift")

        XCTAssertTrue(expanded.contains("expanded-\\(display.family.rawValue)"))
        XCTAssertTrue(expanded.contains("expanded-\\(display.family.rawValue)-close"))
        XCTAssertTrue(uiTest.contains("\"expanded-ac\""))
    }

    func testExpandedLayerPropagatesForceReduceMotionToInternalControls() throws {
        let expanded = try source(at: "App/ExpandedFamilyCard.swift")
        let valueControl = try source(at: "App/ValueControlView.swift")

        XCTAssertTrue(expanded.contains("var forceReduceMotion = false"))
        XCTAssertTrue(expanded.contains("@Environment(\\.accessibilityReduceMotion)"))
        XCTAssertTrue(expanded.contains("private var effectiveReduceMotion: Bool { reduceMotion || forceReduceMotion }"))
        XCTAssertTrue(expanded.contains("forceReduceMotion: effectiveReduceMotion"))
        XCTAssertTrue(expanded.contains("forceReduceMotion: forceReduceMotion"))

        XCTAssertTrue(valueControl.contains("var forceReduceMotion = false"))
        XCTAssertTrue(valueControl.contains("@Environment(\\.accessibilityReduceMotion)"))
        XCTAssertTrue(valueControl.contains("private var effectiveReduceMotion: Bool { reduceMotion || forceReduceMotion }"))
        XCTAssertTrue(valueControl.contains("forceReduceMotion: effectiveReduceMotion"))
        XCTAssertTrue(valueControl.contains("effectiveReduceMotion ? 0 : 6"))
    }
}
