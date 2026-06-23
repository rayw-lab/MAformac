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
        let generatedUtterances = try options.generatedUtterancesURL.map { try decodeJSONL(String(contentsOf: $0, encoding: .utf8), as: C5GeneratedUtteranceRecord.self) } ?? []
        let c6Cases = try C6DatasetCodec().decodeJSONL(read(repoRoot, "contracts/c6-bench-cases.jsonl"))
        let formatDigest = try C6Hash.fileHash(url: repoRoot.appendingPathComponent("contracts/qwen-tool-call-format.yaml"))
        let semanticDigest = C6Hash.sha256Hex(Data(semanticText.utf8))
        let generatedAt = isoNow()
        let environment = buildEnvironment(
            repoRoot: repoRoot,
            baseModelDir: options.baseModelDir,
            modelID: patchedModelDir.path,
            seed: 0
        )
        let context = C5DataGateRunContext(
            sourceSnapshotDigest: semanticDigest,
            sourceAuthorizationStatus: "authorized_c1_semantic_contract",
            formatContractVersion: formatDigest,
            generatedAt: generatedAt
        )
        var buildOptions = C5TrainingBuildOptions(
            targetPositiveRows: options.targetPositiveRows,
            devSelectionRows: options.devSelectionRows,
            refusalRatioTarget: options.thetaAlphaPositiveOnly ? 0 : 0.10,
            refusalRatioHardCap: options.thetaAlphaPositiveOnly ? 0 : 0.20,
            includeNoCallCounterfactuals: !options.thetaAlphaPositiveOnly,
            maskingStage: options.maskingStage,
            usesTrainingTokenizerPatch: true,
            modelOverride: patchedModelDir.path,
            generatedAt: generatedAt,
            environment: environment,
            expectedOffsetArtifactSHA256: options.expectedOffsetArtifactSHA256,
            allowRegeneratedOffsetArtifact: options.allowRegeneratedOffsetArtifact,
            requireCandidateDataQualityGate: options.requireCandidateDataQualityGate,
            requireGeneratedUtteranceRecords: options.requireGeneratedUtteranceRecords,
            generatedUtteranceRecords: generatedUtterances
        )
        let builder = C5TrainingDatasetBuilder()
        var prepared = builder.build(
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
        let samplesURL = samplesDir.appendingPathComponent("c5-training-samples.jsonl")
        try writeJSONL(prepared.samples, encoder: encoder, url: samplesURL)
        let offsetArtifactURL = outputDir.appendingPathComponent("offset-fixture/mlx-mask-offset-fixture.json")
        let offsetArtifact = try generateMaskOffsetArtifact(
            repoRoot: repoRoot,
            modelDir: patchedModelDir,
            samplesURL: samplesURL,
            outputURL: offsetArtifactURL
        )
        buildOptions = C5TrainingBuildOptions(
            targetPositiveRows: options.targetPositiveRows,
            devSelectionRows: options.devSelectionRows,
            refusalRatioTarget: options.thetaAlphaPositiveOnly ? 0 : 0.10,
            refusalRatioHardCap: options.thetaAlphaPositiveOnly ? 0 : 0.20,
            includeNoCallCounterfactuals: !options.thetaAlphaPositiveOnly,
            maskingStage: options.maskingStage,
            usesTrainingTokenizerPatch: true,
            modelOverride: patchedModelDir.path,
            generatedAt: generatedAt,
            environment: environment,
            offsetTokenArtifact: offsetArtifact,
            expectedOffsetArtifactSHA256: options.expectedOffsetArtifactSHA256,
            allowRegeneratedOffsetArtifact: options.allowRegeneratedOffsetArtifact,
            requireCandidateDataQualityGate: options.requireCandidateDataQualityGate,
            requireGeneratedUtteranceRecords: options.requireGeneratedUtteranceRecords,
            generatedUtteranceRecords: generatedUtterances
        )
        prepared = builder.build(
            seeds: seeds,
            c6Cases: c6Cases,
            dataGateContext: context,
            options: buildOptions
        )
        try writeJSONL(prepared.samples, encoder: encoder, url: samplesURL)
        let trainRecords = prepared.samples.filter { sample in
            sample.split == "train" && (sample.trainEligible || options.maskingStage == .smokeOnly)
        }
        try writeJSONL(trainRecords.map(\.mlxRecord), encoder: encoder, url: mlxDir.appendingPathComponent("train.jsonl"))
        try writeJSONL(prepared.samples.filter { $0.split == "dev_selection" }.map(\.mlxRecord), encoder: encoder, url: mlxDir.appendingPathComponent("valid.jsonl"))
        try writeJSONL(prepared.samples.filter { $0.split == "dev_selection" }.prefix(128).map(\.mlxRecord), encoder: encoder, url: mlxDir.appendingPathComponent("test.jsonl"))
        let prettyEncoder = JSONEncoder()
        prettyEncoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        try prettyEncoder.encode(prepared.receipt).write(to: outputDir.appendingPathComponent("c5-training-receipt.json"))
        try renderMarkdown(receipt: prepared.receipt).write(to: outputDir.appendingPathComponent("c5-training-receipt.md"), atomically: true, encoding: .utf8)
        try prepared.receipt.mlxConfig.renderYAML.write(to: outputDir.appendingPathComponent("mlx-lora-config.yaml"), atomically: true, encoding: .utf8)
        try renderTrainCommand(repoRoot: repoRoot, outputDir: outputDir, config: prepared.receipt.mlxConfig).write(to: outputDir.appendingPathComponent("mlx-train-command.txt"), atomically: true, encoding: .utf8)
        print("wrote \(outputDir.appendingPathComponent("c5-training-receipt.json").path)")
        print("wrote \(outputDir.appendingPathComponent("mlx-data/train.jsonl").path)")
        print("status=\(prepared.receipt.status) rows=\(prepared.receipt.rowCount) train_eligible=\(prepared.receipt.trainEligibleCount) smoke_chain_records=\(prepared.receipt.smokeChainRecordCount) dev_selection=\(prepared.receipt.devSelectionCount) refusal_ratio=\(String(format: "%.3f", prepared.receipt.refusalRatioObserved))")
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
        let payload = lines.isEmpty ? "" : lines.joined(separator: "\n") + "\n"
        try payload.write(to: url, atomically: true, encoding: .utf8)
    }

    private static func renderTrainCommand(repoRoot: URL, outputDir: URL, config: C5MLXLoRAConfig) -> String {
        """
        /opt/homebrew/opt/python@3.13/bin/python3.13 \\
          \(repoRoot.appendingPathComponent("Tools/C5TrainingCLI/c5_mlx_train_loop.py").path) \\
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
          --seed \(config.seed) \\
          --max-seq-length \(config.maxSeqLength) \\
          --grad-clip-norm \(config.gradClipNorm) \\
          --nonfinite-fallback-lr 5e-5 \\
          --metrics-jsonl \(outputDir.appendingPathComponent("metrics.jsonl").path) \\
          --source-snapshot-output \(outputDir.appendingPathComponent("c5_mlx_train_loop.snapshot.py").path) \\
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
        - smoke_chain_record_count: \(receipt.smokeChainRecordCount)
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
        - offset_fixture_artifact: \(receipt.offsetFixture.tokenArtifact?.artifactPath ?? "missing")
        - offset_fixture_artifact_sha256: \(receipt.offsetFixture.tokenArtifact?.artifactSHA256 ?? "missing")
        - offset_artifact_authority: \(receipt.offsetArtifactAuthority.status)
        - offset_artifact_authority_mode: \(receipt.offsetArtifactAuthority.authorityMode)
        - offset_artifact_authority_approved_sha256: \(receipt.offsetArtifactAuthority.approvedArtifactSHA256 ?? "missing")
        - offset_artifact_authority_observed_sha256: \(receipt.offsetArtifactAuthority.observedArtifactSHA256 ?? "missing")
        - offset_artifact_authority_observed_path: \(receipt.offsetArtifactAuthority.observedArtifactPath ?? "missing")
        - offset_artifact_same_path_regeneration_required: \(receipt.offsetArtifactAuthority.samePathRegenerationRequired)
        - offset_artifact_same_path_regeneration_observed: \(receipt.offsetArtifactAuthority.samePathRegenerationObserved)
        - generator_orchestration: \(receipt.generatorOrchestration.status)
        - validator_layer1: \(receipt.validatorSummary.layer1RuleStatus)
        - validator_layer2: \(receipt.validatorSummary.layer2SemanticStatus)
        - lineage_reassignment: \(receipt.lineageSummary.candidateSemanticReassignmentStatus)
        - scale_authority: \(receipt.scaleAuthorityResolution.status)
        - scale_first_candidate: \(receipt.scaleAuthorityResolution.firstCandidateScale)
        - scale_observed: \(receipt.scaleAuthorityResolution.observedScale)
        - scale_source_ref: \(receipt.scaleAuthorityResolution.sourceRef)
        - scale_deferred_ab: \(receipt.scaleAuthorityResolution.deferredABScales.map { String($0) }.joined(separator: ", "))
        - candidate_data_quality: \(receipt.candidateDataQualityGate.status)
        - candidate_max_variants_per_seed: \(receipt.candidateDataQualityGate.maxVariantsPerSeed)
        - candidate_max_observed_variants_per_seed: \(receipt.candidateDataQualityGate.maxObservedVariantsPerSeed)
        - candidate_variant_cap: \(receipt.candidateDataQualityGate.capStatus)
        - candidate_diversity: \(receipt.candidateDataQualityGate.diversityStatus)
        - candidate_unique_utterance_ratio: \(String(format: "%.4f", receipt.candidateDataQualityGate.uniqueUtteranceRatio))
        - candidate_ambiguous_duplicate_count: \(receipt.candidateDataQualityGate.ambiguousDuplicateCount)
        - candidate_lineage_parent_overlap: \(receipt.candidateDataQualityGate.lineageParentOverlap)
        - candidate_epoch_exposure_max: \(receipt.candidateDataQualityGate.epochExposureMax)
        - masking_coverage: train_on_turn=\(receipt.maskingCoverage.trainOnTurn), function_name=\(receipt.maskingCoverage.functionName), argument_name=\(receipt.maskingCoverage.argumentName), argument_value=\(receipt.maskingCoverage.argumentValue)
        - diagnostic_verdict: \(receipt.generalizationDiagnostic.diagnosticVerdict)
        - fuse_parity_gate: \(receipt.fuseParityGate.status)
        - fuse_toolcall_exact_delta_pp: \(String(format: "%.4f", receipt.fuseParityGate.toolCallExactDeltaPP))
        - fuse_IrrelAcc_delta_pp: \(receipt.fuseParityGate.irrelAccDeltaPP.map { String(format: "%.4f", $0) } ?? "missing")
        - endpoint_tokenizer_parity: \(receipt.endpointTokenizerParity.status)
        - endpoint_render_source: \(receipt.endpointTokenizerParity.endpointRenderSource)
        - endpoint_byte_parity: \(receipt.endpointTokenizerParity.byteParity)
        - endpoint_first_mismatch_byte: \(receipt.endpointTokenizerParity.firstMismatchByte.map(String.init) ?? "none")

        ## Config
        - model: \(receipt.mlxConfig.model)
        - fine_tune_type: \(receipt.mlxConfig.fineTuneType)
        - rank: \(receipt.mlxConfig.rank)
        - scale: \(receipt.mlxConfig.scale)
        - optimizer: \(receipt.mlxConfig.optimizer)
        - weight_decay: \(receipt.mlxConfig.weightDecay)
        - grad_clip_norm: \(receipt.mlxConfig.gradClipNorm)
        - training_loop: \(receipt.mlxConfig.trainingLoop)
        - learning_rate: \(receipt.mlxConfig.learningRate)
        - lr_schedule: \(receipt.mlxConfig.lrSchedule)
        - lr_schedule_step_unit: \(receipt.mlxConfig.lrScheduleStepUnit)
        - schedule_decay_steps: \(receipt.mlxConfig.scheduleDecaySteps)
        - warmup_steps: \(receipt.mlxConfig.warmupSteps)
        - optimizer_update_steps: \(receipt.mlxConfig.optimizerUpdateSteps)
        - rendered_schedule_decay_steps: \(receipt.mlxConfig.renderedScheduleDecaySteps)
        - rendered_warmup_steps: \(receipt.mlxConfig.renderedWarmupSteps)
        - max_seq_length: \(receipt.mlxConfig.maxSeqLength)
        - keys: \(receipt.mlxConfig.keys.joined(separator: ", "))

        ## Environment
        - seed: \(receipt.environment.seed)
        - mlx_version: \(receipt.environment.mlxVersion)
        - mlx_lm_version: \(receipt.environment.mlxLMVersion)
        - transformers_version: \(receipt.environment.transformersVersion)
        - hardware: \(receipt.environment.hardware)
        - dtype: \(receipt.environment.dtype)
        - base_model_commit_sha: \(receipt.environment.baseModelCommitSHA)
        - repo_commit_sha: \(receipt.environment.repoCommitSHA)
        - gradient_clip_status: \(receipt.environment.gradientClipStatus)
        - training_loop_source_state: \(receipt.environment.trainingLoopSourceState)
        - training_loop_source_sha256: \(receipt.environment.trainingLoopSourceSHA256)
        - training_loop_verification_status: \(receipt.environment.trainingLoopVerificationStatus)
        - training_loop_verification_ref: \(receipt.environment.trainingLoopVerificationRef)

        ## Training curve
        - metrics_jsonl_ref: \(receipt.trainingCurve.metricsJSONLRef)
        - training_log_ref: \(receipt.trainingCurve.trainingLogRef)
        - best_checkpoint_policy: \(receipt.trainingCurve.bestCheckpointPolicy)
        - note: \(receipt.trainingCurve.note)

        ## Failure receipt
        \(receipt.failureReceipt.map { "- \($0)" }.joined(separator: "\n"))
        """
    }

    private static func buildEnvironment(repoRoot: URL, baseModelDir: URL, modelID: String, seed: Int) -> C5TrainingEnvironment {
        let versions = pythonPackageVersions()
        let verification = trainingLoopVerification(repoRoot: repoRoot)
        return C5TrainingEnvironment(
            seed: seed,
            mlxVersion: versions["mlx", default: "unknown"],
            mlxLMVersion: versions["mlx_lm", default: "unknown"],
            transformersVersion: versions["transformers", default: "unknown"],
            hardware: hardwareDescription(),
            dtype: "bf16_lora_on_4bit_base",
            baseModel: modelID,
            baseModelCommitSHA: baseModelDir.lastPathComponent,
            repoCommitSHA: capture("/usr/bin/git", ["rev-parse", "HEAD"], cwd: repoRoot.path) ?? "unknown",
            trainingBackend: "maformac_c5_repo_loop_mlx_lm_0_31_1",
            gradientClipStatus: verification.sourceState == "verified"
                ? "verified_repo_loop_clip_grad_norm_max_1.0_nonfinite_stop_fallback_lr_5e-5"
                : "tracked_unverified_repo_loop_clip_grad_norm_max_1.0_nonfinite_stop_fallback_lr_5e-5",
            trainingLoopSourceState: verification.sourceState,
            trainingLoopSourceSHA256: verification.scriptSHA256,
            trainingLoopVerificationStatus: verification.status,
            trainingLoopVerificationRef: verification.ref
        )
    }

    private struct TrainingLoopVerificationMarker: Decodable {
        var sourceState: String
        var scriptSHA256: String
        var verificationStatus: String
        var verificationRef: String

        enum CodingKeys: String, CodingKey {
            case sourceState = "source_state"
            case scriptSHA256 = "script_sha256"
            case verificationStatus = "verification_status"
            case verificationRef = "verification_ref"
        }
    }

    private static func trainingLoopVerification(repoRoot: URL) -> (sourceState: String, scriptSHA256: String, status: String, ref: String) {
        let script = repoRoot.appendingPathComponent("Tools/C5TrainingCLI/c5_mlx_train_loop.py")
        let actualSHA = (try? C6Hash.fileHash(url: script)) ?? "missing"
        let markerURL = repoRoot.appendingPathComponent("Tools/C5TrainingCLI/c5_mlx_train_loop.verification.json")
        guard
            let markerData = try? Data(contentsOf: markerURL),
            let marker = try? JSONDecoder().decode(TrainingLoopVerificationMarker.self, from: markerData)
        else {
            return ("tracked_unverified", actualSHA, "missing_verification_marker", "missing")
        }
        guard marker.scriptSHA256 == actualSHA else {
            return ("tracked_unverified", actualSHA, "verification_marker_sha_mismatch", marker.verificationRef)
        }
        guard marker.sourceState == "verified", marker.verificationStatus == "pass" else {
            return ("tracked_unverified", actualSHA, marker.verificationStatus, marker.verificationRef)
        }
        return ("verified", actualSHA, "pass", marker.verificationRef)
    }

    private static func generateMaskOffsetArtifact(
        repoRoot: URL,
        modelDir: URL,
        samplesURL: URL,
        outputURL: URL
    ) throws -> C5MaskOffsetTokenArtifact {
        let script = repoRoot.appendingPathComponent("Tools/C5TrainingCLI/c5_mask_offset_fixture.py")
        let output = run(
            "/opt/homebrew/opt/python@3.13/bin/python3.13",
            [
                script.path,
                "--model", modelDir.path,
                "--samples-jsonl", samplesURL.path,
                "--output", outputURL.path
            ],
            cwd: repoRoot.path
        )
        guard output.status == 0 else {
            throw CLIError.usage("offset fixture generation failed: \(output.stderr)\(output.stdout)")
        }
        let data = try Data(contentsOf: outputURL)
        var artifact = try JSONDecoder().decode(C5MaskOffsetTokenArtifact.self, from: data)
        artifact.artifactSHA256 = try C6Hash.fileHash(url: outputURL)
        return artifact
    }

    private static func run(_ executable: String, _ arguments: [String], cwd: String? = nil) -> (status: Int32, stdout: String, stderr: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        if let cwd {
            process.currentDirectoryURL = URL(fileURLWithPath: cwd, isDirectory: true)
        }
        let stdout = Pipe()
        let stderr = Pipe()
        process.standardOutput = stdout
        process.standardError = stderr
        do {
            try process.run()
            process.waitUntilExit()
            let stdoutData = stdout.fileHandleForReading.readDataToEndOfFile()
            let stderrData = stderr.fileHandleForReading.readDataToEndOfFile()
            return (
                process.terminationStatus,
                String(decoding: stdoutData, as: UTF8.self),
                String(decoding: stderrData, as: UTF8.self)
            )
        } catch {
            return (127, "", "\(error)")
        }
    }

    private static func pythonPackageVersions() -> [String: String] {
        let script = """
        import importlib.metadata as m
        for name in ["mlx", "mlx-lm", "transformers"]:
            try:
                print(f"{name}={m.version(name)}")
            except Exception:
                print(f"{name}=unknown")
        """
        guard let output = capture("/opt/homebrew/opt/python@3.13/bin/python3.13", ["-c", script]) else {
            return [:]
        }
        var versions: [String: String] = [:]
        for line in output.split(whereSeparator: \.isNewline) {
            let parts = line.split(separator: "=", maxSplits: 1).map(String.init)
            guard parts.count == 2 else { continue }
            let key = parts[0] == "mlx-lm" ? "mlx_lm" : parts[0]
            versions[key] = parts[1]
        }
        return versions
    }

    private static func hardwareDescription() -> String {
        let model = capture("/usr/sbin/sysctl", ["-n", "hw.model"]) ?? "unknown_model"
        let cpu = capture("/usr/sbin/sysctl", ["-n", "machdep.cpu.brand_string"]) ?? "unknown_cpu"
        let memBytes = capture("/usr/sbin/sysctl", ["-n", "hw.memsize"]) ?? "unknown_mem"
        return "\(model); \(cpu); mem_bytes=\(memBytes)"
    }

    private static func capture(_ executable: String, _ arguments: [String], cwd: String? = nil) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        if let cwd {
            process.currentDirectoryURL = URL(fileURLWithPath: cwd, isDirectory: true)
        }
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()
        do {
            try process.run()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else {
                return nil
            }
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(decoding: data, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return nil
        }
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
    var generatedUtterancesURL: URL?
    var expectedOffsetArtifactSHA256: String?
    var allowRegeneratedOffsetArtifact: Bool
    var requireCandidateDataQualityGate: Bool
    var requireGeneratedUtteranceRecords: Bool
    var thetaAlphaPositiveOnly: Bool

    init(arguments: [String]) throws {
        let usage = "usage: C5TrainingCLI prepare [--repo-root PATH] [--output-dir PATH] [--target-positive N] [--dev-selection N] [--masking-stage STAGE] [--base-model-dir PATH] [--generated-utterances PATH] [--expected-offset-artifact-sha256 SHA256] [--allow-regenerated-offset-artifact] [--require-candidate-data-quality] [--require-generated-utterances] [--theta-alpha-positive-only]"
        guard arguments.count >= 2 else { throw CLIError.usage(usage) }
        command = arguments[1]
        repoRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        outputDir = repoRoot.appendingPathComponent("Reports/c5-lora-training").path
        targetPositiveRows = 4_500
        devSelectionRows = 400
        maskingStage = .trainableV0
        baseModelDir = URL(fileURLWithPath: "/Users/wanglei/.cache/huggingface/hub/models--mlx-community--Qwen3-1.7B-4bit/snapshots/3b1b1768f8f8cf8351c712464f906e86c2b8269e", isDirectory: true)
        generatedUtterancesURL = nil
        expectedOffsetArtifactSHA256 = nil
        allowRegeneratedOffsetArtifact = false
        requireCandidateDataQualityGate = false
        requireGeneratedUtteranceRecords = false
        thetaAlphaPositiveOnly = false
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
            case "--generated-utterances":
                guard let value = iterator.next() else { throw CLIError.usage("missing --generated-utterances value") }
                generatedUtterancesURL = URL(fileURLWithPath: value)
            case "--expected-offset-artifact-sha256":
                guard let value = iterator.next(), !value.isEmpty else { throw CLIError.usage("missing --expected-offset-artifact-sha256 value") }
                expectedOffsetArtifactSHA256 = value
            case "--allow-regenerated-offset-artifact":
                allowRegeneratedOffsetArtifact = true
            case "--require-candidate-data-quality":
                requireCandidateDataQualityGate = true
            case "--require-generated-utterances":
                requireGeneratedUtteranceRecords = true
            case "--theta-alpha-positive-only":
                thetaAlphaPositiveOnly = true
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
