import XCTest
@testable import MAformacCore

final class DialogueStateWindowEnvelopeP1P2Tests: XCTestCase {
    // MARK: - Fixtures

    private func makeIdentity(_ ordinal: UInt32 = 1) -> DialogueGroupIdentity {
        DialogueGroupIdentity(
            sessionRef: "sess-A",
            generationRef: "gen-1",
            groupOrdinal: ordinal
        )
    }

    private func makePairedGroup(_ ordinal: UInt32) -> DialogueGroupRecord {
        DialogueGroupRecord(
            identity: makeIdentity(ordinal),
            completeness: DialogueGroupCompleteness(
                disposition: .paired,
                reason: .pairedComplete
            ),
            userText: "u\(ordinal)",
            assistantText: "a\(ordinal)"
        )
    }

    // MARK: - Supported round-trip

    func testSupportedEnvelopeRoundTripsExactlyWithSortedKeys() throws {
        let envelope = DialogueStateWindowEnvelope(
            schemaVersion: .v1,
            identity: makeIdentity(),
            bound: DialogueWindowBound(maxActiveGroups: 5),
            activeGroups: [makePairedGroup(1)],
            auditGroups: [],
            focusValidity: DialogueFieldValidityRecord(
                reason: .derivedFromReadback,
                sourceGroupRef: DialogueSourceGroupRef(identity: makeIdentity()),
                schemaVersion: .v1
            ),
            readbackValidity: nil,
            sourceReferences: [
                DialogueSourceReference(
                    groupRef: DialogueSourceGroupRef(identity: makeIdentity()),
                    sourceKind: .readback
                )
            ]
        )

        let encoder = DialogueStateSchemaCanonicalCoder.encoder()
        let decoder = DialogueStateSchemaCanonicalCoder.decoder()

        let data1 = try encoder.encode(envelope)
        let decoded = try decoder.decode(DialogueStateWindowEnvelope.self, from: data1)
        let data2 = try encoder.encode(decoded)

        XCTAssertEqual(decoded, envelope)
        XCTAssertEqual(data1, data2, "canonical JSON must be byte-stable")
    }

    // MARK: - Fail-closed: missing identity

    func testMissingSessionRefFailsClosed() {
        let envelope = DialogueStateWindowEnvelope(
            schemaVersion: .v1,
            identity: DialogueGroupIdentity(sessionRef: "", generationRef: "gen-1", groupOrdinal: 1),
            bound: DialogueWindowBound(maxActiveGroups: 5)
        )
        XCTAssertThrowsError(try envelope.validate()) { error in
            guard case DialogueStateEnvelopeError.missingIdentity(let field) = error else {
                return XCTFail("expected .missingIdentity got \(error)")
            }
            XCTAssertEqual(field, "sessionRef")
        }
    }

    func testMissingGenerationRefFailsClosed() {
        let envelope = DialogueStateWindowEnvelope(
            schemaVersion: .v1,
            identity: DialogueGroupIdentity(sessionRef: "sess-A", generationRef: "", groupOrdinal: 1),
            bound: DialogueWindowBound(maxActiveGroups: 5)
        )
        XCTAssertThrowsError(try envelope.validate()) { error in
            guard case DialogueStateEnvelopeError.missingIdentity(let field) = error else {
                return XCTFail("expected .missingIdentity got \(error)")
            }
            XCTAssertEqual(field, "generationRef")
        }
    }

    // MARK: - Fail-closed: unsupported schema version

