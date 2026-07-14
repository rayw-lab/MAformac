import Foundation

// MARK: - S3 Product Operator Boundary Gate
// Stateless public ForceStateDigestGate.validate(metadata:against:) throws
// delegates only to ForceStateDigest.validate; no recompute, no catalog ownership, no second algorithm.

/// Thin, stateless gate for force-state digest validation.
///
/// Delegates **solely** to `ForceStateDigest.validate`. Does NOT:
/// - recompute digests
/// - own a catalog
/// - implement a second digest algorithm
/// - perform silent repair
///
/// Claim ceiling: `FORCE_DIGEST_GATE_UNIT_PASS` only.
/// `W9_APP_CONSUMED` is explicitly forbidden for this change.
public struct ForceStateDigestGate: Sendable {
    public init() {}

    /// Validates the provided force-state metadata against the given catalog.
    ///
    /// - Parameters:
    ///   - metadata: Optional digest metadata to validate. `nil` throws `.absentMetadata`.
    ///   - catalog: The force-state catalog to validate against.
    /// - Throws: `ForceStateDigestError` propagated from `ForceStateDigest.validate`.
    ///           - `.absentMetadata` if `metadata` is `nil`
    ///           - `.unknownAlgorithm` if the algorithm identifier is not recognised
    ///           - `.unknownCanonicalizationVersion` if the canonicalisation version is not recognised
    ///           - `.mismatchNotRepairedLocally` if the digest does not match (includes both expected and recomputed values)
    public static func validate(
        metadata: ForceStateDigestMetadata?,
        against catalog: ForceStateCatalog
    ) throws {
        // Direct delegation — no recomputation, no second algorithm, no catalog ownership.
        try ForceStateDigest.validate(metadata: metadata, against: catalog)
    }
}