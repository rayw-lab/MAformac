import Foundation
import Darwin
import MAformacCore

@main
struct C5DataGateCLI {
    static func main() {
        do {
            let options = try Options(arguments: CommandLine.arguments)
            let receipt = try run(options: options)
            if receipt.status == "blocked" {
                exit(65)
            }
        } catch let error as CLIError {
            writeError(error.description)
            exit(64)
        } catch {
            writeError("error: \(error)")
            exit(1)
        }
    }

    private static func run(options: Options) throws -> C5DataGateReceipt {
        let repoRoot = options.repoRoot
        let c6Cases = try C6DatasetCodec().decodeJSONL(read(repoRoot, "contracts/c6-bench-cases.jsonl"))
        let candidates = try options.candidatePaths.flatMap { try loadCandidates(path: $0) }
        let formatDigest = try C6Hash.fileHash(url: repoRoot.appendingPathComponent("contracts/qwen-tool-call-format.yaml"))
        let sourceDigest = try sourceSnapshotDigest(paths: options.sourceDigestPaths)
        let toolSchemasByName = try options.dDomainToolCatalogPath.map { try loadToolSchemas(path: $0) } ?? [:]
        let surfaceManifest = try options.subsetPolicyManifestPath.map {
            try loadSurfaceManifest(path: $0, toolSchemasByName: toolSchemasByName)
        }
        let context = C5DataGateRunContext(
            sourceSnapshotDigest: sourceDigest,
            sourceAuthorizationStatus: options.sourceAuthorizationStatus,
            formatContractVersion: formatDigest,
            generatedAt: isoNow(),
            allowLegacyMissingSurface: options.allowLegacyMissingSurface,
            surfaceManifest: surfaceManifest
        )
        let validator = C5DataGateValidator()
        let receipt = validator.receipt(candidates: candidates, c6Cases: c6Cases, context: context)
        let outputDir = URL(fileURLWithPath: options.outputDir, isDirectory: true)
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        try encoder.encode(receipt).write(to: outputDir.appendingPathComponent("c5-data-gate-receipt.json"))
        try validator.renderMarkdown(receipt).write(to: outputDir.appendingPathComponent("c5-data-gate-receipt.md"), atomically: true, encoding: .utf8)
        print("wrote \(outputDir.appendingPathComponent("c5-data-gate-receipt.json").path)")
        print("wrote \(outputDir.appendingPathComponent("c5-data-gate-receipt.md").path)")
        print("status=\(receipt.status) rows=\(receipt.rowCount) must_not_train_violations=\(receipt.mustNotTrainViolations) train_parent_semantic_overlap=\(receipt.trainParentSemanticOverlap) quarantine=\(receipt.quarantineCount)")
        return receipt
    }

    private static func read(_ repoRoot: URL, _ path: String) throws -> String {
        try String(contentsOf: repoRoot.appendingPathComponent(path), encoding: .utf8)
    }

    private static func loadCandidates(path: String) throws -> [C5DataGateCandidate] {
        let text = try String(contentsOfFile: path, encoding: .utf8)
        let decoder = JSONDecoder()
        let hint = splitHint(for: path)
        return try text
            .split(whereSeparator: \.isNewline)
            .map {
                var candidate = try decoder.decode(C5DataGateCandidate.self, from: Data(String($0).utf8))
                if candidate.split == nil {
                    candidate.split = hint
                }
                return candidate
            }
    }

    private static func loadSurfaceManifest(
        path: String,
        toolSchemasByName: [String: [String: JSONValue]]
    ) throws -> C5DataGateSurfaceManifest {
        let url = URL(fileURLWithPath: path)
        let raw = try Data(contentsOf: url)
        let manifest = try JSONDecoder().decode(SubsetPolicyManifest.self, from: raw)
        return C5DataGateSurfaceManifest(
            manifestFileDigest: try C6Hash.fileHash(url: url),
            groupingContractDigest: manifest.meta.groupingContractDigest,
            entries: manifest.entries.map {
                C5DataGateSurfaceManifestEntry(
                    subsetPolicyID: $0.subsetPolicyID,
                    subsetGroupID: $0.groupID,
                    toolIDsOrdered: $0.toolIDsOrdered,
                    toolSchemaDigest: $0.toolSchemaDigest
                )
            },
            toolSchemasByName: toolSchemasByName
        )
    }

    private static func loadToolSchemas(path: String) throws -> [String: [String: JSONValue]] {
        let raw = try Data(contentsOf: URL(fileURLWithPath: path))
        let tools = try JSONDecoder().decode([[String: JSONValue]].self, from: raw)
        return Dictionary(uniqueKeysWithValues: tools.compactMap { tool in
            guard case .object(let function)? = tool["function"],
                  case .string(let name)? = function["name"],
                  case .string(let type)? = tool["type"] else {
                return nil
            }
            return (name, ["type": .string(type), "function": .object(function)])
        })
    }

    private static func splitHint(for path: String) -> String? {
        if path.contains("/datasets/train/") {
            return "train"
        }
        if path.contains("/datasets/heldout/") || path.contains("/datasets/negative/") {
            return "heldout"
        }
        if path.contains("/datasets/acceptance/") {
            return "must_pass"
        }
        if path.contains("/datasets/dev_selection/") {
            return "dev_selection"
        }
        if path.contains("/datasets/future/") {
            return "quarantine"
        }
        return nil
    }

