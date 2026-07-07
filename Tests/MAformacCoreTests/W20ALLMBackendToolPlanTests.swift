import XCTest
@testable import MAformacCore

final class W20ALLMBackendToolPlanTests: XCTestCase {
    func testDirectValueToolCallBuildsModelRouterFrame() async throws {
        let backend = backend(completion: toolCall("adjust_ac_temperature_to_number", ["temperature": "26"]))

        let frame = try await backend.generateToolPlan(for: ToolPlanRequest(text: "调到26度")).first

        XCTAssertEqual(frame?.device, "ac_temperature")
        XCTAssertEqual(frame?.value.direct, "26")
        XCTAssertEqual(frame?.value.type, "SPOT")
        XCTAssertEqual(frame?.agentID, "vehicle-control")
        XCTAssertEqual(frame?.capabilityID, "cabin.ac_temperature")
        XCTAssertEqual(frame?.candidateSource, .modelRouter)
    }

    func testHallucinatedDirectionAndModeAreProjectedOut() async throws {
        let backend = backend(completion: toolCall("adjust_ac_temperature_to_number", [
            "temperature": "24",
            "direction": "主驾",
            "mode": "制热"
        ]))

        let frame = try await backend.generateToolPlan(for: ToolPlanRequest(text: "主驾空调制热调到24度")).first

        XCTAssertEqual(frame?.value.direct, "24")
        XCTAssertNil(frame?.slots["direction"])
        XCTAssertNil(frame?.slots["mode"])
    }

    func testUnmountedNameRejectedBeforeNormalizeAndC3() async {
        await assertNameRejected(toolCall("open_ac", [:]), expectedName: "open_ac")
    }

    func testEXPAndLockACToolNamesAreRejected() async {
        await assertNameRejected(toolCall("raise_ac_temperature_by_exp", [:]), expectedName: "raise_ac_temperature_by_exp")
        await assertNameRejected(toolCall("lock_ac", [:]), expectedName: "lock_ac")
    }

    func testStreamTextIsNotUsedForW20AToolPlan() async throws {
        let completion = toolCall("adjust_ac_temperature_to_number", ["temperature": "26"])
        let backend = DDomainToolPlanBackend(
            mountedToolNames: DDomainMountedToolCatalog.mountedToolNames,
            completionProvider: { _ in completion },
            streamTextProvider: { _ in
                XCTFail("streamText must not participate in W20A tool plan")
                return AsyncThrowingStream<String, Error> { $0.finish() }
            }
        )

        _ = try await backend.generateToolPlan(for: ToolPlanRequest(text: "调到26度"))
    }

    private func assertNameRejected(_ completion: String, expectedName: String) async {
        let backend = backend(completion: completion)
        do {
            _ = try await backend.generateToolPlan(for: ToolPlanRequest(text: "bad"))
            XCTFail("expected name_rejected")
        } catch {
            XCTAssertEqual(error as? DDomainToolPlanFailure, .nameRejected(expectedName))
        }
    }

    private func backend(completion: String) -> DDomainToolPlanBackend {
        DDomainToolPlanBackend(
            mountedToolNames: DDomainMountedToolCatalog.mountedToolNames,
            completionProvider: { _ in completion }
        )
    }

    private func toolCall(_ name: String, _ arguments: [String: String]) -> String {
        let args = arguments
            .map { #""\#($0.key)":"\#($0.value)""# }
            .sorted()
            .joined(separator: ",")
        return #"<tool_call>{"name":"\#(name)","arguments":{\#(args)}}</tool_call>"#
    }
}
