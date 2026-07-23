public struct DDomainCatalogReceiptArtifacts: Equatable, Sendable {
    public let irMapName: String
    public let irMapFingerprint: String
    public let mountedCatalogName: String
    public let mountedDemoCatalogSha: String
}

public enum DDomainMountedToolCatalog {
    public static let irMapFingerprint = DDomainIRMap.irMapCompiledFingerprint
    public static let mountedCatalogKind = "mounted_demo_catalog_sha"

    public static let mountedToolNames: Set<String> = [
        "adjust_ac_temperature_to_number",
        "close_ac",
        "open_ac",
        "open_atmosphere_lamp",
        "open_seat_heat",
        "open_window_by_number"
    ]

    public static let personaAvoidListToolNames: Set<String> = [
        "raise_ac_temperature_by_exp",
        "lower_ac_temperature_by_exp",
        "lock_ac"
    ]

    public static let mountedDemoCatalogSha: String = {
        var data = try! C6CanonicalJSON.encode(mountedToolNames.sorted())
        data.append(0x0A)
        return C6Hash.sha256Hex(data)
    }()

    public static let receiptArtifacts = DDomainCatalogReceiptArtifacts(
        irMapName: "ir_map_fingerprint",
        irMapFingerprint: irMapFingerprint,
        mountedCatalogName: mountedCatalogKind,
        mountedDemoCatalogSha: mountedDemoCatalogSha
    )
}
