import XCTest
@testable import MAformacCore

final class RuntimeAdapterMountReceiptTests: XCTestCase {
    func testReceiptRoundTripsWithDeterministicSnakeCaseJSON() throws {
        let receipt = try fixtureReceipt()
        let encoder = RuntimeAdapterMountReceipt.jsonEncoder()
        let data = try encoder.encode(receipt)
        let json = String(decoding: data, as: UTF8.self)

        XCTAssertTrue(json.contains(#""adapter_sha":"9373fd4174922c4e697f188e24756758ec5a236eb6ae944dfaf115450363d8d6""#))
        XCTAssertTrue(json.contains(#""adapter_config_sha":"adapter-config-sha""#))
        XCTAssertTrue(json.contains(#""base_model_id":"Qwen/Qwen3-1.7B""#))
        XCTAssertTrue(json.contains(#""code_head_sha":"code-head-sha""#))
        XCTAssertTrue(json.contains(#""decode_contract_id":"qwen-tool-call-format.v1""#))
        XCTAssertTrue(json.contains(#""mounted_tool_catalog_sha":"tool-catalog-sha""#))
        XCTAssertTrue(json.contains(#""case_ledger_ref":"over-refusal-t1/action-question-control-18.jsonl""#))
        XCTAssertTrue(json.contains(#""non_claims":{"adapter_learned_qa":false,"candidate_status":"unsigned","runtime_qa_safety":"open"}"#))
        XCTAssertFalse(json.contains("adapterSha"))
        XCTAssertFalse(json.contains("candidateStatus"))

        let decoded = try JSONDecoder().decode(RuntimeAdapterMountReceipt.self, from: data)
        try decoded.validate()
        XCTAssertEqual(decoded, receipt)
        XCTAssertEqual(decoded.nonClaims.adapterLearnedQA, false)
        XCTAssertEqual(decoded.nonClaims.candidateStatus, .unsigned)
        XCTAssertEqual(decoded.nonClaims.runtimeQASafety, .open)
    }

    func testBuilderRejectsMissingOrEmptyRequiredFields() throws {
        let requiredFields = [
            "adapter_sha",
            "adapter_config_sha",
            "base_model_id",
            "base_model_digest",
            "tokenizer_digest",
            "code_head_sha",
            "trainpack_sha",
            "decode_contract_id",
            "mounted_tool_catalog_sha",
            "case_ledger_ref",
            "mounted_at"
        ]

        for field in requiredFields {
            XCTAssertThrowsError(try builder(omitting: field).build(), field) { error in
                XCTAssertEqual(
                    error as? RuntimeAdapterMountReceiptValidationError,
                    .missingRequiredField(field)
                )
            }
            XCTAssertThrowsError(try builder(emptying: field).build(), field) { error in
                XCTAssertEqual(
                    error as? RuntimeAdapterMountReceiptValidationError,
                    .missingRequiredField(field)
                )
            }
        }
    }

    func testNonClaimsRejectAdapterLearnedQAAndCannotDecodeSignedOrPassState() throws {
        let learnedQAJSON = """
        {"adapter_learned_qa":true,"candidate_status":"unsigned","runtime_qa_safety":"open"}
        """
        XCTAssertThrowsError(try JSONDecoder().decode(RuntimeAdapterMountNonClaims.self, from: Data(learnedQAJSON.utf8))) { error in
            XCTAssertEqual(
                error as? RuntimeAdapterMountReceiptValidationError,
                .invalidNonClaim("adapter_learned_qa")
            )
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

    func testReceiptDecodeRejectsEmptyRequiredField() throws {
        let receipt = try fixtureReceipt()
        var object = try jsonObject(from: RuntimeAdapterMountReceipt.jsonEncoder().encode(receipt))
        object["adapter_sha"] = " "
        let data = try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])

        XCTAssertThrowsError(try JSONDecoder().decode(RuntimeAdapterMountReceipt.self, from: data)) { error in
            XCTAssertEqual(
                error as? RuntimeAdapterMountReceiptValidationError,
                .missingRequiredField("adapter_sha")
            )
        }
    }

    func testFixtureAdapterShaRoundTrips() throws {
        let receipt = try fixtureReceipt()
        let data = try RuntimeAdapterMountReceipt.jsonEncoder().encode(receipt)
        let decoded = try JSONDecoder().decode(RuntimeAdapterMountReceipt.self, from: data)

        XCTAssertEqual(
            decoded.adapterSha,
            "9373fd4174922c4e697f188e24756758ec5a236eb6ae944dfaf115450363d8d6"
        )
    }

    private func fixtureReceipt() throws -> RuntimeAdapterMountReceipt {
        try builder().build()
    }

    private func builder(omitting field: String? = nil, emptying emptyField: String? = nil) -> RuntimeAdapterMountReceiptBuilder {
        var builder = RuntimeAdapterMountReceiptBuilder()
        builder.mountVerdict = .pass
        builder.adapterSha = value("adapter_sha", omitting: field, emptying: emptyField, defaultValue: "9373fd4174922c4e697f188e24756758ec5a236eb6ae944dfaf115450363d8d6")
        builder.adapterConfigSha = value("adapter_config_sha", omitting: field, emptying: emptyField, defaultValue: "adapter-config-sha")
        builder.baseModelID = value("base_model_id", omitting: field, emptying: emptyField, defaultValue: "Qwen/Qwen3-1.7B")
        builder.baseModelDigest = value("base_model_digest", omitting: field, emptying: emptyField, defaultValue: "base-model-digest")
        builder.tokenizerDigest = value("tokenizer_digest", omitting: field, emptying: emptyField, defaultValue: "tokenizer-digest")
        builder.codeHeadSha = value("code_head_sha", omitting: field, emptying: emptyField, defaultValue: "code-head-sha")
        builder.trainpackSha = value("trainpack_sha", omitting: field, emptying: emptyField, defaultValue: "trainpack-sha")
        builder.decodeContractID = value("decode_contract_id", omitting: field, emptying: emptyField, defaultValue: "qwen-tool-call-format.v1")
        builder.mountedToolCatalogSha = value("mounted_tool_catalog_sha", omitting: field, emptying: emptyField, defaultValue: "tool-catalog-sha")
        builder.caseLedgerRef = value("case_ledger_ref", omitting: field, emptying: emptyField, defaultValue: "over-refusal-t1/action-question-control-18.jsonl")
        builder.provenance = .firstExecution
        builder.mountedAt = value("mounted_at", omitting: field, emptying: emptyField, defaultValue: "2026-07-06T15:11:06+0800")
        return builder
    }

    private func value(_ field: String, omitting omitted: String?, emptying emptied: String?, defaultValue: String) -> String? {
        if omitted == field {
            return nil
        }
        if emptied == field {
            return " \n "
        }
        return defaultValue
    }

    private func jsonObject(from data: Data) throws -> [String: Any] {
        try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }
}
