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
        XCTAssertTrue(source.contains("initialStoreCells: initialStoreCells"))
        XCTAssertTrue(source.contains("runtimeReadbackQueue.start(steps)"))
        XCTAssertTrue(source.contains("completeRuntimeReadbackStep(readbackID: signal.readbackID)"))
        XCTAssertFalse(source.contains("plan.readbacks.last!"))
    }

    func testRuntimeReadbackConsumerUsesCompletionBackpressureNotTaskYield() throws {
        let contentSource = try source(at: "App/ContentView.swift")
        let commit = try section(
            in: contentSource,
            from: "private func commitRuntimeReadbackSteps",
            until: "private func applyRuntimeReadbackStep"
        )
        let apply = try section(
            in: contentSource,
            from: "private func applyRuntimeReadbackStep",
            until: "private func shouldWaitForEnergyLine"
        )
        let overlay = try source(at: "App/Motion/EnergyLineOverlay.swift")

        XCTAssertTrue(commit.contains("runtimeReadbackQueue.start(steps)"))
        XCTAssertTrue(commit.contains("applyRuntimeReadbackStep(firstStep)"))
        XCTAssertFalse(commit.contains("steps.dropFirst()"))
        XCTAssertFalse(commit.contains("Task.yield()"))
        XCTAssertTrue(apply.contains("speech.speak(step.speechText.text)"))
        XCTAssertTrue(apply.contains("completeRuntimeReadbackStep(readbackID: step.event.readbackID)"))
        XCTAssertTrue(overlay.contains("var onCompletion: () -> Void = {}"))
        XCTAssertTrue(overlay.contains("completionCriteria: .logicallyComplete"))
        XCTAssertTrue(overlay.contains("onCompletion()"))
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
