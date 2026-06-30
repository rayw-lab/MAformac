import XCTest
@testable import MAformacCore

final class U18DistributionBoundaryGuardTests: XCTestCase {
    func testOnlyPersonalInternalSelfUseAudienceIsAllowed() {
        XCTAssertTrue(DistributionBoundaryGuard.allows(audience: .personalInternalSelfUse))
        XCTAssertFalse(DistributionBoundaryGuard.allows(audience: .appStore))
        XCTAssertFalse(DistributionBoundaryGuard.allows(audience: .testFlight))
        XCTAssertFalse(DistributionBoundaryGuard.allows(audience: .externalCustomerPackage))
    }

    func testStoreAndCustomerFacingArtifactsAreForbidden() {
        XCTAssertTrue(DistributionBoundaryGuard.allows(artifact: .internalReceipt))

        let forbidden: [DistributionArtifactKind] = [
            .appStoreScreenshot,
            .privacyNutrition,
            .storeDescription,
            .releaseNotes,
            .customerFacingClaim
        ]
        for artifact in forbidden {
            XCTAssertFalse(DistributionBoundaryGuard.allows(artifact: artifact), artifact.rawValue)
        }
    }

    func testOnlyLocalUnitCompletionClaimIsAllowed() {
        XCTAssertTrue(DistributionBoundaryGuard.allows(claim: .localUnitComplete))

        let forbidden: [DistributionClaimKind] = [
            .releaseReady,
            .runtimeReady,
            .mobileReady,
            .trueDeviceReady,
            .vPass
        ]
        for claim in forbidden {
            XCTAssertFalse(DistributionBoundaryGuard.allows(claim: claim), claim.rawValue)
        }
    }
}
