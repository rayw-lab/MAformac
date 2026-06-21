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
        XCTAssertTrue(prepared.receipt.failureReceipt.contains("candidate_semantic_reassignment_not_run"))
        XCTAssertGreaterThanOrEqual(prepared.receipt.rehearsalRatio, 0.05)
        XCTAssertLessThanOrEqual(prepared.receipt.rehearsalRatio, 0.10)
        XCTAssertTrue(prepared.samples.allSatisfy { $0.routeTierSource == "fc_flags_normalized" })
        XCTAssertTrue(prepared.samples.allSatisfy { !$0.generatorModelID.isEmpty })
        XCTAssertTrue(prepared.samples.allSatisfy { !$0.augmentationParentID.isEmpty })
        XCTAssertTrue(prepared.samples.allSatisfy { !$0.lineageGroupID.isEmpty })
        XCTAssertTrue(prepared.samples.allSatisfy { !$0.expectedToolCallSignature.isEmpty })
        XCTAssertTrue(prepared.receipt.maskingCoverage.trainOnTurn)
        XCTAssertTrue(prepared.receipt.maskingCoverage.functionName)
        XCTAssertTrue(prepared.receipt.maskingCoverage.argumentName)
        XCTAssertTrue(prepared.receipt.maskingCoverage.argumentValue)
        XCTAssertEqual(prepared.receipt.maskingStageCounts["trainable_v0"], prepared.samples.count)
        XCTAssertGreaterThan(prepared.receipt.promptDistractorCount, 0)
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
        XCTAssertTrue(prepared.receipt.offsetFixture.failureReceipt.contains("mlx_apply_chat_template_offset_fixture_not_embedded"))
    }

    func testMLXConfigUsesScaleAndExcludesEmbeddings() {
        let config = C5MLXLoRAConfig.rank16Mainline()

        XCTAssertEqual(config.scale, 32)
        XCTAssertTrue(config.excludesEmbeddingTargets)
        XCTAssertFalse(config.renderYAML.contains("alpha"))
        XCTAssertTrue(config.renderYAML.contains("lr_schedule:"))
        XCTAssertTrue(config.renderYAML.contains("name: cosine_decay"))
        XCTAssertTrue(config.renderYAML.contains("warmup: 48"))
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
    }

    private func semanticSeed(id: String, fuzzy: Bool, free: Bool, execTier: String = "L2") -> C5SemanticSeed {
        let json = """
        {"contract_row_id":"\(id)","canonical_semantic_id":"sem-\(id)","dedupe_group_id":"dedupe-\(id)","dedupe_role":"primary","device":"ac","action_primitive":"power_on","action_code":"open_ac","intent":"open_ac","service":"airControl","exec_tier":"\(execTier)","fc_flags":{"fuzzy":\(fuzzy),"free":\(free)},"slot_keys":["device"],"value":{"ref":"ZERO","direct":"+","offset":"ON","type":"EXP"},"source_domain":"airControl","source_sheet":"airControl","source_row_no":1}
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
}
