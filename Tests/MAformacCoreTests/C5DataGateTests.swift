import XCTest
@testable import MAformacCore

final class C5DataGateTests: XCTestCase {
    func testCleanReceiptIsDataGateReady() throws {
        let receipt = try makeReceipt(jsonl: """
        {"sample_id":"C5-OK-001","split":"train","bucket":"tool_call_wrapper_format","case_id":"C5-OK-001","parent_semantic_id":"parent:c5.ok.train","must_not_train":false,"source_authorization":"authorized","input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"set_cabin_ac","arguments":{"power":"on"}},"masking":{"function_name":true,"argument_name":true,"argument_value":true,"train_on_turn":true}}
        """)

        XCTAssertEqual(receipt.status, "data_gate_ready")
        XCTAssertEqual(receipt.rowCount, 1)
        XCTAssertEqual(receipt.mustNotTrainViolations, 0)
        XCTAssertEqual(receipt.trainParentSemanticOverlap, 0)
        XCTAssertEqual(receipt.toolCallFormatPass, 1)
        XCTAssertEqual(receipt.proposedFix.autoApply, false)
        XCTAssertEqual(receipt.redactionStatus, "pass")
        XCTAssertTrue(receipt.maskingCoverage.functionName)
        XCTAssertEqual(receipt.allowLegacyMissingSurface, true)
        XCTAssertEqual(receipt.missingSurfaceCount, 1)
        XCTAssertEqual(receipt.legacyMissingSurfaceAllowedCount, 1)
    }

    func testMissingSurfaceFieldsFailClosedWithoutLegacyFlag() throws {
        let receipt = try makeReceipt(allowLegacyMissingSurface: false, jsonl: """
        {"sample_id":"C5-MISSING-SURFACE","split":"train","bucket":"tool_call_wrapper_format","case_id":"C5-MISSING-SURFACE","parent_semantic_id":"parent:missing.surface","must_not_train":false,"source_authorization":"authorized","input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"set_cabin_ac","arguments":{"power":"on"}}}
        """)

        XCTAssertEqual(receipt.status, "blocked")
        XCTAssertTrue(receipt.hasHardFailure)
        XCTAssertEqual(receipt.allowLegacyMissingSurface, false)
        XCTAssertEqual(receipt.missingSurfaceCount, 1)
        XCTAssertEqual(receipt.legacyMissingSurfaceAllowedCount, 0)
        XCTAssertEqual(receipt.surfaceFieldPass, 0)
        XCTAssertTrue(receipt.failureReceipt.contains { $0.reason == "missing_candidate_surface_fields" })
        XCTAssertTrue(receipt.proposedFix.suggestions.contains { $0.contains("tools/mounted_tool_count/subset") })
    }

    func testLegacyMissingSurfaceRequiresExplicitFlagAndRecordsAllowance() throws {
        let receipt = try makeReceipt(allowLegacyMissingSurface: true, jsonl: """
        {"sample_id":"C5-LEGACY-SURFACE","split":"train","bucket":"tool_call_wrapper_format","case_id":"C5-LEGACY-SURFACE","parent_semantic_id":"parent:legacy.surface","must_not_train":false,"source_authorization":"authorized","input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"set_cabin_ac","arguments":{"power":"on"}}}
        """)

        XCTAssertEqual(receipt.status, "data_gate_ready")
        XCTAssertFalse(receipt.hasHardFailure)
        XCTAssertEqual(receipt.allowLegacyMissingSurface, true)
        XCTAssertEqual(receipt.missingSurfaceCount, 1)
        XCTAssertEqual(receipt.legacyMissingSurfaceAllowedCount, 1)
        XCTAssertEqual(receipt.surfaceFieldPass, 0)
    }

