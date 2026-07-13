import XCTest
@testable import MAformacCore

/// D2 W9 force-state cutover — deliberate-negative + positive test bundle.
///
/// Anti-fixture-green suite (`~/.claude/rules/claim-vs-reality-gap.md` 铁律 2):
/// this file's job is to prove the applier gates are real. The three gates
/// (canonical digest, primary-class enum, attributed write + ack) each get a
/// positive branch that lands cleanly and a negative branch that refuses to
/// touch the store. The suite also includes a repository-shape probe that
/// re-asserts App/ContentView.swift is clean of raw store.replaceCells calls.
///
/// The tests intentionally *do* consume DemoCapabilityMatrixCatalog.sourceSHA256
/// and DemoCapabilityPrimaryClass.allCases to prove the applier is bound to
/// the canonical values, not a second-SSOT copy.
final class D2ForceStateApplierDeliberateNegativeTests: XCTestCase {

    // MARK: - Fixtures

    @MainActor
    private func makeStore(seed: [DemoVehicleStateCell] = []) -> DemoVehicleStateStore {
        DemoVehicleStateStore(cells: seed)
    }

    private func makeCell(key: String, value: String, revision: Int = 0) -> DemoVehicleStateCell {
        DemoVehicleStateCell(key: key, actualValue: value, revision: revision, visualState: .normal)
    }

    // MARK: - POSITIVE 1 — canonical applier writes and emits ack

    @MainActor
    func testPositive_CanonicalApplierWritesAndEmitsAckWithMatchingDigest() throws {
        let store = makeStore()
        var acks: [DemoVehicleStateApplierTerminalAck] = []
        let applier = DemoVehicleStateApplier(
            store: store,
            ackReceiver: { acks.append($0) },
            clock: { Date(timeIntervalSince1970: 1_720_000_000) }
        )
        let cells = [
            makeCell(key: "ac.power", value: "on"),
            makeCell(key: "window.position[主驾]", value: "50")
        ]

        let ack = try applier.apply(cells: cells, authority: .appMockTransition)

        XCTAssertEqual(store.cells.map(\.key).sorted(), ["ac.power", "window.position[主驾]"],
                       "canonical applier must land the write via replaceCells semantics")
        XCTAssertEqual(ack.authority, .appMockTransition)
        XCTAssertEqual(ack.cellCount, 2)
        XCTAssertEqual(ack.canonicalDigest, DemoCapabilityMatrixCatalog.sourceSHA256,
                       "ack must carry the canonical digest, not a locally-declared copy")
        XCTAssertEqual(acks, [ack], "receiver must be invoked with the same ack the API returned")
    }

    // MARK: - POSITIVE 2 — every authority round-trips

    @MainActor
    func testPositive_EveryAuthorityRoundTripsWithDistinctIdentity() throws {
        let store = makeStore()
        var received: [DemoVehicleStateAuthority] = []
        let applier = DemoVehicleStateApplier(
            store: store,
            ackReceiver: { received.append($0.authority) }
        )
        let cells = [makeCell(key: "ac.power", value: "off")]

        for authority in [
            DemoVehicleStateAuthority.appMockTransition,
            .appMockVoicePlan,
            .appLegacyMockVoiceColdIntent,
            .appForceStateSnapshot
        ] {
            _ = try applier.apply(cells: cells, authority: authority)
        }

        XCTAssertEqual(received, [
            .appMockTransition,
            .appMockVoicePlan,
            .appLegacyMockVoiceColdIntent,
            .appForceStateSnapshot
        ], "each authority must be observable exactly as the caller declared it — no default: fallback")
    }

    // MARK: - POSITIVE 3 — canonical primary-class enum has exactly five entries

