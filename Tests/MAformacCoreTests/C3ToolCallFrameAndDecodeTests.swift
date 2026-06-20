import XCTest
@testable import MAformacCore

final class C3ToolCallFrameAndDecodeTests: XCTestCase {
    func testStrongToolCallFrameCodableRoundTripKeepsC1C2Fields() throws {
        let frame = ToolCallFrame(
            traceID: "trace-1",
            agentID: "vehicle-control",
            capabilityID: "cabin.ac_temperature",
            toolName: "vehicle_control",
            device: "ac_temperature",
            actionPrimitive: "increase_by_exp",
            slots: ["direction": "主驾"],
            value: ContractValue(ref: "CUR", direct: "+", offset: "LITTLE", type: "EXP"),
            stateRevision: 7,
            candidateSource: .upstreamToolCall,
            rawPayload: .object(["value": .object(["offset": .string("LITTLE")])])
        )

        let encoded = try JSONEncoder().encode(frame)
        let decoded = try JSONDecoder().decode(ToolCallFrame.self, from: encoded)

        XCTAssertEqual(decoded.device, "ac_temperature")
        XCTAssertEqual(decoded.actionPrimitive, "increase_by_exp")
        XCTAssertEqual(decoded.slots["direction"], "主驾")
        XCTAssertEqual(decoded.value, ContractValue(ref: "CUR", direct: "+", offset: "LITTLE", type: "EXP"))
        XCTAssertEqual(decoded.stateRevision, 7)
        XCTAssertEqual(decoded.candidateSource, .upstreamToolCall)
        XCTAssertEqual(decoded.rawPayload, .object(["value": .object(["offset": .string("LITTLE")])]))
    }

    func testRuntimeUnionAcceptsExactlyOneFrameAndRejectsMultiFrame() {
        let tool = RuntimeFrame.tool(.fixture(device: "window", actionPrimitive: "power_on"))
        XCTAssertNoThrow(try RuntimeFrame.requireExactlyOne([tool]))
        XCTAssertThrowsError(try RuntimeFrame.requireExactlyOne([tool, tool])) { error in
            XCTAssertEqual(error as? ToolExecutionError, .schemaInvalid(.multipleFrames))
        }
        XCTAssertThrowsError(try RuntimeFrame.requireExactlyOne([])) { error in
            XCTAssertEqual(error as? ToolExecutionError, .noToolCall)
        }
    }

    func testNoActionAndClarifyFramesAreAcceptedAsSingleFrame() throws {
        let noAction = try RuntimeFrame.requireExactlyOne([.noAction(NoActionFrame(reason: "out_of_domain"))])
        let clarify = try RuntimeFrame.requireExactlyOne([.clarify(ClarifyFrame(question: "您想调哪个位置?"))])

        XCTAssertEqual(noAction, .noAction(NoActionFrame(reason: "out_of_domain")))
        XCTAssertEqual(clarify, .clarify(ClarifyFrame(question: "您想调哪个位置?")))
    }

    func testContentFallbackIsDisabledByDefault() {
        let decoder = ToolCallCandidateDecoder()
        let content = #"{"device":"window","action_primitive":"power_on"}"#

        XCTAssertThrowsError(try decoder.decodeContentFallback(content)) { error in
            XCTAssertEqual(error as? ToolExecutionError, .malformed(.contentFallbackDisabled))
        }
    }

    func testStrictDecodeMapsUnknownEnumToSchemaInvalidWithoutCrash() {
        let decoder = ToolCallCandidateDecoder(contentFallbackEnabled: true)
        let content = #"{"device":"window","action_primitive":"teleport","slot":{"position":"主驾"},"value":{"ref":"ZERO","direct":"+","offset":"100","type":"PERCENT"},"state_revision":0}"#

        XCTAssertThrowsError(try decoder.decodeContentFallback(content)) { error in
            XCTAssertEqual(error as? ToolExecutionError, .schemaInvalid(.unknownEnum("action_primitive")))
        }
    }

    func testThinkingLeakIsRecordedAsFailure() {
        let decoder = ToolCallCandidateDecoder(contentFallbackEnabled: true)

        XCTAssertThrowsError(try decoder.decodeContentFallback("<think>我要先想想</think>")) { error in
            XCTAssertEqual(error as? ToolExecutionError, .thinkLeak)
        }
    }

    func testNonStreamingCompletionStripsThinkingAndParsesFencedJSONCandidate() throws {
        let decoder = ToolCallCandidateDecoder(contentFallbackEnabled: true)
        let completion = """
        <think>先识别用户想打开主驾车窗</think>
        ```json
        {"device":"window","action_primitive":"power_on","slot":{"position":"主驾"},"value":{"ref":"ZERO","direct":"+","offset":"100","type":"PERCENT"},"state_revision":0}
        ```
        """

        let frame = try decoder.decodeNonStreamingCompletion(completion)

        XCTAssertEqual(frame.device, "window")
        XCTAssertEqual(frame.actionPrimitive, "power_on")
        XCTAssertEqual(frame.slots["position"], "主驾")
        XCTAssertEqual(frame.candidateSource, .parserRepair)
    }
}

private extension ToolCallFrame {
    static func fixture(device: String, actionPrimitive: String) -> ToolCallFrame {
        ToolCallFrame(
            agentID: "vehicle-control",
            capabilityID: "cabin.\(device)",
            toolName: "vehicle_control",
            device: device,
            actionPrimitive: actionPrimitive,
            slots: [:],
            value: ContractValue(),
            stateRevision: 0,
            candidateSource: .upstreamToolCall,
            rawPayload: .object([:])
        )
    }
}
