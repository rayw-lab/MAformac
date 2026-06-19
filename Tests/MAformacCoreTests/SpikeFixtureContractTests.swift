import XCTest
@testable import MAformacCore

final class SpikeFixtureContractTests: XCTestCase {
    @MainActor
    func testSpikeFixtureSmoketestCoversAllFiftyFiveCasesWithNoReadbackMismatch() throws {
        let fixture = try loadFixture()
        let decoder = ToolCallDecoder()
        let guardrail = DemoSchemaGuard()
        let executor = DemoActionExecutor()
        var executedCount = 0
        var readbackMismatchCount = 0
        var noToolCallCount = 0
        var fallbackCandidateIDs: [String] = []

        XCTAssertEqual(fixture.results.count, 55)
        XCTAssertEqual(fixture.results.filter { !$0.isNegative }.count, 40)
        XCTAssertEqual(fixture.results.filter(\.isNegative).count, 15)

        for result in fixture.results {
            let candidates = try candidates(for: result, decoder: decoder)
            if candidates.isEmpty {
                noToolCallCount += 1
                XCTAssertThrowsError(try decoder.decodeFirst([])) { error in
                    XCTAssertEqual(error as? ToolCallDecodeError, .no_tool_call)
                }
                continue
            }

            for candidate in candidates {
                if candidate.source == .contentFallback {
                    fallbackCandidateIDs.append(result.id)
                }
                let frame = try decoder.decode(candidate, traceID: result.id)
                XCTAssertEqual(GeneratedCapabilityCatalog.toolNameToCapabilityID[frame.toolName], frame.capabilityID)
                XCTAssertEqual(guardrail.evaluate(frame), .allow(reason: "schema_valid"), result.id)

                let store = DemoVehicleStateStore()
                let readback = try executor.applyMockTransition(frame, store: store)
                executedCount += 1
                if store.cell(for: readback.key)?.actualValue != readback.actualValue {
                    readbackMismatchCount += 1
                }
            }
        }

        XCTAssertEqual(noToolCallCount, 12)
        XCTAssertEqual(Set(fallbackCandidateIDs), Set(["P002", "P008", "P013", "P018", "P022", "P027", "P028", "P029", "P030", "N016", "N017"]))
        XCTAssertEqual(Set(fallbackCandidateIDs.filter { $0.hasPrefix("P") }), Set(["P002", "P008", "P013", "P018", "P022", "P027", "P028", "P029", "P030"]))
        XCTAssertEqual(executedCount, 43)
        XCTAssertEqual(readbackMismatchCount, 0)
    }

    func testFixtureContainsNoThinkLeakAndSyntheticThinkLeakIsCoveredElsewhere() throws {
        let fixture = try loadFixture()

        XCTAssertEqual(fixture.results.filter(\.thinkLeak).count, 0)
    }

    private func candidates(
        for result: SpikeFixtureResult,
        decoder: ToolCallDecoder
    ) throws -> [ToolCallCandidate] {
        if !result.toolCalls.isEmpty {
            return result.toolCalls.map {
                ToolCallCandidate(
                    toolName: $0.name,
                    arguments: $0.arguments,
                    source: .rawToolCall,
                    stopReason: result.completion.stopReason
                )
            }
        }

        if result.contentLooksLikeToolCall {
            let candidate = try decoder.contentFallbackCandidate(
                from: result.chunkText,
                stopReason: result.completion.stopReason
            )
            if let candidate {
                return [candidate]
            }
        }

        return []
    }

    private func loadFixture() throws -> SpikeFixture {
        let testFile = URL(fileURLWithPath: #filePath)
        let repoRoot = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let data = try Data(contentsOf: repoRoot.appendingPathComponent("dev/spike-e3/Reports/spike-e3-results.json"))
        return try JSONDecoder().decode(SpikeFixture.self, from: data)
    }
}

private struct SpikeFixture: Decodable {
    let results: [SpikeFixtureResult]
}

private struct SpikeFixtureResult: Decodable {
    let id: String
    let chunkText: String
    let contentLooksLikeToolCall: Bool
    let isNegative: Bool
    let thinkLeak: Bool
    let toolCalls: [SpikeFixtureToolCall]
    let completion: SpikeFixtureCompletion
}

private struct SpikeFixtureToolCall: Decodable {
    let name: String
    let arguments: [String: JSONValue]
}

private struct SpikeFixtureCompletion: Decodable {
    let stopReason: String
}
