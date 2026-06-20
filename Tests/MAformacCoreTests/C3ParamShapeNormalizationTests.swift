import XCTest
@testable import MAformacCore

/// gap#2: 工具参数接受多种 JSON 形态但不扩大安全边界。
/// spec tool-execution:169-180 — 对象/字符串化 JSON/数组/标量都要识别并归一为内部 JSON value，
/// 继续走 required/type/enum/range 校验；不静默当空参数执行。
final class C3ParamShapeNormalizationTests: XCTestCase {
    func testStringifiedJSONValueObjectIsParsedAndNormalized() throws {
        let decoder = ToolCallCandidateDecoder(contentFallbackEnabled: true)
        // value 是「字符串化的 JSON 对象」而非内联对象（小模型常见输出形态）。
        let content = #"{"device":"window","action_primitive":"by_percent","value":"{\"ref\":\"ZERO\",\"direct\":\"+\",\"offset\":\"30\",\"type\":\"PERCENT\"}"}"#

        let frame = try decoder.decodeContentFallback(content)
        XCTAssertEqual(frame.value, ContractValue(ref: "ZERO", direct: "+", offset: "30", type: "PERCENT"))
    }

    func testStringifiedJSONValueStillEnforcesTypeEnum() {
        let decoder = ToolCallCandidateDecoder(contentFallbackEnabled: true)
        // 归一后仍要过 value.type enum 校验 —— 安全边界不能被形态归一绕过。
        let content = #"{"device":"window","action_primitive":"by_percent","value":"{\"type\":\"WARP\"}"}"#

        XCTAssertThrowsError(try decoder.decodeContentFallback(content)) { error in
            XCTAssertEqual(error as? ToolExecutionError, .schemaInvalid(.unknownEnum("value.type")))
        }
    }

    func testArrayShapedValueIsNotSilentlyDroppedButRejected() {
        let decoder = ToolCallCandidateDecoder(contentFallbackEnabled: true)
        // 数组形态 value 无法归一为四件套 → 明确 decode failed，不静默当空参数执行。
        let content = #"{"device":"window","action_primitive":"by_percent","value":[30]}"#

        XCTAssertThrowsError(try decoder.decodeContentFallback(content)) { error in
            XCTAssertEqual(error as? ToolExecutionError, .schemaInvalid(.typeMismatch("value")))
        }
    }

    func testScalarShapedValueIsNotSilentlyDroppedButRejected() {
        let decoder = ToolCallCandidateDecoder(contentFallbackEnabled: true)
        let content = #"{"device":"window","action_primitive":"by_percent","value":30}"#

        XCTAssertThrowsError(try decoder.decodeContentFallback(content)) { error in
            XCTAssertEqual(error as? ToolExecutionError, .schemaInvalid(.typeMismatch("value")))
        }
    }

    func testStringifiedJSONSlotMapIsParsed() throws {
        let decoder = ToolCallCandidateDecoder(contentFallbackEnabled: true)
        let content = #"{"device":"window","action_primitive":"power_on","slot":"{\"position\":\"主驾\"}"}"#

        let frame = try decoder.decodeContentFallback(content)
        XCTAssertEqual(frame.slots["position"], "主驾")
    }
}
