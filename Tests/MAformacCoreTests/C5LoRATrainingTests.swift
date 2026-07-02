import XCTest
@testable import MAformacCore

final class C5LoRATrainingTests: XCTestCase {
    func testRouteTierDerivesFromNormalizedFCFlagsWithFreeTakingPrecedence() {
        XCTAssertEqual(C5RouteTier.derive(fuzzy: false, free: false), .ruleL1)
        XCTAssertEqual(C5RouteTier.derive(fuzzy: true, free: false), .fcL2)
        XCTAssertEqual(C5RouteTier.derive(fuzzy: false, free: true), .fcL3)
        XCTAssertEqual(C5RouteTier.derive(fuzzy: true, free: true), .fcL3)
        XCTAssertEqual(C5RouteTier.derive(fuzzy: false, free: false, valueType: "EXP"), .ruleL1)
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
        XCTAssertEqual(prepared.samples[0].routeTierSource, "route_deriver_v2_fc_flags_value_type")
    }

    func testToolCallPayloadRendersNameBeforeArgumentsButKeepsArgumentsCanonical() {
        let first = C5TrainingToolCall(
            name: "tool_call_frame",
            arguments: ["z": .string("last"), "a": .string("first")]
        )
        let second = C5TrainingToolCall(
            name: "tool_call_frame",
            arguments: ["a": .string("first"), "z": .string("last")]
        )

        let rendered = C5TrainingRenderer.renderToolCall(first)

        XCTAssertEqual(rendered, "<tool_call>{\"name\":\"tool_call_frame\",\"arguments\":{\"a\":\"first\",\"z\":\"last\"}}</tool_call>")
        XCTAssertEqual(rendered, C5TrainingRenderer.renderToolCall(second))
    }

    func testToolContractCompilerDerivesEnumsFromSemanticSeeds() throws {
        let seeds = [
            semanticSeed(id: "ac-row", fuzzy: true, free: false, device: "ac", actionPrimitive: "power_on", valueType: "EXP"),
            semanticSeed(id: "window-row", fuzzy: false, free: false, device: "window", actionPrimitive: "by_percent", slotKeys: ["position"], valueType: "PERCENT")
        ]
        let tool = try XCTUnwrap(ToolContractCompiler(seeds: seeds).frameToolSchema.first)
        let properties = try toolProperties(tool)

        XCTAssertEqual(propertyEnum(properties, "device"), ["ac", "window"])
        XCTAssertEqual(propertyEnum(properties, "action_primitive"), ["by_percent", "power_on"])
        XCTAssertEqual(propertyEnum(properties, "value.type"), ["EXP", "PERCENT"])
        XCTAssertNotNil(properties["position"])
    }

