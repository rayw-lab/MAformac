import Foundation

public struct C6ContractBundleComponent: Codable, Equatable, Sendable {
    public var componentID: String
    public var version: String
    public var contentDigest: String

    enum CodingKeys: String, CodingKey {
        case componentID = "component_id"
        case version
        case contentDigest = "content_digest"
    }

    public init(componentID: String, version: String, contentDigest: String) {
        self.componentID = componentID
        self.version = version
        self.contentDigest = contentDigest
    }
}

public struct C6ContractBundleManifest: Codable, Equatable, Sendable {
    public var manifestVersion: String
    public var components: [C6ContractBundleComponent]

    enum CodingKeys: String, CodingKey {
        case manifestVersion = "manifest_version"
        case components
    }

    public init(manifestVersion: String, components: [C6ContractBundleComponent]) {
        self.manifestVersion = manifestVersion
        self.components = components
    }
}

public struct C6ContractBundleFingerprintRecord: Codable, Equatable, Sendable {
    public var schemaVersion: String
    public var bundleHash: String
    public var componentDigests: [String: String]

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case bundleHash = "bundle_hash"
        case componentDigests = "component_digests"
    }

    public init(schemaVersion: String, bundleHash: String, componentDigests: [String: String]) {
        self.schemaVersion = schemaVersion
        self.bundleHash = bundleHash
        self.componentDigests = componentDigests
    }

    public var hasRequiredFields: Bool {
        !schemaVersion.isEmpty
            && !bundleHash.isEmpty
            && C6ContractBundleFingerprint.requiredComponentIDs.allSatisfy { componentID in
                guard let digest = componentDigests[componentID] else { return false }
                return !digest.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
    }
}

public enum C6ContractBundleError: Error, Equatable, Sendable {
    case missingComponentDigest(componentID: String)
    case missingRequiredComponents(componentIDs: [String])
    case duplicateComponentIDs(componentIDs: [String])
    case unexpectedComponentIDs(componentIDs: [String])
    case unsupportedManifestVersion(expected: String, actual: String)
}

public enum C6ContractBundleFingerprint {
    public static let schemaVersion = "c6_contract_bundle_v1"

    private struct Descriptor: Sendable {
        var componentID: String
        var version: String
        var relativePath: String
        var usesDatasetText: Bool
    }

    private static let descriptors: [Descriptor] = [
        Descriptor(componentID: "c1.semantic_function_contract", version: "v1", relativePath: "contracts/semantic-function-contract.jsonl", usesDatasetText: false),
        Descriptor(componentID: "c2.state_cells_renderer", version: "v1", relativePath: "contracts/state-cells.yaml", usesDatasetText: false),
        Descriptor(componentID: "c6.bench_cases", version: "v1", relativePath: "contracts/c6-bench-cases.jsonl", usesDatasetText: true),
        Descriptor(componentID: "qwen.tool_call_format", version: "v1", relativePath: "contracts/qwen-tool-call-format.yaml", usesDatasetText: false),
        Descriptor(componentID: "d_domain.ir_map", version: "v1", relativePath: "generated/d_domain_ir_map.json", usesDatasetText: false),
        Descriptor(componentID: "d_domain.demo_tool_catalog", version: "v1", relativePath: "generated/D_domain.tools.demo.json", usesDatasetText: false)
    ]

    public static let requiredComponentIDs = descriptors.map(\.componentID).sorted()

    public static func manifest(repoRoot: URL, datasetText: String) throws -> C6ContractBundleManifest {
        let components = try descriptors.map { descriptor in
            let digest: String
            if descriptor.usesDatasetText {
                digest = C6Hash.sha256Hex(Data(datasetText.utf8))
            } else {
                digest = try C6Hash.fileHash(url: repoRoot.appendingPathComponent(descriptor.relativePath))
            }
            return C6ContractBundleComponent(
                componentID: descriptor.componentID,
                version: descriptor.version,
                contentDigest: digest
            )
        }
        return try manifest(components: components)
    }

