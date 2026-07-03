import Foundation
import MAformacCore

@main
struct Gate7DryRunCLI {
    static func main() throws {
        let options = try Options(arguments: CommandLine.arguments)
        let outputDir = URL(fileURLWithPath: options.outputDir, isDirectory: true)
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
        let result = try run(options: options)
        let receipt = result.receipt

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        try writeJSONLines(
            result.candidateRows,
            to: outputDir.appendingPathComponent(receipt.candidateRowsPath)
        )
        try encoder.encode(result.batchManifest).write(to: outputDir.appendingPathComponent(receipt.batchManifestPath))
        try encoder.encode(result.batchManifestDryRunReceipt).write(to: outputDir.appendingPathComponent(receipt.batchManifestDryRunReceiptPath))
        try encoder.encode(receipt).write(to: outputDir.appendingPathComponent("gate7-wave1-dry-run-receipt.json"))
        try renderMarkdown(receipt).write(
            to: outputDir.appendingPathComponent("gate7-wave1-dry-run-receipt.md"),
            atomically: true,
            encoding: .utf8
        )

        print("wrote \(outputDir.appendingPathComponent("gate7-wave1-dry-run-receipt.json").path)")
        print("wrote \(outputDir.appendingPathComponent("gate7-wave1-dry-run-receipt.md").path)")
        print("wrote \(outputDir.appendingPathComponent(receipt.batchManifestPath).path)")
        print("status=\(receipt.pipelineStatus) samples=\(receipt.sampleCount) data_gate=\(receipt.dataGateStatus) manifest=\(receipt.batchManifestDryRunStatus) quarantine=\(receipt.quarantineCount)")
    }

