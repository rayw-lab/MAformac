import XCTest
@testable import MAformacCore

final class VisualEvidenceReceiptTests: XCTestCase {
    func testEvidenceKindRawValuesAreStable() {
        XCTAssertEqual(VisualEvidenceKind.tapStep.rawValue, "tap_step")
        XCTAssertEqual(VisualEvidenceKind.toggle.rawValue, "toggle")
        XCTAssertEqual(VisualEvidenceKind.badgeCycle.rawValue, "badge_cycle")
        XCTAssertEqual(VisualEvidenceKind.continuousDrag.rawValue, "continuous_drag")
        XCTAssertEqual(VisualEvidenceKind.terminalVisualOnly.rawValue, "terminal_visual_only")
    }

    func testOnlyTapStepToggleAndBadgeCycleAreAutomatedTapEvidence() {
        let automated = Set(VisualEvidenceKind.allCases.filter(\.isAutomatedTapEvidence))
        XCTAssertEqual(automated, [.tapStep, .toggle, .badgeCycle])

        let processProof = Set(VisualEvidenceKind.allCases.filter(\.provesProcessMutationWithoutOperator))
        XCTAssertEqual(processProof, automated)
        XCTAssertFalse(VisualEvidenceKind.continuousDrag.provesProcessMutationWithoutOperator)
        XCTAssertFalse(VisualEvidenceKind.terminalVisualOnly.provesProcessMutationWithoutOperator)
    }

    func testAutomatedActionSamplesCoverTapStepToggleAndBadgeCycle() {
        let sampleKinds = Set(VisualEvidenceSampleMatrix.automatedActionSamples.map(\.evidenceKind))
        XCTAssertEqual(sampleKinds, [.tapStep, .toggle, .badgeCycle])
        XCTAssertFalse(sampleKinds.contains(.continuousDrag))
        XCTAssertFalse(sampleKinds.contains(.terminalVisualOnly))
    }

    func testRepresentativeFamilySamplesCoverFanSeatWindowAndLight() {
        let samplesByID = Dictionary(
            uniqueKeysWithValues: VisualEvidenceSampleMatrix.representativeFamilySamples.map { ($0.id, $0) }
        )

        XCTAssertEqual(samplesByID["fan-representative"]?.family, .ac)
        XCTAssertEqual(samplesByID["fan-representative"]?.expectedValueType, .stepper)
        XCTAssertEqual(samplesByID["seat-representative"]?.family, .seat)
        XCTAssertEqual(samplesByID["seat-representative"]?.expectedValueType, .stepper)
        XCTAssertEqual(samplesByID["window-representative"]?.family, .window)
        XCTAssertEqual(samplesByID["window-representative"]?.expectedValueType, .percent)
        XCTAssertEqual(samplesByID["light-representative"]?.family, .ambient)
        XCTAssertEqual(samplesByID["light-representative"]?.expectedValueType, .badge)
    }

    func testSamplesStayAlignedWithFamilyAndValueTypeMappers() {
        let samples = VisualEvidenceSampleMatrix.automatedActionSamples
            + VisualEvidenceSampleMatrix.representativeFamilySamples

        for sample in samples {
            XCTAssertEqual(FamilyCardIDMapper.familyCardID(forBase: sample.base), sample.family, sample.id)
            XCTAssertEqual(UIValueTypeMapper.uiValueType(forBase: sample.base), sample.expectedValueType, sample.id)
        }
    }

    @MainActor
    func testAutomatedSamplesWriteStoreAndRefreshPresentationSnapshot() {
        for sample in VisualEvidenceSampleMatrix.automatedActionSamples {
            let store = DemoVehicleStateStore(cells: [
                DemoVehicleStateCell(key: sample.cellKey, actualValue: sample.beforeValue)
            ])

            let readback = store.applyMockTransition(
                DemoMockTransition(key: sample.cellKey, desiredValue: sample.afterValue, source: .user)
            )
            let snapshot = PresentationSnapshot.from(
                store: store,
                activeCells: [sample.family: sample.cellKey],
                readbacks: [readback]
            )

            XCTAssertEqual(
                snapshot.storeCells.first { $0.key == sample.cellKey }?.actualValue,
                sample.afterValue,
                sample.id
            )
            XCTAssertEqual(snapshot.activeCells[sample.family], sample.cellKey, sample.id)
            XCTAssertEqual(snapshot.readbacks.first?.key, sample.cellKey, sample.id)
            XCTAssertNotEqual(
                snapshot.storeCells.first { $0.key == sample.cellKey }?.visualState,
                .normal,
                sample.id
            )
            XCTAssertEqual(snapshot.proofClass, .localMock, sample.id)
        }
    }

    func testEvidenceKindSwitchesDoNotUseFallbackCases() throws {
        let repoRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = repoRoot.appendingPathComponent("Core/Presentation/VisualEvidenceReceipt.swift")
        let source = try String(contentsOf: sourceURL, encoding: .utf8)

        XCTAssertFalse(source.contains("default:"))
        XCTAssertFalse(source.contains("@unknown default"))
    }
}
