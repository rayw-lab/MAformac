import XCTest
@testable import MAformacCore

/// G5 knife4: UI dialogue source = payload readbacks (actual), never invented planned copy.
final class UIReadbackSourceTests: XCTestCase {
    func testDialoguePrefersActualReadbackSpokenText_overEmptyMatrixFallback() {
        let payload = RuntimePresentationPayload(
            traceID: "trace-div",
            turnID: "turn-div",
            eventID: "evt-div",
            isTerminal: true,
            outcome: DemoRuntimeOutcome(result: .acceptedToolCall, reason: "ok"),
            cards: [],
            readbacks: [
                DemoActionReadback(
                    key: "ac.temp_setpoint[主驾]",
                    actualValue: "24",
                    revision: 3,
                    spokenText: "主驾温度24度"
                )
            ],
            reconciliation: PresentationReconciliation(status: .verified, safeReason: "ok"),
            voiceState: .speak,
            orbState: .speak,
            mutationCount: 1
        )

        XCTAssertEqual(
            RuntimePresentationUIRender.dialogueText(from: payload),
            "主驾温度24度"
        )
        XCTAssertEqual(
            RuntimePresentationUIRender.resultKind(from: payload),
            .acceptedToolCall
        )
    }

    func testDivergencePlannedDesiredDoesNotOverrideActualSpoken() {
        // planned/desired may differ; UI must still surface actual readback spokenText.
        let plannedDesired = "26"
        let actual = "24"
        XCTAssertNotEqual(plannedDesired, actual)

        let payload = RuntimePresentationPayload(
            traceID: "trace-mismatch",
            turnID: "turn-mismatch",
            isTerminal: true,
            outcome: DemoRuntimeOutcome(result: .acceptedToolCall, reason: "ok"),
            cards: [],
            readbacks: [
                DemoActionReadback(
                    key: "ac.temp_setpoint[主驾]",
                    actualValue: actual,
                    revision: 5,
                    spokenText: "主驾温度\(actual)度"
                )
            ],
            reconciliation: PresentationReconciliation(
                status: .mismatch,
                readbackKey: "ac.temp_setpoint[主驾]",
                mismatchClass: .valueMismatch,
                safeReason: "value_mismatch"
            ),
            voiceState: .speak,
            orbState: .speak,
            mutationCount: 1
        )

        let dialogue = RuntimePresentationUIRender.dialogueText(from: payload)
        XCTAssertTrue(dialogue.contains(actual))
        XCTAssertFalse(dialogue.contains(plannedDesired))
        XCTAssertEqual(payload.readbacks.first?.actualValue, actual)
    }

    @MainActor
    func testCancelPayloadDialogueComesFromReadbacksNotEventIDHeuristics() async throws {
        let store = DemoVehicleStateStore()
        let route = try DemoSliceRoute(
            store: store,
            traceLogger: InMemoryTraceLogger(),
            speech: RecordingSpeechSynthesisEngine()
        )
        let result = try await route.route(text: "算了")
        let readOnly = try XCTUnwrap(result.readOnly)
        XCTAssertEqual(readOnly.payload.readbacks.count, 1)
        XCTAssertEqual(
            RuntimePresentationUIRender.dialogueText(from: readOnly.payload),
            readOnly.payload.readbacks.first?.spokenText
        )
        XCTAssertEqual(
            RuntimePresentationUIRender.dialogueText(from: readOnly.payload),
            "已取消"
        )
    }

    @MainActor
    func testCapabilityQueryDialogueFromPayloadReadbacks() async throws {
        let store = DemoVehicleStateStore()
        let route = try DemoSliceRoute(
            store: store,
            traceLogger: InMemoryTraceLogger(),
            speech: RecordingSpeechSynthesisEngine()
        )
        let result = try await route.route(text: "空调能调到26度吗")
        let readOnly = try XCTUnwrap(result.readOnly)
        XCTAssertEqual(readOnly.payload.outcome.result, .capabilityQuery)
        XCTAssertEqual(
            RuntimePresentationUIRender.dialogueText(from: readOnly.payload),
            "空调温度支持18到32度"
        )
        XCTAssertEqual(
            RuntimePresentationUIRender.resultKind(from: readOnly.payload),
            .capabilityQuery
        )
    }

    func testAdmissionRejectionPayloadOwnsCopy_notApp() {
        let payload = DemoSliceAdmissionRejectionPresentation.payload(
            for: .valueOutOfRange(actual: 17, allowed: 18 ... 32),
            cards: [],
            revision: 0
        )
        XCTAssertEqual(payload.outcome.result, .clarifyMissingSlot)
        XCTAssertEqual(
            RuntimePresentationUIRender.dialogueText(from: payload),
            "空调温度支持18到32度，请重新输入"
        )
    }

    func testContentViewDemoSliceApplyHasNoInventedCopy() throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let source = try String(
            contentsOf: root.appendingPathComponent("App/ContentView.swift"),
            encoding: .utf8
        )
        let start = try XCTUnwrap(source.range(of: "private func applyDemoSliceExecution"))
        let end = try XCTUnwrap(source.range(of: "private func writeRuntimeTurnReceipt"))
        let body = String(source[start.lowerBound..<end.lowerBound])

        let forbidden = [
            "空调温度支持18到32度",
            "请告诉我空调要打开",
            "命令已执行，如需撤销",
            "已查询",
            "dialogueText = \"已取消\"",
            "message = \"请输入车控指令\""
        ]
        for needle in forbidden {
            XCTAssertFalse(
                body.contains(needle),
                "G5 knife4: applyDemoSlice* must not invent copy; found \(needle)"
            )
        }
        XCTAssertTrue(body.contains("RuntimePresentationUIRender.dialogueText"))
        XCTAssertTrue(body.contains("RuntimePresentationUIRender.resultKind"))
        XCTAssertTrue(body.contains("DemoSliceAdmissionRejectionPresentation.payload"))
    }
}
