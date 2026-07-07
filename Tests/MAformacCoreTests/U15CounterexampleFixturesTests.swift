import XCTest
@testable import MAformacCore

final class U15CounterexampleFixturesTests: XCTestCase {
    func testFixturesCoverOnlyTheFourRequiredCounterexampleKinds() {
        let kinds = U15CounterexampleFixtures.all.map(\.resultKind)

        XCTAssertEqual(kinds, U15CounterexampleFixtures.expectedResultKinds)
        XCTAssertEqual(Set(kinds), [
            .clarifyMissingSlot,
            .refusalNoAvailableTool,
            .refusalSafetyOrPolicy,
            .partialAcceptPartialRefuse
        ])
        XCTAssertFalse(kinds.contains(.acceptedToolCall))
        XCTAssertFalse(kinds.contains(.alreadyStateNoop))
        XCTAssertFalse(kinds.contains(.runtimeError))
        XCTAssertFalse(kinds.contains(.cancelled))
    }

    func testEveryFixtureUsesMatrixDialogAndStaticPreviewProof() {
        for fixture in U15CounterexampleFixtures.all {
            let matrixEntry = DemoRuntimeResultPresentationMatrix.entry(for: fixture.resultKind)

            XCTAssertEqual(fixture.snapshot.resultKind, fixture.resultKind, fixture.id)
            XCTAssertEqual(fixture.snapshot.dialogText, matrixEntry.dialogText, fixture.id)
            XCTAssertEqual(fixture.snapshot.voiceState, matrixEntry.ttsState, fixture.id)
            XCTAssertEqual(fixture.snapshot.proofClass, .staticPreview, fixture.id)
            XCTAssertFalse(fixture.proofIntent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, fixture.id)
            XCTAssertFalse(fixture.snapshot.storeCells.isEmpty, fixture.id)
        }
    }

    func testFixturesCarryExpectedVisualStatesFromRuntimeMatrix() {
        for fixture in U15CounterexampleFixtures.all {
            let expectedState = DemoRuntimeResultPresentationMatrix.entry(for: fixture.resultKind).visualState
            let states = Set(fixture.snapshot.storeCells.map(\.visualState))

            XCTAssertTrue(states.contains(expectedState), fixture.id)
        }
    }

    func testRefusalFixturesCarryRefusedCellButClarifyDoesNot() {
        let fixturesByKind = Dictionary(uniqueKeysWithValues: U15CounterexampleFixtures.all.map { ($0.resultKind, $0) })

        XCTAssertNil(fixturesByKind[.clarifyMissingSlot]?.snapshot.refusedCell)
        XCTAssertNotNil(fixturesByKind[.refusalNoAvailableTool]?.snapshot.refusedCell)
        XCTAssertNotNil(fixturesByKind[.refusalSafetyOrPolicy]?.snapshot.refusedCell)
        XCTAssertNotNil(fixturesByKind[.partialAcceptPartialRefuse]?.snapshot.refusedCell)
    }

    func testCounterexampleSourceDoesNotUseDefaultSwitchFallback() throws {
        let repoRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let source = try String(
            contentsOf: repoRoot.appendingPathComponent("Core/Presentation/U15CounterexampleFixtures.swift"),
            encoding: .utf8
        )

        XCTAssertFalse(source.contains("default:"))
        XCTAssertFalse(source.contains("@unknown default"))
    }

    func testDebugGalleryCounterexamplesOnlyConsumeSharedFixtures() throws {
        let repoRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let source = try String(
            contentsOf: repoRoot.appendingPathComponent("App/DebugGallery.swift"),
            encoding: .utf8
        )
        let gallery = try section(
            in: source,
            from: "struct CounterexampleGallery: View",
            until: "/// value.type 5 类异构控件 spike"
        )

        XCTAssertTrue(gallery.contains("ForEach(U15CounterexampleFixtures.all"))
        XCTAssertTrue(gallery.contains("fixture.snapshot.dialogText"))
        XCTAssertTrue(gallery.contains("fixture.snapshot.storeCells"))
        XCTAssertFalse(gallery.contains("PresentationSnapshot("))
        XCTAssertFalse(gallery.contains("DemoVehicleStateCell("))
        XCTAssertFalse(gallery.contains("DemoRuntimeResultPresentationMatrix.entry"))
    }

    private func section(in source: String, from start: String, until end: String) throws -> String {
        guard let startRange = source.range(of: start) else {
            XCTFail("missing section start: \(start)")
            return ""
        }
        let tail = source[startRange.lowerBound...]
        guard let endRange = tail.range(of: end) else {
            XCTFail("missing section end: \(end)")
            return String(tail)
        }
        return String(tail[..<endRange.lowerBound])
    }
}
