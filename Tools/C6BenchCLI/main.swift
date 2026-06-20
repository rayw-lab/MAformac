import Foundation
import Darwin
import MAformacCore

@main
struct C6BenchCLI {
    static func main() {
        do {
            try run()
        } catch let error as CLIError {
            writeError(error.description)
            exit(64)
        } catch {
            writeError("error: \(error)")
            exit(1)
        }
    }

    private static func run() throws {
        let options = try Options(arguments: CommandLine.arguments)
        switch options.command {
        case "generate":
            try generate(options)
        case "summarize":
            try summarize(options)
        default:
            throw CLIError.usage("unknown command: \(options.command)")
        }
    }

    private static func writeError(_ text: String) {
        guard let data = "\(text)\n".data(using: .utf8) else {
            return
        }
        FileHandle.standardError.write(data)
    }

    private static func generate(_ options: Options) throws {
        let repoRoot = options.repoRoot
        let generator = try makeGenerator(repoRoot: repoRoot)
        let cases = try generator.generate()
        let validation = generator.validate(cases)
        guard validation.isValid else {
            throw CLIError.usage("dataset validation failed: \(validation)")
        }
        let text = try C6DatasetCodec().encodeJSONL(cases)
        let output = repoRoot.appendingPathComponent("contracts/c6-bench-cases.jsonl")
        try text.write(to: output, atomically: true, encoding: .utf8)
        print("wrote \(output.path)")
        print(String(format: "cases=%d negative_ratio=%.3f source_refs_unresolved=%d must_pass=%d represented_devices=%d/%d",
                     validation.caseCount,
                     validation.negativeRatio,
                     validation.unresolvedSourceRefCount,
                     validation.mustPassCount,
                     validation.representedDevices,
                     validation.totalContractDevices))
    }

    private static func summarize(_ options: Options) throws {
        let repoRoot = options.repoRoot
        guard let modelResultsPath = options.modelResultsPath else {
            throw CLIError.usage("summarize requires --model-results")
        }
        guard let modelArtifactPath = options.modelArtifactPath else {
            throw CLIError.usage("summarize requires --model-artifact PATH")
        }
        guard let tokenizerArtifactPath = options.tokenizerArtifactPath else {
            throw CLIError.usage("summarize requires --tokenizer-artifact PATH")
        }
        let datasetText = try String(contentsOf: repoRoot.appendingPathComponent("contracts/c6-bench-cases.jsonl"), encoding: .utf8)
        let cases = try C6DatasetCodec().decodeJSONL(datasetText)
        let generator = try makeGenerator(repoRoot: repoRoot)
        let validation = generator.validate(cases)
        let qwenHash = try C6Hash.fileHash(url: repoRoot.appendingPathComponent("contracts/qwen-tool-call-format.yaml"))
        let contractDigest = try C6Hash.contractDigest(repoRoot: repoRoot, datasetText: datasetText)
        let envelope = try SpikeE3Envelope.load(url: URL(fileURLWithPath: modelResultsPath))
        let modelArtifactDigest = try artifactDigest(path: modelArtifactPath, flag: "--model-artifact")
        let tokenizerDigest = try artifactDigest(path: tokenizerArtifactPath, flag: "--tokenizer-artifact")
        let loraAdapterDigest = try options.loraAdapterPath.map {
            try artifactDigest(path: $0, flag: "--lora-adapter")
        } ?? ""
        let loraAdapterID = envelope.loraAdapterID ?? ""
        let loraCheckpointID = envelope.loraCheckpointID ?? ""
        if loraAdapterDigest.isEmpty && (!loraAdapterID.isEmpty || !loraCheckpointID.isEmpty) {
            throw CLIError.usage("summarize requires --lora-adapter when model results carry LoRA identifiers")
        }
        let runner = C6BenchRunner(
            qwenToolCallFormatVersion: qwenHash,
            contractDigest: contractDigest,
            modelID: envelope.modelID,
            modelArtifactDigest: modelArtifactDigest,
            tokenizerDigest: tokenizerDigest,
            loraAdapterDigest: loraAdapterDigest,
            loraAdapterID: loraAdapterID,
            loraCheckpointID: loraCheckpointID,
            stateCells: generator.stateCells
        )
        let caseByID = Dictionary(uniqueKeysWithValues: cases.map { ($0.caseID, $0) })
        var runCounters: [String: Int] = [:]
        var runs: [C6EvalRun] = []
        for result in envelope.results {
            guard let item = caseByID[result.id] else {
                continue
            }
            let index = result.runIndex ?? runCounters[result.id, default: 0]
            runCounters[result.id, default: 0] += 1
            let output = C6RuntimeOutput(
                toolCalls: result.toolCalls.map { C6ToolCall(name: $0.name, arguments: $0.stringArguments) },
                text: result.chunkText,
                parserFailure: result.contentLooksLikeToolCall || result.thinkLeak,
                elapsedMs: result.elapsedMs,
                samplingSeed: "\(index)"
            )
            runs.append(try runner.evaluate(case: item, output: output, runIndex: index))
        }
        let summary = runner.summarize(cases: cases, runs: runs, validation: validation)
        let outputDir = URL(fileURLWithPath: options.outputDir, isDirectory: true)
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let jsonURL = outputDir.appendingPathComponent("c6-summary.json")
        try encoder.encode(summary).write(to: jsonURL)
        let markdownURL = outputDir.appendingPathComponent("c6-summary.md")
        try renderMarkdown(summary: summary, validation: validation).write(to: markdownURL, atomically: true, encoding: .utf8)
        print("wrote \(jsonURL.path)")
        print("wrote \(markdownURL.path)")
        print("status=\(summary.status) runs=\(summary.totalRuns) cases=\(summary.totalCases) IrrelAcc=\(String(format: "%.3f", summary.IrrelAcc)) hard_failures=\(summary.hardFailureCount)")
    }

