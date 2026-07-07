import Foundation

public enum RuntimeAdapterMountVerdict: String, Codable, Equatable, Sendable {
    case pass
    case partial
    case blocked
}

public enum RuntimeAdapterCandidateStatus: String, Codable, Equatable, Sendable {
    case unsigned
}

public enum RuntimeAdapterRuntimeQASafety: String, Codable, Equatable, Sendable {
    case open
}

public enum RuntimeAdapterMountReceiptValidationError: Error, Equatable, Sendable {
    case missingRequiredField(String)
    case invalidNonClaim(String)
}

public struct RuntimeAdapterMountNonClaims: Codable, Equatable, Sendable {
    public static let defaultOpen = RuntimeAdapterMountNonClaims()

    public let adapterLearnedQA: Bool
    public let candidateStatus: RuntimeAdapterCandidateStatus
    public let runtimeQASafety: RuntimeAdapterRuntimeQASafety

    public init() {
        self.adapterLearnedQA = false
        self.candidateStatus = .unsigned
        self.runtimeQASafety = .open
    }

    enum CodingKeys: String, CodingKey {
        case adapterLearnedQA = "adapter_learned_qa"
        case candidateStatus = "candidate_status"
        case runtimeQASafety = "runtime_qa_safety"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let adapterLearnedQA = try container.decode(Bool.self, forKey: .adapterLearnedQA)
        guard adapterLearnedQA == false else {
            throw RuntimeAdapterMountReceiptValidationError.invalidNonClaim("adapter_learned_qa")
        }
        self.adapterLearnedQA = adapterLearnedQA
        self.candidateStatus = try container.decode(RuntimeAdapterCandidateStatus.self, forKey: .candidateStatus)
        self.runtimeQASafety = try container.decode(RuntimeAdapterRuntimeQASafety.self, forKey: .runtimeQASafety)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(false, forKey: .adapterLearnedQA)
        try container.encode(RuntimeAdapterCandidateStatus.unsigned, forKey: .candidateStatus)
        try container.encode(RuntimeAdapterRuntimeQASafety.open, forKey: .runtimeQASafety)
    }
}

public struct RuntimeAdapterMountReceipt: Codable, Equatable, Sendable {
    public static let schemaVersion = "runtime_adapter_mount_receipt.v1"

