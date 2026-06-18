import XCTest
@testable import MAformacCore

final class CapabilityContractFileTests: XCTestCase {
    private let capabilityIDs = [
        "cabin.ac",
        "cabin.seat_heating",
        "cabin.seat_ventilation",
        "cabin.window",
        "cabin.ambient_light",
        "cabin.screen_brightness",
        "cabin.fan",
        "cabin.comfort_query"
    ]

    @MainActor
    func testCapabilityContractDefinesEightReachableMvpCapabilities() throws {
        let capabilities = try readRepoFile("contracts/capabilities.yaml")
        let agents = try readRepoFile("contracts/agents.yaml")
        let store = DemoVehicleStateStore()

        XCTAssertEqual(capabilityIDs.filter { capabilities.contains("- id: \($0)") }.count, 8)
        for id in capabilityIDs {
            XCTAssertTrue(agents.contains("- \(id)"), "vehicle-control agent must reference \(id)")
            let block = try capabilityBlock(id, in: capabilities)
            for field in ["status:", "display_zh:", "aliases:", "tool_schema:", "reference_binding:", "execution:", "demo_guard:", "response:", "eval_refs:"] {
                XCTAssertTrue(block.contains(field), "\(id) missing \(field)")
            }
            let stateCell = try firstCapture(#"state_cell:\s*([A-Za-z0-9_.]+)"#, in: block)
            XCTAssertNotNil(store.cell(for: stateCell), "\(id) points at missing state_cell \(stateCell)")
        }
    }

    func testCapabilityContractMarksHistoricalDraftsSuperseded() throws {
        let capabilities = try readRepoFile("contracts/capabilities.yaml")

        for draft in ["03-openspec-input", "03-capabilities-catalog", "tech-baseline §4.1"] {
            XCTAssertTrue(capabilities.contains(draft), "missing draft pointer \(draft)")
        }
        XCTAssertEqual(matches(#"status:\s*superseded"#, in: capabilities).count, 3)
    }

    func testCapabilityContractIsFailClosedForSensitiveSourceLeakage() throws {
        let combined = try readRepoFile("contracts/capabilities.yaml") + "\n" + readRepoFile("contracts/agents.yaml")
        let denylist = [
            "T19CFL",
            "禁止外传",
            "对内",
            "报价",
            "成本"
        ]

        for token in denylist {
            XCTAssertFalse(combined.contains(token), "sensitive token leaked: \(token)")
        }
        XCTAssertNil(combined.range(of: #"[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}"#, options: [.regularExpression, .caseInsensitive]))
        XCTAssertNil(combined.range(of: #"1[3-9][0-9]{9}"#, options: .regularExpression))
    }

    private func capabilityBlock(_ id: String, in yaml: String) throws -> String {
        let marker = "- id: \(id)"
        guard let start = yaml.range(of: marker)?.lowerBound else {
            throw XCTSkip("missing capability \(id)")
        }
        let remaining = yaml[start...]
        if let next = remaining.dropFirst(marker.count).range(of: "\n  - id: ")?.lowerBound {
            return String(remaining[..<next])
        }
        return String(remaining)
    }

    private func readRepoFile(_ relativePath: String) throws -> String {
        let testFile = URL(fileURLWithPath: #filePath)
        let repoRoot = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try String(contentsOf: repoRoot.appendingPathComponent(relativePath), encoding: .utf8)
    }

    private func matches(_ pattern: String, in text: String) -> [String] {
        (try? NSRegularExpression(pattern: pattern))?.matches(
            in: text,
            range: NSRange(text.startIndex..., in: text)
        ).map { String(text[Range($0.range, in: text)!]) } ?? []
    }

    private func firstCapture(_ pattern: String, in text: String) throws -> String {
        let regex = try NSRegularExpression(pattern: pattern)
        let nsRange = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: nsRange),
              match.numberOfRanges > 1,
              let range = Range(match.range(at: 1), in: text)
        else {
            throw XCTSkip("missing match for \(pattern)")
        }
        return String(text[range])
    }
}