    private static func run(options: Options) throws -> DryRunResult {
        let repoRoot = URL(fileURLWithPath: options.repoRoot, isDirectory: true)
        let manifest = try JSONDecoder().decode(
            Gate7SubsetManifest.self,
            from: Data(contentsOf: repoRoot.appendingPathComponent("generated/subset-policy-manifest.json"))
        )
        let seed = try loadSeed(repoRoot: repoRoot, contractRowID: options.contractRowID)
        let catalog = try JSONDecoder().decode(
            [DDomainToolEntry].self,
            from: Data(contentsOf: repoRoot.appendingPathComponent("generated/D_domain.tools.demo.json"))
        )
        guard let toolEntry = catalog.first(where: { $0.function.name == seed.intent }) else {
            throw CLIError.message("target intent \(seed.intent) missing from D-domain demo catalog")
        }
        guard let manifestEntry = manifest.entries.first(where: { $0.toolIDsOrdered.contains(toolEntry.function.name) }) else {
            throw CLIError.message("target intent \(toolEntry.function.name) missing from subset manifest")
        }
        let mountedTools = try mountedToolSchemas(manifestEntry: manifestEntry, catalog: catalog)

        let limit = max(1, options.limit)
        let utterances = (0..<limit).map { index in
            dryRunUtterance(index: index)
        }
        let quarantine = C5DataGateCandidate(
            sampleID: "P5W-quarantine-001",
            split: "quarantine",
            bucket: "gate7_mock_quarantine",
            caseID: "P5W-quarantine-001",
            parentSemanticID: "p5w.quarantine.parent",
            candidateParentSemanticID: "p5w.quarantine.candidate",
            device: "mock_quarantine_device",
            toolName: "mock_quarantine_tool",
            valueType: "STATE",
            templateFamily: "gate7_mock_quarantine",
            generatorSource: "anthropic",
            generatorModelID: "gate7_mock_generator",
            generatorSourceVendor: "anthropic",
            mustNotTrain: true,
            sourceAuthorization: "authorized_gate7_mock_quarantine",
            inputText: "quarantine dry-run sample",
            assistantText: "",
            hasActionToolCall: false,
            hasSharedWrapper: false,
            masking: C5MaskingFlags(),
            tools: mountedTools,
            mountedToolCount: mountedTools.count,
            subsetPolicyID: manifestEntry.subsetPolicyID,
            subsetGroupID: manifestEntry.groupID,
            subsetPolicyDigest: manifest.meta.groupingContractDigest,
            promptHash: C5DerivedHashRecipe.promptHash(utterance: "quarantine dry-run sample"),
            hashRecipeRef: C5DerivedHashRecipe.hashRecipeRef,
            hashRecomputedByPipeline: true
        )
        let recipeQuota = Gate7RecipeQuotaConfig.wave1ConstructionAnchors
        let recipeAllocation = Gate7QuotaCalculator.allocate([
            Gate7QuotaInput(
                familyID: manifestEntry.groupID,
                intentBaseline: limit,
                bugPressure: 0,
                demoFloor: 0,
                safetyFloor: 0,
                recipeQuota: recipeQuota
            )
        ]).first
        let request = Gate7PipelineRequest(
            manifestMeta: manifest.meta,
            manifestEntry: manifestEntry,
            prompt: "P5W construction-only mock wave-1 dry-run",
            targetToolName: toolEntry.function.name,
            targetSemanticSeed: seed,
            targetToolEntry: toolEntry,
            mountedTools: mountedTools,
            device: seed.device,
            valueType: seed.value.type.isEmpty ? "SPOT" : seed.value.type,
            templateFamily: "p5w_gate7_mock_wave1",
            parentSemanticIDPrefix: "p5w.\(seed.device)",
            heldOutCandidates: [quarantine]
        )
        let pipeline = Gate7GeneratorPipeline(
            generator: Gate7MockLLMProvider(
                vendor: .anthropic,
                responsesByStage: [
                    .generator: Gate7ProviderResponse(status: .pass, utterances: utterances)
                ]
            ),
            judge: Gate7MockLLMProvider(
                vendor: .openai,
                responsesByStage: [
                    .judge: Gate7ProviderResponse(status: .pass)
                ]
            )
        )
        let pipelineReceipt = try pipeline.run(request)
        let firstCall = pipelineReceipt.samples.first?.expectedToolCalls.first
        let candidateRows = Gate7DecontaminationGate.candidates(samples: pipelineReceipt.samples, request: request)
            + request.heldOutCandidates
        let recipeAllocatedQuota = recipeAllocation?.quota ?? 0
        let recipeActualSampleCount = pipelineReceipt.samples.count
        let batchManifest = Wave1BatchManifestBuilder.warmup(
            batchID: options.batchID,
            mainPinSHA: options.mainPinSHA,
            laneID: options.laneID,
            laneVendor: "anthropic",
            generatorSourceVendor: "anthropic",
            judgeSourceVendorRequired: "openai",
            targetCount: 50,
            quotaConfig: recipeQuota
        )
        let batchManifestDryRunReceipt = Wave1BatchManifestBuilder.validateDryRun(batchManifest)
        let quotaEnforcement = Gate7QuotaEnforcer.enforce(
            status: pipelineReceipt.status,
            reasons: pipelineReceipt.reasons,
            allocatedQuota: recipeAllocatedQuota,
            actualGeneratedCount: recipeActualSampleCount
        )
        let receipt = DryRunReceipt(
            generatedAt: isoNow(),
            proofClass: "local_mock",
            repoRoot: repoRoot.path,
            contractRowID: seed.contractRowID,
            targetToolName: toolEntry.function.name,
            generatorVendor: "anthropic",
            judgeVendor: "openai",
            limit: limit,
            pipelineStatus: quotaEnforcement.status.rawValue,
            reasons: quotaEnforcement.reasons,
            sampleCount: recipeActualSampleCount,
            firstExpectedToolCall: firstCall,
            dataGateStatus: pipelineReceipt.dataGateReceipt?.status ?? "missing",
            dataGateRowCount: pipelineReceipt.dataGateReceipt?.rowCount ?? 0,
            quarantineCount: pipelineReceipt.dataGateReceipt?.quarantineCount ?? 0,
            candidateRowsPath: "gate7-wave1-candidates.jsonl",
            batchManifestPath: "wave1-warmup-batch-manifest.json",
            batchManifestDryRunReceiptPath: "wave1-warmup-batch-manifest-dry-run.json",
            batchManifestDryRunStatus: batchManifestDryRunReceipt.status,
            candidateRowCount: candidateRows.count,
            rowsWithTools: candidateRows.filter { !$0.tools.isEmpty }.count,
            rowsWithMountedToolCount: candidateRows.filter { $0.mountedToolCount != nil }.count,
            rowsWithSubsetPolicyID: candidateRows.filter { $0.subsetPolicyID?.isEmpty == false }.count,
            rowsWithSubsetGroupID: candidateRows.filter { $0.subsetGroupID?.isEmpty == false }.count,
            rowsWithSubsetPolicyDigest: candidateRows.filter { $0.subsetPolicyDigest?.isEmpty == false }.count,
            mountedToolCount: mountedTools.count,
            subsetPolicyID: manifestEntry.subsetPolicyID,
            subsetGroupID: manifestEntry.groupID,
            subsetPolicyDigest: manifest.meta.groupingContractDigest,
            dataGateAllowLegacyMissingSurface: pipelineReceipt.dataGateReceipt?.allowLegacyMissingSurface == true,
            dataGateMissingSurfaceCount: pipelineReceipt.dataGateReceipt?.missingSurfaceCount ?? 0,
            dataGateLegacyMissingSurfaceAllowedCount: pipelineReceipt.dataGateReceipt?.legacyMissingSurfaceAllowedCount ?? 0,
            dataGateSurfaceFieldPass: pipelineReceipt.dataGateReceipt?.surfaceFieldPass ?? 0,
            dataGateHardFailure: pipelineReceipt.dataGateReceipt?.hasHardFailure ?? true,
            dataGateFailureReasons: pipelineReceipt.dataGateReceipt?.failureReceipt.map(\.reason) ?? [],
            recipeQuotaSource: recipeAllocation?.quotaSource ?? recipeQuota.quotaSource,
            recipeAllocatedQuota: recipeAllocatedQuota,
            recipeActualSampleCount: recipeActualSampleCount,
            recipeOpenClosePolarityMinPerDirection: recipeQuota.openClosePolarityMinPerDirection,
            recipeNegativeQuotaActivation: recipeQuota.negativeQuotaActivation,
            recipeQueryReadOnlyQuota: recipeQuota.queryReadOnlyQuota,
            recipeUnsupportedRefusalQuota: recipeQuota.unsupportedRefusalQuota,
            recipeSafetyRefusalQuota: recipeQuota.safetyRefusalQuota,
            recipeMultiCallPairingMinimum: recipeQuota.multiCallPairingMinimum
        )
        return DryRunResult(
            receipt: receipt,
            candidateRows: candidateRows,
            batchManifest: batchManifest,
            batchManifestDryRunReceipt: batchManifestDryRunReceipt
        )
    }

