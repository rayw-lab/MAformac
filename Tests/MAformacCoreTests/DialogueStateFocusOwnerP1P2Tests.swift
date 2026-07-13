import XCTest
@testable import MAformacCore

final class DialogueStateFocusOwnerP1P2Tests: XCTestCase {
    private func groupRef(_ ordinal: UInt32) -> DialogueSourceGroupRef {
        DialogueSourceGroupRef(sessionRef: "sess-A", generationRef: "gen-1", groupOrdinal: ordinal)
    }

    // MARK: - Round-trip

    func testFocusOwnerWindowRoundTrips() throws {
        let window = DialogueFocusOwnerWindow(
            ownerWindowRef: groupRef(1),
            focusValidityReason: .derivedFromReadback,
            activeUntil: .untilOwnerWindowEvicted,
            schemaVersion: .v1
        )
        let encoder = DialogueStateSchemaCanonicalCoder.encoder()
        let decoder = DialogueStateSchemaCanonicalCoder.decoder()
        let data1 = try encoder.encode(window)
        let decoded = try decoder.decode(DialogueFocusOwnerWindow.self, from: data1)
        let data2 = try encoder.encode(decoded)
        XCTAssertEqual(window, decoded)
        XCTAssertEqual(data1, data2)
    }

    // MARK: - R5 scenario: owner-window eviction invalidates focus

    func testOwnerWindowEvictionInvalidatesFocus() {
        let window = DialogueFocusOwnerWindow(
            ownerWindowRef: groupRef(1),
            focusValidityReason: .derivedFromReadback,
            activeUntil: .untilOwnerWindowEvicted,
            schemaVersion: .v1
        )
        // owner group 仍 active → 有效
        XCTAssertTrue(window.isValid(givenActiveWindows: [groupRef(1)]))
        // owner group 已被 evict → 无效
        XCTAssertFalse(window.isValid(givenActiveWindows: [groupRef(2), groupRef(3)]))
        // 空集 → 无效
        XCTAssertFalse(window.isValid(givenActiveWindows: []))
    }

    // MARK: - R5 scenario: force visual state cannot create focus

    func testForceVisualStateProbeIsUninhabited() {
        // Uninhabited 类型：MemoryLayout.size == 0 且无 case，
        // 静态证据「force visual state 不能构造 focus source 值」。
        XCTAssertEqual(MemoryLayout<DialogueForceVisualStateProbe>.size, 0)
    }

    // MARK: - R5 scenario: unauthorised focus injection is rejected

    func testUnauthorisedFocusInjectionEncodesAsNotYetRatified() throws {
        let authority = DialogueFocusInjectionAuthority.notYetRatified
        let encoder = DialogueStateSchemaCanonicalCoder.encoder()
        let data = try encoder.encode(authority)
        XCTAssertEqual(String(data: data, encoding: .utf8), "\"not_yet_ratified\"")
    }

    func testFocusInjectionGuardAlwaysFails() {
        let result = DialogueFocusInjectionGuard.evaluate(authority: .notYetRatified)
        switch result {
        case .failure(.unauthorisedInjectionAttempted(let raw)):
            XCTAssertEqual(raw, "not_yet_ratified")
        default:
            XCTFail("guard must always fail-closed")
        }
    }

    func testDecodingUnknownAuthorityRawFails() {
        let json = Data(#""ratified_by_someone""#.utf8)
        XCTAssertThrowsError(
            try JSONDecoder().decode(DialogueFocusInjectionAuthority.self, from: json)
        ) { error in
            guard case DialogueFocusOwnerError.unauthorisedInjectionAttempted(let raw) = error else {
                return XCTFail("expected .unauthorisedInjectionAttempted got \(error)")
            }
            XCTAssertEqual(raw, "ratified_by_someone")
        }
    }

    // MARK: - Fail-closed: unsupported schema version

    func testUnsupportedSchemaVersionMakesFocusInvalid() throws {
        let json = Data(#""w7.dialogue-state/vNext""#.utf8)
        let unsupported = try JSONDecoder().decode(DialogueStateSchemaVersion.self, from: json)
        let window = DialogueFocusOwnerWindow(
            ownerWindowRef: groupRef(1),
            focusValidityReason: .derivedFromReadback,
            activeUntil: .untilOwnerWindowEvicted,
            schemaVersion: unsupported
        )
        XCTAssertFalse(window.isValid(givenActiveWindows: [groupRef(1)]))
    }

    // MARK: - Fail-closed: enabled=true injection reason

    func testEnabledFocusInjectionReasonMakesFocusInvalid() {
        let window = DialogueFocusOwnerWindow(
            ownerWindowRef: groupRef(1),
            focusValidityReason: .derivedFromExplicitFocusInjection(disabled: false),
            activeUntil: .untilOwnerWindowEvicted,
            schemaVersion: .v1
        )
        XCTAssertFalse(window.isValid(givenActiveWindows: [groupRef(1)]))
    }

    // MARK: - Fail-closed: revoked activation

    func testRevokedActivationBoundIsInvalid() {
        let window = DialogueFocusOwnerWindow(
            ownerWindowRef: groupRef(1),
            focusValidityReason: .derivedFromReadback,
            activeUntil: .revoked(reason: .unauthorisedInjection),
            schemaVersion: .v1
        )
        XCTAssertFalse(window.isValid(givenActiveWindows: [groupRef(1)]))
    }

    // MARK: - Unknown activation bound

    func testUnknownActivationBoundIsInvalid() throws {
        let json = Data(#"{"kind":"future_bound"}"#.utf8)
        let bound = try JSONDecoder().decode(DialogueFocusActivationBound.self, from: json)
        XCTAssertFalse(bound.isKnown)

        let window = DialogueFocusOwnerWindow(
            ownerWindowRef: groupRef(1),
            focusValidityReason: .derivedFromReadback,
            activeUntil: bound,
            schemaVersion: .v1
        )
        XCTAssertFalse(window.isValid(givenActiveWindows: [groupRef(1)]))
    }
}
