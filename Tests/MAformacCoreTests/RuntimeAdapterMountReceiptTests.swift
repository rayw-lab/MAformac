import XCTest
@testable import MAformacCore

final class RuntimeAdapterMountReceiptTests: XCTestCase {
    func testV2ReceiptRoundTripsWithRuntimeTargetAndTwoCatalogArtifacts() throws {
        let receipt = try fixtureReceipt()
        let data = try RuntimeAdapterMountReceipt.jsonEncoder().encode(receipt)
        let json = String(decoding: data, as: UTF8.self)

        XCTAssertTrue(json.contains(#""schema_version":"runtime_adapter_mount_receipt.v2""#))
        XCTAssertTrue(json.contains(#""runtime_target":"ios_sim""#))
        XCTAssertTrue(json.contains(#""ir_map_fingerprint":"ir-map-fingerprint""#))
        XCTAssertTrue(json.contains(#""mounted_demo_catalog_sha":"mounted-demo-catalog-sha""#))
        XCTAssertFalse(json.contains("mounted_tool_catalog_sha"))
        XCTAssertFalse(json.contains("adapterSha"))

        let decoded = try JSONDecoder().decode(RuntimeAdapterMountReceipt.self, from: data)
        XCTAssertEqual(decoded, receipt)
        try decoded.validate()
    }

    func testValidateRejectsWrongSchemaVersion() throws {
        var object = try jsonObject(from: RuntimeAdapterMountReceipt.jsonEncoder().encode(fixtureReceipt()))
        object["schema_version"] = "runtime_adapter_mount_receipt.v1"
        let data = try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])

        XCTAssertThrowsError(try JSONDecoder().decode(RuntimeAdapterMountReceipt.self, from: data)) { error in
            XCTAssertEqual(
                error as? RuntimeAdapterMountReceiptValidationError,
                .invalidSchemaVersion("runtime_adapter_mount_receipt.v1")
            )
        }
    }

    func testV1ReceiptDecodesOnlyAsHistoricalEvidence() throws {
        let data = Data(v1HistoricalJSON.utf8)

        let historical = try JSONDecoder().decode(RuntimeAdapterMountReceiptV1HistoricalEvidence.self, from: data)
        XCTAssertEqual(historical.schemaVersion, "runtime_adapter_mount_receipt.v1")

        XCTAssertThrowsError(try JSONDecoder().decode(RuntimeAdapterMountReceipt.self, from: data)) { error in
            XCTAssertEqual(
                error as? RuntimeAdapterMountReceiptValidationError,
                .invalidSchemaVersion("runtime_adapter_mount_receipt.v1")
            )
        }
    }

    func testMacDestinationCannotForgeIOSSimRuntimeTarget() throws {
        let receipt = try fixtureReceipt(runtimeTarget: "ios_sim")
        let mac = RuntimeDestinationProbe.Observation(runtimeTarget: .mac, stdoutMarker: "runtime_target=mac")

        XCTAssertThrowsError(try RuntimeDestinationProbe.validate(receipt: receipt, against: mac)) { error in
            XCTAssertEqual(
                error as? RuntimeAdapterMountReceiptValidationError,
                .runtimeTargetMismatch(expected: "mac", actual: "ios_sim")
            )
        }
    }

    func testBuilderRejectsMissingOrEmptyRequiredFields() throws {
        let requiredFields = [
            "runtime_target",
            "adapter_sha",
            "adapter_config_sha",
            "base_model_id",
            "base_model_digest",
            "tokenizer_digest",
            "code_head_sha",
            "trainpack_sha",
            "decode_contract_id",
            "ir_map_fingerprint",
            "mounted_demo_catalog_sha",
            "case_ledger_ref",
            "mounted_at"
        ]

        for field in requiredFields {
            XCTAssertThrowsError(try builder(omitting: field).build(), field) { error in
                XCTAssertEqual(error as? RuntimeAdapterMountReceiptValidationError, .missingRequiredField(field))
            }
            XCTAssertThrowsError(try builder(emptying: field).build(), field) { error in
                XCTAssertEqual(error as? RuntimeAdapterMountReceiptValidationError, .missingRequiredField(field))
            }
        }
    }

    func testNonClaimsRejectAdapterLearnedQAAndCannotDecodeSignedOrPassState() throws {
        let learnedQAJSON = """
        {"adapter_learned_qa":true,"candidate_status":"unsigned","runtime_qa_safety":"open"}
        """
        XCTAssertThrowsError(try JSONDecoder().decode(RuntimeAdapterMountNonClaims.self, from: Data(learnedQAJSON.utf8))) { error in
            XCTAssertEqual(error as? RuntimeAdapterMountReceiptValidationError, .invalidNonClaim("adapter_learned_qa"))
        }

        let signedJSON = """
        {"adapter_learned_qa":false,"candidate_status":"signed","runtime_qa_safety":"open"}
        """
        XCTAssertThrowsError(try JSONDecoder().decode(RuntimeAdapterMountNonClaims.self, from: Data(signedJSON.utf8)))

        let passJSON = """
        {"adapter_learned_qa":false,"candidate_status":"unsigned","runtime_qa_safety":"pass"}
        """
        XCTAssertThrowsError(try JSONDecoder().decode(RuntimeAdapterMountNonClaims.self, from: Data(passJSON.utf8)))
    }

    private func fixtureReceipt(runtimeTarget: String = "ios_sim") throws -> RuntimeAdapterMountReceipt {
        try builder(runtimeTarget: runtimeTarget).build()
    }

    private func builder(
        runtimeTarget: String = "ios_sim",
        omitting field: String? = nil,
        emptying emptyField: String? = nil
    ) -> RuntimeAdapterMountReceiptBuilder {
        var builder = RuntimeAdapterMountReceiptBuilder()
        builder.mountVerdict = .pass
        builder.runtimeTarget = value("runtime_target", omitting: field, emptying: emptyField, defaultValue: runtimeTarget)
        builder.adapterSha = value("adapter_sha", omitting: field, emptying: emptyField, defaultValue: "9373fd4174922c4e697f188e24756758ec5a236eb6ae944dfaf115450363d8d6")
        builder.adapterConfigSha = value("adapter_config_sha", omitting: field, emptying: emptyField, defaultValue: "adapter-config-sha")
        builder.baseModelID = value("base_model_id", omitting: field, emptying: emptyField, defaultValue: "Qwen/Qwen3-1.7B")
        builder.baseModelDigest = value("base_model_digest", omitting: field, emptying: emptyField, defaultValue: "base-model-digest")
        builder.tokenizerDigest = value("tokenizer_digest", omitting: field, emptying: emptyField, defaultValue: "tokenizer-digest")
        builder.codeHeadSha = value("code_head_sha", omitting: field, emptying: emptyField, defaultValue: "code-head-sha")
        builder.trainpackSha = value("trainpack_sha", omitting: field, emptying: emptyField, defaultValue: "trainpack-sha")
        builder.decodeContractID = value("decode_contract_id", omitting: field, emptying: emptyField, defaultValue: "qwen-tool-call-format.v1")
        builder.irMapFingerprint = value("ir_map_fingerprint", omitting: field, emptying: emptyField, defaultValue: "ir-map-fingerprint")
        builder.mountedToolCatalogSha = value("mounted_demo_catalog_sha", omitting: field, emptying: emptyField, defaultValue: "mounted-demo-catalog-sha")
        builder.caseLedgerRef = value("case_ledger_ref", omitting: field, emptying: emptyField, defaultValue: "over-refusal-t1/action-question-control-18.jsonl")
        builder.provenance = .firstExecution
        builder.mountedAt = value("mounted_at", omitting: field, emptying: emptyField, defaultValue: "2026-07-06T15:11:06+0800")
        return builder
    }

    private var v1HistoricalJSON: String {
        """
        {
          "schema_version": "runtime_adapter_mount_receipt.v1",
          "mount_verdict": "pass",
          "adapter_sha": "9373fd4174922c4e697f188e24756758ec5a236eb6ae944dfaf115450363d8d6",
          "adapter_config_sha": "adapter-config-sha",
          "base_model_id": "Qwen/Qwen3-1.7B",
          "base_model_digest": "base-model-digest",
          "tokenizer_digest": "tokenizer-digest",
          "code_head_sha": "code-head-sha",
          "trainpack_sha": "trainpack-sha",
          "decode_contract_id": "qwen-tool-call-format.v1",
          "mounted_tool_catalog_sha": "tool-catalog-sha",
          "case_ledger_ref": "over-refusal-t1/action-question-control-18.jsonl",
          "provenance": "first_execution",
          "mounted_at": "2026-07-06T15:11:06+0800",
          "non_claims": {"adapter_learned_qa": false, "candidate_status": "unsigned", "runtime_qa_safety": "open"}
        }
        """
    }

    private func value(_ field: String, omitting omitted: String?, emptying emptied: String?, defaultValue: String) -> String? {
        if omitted == field { return nil }
        if emptied == field { return " \n " }
        return defaultValue
    }

    private func jsonObject(from data: Data) throws -> [String: Any] {
        try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }
}