    private static func loadSeed(repoRoot: URL, contractRowID: String) throws -> C5SemanticSeed {
        let text = try String(contentsOf: repoRoot.appendingPathComponent("contracts/semantic-function-contract.jsonl"), encoding: .utf8)
        let decoder = JSONDecoder()
        for line in text.split(whereSeparator: \.isNewline) {
            let seed = try decoder.decode(C5SemanticSeed.self, from: Data(String(line).utf8))
            if seed.contractRowID == contractRowID {
                return seed
            }
        }
        throw CLIError.message("missing C1 row \(contractRowID)")
    }

    private static func dryRunUtterance(index: Int) -> String {
        let variants = [
            "22度制冷",
            "主驾制冷22度",
            "把主驾空调切到制冷并设成22度",
            "我这边有点热，主驾温区调到二十二度制冷",
            "请把驾驶位空调温度设为22度并保持制冷"
        ]
        return "\(variants[index % variants.count])-\(index + 1)"
    }

    private static func mountedToolSchemas(
        manifestEntry: Gate7SubsetManifest.Entry,
        catalog: [DDomainToolEntry]
    ) throws -> [[String: JSONValue]] {
        let catalogByName = Dictionary(catalog.map { ($0.function.name, $0) }, uniquingKeysWith: { first, _ in first })
        return try manifestEntry.toolIDsOrdered.map { toolID in
            guard let entry = catalogByName[toolID] else {
                throw CLIError.message("mounted tool \(toolID) missing from D-domain demo catalog")
            }
            return C5TrainingRenderer.dDomainToolSchema(entry)
        }
    }