    func testTrainingSampleUsesSeedLocalContractDerivedSchema() throws {
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [
                semanticSeed(id: "ac-row", fuzzy: true, free: false, device: "ac", actionPrimitive: "power_on", valueType: "EXP"),
                semanticSeed(id: "window-row", fuzzy: false, free: false, device: "window", actionPrimitive: "by_percent", slotKeys: ["position"], valueType: "PERCENT")
            ],
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 2, devSelectionRows: 0)
        )
        let tool = try XCTUnwrap(prepared.samples.first?.tools.first { functionName($0) == "tool_call_frame" })
        let properties = try toolProperties(tool)

        XCTAssertEqual(propertyEnum(properties, "device").count, 1)
        XCTAssertEqual(propertyEnum(properties, "action_primitive").count, 1)
        XCTAssertEqual(propertyEnum(properties, "value.type").count, 1)
        XCTAssertLessThan(prepared.samples[0].tools.description.count, 25_000)
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
        XCTAssertTrue(prepared.samples.allSatisfy { $0.routeTierSource == "route_deriver_v2_fc_flags_value_type" })
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
            seeds: [semanticSeed(id: "slot-row", fuzzy: true, free: false, slotKeys: ["position"], range: "position=主驾|副驾|左后")],
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

    func testOmittedWindowTrainingTargetOmitsPositionScope() {
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [
                semanticSeed(
                    id: "omitted-window-row",
                    fuzzy: true,
                    free: false,
                    device: "window",
                    actionPrimitive: "power_on",
                    slotKeys: [],
                    range: ""
                )
            ],
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 4, devSelectionRows: 0)
        )

        let rendered = prepared.samples.map(\.assistantPayload).joined(separator: "\n")
        XCTAssertFalse(rendered.contains("\"position\""))
        XCTAssertFalse(rendered.contains("左前"))
        XCTAssertFalse(rendered.contains("右前"))
        XCTAssertFalse(rendered.contains("后排"))
    }

    func testExplicitScopeCandidatesDeriveFromC2Vocabulary() throws {
        let stateCells = try StateCellContractLookup(yaml: readRepoFile("contracts/state-cells.yaml"))
        let scopeCandidates = C5ScopeCandidateCatalog.scopeCandidatesBySlot(from: stateCells)
        let deviceScopeCandidates = C5ScopeCandidateCatalog.scopeCandidatesByDeviceSlot(from: stateCells)
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [
                semanticSeed(
                    id: "slot-row",
                    fuzzy: true,
                    free: false,
                    device: "window",
                    slotKeys: ["position"],
                    range: ""
                )
            ],
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 12,
                devSelectionRows: 0,
                scopeCandidatesBySlot: scopeCandidates,
                scopeCandidatesByDeviceSlot: deviceScopeCandidates
            )
        )

        let rendered = prepared.samples.map(\.assistantPayload).joined(separator: "\n")
        XCTAssertTrue(rendered.contains("\"position\":\"主驾\""))
        XCTAssertTrue(rendered.contains("\"position\":\"副驾\""))
        XCTAssertTrue(rendered.contains("\"position\":\"左后\""))
        XCTAssertTrue(rendered.contains("\"position\":\"右后\""))
        XCTAssertFalse(rendered.contains("\"position\":\"左前\""))
        XCTAssertFalse(rendered.contains("\"position\":\"右前\""))
        XCTAssertFalse(rendered.contains("\"position\":\"后排\""))
    }

    func testDeviceAwareScopeCandidatesCoverAllMappedScopedCells() throws {
        let stateCells = try StateCellContractLookup(yaml: readRepoFile("contracts/state-cells.yaml"))
        let deviceScopeCandidates = C5ScopeCandidateCatalog.scopeCandidatesByDeviceSlot(from: stateCells)

        XCTAssertEqual(deviceScopeCandidates["sunroof"]?["position"], ["前排", "后排", "全车"])
        XCTAssertEqual(deviceScopeCandidates["seat_backrest"]?["position"], ["主驾", "副驾"])
        XCTAssertEqual(deviceScopeCandidates["wiper_speed"]?["position"], ["前", "后", "前后"])

        for (device, cellID) in ToolContractStateApplier.deviceCellMap {
            guard let cell = stateCells.cell(id: cellID), !cell.scope.isEmpty else {
                continue
            }
            let slots = try XCTUnwrap(deviceScopeCandidates[device], "\(device) should carry C2 scope candidates for \(cellID)")
            let candidateUnion = Set(slots.values.flatMap { $0 })
            XCTAssertEqual(candidateUnion, Set(cell.scope), "\(device) should derive scope candidates from \(cellID)")
        }
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

    func testThetaAlphaPositiveOnlySkipsNoCallRowsButKeepsDistractors() {
        let seeds = (0..<40).map { semanticSeed(id: "theta-alpha-\($0)", fuzzy: true, free: false) }
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 40,
                devSelectionRows: 0,
                refusalRatioTarget: 0,
                refusalRatioHardCap: 0,
                includeNoCallCounterfactuals: false
            )
        )

        XCTAssertEqual(prepared.receipt.refusalRatioTarget, 0)
        XCTAssertEqual(prepared.receipt.refusalRatioHardCap, 0)
        XCTAssertEqual(prepared.receipt.refusalRatioObserved, 0)
        XCTAssertEqual(prepared.receipt.noCallCounterfactualCount, 0)
        XCTAssertFalse(prepared.samples.contains { $0.assistantPayload.contains("NO_TOOL") })
        XCTAssertTrue(prepared.samples.allSatisfy { !$0.expectedToolCalls.isEmpty })
        XCTAssertTrue(prepared.samples.allSatisfy { $0.noCall == nil })
        XCTAssertGreaterThan(prepared.receipt.promptDistractorCount, 0)
        XCTAssertTrue(prepared.samples.contains { $0.promptDistractorToolIDs.contains { $0.hasPrefix("irrelevant_navigation_") } })
        XCTAssertTrue(prepared.receipt.frameSurfaced.contains("theta-alpha positive-only scope excludes theta-beta refusal/no-call rows"))
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

    func testNaturalToolCallRowsOverrideUserOnlyWhenCanonicalTargetMatches() {
        let seed = semanticSeed(id: "row-natural", fuzzy: true, free: false)
        let canonical = C5TrainingDatasetBuilder().build(
            seeds: [seed],
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0, surface: .frame)
        ).samples[0]
        let target = canonical.assistantPayload.trimmingCharacters(in: .whitespacesAndNewlines)
        let natural = C5NaturalToolCallRecord(
            contractRowID: "row-natural",
            variant: 0,
            user: "帮我开一下空调",
            target: target,
            generatorModelID: "hermes_glm",
            generatorSourceVendor: "volcengine",
            generatorCallID: "call-natural-1",
            semanticJudgeModelID: "gptpro",
            semanticJudgeCallID: "judge-natural-1",
            promptHash: "prompt-natural"
        )
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [seed],
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 1,
                devSelectionRows: 0,
                maxVariantsPerSeed: 1,
                naturalToolCallRecords: [natural],
                surface: .frame
            )
        )
        let sample = prepared.samples[0]

        XCTAssertEqual(sample.messages.first { $0.role == "user" }?.content, "帮我开一下空调")
        XCTAssertEqual(sample.assistantPayload.trimmingCharacters(in: .whitespacesAndNewlines), target)
        XCTAssertEqual(sample.generatorModelID, "hermes_glm")
        XCTAssertEqual(sample.semanticJudgeModelID, "gptpro")
        XCTAssertEqual(sample.lossObjectiveProfile, .assistantFullExceptThink)
        XCTAssertEqual(sample.expectedToolCalls, canonical.expectedToolCalls)
    }

    func testNaturalToolCallRowsRejectWrongCanonicalArgumentValue() {
        let fixture = canonicalNaturalToolCallFixture()
        var arguments = fixture.call.arguments
        arguments["value.offset"] = .string("OFF")
        assertNaturalToolCallTargetMismatch(target: C5TrainingRenderer.renderToolCall(C5TrainingToolCall(name: fixture.call.name, arguments: arguments)))
    }

    func testNaturalToolCallRowsRejectMissingCanonicalArgumentKey() {
        let fixture = canonicalNaturalToolCallFixture()
        var arguments = fixture.call.arguments
        arguments.removeValue(forKey: "value.offset")
        assertNaturalToolCallTargetMismatch(target: C5TrainingRenderer.renderToolCall(C5TrainingToolCall(name: fixture.call.name, arguments: arguments)))
    }

    func testNaturalToolCallRowsRejectExtraCanonicalArgumentKey() {
        let fixture = canonicalNaturalToolCallFixture()
        var arguments = fixture.call.arguments
        arguments["unexpected"] = .string("bypass")
        assertNaturalToolCallTargetMismatch(target: C5TrainingRenderer.renderToolCall(C5TrainingToolCall(name: fixture.call.name, arguments: arguments)))
    }

    func testReceiptIncludesMachineReadableFitProofFrontmatter() {
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [semanticSeed(id: "fit-proof-row", fuzzy: true, free: false)],
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0)
        )

        XCTAssertEqual(prepared.receipt.fitProofLevel, "mechanism_true")
        XCTAssertEqual(prepared.receipt.consumer, "Tools/C5TrainingCLI/c5_mlx_train_loop.py --require-maformac-loss-mask")
        XCTAssertTrue(prepared.receipt.consumedArtifact.contains("loss_objective_profile"))
        XCTAssertTrue(prepared.receipt.sufficiencyEvidence.contains("--allow-legacy-loss-objective"))
        XCTAssertTrue(prepared.receipt.residualGap.contains("does not claim live training"))
    }

    func testFormalTrainingBlocksUnverifiedTrainingLoopSource() {
        let seeds = routeBalancedSeeds(prefix: "unverified")
        let initial = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 100,
                devSelectionRows: 0,
                usesTrainingTokenizerPatch: true
            )
        )
        let artifact = passingOffsetArtifact(for: initial.samples)
        let records = generatedRecords(for: initial.samples.filter { !$0.expectedToolCalls.isEmpty })

        let prepared = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 100,
                devSelectionRows: 0,
                usesTrainingTokenizerPatch: true,
                offsetTokenArtifact: artifact,
                generatedUtteranceRecords: records
            )
        )

        XCTAssertEqual(prepared.receipt.environment.trainingLoopSourceState, "tracked_unverified")
        XCTAssertEqual(prepared.receipt.status, "blocked")
        XCTAssertTrue(prepared.receipt.failureReceipt.contains("training_loop_source_unverified"))
    }

    func testVerifiedTrainingLoopSourceUnblocksFormalTrainingGate() {
        let seeds = routeBalancedSeeds(prefix: "verified")
        let verifiedEnvironment = verifiedEnvironment()
        let initial = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 100,
                devSelectionRows: 0,
                usesTrainingTokenizerPatch: true,
                environment: verifiedEnvironment
            )
        )
        let artifact = passingOffsetArtifact(for: initial.samples)
        let records = generatedRecords(for: initial.samples.filter { !$0.expectedToolCalls.isEmpty })

        let prepared = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 100,
                devSelectionRows: 0,
                usesTrainingTokenizerPatch: true,
                environment: verifiedEnvironment,
                offsetTokenArtifact: artifact,
                generatedUtteranceRecords: records
            )
        )

        XCTAssertEqual(prepared.receipt.environment.trainingLoopSourceState, "verified")
        XCTAssertEqual(prepared.receipt.environment.trainingLoopVerificationStatus, "pass")
        XCTAssertFalse(prepared.receipt.failureReceipt.contains("training_loop_source_unverified"))
        XCTAssertEqual(prepared.receipt.status, "trainable_v0_ready")
    }

    func testTrainingMethodContractAuthorityUsesArchivedMethodContract() {
        let seeds = routeBalancedSeeds(prefix: "method-authority")
        let verifiedEnvironment = verifiedEnvironment()
        let initial = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 100,
                devSelectionRows: 0,
                usesTrainingTokenizerPatch: true,
                environment: verifiedEnvironment
            )
        )

        let prepared = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 100,
                devSelectionRows: 0,
                usesTrainingTokenizerPatch: true,
                environment: verifiedEnvironment,
                offsetTokenArtifact: passingOffsetArtifact(for: initial.samples),
                generatedUtteranceRecords: generatedRecords(for: initial.samples.filter { !$0.expectedToolCalls.isEmpty })
            )
        )

        XCTAssertEqual(prepared.receipt.trainingMethodContractAuthority.status, "pass")
        XCTAssertEqual(
            prepared.receipt.trainingMethodContractAuthority.activeMethodSpecPath,
            "openspec/specs/lora-training/spec.md"
        )
        XCTAssertEqual(
            prepared.receipt.trainingMethodContractAuthority.archivedChangePath,
            "openspec/changes/archive/2026-06-21-define-lora-training"
        )
        XCTAssertNotNil(prepared.receipt.trainingMethodContractAuthority.activeMethodSpecSHA256)
        XCTAssertNotNil(prepared.receipt.trainingMethodContractAuthority.archivedMethodSpecSHA256)
        XCTAssertTrue(prepared.receipt.sourceRefs.contains("openspec/specs/lora-training/spec.md"))
        XCTAssertTrue(prepared.receipt.sourceRefs.contains("openspec/changes/archive/2026-06-21-define-lora-training"))
        XCTAssertFalse(prepared.receipt.sourceRefs.contains("openspec/changes/define-lora-training/specs/lora-training/spec.md:3-164"))
        XCTAssertEqual(prepared.receipt.status, "trainable_v0_ready")
    }

    func testTrainingMethodContractAuthorityFailsClosedWhenArchiveAuthorityIsMissing() {
        let authority = C5TrainingMethodContractAuthority.evaluate(
            activeMethodSpecPath: "/tmp/maformac-missing-active-spec-\(UUID().uuidString).md",
            archivedChangePath: "/tmp/maformac-missing-archive-\(UUID().uuidString)",
            archivedMethodSpecPath: "/tmp/maformac-missing-archived-spec-\(UUID().uuidString).md"
        )

        XCTAssertEqual(authority.status, "fail")
        XCTAssertTrue(authority.failureReceipt.contains("active_training_method_spec_missing"))
        XCTAssertTrue(authority.failureReceipt.contains("archived_define_lora_training_change_missing"))
        XCTAssertTrue(authority.failureReceipt.contains("archived_training_method_spec_missing"))
        XCTAssertNil(authority.activeMethodSpecSHA256)
        XCTAssertNil(authority.archivedMethodSpecSHA256)
    }

    func testFirstCandidateScaleAuthorityDefaultsTo20AndBlocksLegacy32() {
        let config = C5MLXLoRAConfig.rank16Mainline()
        XCTAssertEqual(config.scale, 20)
        XCTAssertTrue(config.renderYAML.contains("scale: 20.0"))
        XCTAssertEqual(C5ScaleAuthorityResolution.evaluate(observedScale: config.scale).status, "pass")

        var legacyScaleConfig = config
        legacyScaleConfig.scale = 32
        let seeds = routeBalancedSeeds(prefix: "scale-authority")
        let initial = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 100,
                devSelectionRows: 0,
                usesTrainingTokenizerPatch: true,
                environment: verifiedEnvironment()
            )
        )
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 100,
                devSelectionRows: 0,
                usesTrainingTokenizerPatch: true,
                mlxConfig: legacyScaleConfig,
                environment: verifiedEnvironment(),
                offsetTokenArtifact: passingOffsetArtifact(for: initial.samples),
                generatedUtteranceRecords: generatedRecords(for: initial.samples.filter { !$0.expectedToolCalls.isEmpty })
            )
        )

        XCTAssertEqual(prepared.receipt.mlxConfig.scale, 32)
        XCTAssertEqual(prepared.receipt.scaleAuthorityResolution.status, "fail")
        XCTAssertEqual(prepared.receipt.scaleAuthorityResolution.deferredABScales, [32])
        XCTAssertTrue(prepared.receipt.failureReceipt.contains("scale_authority_mismatch"))
        XCTAssertEqual(prepared.receipt.status, "blocked")
    }

    func testOffsetArtifactAuthorityRequiresApprovedDigestUnlessRegeneratedSamePath() {
        let seeds = routeBalancedSeeds(prefix: "offset-authority")
        let initial = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 100,
                devSelectionRows: 0,
                usesTrainingTokenizerPatch: true,
                environment: verifiedEnvironment()
            )
        )
        var artifact = passingOffsetArtifact(for: initial.samples)
        artifact.artifactSHA256 = "wrong-digest"
        let records = generatedRecords(for: initial.samples.filter { !$0.expectedToolCalls.isEmpty })

        let mismatched = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 100,
                devSelectionRows: 0,
                usesTrainingTokenizerPatch: true,
                environment: verifiedEnvironment(),
                offsetTokenArtifact: artifact,
                expectedOffsetArtifactSHA256: C5OffsetArtifactAuthority.approvedFinalV3SHA256,
                generatedUtteranceRecords: records
            )
        )
        XCTAssertEqual(mismatched.receipt.offsetFixture.status, "pass")
        XCTAssertEqual(mismatched.receipt.offsetArtifactAuthority.status, "fail")
        XCTAssertEqual(mismatched.receipt.offsetArtifactAuthority.authorityMode, "unapproved")
        XCTAssertTrue(mismatched.receipt.failureReceipt.contains("offset_artifact_mismatch"))
        XCTAssertEqual(mismatched.receipt.status, "blocked")

        artifact.artifactPath = "/tmp/pr5/offset-fixture/mlx-mask-offset-fixture.json"
        let regenerated = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 100,
                devSelectionRows: 0,
                usesTrainingTokenizerPatch: true,
                environment: verifiedEnvironment(),
                offsetTokenArtifact: artifact,
                expectedOffsetArtifactSHA256: C5OffsetArtifactAuthority.approvedFinalV3SHA256,
                allowRegeneratedOffsetArtifact: true,
                generatedUtteranceRecords: records
            )
        )
        XCTAssertEqual(regenerated.receipt.offsetArtifactAuthority.status, "pass")
        XCTAssertEqual(regenerated.receipt.offsetArtifactAuthority.authorityMode, "regenerated_same_path")
        XCTAssertTrue(regenerated.receipt.offsetArtifactAuthority.samePathRegenerationObserved)
        XCTAssertFalse(regenerated.receipt.failureReceipt.contains("offset_artifact_mismatch"))
    }

    func testCandidateDataQualityGateBlocksDiversityCapAndAmbiguousDuplicates() {
        let seeds = routeBalancedSeeds(prefix: "quality")
        let initial = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 100,
                devSelectionRows: 0,
                usesTrainingTokenizerPatch: true,
                environment: verifiedEnvironment()
            )
        )
        let duplicateRecords = generatedRecords(for: initial.samples.filter { !$0.expectedToolCalls.isEmpty })
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: seeds,
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 100,
                devSelectionRows: 0,
                usesTrainingTokenizerPatch: true,
                environment: verifiedEnvironment(),
                offsetTokenArtifact: passingOffsetArtifact(for: initial.samples),
                requireCandidateDataQualityGate: true,
                generatedUtteranceRecords: duplicateRecords
            )
        )

        XCTAssertEqual(prepared.receipt.candidateDataQualityGate.status, "fail")
        XCTAssertTrue(prepared.receipt.candidateDataQualityGate.uniqueUtteranceRatio < 0.80)
        XCTAssertTrue(prepared.receipt.failureReceipt.contains("variant_diversity_check_failed"))
        XCTAssertEqual(prepared.receipt.status, "blocked")

        let actionSamples = initial.samples.filter { !$0.expectedToolCalls.isEmpty }
        let capFailure = C5CandidateDataQualityGate.evaluate(
            samples: actionSamples,
            maxVariantsPerSeed: 0,
            epochs: 3,
            lineageParentOverlap: 0
        )
        XCTAssertEqual(capFailure.capStatus, "fail")
        XCTAssertTrue(capFailure.failureReceipt.contains("per_seed_variant_cap_exceeded"))

        var conflicting = Array(actionSamples.prefix(2))
        XCTAssertEqual(conflicting.count, 2)
        let sharedUser = conflicting[0].messages.first { $0.role == "user" }!.content
        conflicting[1].messages = conflicting[1].messages.map { message in
            message.role == "user" ? C5TrainingMessage(role: "user", content: sharedUser) : message
        }
        conflicting[1].promptDistractorToolIDs = conflicting[0].promptDistractorToolIDs
        let ambiguous = C5CandidateDataQualityGate.evaluate(
            samples: conflicting,
            maxVariantsPerSeed: 8,
            epochs: 3,
            lineageParentOverlap: 0
        )
        XCTAssertEqual(ambiguous.ambiguousDuplicateCount, 1)
        XCTAssertTrue(ambiguous.failureReceipt.contains("ambiguous_duplicate"))
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
        guard FileManager.default.fileExists(atPath: baseModelDir.appendingPathComponent("tokenizer_config.json").path) else {
            throw XCTSkip("missing local Qwen3 tokenizer fixture; source-free CI skips this local integration proof")
        }
        let pythonExecutable = "/opt/homebrew/opt/python@3.13/bin/python3.13"
        guard FileManager.default.isExecutableFile(atPath: pythonExecutable) else {
            throw XCTSkip("missing local python@3.13 executable for tokenizer fixture")
        }

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
            executable: pythonExecutable,
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
        let expectedProjectionKeys = [
            "self_attn.q_proj",
            "self_attn.k_proj",
            "self_attn.v_proj",
            "self_attn.o_proj",
            "mlp.gate_proj",
            "mlp.up_proj",
            "mlp.down_proj"
        ]

        XCTAssertEqual(config.scale, 20)
        XCTAssertEqual(config.maxSeqLength, 8192)
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
        XCTAssertTrue(config.renderYAML.contains("scale: 20.0"))
        XCTAssertTrue(config.renderYAML.contains("training_loop: maformac_c5_repo_loop_mlx_lm_0_31_1"))
        XCTAssertTrue(config.renderYAML.contains("learning_rate: 0.0001"))
        XCTAssertEqual(config.lrScheduleStepUnit, "optimizer_update")
        XCTAssertEqual(config.optimizerUpdateSteps, 150)
        XCTAssertEqual(config.renderedScheduleDecaySteps, 150)
        XCTAssertEqual(config.renderedWarmupSteps, 12)
        XCTAssertTrue(config.renderYAML.contains("# optimizer_update_steps: 150"))
        XCTAssertTrue(config.renderYAML.contains("warmup: 12"))
        XCTAssertEqual(C5MLXLoRAConfig.defaultProjectionKeys, expectedProjectionKeys)
        XCTAssertEqual(Set(config.keys), Set(expectedProjectionKeys))
        XCTAssertEqual(config.keys.count, 7)
        XCTAssertFalse(config.keys == ["self_attn.q_proj", "self_attn.v_proj"])
    }

    func testTrainsFullAssistantToolCallPayload() throws {
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [
                semanticSeed(id: "loss-mask-row", fuzzy: true, free: false, slotKeys: ["position"], range: "position=主驾|副驾")
            ],
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0)
        )
        let sample = prepared.samples[0]
        let record = sample.mlxRecord
        let encoded = try JSONEncoder().encode(record)
        let json = String(decoding: encoded, as: UTF8.self)

        XCTAssertEqual(record.lossMask.ignoreIndex, -100)
        XCTAssertEqual(record.lossMask.tokenLabelSource, "runtime_tokenizer_offsets")
        XCTAssertEqual(record.lossMask.enforcement, "token_labels_enforced_after_tokenization_with_think_mask")
        XCTAssertEqual(record.lossObjectiveProfile, .assistantFullExceptThink)
        XCTAssertTrue(record.lossMask.trainableSpans.contains { $0.kind == "assistant_non_think_payload" && $0.text.contains("<tool_call>") })
        XCTAssertTrue(record.lossMask.trainableSpans.contains { $0.text.contains("\"name\"") && $0.text.contains("\"arguments\"") })
        XCTAssertTrue(record.lossMask.trainableSpans.contains { $0.text.contains("\"position\":\"主驾\"") })
        XCTAssertEqual(prepared.receipt.supervisionCoverageDigest.status, "pass")
        XCTAssertGreaterThanOrEqual(prepared.receipt.supervisionCoverageDigest.trainableNonThinkRatio, 0.90)
        XCTAssertTrue(json.contains("\"loss_objective_profile\":\"assistant_full_except_think\""))
        XCTAssertTrue(json.contains("\"augmentation_profile\""))
        XCTAssertTrue(json.contains("\"token_label_source\":\"runtime_tokenizer_offsets\""))
        XCTAssertFalse(json.contains("\"labels\""))
    }

    func testPromptAndUserRemainIgnored() {
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [semanticSeed(id: "prompt-ignore-row", fuzzy: true, free: false)],
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0)
        )
        let sample = prepared.samples[0]
        let maskText = sample.lossMask.trainableSpans.map(\.text).joined(separator: "\n")

        XCTAssertFalse(maskText.contains("MAformac 离线 mock"))
        XCTAssertFalse(maskText.contains("device=ac"))
        XCTAssertFalse(maskText.contains("请按这个语义执行"))
        XCTAssertEqual(prepared.receipt.supervisionCoverageDigest.promptLeakageCount, 0)
        XCTAssertEqual(prepared.receipt.supervisionCoverageDigest.userLeakageCount, 0)
        XCTAssertEqual(prepared.receipt.supervisionCoverageDigest.systemLeakageCount, 0)
    }

    func testNoToolRowsFullNoToolOnly() {
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: (0..<20).map { semanticSeed(id: "no-tool-\($0)", fuzzy: true, free: false) },
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 20, devSelectionRows: 0)
        )
        let noTool = prepared.samples.first { $0.expectedToolCalls.isEmpty }!
        let maskText = noTool.lossMask.trainableSpans.map(\.text).joined(separator: "\n")

        XCTAssertEqual(noTool.lossObjectiveProfile, .noToolFull)
        XCTAssertEqual(maskText.trimmingCharacters(in: .whitespacesAndNewlines), "NO_TOOL")
        XCTAssertFalse(maskText.contains("<tool_call>"))
    }

    func testAugmentationFlagsDoNotDefineLossObjective() {
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [semanticSeed(id: "aug-row", fuzzy: true, free: false, slotKeys: [], valueType: "")],
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0)
        )
        let sample = prepared.samples[0]

        XCTAssertEqual(sample.lossObjectiveProfile, .assistantFullExceptThink)
        XCTAssertFalse(sample.augmentationProfile.argumentValue)
        XCTAssertTrue(sample.lossMask.trainableSpans.contains { $0.text.contains("<tool_call>") })
        XCTAssertTrue(sample.lossMask.trainableSpans.contains { $0.text.contains("\"arguments\"") })
    }

    func testCoverageFailsWhenWrapperUntrained() {
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [semanticSeed(id: "coverage-fail-row", fuzzy: true, free: false)],
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0)
        )
        var sample = prepared.samples[0]
        sample.lossObjectiveProfile = .diagnosticSpanOnly
        let digest = C5SupervisionCoverageDigest.evaluate(samples: [sample])

        XCTAssertEqual(digest.status, "fail")
        XCTAssertEqual(digest.parserCriticalStatus, "fail")
        XCTAssertEqual(digest.ratioStatus, "fail")
        XCTAssertTrue(digest.parserCriticalFailures.contains { $0.contains("parser_critical_untrained:<tool_call>") })
        XCTAssertTrue(digest.failureReceipt.contains { $0.contains("assistant_non_think_trainable_ratio_below") })
    }

    func testThinkSpanIsAlwaysIgnoredByLossMaskEvenWhenToolCallSpanTrains() {
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [semanticSeed(id: "think-mask-row", fuzzy: true, free: false)],
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0)
        )
        var sample = prepared.samples[0]
        let toolCall = sample.assistantPayload.trimmingCharacters(in: .whitespacesAndNewlines)
        sample.messages[sample.messages.count - 1] = C5TrainingMessage(
            role: "assistant",
            content: "<think>内部推理不要训练</think>\n\n\(toolCall)"
        )
        let mask = sample.lossMask

        XCTAssertEqual(mask.maskedThinkSpans.count, 1)
        XCTAssertTrue(mask.maskedThinkSpans.contains { $0.text.contains("内部推理不要训练") })
        XCTAssertTrue(mask.trainableSpans.contains { $0.kind == "assistant_non_think_payload" && $0.text.contains("<tool_call>") })
        XCTAssertFalse(mask.trainableSpans.contains { $0.text.contains("内部推理") })
    }

    func testSmokeOnlyLossMaskKeepsAllLabelsIgnored() {
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [semanticSeed(id: "smoke-mask-row", fuzzy: true, free: false)],
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0, maskingStage: .smokeOnly)
        )
        let mask = prepared.samples[0].lossMask

        XCTAssertEqual(mask.enforcement, "all_masked_not_train_eligible")
        XCTAssertTrue(mask.trainableSpans.isEmpty)
        XCTAssertEqual(mask.tokenLabelSource, "runtime_tokenizer_offsets")
    }

    func testRenderedTrainCommandRequiresMAformacLossMaskPreflight() throws {
        let cli = try readRepoFile("Tools/C5TrainingCLI/main.swift")

        XCTAssertTrue(cli.contains("--require-maformac-loss-mask \\"))
        XCTAssertFalse(cli.contains("--mask-prompt \\"))
    }

    func testPythonTrainingLoopFailsClosedWhenLossMaskPreflightEnabled() throws {
        let loop = try readRepoFile("Tools/C5TrainingCLI/c5_mlx_train_loop.py")

        XCTAssertTrue(loop.contains("parser.add_argument(\"--require-maformac-loss-mask\", action=\"store_true\")"))
        XCTAssertTrue(loop.contains("parser.add_argument(\"--preflight-loss-mask-only\", action=\"store_true\")"))
        XCTAssertTrue(loop.contains("parser.add_argument(\"--allow-legacy-loss-objective\", action=\"store_true\")"))
        XCTAssertTrue(loop.contains("def guard_stock_loader_rejects_loss_mask"))
        XCTAssertTrue(loop.contains("loss_mask_present_but_flag_missing"))
        XCTAssertTrue(loop.contains("loss_objective_profile_missing"))
        XCTAssertTrue(loop.contains("legacy_loss_objective_allowed"))
        XCTAssertTrue(loop.contains("def load_maformac_loss_mask_datasets"))
        XCTAssertTrue(loop.contains("def build_maformac_token_labels"))
        XCTAssertTrue(loop.contains("def maformac_masked_loss"))
        XCTAssertTrue(loop.contains("loss=maformac_masked_loss if args.require_maformac_loss_mask else default_loss"))
        XCTAssertTrue(loop.contains("loss_mask = record.get(\"loss_mask\")"))
        XCTAssertTrue(loop.contains("char_indexed_loss_mask_labels_forbidden"))
        XCTAssertTrue(loop.contains("raise LossMaskValidationError"))
        XCTAssertTrue(loop.contains("LOSS_MASK_PREFLIGHT_FAILED"))
    }

    func testPythonTrainingLoopRejectsMissingLossObjectiveWhenMaskRequired() throws {
        let repoRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let baseModelDir = URL(fileURLWithPath: "/Users/wanglei/.cache/huggingface/hub/models--mlx-community--Qwen3-1.7B-4bit/snapshots/3b1b1768f8f8cf8351c712464f906e86c2b8269e", isDirectory: true)
        guard FileManager.default.fileExists(atPath: baseModelDir.appendingPathComponent("tokenizer_config.json").path) else {
            throw XCTSkip("missing local Qwen3 tokenizer fixture; source-free CI skips this local integration proof")
        }
        let pythonExecutable = "/opt/homebrew/opt/python@3.13/bin/python3.13"
        guard FileManager.default.isExecutableFile(atPath: pythonExecutable) else {
            throw XCTSkip("missing local python@3.13 executable for loss objective fixture")
        }
        let temporary = try makeTemporaryDirectory()
        let modelDir = temporary.appendingPathComponent("qwen3-1_7b-training-tokenizer-patched", isDirectory: true)
        try createTrainingTokenizerPatch(sourceDir: baseModelDir, outputDir: modelDir)
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [semanticSeed(id: "missing_objective_full_toolcall", fuzzy: true, free: false)],
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0, usesTrainingTokenizerPatch: true)
        )
        let row = try mlxRecordJSONWithoutLossObjective(sample: prepared.samples[0]) + "\n"
        try row.write(to: temporary.appendingPathComponent("train.jsonl"), atomically: true, encoding: .utf8)

        let commonArguments = [
            repoRoot.appendingPathComponent("Tools/C5TrainingCLI/c5_mlx_train_loop.py").path,
            "--model", modelDir.path,
            "--data", temporary.path,
            "--require-maformac-loss-mask",
            "--preflight-loss-mask-only",
            "--train",
            "--allow-mlx-lm-version-mismatch"
        ]
        let failure = runProcess(executable: pythonExecutable, arguments: commonArguments, cwd: repoRoot)
        XCTAssertEqual(failure.status, 66, failure.stderr + failure.stdout)
        XCTAssertTrue(failure.stderr.contains("LOSS_MASK_PREFLIGHT_FAILED"), failure.stderr + failure.stdout)
        XCTAssertTrue(failure.stderr.contains("loss_objective_profile_missing"), failure.stderr + failure.stdout)

        let legacy = runProcess(
            executable: pythonExecutable,
            arguments: commonArguments + ["--allow-legacy-loss-objective"],
            cwd: repoRoot
        )
        XCTAssertEqual(legacy.status, 0, legacy.stderr + legacy.stdout)
        XCTAssertTrue(legacy.stdout.contains(#""legacy_loss_objective_allowed": true"#), legacy.stderr + legacy.stdout)
        XCTAssertTrue(legacy.stdout.contains(#""legacy_loss_objective_record_count": 1"#), legacy.stderr + legacy.stdout)
    }

    func testPythonTrainingLoopRejectsLossMaskRowsWhenFlagMissing() throws {
        let repoRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let pythonExecutable = "/opt/homebrew/opt/python@3.13/bin/python3.13"
        guard FileManager.default.isExecutableFile(atPath: pythonExecutable) else {
            throw XCTSkip("missing local python@3.13 executable for loss-mask reverse guard")
        }
        let temporary = try makeTemporaryDirectory()
        let row = #"{"text":"masked row","loss_mask":{"ignore_index":-100,"trainable_spans":[]}}"# + "\n"
        try row.write(to: temporary.appendingPathComponent("train.jsonl"), atomically: true, encoding: .utf8)
        try "{}\n".write(to: temporary.appendingPathComponent("valid.jsonl"), atomically: true, encoding: .utf8)

        let result = runProcess(
            executable: pythonExecutable,
            arguments: [
                repoRoot.appendingPathComponent("Tools/C5TrainingCLI/c5_mlx_train_loop.py").path,
                "--model", "dummy-model-never-loaded",
                "--data", temporary.path,
                "--train",
                "--allow-mlx-lm-version-mismatch"
            ],
            cwd: repoRoot
        )

        XCTAssertEqual(result.status, 66, result.stderr + result.stdout)
        XCTAssertTrue(result.stderr.contains("LOSS_MASK_PREFLIGHT_FAILED"), result.stderr + result.stdout)
        XCTAssertTrue(result.stderr.contains("loss_mask_present_but_flag_missing"), result.stderr + result.stdout)
    }

    func testPythonTrainingLoopRejectsTestLossMaskRowsWhenFlagMissing() throws {
        let repoRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let pythonExecutable = "/opt/homebrew/opt/python@3.13/bin/python3.13"
        guard FileManager.default.isExecutableFile(atPath: pythonExecutable) else {
            throw XCTSkip("missing local python@3.13 executable for loss-mask reverse guard")
        }
        let temporary = try makeTemporaryDirectory()
        let row = #"{"text":"masked eval row","loss_mask":{"ignore_index":-100,"trainable_spans":[]}}"# + "\n"
        try "{}\n".write(to: temporary.appendingPathComponent("train.jsonl"), atomically: true, encoding: .utf8)
        try "{}\n".write(to: temporary.appendingPathComponent("valid.jsonl"), atomically: true, encoding: .utf8)
        try row.write(to: temporary.appendingPathComponent("test.jsonl"), atomically: true, encoding: .utf8)

        let result = runProcess(
            executable: pythonExecutable,
            arguments: [
                repoRoot.appendingPathComponent("Tools/C5TrainingCLI/c5_mlx_train_loop.py").path,
                "--model", "dummy-model-never-loaded",
                "--data", temporary.path,
                "--test",
                "--allow-mlx-lm-version-mismatch"
            ],
            cwd: repoRoot
        )

        XCTAssertEqual(result.status, 66, result.stderr + result.stdout)
        XCTAssertTrue(result.stderr.contains("LOSS_MASK_PREFLIGHT_FAILED"), result.stderr + result.stdout)
        XCTAssertTrue(result.stderr.contains("loss_mask_present_but_flag_missing"), result.stderr + result.stdout)
    }

    func testPythonTrainingLoopDoesNotRejectUnmaskedStockTestRows() throws {
        let repoRoot = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
        let pythonExecutable = "/opt/homebrew/opt/python@3.13/bin/python3.13"
        guard FileManager.default.isExecutableFile(atPath: pythonExecutable) else {
            throw XCTSkip("missing local python@3.13 executable for loss-mask reverse guard")
        }
        let temporary = try makeTemporaryDirectory()
        try "{}\n".write(to: temporary.appendingPathComponent("train.jsonl"), atomically: true, encoding: .utf8)
        try "{}\n".write(to: temporary.appendingPathComponent("valid.jsonl"), atomically: true, encoding: .utf8)
        try "{}\n".write(to: temporary.appendingPathComponent("test.jsonl"), atomically: true, encoding: .utf8)

        let result = runProcess(
            executable: pythonExecutable,
            arguments: [
                repoRoot.appendingPathComponent("Tools/C5TrainingCLI/c5_mlx_train_loop.py").path,
                "--model", "dummy-model-never-loaded",
                "--data", temporary.path,
                "--test",
                "--allow-mlx-lm-version-mismatch"
            ],
            cwd: repoRoot
        )

        XCTAssertNotEqual(result.status, 66, result.stderr + result.stdout)
        XCTAssertFalse(result.stderr.contains("LOSS_MASK_PREFLIGHT_FAILED"), result.stderr + result.stdout)
        XCTAssertFalse(result.stderr.contains("loss_mask_present_but_flag_missing"), result.stderr + result.stdout)
    }

    func testPythonTrainingLoopHasSyntheticLossMaskSelfTest() throws {
        let loop = try readRepoFile("Tools/C5TrainingCLI/c5_mlx_train_loop.py")

        XCTAssertTrue(loop.contains("parser.add_argument(\"--self-test-loss-mask\", action=\"store_true\")"))
        XCTAssertTrue(loop.contains("def maformac_masked_cross_entropy_from_logits"))
        XCTAssertTrue(loop.contains("def run_loss_mask_self_test"))
        XCTAssertTrue(loop.contains("\"event\": \"loss_mask_self_test\""))
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

    // MARK: - A2 S4 D-domain surface(paradigm §1: name=intent, value 形态编码进名, 同族 distractor, removedToolID 真删)

    private func a2RepoRoot() -> URL {
        URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
    }

    private func readRepoFile(_ relativePath: String) throws -> String {
        let url = a2RepoRoot().appendingPathComponent(relativePath)
        return try String(contentsOf: url, encoding: .utf8)
    }

    private func loadDemoCatalog() throws -> [DDomainToolEntry] {
        try ToolContractCompiler.loadDDomainCatalog(repoRoot: a2RepoRoot())   // 562 demo D-domain 具名工具
    }

    private struct TestSubsetManifest: Decodable {
        var entries: [Entry]

        struct Entry: Decodable {
            var subsetPolicyID: String
            var groupID: String
            var mountMode: String
            var toolIDsOrdered: [String]

            enum CodingKeys: String, CodingKey {
                case subsetPolicyID = "subset_policy_id"
                case groupID = "group_id"
                case mountMode = "mount_mode"
                case toolIDsOrdered = "tool_ids_ordered"
            }
        }
    }

    private func subsetManifestEntry(containing toolID: String) throws -> TestSubsetManifest.Entry {
        let url = a2RepoRoot().appendingPathComponent("generated/subset-policy-manifest.json")
        let manifest = try JSONDecoder().decode(TestSubsetManifest.self, from: Data(contentsOf: url))
        return try XCTUnwrap(
            manifest.entries.first { $0.mountMode == "single_group" && $0.toolIDsOrdered.contains(toolID) },
            "expected \(toolID) to be covered by a single_group manifest entry"
        )
    }

    private func writeSubsetManifest(
        toolIDsOrdered: [String],
        policyID: String = "e2-lite-v1",
        to url: URL
    ) throws {
        let encodedToolIDs = toolIDsOrdered.map { "\"\($0)\"" }.joined(separator: ",")
        let text = """
        {"entries":[{"subset_policy_id":"\(policyID)","group_id":"test-group","mount_mode":"single_group","tool_ids_ordered":[\(encodedToolIDs)],"distractor_policy":{"strategy":"same_sg_then_same_domain_then_other","k":3}}]}
        """
        try text.write(to: url, atomically: true, encoding: .utf8)
    }

    private func rawSeed(id: String, intent: String, device: String, actionPrimitive: String = "power_on", valueType: String = "EXP", slotKeys: [String] = ["device"]) -> C5SemanticSeed {
        let encodedSlotKeys = slotKeys.map { "\"\($0)\"" }.joined(separator: ",")
        let json = """
        {"contract_row_id":"\(id)","canonical_semantic_id":"sem-\(id)","dedupe_group_id":"dedupe-\(id)","dedupe_role":"primary","device":"\(device)","action_primitive":"\(actionPrimitive)","action_code":"\(intent)","intent":"\(intent)","service":"x","exec_tier":"L2","fc_flags":{"fuzzy":false,"free":false},"slot_keys":[\(encodedSlotKeys)],"value":{"ref":"ZERO","direct":"+","offset":"ON","type":"\(valueType)"},"source_domain":"x","source_sheet":"x","source_row_no":1,"range":""}
        """
        return try! JSONDecoder().decode(C5SemanticSeed.self, from: Data(json.utf8))
    }

    // 🔴 S5 审计 P1-1 闭合: C5/C6 值键 parity 第三腿(emit 侧)。matcher 是 surface-string 字面键比对 →
    // C5 emit 侧对异构值键(ac_temperature→temperature / ac_windspeed→fanSpeed, 非 value)必须实产同键,
    // 否则训了 value=24 评了 temperature=24 = 0/N 换皮(S4 emit 测只覆盖 value 键工具, 漏异构键)。
    func testC5EmitsHeterogeneousValueKeyMatchingC6ForNumberIntents() throws {
        let catalog = try loadDemoCatalog()
        // ac_temperature number: 真实 contract slot_keys=[adjustment_mode, temperature](value.type 空, 数字走 temperature 槽非 value)
        let tempSeed = rawSeed(id: "ac-temp-1", intent: "adjust_ac_temperature_to_number", device: "ac_temperature", actionPrimitive: "adjust_to_number", valueType: "", slotKeys: ["adjustment_mode", "temperature"])
        let tempPrepared = C5TrainingDatasetBuilder().build(
            seeds: [tempSeed], c6Cases: [], dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0, includeNoCallCounterfactuals: false, surface: .dDomain, dDomainCatalog: catalog)
        )
        let tempCall = tempPrepared.samples.first { $0.split == "train" }?.expectedToolCalls.first
        XCTAssertEqual(tempCall?.name, "adjust_ac_temperature_to_number")
        XCTAssertNotNil(tempCall?.arguments["temperature"], "C5 emit ac_temperature number 用 temperature 键(与 C6 expected 同源, matcher 字面比对)")
        XCTAssertNil(tempCall?.arguments["value"], "C5 emit 不用 value 键(ac_temperature 值键是 temperature, 防 0/N 换皮)")

        // ac_windspeed number: 真实 contract slot_keys=[fanSpeed]
        let fanSeed = rawSeed(id: "ac-fan-1", intent: "adjust_ac_windspeed_to_number", device: "ac_windspeed", actionPrimitive: "adjust_to_number", valueType: "", slotKeys: ["fanSpeed"])
        let fanPrepared = C5TrainingDatasetBuilder().build(
            seeds: [fanSeed], c6Cases: [], dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0, includeNoCallCounterfactuals: false, surface: .dDomain, dDomainCatalog: catalog)
        )
        let fanCall = fanPrepared.samples.first { $0.split == "train" }?.expectedToolCalls.first
        XCTAssertEqual(fanCall?.name, "adjust_ac_windspeed_to_number")
        XCTAssertNotNil(fanCall?.arguments["fanSpeed"], "C5 emit ac_windspeed number 用 fanSpeed 键(与 C6 expected 同源)")
        XCTAssertNil(fanCall?.arguments["value"], "C5 emit 不用 value 键(ac_windspeed 值键是 fanSpeed)")
    }

    // cut1+cut2: surface=.dDomain → name=seed.intent(D-domain), tools=目标具名工具+同族 distractor, 无 generic frame
    func testDDomainSurfaceEmitsIntentAsToolNameNotFrame() throws {
        let catalog = try loadDemoCatalog()
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [semanticSeed(id: "ac-1", fuzzy: false, free: false, device: "ac")],   // intent=open_ac ∈ 562
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0, includeNoCallCounterfactuals: false, surface: .dDomain, dDomainCatalog: catalog)
        )
        let positive = prepared.samples.first { $0.split == "train" }
        XCTAssertEqual(positive?.expectedToolCalls.first?.name, "open_ac", "cut1: name=seed.intent(D-domain 具名工具)")
        let toolNames = (positive?.tools ?? []).compactMap { functionName($0) }
        XCTAssertTrue(toolNames.contains("open_ac"), "cut2: 目标 D-domain 工具在 tools surface")
        XCTAssertFalse(toolNames.contains("tool_call_frame"), "surface=.dDomain 不渲 generic frame")
        XCTAssertFalse(toolNames.contains(where: { $0.hasPrefix("irrelevant_") }), "distractor 改同族 D-domain, 非 irrelevant 占位")
    }

    // cut2: 同族 distractor ∈ 562 catalog(非 irrelevant 占位), 不含目标自身
    func testDDomainDistractorsAreRealCatalogToolsSameFamily() throws {
        let catalog = try loadDemoCatalog()
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [semanticSeed(id: "ac-1", fuzzy: false, free: false, device: "ac")],
            c6Cases: [], dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0, includeNoCallCounterfactuals: false, surface: .dDomain, dDomainCatalog: catalog)
        )
        let positive = prepared.samples.first { $0.split == "train" }
        let distractorNames = positive?.promptDistractorToolIDs ?? []
        XCTAssertFalse(distractorNames.isEmpty, "有同族 distractor")
        let catalogNames = Set(catalog.map(\.function.name))
        XCTAssertTrue(distractorNames.allSatisfy { catalogNames.contains($0) }, "distractor ∈ 562 D-domain catalog(非 irrelevant 占位)")
        XCTAssertFalse(distractorNames.contains("open_ac"), "distractor 不含目标工具自身")
    }

    // G7D: C5 prompt surface 从 subset manifest 装载目标所在 single_group，而不是手写 target+distractors。
    func testDDomainSurfaceMountsManifestGroupAndMetadataDigest() throws {
        let catalog = try loadDemoCatalog()
        let manifestEntry = try subsetManifestEntry(containing: "open_ac")
        let manifestURL = a2RepoRoot().appendingPathComponent("generated/subset-policy-manifest.json")
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [semanticSeed(id: "ac-1", fuzzy: false, free: false, device: "ac")],
            c6Cases: [], dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0, includeNoCallCounterfactuals: false, surface: .dDomain, dDomainCatalog: catalog)
        )
        let positive = try XCTUnwrap(prepared.samples.first { $0.split == "train" })
        let toolNames = positive.tools.compactMap { functionName($0) }
        XCTAssertEqual(toolNames, manifestEntry.toolIDsOrdered, "G7D: mounted prompt tools follow manifest tool_ids_ordered exactly")
        XCTAssertEqual(positive.subsetPolicyID, manifestEntry.subsetPolicyID)
        XCTAssertEqual(positive.subsetGroupID, manifestEntry.groupID)
        XCTAssertEqual(positive.mountedToolCount, manifestEntry.toolIDsOrdered.count)
        XCTAssertEqual(positive.subsetPolicyDigest, try C6Hash.fileHash(url: manifestURL))
    }

    func testDDomainDistractorsFollowManifestSameSGPriority() throws {
        let catalog = try loadDemoCatalog()
        let target = try XCTUnwrap(catalog.first { $0.function.name == "open_ac" })
        let sameSG = catalog
            .filter { $0.function.name != "open_ac" && $0.sg == target.sg }
            .map(\.function.name)
            .sorted()
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [semanticSeed(id: "ac-1", fuzzy: false, free: false, device: "ac")],
            c6Cases: [], dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0, includeNoCallCounterfactuals: false, surface: .dDomain, dDomainCatalog: catalog)
        )
        let positive = try XCTUnwrap(prepared.samples.first { $0.split == "train" })
        let expected = Array(sameSG.prefix(min(3, sameSG.count)))
        XCTAssertEqual(positive.promptDistractorToolIDs, expected, "S-207: same_sg_then_same_domain_then_other,k=3 starts with same _sg")
    }

    func testDDomainSubsetManifestMissingIsFailClosed() throws {
        let catalog = try loadDemoCatalog()
        let missingPath = try makeTemporaryDirectory().appendingPathComponent("missing-subset-policy-manifest.json").path
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [semanticSeed(id: "ac-1", fuzzy: false, free: false, device: "ac")],
            c6Cases: [], dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0, includeNoCallCounterfactuals: false, surface: .dDomain, dDomainCatalog: catalog, subsetPolicyManifestPath: missingPath)
        )
        XCTAssertTrue(prepared.samples.isEmpty, "manifest missing must not silently fall back to legacy frame or target+distractors")
        XCTAssertTrue(prepared.receipt.failureReceipt.contains("subset_manifest_missing"))
    }

    func testDDomainSubsetManifestTargetMissingIsFailClosed() throws {
        let catalog = try loadDemoCatalog()
        let tempDir = try makeTemporaryDirectory()
        let manifestURL = tempDir.appendingPathComponent("subset-policy-manifest.json")
        try writeSubsetManifest(toolIDsOrdered: ["close_ac"], to: manifestURL)
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [semanticSeed(id: "ac-1", fuzzy: false, free: false, device: "ac")],
            c6Cases: [], dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0, includeNoCallCounterfactuals: false, surface: .dDomain, dDomainCatalog: catalog, subsetPolicyManifestPath: manifestURL.path)
        )
        XCTAssertTrue(prepared.samples.isEmpty, "target not in any manifest single_group must fail closed")
        XCTAssertTrue(prepared.receipt.failureReceipt.contains("subset_manifest_target_missing"))
    }

    func testDDomainSubsetManifestWrongPolicyProbe() throws {
        let catalog = try loadDemoCatalog()
        let tempDir = try makeTemporaryDirectory()
        let manifestURL = tempDir.appendingPathComponent("subset-policy-manifest.json")
        let text = """
        {"entries":[{"subset_policy_id":"e2-lite-v1","group_id":"test-good","mount_mode":"single_group","tool_ids_ordered":["open_ac","close_ac"],"distractor_policy":{"strategy":"same_sg_then_same_domain_then_other","k":3}},{"subset_policy_id":"wrong-policy","group_id":"test-wrong","mount_mode":"single_group","tool_ids_ordered":["close_ac"],"distractor_policy":{"strategy":"same_sg_then_same_domain_then_other","k":3}}]}
        """
        try text.write(to: manifestURL, atomically: true, encoding: .utf8)
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [semanticSeed(id: "ac-1", fuzzy: false, free: false, device: "ac")],
            c6Cases: [], dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0, includeNoCallCounterfactuals: false, surface: .dDomain, dDomainCatalog: catalog, subsetPolicyManifestPath: manifestURL.path)
        )
        XCTAssertTrue(prepared.samples.isEmpty, "any wrong subset_policy_id must fail closed before mounting tools")
        XCTAssertTrue(prepared.receipt.failureReceipt.contains("subset_policy_mismatch"))
    }

    // cut1: 值形态工具 emit value arg; device/action_primitive 不 emit(编码进名); arg 键 ∈ schema(additionalProperties:false)
    func testDDomainEmitsValueArgAndOnlySchemaKeys() throws {
        let catalog = try loadDemoCatalog()
        let seed = rawSeed(id: "scr-1", intent: "adjust_blue_ray_filtering_to_gear", device: "blue_ray_filtering", valueType: "PERCENT")
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [seed], c6Cases: [], dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0, includeNoCallCounterfactuals: false, surface: .dDomain, dDomainCatalog: catalog)
        )
        let call = prepared.samples.first { $0.split == "train" }?.expectedToolCalls.first
        XCTAssertEqual(call?.name, "adjust_blue_ray_filtering_to_gear")
        let args = call?.arguments ?? [:]
        XCTAssertNotNil(args["value"], "值形态工具 emit value arg(S1 derive_arg_schema 统一命名 value)")
        XCTAssertNil(args["device"], "device 不 emit(编码进工具名)")
        XCTAssertNil(args["action_primitive"], "action 不 emit(编码进工具名)")
        let entry = catalog.first { $0.function.name == "adjust_blue_ray_filtering_to_gear" }!
        let props = try toolProperties(C5TrainingRenderer.dDomainToolSchema(entry))
        for key in args.keys {
            XCTAssertTrue(props.keys.contains(key), "emit arg \(key) ∈ tool schema properties(additionalProperties:false 合规)")
        }
    }

    // cut4: scope=.demo → 562 allowlist 过滤 562 外 intent
    func testDDomainScopeDemoFiltersOutOfCatalogIntents() throws {
        let catalog = try loadDemoCatalog()
        let inSeed = semanticSeed(id: "ac-1", fuzzy: false, free: false, device: "ac")   // intent=open_ac ∈ 562
        let outSeed = rawSeed(id: "x-1", intent: "nonexistent_intent_zzz", device: "navi")
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [inSeed, outSeed], c6Cases: [], dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 20, devSelectionRows: 0, includeNoCallCounterfactuals: false, scope: .demo, surface: .dDomain, dDomainCatalog: catalog)
        )
        let names = Set(prepared.samples.compactMap { $0.expectedToolCalls.first?.name })
        XCTAssertTrue(names.contains("open_ac"), "562 内 intent 保留")
        XCTAssertFalse(names.contains("nonexistent_intent_zzz"), "scope=.demo 过滤 562 外 intent(unsupported 兜底走别处)")
    }

    // cut5: no-call 反事实物理删目标工具(非只 metadata 声称) + 活样本 targetToolPresent=false(修 446 假删灾难 variant)
    func testDDomainNoCallCounterfactualPhysicallyRemovesTargetTool() throws {
        let catalog = try loadDemoCatalog()
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [semanticSeed(id: "ac-1", fuzzy: false, free: false, device: "ac")],
            c6Cases: [], dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 8, devSelectionRows: 0, refusalRatioTarget: 0.3, refusalRatioHardCap: 0.5, includeNoCallCounterfactuals: true, surface: .dDomain, dDomainCatalog: catalog)
        )
        let noCall = prepared.samples.first { $0.noCall != nil }
        XCTAssertNotNil(noCall, "生成 no-call 反事实")
        let removed = noCall?.noCall?.removedToolID ?? ""
        XCTAssertEqual(removed, "open_ac", "cut5: removedToolID=被移除的 D-domain 目标工具名(非硬编码 tool_call_frame)")
        let toolNames = (noCall?.tools ?? []).compactMap { functionName($0) }
        XCTAssertFalse(toolNames.contains(removed), "cut5 真删: 目标工具物理不在 tools(非只 metadata removedToolID 声称)")
        XCTAssertEqual(noCall?.noCall?.targetToolPresent, false, "活样本: targetToolPresent=false 与产物一致(claim-vs-reality 铁律1)")
    }

    // 🔴 P1(GPT Pro+GLM 审计共识)闭合: surface=.dDomain + catalog 非空 + intent miss → fail-closed skip(不 fallback frame 污染 A2 surface)
    func testDDomainCatalogMissIsFailClosedNotFrameFallback() throws {
        let catalog = try loadDemoCatalog()
        // scope=.full 不过滤 → miss-intent seed 到达 makePositiveSample; surface=.dDomain + catalog 非空 → 走 fail-closed 分支
        let inSeed = semanticSeed(id: "ac-1", fuzzy: false, free: false, device: "ac")   // intent=open_ac ∈ 562
        let missSeed = rawSeed(id: "miss-1", intent: "nonexistent_intent_zzz", device: "navi")
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [inSeed, missSeed], c6Cases: [], dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 20, devSelectionRows: 0, includeNoCallCounterfactuals: false, scope: .full, surface: .dDomain, dDomainCatalog: catalog)
        )
        let names = Set(prepared.samples.flatMap { $0.expectedToolCalls.map(\.name) })
        XCTAssertTrue(names.contains("open_ac"), "in-catalog intent 产 D-domain sample")
        XCTAssertFalse(names.contains("nonexistent_intent_zzz"), "miss intent 不产样本(fail-closed skip)")
        XCTAssertFalse(names.contains("tool_call_frame"), "🔴 miss intent 不 fallback frame(P1 fail-closed, 不污染 A2 surface, 非旧 stderr+frame)")
    }

    // 向后兼容: 空 catalog(默认无注入)→ frame legacy 回退(strangler 旧 surface 保留)
    func testFrameSurfaceBackwardCompatWhenCatalogEmpty() {
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [semanticSeed(id: "ac-1", fuzzy: false, free: false, device: "ac")],
            c6Cases: [], dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0, includeNoCallCounterfactuals: false)
        )
        let positive = prepared.samples.first { $0.split == "train" }
        XCTAssertEqual(positive?.expectedToolCalls.first?.name, "tool_call_frame", "空 catalog → frame legacy(向后兼容, strangler)")
    }

    private func semanticSeed(
        id: String,
        fuzzy: Bool,
        free: Bool,
        execTier: String = "L2",
        device: String = "ac",
        actionPrimitive: String = "power_on",
        slotKeys: [String] = ["device"],
        valueType: String = "EXP",
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
        {"contract_row_id":"\(id)","canonical_semantic_id":"sem-\(id)","dedupe_group_id":"dedupe-\(id)","dedupe_role":"primary","device":"\(device)","action_primitive":"\(actionPrimitive)","action_code":"open_ac","intent":"open_ac","service":"airControl","exec_tier":"\(execTier)","fc_flags":{"fuzzy":\(fuzzy),"free":\(free)},"slot_keys":[\(encodedSlotKeys)],"value":{"ref":"ZERO","direct":"+","offset":"ON","type":"\(valueType)"},"source_domain":"airControl","source_sheet":"airControl","source_row_no":1,"range":"\(range)"\(dsProtocol)}
        """
        return try! JSONDecoder().decode(C5SemanticSeed.self, from: Data(json.utf8))
    }

    private func toolProperties(_ tool: [String: JSONValue]) throws -> [String: JSONValue] {
        guard case let .object(function)? = tool["function"],
              case let .object(parameters)? = function["parameters"],
              case let .object(properties)? = parameters["properties"] else {
            XCTFail("tool schema missing function.parameters.properties")
            return [:]
        }
        return properties
    }

    private func functionName(_ tool: [String: JSONValue]) -> String? {
        guard case let .object(function)? = tool["function"],
              case let .string(name)? = function["name"] else {
            return nil
        }
        return name
    }

    private func propertyEnum(_ properties: [String: JSONValue], _ key: String) -> [String] {
        guard case let .object(schema)? = properties[key],
              case let .array(values)? = schema["enum"] else {
            return []
        }
        return jsonStringArray(values)
    }

    private func jsonStringArray(_ values: [JSONValue]) -> [String] {
        values.compactMap { value in
            guard case let .string(text) = value else {
                return nil
            }
            return text
        }
    }

    private func context() -> C5DataGateRunContext {
        C5DataGateRunContext(
            sourceSnapshotDigest: "semantic-digest",
            sourceAuthorizationStatus: "authorized_c1_semantic_contract",
            formatContractVersion: "format-digest",
            generatedAt: "2026-06-21T00:00:00Z",
            allowLegacyMissingSurface: true
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

    private func canonicalNaturalToolCallFixture() -> (seed: C5SemanticSeed, call: C5TrainingToolCall) {
        let seed = semanticSeed(id: "row-natural", fuzzy: true, free: false)
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [seed],
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(targetPositiveRows: 1, devSelectionRows: 0, surface: .frame)
        )
        return (seed, prepared.samples[0].expectedToolCalls[0])
    }

    private func assertNaturalToolCallTargetMismatch(target: String, file: StaticString = #filePath, line: UInt = #line) {
        let seed = semanticSeed(id: "row-natural", fuzzy: true, free: false)
        let natural = C5NaturalToolCallRecord(
            contractRowID: "row-natural",
            variant: 0,
            user: "帮我开一下空调",
            target: target,
            generatorModelID: "hermes_glm",
            generatorSourceVendor: "volcengine",
            generatorCallID: "call-natural-bypass",
            semanticJudgeModelID: "gptpro",
            semanticJudgeCallID: "judge-natural-bypass",
            promptHash: "prompt-natural"
        )
        let prepared = C5TrainingDatasetBuilder().build(
            seeds: [seed],
            c6Cases: [],
            dataGateContext: context(),
            options: C5TrainingBuildOptions(
                targetPositiveRows: 1,
                devSelectionRows: 0,
                maxVariantsPerSeed: 1,
                naturalToolCallRecords: [natural],
                surface: .frame
            )
        )

        XCTAssertTrue(prepared.samples.isEmpty, file: file, line: line)
        XCTAssertTrue(prepared.receipt.failureReceipt.contains("natural_tool_call_target_mismatch"), file: file, line: line)
    }

    private func mlxRecordJSONWithoutLossObjective(sample: C5TrainingSample) throws -> String {
        let data = try JSONEncoder().encode(sample.mlxRecord)
        guard var object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            XCTFail("encoded mlx record is not a JSON object")
            return "{}"
        }
        object.removeValue(forKey: "loss_objective_profile")
        let patched = try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
        return String(decoding: patched, as: UTF8.self)
    }

    private func routeBalancedSeeds(prefix: String) -> [C5SemanticSeed] {
        (0..<70).map { semanticSeed(id: "\(prefix)-l2-\($0)", fuzzy: true, free: false) }
            + (0..<10).map { semanticSeed(id: "\(prefix)-l3-\($0)", fuzzy: false, free: true) }
            + (0..<30).map { semanticSeed(id: "\(prefix)-l1-\($0)", fuzzy: false, free: false) }
    }

    private func verifiedEnvironment() -> C5TrainingEnvironment {
        C5TrainingEnvironment.defaultPrepare(
            trainingLoopSourceState: "verified",
            trainingLoopSourceSHA256: "loop-sha",
            trainingLoopVerificationStatus: "pass",
            trainingLoopVerificationRef: "Reports/c5-pr2pr4pr5-20260621T235213/pr2-2b-equivalence/evidence-summary.md"
        )
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
