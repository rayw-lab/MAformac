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
        let context = C5DataGateRunContext(
            sourceSnapshotDigest: sourceDigest,
            sourceAuthorizationStatus: options.sourceAuthorizationStatus,
            formatContractVersion: formatDigest,
            generatedAt: isoNow()
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

    init(arguments: [String]) throws {
        repoRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        outputDir = repoRoot.appendingPathComponent("Reports/c5-data-gate").path
        candidatePaths = []
        sourceDigestPaths = []
        sourceAuthorizationStatus = "unknown"
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
            default:
                throw CLIError.usage("unknown argument \(argument)")
            }
        }
        if candidatePaths.isEmpty {
            throw CLIError.usage("usage: C5DataGateCLI --candidates PATH[,PATH...] [--repo-root PATH] [--source-digest-path PATH] [--source-authorization STATUS] [--output-dir PATH]")
        }
        if sourceDigestPaths.isEmpty {
            sourceDigestPaths = candidatePaths
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
