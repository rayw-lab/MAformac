import XCTest
@testable import MAformacCore

/// K3 composition-gate RED suite — expected to fail compile/link until
/// `SessionLifecycleCompositionGate` exists (OpenSpec wire-t09 GREEN).
///
/// Expected production API (GREEN implements; no test-local stubs / injection):
/// - `SessionLifecycleCompositionGateError` { sessionMismatch, activationRejected, unexpectedState }
/// - `SessionLifecycleCompositionGate` @MainActor final class
///   - `init(sessionID:generation:)` default generation 0
///   - `var snapshot: SessionLifecycleSnapshot`
///   - `func ensureActive(expectedSessionID:) throws -> SessionLifecycleSnapshot`
///
/// Unit coverage is ready / active / cross-session only.
/// Terminal / recoveryReady are unreachable via this gate API; nonclaims are
/// source-level (no terminal API surface, private ownerAuthority).
@MainActor
final class SessionLifecycleCompositionGateTests: XCTestCase {

    // MARK: - Identity material (immutable per test)

    private let boundSession = SessionID(rawValue: "k3.parent.session.alpha")
    private let otherSession = SessionID(rawValue: "k3.parent.session.beta")
    private let generation0 = SessionGeneration(value: 0)

    private func makeGate(
        sessionID: SessionID? = nil,
        generation: SessionGeneration? = nil
    ) -> SessionLifecycleCompositionGate {
        SessionLifecycleCompositionGate(
            sessionID: sessionID ?? boundSession,
            generation: generation ?? generation0
        )
    }

    // MARK: - 1. First activation

    func testFirstActivation_readyRev0_ensureMatching_becomesActiveRev1SameIdentityAndGen0() throws {
        let gate = makeGate()
        let initial = gate.snapshot

        XCTAssertEqual(initial.state, .ready)
        XCTAssertEqual(initial.sessionID, boundSession)
        XCTAssertEqual(initial.generation, generation0)
        XCTAssertEqual(initial.revision, 0)

        let after = try gate.ensureActive(expectedSessionID: boundSession)

        XCTAssertEqual(after.state, .active)
        XCTAssertEqual(after.sessionID, boundSession)
        XCTAssertEqual(after.generation, generation0)
        XCTAssertEqual(after.revision, 1)
        XCTAssertEqual(gate.snapshot, after)
    }

    // MARK: - 2. Repeat ensureActive is idempotent

    func testRepeatEnsureActive_idempotent_returnsEqualActiveSnapshot_revisionDoesNotIncrease() throws {
        let gate = makeGate()
        let first = try gate.ensureActive(expectedSessionID: boundSession)
        XCTAssertEqual(first.state, .active)
        XCTAssertEqual(first.revision, 1)

        let second = try gate.ensureActive(expectedSessionID: boundSession)

        XCTAssertEqual(second, first)
        XCTAssertEqual(second.state, .active)
        XCTAssertEqual(second.revision, first.revision)
        XCTAssertEqual(gate.snapshot, first)
    }

    // MARK: - 3. Mismatch before first activation

    func testMismatchBeforeFirstActivation_throwsSessionMismatch_snapshotRemainsReadyRev0() {
        let gate = makeGate()
        let before = gate.snapshot
        XCTAssertEqual(before.state, .ready)
        XCTAssertEqual(before.revision, 0)

        XCTAssertThrowsError(try gate.ensureActive(expectedSessionID: otherSession)) { error in
            guard let gateError = error as? SessionLifecycleCompositionGateError else {
                return XCTFail("expected SessionLifecycleCompositionGateError, got \(error)")
            }
            XCTAssertEqual(
                gateError,
                .sessionMismatch(expected: boundSession, received: otherSession)
            )
        }

        XCTAssertEqual(gate.snapshot, before)
        XCTAssertEqual(gate.snapshot.state, .ready)
        XCTAssertEqual(gate.snapshot.revision, 0)
    }

    // MARK: - 4. Mismatch after active

    func testMismatchAfterActive_throws_snapshotEqualsPriorActive() throws {
        let gate = makeGate()
        let active = try gate.ensureActive(expectedSessionID: boundSession)
        XCTAssertEqual(active.state, .active)

        XCTAssertThrowsError(try gate.ensureActive(expectedSessionID: otherSession)) { error in
            guard let gateError = error as? SessionLifecycleCompositionGateError else {
                return XCTFail("expected SessionLifecycleCompositionGateError, got \(error)")
            }
            XCTAssertEqual(
                gateError,
                .sessionMismatch(expected: boundSession, received: otherSession)
            )
        }

        XCTAssertEqual(gate.snapshot, active)
        XCTAssertEqual(gate.snapshot.state, .active)
        XCTAssertEqual(gate.snapshot.revision, active.revision)
    }

    // MARK: - 5. App source contract (FrontstageRuntimeComposition)

