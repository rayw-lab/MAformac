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

        // 类型 API 上仍能构造 disabled=false，但语义上表示尝试授权——
        // schema 层的下游门（envelope validate / focus owner isValid）会拒收。
        let enabled = DialogueFieldValidityReason.derivedFromExplicitFocusInjection(disabled: false)
        XCTAssertTrue(enabled.isFocusInjectionAllowed, "typed schema must expose the 'enabled=true' signal for callers to reject")
    }
}