    @MainActor
    func testPositive_CanonicalPrimaryClassEnumMatchesCLAUDEMd120ConservedClasses() {
        // CLAUDE.md §9 "canonical digest 消费 DemoCapabilityMatrix.generated.swift
        // sourceSHA256:55 + 5 枚举 :5-9" — probe that the five values exist in
        // the enum-defined order that the applier's Gate 2 relies on.
        XCTAssertEqual(DemoVehicleStateApplier.canonicalPrimaryClasses, [
            .safetyOrClarifyReject,
            .unmountedNameRejected,
            .fastPathNoMatchFallback,
            .defaultExecutable,
            .conditionalDDomainExecutable
        ], "applier's canonical primary-class list must equal the enum values from Core/Contracts/DemoCapabilityMatrix.generated.swift:5-9")
    }

    // MARK: - POSITIVE 4 — canonical digest matches generated source

    @MainActor
    func testPositive_CanonicalDigestMatchesGeneratedSourceSHA256() {
        XCTAssertEqual(DemoVehicleStateApplier.canonicalDigest, DemoCapabilityMatrixCatalog.sourceSHA256,
                       "applier canonical digest must remain a projection of the generated matrix, not a second SSOT")
    }

    // MARK: - POSITIVE 5 — empty cells is still a valid write

    @MainActor
    func testPositive_EmptyCellsIsAValidWriteAndEmitsAckWithZeroCount() throws {
        let store = makeStore(seed: [makeCell(key: "ac.power", value: "on")])
        var acks: [DemoVehicleStateApplierTerminalAck] = []
        let applier = DemoVehicleStateApplier(
            store: store,
            ackReceiver: { acks.append($0) }
        )

        let ack = try applier.apply(cells: [], authority: .appForceStateSnapshot)

        XCTAssertEqual(store.cells.count, 0, "empty cells must translate to store.replaceCells([])")
        XCTAssertEqual(ack.cellCount, 0)
        XCTAssertEqual(acks.count, 1)
    }

    // MARK: - DELIBERATE NEGATIVE 1 — stale digest fails closed

