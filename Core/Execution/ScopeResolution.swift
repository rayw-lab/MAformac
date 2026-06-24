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
    public static func resolve(frame: ToolCallFrame, cell: StateCellDefinition) throws -> ScopeResolution {
        guard !cell.scope.isEmpty else {
            return ScopeResolution(keys: [cell.id], resolvedScopes: [], origin: .explicit)
        }

        if let requested = requestedScope(from: frame), !requested.isEmpty {
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

    public static func requestedScope(from frame: ToolCallFrame) -> String? {
        frame.slots["direction"]
            ?? frame.slots["position"]
            ?? frame.slots["screen_type"]
            ?? frame.slots["name"]
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
