import XCTest
@testable import MAformacCore

final class DialogueStateCheckpointP1P2Tests: XCTestCase {
    private func makeCheckpoint(
        schemaVersion: DialogueStateSchemaVersion = .v1,
        session: String = "sess-A",
        generation: String = "gen-1",
        digest: String = "deadbeef",
        disposition: DialogueStateRestoreDisposition = .authoritative
    ) -> DialogueStateCheckpoint {
        DialogueStateCheckpoint(
            schemaVersion: schemaVersion,
            sessionOwnerRef: session,
            generationOwnerRef: generation,
            digest: digest,
            restoreDisposition: disposition,
            capturedAt: 1_700_000_000
        )
    }

    private let currentIdentity = DialogueStateCheckpointCurrentIdentity(
        sessionOwnerRef: "sess-A",
        generationOwnerRef: "gen-1"
    )

    // MARK: - Supported round-trip

    func testAuthoritativeCheckpointRoundTrips() throws {
        let checkpoint = makeCheckpoint()
        let encoder = DialogueStateSchemaCanonicalCoder.encoder()
        let decoder = DialogueStateSchemaCanonicalCoder.decoder()
        let data1 = try encoder.encode(checkpoint)
        let decoded = try decoder.decode(DialogueStateCheckpoint.self, from: data1)
        let data2 = try encoder.encode(decoded)
        XCTAssertEqual(checkpoint, decoded)
        XCTAssertEqual(data1, data2)
    }

    func testAuthoritativeCheckpointValidatesAgainstMatchingIdentity() {
        let checkpoint = makeCheckpoint()
        switch DialogueStateCheckpointValidator.validate(checkpoint, againstCurrentIdentity: currentIdentity) {
        case .success(let value):
            XCTAssertEqual(value, checkpoint)
        case .failure(let error):
            XCTFail("expected success, got \(error)")
        }
    }

    // MARK: - Fail-closed: unsupported schema version

    func testUnsupportedSchemaVersionFailsClosed() throws {
        let json = Data(#""w7.dialogue-state/vNext""#.utf8)
        let unsupported = try JSONDecoder().decode(DialogueStateSchemaVersion.self, from: json)
        let checkpoint = makeCheckpoint(schemaVersion: unsupported)

        switch DialogueStateCheckpointValidator.validate(checkpoint, againstCurrentIdentity: currentIdentity) {
        case .failure(.unsupportedSchemaVersion(let raw)):
            XCTAssertEqual(raw, "w7.dialogue-state/vNext")
        default:
            XCTFail("expected .unsupportedSchemaVersion")
        }
    }

    // MARK: - R4 scenario: display text does not restore context

    func testDisplayTextOnlyDispositionFailsClosed() {
        let checkpoint = makeCheckpoint(disposition: .displayTextOnlyNoContext)
        switch DialogueStateCheckpointValidator.validate(checkpoint, againstCurrentIdentity: currentIdentity) {
        case .failure(.displayTextOnlyNoContext):
            break
        default:
            XCTFail("display-text-only disposition must fail closed")
        }
    }

    // MARK: - R4 scenario: legacy ambiguous snapshot is explicit

    func testLegacyMigrationAmbiguousFailsClosed() {
        let checkpoint = makeCheckpoint(disposition: .legacyMigrationAmbiguous)
        switch DialogueStateCheckpointValidator.validate(checkpoint, againstCurrentIdentity: currentIdentity) {
        case .failure(.legacyMigrationAmbiguous):
            break
        default:
            XCTFail("legacy ambiguous disposition must fail closed")
        }
    }

    // MARK: - R4 scenario: identity mismatch fails closed

    func testDeclaredIdentityMismatchFailsClosed() {
        let checkpoint = makeCheckpoint(
            disposition: .identityMismatch(
                currentIdentityRef: "sess-A",
                checkpointIdentityRef: "sess-Z"
            )
        )
        switch DialogueStateCheckpointValidator.validate(checkpoint, againstCurrentIdentity: currentIdentity) {
        case .failure(.identityMismatch(let current, let checkpointRef)):
            XCTAssertEqual(current, "sess-A")
            XCTAssertEqual(checkpointRef, "sess-Z")
        default:
            XCTFail("identity mismatch disposition must fail closed")
        }
    }

    func testEffectiveSessionMismatchFailsClosedEvenIfDispositionClaimsAuthoritative() {
        let checkpoint = makeCheckpoint(session: "sess-DIFFERENT")
        switch DialogueStateCheckpointValidator.validate(checkpoint, againstCurrentIdentity: currentIdentity) {
        case .failure(.identityMismatch(let current, let checkpointRef)):
            XCTAssertEqual(current, "sess-A")
            XCTAssertEqual(checkpointRef, "sess-DIFFERENT")
        default:
            XCTFail("effective session mismatch must override the claim of authoritative")
        }
    }

    func testEmptyDigestFailsClosed() {
        let checkpoint = makeCheckpoint(digest: "")
        switch DialogueStateCheckpointValidator.validate(checkpoint, againstCurrentIdentity: currentIdentity) {
        case .failure(.emptyDigest):
            break
        default:
            XCTFail("empty digest must fail closed")
        }
    }

    func testMissingSessionOwnerRefFailsClosed() {
        let checkpoint = makeCheckpoint(session: "")
        switch DialogueStateCheckpointValidator.validate(checkpoint, againstCurrentIdentity: currentIdentity) {
        case .failure(.missingIdentity(let field)):
            XCTAssertEqual(field, "sessionOwnerRef")
        default:
            XCTFail("missing sessionOwnerRef must fail closed")
        }
    }

    // MARK: - Unknown restore disposition fails closed

    func testUnknownRestoreDispositionFailsClosed() throws {
        let json = Data(#"{"kind":"future_disposition"}"#.utf8)
        let unknown = try JSONDecoder().decode(DialogueStateRestoreDisposition.self, from: json)
        let checkpoint = makeCheckpoint(disposition: unknown)
        switch DialogueStateCheckpointValidator.validate(checkpoint, againstCurrentIdentity: currentIdentity) {
        case .failure(.unknownRestoreDisposition(let raw)):
            XCTAssertEqual(raw, "future_disposition")
        default:
            XCTFail("unknown disposition must fail closed")
        }
    }
}
