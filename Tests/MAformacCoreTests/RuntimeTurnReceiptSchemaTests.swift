import XCTest
@testable import MAformacCore

/// G6 刀2: RuntimeTurnReceipt v2 JSON Schema recursive raw-key allowlist.
/// Unknown keys must fail closed (never silently pass via Codable key-dropping).
@MainActor
final class RuntimeTurnReceiptSchemaTests: XCTestCase {
    func testSchemaAllowlistIsNonEmptyAtStrictNodes() throws {
        let schema = try loadSchema()
        let rootKeys = try allowlist(from: schema)
        XCTAssertGreaterThanOrEqual(rootKeys.count, 20, "root allowlist must not be vacuously empty")
        XCTAssertTrue(rootKeys.contains("schema_version"))
        XCTAssertTrue(rootKeys.contains("actions"))
        XCTAssertFalse(rootKeys.contains("proofClass"))
        XCTAssertFalse(rootKeys.contains("proof_class"))

        let properties = try XCTUnwrap(schema["properties"] as? [String: Any])
        let actionsSchema = try XCTUnwrap(properties["actions"] as? [String: Any])
        let items = try XCTUnwrap(actionsSchema["items"] as? [String: Any])
        let actionKeys = try allowlist(from: items)
        XCTAssertGreaterThanOrEqual(actionKeys.count, 10, "actions[] allowlist must not be vacuously empty")
        XCTAssertTrue(actionKeys.contains("action_index"))
        XCTAssertTrue(actionKeys.contains("is_virtual_readback"))
        XCTAssertEqual(items["additionalProperties"] as? Bool, false)
        XCTAssertEqual(schema["additionalProperties"] as? Bool, false)
    }

    func testGeneratedReceiptPassesRecursiveRawKeyAllowlist() throws {
        let root = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let configuration = try foreignConfiguration(runID: "schema-ok", runDirectory: root)
        let turn = try FrontstageVoiceSession(sessionID: "session-schema").submitContainment(utterance: "打开空调")
        let url = try XCTUnwrap(
            RuntimeTurnReceiptAssembler.assembleAndWrite(
                turn: turn,
                routeResult: nil,
                configuration: configuration,
                isCurrent: { true }
            )
        )
        let object = try loadJSONObject(from: url)
        XCTAssertNoThrow(try RuntimeTurnReceiptRawKeyAllowlist.validate(object, schema: loadSchema()))
        XCTAssertNil(object["proofClass"])
        XCTAssertNil(object["proof_class"])
        XCTAssertEqual(object["schema_version"] as? String, RuntimeTurnReceipt.schemaVersionValue)
    }

    func testUnknownRootKeyIsRejected() throws {
        var object = try fixtureReceiptObject()
        object["unknown_root_field"] = "should_fail"
        XCTAssertThrowsError(
            try RuntimeTurnReceiptRawKeyAllowlist.validate(object, schema: loadSchema())
        ) { error in
            let message = String(describing: error)
            XCTAssertTrue(message.contains("unknown_root_field"), message)
        }
        // Codable decode would silently drop unknown keys — allowlist must still reject.
        let data = try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
        XCTAssertNoThrow(try JSONDecoder().decode(RuntimeTurnReceipt.self, from: data))
    }

    func testUnknownActionKeyIsRejected() throws {
        var object = try fixtureReceiptObject()
        var actions = try XCTUnwrap(object["actions"] as? [[String: Any]])
        XCTAssertFalse(actions.isEmpty)
        actions[0]["extra_action_key"] = 1
        object["actions"] = actions
        XCTAssertThrowsError(
            try RuntimeTurnReceiptRawKeyAllowlist.validate(object, schema: loadSchema())
        ) { error in
            let message = String(describing: error)
            XCTAssertTrue(message.contains("extra_action_key"), message)
        }
    }

    func testProofClassKeysAreRejectedAtRoot() throws {
        let schema = try loadSchema()
        for forbidden in ["proofClass", "proof_class"] {
            var object = try fixtureReceiptObject()
            object[forbidden] = "local"
            XCTAssertThrowsError(
                try RuntimeTurnReceiptRawKeyAllowlist.validate(object, schema: schema),
                forbidden
            )
        }
    }

    func testUnknownReadbackKeyIsRejected() throws {
        var object = try fixtureReceiptObject()
        var actions = try XCTUnwrap(object["actions"] as? [[String: Any]])
        actions[0]["readback"] = [
            "key": "ac.power",
            "actualValue": "on",
            "revision": 1,
            "spokenText": "已打开",
            "smuggled": true
        ] as [String: Any]
        object["actions"] = actions
        XCTAssertThrowsError(
            try RuntimeTurnReceiptRawKeyAllowlist.validate(object, schema: loadSchema())
        ) { error in
            let message = String(describing: error)
            XCTAssertTrue(message.contains("smuggled"), message)
        }
    }

    // MARK: - Helpers

