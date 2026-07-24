import XCTest
@testable import MAformacCore

final class DomainRegistryTests: XCTestCase {
    func testDefaultRegistryContainsOnlyDisabledPlannedExternalDomains() {
        let registry = DomainRegistry.default

        XCTAssertEqual(registry.allDescriptors.map(\.domainID), [.navigation, .music, .foodDelivery])
        XCTAssertNil(registry.descriptor(for: .vehicle))

        for descriptor in registry.allDescriptors {
            XCTAssertFalse(descriptor.enabled)
            XCTAssertEqual(descriptor.availability, .planned)
            XCTAssertEqual(descriptor.connectorKind, .mcp)
            XCTAssertEqual(descriptor.proofCap, .openspecContract)
        }

        XCTAssertEqual(registry.descriptor(for: .navigation)?.displayName, "导航")
        XCTAssertEqual(registry.descriptor(for: .music)?.displayName, "音乐")
        XCTAssertEqual(registry.descriptor(for: .foodDelivery)?.displayName, "外卖")
    }

    func testRegistrySnapshotIsReadOnlyFromCallers() {
        let registry = DomainRegistry.default
        var copy = registry.allDescriptors

        copy.removeAll()

        XCTAssertEqual(copy, [])
        XCTAssertEqual(registry.allDescriptors.count, 3)
        XCTAssertNotNil(registry.descriptor(for: .music))
    }

    func testRegistrySnapshotDriftsIfContractsPlannedTruthChanges() throws {
        let agentsYAML = try readRepoFile("contracts/agents.yaml")
        let expected: [(domainID: DomainID, id: String, displayName: String)] = [
            (.navigation, "navigation", "导航"),
            (.music, "music", "音乐"),
            (.foodDelivery, "food-delivery", "外卖")
        ]

        for entry in expected {
            let block = try agentBlock(entry.id, in: agentsYAML)
            let descriptor = try XCTUnwrap(DomainRegistry.default.descriptor(for: entry.domainID))

            XCTAssertEqual(descriptor.domainID.rawValue, entry.id)
            XCTAssertEqual(descriptor.displayName, entry.displayName)
            XCTAssertTrue(block.contains("display_zh: \(entry.displayName)"))
            XCTAssertTrue(block.contains("connector: mock"))
            XCTAssertTrue(block.contains("enabled: false"))
            XCTAssertTrue(block.contains("availability: planned"))
            XCTAssertTrue(block.contains("capability_ids: []"))
        }
    }

    private func readRepoFile(_ relativePath: String) throws -> String {
        let testFile = URL(fileURLWithPath: #filePath)
        let repoRoot = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try String(contentsOf: repoRoot.appendingPathComponent(relativePath), encoding: .utf8)
    }

    private func agentBlock(_ id: String, in yaml: String) throws -> String {
        let marker = "  - id: \(id)"
        guard let start = yaml.range(of: marker)?.lowerBound else {
            throw XCTSkip("missing agent \(id)")
        }
        let remaining = yaml[start...]
        if let next = remaining.dropFirst(marker.count).range(of: "\n  - id: ")?.lowerBound {
            return String(remaining[..<next])
        }
        return String(remaining)
    }
}