    func testSurfaceFieldsPassFormalGateWhenPresent() throws {
        let receipt = try makeReceipt(allowLegacyMissingSurface: false, jsonl: """
        {"sample_id":"C5-SURFACE-PASS","split":"train","bucket":"tool_call_wrapper_format","case_id":"C5-SURFACE-PASS","parent_semantic_id":"parent:surface.pass","must_not_train":false,"source_authorization":"authorized","input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"set_cabin_ac","arguments":{"power":"on"}},"tools":[{"type":"function","function":{"name":"set_cabin_ac"}}],"mounted_tool_count":1,"subset_policy_id":"e2-lite-v1","subset_group_id":"ac","subset_policy_digest":"digest"}
        """)

        XCTAssertEqual(receipt.status, "data_gate_ready")
        XCTAssertFalse(receipt.hasHardFailure)
        XCTAssertEqual(receipt.allowLegacyMissingSurface, false)
        XCTAssertEqual(receipt.missingSurfaceCount, 0)
        XCTAssertEqual(receipt.legacyMissingSurfaceAllowedCount, 0)
        XCTAssertEqual(receipt.surfaceFieldPass, 1)
    }

    func testMalformedToolsObjectFailsClosed() throws {
        let receipt = try makeReceipt(allowLegacyMissingSurface: false, jsonl: """
        {"sample_id":"C5-SURFACE-BYPASS-EMPTY","split":"train","bucket":"tool_call_wrapper_format","case_id":"C5-SURFACE-BYPASS-EMPTY","parent_semantic_id":"parent:surface.empty","must_not_train":false,"source_authorization":"authorized","input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"set_cabin_ac","arguments":{"power":"on"}},"tools":[{}],"mounted_tool_count":1,"subset_policy_id":"e2-lite-v1","subset_group_id":"ac","subset_policy_digest":"digest"}
        """)

        XCTAssertEqual(receipt.status, "blocked")
        XCTAssertTrue(receipt.hasHardFailure)
        XCTAssertEqual(receipt.missingSurfaceCount, 0)
        XCTAssertEqual(receipt.surfaceFieldPass, 0)
        XCTAssertTrue(receipt.failureReceipt.contains { $0.reason == "candidate_surface_invalid_tool_schema" })
        XCTAssertTrue(receipt.failureReceipt.contains { $0.reason == "candidate_surface_mounted_tool_count_mismatch" })
    }

    func testMissingFunctionNameFailsClosed() throws {
        let receipt = try makeReceipt(allowLegacyMissingSurface: false, jsonl: """
        {"sample_id":"C5-SURFACE-BYPASS-FUNCTION","split":"train","bucket":"tool_call_wrapper_format","case_id":"C5-SURFACE-BYPASS-FUNCTION","parent_semantic_id":"parent:surface.function","must_not_train":false,"source_authorization":"authorized","input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"set_cabin_ac","arguments":{"power":"on"}},"tools":[{"type":"function","function":{}}],"mounted_tool_count":1,"subset_policy_id":"e2-lite-v1","subset_group_id":"ac","subset_policy_digest":"digest"}
        """)

        XCTAssertEqual(receipt.status, "blocked")
        XCTAssertTrue(receipt.failureReceipt.contains { $0.reason == "candidate_surface_invalid_tool_schema" })
    }

    func testActionToolMustBeMounted() throws {
        let receipt = try makeReceipt(allowLegacyMissingSurface: false, jsonl: """
        {"sample_id":"C5-SURFACE-WRONG-MOUNT","split":"train","bucket":"tool_call_wrapper_format","case_id":"C5-SURFACE-WRONG-MOUNT","parent_semantic_id":"parent:surface.wrong","must_not_train":false,"source_authorization":"authorized","input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"set_cabin_ac","arguments":{"power":"on"}},"tools":[{"type":"function","function":{"name":"close_ac"}}],"mounted_tool_count":1,"subset_policy_id":"e2-lite-v1","subset_group_id":"ac","subset_policy_digest":"digest"}
        """)

        XCTAssertEqual(receipt.status, "blocked")
        XCTAssertTrue(receipt.failureReceipt.contains { $0.reason == "tool_name_not_mounted" })
    }

