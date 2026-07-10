import Foundation
import XCTest
@testable import MAformacCore

final class DemoCapabilityMatrixGeneratedTests: XCTestCase {
    func testGeneratedCatalogPreservesAll120SourceCellsAndCanDemoTruth() throws {
        let source = try loadSourceMatrix()

        XCTAssertEqual(source.cells.count, 120)
        XCTAssertEqual(DemoCapabilityMatrixCatalog.cells.count, 120)
        XCTAssertEqual(
            DemoCapabilityMatrixCatalog.cells.map(\.matrixID),
            source.cells.map(\.matrixID)
        )

        let generatedByID = Dictionary(
            uniqueKeysWithValues: DemoCapabilityMatrixCatalog.cells.map { ($0.matrixID, $0) }
        )
        for sourceCell in source.cells {
            let generated = try XCTUnwrap(generatedByID[sourceCell.matrixID])
            XCTAssertEqual(generated.canDemo, sourceCell.canDemo, "matrix_id=\(sourceCell.matrixID)")
            XCTAssertEqual(
                generated.entrypointAliases,
                sourceCell.entrypointAliases,
                "matrix_id=\(sourceCell.matrixID)"
            )
            XCTAssertEqual(
                generated.primaryClass.rawValue,
                sourceCell.primaryClass,
                "matrix_id=\(sourceCell.matrixID)"
            )
        }
    }

    func testGeneratedCatalogPinsExactSourceSHA256() throws {
        let sourceURL = repoRoot.appendingPathComponent("contracts/demo-capability-matrix.json")
        XCTAssertEqual(
            DemoCapabilityMatrixCatalog.sourceSHA256,
            try C6Hash.fileHash(url: sourceURL)
        )
    }

    func testPrimaryClassEnumIsClosedOverT0Contract() {
        XCTAssertEqual(
            Set(DemoCapabilityPrimaryClass.allCases.map(\.rawValue)),
            [
                "safety_or_clarify_reject",
                "unmounted_name_rejected",
                "fast_path_no_match_fallback",
                "default_executable",
                "conditional_ddomain_executable",
            ]
        )
    }

    func testFastPathAliasCannotPromoteCanDemoBeyondSourceTruth() throws {
        let source = try loadSourceMatrix()
        let sourceFastPath = source.cells.filter { !$0.entrypointAliases.isEmpty }
        let generatedFastPath = DemoCapabilityMatrixCatalog.cells.filter { !$0.entrypointAliases.isEmpty }

        XCTAssertFalse(sourceFastPath.isEmpty)
        XCTAssertEqual(generatedFastPath.map(\.matrixID), sourceFastPath.map(\.matrixID))
        XCTAssertEqual(generatedFastPath.map(\.canDemo), sourceFastPath.map(\.canDemo))
        XCTAssertTrue(
            zip(generatedFastPath, sourceFastPath).allSatisfy { generated, sourceCell in
                generated.canDemo == sourceCell.canDemo
            }
        )
    }

    func testGeneratorPassesThroughValidSourceCanDemoTrue() throws {
        let sourceURL = repoRoot.appendingPathComponent("contracts/demo-capability-matrix.json")
        var root = try XCTUnwrap(
            JSONSerialization.jsonObject(with: Data(contentsOf: sourceURL)) as? [String: Any]
        )
        var cells = try XCTUnwrap(root["cells"] as? [[String: Any]])
        var first = cells[0]
        var basis = try XCTUnwrap(first["canDemo_basis"] as? [String: Any])
        for key in ["mounted_or_approved_action", "semantic_contract", "state_readback_cell"] {
            var item = try XCTUnwrap(basis[key] as? [String: Any])
            item["observed"] = true
            basis[key] = item
        }
        var readback = try XCTUnwrap(basis["readbackProbePass"] as? [String: Any])
        readback["observed"] = true
        readback["status"] = "passed"
        readback["probe_id"] = "probe.action.matrix.1.zh-CN"
        readback["probe_receipt_id"] = "runtime-action-readback-probes"
        basis["readbackProbePass"] = readback
        first["canDemo_basis"] = basis
        first["canDemo"] = true
        cells[0] = first
        root["cells"] = cells

        let temporaryDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: temporaryDirectory) }
        let input = temporaryDirectory.appendingPathComponent("matrix.json")
        let output = temporaryDirectory.appendingPathComponent("matrix.swift")
        try JSONSerialization.data(withJSONObject: root, options: [.sortedKeys])
            .write(to: input)
        try runGenerator(
            generator: repoRoot.appendingPathComponent("Tools/generate_demo_capability_matrix_swift.py"),
            input: input,
            output: output
        )

        let generated = try String(contentsOf: output, encoding: .utf8)
        let firstCell = try XCTUnwrap(generated.range(of: "matrixID: 1,"))
        let suffix = generated[firstCell.lowerBound...]
        let nextCell = try XCTUnwrap(suffix.range(of: "matrixID: 2,"))
        XCTAssertTrue(suffix[..<nextCell.lowerBound].contains("canDemo: true"))
    }

    func testGeneratorIsByteIdenticalAcrossRunsAndMatchesTrackedOutput() throws {
        let generator = repoRoot.appendingPathComponent("Tools/generate_demo_capability_matrix_swift.py")
        let temporaryDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(
            at: temporaryDirectory,
            withIntermediateDirectories: true
        )
        defer { try? FileManager.default.removeItem(at: temporaryDirectory) }

        let first = temporaryDirectory.appendingPathComponent("first.swift")
        let second = temporaryDirectory.appendingPathComponent("second.swift")
        let input = repoRoot.appendingPathComponent("contracts/demo-capability-matrix.json")
        try runGenerator(generator: generator, input: input, output: first)
        try runGenerator(generator: generator, input: input, output: second)

        let firstData = try Data(contentsOf: first)
        XCTAssertEqual(firstData, try Data(contentsOf: second))
        XCTAssertEqual(
            firstData,
            try Data(contentsOf: repoRoot.appendingPathComponent(
                "Core/Contracts/DemoCapabilityMatrix.generated.swift"
            ))
        )
    }

    private var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func loadSourceMatrix() throws -> SourceMatrix {
        let data = try Data(contentsOf: repoRoot.appendingPathComponent(
            "contracts/demo-capability-matrix.json"
        ))
        return try JSONDecoder().decode(SourceMatrix.self, from: data)
    }

    private func runGenerator(generator: URL, input: URL, output: URL) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        process.arguments = [
            generator.path,
            "--input",
            input.path,
            "--output",
            output.path,
        ]
        let errorPipe = Pipe()
        process.standardError = errorPipe
        try process.run()
        process.waitUntilExit()
        let stderr = String(
            decoding: errorPipe.fileHandleForReading.readDataToEndOfFile(),
            as: UTF8.self
        )
        XCTAssertEqual(process.terminationStatus, 0, stderr)
    }
}

private struct SourceMatrix: Decodable {
    var cells: [SourceCell]
}

private struct SourceCell: Decodable {
    var matrixID: Int
    var primaryClass: String
    var entrypointAliases: [String]
    var canDemo: Bool

    private enum CodingKeys: String, CodingKey {
        case matrixID = "matrix_id"
        case primaryClass = "primary_class"
        case entrypointAliases
        case canDemo
    }
}
