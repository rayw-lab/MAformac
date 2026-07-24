import XCTest
@testable import MAformacCore

final class PresentationSnapshotTests: XCTestCase {
    func testResultKindHasAllNineCases() {
        let all: [DemoRuntimeResultKind] = [
            .acceptedToolCall,
            .noAction,
            .clarifyMissingSlot,
            .refusalNoAvailableTool,
            .refusalSafetyOrPolicy,
            .alreadyStateNoop,
            .runtimeError,
            .cancelled,
            .partialAcceptPartialRefuse,
            .stateQuery,
            .capabilityQuery,
            .refusalContractViolation
        ]

        XCTAssertEqual(Set(all).count, 12)
        XCTAssertEqual(DemoRuntimeResultKind.allCases, all)
    }

    func testContextFourDimensions() {
        let snapshot = MockPresentationSnapshotProvider.coldStart()

        XCTAssertGreaterThanOrEqual(snapshot.context.vehicle.speed, 0)
        XCTAssertFalse(snapshot.context.vehicle.gear.isEmpty)
        XCTAssertFalse(snapshot.context.environment.weather.isEmpty)
        XCTAssertFalse(snapshot.context.environment.timePeriod.isEmpty)
    }

    func testColdStartTenFamiliesViaFamilyDisplays() {
        let snapshot = MockPresentationSnapshotProvider.coldStart()
        let cards = VehicleCardDisplay.familyDisplays(from: snapshot.storeCells)

        XCTAssertEqual(Set(cards.compactMap { $0.familyCardID }).count, FamilyCardID.allCases.count)
    }

    func testMockProofClassIsLocalMock() {
        XCTAssertEqual(MockPresentationSnapshotProvider.coldStart().proofClass, .localMock)
    }

    func testNonColdMockSnapshotsCarryRuntimeResultClassification() {
        let snapshots = [
            MockPresentationSnapshotProvider.acStarted(),
            MockPresentationSnapshotProvider.coolingMode(),
            MockPresentationSnapshotProvider.safetyRefusal()
        ]

        for snapshot in snapshots {
            XCTAssertNotNil(snapshot.resultKind)
            if let resultKind = snapshot.resultKind {
                XCTAssertTrue(DemoRuntimeResultKind.allCases.contains(resultKind))
            }
        }
    }

    func testSnapshotCarriesScopeOriginSeparateFromValueSource() {
        let cell = DemoVehicleStateCell(
            key: "window.position[主驾]",
            actualValue: "100",
            source: .user,
            revision: 1,
            visualState: .satisfied
        )
        let snapshot = StagePresentationSnapshot(
            storeCells: [cell],
            scopeOrigins: ["window.position[主驾]": .defaulted]
        )

        XCTAssertEqual(snapshot.storeCells.first?.source, .user)
        XCTAssertEqual(snapshot.scopeOrigins["window.position[主驾]"], .defaulted)
    }
}
