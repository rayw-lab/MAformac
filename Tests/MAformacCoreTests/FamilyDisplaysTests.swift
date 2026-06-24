import XCTest
@testable import MAformacCore

/// `VehicleCardDisplay.familyDisplays` — 10 族全景常驻摘要层（AD-9/10/11）。
/// 与 `VehicleCardDisplayTests`（device 级 `displays()`）正交：那 5 测试不破是硬门。
final class FamilyDisplaysTests: XCTestCase {

    // 计划 Task4 核心：每族 1 卡显主 cell + 族名 title + ambient 色块 badge
    func testFamilyDisplaysOnePerFamilyShowingPrimaryCell() {
        let displays = VehicleCardDisplay.familyDisplays(
            from: [
                DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: "24", revision: 1, visualState: .satisfied),
                DemoVehicleStateCell(key: "ac.power", actualValue: "on", revision: 1, visualState: .satisfied),
                DemoVehicleStateCell(key: "ambient.color", actualValue: "红色", revision: 1, visualState: .satisfied)
            ],
            catalog: .load()
        )
        // ac 族 1 卡：族名 title「空调」+ 主 cell temp_setpoint 值「24℃」（非 ac.power）
        let ac = displays.first { $0.familyCardID == .ac }
        XCTAssertEqual(ac?.title, "空调")
        XCTAssertEqual(ac?.valueText, "24℃")
        // ambient 族 badge = colorSwatch（炸场色块）
        let amb = displays.first { $0.familyCardID == .ambient }
        if case .colorSwatch(let name)? = amb?.badgeStyle { XCTAssertEqual(name, "红色") }
        else { XCTFail("ambient should be colorSwatch, got \(String(describing: amb?.badgeStyle))") }
    }

    // 🔴 设计点：10 族全景常驻——空输入也返 10 张（全 normal 占位），冷启动不空屏
    func testFamilyDisplaysAlwaysReturnsTenCardsEvenWhenEmpty() {
        let displays = VehicleCardDisplay.familyDisplays(from: [], catalog: .load())
        XCTAssertEqual(displays.count, 10)
        XCTAssertTrue(displays.allSatisfy { $0.visualState == .normal }, "空输入应全 normal 占位")
        XCTAssertTrue(displays.allSatisfy { $0.valueText == "未激活" })
        XCTAssertEqual(Set(displays.compactMap { $0.familyCardID }), Set(FamilyCardID.allCases))
    }

    // 🔴 设计点：无 cell 族 = normal 占位卡（族名 + 未激活 + scopeBadge nil）
    func testAbsentFamilyRendersNormalPlaceholder() {
        let displays = VehicleCardDisplay.familyDisplays(
            from: [DemoVehicleStateCell(key: "ac.power", actualValue: "on", revision: 1, visualState: .satisfied)],
            catalog: .load()
        )
        let fragrance = displays.first { $0.familyCardID == .fragrance }
        XCTAssertEqual(fragrance?.title, "香氛")
        XCTAssertEqual(fragrance?.valueText, "未激活")
        XCTAssertEqual(fragrance?.visualState, .normal)
        XCTAssertNil(fragrance?.scopeBadge)
    }

    // 🔴 设计点：常驻骨架固定序 = allowlist row_count 降序（不按 revision，激活不跳位）
    func testFamilyDisplaysFixedRowCountOrder() {
        // 故意给低频族高 revision，高频族低 revision —— 验证仍按固定 displayOrder 不按 revision
        let displays = VehicleCardDisplay.familyDisplays(
            from: [
                DemoVehicleStateCell(key: "fragrance.power", actualValue: "on", revision: 9, visualState: .satisfied),
                DemoVehicleStateCell(key: "seat.heat_level[主驾]", actualValue: "1", revision: 1, visualState: .satisfied)
            ],
            catalog: .load()
        )
        XCTAssertEqual(displays.map { $0.familyCardID }, FamilyCardID.displayOrder.map { Optional($0) })
        // seat（row_count 696）必排 fragrance（32）之前，即便 fragrance revision 更高
        let seatIdx = displays.firstIndex { $0.familyCardID == .seat }!
        let fragIdx = displays.firstIndex { $0.familyCardID == .fragrance }!
        XCTAssertLessThan(seatIdx, fragIdx)
    }

    // 🔴 设计点 occupancy：族卡态 = 族内所有 cell dominant 态（「打开空调」动 ac.power，温度 normal，族卡仍亮）
    func testFamilyStateAggregatesDominantAcrossCells() {
        let displays = VehicleCardDisplay.familyDisplays(
            from: [
                DemoVehicleStateCell(key: "ac.power", actualValue: "on", revision: 1, visualState: .satisfied),
                DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: "24", revision: 0, visualState: .normal)
            ],
            catalog: .load()
        )
        let ac = displays.first { $0.familyCardID == .ac }
        // 主 cell temp_setpoint 是 normal，但族内 ac.power satisfied → 族卡 dominant = satisfied（点亮）
        XCTAssertEqual(ac?.visualState, .satisfied)
        XCTAssertEqual(ac?.valueText, "24℃", "value 仍取主 cell temp_setpoint")
    }

    // 🔴 P0-1：vehicle.* 不创建第 11 族卡（被过滤，仍 10 族）
    func testVehicleCellsExcludedFromFamilyGrid() {
        let displays = VehicleCardDisplay.familyDisplays(
            from: [
                DemoVehicleStateCell(key: "vehicle.speed", actualValue: "60", revision: 5, visualState: .changing),
                DemoVehicleStateCell(key: "vehicle.gear", actualValue: "D", revision: 5, visualState: .changing)
            ],
            catalog: .load()
        )
        XCTAssertEqual(displays.count, 10)
        XCTAssertFalse(displays.contains { $0.title.contains("车速") || $0.title.contains("挡位") })
    }

    // 裂缝⑤ family 级：默认 scope = 族名 + 淡角标（dim），不在 title 啰嗦
    func testDefaultScopeFamilyCardShowsDimBadge() {
        let displays = VehicleCardDisplay.familyDisplays(
            from: [DemoVehicleStateCell(key: "window.position[主驾]", actualValue: "100", revision: 1, visualState: .satisfied)],
            catalog: .load()
        )
        let win = displays.first { $0.familyCardID == .window }
        XCTAssertEqual(win?.title, "车窗")  // 默认 scope 不进 title
        XCTAssertEqual(win?.valueText, "100%")
        XCTAssertEqual(win?.scopeBadge, ScopeBadge(text: "主驾", style: .dim))  // 淡角标
    }

    // 裂缝⑤ family 级：非默认 scope = 族名前缀显式（副驾车窗），badge nil
    func testNonDefaultScopeFamilyCardExplicitInTitle() {
        let displays = VehicleCardDisplay.familyDisplays(
            from: [DemoVehicleStateCell(key: "window.position[副驾]", actualValue: "50", revision: 1, visualState: .satisfied)],
            catalog: .load()
        )
        let win = displays.first { $0.familyCardID == .window }
        XCTAssertEqual(win?.title, "副驾车窗")  // 非默认显式进 title
        XCTAssertNil(win?.scopeBadge)
    }

    // 裂缝⑥ family 级：全车 fan-out = 1 聚合族卡 + 全车 emphasized badge（不分裂）
    func testAllVehicleFanoutFamilyCardShowsRangeBadge() {
        let displays = VehicleCardDisplay.familyDisplays(
            from: [
                DemoVehicleStateCell(key: "window.position[主驾]", actualValue: "0", revision: 1),
                DemoVehicleStateCell(key: "window.position[副驾]", actualValue: "0", revision: 1),
                DemoVehicleStateCell(key: "window.position[左后]", actualValue: "0", revision: 1),
                DemoVehicleStateCell(key: "window.position[右后]", actualValue: "0", revision: 1)
            ],
            catalog: .load()
        )
        let winCards = displays.filter { $0.familyCardID == .window }
        XCTAssertEqual(winCards.count, 1, "全车 fan-out 聚合 1 卡不分裂")
        XCTAssertEqual(winCards.first?.title, "车窗")
        XCTAssertEqual(winCards.first?.scopeBadge, ScopeBadge(text: "全车", style: .emphasized))
    }

    // enforce（claim-vs-reality）：静态 displayOrder 必匹配 allowlist row_count 降序，防 A2 改 row_count 后漂移
    func testDisplayOrderMatchesAllowlistRowCountSource() throws {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("generated/family-device-allowlist.json")
        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let fams = json["families"] as! [String: Any]
        let expectedOrder = FamilyCardID.allCases.sorted { a, b in
            let ra = (fams[a.allowlistKey] as? [String: Any])?["row_count"] as? Int ?? -1
            let rb = (fams[b.allowlistKey] as? [String: Any])?["row_count"] as? Int ?? -1
            return ra > rb
        }
        XCTAssertEqual(FamilyCardID.displayOrder, expectedOrder, "displayOrder 必须 = allowlist row_count 降序（源漂移则更新 displayOrder）")
        // 每族 allowlistKey 必在 allowlist 中（桥接表 enforce：ambient↔light / sunroofShade↔sunroof）
        for f in FamilyCardID.allCases {
            XCTAssertNotNil(fams[f.allowlistKey], "family \(f) 的 allowlistKey \(f.allowlistKey) 不在 allowlist")
        }
    }
}
