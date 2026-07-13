import Foundation

// M16-011 typed catalog surface.
//
// This file is the K2-catalog-only slice of the W9 core-config-force-state
// authority. It materialises the three M16-011 SHALL Requirements declared in
// `openspec/specs/core-config-force-state/spec.md:93-145` (ratified under
// D-152, `docs/commander-log/decisions.md:1384`) into a typed Swift value
// surface. It intentionally does NOT wire itself into `DemoForceStateBoundary`,
// `DemoVehicleStateStore.replaceCells`, or any App/UI direct-write path;
// M16-012 cutover is a separate D2 slice.

public enum ForceStateCatalogKind: String, Codable, CaseIterable, Equatable, Sendable {
    case debug
    case demo
}

public enum ForceStateCatalogNamespace: String, Codable, CaseIterable, Equatable, Sendable {
    case debug
    case demo
}

public struct ForceStateCatalogEntry: Codable, Equatable, Sendable {
    public let stableIdentity: String
    public let kind: ForceStateCatalogKind
    public let namespace: ForceStateCatalogNamespace
    public let version: String
    public let owner: String

    public init(
        stableIdentity: String,
        kind: ForceStateCatalogKind,
        namespace: ForceStateCatalogNamespace,
        version: String,
        owner: String
    ) {
        self.stableIdentity = stableIdentity
        self.kind = kind
        self.namespace = namespace
        self.version = version
        self.owner = owner
    }
}

public enum ForceStateCatalogError: Error, Equatable, Sendable {
    case duplicateStableIdentity(String)
    case emptyStableIdentity
    case emptyVersion(stableIdentity: String)
    case emptyOwner(stableIdentity: String)
    case secondSameMeaningAuthority
}

public struct ForceStateCatalog: Equatable, Sendable {
    public let entries: [ForceStateCatalogEntry]

    private init(entries: [ForceStateCatalogEntry]) {
        self.entries = entries
    }

    /// Validating factory. Rejects duplicate stable identity, empty required
    /// metadata, and any structurally invalid entry. Empty catalogs are allowed
    /// because the M16-011 SHALL does not require a minimum non-zero cardinality;
    /// it only requires exhaustive typed `debug`/`demo` representation.
    public static func load(entries proposedEntries: [ForceStateCatalogEntry]) throws -> ForceStateCatalog {
        var seenIdentities = Set<String>()
        for entry in proposedEntries {
            let identity = entry.stableIdentity.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !identity.isEmpty else {
                throw ForceStateCatalogError.emptyStableIdentity
            }
            let version = entry.version.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !version.isEmpty else {
                throw ForceStateCatalogError.emptyVersion(stableIdentity: entry.stableIdentity)
            }
            let owner = entry.owner.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !owner.isEmpty else {
                throw ForceStateCatalogError.emptyOwner(stableIdentity: entry.stableIdentity)
            }
            guard seenIdentities.insert(entry.stableIdentity).inserted else {
                throw ForceStateCatalogError.duplicateStableIdentity(entry.stableIdentity)
            }
        }
        return ForceStateCatalog(entries: proposedEntries)
    }
}

/// Aggregator that structurally prevents holding a second same-meaning catalog
/// authority. Callers install the sole catalog via `install(_:)` and every
/// subsequent installation throws `.secondSameMeaningAuthority`, matching the
/// M16-011 Scenario "Unknown or duplicate catalog authority fails closed".
public final class ForceStateCatalogAggregator: @unchecked Sendable {
    private var installedCatalog: ForceStateCatalog?
    private let mutationLock = NSLock()

    public init() {
        self.installedCatalog = nil
    }

    public func install(_ catalog: ForceStateCatalog) throws {
        mutationLock.lock()
        defer { mutationLock.unlock() }
        guard installedCatalog == nil else {
            throw ForceStateCatalogError.secondSameMeaningAuthority
        }
        installedCatalog = catalog
    }

    public var current: ForceStateCatalog? {
        mutationLock.lock()
        defer { mutationLock.unlock() }
        return installedCatalog
    }
}