    private static func makeGenerator(repoRoot: URL) throws -> C6DatasetGenerator {
        C6DatasetGenerator(
            semantic: try SemanticContractLookup(jsonl: read(repoRoot, "contracts/semantic-function-contract.jsonl")),
            stateCells: try StateCellContractLookup(yaml: read(repoRoot, "contracts/state-cells.yaml")),
            demoScenariosYAML: try read(repoRoot, "contracts/demo-scenarios.yaml"),
            riskPolicyYAML: try read(repoRoot, "contracts/risk-policy.yaml")
        )
    }

    private static func read(_ repoRoot: URL, _ path: String) throws -> String {
        try String(contentsOf: repoRoot.appendingPathComponent(path), encoding: .utf8)
    }

    private static func artifactDigest(path: String, flag: String) throws -> String {
        let url = URL(fileURLWithPath: path)
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            throw CLIError.usage("\(flag) not found: \(path)")
        }
        guard !isDirectory.boolValue else {
            throw CLIError.usage("\(flag) must be a file; directories are not supported: \(path)")
        }
        return try C6Hash.fileHash(url: url)
    }

    private static func renderMarkdown(summary: C6Summary, validation: C6DatasetValidation) -> String {
        """
        # C6 vehicle-tool-bench summary

        status: \(summary.status)
        model_id: \(summary.modelID)
        model_artifact_digest: \(summary.modelArtifactDigest)
        tokenizer_digest: \(summary.tokenizerDigest)
        lora_adapter_id: "\(summary.loraAdapterID)"
        lora_checkpoint_id: "\(summary.loraCheckpointID)"
        lora_adapter_digest: "\(summary.loraAdapterDigest)"
        qwen_tool_call_format_version: \(summary.qwenToolCallFormatVersion)
        contract_digest: \(summary.contractDigest)

        ## Dataset
        - cases: \(validation.caseCount)
        - no_call_negative_ratio: \(String(format: "%.3f", validation.negativeRatio))
        - source_refs_unresolved: \(validation.unresolvedSourceRefCount)
        - must_pass: \(validation.mustPassCount)
        - represented_devices: \(validation.representedDevices)/\(validation.totalContractDevices)

        ## Gates
        - total_runs: \(summary.totalRuns)
        - hard_failure_count: \(summary.hardFailureCount)
        - no_tool_false_positive_count: \(summary.noToolFalsePositiveCount)
        - IrrelAcc: \(String(format: "%.3f", summary.IrrelAcc)) / threshold \(String(format: "%.2f", summary.IrrelAccThreshold))

        ## Axes
        - contract_coverage_score: \(String(format: "%.4f", summary.contractCoverageScore))
        - scenario_score: \(String(format: "%.4f", summary.scenarioScore))

        ## Per-case mean/variance
        \(summary.perCaseStats.map { "- \($0.caseID): runs=\($0.runCount), hard_pass_mean=\(String(format: "%.3f", $0.hardPassMean)), hard_pass_variance=\(String(format: "%.3f", $0.hardPassVariance)), elapsed_mean_ms=\(String(format: "%.1f", $0.elapsedMeanMs)), elapsed_variance_ms=\(String(format: "%.1f", $0.elapsedVarianceMs))" }.joined(separator: "\n"))
        """
    }
}

