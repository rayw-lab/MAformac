import Foundation
import Darwin
import MAformacCore

@main
struct C5TrainingCLI {
    static func main() {
        do {
            let options = try Options(arguments: CommandLine.arguments)
            switch options.command {
            case "prepare":
                try prepare(options)
            default:
                throw CLIError.usage("unknown command: \(options.command)")
            }
        } catch let error as CLIError {
            writeError(error.description)
            exit(64)
        } catch {
            writeError("error: \(error)")
            exit(1)
        }
    }

    private static func prepare(_ options: Options) throws {
        let repoRoot = options.repoRoot
        let outputDir = URL(fileURLWithPath: options.outputDir, isDirectory: true)
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
        let patchedModelDir = outputDir.appendingPathComponent("qwen3-1_7b-training-tokenizer-patched", isDirectory: true)
        try createTrainingTokenizerPatch(sourceDir: options.baseModelDir, outputDir: patchedModelDir)
        let semanticText = try read(repoRoot, "contracts/semantic-function-contract.jsonl")
        let seeds = try decodeJSONL(semanticText, as: C5SemanticSeed.self)
        let c6Cases = try C6DatasetCodec().decodeJSONL(read(repoRoot, "contracts/c6-bench-cases.jsonl"))
        let formatDigest = try C6Hash.fileHash(url: repoRoot.appendingPathComponent("contracts/qwen-tool-call-format.yaml"))
        let semanticDigest = C6Hash.sha256Hex(Data(semanticText.utf8))
        let generatedAt = isoNow()
        let context = C5DataGateRunContext(
            sourceSnapshotDigest: semanticDigest,
            sourceAuthorizationStatus: "authorized_c1_semantic_contract",
            formatContractVersion: formatDigest,
            generatedAt: generatedAt
        )
        let buildOptions = C5TrainingBuildOptions(
            targetPositiveRows: options.targetPositiveRows,
            devSelectionRows: options.devSelectionRows,
            maskingStage: options.maskingStage,
            usesTrainingTokenizerPatch: true,
            modelOverride: patchedModelDir.path,
            generatedAt: generatedAt
        )
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: c6Cases,
            dataGateContext: context,
            options: buildOptions
        )
        let samplesDir = outputDir.appendingPathComponent("samples", isDirectory: true)
        let mlxDir = outputDir.appendingPathComponent("mlx-data", isDirectory: true)
        try FileManager.default.createDirectory(at: samplesDir, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: mlxDir, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        try writeJSONL(prepared.samples, encoder: encoder, url: samplesDir.appendingPathComponent("c5-training-samples.jsonl"))
        try writeJSONL(prepared.samples.filter { $0.split == "train" && $0.trainEligible }.map(\.mlxRecord), encoder: encoder, url: mlxDir.appendingPathComponent("train.jsonl"))
        try writeJSONL(prepared.samples.filter { $0.split == "dev_selection" }.map(\.mlxRecord), encoder: encoder, url: mlxDir.appendingPathComponent("valid.jsonl"))
        try writeJSONL(prepared.samples.filter { $0.split == "dev_selection" }.prefix(128).map(\.mlxRecord), encoder: encoder, url: mlxDir.appendingPathComponent("test.jsonl"))
        let prettyEncoder = JSONEncoder()
        prettyEncoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        try prettyEncoder.encode(prepared.receipt).write(to: outputDir.appendingPathComponent("c5-training-receipt.json"))
        try renderMarkdown(receipt: prepared.receipt).write(to: outputDir.appendingPathComponent("c5-training-receipt.md"), atomically: true, encoding: .utf8)
        try prepared.receipt.mlxConfig.renderYAML.write(to: outputDir.appendingPathComponent("mlx-lora-config.yaml"), atomically: true, encoding: .utf8)
        try renderTrainCommand(outputDir: outputDir, config: prepared.receipt.mlxConfig).write(to: outputDir.appendingPathComponent("mlx-train-command.txt"), atomically: true, encoding: .utf8)
        print("wrote \(outputDir.appendingPathComponent("c5-training-receipt.json").path)")
        print("wrote \(outputDir.appendingPathComponent("mlx-data/train.jsonl").path)")
        print("status=\(prepared.receipt.status) rows=\(prepared.receipt.rowCount) train_eligible=\(prepared.receipt.trainEligibleCount) dev_selection=\(prepared.receipt.devSelectionCount) refusal_ratio=\(String(format: "%.3f", prepared.receipt.refusalRatioObserved))")
        if prepared.receipt.status == "blocked" {
            exit(65)
        }
    }

