import XCTest
@testable import MAformacCore

final class ToolCallFrameDecoderAllowlistTests: XCTestCase {
    private let decoder = ToolCallCandidateDecoder(contentFallbackEnabled: true)

    func testDecodeNonStreamingCompletionRejectsUnmountedCatalogName() {
        XCTAssertThrowsError(try decoder.decodeNonStreamingCompletion(
            completion(for: "open_ac", device: "ac", actionPrimitive: "power_on"),
            allowedToolNames: DDomainMountedToolCatalog.mountedToolNames
        )) { error in
            XCTAssertEqual(error as? ToolExecutionError, .schemaInvalid(.unknownToolName("open_ac")))
        }
    }

    func testDecodeNonStreamingCompletionRejectsByEXPName() {
        XCTAssertThrowsError(try decoder.decodeNonStreamingCompletion(
            completion(for: "raise_ac_temperature_by_exp", device: "ac_temperature", actionPrimitive: "increase_by_exp"),
            allowedToolNames: DDomainMountedToolCatalog.mountedToolNames
        )) { error in
            XCTAssertEqual(error as? ToolExecutionError, .schemaInvalid(.unknownToolName("raise_ac_temperature_by_exp")))
        }
    }

    func testDecodeNonStreamingCompletionRejectsLockACName() {
        XCTAssertThrowsError(try decoder.decodeNonStreamingCompletion(
            completion(for: "lock_ac", device: "ac", actionPrimitive: "power_on"),
            allowedToolNames: DDomainMountedToolCatalog.mountedToolNames
        )) { error in
            XCTAssertEqual(error as? ToolExecutionError, .schemaInvalid(.unknownToolName("lock_ac")))
        }
    }

    func testDecodeNonStreamingCompletionAcceptsAllowedName() throws {
        let frame = try decoder.decodeNonStreamingCompletion(
            completion(for: "adjust_ac_temperature_to_number", device: "ac_temperature", actionPrimitive: "adjust_to_number"),
            allowedToolNames: DDomainMountedToolCatalog.mountedToolNames
        )

        XCTAssertEqual(frame.toolName, "adjust_ac_temperature_to_number")
        XCTAssertEqual(frame.candidateSource, ToolCandidateSource.parserRepair)
    }

    func testProductionHelperCallsRequireAllowedToolNames() throws {
        let root = repoRoot()
        for relativePath in ["Core", "App"] {
            let directory = root.appendingPathComponent(relativePath)
            guard let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: nil) else { continue }
            for case let url as URL in enumerator where url.pathExtension == "swift" {
                let text = try String(contentsOf: url, encoding: .utf8)
                let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
                for (offset, line) in lines.enumerated() {
                    if line.contains("decodeNonStreamingCompletion("),
                       !line.contains("func decodeNonStreamingCompletion"),
                       !line.contains("allowedToolNames:") {
                        XCTFail("\(url.path):\(offset + 1) calls decodeNonStreamingCompletion without allowedToolNames")
                    }
                }
            }
        }
    }

    private func completion(for toolName: String, device: String, actionPrimitive: String) -> String {
        """
        {"device":"\(device)","action_primitive":"\(actionPrimitive)","tool_name":"\(toolName)","value":{"type":"SPOT","direct":"26"},"state_revision":0}
        """
    }

    private func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