    func testSurfaceManifestDigestAndMembersMustMatchSource() throws {
        let manifest = C5DataGateSurfaceManifest(
            manifestFileDigest: "manifest-file-digest",
            groupingContractDigest: "grouping-contract-digest",
            entries: [
                C5DataGateSurfaceManifestEntry(
                    subsetPolicyID: "e2-lite-v1",
                    subsetGroupID: "ac",
                    toolIDsOrdered: ["set_cabin_ac"],
                    toolSchemaDigest: "schema-digest"
                )
            ]
        )
        let receipt = try makeReceipt(allowLegacyMissingSurface: false, surfaceManifest: manifest, jsonl: """
        {"sample_id":"C5-SURFACE-DIGEST-DRIFT","split":"train","bucket":"tool_call_wrapper_format","case_id":"C5-SURFACE-DIGEST-DRIFT","parent_semantic_id":"parent:surface.digest","must_not_train":false,"source_authorization":"authorized","input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"set_cabin_ac","arguments":{"power":"on"}},"tools":[{"type":"function","function":{"name":"set_cabin_ac"}}],"mounted_tool_count":1,"subset_policy_id":"e2-lite-v1","subset_group_id":"ac","subset_policy_digest":"wrong-digest","tool_schema_digest":"wrong-schema-digest"}
        """)

        XCTAssertEqual(receipt.status, "blocked")
        XCTAssertTrue(receipt.failureReceipt.contains { $0.reason == "subset_policy_digest_mismatch" })
        XCTAssertTrue(receipt.failureReceipt.contains { $0.reason == "tool_schema_digest_mismatch" })
    }

    func testSurfaceManifestCatalogSchemaMustMatchMountedTools() throws {
        let manifest = C5DataGateSurfaceManifest(
            manifestFileDigest: "manifest-file-digest",
            groupingContractDigest: "grouping-contract-digest",
            entries: [
                C5DataGateSurfaceManifestEntry(
                    subsetPolicyID: "e2-lite-v1",
                    subsetGroupID: "ac",
                    toolIDsOrdered: ["set_cabin_ac"],
                    toolSchemaDigest: "schema-digest"
                )
            ],
            toolSchemasByName: [
                "set_cabin_ac": [
                    "type": .string("function"),
                    "function": .object([
                        "name": .string("set_cabin_ac"),
                        "parameters": .object(["type": .string("object")])
                    ])
                ]
            ]
        )
        let receipt = try makeReceipt(allowLegacyMissingSurface: false, surfaceManifest: manifest, jsonl: """
        {"sample_id":"C5-SURFACE-CATALOG-DRIFT","split":"train","bucket":"tool_call_wrapper_format","case_id":"C5-SURFACE-CATALOG-DRIFT","parent_semantic_id":"parent:surface.catalog","must_not_train":false,"source_authorization":"authorized","input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"set_cabin_ac","arguments":{"power":"on"}},"tools":[{"type":"function","function":{"name":"set_cabin_ac"}}],"mounted_tool_count":1,"subset_policy_id":"e2-lite-v1","subset_group_id":"ac","subset_policy_digest":"manifest-file-digest"}
        """)

        XCTAssertEqual(receipt.status, "blocked")
        XCTAssertTrue(receipt.failureReceipt.contains { $0.reason == "tool_schema_digest_mismatch" })
    }

    func testSurfaceManifestAcceptsManifestFileOrGroupingDigest() throws {
        let manifest = C5DataGateSurfaceManifest(
            manifestFileDigest: "manifest-file-digest",
            groupingContractDigest: "grouping-contract-digest",
            entries: [
                C5DataGateSurfaceManifestEntry(
                    subsetPolicyID: "e2-lite-v1",
                    subsetGroupID: "ac",
                    toolIDsOrdered: ["set_cabin_ac"],
                    toolSchemaDigest: "schema-digest"
                )
            ]
        )
        let receipt = try makeReceipt(allowLegacyMissingSurface: false, surfaceManifest: manifest, jsonl: """
        {"sample_id":"C5-SURFACE-MANIFEST-PASS","split":"train","bucket":"tool_call_wrapper_format","case_id":"C5-SURFACE-MANIFEST-PASS","parent_semantic_id":"parent:surface.manifest.pass","must_not_train":false,"source_authorization":"authorized","input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"set_cabin_ac","arguments":{"power":"on"}},"tools":[{"type":"function","function":{"name":"set_cabin_ac"}}],"mounted_tool_count":1,"subset_policy_id":"e2-lite-v1","subset_group_id":"ac","subset_policy_digest":"grouping-contract-digest","tool_schema_digest":"schema-digest"}
        """)

        XCTAssertEqual(receipt.status, "data_gate_ready")
        XCTAssertEqual(receipt.surfaceFieldPass, 1)
    }

