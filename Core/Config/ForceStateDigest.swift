import CryptoKit
import Foundation

// M16-011 canonical catalog digest.
//
// Deterministic digest over the complete load-bearing catalog entry set. The
// canonicalisation sorts entries lexicographically on
// `(kind.rawValue, namespace.rawValue, stableIdentity)`, serialises each entry
// as `kind|namespace|stableIdentity|version|owner\n`, and hashes the aggregate
// UTF-8 bytes with `CryptoKit.SHA256`. Any load-bearing field change flips the
// digest; absent metadata, an unknown algorithm identifier, an unknown
// canonicalisation version, or a mismatched digest all fail closed without a
// silent recomputed replacement.

public enum ForceStateDigestAlgorithm: String, Codable, CaseIterable, Equatable, Sendable {
    case sha256V1 = "sha256-v1"
}

public enum ForceStateCanonicalizationVersion: String, Codable, CaseIterable, Equatable, Sendable {
    case v1
}

public struct ForceStateDigestMetadata: Codable, Equatable, Sendable {
    /// Raw algorithm identifier string.  The typed `ForceStateDigestAlgorithm`
    /// enum is used for canonical output; this field accepts any string so that
    /// `validate(metadata:against:)` can reject unknown algorithms at runtime
    /// (the typed enum's exhaustive `CaseIterable` makes the guard unreachable
    /// when the field itself is typed).
    public let algorithm: String
    public let canonicalizationVersion: ForceStateCanonicalizationVersion
    public let digestHex: String

    public init(
        algorithm: String,
        canonicalizationVersion: ForceStateCanonicalizationVersion,
        digestHex: String
    ) {
        self.algorithm = algorithm
        self.canonicalizationVersion = canonicalizationVersion
        self.digestHex = digestHex
    }
}

public enum ForceStateDigestError: Error, Equatable, Sendable {
    case absentMetadata
    case unknownAlgorithm(String)
    case unknownCanonicalizationVersion(String)
    case mismatchNotRepairedLocally(expected: String, recomputed: String)
}

public enum ForceStateDigest {
    /// Deterministic canonical digest for the entry set. Identical entry sets
    /// in different input orderings produce the same digest; any load-bearing
    /// field change flips the digest.
    public static func canonicalDigest(
        of catalog: ForceStateCatalog,
        algorithm: ForceStateDigestAlgorithm = .sha256V1,
        canonicalizationVersion: ForceStateCanonicalizationVersion = .v1
    ) -> ForceStateDigestMetadata {
        let payload = canonicalPayload(
            entries: catalog.entries,
            canonicalizationVersion: canonicalizationVersion
        )
        let digestHex = hash(algorithm: algorithm, payload: payload)
        return ForceStateDigestMetadata(
            algorithm: algorithm.rawValue,
            canonicalizationVersion: canonicalizationVersion,
            digestHex: digestHex
        )
    }

    /// Fail-closed validation. Never silently recomputes a replacement digest;
    /// on mismatch it throws `.mismatchNotRepairedLocally` with both the
    /// received and recomputed digests so the caller can decide upstream.
    public static func validate(
        metadata proposedMetadata: ForceStateDigestMetadata?,
        against catalog: ForceStateCatalog
    ) throws {
        guard let metadata = proposedMetadata else {
            throw ForceStateDigestError.absentMetadata
        }
        // Enum decoding already restricts algorithm and canonicalization
        // version. However, decoders may pass raw values captured elsewhere;
        // the guards below are the code-level fail-closed backstop mandated
        // by the M16-011 SHALL and its "unknown algorithm" Scenario.
        guard let algorithm = ForceStateDigestAlgorithm(rawValue: metadata.algorithm) else {
            throw ForceStateDigestError.unknownAlgorithm(metadata.algorithm)
        }
        guard ForceStateCanonicalizationVersion.allCases.contains(metadata.canonicalizationVersion) else {
            throw ForceStateDigestError.unknownCanonicalizationVersion(metadata.canonicalizationVersion.rawValue)
        }
        let recomputed = canonicalDigest(
            of: catalog,
            algorithm: algorithm,
            canonicalizationVersion: metadata.canonicalizationVersion
        )
        guard recomputed.digestHex == metadata.digestHex else {
            throw ForceStateDigestError.mismatchNotRepairedLocally(
                expected: metadata.digestHex,
                recomputed: recomputed.digestHex
            )
        }
    }

    // MARK: - Canonicalization internals

    private static func canonicalPayload(
        entries: [ForceStateCatalogEntry],
        canonicalizationVersion: ForceStateCanonicalizationVersion
    ) -> Data {
        switch canonicalizationVersion {
        case .v1:
            let sortedEntries = entries.sorted { lhs, rhs in
                if lhs.kind.rawValue != rhs.kind.rawValue {
                    return lhs.kind.rawValue < rhs.kind.rawValue
                }
                if lhs.namespace.rawValue != rhs.namespace.rawValue {
                    return lhs.namespace.rawValue < rhs.namespace.rawValue
                }
                return lhs.stableIdentity < rhs.stableIdentity
            }
            var buffer = Data()
            // Canonicalisation version prefix keeps the payload sensitive to
            // future version bumps even if the entry serialisation stays the
            // same.
            buffer.append(Data("v=\(canonicalizationVersion.rawValue)\n".utf8))
            for entry in sortedEntries {
                let line = "\(entry.kind.rawValue)|\(entry.namespace.rawValue)|\(entry.stableIdentity)|\(entry.version)|\(entry.owner)\n"
                buffer.append(Data(line.utf8))
            }
            return buffer
        }
    }

    private static func hash(
        algorithm: ForceStateDigestAlgorithm,
        payload: Data
    ) -> String {
        switch algorithm {
        case .sha256V1:
            return SHA256.hash(data: payload)
                .map { String(format: "%02x", $0) }
                .joined()
        }
    }
}