    private static func read(_ repoRoot: URL, _ path: String) throws -> String {
        try String(contentsOf: repoRoot.appendingPathComponent(path), encoding: .utf8)
    }

    private static func decodeJSONL<T: Decodable>(_ text: String, as type: T.Type) throws -> [T] {
        let decoder = JSONDecoder()
        return try text.split(whereSeparator: \.isNewline).map {
            try decoder.decode(T.self, from: Data(String($0).utf8))
        }
    }

    private static func writeJSONL<T: Encodable>(_ values: [T], encoder: JSONEncoder, url: URL) throws {
        let lines = try values.map { value in
            String(decoding: try encoder.encode(value), as: UTF8.self)
        }
        try (lines.joined(separator: "\n") + "\n").write(to: url, atomically: true, encoding: .utf8)
    }

    private static func renderTrainCommand(outputDir: URL, config: C5MLXLoRAConfig) -> String {
        """
        /Users/wanglei/Library/Python/3.13/bin/mlx_lm.lora \\
          --train \\
          --model \(config.model) \\
          --data \(outputDir.appendingPathComponent("mlx-data").path) \\
          --config \(outputDir.appendingPathComponent("mlx-lora-config.yaml").path) \\
          --mask-prompt \\
          --num-layers \(config.numLayers) \\
          --batch-size \(config.batchSize) \\
          --grad-accumulation-steps \(config.gradAccumulationSteps) \\
          --iters 600 \\
          --learning-rate \(config.learningRate) \\
          --max-seq-length \(config.maxSeqLength) \\
          --adapter-path \(outputDir.appendingPathComponent("adapters-rank16").path)
        """
    }

    private static func renderMarkdown(receipt: C5TrainingReceipt) -> String {
        """
        # C5 LoRA training receipt

        status: \(receipt.status)
        receipt_version: \(receipt.receiptVersion)
        generated_at: \(receipt.generatedAt)
        acceptance_stage: \(receipt.acceptanceStage.rawValue)

        ## Data
        - row_count: \(receipt.rowCount)
        - train_eligible_count: \(receipt.trainEligibleCount)
        - dev_selection_count: \(receipt.devSelectionCount)
        - route_tier_counts: \(receipt.routeTierCounts.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value)" }.joined(separator: ", "))
        - masking_stage_counts: \(receipt.maskingStageCounts.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value)" }.joined(separator: ", "))
        - rehearsal_ratio: \(String(format: "%.4f", receipt.rehearsalRatio))
        - refusal_ratio_observed: \(String(format: "%.4f", receipt.refusalRatioObserved))
        - refusal_ratio_target: \(receipt.refusalRatioTarget)
        - refusal_ratio_hard_cap: \(receipt.refusalRatioHardCap)
        - prompt_distractor_count: \(receipt.promptDistractorCount)

        ## Gates
        - data_gate_status: \(receipt.dataGateReceipt.status)
        - offset_fixture: \(receipt.offsetFixture.status)
        - generator_orchestration: \(receipt.generatorOrchestration.status)
        - validator_layer1: \(receipt.validatorSummary.layer1RuleStatus)
        - validator_layer2: \(receipt.validatorSummary.layer2SemanticStatus)
        - lineage_reassignment: \(receipt.lineageSummary.candidateSemanticReassignmentStatus)
        - masking_coverage: train_on_turn=\(receipt.maskingCoverage.trainOnTurn), function_name=\(receipt.maskingCoverage.functionName), argument_name=\(receipt.maskingCoverage.argumentName), argument_value=\(receipt.maskingCoverage.argumentValue)
        - diagnostic_verdict: \(receipt.generalizationDiagnostic.diagnosticVerdict)
        - fuse_parity_gate: \(receipt.fuseParityGate.status)

        ## Failure receipt
        \(receipt.failureReceipt.map { "- \($0)" }.joined(separator: "\n"))
        """
    }

