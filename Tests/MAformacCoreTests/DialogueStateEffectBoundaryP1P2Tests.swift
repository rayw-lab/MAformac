import XCTest
@testable import MAformacCore

final class DialogueStateEffectBoundaryP1P2Tests: XCTestCase {
    private func matrixV1() -> DialogueW7EffectMatrix {
        DialogueW7EffectMatrix(
            version: .v1,
            entries: [
                DialogueW7EffectMatrixEntry(
                    fact: .terminalClear,
                    effect: DialogueW7Effect(
                        focusEffect: .clear,
                        lastReadbackEffect: .clear,
                        activeWindowEffect: .retain,
                        unpairedGroupEffect: .retain,
                        terminalAuditEffect: .retainAsAuditOnly
                    )
                ),
                DialogueW7EffectMatrixEntry(
                    fact: .sessionCleared,
                    effect: DialogueW7Effect(
                        focusEffect: .clear,
                        lastReadbackEffect: .clear,
                        activeWindowEffect: .clear,
                        unpairedGroupEffect: .clear,
                        terminalAuditEffect: .retain
                    )
                ),
                DialogueW7EffectMatrixEntry(
                    fact: .turnCancelled,
                    effect: DialogueW7Effect(
                        focusEffect: .clear,
                        lastReadbackEffect: .clear,
                        activeWindowEffect: .retain,
                        unpairedGroupEffect: .retain,
                        terminalAuditEffect: .retainAsAuditOnly
                    )
                )
            ]
        )
    }

    // MARK: - Round-trip

    func testMatrixRoundTrips() throws {
        let matrix = matrixV1()
        let encoder = DialogueStateSchemaCanonicalCoder.encoder()
        let decoder = DialogueStateSchemaCanonicalCoder.decoder()
        let data1 = try encoder.encode(matrix)
        let decoded = try decoder.decode(DialogueW7EffectMatrix.self, from: data1)
        let data2 = try encoder.encode(decoded)
        XCTAssertEqual(matrix, decoded)
        XCTAssertEqual(data1, data2)
    }

    // MARK: - R6 scenario: transient clear does not impersonate session clear

    func testTerminalClearRetainsActiveWindowAndAuditsOnly() {
        let matrix = matrixV1()
        switch matrix.apply(.terminalClear) {
        case .success(let effect):
            XCTAssertEqual(effect.focusEffect, .clear)
            XCTAssertEqual(effect.lastReadbackEffect, .clear)
            XCTAssertEqual(effect.activeWindowEffect, .retain, "transient clear must preserve active window")
            XCTAssertEqual(effect.terminalAuditEffect, .retainAsAuditOnly)
        case .failure(let error):
            XCTFail("expected success, got \(error)")
        }
    }

    func testSessionClearWipesActiveButAuditMayRetain() {
        let matrix = matrixV1()
        switch matrix.apply(.sessionCleared) {
        case .success(let effect):
            XCTAssertEqual(effect.focusEffect, .clear)
            XCTAssertEqual(effect.lastReadbackEffect, .clear)
            XCTAssertEqual(effect.activeWindowEffect, .clear)
            XCTAssertEqual(effect.unpairedGroupEffect, .clear)
            // terminal audit stays separate — retained without re-entering active
            XCTAssertEqual(effect.terminalAuditEffect, .retain)
        case .failure(let error):
            XCTFail("expected success, got \(error)")
        }
    }

    // MARK: - R6 scenario: effect version mismatch fails closed

    func testEffectVersionMismatchFailsClosed() throws {
        let json = Data(#""w7.effect-matrix/vNext""#.utf8)
        let unsupported = try JSONDecoder().decode(DialogueEffectMatrixVersion.self, from: json)
        let matrix = DialogueW7EffectMatrix(version: unsupported, entries: matrixV1().entries)

        switch matrix.apply(.terminalClear) {
        case .failure(.effectVersionMismatch(let raw)):
            XCTAssertEqual(raw, "w7.effect-matrix/vNext")
        default:
            XCTFail("expected .effectVersionMismatch")
        }
    }

    // MARK: - R1 scenario: unknown W8 fact fails closed

    func testUnknownFactFailsClosed() throws {
        let matrix = matrixV1()
        let json = Data(#""future_fact""#.utf8)
        let unknown = try JSONDecoder().decode(DialogueW8FactKind.self, from: json)
        XCTAssertFalse(unknown.isKnown)

        switch matrix.apply(unknown) {
        case .failure(.unknownFact(let raw)):
            XCTAssertEqual(raw, "future_fact")
        default:
            XCTFail("expected .unknownFact")
        }
    }

    func testKnownFactWithoutMatrixEntryFailsClosed() {
        let matrix = matrixV1() // 只覆盖 terminalClear/sessionCleared/turnCancelled
        switch matrix.apply(.generationFenced) {
        case .failure(.unrecognizedEffect(let raw)):
            XCTAssertEqual(raw, "generation_fenced")
        default:
            XCTFail("expected .unrecognizedEffect")
        }
    }

    // MARK: - R1 scenario: A supported fact produces one deterministic effect

    func testSameFactAlwaysProducesSameEffect() {
        let matrix = matrixV1()
        var results: [DialogueW7Effect] = []
        for _ in 0 ..< 4 {
            if case .success(let effect) = matrix.apply(.turnCancelled) {
                results.append(effect)
            }
        }
        XCTAssertEqual(results.count, 4)
        XCTAssertEqual(Set(results.map(\.focusEffect)), [.clear])
        XCTAssertEqual(Set(results.map(\.terminalAuditEffect)), [.retainAsAuditOnly])
        // 完全等价
        XCTAssertTrue(results.allSatisfy { $0 == results[0] })
    }
}
