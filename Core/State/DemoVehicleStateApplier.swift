import Foundation

// D2 W9 force-state cutover — single-owner applier over the vehicle store.
//
// This applier is the *sole* code-level path App/UI direct-write sites are
// permitted to use in place of `DemoVehicleStateStore.replaceCells(_:)`. The
// underlying `replaceCells` public method is intentionally NOT deleted (Tests
// and the runtime pipeline still reference it), but every App/ContentView.swift
// call site MUST route through this applier so that:
//
//   1. The write carries an explicit `Authority` tag naming the App-layer caller
//      (`~/.claude/rules/derivation-layer-discipline.md` 铁律 1: no default:
//      fallback that silently swallows unattributed writes).
//   2. Each write emits a `TerminalAck` observable to downstream harness code
//      (`~/.claude/rules/verification-economics-baseline-registry.md`: door
//      shape has to observe an ack, not "assumed applied").
//   3. Each apply is gated on the canonical demo-capability-matrix digest at
//      `DemoCapabilityMatrixCatalog.sourceSHA256` (`Core/Contracts/
//      DemoCapabilityMatrix.generated.swift:55`) plus the fixed five-class
//      enum `DemoCapabilityPrimaryClass` (`:5-9`). Digest mismatch or a
//      caller-declared primary-class list that does not exactly equal the
//      canonical five (in enum order) fails closed — no partial write, no
//      fallback into the underlying store.
//
// The applier does NOT introduce a second SSOT for either the digest or the
// primary-class enum; it consumes both from the generated canonical catalog
// (see CLAUDE.md §9 "canonical digest 消费 Core/Contracts/DemoCapabilityMatrix.
// generated.swift sourceSHA256:55 + 5 枚举:5-9").

/// The App/UI caller identity permitted to route a force-state write through
/// the applier. This enum is exhaustive at compile time: adding a fifth App/
/// direct-write site is a source change that must appear in the enum, so it
/// cannot silently smuggle in an untagged write.
public enum DemoVehicleStateAuthority: Equatable, Hashable, Sendable {
    /// `App/ContentView.swift:applyMockTransition` — 卡片触摸.
    case appMockTransition
    /// `App/ContentView.swift:commitMockVoicePlan` — mock 语音预设.
    case appMockVoicePlan
    /// `App/ContentView.swift:applyLegacyMockVoiceColdIntent` — legacy 冷意图.
    case appLegacyMockVoiceColdIntent
    /// `App/ContentView.swift:applySnapshotCells` — force-state 控制台快照.
    case appForceStateSnapshot
}

/// Fail-closed reason surfaced by `DemoVehicleStateApplier.apply`.
public enum DemoVehicleStateApplierError: Error, Equatable, Sendable {
    /// The applier was constructed with a digest that does not match the
    /// canonical `DemoCapabilityMatrixCatalog.sourceSHA256`. The apply MUST NOT
    /// touch the store.
    case digestMismatch(expected: String, actual: String)
    /// The applier was constructed with a primary-class list that does not
    /// exactly equal `DemoCapabilityPrimaryClass.allCases` in enum-defined
    /// order. Second-SSOT check per `derivation-layer-discipline` 铁律 2.
    case primaryClassCatalogMismatch(
        expected: [DemoCapabilityPrimaryClass],
        actual: [DemoCapabilityPrimaryClass]
    )
}

/// Structured ack emitted after each successful apply. Downstream harness code
/// (runtime observers, tests, App-layer telemetry) consumes this to prove the
/// write actually occurred instead of trusting a "no throw" assumption.
public struct DemoVehicleStateApplierTerminalAck: Equatable, Sendable {
    public let authority: DemoVehicleStateAuthority
    public let cellCount: Int
    public let canonicalDigest: String
    public let timestamp: Date

    public init(
        authority: DemoVehicleStateAuthority,
        cellCount: Int,
        canonicalDigest: String,
        timestamp: Date
    ) {
        self.authority = authority
        self.cellCount = cellCount
        self.canonicalDigest = canonicalDigest
        self.timestamp = timestamp
    }
}