    func testSurfaceManifestAllowsMountedSubsetButRejectsOutsider() throws {
        let manifest = C5DataGateSurfaceManifest(
            manifestFileDigest: "manifest-file-digest",
            groupingContractDigest: "grouping-contract-digest",
            entries: [
                C5DataGateSurfaceManifestEntry(
                    subsetPolicyID: "e2-lite-v1",
                    subsetGroupID: "seat.massage_force_time",
                    toolIDsOrdered: ["open_seat_massage", "adjust_seat_massage_force_to_gear", "close_seat_massage"],
                    toolSchemaDigest: "full-schema-digest"
                )
            ]
        )
        let subsetReceipt = try makeReceipt(allowLegacyMissingSurface: false, surfaceManifest: manifest, jsonl: """
        {"sample_id":"C5-SURFACE-SUBSET-PASS","split":"train","bucket":"tool_call_wrapper_format","case_id":"C5-SURFACE-SUBSET-PASS","parent_semantic_id":"parent:surface.subset.pass","must_not_train":false,"source_authorization":"authorized","input_zh":"打开座椅按摩","tool_call":{"wrapper":"tool_call","name":"open_seat_massage","arguments":{}},"tools":[{"type":"function","function":{"name":"open_seat_massage"}},{"type":"function","function":{"name":"adjust_seat_massage_force_to_gear"}}],"mounted_tool_count":2,"subset_policy_id":"e2-lite-v1","subset_group_id":"seat.massage_force_time","subset_policy_digest":"manifest-file-digest"}
        """)
        let outsiderReceipt = try makeReceipt(allowLegacyMissingSurface: false, surfaceManifest: manifest, jsonl: """
        {"sample_id":"C5-SURFACE-OUTSIDER-BLOCK","split":"train","bucket":"tool_call_wrapper_format","case_id":"C5-SURFACE-OUTSIDER-BLOCK","parent_semantic_id":"parent:surface.outsider.block","must_not_train":false,"source_authorization":"authorized","input_zh":"打开座椅按摩","tool_call":{"wrapper":"tool_call","name":"open_seat_massage","arguments":{}},"tools":[{"type":"function","function":{"name":"open_seat_massage"}},{"type":"function","function":{"name":"set_cabin_ac"}}],"mounted_tool_count":2,"subset_policy_id":"e2-lite-v1","subset_group_id":"seat.massage_force_time","subset_policy_digest":"manifest-file-digest"}
        """)

        XCTAssertEqual(subsetReceipt.status, "data_gate_ready")
        XCTAssertEqual(outsiderReceipt.status, "blocked")
        XCTAssertTrue(outsiderReceipt.failureReceipt.contains { $0.reason == "mounted_tool_names_manifest_mismatch" })
    }

    func testC6MustPassInTrainFails() throws {
        let c6Case = protectedC6Case(caseID: "C6-MP-FIXTURE", semanticID: "c1_fixture_protected")
        let receipt = try makeReceipt(c6Cases: [c6Case], jsonl: """
        {"sample_id":"C5-BAD-MP","split":"train","bucket":"tool_call_wrapper_format","case_id":"C6-MP-FIXTURE","parent_semantic_id":"parent:c5.bad","must_not_train":false,"input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"set_cabin_ac","arguments":{"power":"on"}}}
        """)

        XCTAssertEqual(receipt.status, "blocked")
        XCTAssertEqual(receipt.mustNotTrainViolations, 1)
        XCTAssertTrue(receipt.failureReceipt.contains { $0.reason == "must_not_train_candidate_in_train" })
    }

