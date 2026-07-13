import XCTest
@testable import MAformacCore

final class DialogueStateRouteCorrelationP1P2Tests: XCTestCase {
    private func attribution(
        turn: String = "turn-1",
        trace: String = "trace-1",
        digest: String? = "digest-abc",
        candidate: String? = "cand-1",
        version: DialogueStateSchemaVersion = .v1
    ) -> DialogueRouteAttribution {
        DialogueRouteAttribution(
            routeTurnID: RouteTurnIdentifier(turn),
            routeTraceID: RouteTraceIdentifier(trace),
            traceDigestRef: digest,
            actionCandidateRef: candidate,
            schemaVersion: version
        )
    }

    private func dialogueRef() -> DialogueSourceGroupRef {
        DialogueSourceGroupRef(sessionRef: "sess-A", generationRef: "gen-1", groupOrdinal: 1)
    }

    // MARK: - Round-trip

    func testCorrelationRoundTrips() throws {
        let correlation = RouteToDialogueCorrelation(
            route: attribution(),
            dialogueGroupRef: dialogueRef(),
            schemaVersion: .v1
        )
        let encoder = DialogueStateSchemaCanonicalCoder.encoder()
        let decoder = DialogueStateSchemaCanonicalCoder.decoder()
        let data1 = try encoder.encode(correlation)
        let decoded = try decoder.decode(RouteToDialogueCorrelation.self, from: data1)
        let data2 = try encoder.encode(decoded)
        XCTAssertEqual(correlation, decoded)
        XCTAssertEqual(data1, data2)
    }

    func testCorrelationRoundTripsWithNilOptionals() throws {
        let correlation = RouteToDialogueCorrelation(
            route: attribution(digest: nil, candidate: nil),
            dialogueGroupRef: dialogueRef(),
            schemaVersion: .v1
        )
        let encoder = DialogueStateSchemaCanonicalCoder.encoder()
        let decoder = DialogueStateSchemaCanonicalCoder.decoder()
        let data1 = try encoder.encode(correlation)
        let decoded = try decoder.decode(RouteToDialogueCorrelation.self, from: data1)
        let data2 = try encoder.encode(decoded)
        XCTAssertEqual(correlation, decoded)
        XCTAssertEqual(data1, data2)
    }

    // MARK: - Supported validate

    func testSupportedCorrelationValidates() {
        let correlation = RouteToDialogueCorrelation(
            route: attribution(),
            dialogueGroupRef: dialogueRef(),
            schemaVersion: .v1
        )
        switch DialogueRouteCorrelationValidator.validate(correlation) {
        case .success(let value): XCTAssertEqual(value, correlation)
        case .failure(let error): XCTFail("expected success got \(error)")
        }
    }

    // MARK: - Fail-closed: unsupported schema version

    func testCorrelationUnsupportedVersionFailsClosed() throws {
        let json = Data(#""w7.dialogue-state/vNext""#.utf8)
        let unsupported = try JSONDecoder().decode(DialogueStateSchemaVersion.self, from: json)
        let correlation = RouteToDialogueCorrelation(
            route: attribution(version: unsupported),
            dialogueGroupRef: dialogueRef(),
            schemaVersion: unsupported
        )
        switch DialogueRouteCorrelationValidator.validate(correlation) {
        case .failure(.unsupportedSchemaVersion(let raw)):
            XCTAssertEqual(raw, "w7.dialogue-state/vNext")
        default:
            XCTFail("expected .unsupportedSchemaVersion")
        }
    }

    // MARK: - Fail-closed: route/correlation version mismatch

    func testRouteAndCorrelationVersionMismatchFailsClosed() throws {
        // outer v1, inner is a different (still supported-shaped) raw string via decode of unsupported form.
        // 手动构造 mismatch：route side 用 .v1，correlation side 用 unsupported raw
        // 但都必须 fail-closed 的情况我们靠 supported-vs-unsupported 已覆盖；
        // 这里造一个「都是 supported 但 raw 字符串不等」也不可能（.v1 唯一）——
        // 因此额外测：outer unsupported、inner v1 → fail on outer version check first。
        let json = Data(#""w7.dialogue-state/vNext""#.utf8)
        let unsupported = try JSONDecoder().decode(DialogueStateSchemaVersion.self, from: json)
        let correlation = RouteToDialogueCorrelation(
            route: attribution(version: .v1),
            dialogueGroupRef: dialogueRef(),
            schemaVersion: unsupported
        )
        switch DialogueRouteCorrelationValidator.validate(correlation) {
        case .failure(.unsupportedSchemaVersion(let raw)):
            XCTAssertEqual(raw, "w7.dialogue-state/vNext")
        default:
            XCTFail("expected .unsupportedSchemaVersion for outer mismatch")
        }
    }

    // MARK: - Fail-closed: missing identifiers

    func testMissingRouteTurnIDFailsClosed() {
        let correlation = RouteToDialogueCorrelation(
            route: attribution(turn: ""),
            dialogueGroupRef: dialogueRef(),
            schemaVersion: .v1
        )
        switch DialogueRouteCorrelationValidator.validate(correlation) {
        case .failure(.missingRouteTurnID): break
        default: XCTFail("expected .missingRouteTurnID")
        }
    }

    func testMissingRouteTraceIDFailsClosed() {
        let correlation = RouteToDialogueCorrelation(
            route: attribution(trace: ""),
            dialogueGroupRef: dialogueRef(),
            schemaVersion: .v1
        )
        switch DialogueRouteCorrelationValidator.validate(correlation) {
        case .failure(.missingRouteTraceID): break
        default: XCTFail("expected .missingRouteTraceID")
        }
    }

    func testMissingDialogueSessionRefFailsClosed() {
        let correlation = RouteToDialogueCorrelation(
            route: attribution(),
            dialogueGroupRef: DialogueSourceGroupRef(sessionRef: "", generationRef: "gen-1", groupOrdinal: 1),
            schemaVersion: .v1
        )
        switch DialogueRouteCorrelationValidator.validate(correlation) {
        case .failure(.dialogueGroupRefMissingIdentity(let field)):
            XCTAssertEqual(field, "sessionRef")
        default:
            XCTFail("expected .dialogueGroupRefMissingIdentity(sessionRef)")
        }
    }

    func testMissingDialogueGenerationRefFailsClosed() {
        let correlation = RouteToDialogueCorrelation(
            route: attribution(),
            dialogueGroupRef: DialogueSourceGroupRef(sessionRef: "sess-A", generationRef: "", groupOrdinal: 1),
            schemaVersion: .v1
        )
        switch DialogueRouteCorrelationValidator.validate(correlation) {
        case .failure(.dialogueGroupRefMissingIdentity(let field)):
            XCTAssertEqual(field, "generationRef")
        default:
            XCTFail("expected .dialogueGroupRefMissingIdentity(generationRef)")
        }
    }

    // MARK: - Wire responsibility marker uninhabited

    func testWireResponsibilityMarkerIsUninhabited() {
        // uninhabited type 大小为 0，静态证据 D1 wire 未落地。
        XCTAssertEqual(MemoryLayout<RouteToDialogueWireResponsibilityMarker>.size, 0)
    }
}