    private static func isoNow() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: Date())
    }

    private static func createTrainingTokenizerPatch(sourceDir: URL, outputDir: URL) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: outputDir.path) {
            try fileManager.removeItem(at: outputDir)
        }
        try fileManager.createDirectory(at: outputDir, withIntermediateDirectories: true)
        let children = try fileManager.contentsOfDirectory(at: sourceDir, includingPropertiesForKeys: nil)
        for child in children {
            let destination = outputDir.appendingPathComponent(child.lastPathComponent)
            if child.lastPathComponent == "tokenizer_config.json" {
                let data = try Data(contentsOf: child)
                guard var object = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let template = object["chat_template"] as? String else {
                    throw CLIError.usage("tokenizer_config.json missing chat_template")
                }
                let old = "{%- if enable_thinking is defined and enable_thinking is false %}"
                let new = "{%- if enable_thinking is not defined or enable_thinking is false %}"
                guard template.contains(old) else {
                    throw CLIError.usage("tokenizer chat_template enable_thinking condition not found")
                }
                object["chat_template"] = template.replacingOccurrences(of: old, with: new, options: [], range: template.range(of: old))
                let patched = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys])
                try patched.write(to: destination)
            } else {
                try fileManager.createSymbolicLink(at: destination, withDestinationURL: child.resolvingSymlinksInPath())
            }
        }
    }

    private static func writeError(_ text: String) {
        guard let data = "\(text)\n".data(using: .utf8) else {
            return
        }
        FileHandle.standardError.write(data)
    }
}

private struct Options {
    var command: String
    var repoRoot: URL
    var outputDir: String
    var targetPositiveRows: Int
    var devSelectionRows: Int
    var maskingStage: C5MaskingStage
    var baseModelDir: URL

    init(arguments: [String]) throws {
        guard arguments.count >= 2 else {
            throw CLIError.usage("usage: C5TrainingCLI prepare [--repo-root PATH] [--output-dir PATH] [--target-positive N] [--dev-selection N] [--masking-stage STAGE] [--base-model-dir PATH]")
        }
        command = arguments[1]
        repoRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        outputDir = repoRoot.appendingPathComponent("Reports/c5-lora-training").path
        targetPositiveRows = 4_500
        devSelectionRows = 400
        maskingStage = .trainableV0
        baseModelDir = URL(fileURLWithPath: "/Users/wanglei/.cache/huggingface/hub/models--mlx-community--Qwen3-1.7B-4bit/snapshots/3b1b1768f8f8cf8351c712464f906e86c2b8269e", isDirectory: true)
        var iterator = arguments.dropFirst(2).makeIterator()
        while let argument = iterator.next() {
            switch argument {
            case "--repo-root":
                guard let value = iterator.next() else { throw CLIError.usage("missing --repo-root value") }
                repoRoot = URL(fileURLWithPath: value, isDirectory: true)
            case "--output-dir":
                guard let value = iterator.next() else { throw CLIError.usage("missing --output-dir value") }
                outputDir = value
            case "--target-positive":
                guard let value = iterator.next(), let intValue = Int(value) else { throw CLIError.usage("invalid --target-positive value") }
                targetPositiveRows = intValue
            case "--dev-selection":
                guard let value = iterator.next(), let intValue = Int(value) else { throw CLIError.usage("invalid --dev-selection value") }
                devSelectionRows = intValue
            case "--masking-stage":
                guard let value = iterator.next(), let stage = C5MaskingStage(rawValue: value) else { throw CLIError.usage("invalid --masking-stage value") }
                maskingStage = stage
            case "--base-model-dir":
                guard let value = iterator.next() else { throw CLIError.usage("missing --base-model-dir value") }
                baseModelDir = URL(fileURLWithPath: value, isDirectory: true)
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