    func testUnsupportedSchemaVersionFailsClosed() throws {
        // 通过 decode 一个未知 raw 值来构造 `.unsupported`
        let json = Data(#""w7.dialogue-state/vNext""#.utf8)
        let version = try JSONDecoder().decode(DialogueStateSchemaVersion.self, from: json)
        XCTAssertFalse(version.isSupported)

        let envelope = DialogueStateWindowEnvelope(
            schemaVersion: version,
            identity: makeIdentity(),
            bound: DialogueWindowBound(maxActiveGroups: 5)
        )
        XCTAssertThrowsError(try envelope.validate()) { error in
            guard case DialogueStateEnvelopeError.unsupportedSchemaVersion(let raw) = error else {
                return XCTFail("expected .unsupportedSchemaVersion got \(error)")
            }
            XCTAssertEqual(raw, "w7.dialogue-state/vNext")
        }
    }

    // MARK: - Fail-closed: unknown disposition

    func testUnknownDispositionInActiveFailsClosed() throws {
        let json = Data(#""some_future_disposition""#.utf8)
        let disposition = try JSONDecoder().decode(DialogueGroupDisposition.self, from: json)
        XCTAssertFalse(disposition.isKnown)

        let group = DialogueGroupRecord(
            identity: makeIdentity(),
            completeness: DialogueGroupCompleteness(disposition: disposition, reason: .pairedComplete)
        )
        let envelope = DialogueStateWindowEnvelope(
            schemaVersion: .v1,
            identity: makeIdentity(),
            bound: DialogueWindowBound(maxActiveGroups: 5),
            activeGroups: [group]
        )
        XCTAssertThrowsError(try envelope.validate()) { error in
            guard case DialogueStateEnvelopeError.unknownDisposition(let raw) = error else {
                return XCTFail("expected .unknownDisposition got \(error)")
            }
            XCTAssertEqual(raw, "some_future_disposition")
        }
    }

    // MARK: - Fail-closed: terminal audit-only in active window / non-terminal in audit

    func testTerminalAuditOnlyGroupCannotSitInActiveWindow() {
        let group = DialogueGroupRecord(
            identity: makeIdentity(),
            completeness: DialogueGroupCompleteness(
                disposition: .terminalAuditOnly,
                reason: .terminalAuditOnly
            )
        )
        let envelope = DialogueStateWindowEnvelope(
            schemaVersion: .v1,
            identity: makeIdentity(),
            bound: DialogueWindowBound(maxActiveGroups: 5),
            activeGroups: [group]
        )
        XCTAssertThrowsError(try envelope.validate()) { error in
            guard case DialogueStateEnvelopeError.terminalAuditInActiveWindow = error else {
                return XCTFail("expected .terminalAuditInActiveWindow got \(error)")
            }
        }
    }

    func testNonTerminalGroupCannotSitInAuditWindow() {
        let envelope = DialogueStateWindowEnvelope(
            schemaVersion: .v1,
            identity: makeIdentity(),
            bound: DialogueWindowBound(maxActiveGroups: 5),
            auditGroups: [makePairedGroup(1)]
        )
        XCTAssertThrowsError(try envelope.validate()) { error in
            guard case DialogueStateEnvelopeError.nonTerminalGroupInAuditWindow = error else {
                return XCTFail("expected .nonTerminalGroupInAuditWindow got \(error)")
            }
        }
    }

    // MARK: - Retention & bounded eviction

    func testRetentionExceededFailsClosed() {
        let envelope = DialogueStateWindowEnvelope(
            schemaVersion: .v1,
            identity: makeIdentity(),
            bound: DialogueWindowBound(maxActiveGroups: 2),
            activeGroups: [
                makePairedGroup(1),
                makePairedGroup(2),
                makePairedGroup(3)
            ]
        )
        XCTAssertThrowsError(try envelope.validate()) { error in
            guard case DialogueStateEnvelopeError.retentionExceeded(let current, let bound) = error else {
                return XCTFail("expected .retentionExceeded got \(error)")
            }
            XCTAssertEqual(current, 3)
            XCTAssertEqual(bound, 2)
        }
    }

    func testEvictingOldestActiveDoesNotPromoteToAuditAndIsDeterministic() {
        let envelope = DialogueStateWindowEnvelope(
            schemaVersion: .v1,
            identity: makeIdentity(),
            bound: DialogueWindowBound(maxActiveGroups: 2),
            activeGroups: [
                makePairedGroup(1),
                makePairedGroup(2),
                makePairedGroup(3)
            ]
        )
        let evicted = envelope.evictingOldestActive()

        // deterministic: 掐掉最老（groupOrdinal 1）
        XCTAssertEqual(evicted.activeGroups.map(\.identity.groupOrdinal), [2, 3])
        // eviction 不进 auditGroups：不创建 cross-session context
        XCTAssertEqual(evicted.auditGroups.count, envelope.auditGroups.count)
        XCTAssertTrue(evicted.auditGroups.isEmpty)
    }
}