    private static func writeJSONLines<T: Encodable>(_ rows: [T], to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        let lines = try rows.map { row -> String in
            let data = try encoder.encode(row)
            guard let line = String(data: data, encoding: .utf8) else {
                throw CLIError.message("failed to encode candidate row as utf8")
            }
            return line
        }
        try (lines.joined(separator: "\n") + "\n").write(to: url, atomically: true, encoding: .utf8)
    }

    private static func renderMarkdown(_ receipt: DryRunReceipt) -> String {
        let call = receipt.firstExpectedToolCall.map { "\($0.name) \($0.arguments)" } ?? "missing"
        return """
        # Gate7 wave-1 mock dry-run receipt

        - generated_at: \(receipt.generatedAt)
        - proof_class: \(receipt.proofClass)
        - repo_root: \(receipt.repoRoot)
        - target_contract_row_id: \(receipt.contractRowID)
        - target_tool_name: \(receipt.targetToolName)
        - generator_vendor: \(receipt.generatorVendor)
        - judge_vendor: \(receipt.judgeVendor)
        - requested_limit: \(receipt.limit)
        - pipeline_status: \(receipt.pipelineStatus)
        - reasons: \(receipt.reasons)
        - sample_count: \(receipt.sampleCount)
        - first_expected_tool_call: \(call)
        - data_gate_status: \(receipt.dataGateStatus)
        - data_gate_row_count: \(receipt.dataGateRowCount)
        - quarantine_count: \(receipt.quarantineCount)
        - candidate_rows_path: \(receipt.candidateRowsPath)
        - batch_manifest_path: \(receipt.batchManifestPath)
        - batch_manifest_dry_run_receipt_path: \(receipt.batchManifestDryRunReceiptPath)
        - batch_manifest_dry_run_status: \(receipt.batchManifestDryRunStatus)
        - candidate_row_count: \(receipt.candidateRowCount)
        - rows_with_tools: \(receipt.rowsWithTools)
        - rows_with_mounted_tool_count: \(receipt.rowsWithMountedToolCount)
        - rows_with_subset_policy_id: \(receipt.rowsWithSubsetPolicyID)
        - rows_with_subset_group_id: \(receipt.rowsWithSubsetGroupID)
        - rows_with_subset_policy_digest: \(receipt.rowsWithSubsetPolicyDigest)
        - mounted_tool_count: \(receipt.mountedToolCount)
        - subset_policy_id: \(receipt.subsetPolicyID)
        - subset_group_id: \(receipt.subsetGroupID)
        - subset_policy_digest: \(receipt.subsetPolicyDigest)
        - data_gate_allow_legacy_missing_surface: \(receipt.dataGateAllowLegacyMissingSurface)
        - data_gate_missing_surface_count: \(receipt.dataGateMissingSurfaceCount)
        - data_gate_legacy_missing_surface_allowed_count: \(receipt.dataGateLegacyMissingSurfaceAllowedCount)
        - data_gate_surface_field_pass: \(receipt.dataGateSurfaceFieldPass)
        - data_gate_hard_failure: \(receipt.dataGateHardFailure)
        - data_gate_failure_reasons: \(receipt.dataGateFailureReasons)
        - recipe_quota_source: \(receipt.recipeQuotaSource)
        - recipe_allocated_quota: \(receipt.recipeAllocatedQuota)
        - recipe_actual_sample_count: \(receipt.recipeActualSampleCount)
        - recipe_open_close_polarity_min_per_direction: \(receipt.recipeOpenClosePolarityMinPerDirection)
        - recipe_negative_quota_activation: \(receipt.recipeNegativeQuotaActivation)
        - recipe_query_read_only_quota: \(receipt.recipeQueryReadOnlyQuota)
        - recipe_unsupported_refusal_quota: \(receipt.recipeUnsupportedRefusalQuota)
        - recipe_safety_refusal_quota: \(receipt.recipeSafetyRefusalQuota)
        - recipe_multi_call_pairing_minimum: \(receipt.recipeMultiCallPairingMinimum)

        Boundary: mock provider only; no live cloud generation and no training.
        """
    }