    func testParentSemanticOverlapInTrainFails() throws {
        let receipt = try makeReceipt(jsonl: """
        {"sample_id":"C5-TRAIN-001","split":"train","bucket":"tool_call_wrapper_format","case_id":"C5-TRAIN-001","parent_semantic_id":"parent:shared","must_not_train":false,"input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"set_cabin_ac","arguments":{"power":"on"}}}
        {"sample_id":"C5-HELDOUT-001","split":"heldout","bucket":"heldout_test","case_id":"C5-HELDOUT-001","parent_semantic_id":"parent:shared","must_not_train":true,"input_zh":"空调打开"}
        """)

        XCTAssertEqual(receipt.status, "blocked")
        XCTAssertEqual(receipt.detectedParentSemanticOverlapCount, 1)
        XCTAssertEqual(receipt.trainParentSemanticOverlap, 1)
        XCTAssertTrue(receipt.failureReceipt.contains { $0.reason == "train_parent_semantic_overlap" })
    }

    func testCandidateParentSemanticOverlapInTrainFailsEvenWhenSeedParentIsSafe() throws {
        let receipt = try makeReceipt(jsonl: """
        {"sample_id":"C5-TRAIN-001","split":"train","bucket":"tool_call_wrapper_format","case_id":"C5-TRAIN-001","parent_semantic_id":"parent:seed.safe","candidate_parent_semantic_id":"parent:protected","must_not_train":false,"input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"set_cabin_ac","arguments":{"power":"on"}}}
        {"sample_id":"C5-HELDOUT-001","split":"heldout","bucket":"heldout_test","case_id":"C5-HELDOUT-001","parent_semantic_id":"parent:protected","must_not_train":true,"input_zh":"空调打开"}
        """)

        XCTAssertEqual(receipt.status, "blocked")
        XCTAssertEqual(receipt.trainParentSemanticOverlap, 1)
        XCTAssertTrue(receipt.failureReceipt.contains { $0.reason == "train_parent_semantic_overlap" && $0.parentSemanticID == "parent:protected" })
    }

    func testCandidateParentSemanticIDOverridesSeedParentForOverlap() throws {
        let receipt = try makeReceipt(jsonl: """
        {"sample_id":"C5-TRAIN-001","split":"train","bucket":"tool_call_wrapper_format","case_id":"C5-TRAIN-001","parent_semantic_id":"parent:seed.shared","candidate_parent_semantic_id":"parent:candidate.reassigned","must_not_train":false,"input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"set_cabin_ac","arguments":{"power":"on"}}}
        {"sample_id":"C5-HELDOUT-001","split":"heldout","bucket":"heldout_test","case_id":"C5-HELDOUT-001","parent_semantic_id":"parent:seed.shared","must_not_train":true,"input_zh":"空调打开"}
        """)

        XCTAssertEqual(receipt.status, "data_gate_ready")
        XCTAssertEqual(receipt.detectedParentSemanticOverlapCount, 0)
        XCTAssertEqual(receipt.trainParentSemanticOverlap, 0)
        XCTAssertFalse(receipt.failureReceipt.contains { $0.reason == "train_parent_semantic_overlap" })
    }

    func testBareJSONTrainActionFailsFormatGate() throws {
        let receipt = try makeReceipt(jsonl: """
        {"sample_id":"C5-BAD-FORMAT","split":"train","bucket":"tool_call_wrapper_format","case_id":"C5-BAD-FORMAT","parent_semantic_id":"parent:bad.format","must_not_train":false,"input_zh":"打开空调","expected_tool_calls":[{"name":"set_cabin_ac","arguments":{"power":"on"}}],"messages":[{"role":"assistant","content":"{\\"name\\":\\"set_cabin_ac\\",\\"arguments\\":{\\"power\\":\\"on\\"}}"}]}
        """)

        XCTAssertEqual(receipt.status, "blocked")
        XCTAssertEqual(receipt.toolCallFormatFailures.count, 1)
        XCTAssertTrue(receipt.failureReceipt.contains { $0.reason == "tool_call_format_mismatch" })
    }

    func testLegacyRawCandidateSchemaDecodes() throws {
        let receipt = try makeReceipt(jsonl: """
        {"case_id":"mfc-004","dataset_bucket":"train_candidate","scenario_family_id":"ac_free_say_temperature","must_not_train":false,"query_template":"表达自己有点冷","expected":{"frames":[{"arguments":{"delta":"warmer"},"tool_name":"set_cabin_ac","type":"tool_call"}]},"messages":[{"role":"assistant","content":"<tool_call>{\\"name\\":\\"set_cabin_ac\\",\\"arguments\\":{\\"delta\\":\\"warmer\\"}}</tool_call>"}]}
        """)

        XCTAssertEqual(receipt.status, "data_gate_ready")
        XCTAssertEqual(receipt.bucketCounts["train"], 1)
        XCTAssertEqual(receipt.toolCallFormatPass, 1)
    }

