import XCTest
@testable import MAformacCore

final class ForceStateDigestTests: XCTestCase {
    private func makeEntry(
        stableIdentity: String,
        kind: ForceStateCatalogKind = .debug,
        namespace: ForceStateCatalogNamespace = .debug,
        version: String = "v1",
        owner: String = "core-config-force-state"
    ) -> ForceStateCatalogEntry {
        ForceStateCatalogEntry(
            stableIdentity: stableIdentity,
            kind: kind,
            namespace: namespace,
            version: version,
            owner: owner
        )
    }

    // MARK: - Order independence

    func testCanonicalDigestIsOrderIndependent() throws {
        let entryA = makeEntry(stableIdentity: "force.debug.a", kind: .debug, namespace: .debug)
        let entryB = makeEntry(stableIdentity: "force.demo.b", kind: .demo, namespace: .demo)
        let entryC = makeEntry(stableIdentity: "force.debug.c", kind: .debug, namespace: .debug)

        let first = try ForceStateCatalog.load(entries: [entryA, entryB, entryC])
        let second = try ForceStateCatalog.load(entries: [entryC, entryA, entryB])
        let third = try ForceStateCatalog.load(entries: [entryB, entryC, entryA])

        let firstDigest = ForceStateDigest.canonicalDigest(of: first)
        let secondDigest = ForceStateDigest.canonicalDigest(of: second)
        let thirdDigest = ForceStateDigest.canonicalDigest(of: third)

        XCTAssertEqual(firstDigest.digestHex, secondDigest.digestHex)
        XCTAssertEqual(firstDigest.digestHex, thirdDigest.digestHex)
        XCTAssertEqual(firstDigest.algorithm, .sha256V1)
        XCTAssertEqual(firstDigest.canonicalizationVersion, .v1)
        XCTAssertFalse(firstDigest.digestHex.isEmpty)
    }

    // MARK: - Load-bearing field sensitivity

    func testEntrySetChangeFlipsDigest() throws {
        let base = try ForceStateCatalog.load(entries: [
            makeEntry(stableIdentity: "force.debug.a"),
            makeEntry(stableIdentity: "force.demo.b", kind: .demo, namespace: .demo)
        ])
        let extended = try ForceStateCatalog.load(entries: [
            makeEntry(stableIdentity: "force.debug.a"),
            makeEntry(stableIdentity: "force.demo.b", kind: .demo, namespace: .demo),
            makeEntry(stableIdentity: "force.debug.c")
        ])
        XCTAssertNotEqual(
            ForceStateDigest.canonicalDigest(of: base).digestHex,
            ForceStateDigest.canonicalDigest(of: extended).digestHex
        )
    }

    func testStableIdentityChangeFlipsDigest() throws {
        let baseline = try ForceStateCatalog.load(entries: [makeEntry(stableIdentity: "force.a")])
        let alternate = try ForceStateCatalog.load(entries: [makeEntry(stableIdentity: "force.b")])
        XCTAssertNotEqual(
            ForceStateDigest.canonicalDigest(of: baseline).digestHex,
            ForceStateDigest.canonicalDigest(of: alternate).digestHex
        )
    }

    func testKindChangeFlipsDigest() throws {
        let baseline = try ForceStateCatalog.load(entries: [
            makeEntry(stableIdentity: "force.a", kind: .debug)
        ])
        let alternate = try ForceStateCatalog.load(entries: [
            makeEntry(stableIdentity: "force.a", kind: .demo)
        ])
        XCTAssertNotEqual(
            ForceStateDigest.canonicalDigest(of: baseline).digestHex,
            ForceStateDigest.canonicalDigest(of: alternate).digestHex
        )
    }

    func testNamespaceChangeFlipsDigest() throws {
        let baseline = try ForceStateCatalog.load(entries: [
            makeEntry(stableIdentity: "force.a", namespace: .debug)
        ])
        let alternate = try ForceStateCatalog.load(entries: [
            makeEntry(stableIdentity: "force.a", namespace: .demo)
        ])
        XCTAssertNotEqual(
            ForceStateDigest.canonicalDigest(of: baseline).digestHex,
            ForceStateDigest.canonicalDigest(of: alternate).digestHex
        )
    }

    func testVersionChangeFlipsDigest() throws {
        let baseline = try ForceStateCatalog.load(entries: [
            makeEntry(stableIdentity: "force.a", version: "v1")
        ])
        let alternate = try ForceStateCatalog.load(entries: [
            makeEntry(stableIdentity: "force.a", version: "v2")
        ])
        XCTAssertNotEqual(
            ForceStateDigest.canonicalDigest(of: baseline).digestHex,
            ForceStateDigest.canonicalDigest(of: alternate).digestHex
        )
    }

    func testOwnerChangeFlipsDigest() throws {
        let baseline = try ForceStateCatalog.load(entries: [
            makeEntry(stableIdentity: "force.a", owner: "team-alpha")
        ])
        let alternate = try ForceStateCatalog.load(entries: [
            makeEntry(stableIdentity: "force.a", owner: "team-beta")
        ])
        XCTAssertNotEqual(
            ForceStateDigest.canonicalDigest(of: baseline).digestHex,
            ForceStateDigest.canonicalDigest(of: alternate).digestHex
        )
    }

    // MARK: - Fail-closed validation

    func testAbsentMetadataFailsClosed() throws {
        let catalog = try ForceStateCatalog.load(entries: [makeEntry(stableIdentity: "force.a")])
        XCTAssertThrowsError(try ForceStateDigest.validate(metadata: nil, against: catalog)) { error in
            XCTAssertEqual(error as? ForceStateDigestError, .absentMetadata)
        }
    }

    func testMismatchedDigestFailsClosedWithoutSilentRepair() throws {
        let catalog = try ForceStateCatalog.load(entries: [makeEntry(stableIdentity: "force.a")])
        let poisoned = ForceStateDigestMetadata(
            algorithm: .sha256V1,
            canonicalizationVersion: .v1,
            digestHex: String(repeating: "0", count: 64)
        )
        XCTAssertThrowsError(try ForceStateDigest.validate(metadata: poisoned, against: catalog)) { error in
            guard case .mismatchNotRepairedLocally(let expected, let recomputed) = error as? ForceStateDigestError else {
                return XCTFail("expected mismatch error, got \(error)")
            }
            XCTAssertEqual(expected, poisoned.digestHex)
            XCTAssertNotEqual(recomputed, poisoned.digestHex)
        }
    }

    func testValidateReturnsCleanlyOnMatch() throws {
        let catalog = try ForceStateCatalog.load(entries: [
            makeEntry(stableIdentity: "force.demo.a", kind: .demo, namespace: .demo),
            makeEntry(stableIdentity: "force.debug.a", kind: .debug, namespace: .debug)
        ])
        let metadata = ForceStateDigest.canonicalDigest(of: catalog)
        XCTAssertNoThrow(try ForceStateDigest.validate(metadata: metadata, against: catalog))
    }
}
