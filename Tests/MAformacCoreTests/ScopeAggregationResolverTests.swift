import XCTest
@testable import MAformacCore

/// `ScopeAggregationResolver` — per-base scope 聚合纯逻辑（AD-13，gptpro 跨厂商审第 8 点提取）。
/// 纯逻辑可直接测（不经 yaml 加载）；gptpro 第 1 点点名的 ambient/sunroof 在此闭合。
final class ScopeAggregationResolverTests: XCTestCase {

    // wiper 域含「前后」集合词 → 前+后 聚合「前后」（非硬编码「全车」，gptpro 第1点核心 bug）
    func testWiperFrontRearAggregatesToFrontRear() {
        XCTAssertEqual(
            ScopeAggregationResolver.aggregateLabel(activeScopes: ["前", "后"], scopeDomain: ["前", "后", "前后"]),
            "前后"
        )
    }

    // screen 域含「全车屏」集合词 → 全 4 物理屏聚合「全车屏」
    func testScreenAllPhysicalScreensAggregatesToAllScreens() {
        XCTAssertEqual(
            ScopeAggregationResolver.aggregateLabel(
                activeScopes: ["中控屏", "仪表屏", "主驾屏", "副驾屏"],
                scopeDomain: ["中控屏", "仪表屏", "主驾屏", "副驾屏", "全车屏"]
            ),
            "全车屏"
        )
    }

    // 🔴 gptpro 第1点点名：sunroof 前排+后排 → 域集合词「全车」
    func testSunroofFrontRearAggregatesToAllCar() {
        XCTAssertEqual(
            ScopeAggregationResolver.aggregateLabel(
                activeScopes: ["前排", "后排"],
                scopeDomain: ["前排", "后排", "全车"]
            ),
            "全车"
        )
    }

    // 🔴 gptpro 第1点点名：ambient.brightness 域 5 区无集合词 → fallback「全车」（记录现状，demo 轻治理）
    // 氛围灯 5 区（面发光/轮廓/门板/仪表板/中央通道）域内无「全车」类集合词 → collectionWord fallback「全车」。
    func testAmbientAllZonesAggregationLabel() {
        let zones = ["面发光氛围灯", "轮廓氛围灯", "门板氛围灯", "仪表板氛围灯", "中央通道氛围灯"]
        XCTAssertEqual(
            ScopeAggregationResolver.aggregateLabel(activeScopes: zones, scopeDomain: zones),
            "全车",
            "氛围灯域无集合词 → fallback「全车」（现状；若未来 yaml 定「全车氛围灯」集合词，更新此测试 + 域）"
        )
    }

    // window/ac/seat 域含「全车」→ 4 区全激活聚合「全车」
    func testFourZonesAggregatesToAllCar() {
        XCTAssertEqual(
            ScopeAggregationResolver.aggregateLabel(
                activeScopes: ["主驾", "副驾", "左后", "右后"],
                scopeDomain: ["主驾", "副驾", "左后", "右后", "全车"]
            ),
            "全车"
        )
    }

    // 跨域 lattice：前两座 → 前排（与具体 base 无关）
    func testFrontSeatsAggregateToFrontRow() {
        XCTAssertEqual(
            ScopeAggregationResolver.aggregateLabel(
                activeScopes: ["主驾", "副驾"],
                scopeDomain: ["主驾", "副驾", "左后", "右后", "全车"]
            ),
            "前排"
        )
    }

    // 跨域 lattice：两后座 → 后排
    func testRearSeatsAggregateToRearRow() {
        XCTAssertEqual(
            ScopeAggregationResolver.aggregateLabel(
                activeScopes: ["左后", "右后"],
                scopeDomain: ["主驾", "副驾", "左后", "右后", "全车"]
            ),
            "后排"
        )
    }

    // 单 scope 不聚合（保留单 scope 走 individual 路径）
    func testSingleScopeNoAggregation() {
        XCTAssertNil(
            ScopeAggregationResolver.aggregateLabel(activeScopes: ["主驾"], scopeDomain: ["主驾", "副驾", "全车"])
        )
    }

    // 部分非成集合的 scope 组合 → nil（不强聚合，退化保留）
    func testPartialNonLatticeScopesNoAggregation() {
        XCTAssertNil(
            ScopeAggregationResolver.aggregateLabel(
                activeScopes: ["主驾", "左后"],
                scopeDomain: ["主驾", "副驾", "左后", "右后", "全车"]
            ),
            "主驾+左后 不成任何集合规则 → 不聚合"
        )
    }

    // 🔴 base-aware 关键证明：同样「主+副」在不同域结果不同（这正是 gptpro 第8点「per-base 非全局 if」的价值）。
    // ac.fan_speed 域 [主驾,副驾,全车]（风量仅两区）→ 主+副 = 全 executable → 域集合词「全车」（executable 全集命中优先于 lattice）。
    // 对比 testFrontSeatsAggregateToFrontRow（温度域含左后/右后）→ 主+副 = 前排。证明聚合是 per-base 语义非全局规则。
    func testTwoZoneDomainFullSetAggregatesToCollectionWord() {
        XCTAssertEqual(
            ScopeAggregationResolver.aggregateLabel(
                activeScopes: ["主驾", "副驾"],
                scopeDomain: ["主驾", "副驾", "全车"]
            ),
            "全车",
            "两区域(风量)全激活 = 该域全集 → 集合词「全车」（executable 全集命中优先于 lattice 前排规则）"
        )
    }
}