    private static func isoNow() -> String {
        ISO8601DateFormatter().string(from: Date())
    }
}

struct DryRunResult {
    var receipt: DryRunReceipt
    var candidateRows: [C5DataGateCandidate]
    var batchManifest: Wave1BatchManifest
    var batchManifestDryRunReceipt: Wave1BatchManifestDryRunReceipt
}

struct DryRunReceipt: Codable, Equatable {
    var generatedAt: String
    var proofClass: String
    var repoRoot: String
    var contractRowID: String
    var targetToolName: String
    var generatorVendor: String
    var judgeVendor: String
    var limit: Int
    var pipelineStatus: String
    var reasons: [String]
    var sampleCount: Int
    var firstExpectedToolCall: C6ToolCall?
    var dataGateStatus: String
    var dataGateRowCount: Int
    var quarantineCount: Int
    var candidateRowsPath: String
    var batchManifestPath: String
    var batchManifestDryRunReceiptPath: String
    var batchManifestDryRunStatus: String
    var candidateRowCount: Int
    var rowsWithTools: Int
    var rowsWithMountedToolCount: Int
    var rowsWithSubsetPolicyID: Int
    var rowsWithSubsetGroupID: Int
    var rowsWithSubsetPolicyDigest: Int
    var mountedToolCount: Int
    var subsetPolicyID: String
    var subsetGroupID: String
    var subsetPolicyDigest: String
    var dataGateAllowLegacyMissingSurface: Bool
    var dataGateMissingSurfaceCount: Int
    var dataGateLegacyMissingSurfaceAllowedCount: Int
    var dataGateSurfaceFieldPass: Int
    var dataGateHardFailure: Bool
    var dataGateFailureReasons: [String]
    var recipeQuotaSource: String
    var recipeAllocatedQuota: Int
    var recipeActualSampleCount: Int
    var recipeOpenClosePolarityMinPerDirection: Int
    var recipeNegativeQuotaActivation: String
    var recipeQueryReadOnlyQuota: Int
    var recipeUnsupportedRefusalQuota: Int
    var recipeSafetyRefusalQuota: Int
    var recipeMultiCallPairingMinimum: Int

