import Foundation
import XCTest
@testable import MAformacCore

final class RuntimeFiniteReasonAuthorityTests: XCTestCase {
    func testDDomainFailuresUseLockedTypedMappings() {
        let cases: [(DDomainToolPlanFailure, RuntimeFiniteReason, DDomainDecodeFailureKind)] = [
            (.parseFailed, .unsupportedToolPlan, .parseFailed),
            (.nameRejected("secret_raw_tool_name"), .nameRejected, .nameRejected),
            (.irUnclassified("secret_raw_tool_name"), .unsupportedToolPlan, .irUnclassified),
            (.bridgeFailed("secret_bridge_detail"), .unsupportedToolPlan, .bridgeFailed),
        ]

        for (failure, finiteReason, decodeFailureKind) in cases {
            XCTAssertEqual(failure.finiteReason, finiteReason)
            XCTAssertEqual(failure.decodeFailureKind, decodeFailureKind)
        }
    }

    func testRuntimeFiniteReasonRejectsOutsideT0AtDecodeBoundary() throws {
        XCTAssertEqual(RuntimeFiniteReason.allCases.count, 21)
        XCTAssertThrowsError(
            try JSONDecoder().decode(
                RuntimeFiniteReason.self,
                from: Data(#""w1_non_t0_reason""#.utf8)
            )
        )
    }

    func testTraceEncodesFiniteReasonAndDecodeFailureKindAsSeparateTypedFields() throws {
        let attributes = TraceAttributes(
            finiteReason: .unsupportedToolPlan,
            decodeFailureKind: .parseFailed
        )
        let data = try JSONEncoder().encode(attributes)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

        XCTAssertEqual(object["finiteReason"] as? String, "unsupported_tool_plan")
        XCTAssertEqual(object["decodeFailureKind"] as? String, "parse_failed")

        let traceID = "trace-runtime-finite-reason-authority"
        let envelope = try XCTUnwrap(
            TraceEnvelope(
                traceID: traceID,
                entries: [
                    TraceEntry(
                        stage: .guard,
                        traceID: traceID,
                        message: "unsupported_tool_plan",
                        attributes: attributes,
                        timestamp: Date(timeIntervalSince1970: 1_800_002_000)
                    )
                ]
            )
        )
        let safeAttributes = try XCTUnwrap(envelope.presentationSafe().entries.first?.attributes)
        XCTAssertNil(safeAttributes.finiteReason)
        XCTAssertNil(safeAttributes.decodeFailureKind)
        XCTAssertEqual(safeAttributes.guardReason, RuntimePresentationSafeReasonKind.notAvailableInDemo.rawValue)
    }

    func testFallbackResolutionMatchesHardcodedTenReasonScriptTable() {
        // Every cell is a literal oracle. Do not derive expectations from generated authority/catalog data.
        let cases: [ExpectedFallbackCell] = [
            // ac
            .init(userText: "空调", finiteReason: .safetyOrPolicyRefusal, family: .ac, result: .refusalSafetyOrPolicy, safeReason: .safetyPolicy, dialogText: "当前状态下不能执行这项操作，车辆状态保持不变。", ttsText: "当前状态下不能执行这项操作，车辆状态保持不变。", badgeLabel: "安全限制"),
            .init(userText: "空调", finiteReason: .clarifyMissingSlot, family: .ac, result: .clarifyMissingSlot, safeReason: .clarificationRequired, dialogText: "请先确认温区或目标温度，我先保持空调状态不变。", ttsText: "请先确认温区或目标温度，我先保持空调状态不变。", badgeLabel: "需确认"),
            .init(userText: "空调", finiteReason: .unmountedToolName, family: .ac, result: .refusalNoAvailableTool, safeReason: .capabilityNotMounted, dialogText: "这项空调控制暂未接入演示版，我先不改车内状态。", ttsText: "这项空调控制暂未接入演示版，我先不改车内状态。", badgeLabel: "暂未接入"),
            .init(userText: "空调", finiteReason: .nameRejected, family: .ac, result: .refusalNoAvailableTool, safeReason: .capabilityNotMounted, dialogText: "这项空调控制暂未接入演示版，我先不改车内状态。", ttsText: "这项空调控制暂未接入演示版，我先不改车内状态。", badgeLabel: "暂未接入"),
            .init(userText: "空调", finiteReason: .fastPathNoMatch, family: .ac, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这个空调说法还没稳稳接住，您可以说空调调到26度。", ttsText: "这个空调说法还没稳稳接住，您可以说空调调到26度。", badgeLabel: "换个说法"),
            .init(userText: "空调", finiteReason: .unsupportedToolPlan, family: .ac, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这个空调说法还没稳稳接住，您可以说空调调到26度。", ttsText: "这个空调说法还没稳稳接住，您可以说空调调到26度。", badgeLabel: "换个说法"),
            .init(userText: "空调", finiteReason: .noRepresentativeTool, family: .ac, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这类空调能力不在本轮演示范围，我先保持原样。", ttsText: "这类空调能力不在本轮演示范围，我先保持原样。", badgeLabel: "不在范围"),
            .init(userText: "空调", finiteReason: .runtimeExecutionError, family: .ac, result: .runtimeError, safeReason: .runtimeUnavailable, dialogText: "当前运行状态不可用，请稍后重试。", ttsText: "当前运行状态不可用，请稍后重试。", badgeLabel: "暂不可用"),
            .init(userText: "空调", finiteReason: .staleStateRevision, family: .ac, result: .runtimeError, safeReason: .runtimeUnavailable, dialogText: "当前运行状态不可用，请稍后重试。", ttsText: "当前运行状态不可用，请稍后重试。", badgeLabel: "暂不可用"),
            .init(userText: "空调", finiteReason: .alreadyStateNoop, family: .ac, result: .alreadyStateNoop, safeReason: .alreadyDone, dialogText: "当前已经是目标状态，无需重复操作。", ttsText: "当前已经是目标状态，无需重复操作。", badgeLabel: "已完成"),

            // seat
            .init(userText: "座椅", finiteReason: .safetyOrPolicyRefusal, family: .seat, result: .refusalSafetyOrPolicy, safeReason: .safetyPolicy, dialogText: "当前状态下不能执行这项操作，车辆状态保持不变。", ttsText: "当前状态下不能执行这项操作，车辆状态保持不变。", badgeLabel: "安全限制"),
            .init(userText: "座椅", finiteReason: .clarifyMissingSlot, family: .seat, result: .clarifyMissingSlot, safeReason: .clarificationRequired, dialogText: "座椅动作需要确认位置，我先保持座椅不动。", ttsText: "座椅动作需要确认位置，我先保持座椅不动。", badgeLabel: "需确认"),
            .init(userText: "座椅", finiteReason: .unmountedToolName, family: .seat, result: .refusalNoAvailableTool, safeReason: .capabilityNotMounted, dialogText: "座椅控制暂未接入演示版，我先不移动座椅。", ttsText: "座椅控制暂未接入演示版，我先不移动座椅。", badgeLabel: "暂未接入"),
            .init(userText: "座椅", finiteReason: .nameRejected, family: .seat, result: .refusalNoAvailableTool, safeReason: .capabilityNotMounted, dialogText: "座椅控制暂未接入演示版，我先不移动座椅。", ttsText: "座椅控制暂未接入演示版，我先不移动座椅。", badgeLabel: "暂未接入"),
            .init(userText: "座椅", finiteReason: .fastPathNoMatch, family: .seat, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这个座椅说法还没稳稳接住，您可以说主驾座椅加热打开。", ttsText: "这个座椅说法还没稳稳接住，您可以说主驾座椅加热打开。", badgeLabel: "换个说法"),
            .init(userText: "座椅", finiteReason: .unsupportedToolPlan, family: .seat, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这个座椅说法还没稳稳接住，您可以说主驾座椅加热打开。", ttsText: "这个座椅说法还没稳稳接住，您可以说主驾座椅加热打开。", badgeLabel: "换个说法"),
            .init(userText: "座椅", finiteReason: .noRepresentativeTool, family: .seat, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这类座椅能力不在本轮演示范围，我先保持原样。", ttsText: "这类座椅能力不在本轮演示范围，我先保持原样。", badgeLabel: "不在范围"),
            .init(userText: "座椅", finiteReason: .runtimeExecutionError, family: .seat, result: .runtimeError, safeReason: .runtimeUnavailable, dialogText: "当前运行状态不可用，请稍后重试。", ttsText: "当前运行状态不可用，请稍后重试。", badgeLabel: "暂不可用"),
            .init(userText: "座椅", finiteReason: .staleStateRevision, family: .seat, result: .runtimeError, safeReason: .runtimeUnavailable, dialogText: "当前运行状态不可用，请稍后重试。", ttsText: "当前运行状态不可用，请稍后重试。", badgeLabel: "暂不可用"),
            .init(userText: "座椅", finiteReason: .alreadyStateNoop, family: .seat, result: .alreadyStateNoop, safeReason: .alreadyDone, dialogText: "当前已经是目标状态，无需重复操作。", ttsText: "当前已经是目标状态，无需重复操作。", badgeLabel: "已完成"),

            // window
            .init(userText: "车窗", finiteReason: .safetyOrPolicyRefusal, family: .window, result: .refusalSafetyOrPolicy, safeReason: .safetyPolicy, dialogText: "当前状态下不能执行这项操作，车辆状态保持不变。", ttsText: "当前状态下不能执行这项操作，车辆状态保持不变。", badgeLabel: "安全限制"),
            .init(userText: "车窗", finiteReason: .clarifyMissingSlot, family: .window, result: .clarifyMissingSlot, safeReason: .clarificationRequired, dialogText: "车窗动作需要确认位置和开度，我先保持车窗不变。", ttsText: "车窗动作需要确认位置和开度，我先保持车窗不变。", badgeLabel: "需确认"),
            .init(userText: "车窗", finiteReason: .unmountedToolName, family: .window, result: .refusalNoAvailableTool, safeReason: .capabilityNotMounted, dialogText: "车窗控制暂未接入演示版，我先不动车窗。", ttsText: "车窗控制暂未接入演示版，我先不动车窗。", badgeLabel: "暂未接入"),
            .init(userText: "车窗", finiteReason: .nameRejected, family: .window, result: .refusalNoAvailableTool, safeReason: .capabilityNotMounted, dialogText: "车窗控制暂未接入演示版，我先不动车窗。", ttsText: "车窗控制暂未接入演示版，我先不动车窗。", badgeLabel: "暂未接入"),
            .init(userText: "车窗", finiteReason: .fastPathNoMatch, family: .window, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这个车窗说法还没稳稳接住，您可以说主驾车窗打开一半。", ttsText: "这个车窗说法还没稳稳接住，您可以说主驾车窗打开一半。", badgeLabel: "换个说法"),
            .init(userText: "车窗", finiteReason: .unsupportedToolPlan, family: .window, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这个车窗说法还没稳稳接住，您可以说主驾车窗打开一半。", ttsText: "这个车窗说法还没稳稳接住，您可以说主驾车窗打开一半。", badgeLabel: "换个说法"),
            .init(userText: "车窗", finiteReason: .noRepresentativeTool, family: .window, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这类车窗能力不在本轮演示范围，我先保持原样。", ttsText: "这类车窗能力不在本轮演示范围，我先保持原样。", badgeLabel: "不在范围"),
            .init(userText: "车窗", finiteReason: .runtimeExecutionError, family: .window, result: .runtimeError, safeReason: .runtimeUnavailable, dialogText: "当前运行状态不可用，请稍后重试。", ttsText: "当前运行状态不可用，请稍后重试。", badgeLabel: "暂不可用"),
            .init(userText: "车窗", finiteReason: .staleStateRevision, family: .window, result: .runtimeError, safeReason: .runtimeUnavailable, dialogText: "当前运行状态不可用，请稍后重试。", ttsText: "当前运行状态不可用，请稍后重试。", badgeLabel: "暂不可用"),
            .init(userText: "车窗", finiteReason: .alreadyStateNoop, family: .window, result: .alreadyStateNoop, safeReason: .alreadyDone, dialogText: "当前已经是目标状态，无需重复操作。", ttsText: "当前已经是目标状态，无需重复操作。", badgeLabel: "已完成"),

            // door
            .init(userText: "车门", finiteReason: .safetyOrPolicyRefusal, family: .door, result: .refusalSafetyOrPolicy, safeReason: .safetyPolicy, dialogText: "行驶中为了安全不能开门；停稳后请再说一次，我先保持车门不变。", ttsText: "行驶中为了安全不能开门；停稳后请再说一次，我先保持车门不变。", badgeLabel: "安全拦截"),
            .init(userText: "车门", finiteReason: .clarifyMissingSlot, family: nil, result: .clarifyMissingSlot, safeReason: .clarificationRequired, dialogText: "需要确认具体能力后我再执行，当前状态保持不变。", ttsText: "需要确认具体能力后我再执行，当前状态保持不变。", badgeLabel: "需确认"),
            .init(userText: "车门", finiteReason: .unmountedToolName, family: .door, result: .refusalNoAvailableTool, safeReason: .capabilityNotMounted, dialogText: "车门控制暂未接入演示版，我先不动车门。", ttsText: "车门控制暂未接入演示版，我先不动车门。", badgeLabel: "暂未接入"),
            .init(userText: "车门", finiteReason: .nameRejected, family: .door, result: .refusalNoAvailableTool, safeReason: .capabilityNotMounted, dialogText: "车门控制暂未接入演示版，我先不动车门。", ttsText: "车门控制暂未接入演示版，我先不动车门。", badgeLabel: "暂未接入"),
            .init(userText: "车门", finiteReason: .fastPathNoMatch, family: .door, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这个车门说法还没稳稳接住，我先保持车门状态不变。", ttsText: "这个车门说法还没稳稳接住，我先保持车门状态不变。", badgeLabel: "换个说法"),
            .init(userText: "车门", finiteReason: .unsupportedToolPlan, family: .door, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这个车门说法还没稳稳接住，我先保持车门状态不变。", ttsText: "这个车门说法还没稳稳接住，我先保持车门状态不变。", badgeLabel: "换个说法"),
            .init(userText: "车门", finiteReason: .noRepresentativeTool, family: .door, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这类车门能力不在本轮演示范围，我先保持原样。", ttsText: "这类车门能力不在本轮演示范围，我先保持原样。", badgeLabel: "不在范围"),
            .init(userText: "车门", finiteReason: .runtimeExecutionError, family: .door, result: .runtimeError, safeReason: .runtimeUnavailable, dialogText: "当前运行状态不可用，请稍后重试。", ttsText: "当前运行状态不可用，请稍后重试。", badgeLabel: "暂不可用"),
            .init(userText: "车门", finiteReason: .staleStateRevision, family: .door, result: .runtimeError, safeReason: .runtimeUnavailable, dialogText: "当前运行状态不可用，请稍后重试。", ttsText: "当前运行状态不可用，请稍后重试。", badgeLabel: "暂不可用"),
            .init(userText: "车门", finiteReason: .alreadyStateNoop, family: .door, result: .alreadyStateNoop, safeReason: .alreadyDone, dialogText: "当前已经是目标状态，无需重复操作。", ttsText: "当前已经是目标状态，无需重复操作。", badgeLabel: "已完成"),

            // ambient
            .init(userText: "氛围灯", finiteReason: .safetyOrPolicyRefusal, family: .ambient, result: .refusalSafetyOrPolicy, safeReason: .safetyPolicy, dialogText: "当前状态下不能执行这项操作，车辆状态保持不变。", ttsText: "当前状态下不能执行这项操作，车辆状态保持不变。", badgeLabel: "安全限制"),
            .init(userText: "氛围灯", finiteReason: .clarifyMissingSlot, family: .ambient, result: .clarifyMissingSlot, safeReason: .clarificationRequired, dialogText: "氛围灯效果需要确认颜色或亮度，我先保持灯光不变。", ttsText: "氛围灯效果需要确认颜色或亮度，我先保持灯光不变。", badgeLabel: "需确认"),
            .init(userText: "氛围灯", finiteReason: .unmountedToolName, family: .ambient, result: .refusalNoAvailableTool, safeReason: .capabilityNotMounted, dialogText: "氛围灯控制暂未接入演示版，我先不改灯光。", ttsText: "氛围灯控制暂未接入演示版，我先不改灯光。", badgeLabel: "暂未接入"),
            .init(userText: "氛围灯", finiteReason: .nameRejected, family: .ambient, result: .refusalNoAvailableTool, safeReason: .capabilityNotMounted, dialogText: "氛围灯控制暂未接入演示版，我先不改灯光。", ttsText: "氛围灯控制暂未接入演示版，我先不改灯光。", badgeLabel: "暂未接入"),
            .init(userText: "氛围灯", finiteReason: .fastPathNoMatch, family: .ambient, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这个氛围灯说法还没稳稳接住，您可以说氛围灯调亮一点。", ttsText: "这个氛围灯说法还没稳稳接住，您可以说氛围灯调亮一点。", badgeLabel: "换个说法"),
            .init(userText: "氛围灯", finiteReason: .unsupportedToolPlan, family: .ambient, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这个氛围灯说法还没稳稳接住，您可以说氛围灯调亮一点。", ttsText: "这个氛围灯说法还没稳稳接住，您可以说氛围灯调亮一点。", badgeLabel: "换个说法"),
            .init(userText: "氛围灯", finiteReason: .noRepresentativeTool, family: .ambient, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这类氛围灯能力不在本轮演示范围，我先保持原样。", ttsText: "这类氛围灯能力不在本轮演示范围，我先保持原样。", badgeLabel: "不在范围"),
            .init(userText: "氛围灯", finiteReason: .runtimeExecutionError, family: .ambient, result: .runtimeError, safeReason: .runtimeUnavailable, dialogText: "当前运行状态不可用，请稍后重试。", ttsText: "当前运行状态不可用，请稍后重试。", badgeLabel: "暂不可用"),
            .init(userText: "氛围灯", finiteReason: .staleStateRevision, family: .ambient, result: .runtimeError, safeReason: .runtimeUnavailable, dialogText: "当前运行状态不可用，请稍后重试。", ttsText: "当前运行状态不可用，请稍后重试。", badgeLabel: "暂不可用"),
            .init(userText: "氛围灯", finiteReason: .alreadyStateNoop, family: .ambient, result: .alreadyStateNoop, safeReason: .alreadyDone, dialogText: "当前已经是目标状态，无需重复操作。", ttsText: "当前已经是目标状态，无需重复操作。", badgeLabel: "已完成"),

            // screen
            .init(userText: "中控屏", finiteReason: .safetyOrPolicyRefusal, family: .screen, result: .refusalSafetyOrPolicy, safeReason: .safetyPolicy, dialogText: "当前状态下不能执行这项操作，车辆状态保持不变。", ttsText: "当前状态下不能执行这项操作，车辆状态保持不变。", badgeLabel: "安全限制"),
            .init(userText: "中控屏", finiteReason: .clarifyMissingSlot, family: .screen, result: .clarifyMissingSlot, safeReason: .clarificationRequired, dialogText: "屏幕设置需要确认目标屏幕，我先保持显示不变。", ttsText: "屏幕设置需要确认目标屏幕，我先保持显示不变。", badgeLabel: "需确认"),
            .init(userText: "中控屏", finiteReason: .unmountedToolName, family: .screen, result: .refusalNoAvailableTool, safeReason: .capabilityNotMounted, dialogText: "屏幕控制暂未接入演示版，我先不改屏幕设置。", ttsText: "屏幕控制暂未接入演示版，我先不改屏幕设置。", badgeLabel: "暂未接入"),
            .init(userText: "中控屏", finiteReason: .nameRejected, family: .screen, result: .refusalNoAvailableTool, safeReason: .capabilityNotMounted, dialogText: "屏幕控制暂未接入演示版，我先不改屏幕设置。", ttsText: "屏幕控制暂未接入演示版，我先不改屏幕设置。", badgeLabel: "暂未接入"),
            .init(userText: "中控屏", finiteReason: .fastPathNoMatch, family: .screen, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这个屏幕说法还没稳稳接住，您可以说中控屏亮度调高。", ttsText: "这个屏幕说法还没稳稳接住，您可以说中控屏亮度调高。", badgeLabel: "换个说法"),
            .init(userText: "中控屏", finiteReason: .unsupportedToolPlan, family: .screen, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这个屏幕说法还没稳稳接住，您可以说中控屏亮度调高。", ttsText: "这个屏幕说法还没稳稳接住，您可以说中控屏亮度调高。", badgeLabel: "换个说法"),
            .init(userText: "中控屏", finiteReason: .noRepresentativeTool, family: .screen, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这类屏幕能力不在本轮演示范围，我先保持原样。", ttsText: "这类屏幕能力不在本轮演示范围，我先保持原样。", badgeLabel: "不在范围"),
            .init(userText: "中控屏", finiteReason: .runtimeExecutionError, family: .screen, result: .runtimeError, safeReason: .runtimeUnavailable, dialogText: "当前运行状态不可用，请稍后重试。", ttsText: "当前运行状态不可用，请稍后重试。", badgeLabel: "暂不可用"),
            .init(userText: "中控屏", finiteReason: .staleStateRevision, family: .screen, result: .runtimeError, safeReason: .runtimeUnavailable, dialogText: "当前运行状态不可用，请稍后重试。", ttsText: "当前运行状态不可用，请稍后重试。", badgeLabel: "暂不可用"),
            .init(userText: "中控屏", finiteReason: .alreadyStateNoop, family: .screen, result: .alreadyStateNoop, safeReason: .alreadyDone, dialogText: "当前已经是目标状态，无需重复操作。", ttsText: "当前已经是目标状态，无需重复操作。", badgeLabel: "已完成"),

            // volume
            .init(userText: "音量", finiteReason: .safetyOrPolicyRefusal, family: .volume, result: .refusalSafetyOrPolicy, safeReason: .safetyPolicy, dialogText: "当前状态下不能执行这项操作，车辆状态保持不变。", ttsText: "当前状态下不能执行这项操作，车辆状态保持不变。", badgeLabel: "安全限制"),
            .init(userText: "音量", finiteReason: .clarifyMissingSlot, family: .volume, result: .clarifyMissingSlot, safeReason: .clarificationRequired, dialogText: "音量变化需要确认方向，我先保持当前音量。", ttsText: "音量变化需要确认方向，我先保持当前音量。", badgeLabel: "需确认"),
            .init(userText: "音量", finiteReason: .unmountedToolName, family: .volume, result: .refusalNoAvailableTool, safeReason: .capabilityNotMounted, dialogText: "音量控制暂未接入演示版，我先不改音量。", ttsText: "音量控制暂未接入演示版，我先不改音量。", badgeLabel: "暂未接入"),
            .init(userText: "音量", finiteReason: .nameRejected, family: .volume, result: .refusalNoAvailableTool, safeReason: .capabilityNotMounted, dialogText: "音量控制暂未接入演示版，我先不改音量。", ttsText: "音量控制暂未接入演示版，我先不改音量。", badgeLabel: "暂未接入"),
            .init(userText: "音量", finiteReason: .fastPathNoMatch, family: .volume, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这个音量说法还没稳稳接住，您可以说音量调低一点。", ttsText: "这个音量说法还没稳稳接住，您可以说音量调低一点。", badgeLabel: "换个说法"),
            .init(userText: "音量", finiteReason: .unsupportedToolPlan, family: .volume, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这个音量说法还没稳稳接住，您可以说音量调低一点。", ttsText: "这个音量说法还没稳稳接住，您可以说音量调低一点。", badgeLabel: "换个说法"),
            .init(userText: "音量", finiteReason: .noRepresentativeTool, family: .volume, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这类音量能力不在本轮演示范围，我先保持原样。", ttsText: "这类音量能力不在本轮演示范围，我先保持原样。", badgeLabel: "不在范围"),
            .init(userText: "音量", finiteReason: .runtimeExecutionError, family: .volume, result: .runtimeError, safeReason: .runtimeUnavailable, dialogText: "当前运行状态不可用，请稍后重试。", ttsText: "当前运行状态不可用，请稍后重试。", badgeLabel: "暂不可用"),
            .init(userText: "音量", finiteReason: .staleStateRevision, family: .volume, result: .runtimeError, safeReason: .runtimeUnavailable, dialogText: "当前运行状态不可用，请稍后重试。", ttsText: "当前运行状态不可用，请稍后重试。", badgeLabel: "暂不可用"),
            .init(userText: "音量", finiteReason: .alreadyStateNoop, family: .volume, result: .alreadyStateNoop, safeReason: .alreadyDone, dialogText: "当前已经是目标状态，无需重复操作。", ttsText: "当前已经是目标状态，无需重复操作。", badgeLabel: "已完成"),

            // wiper
            .init(userText: "雨刷", finiteReason: .safetyOrPolicyRefusal, family: .wiper, result: .refusalSafetyOrPolicy, safeReason: .safetyPolicy, dialogText: "当前状态下不能执行这项操作，车辆状态保持不变。", ttsText: "当前状态下不能执行这项操作，车辆状态保持不变。", badgeLabel: "安全限制"),
            .init(userText: "雨刷", finiteReason: .clarifyMissingSlot, family: .wiper, result: .clarifyMissingSlot, safeReason: .clarificationRequired, dialogText: "雨刮动作需要确认模式或速度，我先保持雨刮不变。", ttsText: "雨刮动作需要确认模式或速度，我先保持雨刮不变。", badgeLabel: "需确认"),
            .init(userText: "雨刷", finiteReason: .unmountedToolName, family: .wiper, result: .refusalNoAvailableTool, safeReason: .capabilityNotMounted, dialogText: "雨刮控制暂未接入演示版，我先不动雨刮。", ttsText: "雨刮控制暂未接入演示版，我先不动雨刮。", badgeLabel: "暂未接入"),
            .init(userText: "雨刷", finiteReason: .nameRejected, family: .wiper, result: .refusalNoAvailableTool, safeReason: .capabilityNotMounted, dialogText: "雨刮控制暂未接入演示版，我先不动雨刮。", ttsText: "雨刮控制暂未接入演示版，我先不动雨刮。", badgeLabel: "暂未接入"),
            .init(userText: "雨刷", finiteReason: .fastPathNoMatch, family: .wiper, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这个雨刮说法还没稳稳接住，您可以说打开雨刮。", ttsText: "这个雨刮说法还没稳稳接住，您可以说打开雨刮。", badgeLabel: "换个说法"),
            .init(userText: "雨刷", finiteReason: .unsupportedToolPlan, family: .wiper, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这个雨刮说法还没稳稳接住，您可以说打开雨刮。", ttsText: "这个雨刮说法还没稳稳接住，您可以说打开雨刮。", badgeLabel: "换个说法"),
            .init(userText: "雨刷", finiteReason: .noRepresentativeTool, family: .wiper, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这类雨刮能力不在本轮演示范围，我先保持原样。", ttsText: "这类雨刮能力不在本轮演示范围，我先保持原样。", badgeLabel: "不在范围"),
            .init(userText: "雨刷", finiteReason: .runtimeExecutionError, family: .wiper, result: .runtimeError, safeReason: .runtimeUnavailable, dialogText: "当前运行状态不可用，请稍后重试。", ttsText: "当前运行状态不可用，请稍后重试。", badgeLabel: "暂不可用"),
            .init(userText: "雨刷", finiteReason: .staleStateRevision, family: .wiper, result: .runtimeError, safeReason: .runtimeUnavailable, dialogText: "当前运行状态不可用，请稍后重试。", ttsText: "当前运行状态不可用，请稍后重试。", badgeLabel: "暂不可用"),
            .init(userText: "雨刷", finiteReason: .alreadyStateNoop, family: .wiper, result: .alreadyStateNoop, safeReason: .alreadyDone, dialogText: "当前已经是目标状态，无需重复操作。", ttsText: "当前已经是目标状态，无需重复操作。", badgeLabel: "已完成"),

            // sunroof shade
            .init(userText: "遮阳帘", finiteReason: .safetyOrPolicyRefusal, family: .sunroofShade, result: .refusalSafetyOrPolicy, safeReason: .safetyPolicy, dialogText: "当前状态下不能执行这项操作，车辆状态保持不变。", ttsText: "当前状态下不能执行这项操作，车辆状态保持不变。", badgeLabel: "安全限制"),
            .init(userText: "遮阳帘", finiteReason: .clarifyMissingSlot, family: .sunroofShade, result: .clarifyMissingSlot, safeReason: .clarificationRequired, dialogText: "天窗遮阳需要确认部件和开度，我先保持当前位置。", ttsText: "天窗遮阳需要确认部件和开度，我先保持当前位置。", badgeLabel: "需确认"),
            .init(userText: "遮阳帘", finiteReason: .unmountedToolName, family: .sunroofShade, result: .refusalNoAvailableTool, safeReason: .capabilityNotMounted, dialogText: "天窗遮阳控制暂未接入演示版，我先不动车顶部件。", ttsText: "天窗遮阳控制暂未接入演示版，我先不动车顶部件。", badgeLabel: "暂未接入"),
            .init(userText: "遮阳帘", finiteReason: .nameRejected, family: .sunroofShade, result: .refusalNoAvailableTool, safeReason: .capabilityNotMounted, dialogText: "天窗遮阳控制暂未接入演示版，我先不动车顶部件。", ttsText: "天窗遮阳控制暂未接入演示版，我先不动车顶部件。", badgeLabel: "暂未接入"),
            .init(userText: "遮阳帘", finiteReason: .fastPathNoMatch, family: .sunroofShade, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这个天窗遮阳说法还没稳稳接住，您可以说打开天窗遮阳帘。", ttsText: "这个天窗遮阳说法还没稳稳接住，您可以说打开天窗遮阳帘。", badgeLabel: "换个说法"),
            .init(userText: "遮阳帘", finiteReason: .unsupportedToolPlan, family: .sunroofShade, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这个天窗遮阳说法还没稳稳接住，您可以说打开天窗遮阳帘。", ttsText: "这个天窗遮阳说法还没稳稳接住，您可以说打开天窗遮阳帘。", badgeLabel: "换个说法"),
            .init(userText: "遮阳帘", finiteReason: .noRepresentativeTool, family: .sunroofShade, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这类车顶部件不在本轮演示范围，我先保持原样。", ttsText: "这类车顶部件不在本轮演示范围，我先保持原样。", badgeLabel: "不在范围"),
            .init(userText: "遮阳帘", finiteReason: .runtimeExecutionError, family: .sunroofShade, result: .runtimeError, safeReason: .runtimeUnavailable, dialogText: "当前运行状态不可用，请稍后重试。", ttsText: "当前运行状态不可用，请稍后重试。", badgeLabel: "暂不可用"),
            .init(userText: "遮阳帘", finiteReason: .staleStateRevision, family: .sunroofShade, result: .runtimeError, safeReason: .runtimeUnavailable, dialogText: "当前运行状态不可用，请稍后重试。", ttsText: "当前运行状态不可用，请稍后重试。", badgeLabel: "暂不可用"),
            .init(userText: "遮阳帘", finiteReason: .alreadyStateNoop, family: .sunroofShade, result: .alreadyStateNoop, safeReason: .alreadyDone, dialogText: "当前已经是目标状态，无需重复操作。", ttsText: "当前已经是目标状态，无需重复操作。", badgeLabel: "已完成"),

            // fragrance
            .init(userText: "香氛", finiteReason: .safetyOrPolicyRefusal, family: .fragrance, result: .refusalSafetyOrPolicy, safeReason: .safetyPolicy, dialogText: "当前状态下不能执行这项操作，车辆状态保持不变。", ttsText: "当前状态下不能执行这项操作，车辆状态保持不变。", badgeLabel: "安全限制"),
            .init(userText: "香氛", finiteReason: .clarifyMissingSlot, family: .fragrance, result: .clarifyMissingSlot, safeReason: .clarificationRequired, dialogText: "香氛设置需要确认模式或浓度，我先保持当前香氛。", ttsText: "香氛设置需要确认模式或浓度，我先保持当前香氛。", badgeLabel: "需确认"),
            .init(userText: "香氛", finiteReason: .unmountedToolName, family: .fragrance, result: .refusalNoAvailableTool, safeReason: .capabilityNotMounted, dialogText: "香氛控制暂未接入演示版，我先不改香氛设置。", ttsText: "香氛控制暂未接入演示版，我先不改香氛设置。", badgeLabel: "暂未接入"),
            .init(userText: "香氛", finiteReason: .nameRejected, family: .fragrance, result: .refusalNoAvailableTool, safeReason: .capabilityNotMounted, dialogText: "香氛控制暂未接入演示版，我先不改香氛设置。", ttsText: "香氛控制暂未接入演示版，我先不改香氛设置。", badgeLabel: "暂未接入"),
            .init(userText: "香氛", finiteReason: .fastPathNoMatch, family: .fragrance, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这个香氛说法还没稳稳接住，您可以说打开香氛。", ttsText: "这个香氛说法还没稳稳接住，您可以说打开香氛。", badgeLabel: "换个说法"),
            .init(userText: "香氛", finiteReason: .unsupportedToolPlan, family: .fragrance, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这个香氛说法还没稳稳接住，您可以说打开香氛。", ttsText: "这个香氛说法还没稳稳接住，您可以说打开香氛。", badgeLabel: "换个说法"),
            .init(userText: "香氛", finiteReason: .noRepresentativeTool, family: .fragrance, result: .refusalNoAvailableTool, safeReason: .notAvailableInDemo, dialogText: "这类香氛能力不在本轮演示范围，我先保持原样。", ttsText: "这类香氛能力不在本轮演示范围，我先保持原样。", badgeLabel: "不在范围"),
            .init(userText: "香氛", finiteReason: .runtimeExecutionError, family: .fragrance, result: .runtimeError, safeReason: .runtimeUnavailable, dialogText: "当前运行状态不可用，请稍后重试。", ttsText: "当前运行状态不可用，请稍后重试。", badgeLabel: "暂不可用"),
            .init(userText: "香氛", finiteReason: .staleStateRevision, family: .fragrance, result: .runtimeError, safeReason: .runtimeUnavailable, dialogText: "当前运行状态不可用，请稍后重试。", ttsText: "当前运行状态不可用，请稍后重试。", badgeLabel: "暂不可用"),
            .init(userText: "香氛", finiteReason: .alreadyStateNoop, family: .fragrance, result: .alreadyStateNoop, safeReason: .alreadyDone, dialogText: "当前已经是目标状态，无需重复操作。", ttsText: "当前已经是目标状态，无需重复操作。", badgeLabel: "已完成"),
        ]

        // G5 knife2 typed reasons: shared Chinese copy by SafeReasonKind (no catalog bucket expansion).
        // Literal oracle — do not derive from generated RuntimePresentationReasonAuthority projections.
        let g5FamilyHints: [(userText: String, family: FallbackScriptFamily?)] = [
            ("空调", .ac),
            ("座椅", .seat),
            ("车窗", .window),
            ("车门", .door),
            ("氛围灯", .ambient),
            ("中控屏", .screen),
            ("音量", .volume),
            ("雨刷", .wiper),
            ("遮阳帘", .sunroofShade),
            ("香氛", .fragrance),
        ]
        let g5ReasonOracle: [(
            finiteReason: RuntimeFiniteReason,
            result: DemoRuntimeResult,
            safeReason: RuntimePresentationSafeReasonKind,
            dialogText: String,
            badgeLabel: String
        )] = [
            (.lexicalInvalid, .refusalContractViolation, .lexicalInvalid, "输入格式无效，请换个说法，车辆状态保持不变。", "格式无效"),
            (.numericOverflow, .refusalContractViolation, .numericOverflow, "数值超出可处理范围，车辆状态保持不变。", "数值溢出"),
            (.arithmeticOverflow, .refusalContractViolation, .numericOverflow, "数值超出可处理范围，车辆状态保持不变。", "数值溢出"),
            (.unsupportedPrecision, .refusalContractViolation, .unsupportedPrecision, "精度不受支持，请使用整数或合法步进，车辆状态保持不变。", "精度不支持"),
            (.outOfRange, .refusalContractViolation, .outOfRange, "目标超出可调范围，车辆状态保持不变。", "超出范围"),
            (.malformedCurrent, .refusalContractViolation, .malformedCurrent, "当前状态异常，无法据此计算，车辆状态保持不变。", "状态异常"),
            (.unsupportedUnitReference, .refusalContractViolation, .unsupportedUnitReference, "该单位用法不受支持，车辆状态保持不变。", "单位不支持"),
            (.contractViolation, .refusalContractViolation, .contractViolation, "当前输入不符合演示契约，车辆状态保持不变。", "约定不符"),
            (.stateQuery, .stateQuery, .stateQuery, "已查询当前状态", "状态查询"),
            (.capabilityQuery, .capabilityQuery, .capabilityQuery, "已查询可调范围", "能力查询"),
            (.cancelTooLate, .cancelled, .cancelTooLate, "当前操作已提交，无法取消。", "取消过晚"),
        ]
        var allCases = cases
        for hint in g5FamilyHints {
            for oracle in g5ReasonOracle {
                allCases.append(
                    .init(
                        userText: hint.userText,
                        finiteReason: oracle.finiteReason,
                        family: hint.family,
                        result: oracle.result,
                        safeReason: oracle.safeReason,
                        dialogText: oracle.dialogText,
                        ttsText: oracle.dialogText,
                        badgeLabel: oracle.badgeLabel
                    )
                )
            }
        }

        XCTAssertEqual(allCases.count, 210)
        let expectedReasons: Set<RuntimeFiniteReason> = [
            .safetyOrPolicyRefusal,
            .clarifyMissingSlot,
            .unmountedToolName,
            .nameRejected,
            .fastPathNoMatch,
            .unsupportedToolPlan,
            .noRepresentativeTool,
            .runtimeExecutionError,
            .staleStateRevision,
            .alreadyStateNoop,
            .lexicalInvalid,
            .numericOverflow,
            .arithmeticOverflow,
            .unsupportedPrecision,
            .outOfRange,
            .malformedCurrent,
            .unsupportedUnitReference,
            .contractViolation,
            .stateQuery,
            .capabilityQuery,
            .cancelTooLate,
        ]
        XCTAssertEqual(expectedReasons, Set(RuntimeFiniteReason.allCases))
        for userText in ["空调", "座椅", "车窗", "车门", "氛围灯", "中控屏", "音量", "雨刷", "遮阳帘", "香氛"] {
            let familyCells = allCases.filter { $0.userText == userText }
            XCTAssertEqual(familyCells.count, 21, userText)
            XCTAssertEqual(Set(familyCells.map(\.finiteReason)), expectedReasons, userText)
        }
        for expected in allCases {
            let coordinate = "\(expected.userText)/\(expected.finiteReason.rawValue)"
            let context = FallbackContext.resolve(userText: expected.userText, finiteReason: expected.finiteReason)

            XCTAssertEqual(context.family, expected.family, coordinate)
            XCTAssertEqual(context.outcome.resultKind, expected.result, coordinate)
            XCTAssertEqual(context.outcome.safeReasonKind, expected.safeReason, coordinate)
            XCTAssertEqual(context.dialogText, expected.dialogText, coordinate)
            XCTAssertEqual(context.ttsText, expected.ttsText, coordinate)
            XCTAssertEqual(context.badgeLabel, expected.badgeLabel, coordinate)
        }
    }

    func testTraceRoundTripsHardcodedTenFiniteReasonsEndToEnd() throws {
        // Intentionally hard-coded so trace projection drift cannot update its own expected values.
        let cases: [(
            finiteReason: RuntimeFiniteReason,
            rawValue: String,
            safeReason: String
        )] = [
            (.safetyOrPolicyRefusal, "safety_or_policy_refusal", "safety_policy"),
            (.clarifyMissingSlot, "clarify_missing_slot", "clarification_required"),
            (.unmountedToolName, "unmounted_tool_name", "capability_not_mounted"),
            (.nameRejected, "name_rejected", "capability_not_mounted"),
            (.fastPathNoMatch, "fast_path_no_match", "not_available_in_demo"),
            (.unsupportedToolPlan, "unsupported_tool_plan", "not_available_in_demo"),
            (.noRepresentativeTool, "no_representative_tool", "not_available_in_demo"),
            (.runtimeExecutionError, "runtime_execution_error", "runtime_unavailable"),
            (.staleStateRevision, "stale_state_revision", "runtime_unavailable"),
            (.alreadyStateNoop, "already_state_noop", "already_done"),
            (.lexicalInvalid, "lexical_invalid", "lexical_invalid"),
            (.numericOverflow, "numeric_overflow", "numeric_overflow"),
            (.arithmeticOverflow, "arithmetic_overflow", "numeric_overflow"),
            (.unsupportedPrecision, "unsupported_precision", "unsupported_precision"),
            (.outOfRange, "out_of_range", "out_of_range"),
            (.malformedCurrent, "malformed_current", "malformed_current"),
            (.unsupportedUnitReference, "unsupported_unit_reference", "unsupported_unit_reference"),
            (.contractViolation, "contract_violation", "contract_violation"),
            (.stateQuery, "state_query", "state_query"),
            (.capabilityQuery, "capability_query", "capability_query"),
            (.cancelTooLate, "cancel_too_late", "cancel_too_late"),
        ]

        XCTAssertEqual(cases.count, 21)
        for expected in cases {
            let traceID = "trace-hardcoded-\(expected.rawValue)"
            let attributes = TraceAttributes(finiteReason: expected.finiteReason)
            let encodedAttributes = try JSONEncoder().encode(attributes)
            let decodedAttributes = try JSONDecoder().decode(TraceAttributes.self, from: encodedAttributes)
            let attributesObject = try XCTUnwrap(
                JSONSerialization.jsonObject(with: encodedAttributes) as? [String: Any]
            )

            XCTAssertEqual(decodedAttributes.finiteReason, expected.finiteReason, expected.rawValue)
            XCTAssertEqual(attributesObject["finiteReason"] as? String, expected.rawValue)

            let envelope = try XCTUnwrap(
                TraceEnvelope(
                    traceID: traceID,
                    entries: [
                        TraceEntry(
                            stage: .guard,
                            traceID: traceID,
                            message: "hardcoded finite reason behavior oracle",
                            attributes: decodedAttributes,
                            timestamp: Date(timeIntervalSince1970: 1_800_003_000)
                        )
                    ]
                )
            )
            let safeAttributes = try XCTUnwrap(envelope.presentationSafe().entries.first?.attributes)

            XCTAssertNil(safeAttributes.finiteReason, expected.rawValue)
            XCTAssertEqual(safeAttributes.guardReason, expected.safeReason, expected.rawValue)
        }

        // Four diagnostic kinds are an independent literal table; safe public trace JSON must erase both raw layers.
        let decodeFailureCases: [(
            finiteReason: RuntimeFiniteReason,
            rawFiniteReason: String,
            decodeFailureKind: DDomainDecodeFailureKind,
            rawDecodeFailureKind: String,
            safeReason: String
        )] = [
            (.unsupportedToolPlan, "unsupported_tool_plan", .parseFailed, "parse_failed", "not_available_in_demo"),
            (.nameRejected, "name_rejected", .nameRejected, "name_rejected", "capability_not_mounted"),
            (.unsupportedToolPlan, "unsupported_tool_plan", .irUnclassified, "ir_unclassified", "not_available_in_demo"),
            (.unsupportedToolPlan, "unsupported_tool_plan", .bridgeFailed, "bridge_failed", "not_available_in_demo"),
        ]

        XCTAssertEqual(decodeFailureCases.count, 4)
        for (index, expected) in decodeFailureCases.enumerated() {
            let attributes = TraceAttributes(
                finiteReason: expected.finiteReason,
                decodeFailureKind: expected.decodeFailureKind
            )
            let rawData = try JSONEncoder().encode(attributes)
            let rawObject = try XCTUnwrap(JSONSerialization.jsonObject(with: rawData) as? [String: Any])
            let decodedAttributes = try JSONDecoder().decode(TraceAttributes.self, from: rawData)

            XCTAssertEqual(rawObject["finiteReason"] as? String, expected.rawFiniteReason)
            XCTAssertEqual(rawObject["decodeFailureKind"] as? String, expected.rawDecodeFailureKind)
            XCTAssertNil(rawObject["guardReason"])
            XCTAssertEqual(decodedAttributes.finiteReason, expected.finiteReason)
            XCTAssertEqual(decodedAttributes.decodeFailureKind, expected.decodeFailureKind)

            let traceID = "trace-hardcoded-decode-failure-\(index)"
            let envelope = try XCTUnwrap(
                TraceEnvelope(
                    traceID: traceID,
                    entries: [
                        TraceEntry(
                            stage: .guard,
                            traceID: traceID,
                            message: "hardcoded decode failure behavior oracle",
                            attributes: decodedAttributes,
                            timestamp: Date(timeIntervalSince1970: 1_800_004_000 + Double(index))
                        )
                    ]
                )
            )
            let safeEnvelope = envelope.presentationSafe()
            let safeAttributes = try XCTUnwrap(safeEnvelope.entries.first?.attributes)
            let safeData = try JSONEncoder().encode(safeEnvelope)
            let safeText = try XCTUnwrap(String(data: safeData, encoding: .utf8))

            XCTAssertNil(safeAttributes.finiteReason, expected.rawDecodeFailureKind)
            XCTAssertNil(safeAttributes.decodeFailureKind, expected.rawDecodeFailureKind)
            XCTAssertEqual(safeAttributes.guardReason, expected.safeReason, expected.rawDecodeFailureKind)
            XCTAssertFalse(safeText.contains("\"finiteReason\""), safeText)
            XCTAssertFalse(safeText.contains("\"decodeFailureKind\""), safeText)
            XCTAssertFalse(safeText.contains(expected.rawFiniteReason), safeText)
            XCTAssertFalse(safeText.contains(expected.rawDecodeFailureKind), safeText)
        }
    }

    @MainActor
    func testPublicPayloadDoesNotLeakDecodeDiagnosticOrRejectedName() async throws {
        let rawRejectedName = "secret_raw_tool_name"
        let runner = try DemoRuntimeSessionRunner.defaultRunner(
            store: DemoVehicleStateStore(),
            traceLogger: InMemoryTraceLogger(),
            speech: RecordingSpeechSynthesisEngine(),
            modelBackend: RejectingBackend(failure: .nameRejected(rawRejectedName))
        )

        let payload = try await runner.run(text: "打开一个未挂载工具")
        let data = try JSONEncoder().encode(payload)
        let text = try XCTUnwrap(String(data: data, encoding: .utf8))

        XCTAssertFalse(text.contains(rawRejectedName), text)
        XCTAssertFalse(text.contains(DDomainDecodeFailureKind.nameRejected.rawValue), text)
        XCTAssertTrue(text.contains(RuntimePresentationSafeReasonKind.capabilityNotMounted.rawValue), text)
    }

    // Production E2E: drive the real DemoRuntimeSessionRunner failure catch/emitter path for the
    // four diagnostic kinds. Reads the raw trace from a retained InMemoryTraceLogger (not a hand-built
    // TraceAttributes DTO), asserts the typed finiteReason + decodeFailureKind pair the production
    // emitter wrote, then asserts presentation-safe erases both raw layers. Deleting the
    // `decodeFailureKind: failure.decodeFailureKind` forwarding in DemoRuntimeSessionRunner makes this RED.
    @MainActor
    func testDiagnosticFailuresTraverseProductionRunnerAndRedactPresentationTrace() async throws {
        let cases: [(
            userText: String,
            failure: DDomainToolPlanFailure,
            finiteReason: RuntimeFiniteReason,
            rawFiniteReason: String,
            decodeFailureKind: DDomainDecodeFailureKind,
            rawDecodeFailureKind: String,
            safeReason: RuntimePresentationSafeReasonKind
        )] = [
            ("解析失败输入", .parseFailed, .unsupportedToolPlan, "unsupported_tool_plan", .parseFailed, "parse_failed", .notAvailableInDemo),
            ("打开一个未挂载工具", .nameRejected("secret_raw_tool_name"), .nameRejected, "name_rejected", .nameRejected, "name_rejected", .capabilityNotMounted),
            ("无法归类的意图", .irUnclassified("secret_ir_detail"), .unsupportedToolPlan, "unsupported_tool_plan", .irUnclassified, "ir_unclassified", .notAvailableInDemo),
            ("桥接失败的意图", .bridgeFailed("secret_bridge_detail"), .unsupportedToolPlan, "unsupported_tool_plan", .bridgeFailed, "bridge_failed", .notAvailableInDemo),
        ]

        XCTAssertEqual(cases.count, 4)
        for expected in cases {
            let logger = InMemoryTraceLogger()
            let runner = try DemoRuntimeSessionRunner.defaultRunner(
                store: DemoVehicleStateStore(),
                traceLogger: logger,
                speech: RecordingSpeechSynthesisEngine(),
                modelBackend: RejectingBackend(failure: expected.failure)
            )

            _ = try await runner.run(text: expected.userText)

            let guardEntry = try XCTUnwrap(
                logger.entries.first { $0.stage == .guard && $0.message == "unsupported_tool_plan" },
                "\(expected.rawDecodeFailureKind): missing production unsupported_tool_plan guard trace"
            )
            XCTAssertEqual(guardEntry.attributes.finiteReason, expected.finiteReason, expected.rawDecodeFailureKind)
            XCTAssertEqual(
                guardEntry.attributes.decodeFailureKind,
                expected.decodeFailureKind,
                expected.rawDecodeFailureKind
            )

            let rawData = try JSONEncoder().encode(guardEntry.attributes)
            let rawObject = try XCTUnwrap(JSONSerialization.jsonObject(with: rawData) as? [String: Any])
            XCTAssertEqual(rawObject["finiteReason"] as? String, expected.rawFiniteReason)
            XCTAssertEqual(rawObject["decodeFailureKind"] as? String, expected.rawDecodeFailureKind)

            let envelope = try XCTUnwrap(
                TraceEnvelope(traceID: guardEntry.traceID, entries: [guardEntry])
            )
            let safeEnvelope = envelope.presentationSafe()
            let safeAttributes = try XCTUnwrap(safeEnvelope.entries.first?.attributes)
            let safeData = try JSONEncoder().encode(safeEnvelope)
            let safeText = try XCTUnwrap(String(data: safeData, encoding: .utf8))

            XCTAssertNil(safeAttributes.finiteReason, expected.rawDecodeFailureKind)
            XCTAssertNil(safeAttributes.decodeFailureKind, expected.rawDecodeFailureKind)
            XCTAssertEqual(safeAttributes.guardReason, expected.safeReason.rawValue, expected.rawDecodeFailureKind)
            XCTAssertFalse(safeText.contains("\"finiteReason\""), safeText)
            XCTAssertFalse(safeText.contains("\"decodeFailureKind\""), safeText)
            XCTAssertFalse(safeText.contains(expected.rawDecodeFailureKind), safeText)
        }
    }
}

private struct ExpectedFallbackCell {
    let userText: String
    let finiteReason: RuntimeFiniteReason
    let family: FallbackScriptFamily?
    let result: DemoRuntimeResult
    let safeReason: RuntimePresentationSafeReasonKind
    let dialogText: String
    let ttsText: String
    let badgeLabel: String
}

private struct RejectingBackend: LLMBackend {
    let failure: DDomainToolPlanFailure

    func load() async throws {}
    func generateToolPlan(for request: ToolPlanRequest) async throws -> RuntimePlan { throw failure }
    func streamText(for prompt: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { $0.finish() }
    }
    func cancel() {}
}