    func testDevSelectionIsWhitelistedAndDoesNotProtectParentOverlap() throws {
        let receipt = try makeReceipt(jsonl: """
        {"sample_id":"C5-TRAIN-001","split":"train","bucket":"semantic_protocol_augmented","case_id":"C5-TRAIN-001","parent_semantic_id":"parent:shared","must_not_train":false,"input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"tool_call_frame","arguments":{"device":"ac","action_primitive":"power_on"}}}
        {"sample_id":"C5-DEV-001","split":"dev_selection","bucket":"dev_selection","case_id":"C5-DEV-001","parent_semantic_id":"parent:shared","must_not_train":true,"input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"tool_call_frame","arguments":{"device":"ac","action_primitive":"power_on"}}}
        """)

        XCTAssertEqual(receipt.status, "data_gate_ready")
        XCTAssertEqual(receipt.bucketCounts["dev_selection"], 1)
        XCTAssertEqual(receipt.trainParentSemanticOverlap, 0)
        XCTAssertTrue(receipt.splitWhitelist.contains("dev_selection"))
    }

    func testSixAxisHeldOutOverlapBlocksTrainRows() throws {
        try assertAxisOverlap(axisKey: "parent_semantic_id", value: "parent:shared", expectedReason: "train_parent_semantic_overlap")
        try assertAxisOverlap(axisKey: "device", value: "ac", expectedReason: "train_device_overlap")
        try assertAxisOverlap(axisKey: "tool_name", value: "set_cabin_ac", expectedReason: "train_tool_overlap")
        try assertAxisOverlap(axisKey: "value_type", value: "EXP", expectedReason: "train_value_type_overlap")
        try assertAxisOverlap(axisKey: "template_family", value: "temperature_request", expectedReason: "train_template_family_overlap")
        try assertAxisOverlap(axisKey: "generator_source", value: "hermes_glm", expectedReason: "train_generator_source_overlap")
    }

    func testDeviceOverlapBlocksEvenWhenParentDoesNotOverlap() throws {
        let receipt = try makeReceipt(jsonl: """
        {"sample_id":"C5-TRAIN-DEV","split":"train","bucket":"tool_call_wrapper_format","case_id":"C5-TRAIN-DEV","parent_semantic_id":"parent:train.unique","device":"ac","tool_name":"set_cabin_ac","value_type":"EXP","template_family":"train_template","generator_source":"codex","must_not_train":false,"input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"set_cabin_ac","arguments":{"power":"on"}}}
        {"sample_id":"C5-HELDOUT-DEV","split":"heldout","bucket":"heldout_test","case_id":"C5-HELDOUT-DEV","parent_semantic_id":"parent:heldout.unique","device":"ac","tool_name":"different_tool","value_type":"PERCENT","template_family":"heldout_template","generator_source":"hermes_glm","must_not_train":true,"input_zh":"空调打开"}
        """)

        XCTAssertEqual(receipt.status, "blocked")
        XCTAssertEqual(receipt.trainParentSemanticOverlap, 0)
        XCTAssertEqual(receipt.trainHeldOutAxisOverlapCount, 1)
        XCTAssertEqual(receipt.trainHeldOutAxisOverlapRowCount, 1)
        XCTAssertTrue(receipt.hasHardFailure)
        XCTAssertTrue(receipt.failureReceipt.contains { $0.reason == "train_device_overlap" })
    }

