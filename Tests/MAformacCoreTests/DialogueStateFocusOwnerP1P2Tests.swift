import XCTest
@testable import MAformacCore

final class DialogueStateFocusOwnerP1P2Tests: XCTestCase {
    private func groupRef(_ ordinal: UInt32) -> DialogueSourceGroupRef {
        DialogueSourceGroupRef(sessionRef: "sess-A", generationRef: "gen-1", groupOrdinal: ordinal)
    }

    private func identity(_ ordinal: UInt32) -> DialogueGroupIdentity {
        DialogueGroupIdentity(sessionRef: "sess-A", generationRef: "gen-1", groupOrdinal: ordinal)
    }

    private func pairedRecord(_ ordinal: UInt32) -> DialogueGroupRecord {
        DialogueGroupRecord(
            identity: identity(ordinal),
            completeness: DialogueGroupCompleteness(
                disposition: .paired,
                reason: .pairedComplete
            ),
            userText: "u\(ordinal)",
            assistantText: "a\(ordinal)"
        )
    }

    private func unpairedRecord(_ ordinal: UInt32, disposition: DialogueGroupDisposition) -> DialogueGroupRecord {
        DialogueGroupRecord(
            identity: identity(ordinal),
            completeness: DialogueGroupCompleteness(
                disposition: disposition,
                reason: .userOnlyPending
            ),
            userText: "u\(ordinal)"
        )
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
        // owner group 仍 active 且 paired → 有效
        XCTAssertTrue(window.isValid(givenActiveGroups: [pairedRecord(1)]))
        // owner group 已被 evict → 无效
        XCTAssertFalse(window.isValid(givenActiveGroups: [pairedRecord(2), pairedRecord(3)]))
        // 空集 → 无效
        XCTAssertFalse(window.isValid(givenActiveGroups: []))
    }

    // MARK: - R5 enforce: unpaired ordinal cannot be focus owner (P1 blocker)

    func testUnpairedOwnerCannotBeFocusOwner_userOnly() {
        let window = DialogueFocusOwnerWindow(
            ownerWindowRef: groupRef(1),
            focusValidityReason: .derivedFromReadback,
            activeUntil: .untilOwnerWindowEvicted,
            schemaVersion: .v1
        )
        // ordinal=1 匹配 owner，但 disposition=.unpairedUserOnly → 必须拒收（R5 enforce）。
        XCTAssertFalse(
            window.isValid(givenActiveGroups: [unpairedRecord(1, disposition: .unpairedUserOnly)]),
            "R5: unpaired group SHALL NOT renew focus (was declare-only in prior isValid)"
        )
    }

    func testUnpairedOwnerCannotBeFocusOwner_consecutiveUserSupersession() {
        let window = DialogueFocusOwnerWindow(
            ownerWindowRef: groupRef(1),
            focusValidityReason: .derivedFromReadback,
            activeUntil: .untilOwnerWindowEvicted,
            schemaVersion: .v1
        )
        XCTAssertFalse(
            window.isValid(givenActiveGroups: [unpairedRecord(1, disposition: .unpairedConsecutiveUserSupersession)])
        )
    }

    func testUnpairedOwnerCannotBeFocusOwner_assistantCancelled() {
        let window = DialogueFocusOwnerWindow(
            ownerWindowRef: groupRef(1),
            focusValidityReason: .derivedFromReadback,
            activeUntil: .untilOwnerWindowEvicted,
            schemaVersion: .v1
        )
        XCTAssertFalse(
            window.isValid(givenActiveGroups: [unpairedRecord(1, disposition: .unpairedAssistantCancelled)])
        )
    }

    func testUnpairedOwnerCannotBeFocusOwner_contextInvalid() {
        let window = DialogueFocusOwnerWindow(
            ownerWindowRef: groupRef(1),
            focusValidityReason: .derivedFromReadback,
            activeUntil: .untilOwnerWindowEvicted,
            schemaVersion: .v1
        )
        XCTAssertFalse(
            window.isValid(givenActiveGroups: [unpairedRecord(1, disposition: .contextInvalid)])
        )
    }

    func testUnknownDispositionOwnerFailsClosed() throws {
        let json = Data(#""future_disposition""#.utf8)
        let unknownDisposition = try JSONDecoder().decode(DialogueGroupDisposition.self, from: json)
        let record = DialogueGroupRecord(
            identity: identity(1),
            completeness: DialogueGroupCompleteness(disposition: unknownDisposition, reason: .contextInvalid),
            userText: "u1"
        )
        let window = DialogueFocusOwnerWindow(
            ownerWindowRef: groupRef(1),
            focusValidityReason: .derivedFromReadback,
            activeUntil: .untilOwnerWindowEvicted,
            schemaVersion: .v1
        )
        XCTAssertFalse(window.isValid(givenActiveGroups: [record]))
    }

    func testPairedOwnerAmongMixedGroupsIsValid() {
        let window = DialogueFocusOwnerWindow(
            ownerWindowRef: groupRef(2),
            focusValidityReason: .derivedFromReadback,
            activeUntil: .untilOwnerWindowEvicted,
            schemaVersion: .v1
        )
        // ordinal=2 是 paired，ordinal=1/3 是 unpaired → 只 owner 那条决定结果。
        let groups: [DialogueGroupRecord] = [
            unpairedRecord(1, disposition: .unpairedUserOnly),
            pairedRecord(2),
            unpairedRecord(3, disposition: .unpairedConsecutiveUserSupersession)
        ]
        XCTAssertTrue(window.isValid(givenActiveGroups: groups))
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
        XCTAssertFalse(window.isValid(givenActiveGroups: [pairedRecord(1)]))
    }

    // MARK: - Fail-closed: enabled=true injection reason

    func testEnabledFocusInjectionReasonMakesFocusInvalid() {
        let window = DialogueFocusOwnerWindow(
            ownerWindowRef: groupRef(1),
            focusValidityReason: .derivedFromExplicitFocusInjection(disabled: false),
            activeUntil: .untilOwnerWindowEvicted,
            schemaVersion: .v1
        )
        XCTAssertFalse(window.isValid(givenActiveGroups: [pairedRecord(1)]))
    }

    // MARK: - Fail-closed: revoked activation

    func testRevokedActivationBoundIsInvalid() {
        let window = DialogueFocusOwnerWindow(
            ownerWindowRef: groupRef(1),
            focusValidityReason: .derivedFromReadback,
            activeUntil: .revoked(reason: .unauthorisedInjection),
            schemaVersion: .v1
        )
        XCTAssertFalse(window.isValid(givenActiveGroups: [pairedRecord(1)]))
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
        XCTAssertFalse(window.isValid(givenActiveGroups: [pairedRecord(1)]))
    }
}