    @MainActor
    func testNegative_StaleDigestRefusesWriteWithoutTouchingStore() {
        let seed = [makeCell(key: "ac.power", value: "on", revision: 3)]
        let store = makeStore(seed: seed)
        var acks: [DemoVehicleStateApplierTerminalAck] = []
        let applier = DemoVehicleStateApplier(
            store: store,
            expectedDigest: "deadbeef-not-canonical",
            ackReceiver: { acks.append($0) }
        )
        let cells = [makeCell(key: "ac.power", value: "off")]

        XCTAssertThrowsError(try applier.apply(cells: cells, authority: .appMockTransition)) { error in
            if case DemoVehicleStateApplierError.digestMismatch(let expected, let actual) = error {
                XCTAssertEqual(expected, DemoCapabilityMatrixCatalog.sourceSHA256)
                XCTAssertEqual(actual, "deadbeef-not-canonical")
            } else {
                XCTFail("expected .digestMismatch, got \(error)")
            }
        }
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on",
                       "stale-digest gate must not touch the store — value must remain 'on' (seed)")
        XCTAssertTrue(acks.isEmpty, "no ack on refused write")
    }

    // MARK: - DELIBERATE NEGATIVE 2 — reordered primary-class list fails closed

    @MainActor
    func testNegative_ReorderedPrimaryClassListRefusesWrite() {
        let seed = [makeCell(key: "ac.power", value: "on")]
        let store = makeStore(seed: seed)
        // Simulate a caller that constructed a second-SSOT copy of the enum
        // with the same members in the wrong order.
        let scrambled: [DemoCapabilityPrimaryClass] = [
            .conditionalDDomainExecutable,
            .safetyOrClarifyReject,
            .unmountedNameRejected,
            .fastPathNoMatchFallback,
            .defaultExecutable
        ]
        let applier = DemoVehicleStateApplier(
            store: store,
            expectedPrimaryClasses: scrambled
        )
        let cells = [makeCell(key: "window.position[主驾]", value: "50")]

        XCTAssertThrowsError(try applier.apply(cells: cells, authority: .appForceStateSnapshot)) { error in
            if case DemoVehicleStateApplierError.primaryClassCatalogMismatch = error {
                // OK
            } else {
                XCTFail("expected .primaryClassCatalogMismatch, got \(error)")
            }
        }
        XCTAssertNil(store.cell(for: "window.position[主驾]"),
                     "primary-class-mismatch gate must not touch the store")
    }

    // MARK: - DELIBERATE NEGATIVE 3 — truncated primary-class list fails closed

    @MainActor
    func testNegative_TruncatedPrimaryClassListRefusesWrite() {
        let store = makeStore()
        let truncated: [DemoCapabilityPrimaryClass] = [
            .safetyOrClarifyReject,
            .unmountedNameRejected,
            .fastPathNoMatchFallback,
            .defaultExecutable
            // .conditionalDDomainExecutable dropped
        ]
        let applier = DemoVehicleStateApplier(
            store: store,
            expectedPrimaryClasses: truncated
        )

        XCTAssertThrowsError(try applier.apply(cells: [makeCell(key: "ac.power", value: "off")],
                                               authority: .appMockTransition))
        XCTAssertEqual(store.cells.count, 0, "dropped-fifth-class gate must not write")
    }

    // MARK: - DELIBERATE NEGATIVE 4 — App/ layer has no raw replaceCells calls

    func testNegative_AppLayerHasNoRawStoreReplaceCellsCallSites() throws {
        // Repo-shape probe: ContentView must NOT contain any non-comment call
        // to `store.replaceCells(`. This is the concrete guarantee the D2 cutover
        // gives — every App-layer write goes through the applier. Comments are
        // allowed and expected because the cutover annotates the removed sites.
        let contentView = try repoRelativeSource("App/ContentView.swift")
        let lines = contentView.split(separator: "\n", omittingEmptySubsequences: false)
        let violators = lines.enumerated().compactMap { (index, line) -> String? in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            // Skip comment lines wholesale
            if trimmed.hasPrefix("//") { return nil }
            // Look for the raw call token
            if trimmed.contains("store.replaceCells(") {
                return "line \(index + 1): \(trimmed)"
            }
            return nil
        }
        XCTAssertTrue(violators.isEmpty,
                      "App/ContentView.swift must not contain raw store.replaceCells( calls after D2 cutover; found:\n\(violators.joined(separator: "\n"))")
    }

    // MARK: - DELIBERATE NEGATIVE 5 — applier does not silently mutate on refusal

    @MainActor
    func testNegative_ApplierDoesNotSilentlyFallbackToDirectReplaceCellsOnRefusal() {
        let seed = [
            makeCell(key: "ac.power", value: "on", revision: 5),
            makeCell(key: "seat.heat", value: "1", revision: 2)
        ]
        let store = makeStore(seed: seed)
        let applier = DemoVehicleStateApplier(
            store: store,
            expectedDigest: "not-canonical",
            expectedPrimaryClasses: [.defaultExecutable]  // deliberately wrong
        )

        let cellsWeMustNotWrite = [makeCell(key: "vehicle.speed", value: "99")]
        XCTAssertThrowsError(try applier.apply(
            cells: cellsWeMustNotWrite,
            authority: .appForceStateSnapshot
        ))

        // Store must remain exactly what the seed put in — no partial apply, no
        // silent fallback to replaceCells. If the applier ever quietly wrote,
        // vehicle.speed would appear and ac.power / seat.heat would vanish.
        XCTAssertEqual(store.cell(for: "ac.power")?.actualValue, "on")
        XCTAssertEqual(store.cell(for: "ac.power")?.revision, 5)
        XCTAssertEqual(store.cell(for: "seat.heat")?.actualValue, "1")
        XCTAssertNil(store.cell(for: "vehicle.speed"),
                     "refused apply must NOT write vehicle.speed = anti-fixture-green invariant")
    }

    // MARK: - Helpers

    private func repoRelativeSource(_ relativePath: String) throws -> String {
        let testFile = URL(fileURLWithPath: #filePath)
        let repoRoot = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try String(contentsOf: repoRoot.appendingPathComponent(relativePath), encoding: .utf8)
    }
}
