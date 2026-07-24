import Foundation

// M16-011 exact migration ledger.
//
// Every supported catalog migration is one unambiguous typed row with a
// non-empty source identity, target identity, direction, reason, and evidence.
// Missing, duplicate, ambiguous, empty-evidence, and empty-identity rows are
// rejected at load. Resolution returns exactly one row for a given source and
// direction or a `.missingRow` error; no similarity, positional, or inferred
// fallback exists. A `4↔5` mapping is refused unconditionally in both
// directions.

public enum ForceStateMigrationDirection: String, Codable, CaseIterable, Equatable, Sendable {
    case forward
    case reverse
}

public struct ForceStateMigrationRow: Codable, Equatable, Sendable {
    public let sourceStableIdentity: String
    public let targetStableIdentity: String
    public let direction: ForceStateMigrationDirection
    public let reason: String
    public let evidence: String

    public init(
        sourceStableIdentity: String,
        targetStableIdentity: String,
        direction: ForceStateMigrationDirection,
        reason: String,
        evidence: String
    ) {
        self.sourceStableIdentity = sourceStableIdentity
        self.targetStableIdentity = targetStableIdentity
        self.direction = direction
        self.reason = reason
        self.evidence = evidence
    }
}

public enum ForceStateMigrationError: Error, Equatable, Sendable {
    case forbidden4to5Mapping(source: String, target: String, direction: ForceStateMigrationDirection)
    case duplicateRow(sourceStableIdentity: String, targetStableIdentity: String, direction: ForceStateMigrationDirection)
    case ambiguousMapping(sourceStableIdentity: String, direction: ForceStateMigrationDirection, existingTarget: String, newTarget: String)
    case emptyEvidence(sourceStableIdentity: String, targetStableIdentity: String)
    case emptyStableIdentity
    case emptyReason(sourceStableIdentity: String, targetStableIdentity: String)
    case missingRow(sourceStableIdentity: String, direction: ForceStateMigrationDirection)
}

public struct ForceStateMigrationLedger: Equatable, Sendable {
    public let rows: [ForceStateMigrationRow]
    private let index: [ForceStateMigrationLedgerKey: ForceStateMigrationRow]

    private init(rows: [ForceStateMigrationRow], index: [ForceStateMigrationLedgerKey: ForceStateMigrationRow]) {
        self.rows = rows
        self.index = index
    }

    public static func load(rows proposedRows: [ForceStateMigrationRow]) throws -> ForceStateMigrationLedger {
        var seenExactRows = Set<ForceStateMigrationExactKey>()
        var indexBySourceDirection = [ForceStateMigrationLedgerKey: ForceStateMigrationRow]()
        for row in proposedRows {
            let source = row.sourceStableIdentity.trimmingCharacters(in: .whitespacesAndNewlines)
            let target = row.targetStableIdentity.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !source.isEmpty, !target.isEmpty else {
                throw ForceStateMigrationError.emptyStableIdentity
            }
            let reason = row.reason.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !reason.isEmpty else {
                throw ForceStateMigrationError.emptyReason(
                    sourceStableIdentity: row.sourceStableIdentity,
                    targetStableIdentity: row.targetStableIdentity
                )
            }
            let evidence = row.evidence.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !evidence.isEmpty else {
                throw ForceStateMigrationError.emptyEvidence(
                    sourceStableIdentity: row.sourceStableIdentity,
                    targetStableIdentity: row.targetStableIdentity
                )
            }
            // M16-011 hard refusal: `4↔5` mapping in either direction.
            if isForbidden4to5(source: source, target: target) {
                throw ForceStateMigrationError.forbidden4to5Mapping(
                    source: row.sourceStableIdentity,
                    target: row.targetStableIdentity,
                    direction: row.direction
                )
            }
            let exactKey = ForceStateMigrationExactKey(
                source: row.sourceStableIdentity,
                target: row.targetStableIdentity,
                direction: row.direction,
                reason: row.reason
            )
            guard seenExactRows.insert(exactKey).inserted else {
                throw ForceStateMigrationError.duplicateRow(
                    sourceStableIdentity: row.sourceStableIdentity,
                    targetStableIdentity: row.targetStableIdentity,
                    direction: row.direction
                )
            }
            let indexKey = ForceStateMigrationLedgerKey(
                source: row.sourceStableIdentity,
                direction: row.direction
            )
            if let existing = indexBySourceDirection[indexKey], existing.targetStableIdentity != row.targetStableIdentity {
                throw ForceStateMigrationError.ambiguousMapping(
                    sourceStableIdentity: row.sourceStableIdentity,
                    direction: row.direction,
                    existingTarget: existing.targetStableIdentity,
                    newTarget: row.targetStableIdentity
                )
            }
            indexBySourceDirection[indexKey] = row
        }
        return ForceStateMigrationLedger(rows: proposedRows, index: indexBySourceDirection)
    }

    public func resolve(
        source sourceStableIdentity: String,
        direction: ForceStateMigrationDirection
    ) throws -> ForceStateMigrationRow {
        let key = ForceStateMigrationLedgerKey(source: sourceStableIdentity, direction: direction)
        guard let row = index[key] else {
            throw ForceStateMigrationError.missingRow(
                sourceStableIdentity: sourceStableIdentity,
                direction: direction
            )
        }
        return row
    }

    // MARK: - Forbidden 4↔5 detection

    /// Patterns that match a stable identity referring to catalog version "4".
    /// Each pattern is a regular expression; if the source matches any
    /// `fourPatterns` AND the target matches any `fivePatterns` (or vice
    /// versa), the mapping is unconditionally refused.
    private static let fourPatterns: [String] = [
        "^4$",
        "\\bv4\\b",
        "\\bcatalog-4\\b",
        "\\b4\\.0\\b",
        "\\bfour\\b",
    ]

    /// Patterns that match a stable identity referring to catalog version "5".
    private static let fivePatterns: [String] = [
        "^5$",
        "\\bv5\\b",
        "\\bcatalog-5\\b",
        "\\b5\\.0\\b",
        "\\bfive\\b",
    ]

    private static func matchesAnyPattern(_ s: String, patterns: [String]) -> Bool {
        for pattern in patterns {
            if s.range(of: pattern, options: .regularExpression) != nil {
                return true
            }
        }
        return false
    }

    private static func isForbidden4to5(source: String, target: String) -> Bool {
        let sourceIsFour = matchesAnyPattern(source, patterns: fourPatterns)
        let sourceIsFive = matchesAnyPattern(source, patterns: fivePatterns)
        let targetIsFour = matchesAnyPattern(target, patterns: fourPatterns)
        let targetIsFive = matchesAnyPattern(target, patterns: fivePatterns)
        return (sourceIsFour && targetIsFive) || (sourceIsFive && targetIsFour)
    }
}

private struct ForceStateMigrationLedgerKey: Hashable {
    let source: String
    let direction: ForceStateMigrationDirection
}

private struct ForceStateMigrationExactKey: Hashable {
    let source: String
    let target: String
    let direction: ForceStateMigrationDirection
    let reason: String
}
