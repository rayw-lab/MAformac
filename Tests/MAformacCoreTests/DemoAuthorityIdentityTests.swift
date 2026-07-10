import XCTest
@testable import MAformacCore

final class DemoAuthorityIdentityTests: XCTestCase {
    func testCurrentCarriesDistinctCanonicalDigests() {
        let identity = DemoAuthorityIdentity.current
        XCTAssertEqual(identity.matrixSourceSHA256.count, 64)
        XCTAssertEqual(identity.runtimeContractBundleDigest.count, 64)
        XCTAssertNotEqual(identity.matrixSourceSHA256, identity.runtimeContractBundleDigest)
    }
}
