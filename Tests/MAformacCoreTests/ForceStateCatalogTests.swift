import XCTest
@testable import MAformacCore

final class ForceStateCatalogTests: XCTestCase {
    private func makeEntry(
        stableIdentity: String = "force.entry.default",
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

    func testLoadsHappyPathWithBothExplicitKinds() throws {
        let catalog = try ForceStateCatalog.load(entries: [
            makeEntry(stableIdentity: "force.debug.a", kind: .debug, namespace: .debug),
            makeEntry(stableIdentity: "force.demo.a", kind: .demo, namespace: .demo)
        ])
        XCTAssertEqual(catalog.entries.count, 2)
        XCTAssertEqual(Set(catalog.entries.map(\.kind)), [.debug, .demo])
        XCTAssertEqual(Set(catalog.entries.map(\.namespace)), [.debug, .demo])
    }

    func testDuplicateStableIdentityFailsClosed() {
        XCTAssertThrowsError(
            try ForceStateCatalog.load(entries: [
                makeEntry(stableIdentity: "force.dup", kind: .debug, namespace: .debug),
                makeEntry(stableIdentity: "force.dup", kind: .demo, namespace: .demo)
            ])
        ) { error in
            XCTAssertEqual(
                error as? ForceStateCatalogError,
                .duplicateStableIdentity("force.dup")
            )
        }
    }

    func testEmptyStableIdentityFailsClosed() {
        XCTAssertThrowsError(
            try ForceStateCatalog.load(entries: [makeEntry(stableIdentity: "   ")])
        ) { error in
            XCTAssertEqual(error as? ForceStateCatalogError, .emptyStableIdentity)
        }
    }

    func testEmptyVersionFailsClosed() {
        XCTAssertThrowsError(
            try ForceStateCatalog.load(entries: [makeEntry(stableIdentity: "force.a", version: " ")])
        ) { error in
            XCTAssertEqual(
                error as? ForceStateCatalogError,
                .emptyVersion(stableIdentity: "force.a")
            )
        }
    }

    func testEmptyOwnerFailsClosed() {
        XCTAssertThrowsError(
            try ForceStateCatalog.load(entries: [makeEntry(stableIdentity: "force.a", owner: "")])
        ) { error in
            XCTAssertEqual(
                error as? ForceStateCatalogError,
                .emptyOwner(stableIdentity: "force.a")
            )
        }
    }

    func testEmptyEntriesLoadIsAllowed() throws {
        // The M16-011 SHALL does not require a minimum non-zero cardinality;
        // it only requires exhaustive typed debug/demo representation.
        let catalog = try ForceStateCatalog.load(entries: [])
        XCTAssertTrue(catalog.entries.isEmpty)
    }

    func testAggregatorRefusesSecondSameMeaningAuthority() throws {
        let first = try ForceStateCatalog.load(entries: [makeEntry(stableIdentity: "force.a")])
        let second = try ForceStateCatalog.load(entries: [makeEntry(stableIdentity: "force.b")])

        let aggregator = ForceStateCatalogAggregator()
        try aggregator.install(first)
        XCTAssertEqual(aggregator.current?.entries.map(\.stableIdentity), ["force.a"])

        XCTAssertThrowsError(try aggregator.install(second)) { error in
            XCTAssertEqual(
                error as? ForceStateCatalogError,
                .secondSameMeaningAuthority
            )
        }
        // First installed catalog remains retrievable; second is rejected.
        XCTAssertEqual(aggregator.current?.entries.map(\.stableIdentity), ["force.a"])
    }
}
