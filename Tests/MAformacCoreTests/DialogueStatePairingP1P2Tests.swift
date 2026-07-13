import XCTest
@testable import MAformacCore

final class DialogueStatePairingP1P2Tests: XCTestCase {
    private func identity(_ ordinal: UInt32) -> DialogueGroupIdentity {
        DialogueGroupIdentity(sessionRef: "sess-A", generationRef: "gen-1", groupOrdinal: ordinal)
    }

    private func userOnlyRecord(_ ordinal: UInt32) -> DialogueGroupRecord {
        DialogueGroupRecord(
            identity: identity(ordinal),
            completeness: DialogueGroupCompleteness(
                disposition: .unpairedUserOnly,
                reason: .userOnlyPending
            ),
            userText: "u\(ordinal)"
        )
    }

    // MARK: - Round-trip

    func testValidityRecordRoundTrips() throws {
        let record = DialogueFieldValidityRecord(
            reason: .derivedFromReadback,
            sourceGroupRef: DialogueSourceGroupRef(identity: identity(1)),
            schemaVersion: .v1
        )
        let encoder = DialogueStateSchemaCanonicalCoder.encoder()
        let decoder = DialogueStateSchemaCanonicalCoder.decoder()
        let data1 = try encoder.encode(record)
        let decoded = try decoder.decode(DialogueFieldValidityRecord.self, from: data1)
        let data2 = try encoder.encode(decoded)
        XCTAssertEqual(record, decoded)
        XCTAssertEqual(data1, data2)
    }

    // MARK: - R3 scenario: consecutive user messages are not a fake pair

    func testConsecutiveUserMessagesArePromotedToSupersession() {
        let raw = [userOnlyRecord(1), userOnlyRecord(2)]
        let promoted = DialogueStatePairingAnalyzer.superseding(raw)

        XCTAssertEqual(promoted.count, 2)
        XCTAssertEqual(promoted[0].completeness.disposition, .unpairedConsecutiveUserSupersession)
        XCTAssertEqual(promoted[0].completeness.reason, .consecutiveUserSupersession)
        XCTAssertEqual(promoted[1].completeness.disposition, .unpairedUserOnly)
        XCTAssertEqual(promoted[1].completeness.reason, .userOnlyPending)
    }

    func testArrayLengthAloneCannotInferPair() {
        // 两条 record 长度 == 2，但两个都是 userOnlyPending，array length 不能推断 paired。
        // supersede 之后必须仍反映真实 disposition，无 "paired" 结果。
        let raw = [userOnlyRecord(1), userOnlyRecord(2)]
        let promoted = DialogueStatePairingAnalyzer.superseding(raw)
        for record in promoted {
            XCTAssertNotEqual(record.completeness.disposition, .paired)
        }
    }

    // MARK: - R3 scenario: focus & readback validity independent

    func testFocusAndReadbackValidityDoNotCrossInfer() {
        let focus = DialogueFieldValidityRecord(
            reason: .derivedFromReadback,
            sourceGroupRef: DialogueSourceGroupRef(identity: identity(1)),
            schemaVersion: .v1
        )
        let readback = DialogueFieldValidityRecord(
            reason: .invalidated(dueTo: .terminalClear),
            sourceGroupRef: DialogueSourceGroupRef(identity: identity(2)),
            schemaVersion: .v1
        )
        // 两个 record 完全独立，reason 不同、sourceGroupRef 不同、无字段互继承。
        XCTAssertNotEqual(focus.reason, readback.reason)
        XCTAssertNotEqual(focus.sourceGroupRef, readback.sourceGroupRef)
    }

    // MARK: - Unknown validity reason fail-closed

    func testUnknownValidityReasonMarksNotKnown() throws {
        let json = Data(#"{"kind":"future_kind"}"#.utf8)
        let reason = try JSONDecoder().decode(DialogueFieldValidityReason.self, from: json)
        XCTAssertFalse(reason.isKnown)
        XCTAssertFalse(reason.isFocusInjectionAllowed)
    }

    // MARK: - Focus injection disabled=true is the only accepted case

    func testFocusInjectionMustRemainDisabled() {
        let disabled = DialogueFieldValidityReason.derivedFromExplicitFocusInjection(disabled: true)
        XCTAssertFalse(disabled.isFocusInjectionAllowed)

        // 类型 API 上仍能构造 disabled=false（Swift 编译层不可完全禁止）；
        // 但 decode 层 + envelope validate + focus owner isValid 三处 fail-closed。
        let enabled = DialogueFieldValidityReason.derivedFromExplicitFocusInjection(disabled: false)
        XCTAssertTrue(enabled.isFocusInjectionAllowed, "typed schema must expose the 'enabled=true' signal for downstream fail-closed")
    }

    // MARK: - P2#2 fix: decode of disabled=false fails closed

    func testDecodingEnabledFocusInjectionFailsClosed() {
        let json = Data(#"{"kind":"derived_from_explicit_focus_injection","disabled":false}"#.utf8)
        XCTAssertThrowsError(
            try JSONDecoder().decode(DialogueFieldValidityReason.self, from: json)
        ) { error in
            guard case DecodingError.dataCorrupted(let ctx) = error else {
                return XCTFail("expected DecodingError.dataCorrupted got \(error)")
            }
            XCTAssertTrue(ctx.debugDescription.contains("disabled=true"))
        }
    }

    func testDecodingDisabledFocusInjectionSucceedsAndStaysDisabled() throws {
        let json = Data(#"{"kind":"derived_from_explicit_focus_injection","disabled":true}"#.utf8)
        let reason = try JSONDecoder().decode(DialogueFieldValidityReason.self, from: json)
        XCTAssertFalse(reason.isFocusInjectionAllowed)
    }

    func testDecodingFocusInjectionAbsentDisabledDefaultsToDisabledTrue() throws {
        // 缺 disabled 字段 → 默认 disabled=true（不冒充授权）
        let json = Data(#"{"kind":"derived_from_explicit_focus_injection"}"#.utf8)
        let reason = try JSONDecoder().decode(DialogueFieldValidityReason.self, from: json)
        XCTAssertFalse(reason.isFocusInjectionAllowed)
    }
}