    public static func receipt(repoRoot: URL, datasetText: String) throws -> C6ContractBundleFingerprintRecord {
        try receipt(manifest: manifest(repoRoot: repoRoot, datasetText: datasetText))
    }

    public static func receipt(components: [C6ContractBundleComponent]) throws -> C6ContractBundleFingerprintRecord {
        try receipt(manifest: manifest(components: components))
    }

    public static func receipt(manifest: C6ContractBundleManifest) throws -> C6ContractBundleFingerprintRecord {
        let validatedManifest = try validated(manifest: manifest)
        let componentDigests = Dictionary(uniqueKeysWithValues: validatedManifest.components.map { ($0.componentID, $0.contentDigest) })
        let bundleHash = C6Hash.sha256Hex(C6CanonicalJSON.encode(BundleHashInput(
            schemaVersion: validatedManifest.manifestVersion,
            componentDigests: componentDigests
        )))
        return C6ContractBundleFingerprintRecord(
            schemaVersion: validatedManifest.manifestVersion,
            bundleHash: bundleHash,
            componentDigests: componentDigests
        )
    }

    public static func manifest(components: [C6ContractBundleComponent]) throws -> C6ContractBundleManifest {
        try validated(manifest: C6ContractBundleManifest(manifestVersion: schemaVersion, components: components))
    }

    static func fingerprint(repoRoot: URL, datasetText: String) throws -> String {
        try fingerprint(manifest: manifest(repoRoot: repoRoot, datasetText: datasetText))
    }

    static func fingerprint(components: [C6ContractBundleComponent]) throws -> String {
        try fingerprint(manifest: manifest(components: components))
    }

    static func fingerprint(manifest: C6ContractBundleManifest) throws -> String {
        C6Hash.sha256Hex(C6CanonicalJSON.encode(try validated(manifest: manifest)))
    }

    private struct BundleHashInput: Codable, Sendable {
        var schemaVersion: String
        var componentDigests: [String: String]

        enum CodingKeys: String, CodingKey {
            case schemaVersion = "schema_version"
            case componentDigests = "component_digests"
        }
    }

    private static func validated(manifest: C6ContractBundleManifest) throws -> C6ContractBundleManifest {
        guard manifest.manifestVersion == schemaVersion else {
            throw C6ContractBundleError.unsupportedManifestVersion(
                expected: schemaVersion,
                actual: manifest.manifestVersion
            )
        }
        let duplicates = duplicateComponentIDs(in: manifest.components)
        guard duplicates.isEmpty else {
            throw C6ContractBundleError.duplicateComponentIDs(componentIDs: duplicates)
        }
        let allowedComponentIDs = Set(requiredComponentIDs)
        let unexpectedIDs = Set(manifest.components.map(\.componentID))
            .subtracting(allowedComponentIDs)
            .sorted()
        guard unexpectedIDs.isEmpty else {
            throw C6ContractBundleError.unexpectedComponentIDs(componentIDs: unexpectedIDs)
        }
        let normalized = try manifest.components
            .map { component -> C6ContractBundleComponent in
                guard !component.contentDigest.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    throw C6ContractBundleError.missingComponentDigest(componentID: component.componentID)
                }
                return component
            }
            .sorted { lhs, rhs in
                if lhs.componentID == rhs.componentID {
                    return lhs.version < rhs.version
                }
                return lhs.componentID < rhs.componentID
            }
        let componentIDs = Set(normalized.map(\.componentID))
        let missingIDs = requiredComponentIDs.filter { !componentIDs.contains($0) }
        guard missingIDs.isEmpty else {
            throw C6ContractBundleError.missingRequiredComponents(componentIDs: missingIDs)
        }
        return C6ContractBundleManifest(manifestVersion: manifest.manifestVersion, components: normalized)
    }

    private static func duplicateComponentIDs(in components: [C6ContractBundleComponent]) -> [String] {
        var seen: Set<String> = []
        var duplicates: Set<String> = []
        for component in components {
            if !seen.insert(component.componentID).inserted {
                duplicates.insert(component.componentID)
            }
        }
        return duplicates.sorted()
    }
}