    private static func sourceSnapshotDigest(paths: [String]) throws -> String {
        guard !paths.isEmpty else {
            return ""
        }
        var data = Data()
        for path in paths.sorted() {
            let url = URL(fileURLWithPath: path)
            var isDirectory: ObjCBool = false
            guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
                throw CLIError.usage("source digest path not found: \(path)")
            }
            if isDirectory.boolValue {
                let files = try recursiveFiles(url)
                for file in files {
                    data.append(Data(file.path.utf8))
                    data.append(try Data(contentsOf: file))
                }
            } else {
                data.append(Data(url.path.utf8))
                data.append(try Data(contentsOf: url))
            }
        }
        return C6Hash.sha256Hex(data)
    }

    private static func recursiveFiles(_ root: URL) throws -> [URL] {
        guard let enumerator = FileManager.default.enumerator(
            at: root,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }
        var files: [URL] = []
        for case let url as URL in enumerator {
            let values = try url.resourceValues(forKeys: [.isRegularFileKey])
            if values.isRegularFile == true {
                files.append(url)
            }
        }
        return files.sorted { $0.path < $1.path }
    }

    private static func isoNow() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: Date())
    }

    private static func writeError(_ text: String) {
        guard let data = "\(text)\n".data(using: .utf8) else {
            return
        }
        FileHandle.standardError.write(data)
    }
}

private struct Options {
    var repoRoot: URL
    var outputDir: String
    var candidatePaths: [String]
    var sourceDigestPaths: [String]
    var sourceAuthorizationStatus: String
    var allowLegacyMissingSurface: Bool
    var subsetPolicyManifestPath: String?
    var dDomainToolCatalogPath: String?

    init(arguments: [String]) throws {
        repoRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        outputDir = repoRoot.appendingPathComponent("Reports/c5-data-gate").path
        candidatePaths = []
        sourceDigestPaths = []
        sourceAuthorizationStatus = "unknown"
        allowLegacyMissingSurface = false
        subsetPolicyManifestPath = nil
        dDomainToolCatalogPath = nil
        var iterator = arguments.dropFirst().makeIterator()
        while let argument = iterator.next() {
            switch argument {
            case "--repo-root":
                guard let value = iterator.next() else { throw CLIError.usage("missing --repo-root value") }
                repoRoot = URL(fileURLWithPath: value, isDirectory: true)
            case "--candidates":
                guard let value = iterator.next() else { throw CLIError.usage("missing --candidates value") }
                candidatePaths.append(contentsOf: value.split(separator: ",").map(String.init))
            case "--source-digest-path":
                guard let value = iterator.next() else { throw CLIError.usage("missing --source-digest-path value") }
                sourceDigestPaths.append(value)
            case "--source-authorization":
                guard let value = iterator.next() else { throw CLIError.usage("missing --source-authorization value") }
                sourceAuthorizationStatus = value
            case "--output-dir":
                guard let value = iterator.next() else { throw CLIError.usage("missing --output-dir value") }
                outputDir = value
            case "--subset-policy-manifest-path":
                guard let value = iterator.next() else { throw CLIError.usage("missing --subset-policy-manifest-path value") }
                subsetPolicyManifestPath = value
            case "--d-domain-tool-catalog-path":
                guard let value = iterator.next() else { throw CLIError.usage("missing --d-domain-tool-catalog-path value") }
                dDomainToolCatalogPath = value
            case "--allow-legacy-missing-surface":
                allowLegacyMissingSurface = true
            default:
                throw CLIError.usage("unknown argument \(argument)")
            }
        }
        if candidatePaths.isEmpty {
            throw CLIError.usage("usage: C5DataGateCLI --candidates PATH[,PATH...] [--repo-root PATH] [--source-digest-path PATH] [--source-authorization STATUS] [--output-dir PATH] [--subset-policy-manifest-path PATH] [--d-domain-tool-catalog-path PATH] [--allow-legacy-missing-surface]")
        }
        if sourceDigestPaths.isEmpty {
            sourceDigestPaths = candidatePaths
        }
        let defaultManifestPath = repoRoot.appendingPathComponent("generated/subset-policy-manifest.json").path
        if subsetPolicyManifestPath == nil && FileManager.default.fileExists(atPath: defaultManifestPath) {
            subsetPolicyManifestPath = defaultManifestPath
        }
        let defaultCatalogPath = repoRoot.appendingPathComponent("generated/D_domain.tools.demo.json").path
        if dDomainToolCatalogPath == nil && FileManager.default.fileExists(atPath: defaultCatalogPath) {
            dDomainToolCatalogPath = defaultCatalogPath
        }
    }
}

private struct SubsetPolicyManifest: Decodable {
    var meta: Meta
    var entries: [Entry]

    struct Meta: Decodable {
        var groupingContractDigest: String

        enum CodingKeys: String, CodingKey {
            case groupingContractDigest = "grouping_contract_digest"
        }
    }

    struct Entry: Decodable {
        var subsetPolicyID: String
        var groupID: String
        var toolIDsOrdered: [String]
        var toolSchemaDigest: String

        enum CodingKeys: String, CodingKey {
            case subsetPolicyID = "subset_policy_id"
            case groupID = "group_id"
            case toolIDsOrdered = "tool_ids_ordered"
            case toolSchemaDigest = "tool_schema_digest"
        }
    }
}

private enum CLIError: Error, CustomStringConvertible {
    case usage(String)

    var description: String {
        switch self {
        case .usage(let text):
            return text
        }
    }
}