private struct Options {
    var command: String
    var repoRoot: URL
    var outputDir: String
    var modelResultsPath: String?
    var modelArtifactPath: String?
    var tokenizerArtifactPath: String?
    var loraAdapterPath: String?

    init(arguments: [String]) throws {
        guard arguments.count >= 2 else {
            throw CLIError.usage("usage: C6BenchCLI <generate|summarize> [--repo-root PATH] [--model-results PATH] [--model-artifact PATH] [--tokenizer-artifact PATH] [--lora-adapter PATH] [--output-dir PATH]")
        }
        command = arguments[1]
        repoRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        outputDir = repoRoot.appendingPathComponent("Reports/c6-base").path
        var iterator = arguments.dropFirst(2).makeIterator()
        while let argument = iterator.next() {
            switch argument {
            case "--repo-root":
                guard let value = iterator.next() else { throw CLIError.usage("missing --repo-root value") }
                repoRoot = URL(fileURLWithPath: value, isDirectory: true)
            case "--model-results":
                guard let value = iterator.next() else { throw CLIError.usage("missing --model-results value") }
                modelResultsPath = value
            case "--model-artifact":
                guard let value = iterator.next() else { throw CLIError.usage("missing --model-artifact value") }
                modelArtifactPath = value
            case "--tokenizer-artifact":
                guard let value = iterator.next() else { throw CLIError.usage("missing --tokenizer-artifact value") }
                tokenizerArtifactPath = value
            case "--lora-adapter":
                guard let value = iterator.next() else { throw CLIError.usage("missing --lora-adapter value") }
                loraAdapterPath = value
            case "--output-dir":
                guard let value = iterator.next() else { throw CLIError.usage("missing --output-dir value") }
                outputDir = value
            default:
                throw CLIError.usage("unknown argument \(argument)")
            }
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

private struct SpikeE3Envelope: Decodable {
    var modelID: String
    var loraAdapterID: String?
    var loraCheckpointID: String?
    var results: [SpikeE3CaseResult]

    static func load(url: URL) throws -> SpikeE3Envelope {
        try JSONDecoder().decode(SpikeE3Envelope.self, from: Data(contentsOf: url))
    }
}

private struct SpikeE3CaseResult: Decodable {
    var id: String
    var runIndex: Int?
    var toolCalls: [SpikeE3ToolCall]
    var chunkText: String
    var contentLooksLikeToolCall: Bool
    var thinkLeak: Bool
    var elapsedMs: Int
}

private struct SpikeE3ToolCall: Decodable {
    var name: String
    var arguments: [String: LooseJSON]

    var stringArguments: [String: String] {
        arguments.mapValues(\.stringValue)
    }
}

private enum LooseJSON: Decodable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case object
    case array
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Double.self) {
            self = .number(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if (try? container.decode([String: LooseJSON].self)) != nil {
            self = .object
        } else if (try? container.decode([LooseJSON].self)) != nil {
            self = .array
        } else {
            self = .null
        }
    }

    var stringValue: String {
        switch self {
        case .string(let value):
            return value
        case .number(let value):
            if value.rounded() == value {
                return String(Int(value))
            }
            return String(value)
        case .bool(let value):
            return value ? "true" : "false"
        case .object:
            return "{}"
        case .array:
            return "[]"
        case .null:
            return ""
        }
    }
}