    func testTrainCandidateMissingDeviceBlocksSixAxisSplit() throws {
        let receipt = try makeReceipt(jsonl: """
        {"sample_id":"C5-TRAIN-MISSING-DEVICE","split":"train","bucket":"tool_call_wrapper_format","case_id":"C5-TRAIN-MISSING-DEVICE","parent_semantic_id":"parent:train.missing.device","tool_name":"set_cabin_ac","value_type":"EXP","template_family":"train_template","generator_source":"codex","must_not_train":false,"input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"set_cabin_ac","arguments":{"power":"on"}}}
        """)

        XCTAssertEqual(receipt.status, "blocked")
        XCTAssertTrue(receipt.hasHardFailure)
        XCTAssertTrue(receipt.failureReceipt.contains { $0.reason == "missing_train_device_axis_for_six_axis_split" })
    }

    func testGeneratorSourceAxisUsesCanonicalVendorNotModelID() throws {
        let receipt = try makeReceipt(jsonl: """
        {"sample_id":"C5-TRAIN-VENDOR","split":"train","bucket":"tool_call_wrapper_format","case_id":"C5-TRAIN-VENDOR","parent_semantic_id":"parent:train.vendor","device":"ac","tool_name":"set_cabin_ac","value_type":"EXP","template_family":"train_template","generator_model_id":"hermes_glm","generator_source_vendor":"Volc-twofish","must_not_train":false,"input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"set_cabin_ac","arguments":{"power":"on"}}}
        {"sample_id":"C5-HELDOUT-VENDOR","split":"heldout","bucket":"heldout_test","case_id":"C5-HELDOUT-VENDOR","parent_semantic_id":"parent:heldout.vendor","device":"window","tool_name":"set_window_position","value_type":"PERCENT","template_family":"heldout_template","generator_model_id":"ark_standard","generator_source_vendor":"Volc-twofish","must_not_train":true,"input_zh":"打开车窗"}
        """)

        XCTAssertEqual(receipt.status, "blocked")
        XCTAssertTrue(receipt.failureReceipt.contains { $0.reason == "train_generator_source_overlap" })
        XCTAssertTrue(receipt.heldOutAxisOverlaps?.contains { $0.axis == "generator_source" && $0.overlappingValues == ["Volc-twofish"] } == true)
    }

    func testCleanSixAxisSplitPasses() throws {
        let receipt = try makeReceipt(jsonl: """
        {"sample_id":"C5-TRAIN-CLEAN","split":"train","bucket":"tool_call_wrapper_format","case_id":"C5-TRAIN-CLEAN","parent_semantic_id":"parent:train.clean","device":"ac","tool_name":"set_cabin_ac","value_type":"EXP","template_family":"train_template","generator_source":"codex","must_not_train":false,"input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"set_cabin_ac","arguments":{"power":"on"}}}
        {"sample_id":"C5-HELDOUT-CLEAN","split":"heldout","bucket":"heldout_test","case_id":"C5-HELDOUT-CLEAN","parent_semantic_id":"parent:heldout.clean","device":"window","tool_name":"set_window_position","value_type":"PERCENT","template_family":"heldout_template","generator_source":"hermes_glm","must_not_train":true,"input_zh":"打开车窗"}
        """)

        XCTAssertEqual(receipt.status, "data_gate_ready")
        XCTAssertEqual(receipt.trainHeldOutAxisOverlapCount, 0)
        XCTAssertEqual(receipt.trainHeldOutAxisOverlapRowCount, 0)
        XCTAssertFalse(receipt.hasHardFailure)
    }

    func testLegacyReceiptDecodesWithoutHeldOutAxisFields() throws {
        let json = """
        {"receipt_version":"c5-data-gate.v1","generated_at":"2026-06-20T00:00:00Z","status":"data_gate_ready","source_snapshot_digest":"source-digest","source_authorization_status":"authorized_fixture","format_contract_version":"format-digest","row_count":1,"bucket_counts":{"train":1},"split_whitelist":["train","heldout"],"must_not_train_violations":0,"detected_parent_semantic_overlap_count":0,"train_parent_semantic_overlap":0,"tool_call_format_pass":1,"tool_call_format_failures":[],"masking_coverage":{"function_name":true,"argument_name":true,"argument_value":true,"train_on_turn":true},"redaction_status":"pass","quarantine_count":0,"failure_receipt":[],"proposed_fix":{"auto_apply":false,"suggestions":[]}}
        """
        let receipt = try JSONDecoder().decode(C5DataGateReceipt.self, from: Data(json.utf8))

        XCTAssertNil(receipt.trainHeldOutAxisOverlapCount)
        XCTAssertNil(receipt.heldOutAxisOverlaps)
        XCTAssertFalse(receipt.hasHardFailure)
    }