    private func fixtureReceiptObject() throws -> [String: Any] {
        let root = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: root) }
        let configuration = try foreignConfiguration(runID: "schema-fixture", runDirectory: root)
        let turn = try FrontstageVoiceSession(sessionID: "session-fixture").submitContainment(utterance: "打开空调")
        let url = try XCTUnwrap(
            RuntimeTurnReceiptAssembler.assembleAndWrite(
                turn: turn,
                routeResult: nil,
                configuration: configuration,
                isCurrent: { true }
            )
        )
        return try loadJSONObject(from: url)
    }

    private func foreignConfiguration(runID: String, runDirectory: URL) throws -> FrontstageRouteReceiptConfiguration {
        try FrontstageRouteReceiptConfiguration.environment(
            [
                "C1_FRONTSTAGE_RECEIPT_EMIT": "1",
                "C1_FRONTSTAGE_RUN_ID": runID,
                "C1_FRONTSTAGE_RUN_NONCE": "0123456789abcdef0123456789abcdef",
                "C1_RUN_DIR": runDirectory.path,
                "C1_FRONTSTAGE_SOURCE_HEAD_SHA": String(repeating: "d", count: 40)
            ],
            currentDirectory: runDirectory
        )
    }

    private func loadSchema() throws -> [String: Any] {
        let url = repoRoot()
            .appendingPathComponent("contracts/schemas/frontstage-route-receipt.schema.json")
        let object = try JSONSerialization.jsonObject(with: Data(contentsOf: url))
        return try XCTUnwrap(object as? [String: Any])
    }

    private func allowlist(from schemaNode: [String: Any]) throws -> Set<String> {
        let properties = try XCTUnwrap(schemaNode["properties"] as? [String: Any])
        return Set(properties.keys)
    }

    private func loadJSONObject(from url: URL) throws -> [String: Any] {
        let object = try JSONSerialization.jsonObject(with: Data(contentsOf: url))
        return try XCTUnwrap(object as? [String: Any])
    }

    private func temporaryDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}

/// Recursive raw-key allowlist validator derived from JSON Schema `properties` + `additionalProperties:false`.
enum RuntimeTurnReceiptRawKeyAllowlist {
    enum ValidationError: Error, CustomStringConvertible {
        case vacuousAllowlist(path: String)
        case unknownKey(path: String, key: String, allowed: [String])
        case expectedObject(path: String)
        case expectedArray(path: String)

        var description: String {
            switch self {
            case let .vacuousAllowlist(path):
                return "vacuous allowlist at \(path)"
            case let .unknownKey(path, key, allowed):
                return "unknown key \(key) at \(path); allowed=\(allowed.sorted())"
            case let .expectedObject(path):
                return "expected object at \(path)"
            case let .expectedArray(path):
                return "expected array at \(path)"
            }
        }
    }

    static func validate(_ value: Any, schema: [String: Any], path: String = "$") throws {
        if schema["type"] as? String == "array" || (schema["type"] as? [Any])?.contains(where: { ($0 as? String) == "array" }) == true {
            guard let items = schema["items"] as? [String: Any] else { return }
            guard let array = value as? [Any] else { throw ValidationError.expectedArray(path: path) }
            for (index, element) in array.enumerated() {
                try validate(element, schema: items, path: "\(path)[\(index)]")
            }
            return
        }

        let types = normalizedTypes(schema["type"])
        if types.contains("null"), value is NSNull { return }
        if types == ["null"] { return }

        guard let object = value as? [String: Any] else {
            if types.contains("object") == false { return }
            throw ValidationError.expectedObject(path: path)
        }

        let additionalProperties = schema["additionalProperties"] as? Bool
        if let properties = schema["properties"] as? [String: Any] {
            if additionalProperties == false, properties.isEmpty {
                throw ValidationError.vacuousAllowlist(path: path)
            }
            if additionalProperties == false {
                let allowed = Set(properties.keys)
                for key in object.keys where !allowed.contains(key) {
                    throw ValidationError.unknownKey(path: path, key: key, allowed: Array(allowed))
                }
            }
            for (key, childSchemaAny) in properties {
                guard let childValue = object[key] else { continue }
                if let childSchema = childSchemaAny as? [String: Any] {
                    try validate(childValue, schema: childSchema, path: "\(path).\(key)")
                }
            }
            return
        }

        // Schema leaves an open object (e.g. readback without properties).
        // Fail-closed: apply DemoActionReadback raw-key allowlist so nested smuggling cannot vacuous-pass.
        if path.hasSuffix(".readback"), !(value is NSNull) {
            let allowed: Set<String> = ["key", "actualValue", "revision", "spokenText", "scopeOrigin"]
            for key in object.keys where !allowed.contains(key) {
                throw ValidationError.unknownKey(path: path, key: key, allowed: Array(allowed))
            }
        }
    }

    private static func normalizedTypes(_ typeValue: Any?) -> Set<String> {
        if let single = typeValue as? String { return [single] }
        if let many = typeValue as? [Any] {
            return Set(many.compactMap { $0 as? String })
        }
        return []
    }
}
