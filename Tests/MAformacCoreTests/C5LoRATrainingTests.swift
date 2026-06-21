import XCTest
@testable import MAformacCore

final class C5LoRATrainingTests: XCTestCase {
    func testRouteTierDerivesFromNormalizedFCFlagsWithFreeTakingPrecedence() {
        XCTAssertEqual(C5RouteTier.derive(fuzzy: false, free: false), .ruleL1)
        XCTAssertEqual(C5RouteTier.derive(fuzzy: true, free: false), .fcL2)
        XCTAssertEqual(C5RouteTier.derive(fuzzy: false, free: true), .fcL3)
        XCTAssertEqual(C5RouteTier.derive(fuzzy: true, free: true), .fcL3)
    }

    func testBuilderKeepsExecutionTierSeparateFromRouteTier() {
        let seed = semanticSeed(id: "row1", fuzzy: false, free: true, execTier: "L1")
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [seed],
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0)
        )

        XCTAssertEqual(prepared.samples[0].routeTier, .fcL3)
        XCTAssertEqual(prepared.samples[0].executionTier, "L1")
        XCTAssertEqual(prepared.samples[0].routeTierSource, "fc_flags_normalized")
    }

    func testBuilderProducesRequiredMetadataAndRuleRehearsalRatio() {
        let seeds = (0..<70).map { semanticSeed(id: "l2-\($0)", fuzzy: true, free: false) }
            + (0..<10).map { semanticSeed(id: "l3-\($0)", fuzzy: false, free: true) }
            + (0..<30).map { semanticSeed(id: "l1-\($0)", fuzzy: false, free: false) }
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 100, devSelectionRows: 0)
        )

        XCTAssertEqual(prepared.receipt.status, "blocked")
        XCTAssertTrue(prepared.receipt.failureReceipt.contains("offset_fixture_failed"))
        XCTAssertTrue(prepared.receipt.failureReceipt.contains("cloud_multi_source_generator_not_run"))
        XCTAssertTrue(prepared.receipt.failureReceipt.contains("cross_vendor_semantic_judge_not_run"))
        XCTAssertFalse(prepared.receipt.failureReceipt.contains("candidate_semantic_reassignment_not_run"))
        XCTAssertGreaterThanOrEqual(prepared.receipt.rehearsalRatio, 0.05)
        XCTAssertLessThanOrEqual(prepared.receipt.rehearsalRatio, 0.10)
        XCTAssertTrue(prepared.samples.allSatisfy { $0.routeTierSource == "fc_flags_normalized" })
        XCTAssertTrue(prepared.samples.allSatisfy { !$0.generatorModelID.isEmpty })
        XCTAssertTrue(prepared.samples.allSatisfy { !$0.augmentationParentID.isEmpty })
        XCTAssertTrue(prepared.samples.allSatisfy { !$0.lineageGroupID.isEmpty })
        XCTAssertTrue(prepared.samples.filter { !$0.expectedToolCalls.isEmpty }.allSatisfy { $0.candidateParentSemanticID != $0.seedParentSemanticID })
        XCTAssertTrue(prepared.samples.allSatisfy { !$0.expectedToolCallSignature.isEmpty })
        XCTAssertTrue(prepared.receipt.maskingCoverage.trainOnTurn)
        XCTAssertTrue(prepared.receipt.maskingCoverage.functionName)
        XCTAssertTrue(prepared.receipt.maskingCoverage.argumentName)
        XCTAssertTrue(prepared.receipt.maskingCoverage.argumentValue)
        XCTAssertEqual(prepared.receipt.maskingStageCounts["trainable_v0"], prepared.samples.count)
        XCTAssertGreaterThan(prepared.receipt.promptDistractorCount, 0)
        XCTAssertEqual(prepared.receipt.endpointTokenizerParity.status, "blocked")
        XCTAssertTrue(prepared.receipt.endpointTokenizerParity.failureReceipt.contains("endpoint_render_bytes_missing"))
    }

    func testReceiptSummarizesMaskingCompleteStage() {
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [semanticSeed(id: "row1", fuzzy: true, free: false)],
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0, maskingStage: .maskingCompleteV1)
        )

        XCTAssertEqual(prepared.receipt.maskingStageCounts["masking_complete_v1"], prepared.samples.count)
        XCTAssertTrue(prepared.samples.allSatisfy { $0.maskingStage == .maskingCompleteV1 })
    }

    func testSmokeOnlyStageIsChainDataButNotTrainEligible() {
        let seeds = (0..<70).map { semanticSeed(id: "l2-smoke-\($0)", fuzzy: true, free: false) }
            + (0..<10).map { semanticSeed(id: "l3-smoke-\($0)", fuzzy: false, free: true) }
            + (0..<30).map { semanticSeed(id: "l1-smoke-\($0)", fuzzy: false, free: false) }
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 100,
                devSelectionRows: 0,
                maskingStage: .smokeOnly,
                usesTrainingTokenizerPatch: true
            )
        )

        XCTAssertEqual(prepared.receipt.status, "smoke_only_ready")
        XCTAssertEqual(prepared.receipt.offsetFixture.status, "external_mlx_fixture_required")
        XCTAssertTrue(prepared.receipt.offsetFixture.failureReceipt.contains("mlx_apply_chat_template_token_artifact_missing"))
        XCTAssertFalse(prepared.receipt.failureReceipt.contains("offset_fixture_failed"))
        XCTAssertEqual(prepared.receipt.acceptanceStage, .trainHealth)
        XCTAssertEqual(prepared.receipt.trainEligibleCount, 0)
        XCTAssertEqual(prepared.receipt.maskingStageCounts["smoke_only"], prepared.samples.count)
        XCTAssertEqual(prepared.receipt.smokeChainRecordCount, prepared.samples.filter { $0.split == "train" }.count)
        XCTAssertTrue(prepared.samples.allSatisfy { $0.maskingStage == .smokeOnly })
        XCTAssertTrue(prepared.samples.allSatisfy { !$0.trainEligible })
    }

    func testSlotPlaceholdersAreRenderedAsConcreteValuesInUserAndAssistant() {
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [semanticSeed(id: "slot-row", fuzzy: true, free: false, slotKeys: ["position"], range: "position=主驾|副驾|左前")],
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0)
        )
        let sample = prepared.samples[0]
        let user = sample.messages.first { $0.role == "user" }?.content ?? ""
        let assistant = sample.assistantPayload

        XCTAssertTrue(user.contains("position:主驾"))
        XCTAssertTrue(assistant.contains("\"position\":\"主驾\""))
        XCTAssertFalse(user.contains("<position>"))
        XCTAssertFalse(assistant.contains("<position>"))
    }

    func testFixedSemanticSlotsOverrideFallbackWhenRangeIsAbsent() {
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [
                semanticSeed(
                    id: "fixed-slot-row",
                    fuzzy: true,
                    free: false,
                    slotKeys: ["mode", "modeValue"],
                    range: "modeValue=无AC|LOW",
                    semanticSlots: ["mode": "座舱过热保护模式", "modeValue": "<模式取值>"]
                )
            ],
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0)
        )
        let sample = prepared.samples[0]
        let user = sample.messages.first { $0.role == "user" }?.content ?? ""
        let assistant = sample.assistantPayload

        XCTAssertTrue(user.contains("mode:座舱过热保护模式"))
        XCTAssertTrue(user.contains("modeValue:无AC"))
        XCTAssertTrue(assistant.contains("\"mode\":\"座舱过热保护模式\""))
        XCTAssertTrue(assistant.contains("\"modeValue\":\"无AC\""))
        XCTAssertFalse(assistant.contains("\"mode\":\"自动\""))
        XCTAssertFalse(assistant.contains("<模式取值>"))
    }

    func testSampleIDsStayUniqueAcrossRouteTierBatchesAndDevSelectionIsExact() {
        let seeds = (0..<80).map { semanticSeed(id: "l2-\($0)", fuzzy: true, free: false) }
            + (0..<30).map { semanticSeed(id: "l3-\($0)", fuzzy: false, free: true) }
            + (0..<30).map { semanticSeed(id: "l1-\($0)", fuzzy: false, free: false) }
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 120, devSelectionRows: 24)
        )
        let positiveSamples = prepared.samples.filter { !$0.expectedToolCalls.isEmpty }
        let positiveIDs = positiveSamples.map(\.sampleID)

        XCTAssertEqual(Set(positiveIDs).count, positiveIDs.count)
        XCTAssertEqual(positiveSamples.filter { $0.split == "dev_selection" }.count, 24)
        XCTAssertGreaterThanOrEqual(prepared.receipt.rehearsalRatio, 0.05)
        XCTAssertLessThanOrEqual(prepared.receipt.rehearsalRatio, 0.10)
    }

    func testNoCallCounterfactualsArePairedAndCapped() {
        let seeds = (0..<40).map { semanticSeed(id: "l2-\($0)", fuzzy: true, free: false) }
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 40, devSelectionRows: 0)
        )
        let noCalls = prepared.samples.filter { $0.expectedToolCalls.isEmpty }

        XCTAssertFalse(noCalls.isEmpty)
        XCTAssertLessThanOrEqual(prepared.receipt.refusalRatioObserved, 0.20)
        XCTAssertTrue(noCalls.allSatisfy { $0.split == "train" })
        XCTAssertTrue(noCalls.allSatisfy { $0.noCall?.targetToolPresent == false })
        XCTAssertTrue(noCalls.allSatisfy { $0.noCall?.counterfactualPairID.isEmpty == false })
    }

    func testAssistantDoubleNewlineOffsetFixtureCoversToolCallSpan() {
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [semanticSeed(id: "row1", fuzzy: true, free: false)],
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0)
        )

        XCTAssertEqual(prepared.receipt.offsetFixture.status, "external_mlx_fixture_required")
        XCTAssertEqual(prepared.receipt.offsetFixture.assistantPrefixBytes, 2)
        XCTAssertTrue(prepared.receipt.offsetFixture.assistantContentHasPrefix)
        XCTAssertTrue(prepared.receipt.offsetFixture.trainedSpanEqualsToolCall)
        XCTAssertTrue(prepared.receipt.offsetFixture.failureReceipt.contains("training_tokenizer_patch_not_declared"))
        XCTAssertTrue(prepared.receipt.offsetFixture.failureReceipt.contains("mlx_apply_chat_template_token_artifact_missing"))
        XCTAssertNil(prepared.receipt.offsetFixture.tokenArtifact)
    }

    func testOffsetFixtureRequiresTrueTokenArtifactEvenWhenTokenizerPatchFlagIsSet() {
        let seeds = (0..<40).map { semanticSeed(id: "artifact-row-\($0)", fuzzy: true, free: false) }
        let missing = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 40,
                devSelectionRows: 0,
                usesTrainingTokenizerPatch: true
            )
        )
        XCTAssertEqual(missing.receipt.offsetFixture.status, "external_mlx_fixture_required")
        XCTAssertTrue(missing.receipt.failureReceipt.contains("offset_fixture_failed"))

        let artifact = passingOffsetArtifact(for: missing.samples)
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 40,
                devSelectionRows: 0,
                usesTrainingTokenizerPatch: true,
                offsetTokenArtifact: artifact
            )
        )

        XCTAssertEqual(prepared.receipt.offsetFixture.status, "pass")
        XCTAssertEqual(prepared.receipt.offsetFixture.tokenArtifact?.artifactSHA256, "artifact-digest")
        XCTAssertFalse(prepared.receipt.failureReceipt.contains("offset_fixture_failed"))

        var mismatchedArtifact = artifact
        mismatchedArtifact.tokenizerModelID = "/tmp/not-the-training-tokenizer"
        let mismatched = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 40,
                devSelectionRows: 0,
                usesTrainingTokenizerPatch: true,
                offsetTokenArtifact: mismatchedArtifact
            )
        )
        XCTAssertEqual(mismatched.receipt.offsetFixture.status, "fail")
        XCTAssertTrue(mismatched.receipt.offsetFixture.failureReceipt.contains("mlx_apply_chat_template_token_artifact_tokenizer_mismatch"))
        XCTAssertTrue(mismatched.receipt.failureReceipt.contains("offset_fixture_failed"))
    }

    func testGeneratedNaturalChineseRecordsDriveGeneratorJudgeAndLineageReceipts() {
        let seeds = (0..<40).map { semanticSeed(id: "cloud-row-\($0)", fuzzy: true, free: false) }
        let initial = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 40,
                devSelectionRows: 0,
                usesTrainingTokenizerPatch: true
            )
        )
        let records = generatedRecords(for: initial.samples.filter { !$0.expectedToolCalls.isEmpty })
        let artifact = passingOffsetArtifact(for: initial.samples)

        let prepared = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 40,
                devSelectionRows: 0,
                usesTrainingTokenizerPatch: true,
                offsetTokenArtifact: artifact,
                generatedUtteranceRecords: records
            )
        )

        let actionSamples = prepared.samples.filter { !$0.expectedToolCalls.isEmpty }
        XCTAssertEqual(prepared.receipt.generatorOrchestration.status, "pass")
        XCTAssertEqual(prepared.receipt.validatorSummary.layer2SemanticStatus, "pass")
        XCTAssertEqual(prepared.receipt.lineageSummary.candidateSemanticReassignmentStatus, "pass")
        XCTAssertFalse(prepared.receipt.failureReceipt.contains("cloud_multi_source_generator_not_run"))
        XCTAssertFalse(prepared.receipt.failureReceipt.contains("multi_source_generator_diversity_missing"))
        XCTAssertFalse(prepared.receipt.failureReceipt.contains("cross_vendor_semantic_judge_not_run"))
        XCTAssertFalse(prepared.receipt.failureReceipt.contains("candidate_semantic_reassignment_not_run"))
        XCTAssertTrue(actionSamples.allSatisfy { $0.utteranceSource == .llmAugmented })
        XCTAssertTrue(actionSamples.allSatisfy { $0.semanticJudgeModelID != $0.generatorModelID })
        XCTAssertTrue(actionSamples.allSatisfy { $0.candidateParentSemanticID != $0.seedParentSemanticID })
        XCTAssertFalse(actionSamples.contains { ($0.messages.first { $0.role == "user" }?.content ?? "").contains("device=") })
        XCTAssertFalse(actionSamples.contains { ($0.messages.first { $0.role == "user" }?.content ?? "").contains("primitive=") })
    }

    func testGeneratedRecordCandidateParentIsRecomputedFromFinalUtteranceAndToolCall() {
        let seeds = [semanticSeed(id: "cloud-parent-row", fuzzy: true, free: false)]
        let initial = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 1,
                devSelectionRows: 0,
                usesTrainingTokenizerPatch: true
            )
        )
        let first = initial.samples.first { !$0.expectedToolCalls.isEmpty }!
        let generatedUtterance = "帮我把空调打开"
        let record = C5GeneratedUtteranceRecord(
            contractRowID: first.augmentationParentID,
            variant: Int(first.generatorCallID.split(separator: "v").last ?? "0") ?? 0,
            utterance: generatedUtterance,
            generatorModelID: "hermes_glm",
            generatorCallID: "hermes-fixture",
            semanticJudgeModelID: "hermes_ark_standard",
            semanticJudgeCallID: "ark-fixture",
            promptHash: C6Hash.sha256Hex(Data(generatedUtterance.utf8)),
            candidateParentSemanticID: "external_unique_parent_should_not_be_trusted"
        )
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 1,
                devSelectionRows: 0,
                usesTrainingTokenizerPatch: true,
                offsetTokenArtifact: passingOffsetArtifact(for: initial.samples),
                generatedUtteranceRecords: [record]
            )
        )
        let sample = prepared.samples.first { !$0.expectedToolCalls.isEmpty }!
        let renderedToolCall = String(sample.assistantPayload.dropFirst(2))
        let expected = C5TrainingRenderer.candidateParentSemanticID(
            userUtterance: generatedUtterance,
            renderedToolCall: renderedToolCall
        )

        XCTAssertEqual(sample.candidateParentSemanticID, expected)
        XCTAssertNotEqual(sample.candidateParentSemanticID, record.candidateParentSemanticID)
        XCTAssertEqual(
            C5TrainingRenderer.candidateParentSemanticID(userUtterance: generatedUtterance, renderedToolCall: renderedToolCall),
            C5TrainingRenderer.candidateParentSemanticID(userUtterance: "帮 我 把 空 调 打 开", renderedToolCall: renderedToolCall)
        )
    }

    func testPythonMaskOffsetFixtureRunsTrainingTokenizerPath() throws {
        let repoRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let baseModelDir = URL(fileURLWithPath: "/Users/wanglei/.cache/huggingface/hub/models--mlx-community--Qwen3-1.7B-4bit/snapshots/3b1b1768f8f8cf8351c712464f906e86c2b8269e", isDirectory: true)
        XCTAssertTrue(FileManager.default.fileExists(atPath: baseModelDir.appendingPathComponent("tokenizer_config.json").path), "missing local Qwen3 tokenizer fixture")

        let seeds = (0..<40).map { semanticSeed(id: "python-artifact-row-\($0)", fuzzy: true, free: false) }
        let initial = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 40,
                devSelectionRows: 0,
                usesTrainingTokenizerPatch: true
            )
        )
        let temporary = try makeTemporaryDirectory()
        let modelDir = temporary.appendingPathComponent("qwen3-1_7b-training-tokenizer-patched", isDirectory: true)
        try createTrainingTokenizerPatch(sourceDir: baseModelDir, outputDir: modelDir)
        let samplesURL = temporary.appendingPathComponent("samples.jsonl")
        let artifactURL = temporary.appendingPathComponent("offset-fixture.json")
        try writeJSONL(initial.samples, to: samplesURL)

        let result = runProcess(
            executable: "/opt/homebrew/opt/python@3.13/bin/python3.13",
            arguments: [
                repoRoot.appendingPathComponent("Tools/C5TrainingCLI/c5_mask_offset_fixture.py").path,
                "--model", modelDir.path,
                "--samples-jsonl", samplesURL.path,
                "--output", artifactURL.path
            ],
            cwd: repoRoot
        )
        XCTAssertEqual(result.status, 0, result.stderr + result.stdout)

        var artifact = try JSONDecoder().decode(C5MaskOffsetTokenArtifact.self, from: Data(contentsOf: artifactURL))
        artifact.artifactSHA256 = try C6Hash.fileHash(url: artifactURL)
        XCTAssertEqual(artifact.status, "pass")
        XCTAssertEqual(artifact.tokenizerModelID, modelDir.path)
        XCTAssertTrue(artifact.classCoverage.contains("tool_call"))
        XCTAssertTrue(artifact.classCoverage.contains("no_call"))
        XCTAssertTrue(artifact.probes.allSatisfy(\.trainedSpanStartsWithExpected))
        XCTAssertFalse(artifact.probes.contains { $0.trainedSpanContainsUserMarker })
        XCTAssertFalse(artifact.probes.contains { $0.trainedSpanContainsThinkMarker })

        let prepared = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 40,
                devSelectionRows: 0,
                usesTrainingTokenizerPatch: true,
                modelOverride: modelDir.path,
                offsetTokenArtifact: artifact
            )
        )
        XCTAssertEqual(prepared.receipt.offsetFixture.status, "pass")
    }

    func testMLXConfigUsesScaleAndExcludesEmbeddings() {
        let config = C5MLXLoRAConfig.rank16Mainline()

        XCTAssertEqual(config.scale, 32)
        XCTAssertEqual(config.learningRate, 0.0001)
        XCTAssertEqual(config.optimizer, "adamw")
        XCTAssertEqual(config.weightDecay, 0.01)
        XCTAssertEqual(config.seed, 0)
        XCTAssertEqual(config.gradClipNorm, 1.0)
        XCTAssertEqual(config.trainingLoop, "maformac_c5_repo_loop_mlx_lm_0_31_1")
        XCTAssertTrue(config.excludesEmbeddingTargets)
        XCTAssertFalse(config.renderYAML.contains("alpha"))
        XCTAssertTrue(config.renderYAML.contains("lr_schedule:"))
        XCTAssertTrue(config.renderYAML.contains("name: cosine_decay"))
        XCTAssertTrue(config.renderYAML.contains("optimizer: adamw"))
        XCTAssertTrue(config.renderYAML.contains("weight_decay: 0.01"))
        XCTAssertTrue(config.renderYAML.contains("grad_clip_norm: 1.0"))
        XCTAssertTrue(config.renderYAML.contains("training_loop: maformac_c5_repo_loop_mlx_lm_0_31_1"))
        XCTAssertTrue(config.renderYAML.contains("learning_rate: 0.0001"))
        XCTAssertEqual(config.lrScheduleStepUnit, "optimizer_update")
        XCTAssertEqual(config.optimizerUpdateSteps, 150)
        XCTAssertEqual(config.renderedScheduleDecaySteps, 150)
        XCTAssertEqual(config.renderedWarmupSteps, 12)
        XCTAssertTrue(config.renderYAML.contains("# optimizer_update_steps: 150"))
        XCTAssertTrue(config.renderYAML.contains("warmup: 12"))
        XCTAssertTrue(config.keys.contains("self_attn.q_proj"))
        XCTAssertTrue(config.keys.contains("mlp.down_proj"))
    }

    func testGeneralizationDiagnosticAndFuseParityFailClosed() {
        let missing = C5GeneralizationDiagnostic(
            inDistProbe: nil,
            heldout: nil,
            oodProbe: nil,
            trainHeldoutGapPP: nil,
            trainOODGapPP: nil,
            parentOverlap: 0,
            leakageViolations: 0
        )
        XCTAssertEqual(missing.diagnosticVerdict, "blocked_missing")

        let leakage = C5GeneralizationDiagnostic(
            inDistProbe: nil,
            heldout: nil,
            oodProbe: nil,
            trainHeldoutGapPP: nil,
            trainOODGapPP: nil,
            parentOverlap: 1,
            leakageViolations: 0
        )
        XCTAssertEqual(leakage.diagnosticVerdict, "blocked_leakage")

        let parity = C5FuseParityGate.evaluate(C5FuseParityInput(dynamicToolCallExact: 0.95, fusedToolCallExact: 0.90))
        XCTAssertEqual(parity.status, "fail")
        XCTAssertTrue(parity.failureReceipt.contains { $0.contains("toolcall_exact_delta") })

        let irrelDrop = C5FuseParityGate.evaluate(
            C5FuseParityInput(
                dynamicToolCallExact: 0.99,
                fusedToolCallExact: 0.99,
                dynamicIrrelAcc: 0.95,
                fusedIrrelAcc: 0.91,
                quantizedIrrelAcc: 0.91
            )
        )
        XCTAssertEqual(irrelDrop.status, "fail")
        XCTAssertEqual(irrelDrop.irrelAccDeltaPP ?? 0, 4, accuracy: 0.0001)
        XCTAssertTrue(irrelDrop.failureReceipt.contains { $0.contains("IrrelAcc_delta") })

        let irrelPass = C5FuseParityGate.evaluate(
            C5FuseParityInput(
                dynamicToolCallExact: 0.99,
                fusedToolCallExact: 0.98,
                dynamicIrrelAcc: 0.95,
                fusedIrrelAcc: 0.94,
                quantizedIrrelAcc: 0.94
            )
        )
        XCTAssertEqual(irrelPass.status, "pass")
        XCTAssertEqual(irrelPass.irrelAccDeltaPP ?? 0, 1, accuracy: 0.0001)
    }

    func testEndpointTokenizerParityRequiresByteExactEndpointRender() {
        let trainingRendered = "<tool_call>{\"name\":\"tool_call_frame\",\"arguments\":{}}</tool_call>"
        let missing = C5EndpointTokenizerParityGate.blockedMissingEndpointRender(trainingRendered: trainingRendered)
        XCTAssertEqual(missing.status, "blocked")
        XCTAssertTrue(missing.failureReceipt.contains("endpoint_render_bytes_missing"))
        XCTAssertTrue(missing.failureReceipt.contains("endpoint_render_source_missing_patched_tokenizer_or_explicit_enable_thinking_false"))

        let endpointWithThink = "<think>\n\n</think>\n\n" + trainingRendered
        let mismatch = C5EndpointTokenizerParityGate.evaluate(
            trainingRendered: trainingRendered,
            endpointRendered: endpointWithThink,
            endpointRenderSource: "explicit_enable_thinking_false"
        )
        XCTAssertEqual(mismatch.status, "fail")
        XCTAssertFalse(mismatch.byteParity)
        XCTAssertEqual(mismatch.firstMismatchByte, 2)
        XCTAssertFalse(mismatch.thinkBlockParity)
        XCTAssertTrue(mismatch.failureReceipt.contains { $0.contains("rendered_byte_parity_mismatch") })
        XCTAssertTrue(mismatch.failureReceipt.contains("think_marker_or_empty_block_parity_mismatch"))

        let endpointRendered = "<think>\n\n</think>\n\n" + trainingRendered
        let pass = C5EndpointTokenizerParityGate.evaluate(
            trainingRendered: endpointRendered,
            endpointRendered: endpointRendered,
            endpointRenderSource: "patched_tokenizer"
        )
        XCTAssertEqual(pass.status, "pass")
        XCTAssertTrue(pass.byteParity)
        XCTAssertTrue(pass.thinkBlockParity)
    }

    private func semanticSeed(
        id: String,
        fuzzy: Bool,
        free: Bool,
        execTier: String = "L2",
        slotKeys: [String] = ["device"],
        range: String = "",
        semanticSlots: [String: String] = [:]
    ) -> C5SemanticSeed {
        let encodedSlotKeys = slotKeys.map { "\"\($0)\"" }.joined(separator: ",")
        let dsProtocol: String
        if semanticSlots.isEmpty {
            dsProtocol = ""
        } else {
            let encodedSlots = semanticSlots
                .sorted { $0.key < $1.key }
                .map { "\"\($0.key)\":\"\($0.value)\"" }
                .joined(separator: ",")
            dsProtocol = ",\"ds_protocol\":{\"semantic\":{\"slots\":{\(encodedSlots)}}}"
        }
        let json = """
        {"contract_row_id":"\(id)","canonical_semantic_id":"sem-\(id)","dedupe_group_id":"dedupe-\(id)","dedupe_role":"primary","device":"ac","action_primitive":"power_on","action_code":"open_ac","intent":"open_ac","service":"airControl","exec_tier":"\(execTier)","fc_flags":{"fuzzy":\(fuzzy),"free":\(free)},"slot_keys":[\(encodedSlotKeys)],"value":{"ref":"ZERO","direct":"+","offset":"ON","type":"EXP"},"source_domain":"airControl","source_sheet":"airControl","source_row_no":1,"range":"\(range)"\(dsProtocol)}
        """
        return try! JSONDecoder().decode(C5SemanticSeed.self, from: Data(json.utf8))
    }

    private func context() -> C5DataGateRunContext {
        C5DataGateRunContext(
            sourceSnapshotDigest: "semantic-digest",
            sourceAuthorizationStatus: "authorized_c1_semantic_contract",
            formatContractVersion: "format-digest",
            generatedAt: "2026-06-21T00:00:00Z"
        )
    }

    private func passingOffsetArtifact(for samples: [C5TrainingSample]) -> C5MaskOffsetTokenArtifact {
        let selected = [
            samples.first { !$0.expectedToolCalls.isEmpty },
            samples.first { $0.expectedToolCalls.isEmpty && $0.noCall != nil }
        ].compactMap { $0 }
        let probes = selected.map { sample in
            let expectedStart = sample.expectedToolCalls.isEmpty ? "NO_TOOL" : "<tool_call>"
            return C5MaskOffsetTokenProbe(
                sampleID: sample.sampleID,
                assistantPayloadDigest: C6Hash.sha256Hex(Data(sample.assistantPayload.utf8)),
                expectedStart: expectedStart,
                offset: 128,
                length: 192,
                trainedTokenCount: 64,
                trainedSpanDigest: "trained-span-\(sample.sampleID)",
                trainedSpanStartsWithExpected: true,
                trainedSpanContainsUserMarker: false,
                trainedSpanContainsSystemMarker: false,
                trainedSpanContainsThinkMarker: false,
                status: "pass",
                failureReceipt: []
            )
        }
        return C5MaskOffsetTokenArtifact(
            status: "pass",
            artifactPath: "/tmp/c5-mask-offset-fixture.json",
            artifactSHA256: "artifact-digest",
            tokenizerModelID: "mlx-community/Qwen3-1.7B-4bit",
            mlxLMVersion: "0.31.1",
            transformersVersion: "5.6.1",
            generatedAt: "2026-06-21T00:00:00Z",
            sampleCount: probes.count,
            classCoverage: ["no_call", "tool_call"],
            probes: probes,
            failureReceipt: []
        )
    }

    private func generatedRecords(for samples: [C5TrainingSample]) -> [C5GeneratedUtteranceRecord] {
        samples.enumerated().map { index, sample in
            let variant = Int(sample.generatorCallID.split(separator: "v").last ?? "0") ?? 0
            let source = index.isMultiple(of: 2) ? "hermes_glm" : "codex"
            let judge = index.isMultiple(of: 2) ? "gpt_5" : "hermes_glm"
            let utterance = index.isMultiple(of: 2)
                ? "帮我把空调打开一下，车里有点闷。"
                : "现在车里不太舒服，麻烦把空调开起来。"
            return C5GeneratedUtteranceRecord(
                contractRowID: sample.augmentationParentID,
                variant: variant,
                utterance: utterance,
                generatorModelID: source,
                generatorCallID: "\(source)-fixture-\(sample.sampleID)",
                semanticJudgeModelID: judge,
                semanticJudgeCallID: "\(judge)-fixture-\(sample.sampleID)",
                promptHash: C6Hash.sha256Hex(Data(utterance.utf8)),
                candidateParentSemanticID: "external_untrusted_\(C6Hash.sha256Hex(Data(sample.sampleID.utf8)).prefix(16))"
            )
        }
    }

    private func writeJSONL<T: Encodable>(_ values: [T], to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        let lines = try values.map { String(decoding: try encoder.encode($0), as: UTF8.self) }
        try (lines.joined(separator: "\n") + "\n").write(to: url, atomically: true, encoding: .utf8)
    }

    private func makeTemporaryDirectory() throws -> URL {
        let url = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("maformac-c5-offset-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func runProcess(executable: String, arguments: [String], cwd: URL) -> (status: Int32, stdout: String, stderr: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.currentDirectoryURL = cwd
        let stdout = Pipe()
        let stderr = Pipe()
        process.standardOutput = stdout
        process.standardError = stderr
        do {
            try process.run()
            process.waitUntilExit()
            return (
                process.terminationStatus,
                String(decoding: stdout.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self),
                String(decoding: stderr.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
            )
        } catch {
            return (127, "", "\(error)")
        }
    }

    private func createTrainingTokenizerPatch(sourceDir: URL, outputDir: URL) throws {
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: outputDir, withIntermediateDirectories: true)
        let old = "{%- if enable_thinking is defined and enable_thinking is false %}"
        let new = "{%- if enable_thinking is not defined or enable_thinking is false %}"
        for child in try fileManager.contentsOfDirectory(at: sourceDir, includingPropertiesForKeys: nil) {
            let destination = outputDir.appendingPathComponent(child.lastPathComponent)
            if child.lastPathComponent == "tokenizer_config.json" {
                let data = try Data(contentsOf: child)
                guard var object = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let template = object["chat_template"] as? String else {
                    XCTFail("tokenizer_config.json missing chat_template")
                    return
                }
                XCTAssertTrue(template.contains(old))
                object["chat_template"] = template.replacingOccurrences(of: old, with: new, options: [], range: template.range(of: old))
                let patched = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys])
                try patched.write(to: destination)
            } else {
                try fileManager.createSymbolicLink(at: destination, withDestinationURL: child.resolvingSymlinksInPath())
            }
        }
    }
}
