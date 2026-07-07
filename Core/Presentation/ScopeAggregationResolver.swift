import Foundation

/// scope 聚合 resolver（AD-13 / `derivation-layer-discipline` 铁律：聚合是 **per-base semantic aggregation** 非全局 if）。
///
/// 输入某 base 的 scope 域（来自 `state-cells.yaml` 的 `scope`）+ 当前激活 scopes → domain-specific 集合词 or nil。
/// 提取自 `StateCellPresentationCatalog.aggregateScopeLabel` 内联逻辑（gptpro 跨厂商审第 8 点：
/// 「下一刀最该补 ScopeAggregationResolver，scope 聚合不靠硬编码『全车』set equality」）。
///
/// 独立纯逻辑 = 可直接单测（不经 yaml 加载）；catalog 作薄 wrapper 注入 scope 域。
enum ScopeAggregationResolver {
    /// 集合词（覆盖全域的范围词，本身不算 executable scope；按域取对应集合词）。
    static let collectionScopes: Set<String> = ["全车", "全车屏", "前后"]

    /// per-base scope 聚合标签。
    /// - Parameters:
    ///   - activeScopes: 当前激活的 scope（去重 >1 才聚合；单 scope 返 nil 不聚合）。
    ///   - scopeDomain: 该 base 的完整 scope 域（state-cells `scope` 列表，决定该域的集合词与 executable 子集）。
    /// - Returns: domain-specific 集合词（`全车`/`全车屏`/`前后`/`前排`/`后排`）；不命中集合规则返 `nil`（保留单 scope/退化）。
    static func aggregateLabel(activeScopes: [String], scopeDomain: [String]) -> String? {
        let unique = Set(activeScopes)
        guard unique.count > 1 else { return nil }

        // 🔴 集合词从该 base 的 scope 域取，非硬编码「全车」（gptpro 第 1 点核心 bug）：
        //   wiper 域含「前后」→ 前+后 聚合成「前后」；screen 域含「全车屏」→ 全屏聚合成「全车屏」。
        let collectionWord = scopeDomain.first { collectionScopes.contains($0) } ?? "全车"
        let executable = Set(scopeDomain.filter { !collectionScopes.contains($0) })

        // 域内全 executable scope 命中 → 该域集合词（wiper→前后 / screen→全车屏 / sunroof 前后排→全车 / 余→全车）。
        if !executable.isEmpty, unique == executable { return collectionWord }
        // 跨域固定 lattice 规则（与具体 base 无关的通用聚合：前两排→前排 / 两后→后排 / 前后排→该域集合词）。
        if unique == Set(["主驾", "副驾"]) { return "前排" }
        if unique == Set(["左后", "右后"]) { return "后排" }
        if unique == Set(["前排", "后排"]) { return collectionWord }
        return nil
    }
}