    func testAppSourceContract_sessionLifecycleGatePropertyAndEnsureActiveBeforeRoute() throws {
        let sourceURL = repoRoot().appendingPathComponent("App/FrontstageRuntimeComposition.swift")
        let source = try String(contentsOf: sourceURL, encoding: .utf8)

        XCTAssertTrue(
            source.contains("private var sessionLifecycleGate: SessionLifecycleCompositionGate?"),
            "composition must hold exact lazy optional gate property"
        )

        // routeDemoSlice body through first closing brace after the method start.
        let routeSlice = try section(in: source, from: "func routeDemoSlice", until: "\n}")

        let ensureNeedle = "ensureActive"
        let demoSliceRouteCreate = "DemoSliceRoute("
        // Production multi-line surface (not legacy single-arg `.route(text: turn.utterance)`):
        //   demoSliceRoute!.route(
        //       text: turn.utterance,
        //       correlationProvider: correlationProvider
        //   )
        let routeUtteranceArg = "text: turn.utterance"
        let routeCorrelationArg = "correlationProvider: correlationProvider"

        XCTAssertTrue(routeSlice.contains(ensureNeedle), "routeDemoSlice must call ensureActive")
        XCTAssertTrue(
            routeSlice.contains(demoSliceRouteCreate),
            "routeDemoSlice still constructs DemoSliceRoute after guard"
        )
        XCTAssertTrue(
            routeSlice.contains(routeUtteranceArg),
            "routeDemoSlice still routes utterance after guard"
        )
        XCTAssertTrue(
            routeSlice.contains(routeCorrelationArg),
            "routeDemoSlice must pass product correlation provider on production route"
        )
        XCTAssertFalse(routeSlice.contains(".route(text: turn.utterance)"),
        "production path must not use legacy single-arg .route(text: turn.utterance)")

        let ensureIdx = try index(of: ensureNeedle, in: routeSlice)
        let demoCreateIdx = try index(of: demoSliceRouteCreate, in: routeSlice)
        let routeUtteranceIdx = try index(of: routeUtteranceArg, in: routeSlice)
        let routeCorrelationIdx = try index(of: routeCorrelationArg, in: routeSlice)
        XCTAssertLessThan(ensureIdx, demoCreateIdx, "ensureActive must appear before DemoSliceRoute(")
        XCTAssertLessThan(
            ensureIdx,
            routeUtteranceIdx,
            "ensureActive must appear before production route text: turn.utterance"
        )
        XCTAssertLessThan(
            ensureIdx,
            routeCorrelationIdx,
            "ensureActive must appear before production route correlationProvider: correlationProvider"
        )

        // Explicit active-state guard + turn session identity wiring.
        XCTAssertTrue(
            routeSlice.contains("== .active") || routeSlice.contains(".active"),
            "routeDemoSlice must explicitly guard active state on returned snapshot"
        )
        let hasRawEquality =
            routeSlice.contains("sessionID.rawValue") && routeSlice.contains("turn.sessionID")
        let hasEnsureWithTurn =
            routeSlice.contains("ensureActive") && routeSlice.contains("turn.sessionID")
        XCTAssertTrue(
            hasRawEquality || hasEnsureWithTurn,
            "must wire turn.sessionID into ensureActive and/or snapshot identity guard"
        )

        let initSection = try section(in: source, from: "init(session:", until: "func markCurrent")
        XCTAssertFalse(initSection.contains("sessionLifecycleGate"),
        "init(session:) must not assign sessionLifecycleGate (lazy optional)")

        XCTAssertFalse(routeSlice.contains("DemoRuntimeSessionRunner"),
        "routeDemoSlice must not wire DemoRuntimeSessionRunner")
        XCTAssertFalse(routeSlice.contains("C3ExecutionPipeline"),
        "routeDemoSlice must not wire C3ExecutionPipeline")
        XCTAssertEqual(occurrences(of: "DemoRuntimeSessionRunner", in: source), 0)
        XCTAssertEqual(occurrences(of: "C3ExecutionPipeline", in: source), 0)
    }

    // MARK: - 6. Gate source contract

    func testGateSourceContract_noTerminalAPI_privateOwner_mainActor() throws {
        let sourceURL = repoRoot()
            .appendingPathComponent("Core/Lifecycle/SessionLifecycleCompositionGate.swift")
        let source = try String(contentsOf: sourceURL, encoding: .utf8)

        XCTAssertFalse(source.contains("apply(.terminal"),
        "gate must not apply terminal events")
        XCTAssertFalse(source.contains("recoveryReady"),
        "gate must not surface recoveryReady transitions")
        XCTAssertFalse(source.contains("newGeneration"),
        "gate must not surface newGeneration transitions")
        XCTAssertTrue(
            source.contains("private") && source.contains("ownerAuthority"),
            "ownerAuthority must be private"
        )
        XCTAssertTrue(
            source.contains("@MainActor"),
            "SessionLifecycleCompositionGate must be @MainActor"
        )
        XCTAssertTrue(
            source.contains("final class SessionLifecycleCompositionGate"),
            "expected public final class SessionLifecycleCompositionGate"
        )
    }

    // MARK: - Source helpers

    private func repoRoot() -> URL {
        // Tests/MAformacCoreTests/<file> → up 3 → package root
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func occurrences(of needle: String, in source: String) -> Int {
        var count = 0
        var search = source.startIndex..<source.endIndex
        while let range = source.range(of: needle, range: search) {
            count += 1
            search = range.upperBound..<source.endIndex
        }
        return count
    }

    private func section(in source: String, from start: String, until end: String) throws -> String {
        guard let startRange = source.range(of: start) else {
            throw NSError(
                domain: "SessionLifecycleCompositionGateTests",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "missing start marker: \(start)"]
            )
        }
        let tail = source[startRange.lowerBound...]
        if end == "\u{0}" {
            return String(tail)
        }
        guard let endRange = tail.range(of: end) else {
            return String(tail)
        }
        return String(tail[..<endRange.lowerBound])
    }

    private func index(of needle: String, in source: String) throws -> String.Index {
        guard let range = source.range(of: needle) else {
            throw NSError(
                domain: "SessionLifecycleCompositionGateTests",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "missing needle: \(needle)"]
            )
        }
        return range.lowerBound
    }
}