    enum CodingKeys: String, CodingKey {
        case generatedAt = "generated_at"
        case proofClass = "proof_class"
        case repoRoot = "repo_root"
        case contractRowID = "contract_row_id"
        case targetToolName = "target_tool_name"
        case generatorVendor = "generator_vendor"
        case judgeVendor = "judge_vendor"
        case limit
        case pipelineStatus = "pipeline_status"
        case reasons
        case sampleCount = "sample_count"
        case firstExpectedToolCall = "first_expected_tool_call"
        case dataGateStatus = "data_gate_status"
        case dataGateRowCount = "data_gate_row_count"
        case quarantineCount = "quarantine_count"
        case candidateRowsPath = "candidate_rows_path"
        case batchManifestPath = "batch_manifest_path"
        case batchManifestDryRunReceiptPath = "batch_manifest_dry_run_receipt_path"
        case batchManifestDryRunStatus = "batch_manifest_dry_run_status"
        case candidateRowCount = "candidate_row_count"
        case rowsWithTools = "rows_with_tools"
        case rowsWithMountedToolCount = "rows_with_mounted_tool_count"
        case rowsWithSubsetPolicyID = "rows_with_subset_policy_id"
        case rowsWithSubsetGroupID = "rows_with_subset_group_id"
        case rowsWithSubsetPolicyDigest = "rows_with_subset_policy_digest"
        case mountedToolCount = "mounted_tool_count"
        case subsetPolicyID = "subset_policy_id"
        case subsetGroupID = "subset_group_id"
        case subsetPolicyDigest = "subset_policy_digest"
        case dataGateAllowLegacyMissingSurface = "data_gate_allow_legacy_missing_surface"
        case dataGateMissingSurfaceCount = "data_gate_missing_surface_count"
        case dataGateLegacyMissingSurfaceAllowedCount = "data_gate_legacy_missing_surface_allowed_count"
        case dataGateSurfaceFieldPass = "data_gate_surface_field_pass"
        case dataGateHardFailure = "data_gate_hard_failure"
        case dataGateFailureReasons = "data_gate_failure_reasons"
        case recipeQuotaSource = "recipe_quota_source"
        case recipeAllocatedQuota = "recipe_allocated_quota"
        case recipeActualSampleCount = "recipe_actual_sample_count"
        case recipeOpenClosePolarityMinPerDirection = "recipe_open_close_polarity_min_per_direction"
        case recipeNegativeQuotaActivation = "recipe_negative_quota_activation"
        case recipeQueryReadOnlyQuota = "recipe_query_read_only_quota"
        case recipeUnsupportedRefusalQuota = "recipe_unsupported_refusal_quota"
        case recipeSafetyRefusalQuota = "recipe_safety_refusal_quota"
        case recipeMultiCallPairingMinimum = "recipe_multi_call_pairing_minimum"
    }
}

struct Options {
    var repoRoot: String
    var outputDir: String
    var contractRowID: String
    var limit: Int
    var batchID: String
    var laneID: String
    var mainPinSHA: String

    init(arguments: [String]) throws {
        repoRoot = FileManager.default.currentDirectoryPath
        outputDir = URL(fileURLWithPath: repoRoot, isDirectory: true)
            .appendingPathComponent("Reports/gate7-wave1-dry-run")
            .path
        contractRowID = "c1_airControl_000167"
        limit = 20
        batchID = "wave1-warmup-0001"
        laneID = "lane-1"
        mainPinSHA = Wave1BatchManifestBuilder.defaultMainPinSHA

        var iterator = arguments.dropFirst().makeIterator()
        while let argument = iterator.next() {
            switch argument {
            case "--repo-root":
                guard let value = iterator.next() else { throw CLIError.usage("missing --repo-root value") }
                repoRoot = value
            case "--output-dir":
                guard let value = iterator.next() else { throw CLIError.usage("missing --output-dir value") }
                outputDir = value
            case "--contract-row-id":
                guard let value = iterator.next() else { throw CLIError.usage("missing --contract-row-id value") }
                contractRowID = value
            case "--limit":
                guard let value = iterator.next(), let intValue = Int(value) else { throw CLIError.usage("invalid --limit value") }
                limit = intValue
            case "--batch-id":
                guard let value = iterator.next() else { throw CLIError.usage("missing --batch-id value") }
                batchID = value
            case "--lane-id":
                guard let value = iterator.next() else { throw CLIError.usage("missing --lane-id value") }
                laneID = value
            case "--main-pin-sha":
                guard let value = iterator.next() else { throw CLIError.usage("missing --main-pin-sha value") }
                mainPinSHA = value
            default:
                throw CLIError.usage("unknown argument \(argument)")
            }
        }
    }
}

enum CLIError: Error, CustomStringConvertible {
    case usage(String)
    case message(String)

    var description: String {
        switch self {
        case .usage(let value), .message(let value):
            return value
        }
    }
}
