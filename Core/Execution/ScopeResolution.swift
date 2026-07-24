import Foundation

public enum ScopeOrigin: String, Codable, Equatable, Sendable {
    case defaulted
    case explicit
    case fanout
}

public struct ScopeResolution: Equatable, Sendable {
    public var keys: [String]
    public var resolvedScopes: [String]
    public var origin: ScopeOrigin

    public init(keys: [String], resolvedScopes: [String], origin: ScopeOrigin) {
        self.keys = keys
        self.resolvedScopes = resolvedScopes
        self.origin = origin
    }
}

public enum C2ScopeResolver {
    /// Scope-bearing slot keys. Distinct non-empty values across these → typed refuse.
    public static let scopeSlotKeys = ["direction", "position", "screen_type", "name"]

    public static func resolve(frame: ToolCallFrame, cell: StateCellDefinition) throws -> ScopeResolution {
        guard !cell.scope.isEmpty else {
            return ScopeResolution(keys: [cell.id], resolvedScopes: [], origin: .explicit)
        }

        if let requested = try requestedScope(from: frame), !requested.isEmpty {
            if isCollectionAlias(requested, cell: cell) {
                let scopes = executableScopes(for: cell)
                return ScopeResolution(
                    keys: scopes.map { scopedKey(cell.id, scope: $0) },
                    resolvedScopes: scopes,
                    origin: .fanout
                )
            }
            guard cell.scope.contains(requested) else {
                throw ToolExecutionError.semanticInvalid("slot_out_of_scope")
            }
            return ScopeResolution(
                keys: [scopedKey(cell.id, scope: requested)],
                resolvedScopes: [requested],
                origin: .explicit
            )
        }

        guard let defaultScope = cell.defaultScope, cell.scope.contains(defaultScope) else {
            throw ToolExecutionError.semanticInvalid("missing_default_scope")
        }
        return ScopeResolution(
            keys: [scopedKey(cell.id, scope: defaultScope)],
            resolvedScopes: [defaultScope],
            origin: .defaulted
        )
    }

    /// Collects explicit scope lexemes. Conflicting distinct values refuse (no first-wins).
    public static func requestedScope(from frame: ToolCallFrame) throws -> String? {
        let present = scopeSlotKeys.compactMap { key -> String? in
            guard let value = frame.slots[key], !value.isEmpty else { return nil }
            return value
        }
        guard !present.isEmpty else { return nil }
        let unique = Array(Set(present))
        guard unique.count == 1 else {
            throw ToolExecutionError.semanticInvalid("scope_conflict")
        }
        return unique[0]
    }

    private static func isCollectionAlias(_ value: String, cell: StateCellDefinition) -> Bool {
        if value == "全车" && cell.scope.contains("全车") {
            return true
        }
        if cell.id == "window.position" {
            return ["所有车窗", "四个车窗", "车窗都"].contains(value)
        }
        return false
    }

    private static func executableScopes(for cell: StateCellDefinition) -> [String] {
        cell.scope.filter { scope in
            scope != "全车" && !scope.hasSuffix("屏") && !scope.hasSuffix("氛围灯")
        }
    }

    private static func scopedKey(_ cellID: String, scope: String) -> String {
        "\(cellID)[\(scope)]"
    }
}
