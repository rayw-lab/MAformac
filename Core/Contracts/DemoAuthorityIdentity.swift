import Foundation

public struct DemoAuthorityIdentity: Codable, Equatable, Sendable {
    public let matrixSourceSHA256: String
    public let runtimeContractBundleDigest: String

    public static let current = DemoAuthorityIdentity(
        matrixSourceSHA256: DemoCapabilityMatrixCatalog.sourceSHA256,
        runtimeContractBundleDigest: DemoRuntimeContractBundleCatalog.runtimeContractBundleDigest
    )
}
