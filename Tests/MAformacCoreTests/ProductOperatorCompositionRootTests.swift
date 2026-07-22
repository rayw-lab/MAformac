import XCTest

/// S0 production composition root proofs.
///
/// App types (`FrontstageRuntimeComposition`) are not instantiated by SwiftPM
/// unit tests. Fail-closed identity assembly and sole-root wiring are enforced
/// via source contracts over `App/FrontstageRuntimeComposition.swift` and
/// `App/ContentView.swift`. Core route/provider behavior is covered in
/// `ProductOperatorCorrelationWireTests` / `DemoSliceRouteTests`.
final class ProductOperatorCompositionRootTests: XCTestCase {
    private var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    // MARK: - Sole production composition root

    func testSoleProductionCompositionRoot_oneCachedRouteAndS0FreezeComment() throws {
        let source = try compositionSource()

        XCTAssertTrue(
            source.contains("final class FrontstageRuntimeComposition"),
            "production composition root type must exist"
        )
        XCTAssertTrue(
            source.contains("sole customer-facing production composition root")
                || source.contains("S0 freeze"),
            "S0 freeze comment must name this type as the sole production root"
        )
        XCTAssertEqual(
            occurrences(of: "private var demoSliceRoute: DemoSliceRoute?", in: source),
            1,
            "exactly one cached DemoSliceRoute optional"
        )
        XCTAssertEqual(
            occurrences(of: "DemoSliceRoute(", in: source),
            1,
            "route must be constructed once (lazy cache), not per-call re-root"
        )
        XCTAssertEqual(
            occurrences(of: "private var sessionLifecycleGate: SessionLifecycleCompositionGate?", in: source),
            1
        )
    }

    func testContentViewUsesCompositionRootAndHasNoLocalProductionRunner() throws {
        let source = try String(
            contentsOf: repoRoot.appendingPathComponent("App/ContentView.swift"),
            encoding: .utf8
        )

        XCTAssertTrue(source.contains("FrontstageRuntimeComposition"))
        XCTAssertTrue(source.contains("frontstageRuntimeComposition.routeDemoSlice"))
        XCTAssertEqual(
            occurrences(of: "DemoSliceRoute(", in: source),
            0,
            "ContentView must not construct a second DemoSliceRoute production root"
        )
        XCTAssertEqual(
            occurrences(of: "DemoRuntimeSessionRunner(", in: source),
            0,
            "ContentView must not host a ContentView-local production runner"
        )
        XCTAssertFalse(source.contains("ProductionRouteCorrelationProvider.make"),
        "correlation factory belongs in composition root, not ContentView")
    }

    // MARK: - Fail-closed typed errors before route success

    func testProductionRootFailClosed_typedMismatchAndInvalidSequenceBeforeRoute() throws {
        let source = try compositionSource()
        let routeBody = try routeDemoSliceBody(in: source)

        // Typed error surface (not silent precondition-only).
        XCTAssertTrue(source.contains("enum FrontstageRuntimeCompositionError"))
        XCTAssertTrue(source.contains("case currentTurnMismatch"))
        XCTAssertTrue(source.contains("case invalidTurnSequence"))
        XCTAssertTrue(source.contains("case emptyTurnIdentity"))

        // Order: current-turn guard → identity/sequence fail-closed → factory → route(provider).
        let mismatchThrow = "FrontstageRuntimeCompositionError.currentTurnMismatch"
        let invalidSeqThrow = "FrontstageRuntimeCompositionError.invalidTurnSequence"
        let emptyIdentityThrow = "FrontstageRuntimeCompositionError.emptyTurnIdentity"
        let factoryCall = "ProductionRouteCorrelationProvider.make"
        let routeWithProvider = "correlationProvider: correlationProvider"

        XCTAssertTrue(routeBody.contains(mismatchThrow))
        XCTAssertTrue(routeBody.contains(invalidSeqThrow))
        XCTAssertTrue(routeBody.contains(emptyIdentityThrow))
        XCTAssertTrue(routeBody.contains(factoryCall))
        XCTAssertTrue(routeBody.contains(routeWithProvider))

        let mismatchIdx = try index(of: mismatchThrow, in: routeBody)
        let invalidSeqIdx = try index(of: invalidSeqThrow, in: routeBody)
        let factoryIdx = try index(of: factoryCall, in: routeBody)
        let routeIdx = try index(of: routeWithProvider, in: routeBody)

        XCTAssertLessThan(
            mismatchIdx,
            factoryIdx,
            "stale/current-turn mismatch must throw before correlation factory"
        )
        XCTAssertLessThan(
            invalidSeqIdx,
            factoryIdx,
            "invalid sequence must throw before correlation factory"
        )
        XCTAssertLessThan(
            factoryIdx,
            routeIdx,
            "correlation factory must run before production route call"
        )

        // Production surface must not call the nil-provider legacy helper as a single-arg route.
        // Multi-line production call is: .route(\n text: turn.utterance,\n correlationProvider: ...)
        XCTAssertTrue(routeBody.contains("text: turn.utterance"))
        XCTAssertTrue(routeBody.contains("correlationProvider: correlationProvider"))
        XCTAssertFalse(routeBody.contains(".route(text: turn.utterance)"),
        "production path must not use legacy single-arg route(text:) without correlationProvider")
    }