    public var schemaVersion: String
    public var mountVerdict: RuntimeAdapterMountVerdict
    public var adapterSha: String
    public var adapterConfigSha: String
    public var baseModelID: String
    public var baseModelDigest: String
    public var tokenizerDigest: String
    public var codeHeadSha: String
    public var trainpackSha: String
    public var decodeContractID: String
    public var mountedToolCatalogSha: String
    public var caseLedgerRef: String
    public var provenance: DemoRuntimeAdapterProvenance
    public var mountedAt: String
    public var nonClaims: RuntimeAdapterMountNonClaims

    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case mountVerdict = "mount_verdict"
        case adapterSha = "adapter_sha"
        case adapterConfigSha = "adapter_config_sha"
        case baseModelID = "base_model_id"
        case baseModelDigest = "base_model_digest"
        case tokenizerDigest = "tokenizer_digest"
        case codeHeadSha = "code_head_sha"
        case trainpackSha = "trainpack_sha"
        case decodeContractID = "decode_contract_id"
        case mountedToolCatalogSha = "mounted_tool_catalog_sha"
        case caseLedgerRef = "case_ledger_ref"
        case provenance
        case mountedAt = "mounted_at"
        case nonClaims = "non_claims"
    }

    public init(
        schemaVersion: String = RuntimeAdapterMountReceipt.schemaVersion,
        mountVerdict: RuntimeAdapterMountVerdict,
        adapterSha: String,
        adapterConfigSha: String,
        baseModelID: String,
        baseModelDigest: String,
        tokenizerDigest: String,
        codeHeadSha: String,
        trainpackSha: String,
        decodeContractID: String,
        mountedToolCatalogSha: String,
        caseLedgerRef: String,
        provenance: DemoRuntimeAdapterProvenance,
        mountedAt: String,
        nonClaims: RuntimeAdapterMountNonClaims = .defaultOpen
    ) throws {
        self.schemaVersion = schemaVersion
        self.mountVerdict = mountVerdict
        self.adapterSha = adapterSha
        self.adapterConfigSha = adapterConfigSha
        self.baseModelID = baseModelID
        self.baseModelDigest = baseModelDigest
        self.tokenizerDigest = tokenizerDigest
        self.codeHeadSha = codeHeadSha
        self.trainpackSha = trainpackSha
        self.decodeContractID = decodeContractID
        self.mountedToolCatalogSha = mountedToolCatalogSha
        self.caseLedgerRef = caseLedgerRef
        self.provenance = provenance
        self.mountedAt = mountedAt
        self.nonClaims = nonClaims
        try validate()
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.schemaVersion = try container.decode(String.self, forKey: .schemaVersion)
        self.mountVerdict = try container.decode(RuntimeAdapterMountVerdict.self, forKey: .mountVerdict)
        self.adapterSha = try container.decode(String.self, forKey: .adapterSha)
        self.adapterConfigSha = try container.decode(String.self, forKey: .adapterConfigSha)
        self.baseModelID = try container.decode(String.self, forKey: .baseModelID)
        self.baseModelDigest = try container.decode(String.self, forKey: .baseModelDigest)
        self.tokenizerDigest = try container.decode(String.self, forKey: .tokenizerDigest)
        self.codeHeadSha = try container.decode(String.self, forKey: .codeHeadSha)
        self.trainpackSha = try container.decode(String.self, forKey: .trainpackSha)
        self.decodeContractID = try container.decode(String.self, forKey: .decodeContractID)
        self.mountedToolCatalogSha = try container.decode(String.self, forKey: .mountedToolCatalogSha)
        self.caseLedgerRef = try container.decode(String.self, forKey: .caseLedgerRef)
        self.provenance = try container.decode(DemoRuntimeAdapterProvenance.self, forKey: .provenance)
        self.mountedAt = try container.decode(String.self, forKey: .mountedAt)
        self.nonClaims = try container.decode(RuntimeAdapterMountNonClaims.self, forKey: .nonClaims)
        try validate()
    }

    public func validate() throws {
        try Self.requireNonEmpty(schemaVersion, field: "schema_version")
        try Self.requireNonEmpty(adapterSha, field: "adapter_sha")
        try Self.requireNonEmpty(adapterConfigSha, field: "adapter_config_sha")
        try Self.requireNonEmpty(baseModelID, field: "base_model_id")
        try Self.requireNonEmpty(baseModelDigest, field: "base_model_digest")
        try Self.requireNonEmpty(tokenizerDigest, field: "tokenizer_digest")
        try Self.requireNonEmpty(codeHeadSha, field: "code_head_sha")
        try Self.requireNonEmpty(trainpackSha, field: "trainpack_sha")
        try Self.requireNonEmpty(decodeContractID, field: "decode_contract_id")
        try Self.requireNonEmpty(mountedToolCatalogSha, field: "mounted_tool_catalog_sha")
        try Self.requireNonEmpty(caseLedgerRef, field: "case_ledger_ref")
        try Self.requireNonEmpty(mountedAt, field: "mounted_at")
        guard nonClaims.adapterLearnedQA == false else {
            throw RuntimeAdapterMountReceiptValidationError.invalidNonClaim("adapter_learned_qa")
        }
        guard nonClaims.candidateStatus == .unsigned else {
            throw RuntimeAdapterMountReceiptValidationError.invalidNonClaim("candidate_status")
        }
        guard nonClaims.runtimeQASafety == .open else {
            throw RuntimeAdapterMountReceiptValidationError.invalidNonClaim("runtime_qa_safety")
        }
    }

    public static func jsonEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return encoder
    }

    private static func requireNonEmpty(_ value: String, field: String) throws {
        guard !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw RuntimeAdapterMountReceiptValidationError.missingRequiredField(field)
        }
    }
}

public struct RuntimeAdapterMountReceiptBuilder: Equatable, Sendable {
    public var mountVerdict: RuntimeAdapterMountVerdict = .blocked
    public var adapterSha: String?
    public var adapterConfigSha: String?
    public var baseModelID: String?
    public var baseModelDigest: String?
    public var tokenizerDigest: String?
    public var codeHeadSha: String?
    public var trainpackSha: String?
    public var decodeContractID: String?
    public var mountedToolCatalogSha: String?
    public var caseLedgerRef: String?
    public var provenance: DemoRuntimeAdapterProvenance = .firstExecution
    public var mountedAt: String?

    public init() {}

    public func build() throws -> RuntimeAdapterMountReceipt {
        try RuntimeAdapterMountReceipt(
            mountVerdict: mountVerdict,
            adapterSha: try required(adapterSha, field: "adapter_sha"),
            adapterConfigSha: try required(adapterConfigSha, field: "adapter_config_sha"),
            baseModelID: try required(baseModelID, field: "base_model_id"),
            baseModelDigest: try required(baseModelDigest, field: "base_model_digest"),
            tokenizerDigest: try required(tokenizerDigest, field: "tokenizer_digest"),
            codeHeadSha: try required(codeHeadSha, field: "code_head_sha"),
            trainpackSha: try required(trainpackSha, field: "trainpack_sha"),
            decodeContractID: try required(decodeContractID, field: "decode_contract_id"),
            mountedToolCatalogSha: try required(mountedToolCatalogSha, field: "mounted_tool_catalog_sha"),
            caseLedgerRef: try required(caseLedgerRef, field: "case_ledger_ref"),
            provenance: provenance,
            mountedAt: try required(mountedAt, field: "mounted_at")
        )
    }

    private func required(_ value: String?, field: String) throws -> String {
        guard let value else {
            throw RuntimeAdapterMountReceiptValidationError.missingRequiredField(field)
        }
        guard !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw RuntimeAdapterMountReceiptValidationError.missingRequiredField(field)
        }
        return value
    }
}