    private func makeReceipt(
        c6Cases: [C6BenchCase] = [],
        allowLegacyMissingSurface: Bool = true,
        surfaceManifest: C5DataGateSurfaceManifest? = nil,
        jsonl: String
    ) throws -> C5DataGateReceipt {
        let decoder = JSONDecoder()
        let candidates = try jsonl.split(whereSeparator: \.isNewline).map {
            try decoder.decode(C5DataGateCandidate.self, from: Data(String($0).utf8))
        }
        let context = C5DataGateRunContext(
            sourceSnapshotDigest: "source-digest",
            sourceAuthorizationStatus: "authorized_fixture",
            formatContractVersion: "format-digest",
            generatedAt: "2026-06-20T00:00:00Z",
            allowLegacyMissingSurface: allowLegacyMissingSurface,
            surfaceManifest: surfaceManifest
        )
        return C5DataGateValidator().receipt(candidates: candidates, c6Cases: c6Cases, context: context)
    }

    private func assertAxisOverlap(axisKey: String, value: String, expectedReason: String) throws {
        let parentTrain = axisKey == "parent_semantic_id" ? value : "parent:train.\(axisKey)"
        let parentHeldout = axisKey == "parent_semantic_id" ? value : "parent:heldout.\(axisKey)"
        let trainAxis = axisFields(overriding: axisKey, with: value, parent: parentTrain, suffix: "train")
        let heldoutAxis = axisFields(overriding: axisKey, with: value, parent: parentHeldout, suffix: "heldout")
        let receipt = try makeReceipt(jsonl: """
        {"sample_id":"C5-TRAIN-\(axisKey)","split":"train","bucket":"tool_call_wrapper_format","case_id":"C5-TRAIN-\(axisKey)",\(trainAxis),"must_not_train":false,"input_zh":"打开空调","tool_call":{"wrapper":"tool_call","name":"set_cabin_ac","arguments":{"power":"on"}}}
        {"sample_id":"C5-HELDOUT-\(axisKey)","split":"heldout","bucket":"heldout_test","case_id":"C5-HELDOUT-\(axisKey)",\(heldoutAxis),"must_not_train":true,"input_zh":"空调打开"}
        """)

        XCTAssertEqual(receipt.status, "blocked", axisKey)
        XCTAssertEqual(receipt.trainHeldOutAxisOverlapCount, 1, axisKey)
        XCTAssertTrue(receipt.hasHardFailure, axisKey)
        XCTAssertTrue(receipt.failureReceipt.contains { $0.reason == expectedReason }, axisKey)
    }

    private func axisFields(overriding axisKey: String, with value: String, parent: String, suffix: String) -> String {
        var fields = [
            "parent_semantic_id": parent,
            "device": "device-\(suffix)",
            "tool_name": "tool-\(suffix)",
            "value_type": "value-\(suffix)",
            "template_family": "template-\(suffix)",
            "generator_source": "generator-\(suffix)"
        ]
        fields[axisKey] = value
        return fields.sorted { $0.key < $1.key }
            .map { "\"\($0.key)\":\"\($0.value)\"" }
            .joined(separator: ",")
    }

    private func protectedC6Case(caseID: String, semanticID: String) -> C6BenchCase {
        C6BenchCase(
            caseID: caseID,
            sourceRefs: C6SourceRefs(semanticContractIDs: [semanticID], stateCellIDs: ["ac.power"], scenarioIDs: ["scene1"]),
            tags: C6CaseTags(bucket: .action, mustPass: true, mustNotTrain: true, contractDevice: "ac", scenarioID: "scene1", sampleKind: "fixture"),
            preState: ["ac.power": "off"],
            inputZh: "打开空调",
            expectedToolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])],
            expectNoCall: false,
            expectedStateDelta: ["ac.power": "on"],
            readbackAssertion: C6ReadbackAssertion(contains: ["空调"]),
            clarifyTag: .implicit,
            failureClass: .none
        )
    }
}
