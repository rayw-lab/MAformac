import XCTest
@testable import MAformacCore

final class DemoForceStateBoundaryTests: XCTestCase {
    func testAcceptsDebugHarnessContextWithLocalUnitProofOnly() throws {
        XCTAssertTrue(DemoForceStateBuildIsolation.isDebugOrDemoMode)

        let context = try DemoForceStateBoundary().accept(
            isolation: .debug,
            event: demoHarnessEvent(),
            values: [
                DemoForceStateValue(dimension: .vehicleSpeed, value: "82"),
                DemoForceStateValue(dimension: .environmentWeather, value: "heavy_rain")
            ]
        )

        XCTAssertEqual(context.isolation, .debug)
        XCTAssertEqual(context.provenanceEventID, "evt.force-state.gate3")
        XCTAssertEqual(context.provenanceTraceID, "trace.force-state.gate3")
        XCTAssertEqual(context.values.map(\.dimension), [.vehicleSpeed, .environmentWeather])
        XCTAssertEqual(context.proofClass, .localUnit)
        XCTAssertTrue(context.proofClass.displayCaps.isEmpty)
    }

    func testCustomerFacingIsolationFailsClosed() throws {
        XCTAssertThrowsError(
            try DemoForceStateBoundary().accept(
                isolation: .customerFacing,
                event: demoHarnessEvent(),
                values: [DemoForceStateValue(dimension: .vehicleGear, value: "drive")]
            )
        ) { error in
            XCTAssertEqual(
                error as? DemoForceStateBoundaryError,
                .unsupportedIsolation(.customerFacing)
            )
        }
    }

    func testMissingDemoHarnessProvenanceFailsClosed() throws {
        XCTAssertThrowsError(
            try DemoForceStateBoundary().accept(
                isolation: .demoMode,
                event: DemoInteractionEvent(
                    eventID: "evt.user",
                    traceID: "trace.user",
                    kind: .cardTap,
                    source: .user
                ),
                values: [DemoForceStateValue(dimension: .vehicleSpeed, value: "82")]
            )
        ) { error in
            XCTAssertEqual(error as? DemoForceStateBoundaryError, .missingDemoHarnessProvenance)
        }

        XCTAssertThrowsError(
            try DemoForceStateBoundary().accept(
                isolation: .demoMode,
                event: DemoInteractionEvent(
                    eventID: "evt.no-trace",
                    kind: .cardTap,
                    source: .demoHarness
                ),
                values: [DemoForceStateValue(dimension: .vehicleSpeed, value: "82")]
            )
        ) { error in
            XCTAssertEqual(error as? DemoForceStateBoundaryError, .missingDemoHarnessProvenance)
        }
    }

    func testEmptyOrDuplicateContextFailsClosed() throws {
        XCTAssertThrowsError(
            try DemoForceStateBoundary().accept(
                isolation: .debug,
                event: demoHarnessEvent(),
                values: []
            )
        ) { error in
            XCTAssertEqual(error as? DemoForceStateBoundaryError, .emptyContext)
        }

        XCTAssertThrowsError(
            try DemoForceStateBoundary().accept(
                isolation: .debug,
                event: demoHarnessEvent(),
                values: [
                    DemoForceStateValue(dimension: .vehicleSpeed, value: "82"),
                    DemoForceStateValue(dimension: .vehicleSpeed, value: "12")
                ]
            )
        ) { error in
            XCTAssertEqual(error as? DemoForceStateBoundaryError, .duplicateDimension(.vehicleSpeed))
        }
    }

    func testBoundaryDoesNotExposeRuntimeAdapterPrivateNames() {
        let publicNames = Set(
            DemoForceStateIsolation.allCases.map(\.rawValue)
                + ForceStateContextDimension.allCases.map(\.rawValue)
        )

        for forbiddenName in [
            "DemoRuntimeAdapter",
            "RuntimeAdapterBox",
            "requestFingerprint",
            "parentRequestFingerprint",
            "failureLedger",
            "rawRuntimeStore",
            "rawModelOutput",
            "trainingReceipt"
        ] {
            XCTAssertFalse(publicNames.contains(forbiddenName), forbiddenName)
        }
    }

    private func demoHarnessEvent() -> DemoInteractionEvent {
        DemoInteractionEvent(
            eventID: "evt.force-state.gate3",
            traceID: "trace.force-state.gate3",
            kind: .cardTap,
            source: .demoHarness
        )
    }
}