    func testProductionRootWiresLifecycleIdentityIntoFactoryInputs() throws {
        let source = try compositionSource()
        let routeBody = try routeDemoSliceBody(in: source)

        XCTAssertTrue(routeBody.contains("ensureActive"))
        XCTAssertTrue(routeBody.contains("routeTurnID:"))
        XCTAssertTrue(routeBody.contains("sessionRef:"))
        XCTAssertTrue(routeBody.contains("generationRef:"))
        XCTAssertTrue(routeBody.contains("groupOrdinal:"))
        XCTAssertTrue(
            routeBody.contains("lifecycleSnapshot.generation")
                || routeBody.contains("String(lifecycleSnapshot.generation.value)")
        )
        XCTAssertTrue(
            routeBody.contains("UInt32(exactly: turn.sequence)")
                || routeBody.contains("UInt32(exactly:")
        )

        let ensureIdx = try index(of: "ensureActive", in: routeBody)
        let factoryIdx = try index(of: "ProductionRouteCorrelationProvider.make", in: routeBody)
        XCTAssertLessThan(ensureIdx, factoryIdx, "ensureActive must precede correlation factory")
    }

    // MARK: - Helpers

    private func compositionSource() throws -> String {
        try String(
            contentsOf: repoRoot.appendingPathComponent("App/FrontstageRuntimeComposition.swift"),
            encoding: .utf8
        )
    }

    /// Extract `routeDemoSlice` body by brace depth (avoids cutting on nested `}`).
    private func routeDemoSliceBody(in source: String) throws -> String {
        guard let start = source.range(of: "func routeDemoSlice") else {
            throw NSError(
                domain: "ProductOperatorCompositionRootTests",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "missing func routeDemoSlice"]
            )
        }
        let fromFunc = source[start.lowerBound...]
        guard let openBrace = fromFunc.firstIndex(of: "{") else {
            throw NSError(
                domain: "ProductOperatorCompositionRootTests",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "missing opening brace for routeDemoSlice"]
            )
        }
        var depth = 0
        var idx = openBrace
        while idx < fromFunc.endIndex {
            let ch = fromFunc[idx]
            if ch == "{" { depth += 1 }
            if ch == "}" {
                depth -= 1
                if depth == 0 {
                    return String(fromFunc[openBrace...idx])
                }
            }
            idx = fromFunc.index(after: idx)
        }
        throw NSError(
            domain: "ProductOperatorCompositionRootTests",
            code: 3,
            userInfo: [NSLocalizedDescriptionKey: "unbalanced braces in routeDemoSlice"]
        )
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

    private func index(of needle: String, in source: String) throws -> String.Index {
        guard let range = source.range(of: needle) else {
            throw NSError(
                domain: "ProductOperatorCompositionRootTests",
                code: 4,
                userInfo: [NSLocalizedDescriptionKey: "missing needle: \(needle)"]
            )
        }
        return range.lowerBound
    }
}
