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
        XCTAssertEqual(RuntimeFiniteReason.allCases.count, 10)
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

    func testFallbackResolutionConsumesGeneratedProjectionForAllTenReasons() {
        for finiteReason in RuntimeFiniteReason.allCases {
            let context = FallbackContext.resolve(userText: nil, finiteReason: finiteReason)
            let projection = RuntimePresentationReasonAuthority.projection(for: finiteReason)

            XCTAssertEqual(context.outcome.safeReasonKind, projection.safeReasonKind, finiteReason.rawValue)
            XCTAssertEqual(context.outcome.resultKind, projection.result, finiteReason.rawValue)
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
}

private struct RejectingBackend: LLMBackend {
    let failure: DDomainToolPlanFailure

    func load() async throws {}
    func generateToolPlan(for request: ToolPlanRequest) async throws -> [ToolCallFrame] { throw failure }
    func streamText(for prompt: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { $0.finish() }
    }
    func cancel() {}
}