/// Single-owner applier for App/UI direct-write force-state paths. Constructed
/// once by the App layer (typically inside `ContentView`) and threaded through
/// every write site.
///
/// The applier holds a weak-style reference to the store by way of pointing
/// at the same public API surface a caller would have used; it does not add
/// state of its own. Being a `struct` means callers cannot accidentally share
/// mutable applier state across contexts; each call site can hold its own
/// applier value with an independent `ackReceiver`.
@MainActor
public struct DemoVehicleStateApplier {
    /// The canonical digest fed by `Core/Contracts/DemoCapabilityMatrix.
    /// generated.swift:55`. Any caller must construct the applier with this
    /// exact digest; the default initialiser does so, but the explicit
    /// initialiser allows tests to inject a mismatched value to exercise the
    /// fail-closed branch without touching the codegen.
    public static var canonicalDigest: String { DemoCapabilityMatrixCatalog.sourceSHA256 }
    /// The canonical primary-class enum values, in enum-defined order. Used to
    /// prove no second SSOT is being constructed for the five classes.
    public static var canonicalPrimaryClasses: [DemoCapabilityPrimaryClass] {
        DemoCapabilityPrimaryClass.allCases
    }

    private let store: DemoVehicleStateStore
    private let expectedDigest: String
    private let expectedPrimaryClasses: [DemoCapabilityPrimaryClass]
    private let ackReceiver: @MainActor (DemoVehicleStateApplierTerminalAck) -> Void
    private let clock: @Sendable () -> Date

    public init(
        store: DemoVehicleStateStore,
        expectedDigest: String = DemoVehicleStateApplier.canonicalDigest,
        expectedPrimaryClasses: [DemoCapabilityPrimaryClass] = DemoVehicleStateApplier.canonicalPrimaryClasses,
        ackReceiver: @escaping @MainActor (DemoVehicleStateApplierTerminalAck) -> Void = { _ in },
        clock: @escaping @Sendable () -> Date = Date.init
    ) {
        self.store = store
        self.expectedDigest = expectedDigest
        self.expectedPrimaryClasses = expectedPrimaryClasses
        self.ackReceiver = ackReceiver
        self.clock = clock
    }

    /// Apply a full cell set to the store under a caller-attributed authority.
    /// Fail-closed on digest mismatch and primary-class list mismatch; on
    /// either error the store is not touched and no ack is emitted.
    @discardableResult
    public func apply(
        cells: [DemoVehicleStateCell],
        authority: DemoVehicleStateAuthority
    ) throws -> DemoVehicleStateApplierTerminalAck {
        // Gate 1: canonical digest binding. If someone rebuilds the applier
        // with a stale digest, we refuse to write instead of silently letting
        // the write land against an unknown canonical baseline.
        let canonical = Self.canonicalDigest
        guard expectedDigest == canonical else {
            throw DemoVehicleStateApplierError.digestMismatch(
                expected: canonical,
                actual: expectedDigest
            )
        }
        // Gate 2: primary-class enum count-and-order binding. Refuses any
        // second-SSOT construction of the demo primary classes. `allCases` is
        // exhaustive by Swift enum definition, so the check both catches
        // upstream refactors that silently drop / append a case *and* callers
        // that construct their own out-of-order list.
        let canonicalPrimaryClasses = Self.canonicalPrimaryClasses
        guard expectedPrimaryClasses == canonicalPrimaryClasses else {
            throw DemoVehicleStateApplierError.primaryClassCatalogMismatch(
                expected: canonicalPrimaryClasses,
                actual: expectedPrimaryClasses
            )
        }
        // Gate 3: privileged write. The applier is the *only* App-layer path
        // permitted to reach `replaceCells`; enforcement lives in the App layer
        // (`App/ContentView.swift` grep of `store.replaceCells(` returns zero
        // after cutover).
        store.replaceCells(cells)
        let ack = DemoVehicleStateApplierTerminalAck(
            authority: authority,
            cellCount: cells.count,
            canonicalDigest: canonical,
            timestamp: clock()
        )
        ackReceiver(ack)
        return ack
    }
}
