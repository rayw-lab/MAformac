import XCTest
@testable import MAformacCore

/// `ExpandedFamilyDisplay` — 展开层 device composite（4b 触发聚焦展开，P4-D2②座椅 5 cell 行分3类）。
final class ExpandedFamilyDisplayTests: XCTestCase {
    private let catalog = StateCellPresentationCatalog.load()

    private var seatCells: [DemoVehicleStateCell] {
        [
            DemoVehicleStateCell(key: "seat.heat_level[主驾]", actualValue: "2", revision: 1, visualState: .satisfied),
            DemoVehicleStateCell(key: "seat.vent_level[主驾]", actualValue: "1", revision: 1, visualState: .satisfied),
            DemoVehicleStateCell(key: "seat.massage_force", actualValue: "1", revision: 1, visualState: .satisfied),
            DemoVehicleStateCell(key: "seat.massage_mode", actualValue: "波浪模式", revision: 1, visualState: .satisfied),
            DemoVehicleStateCell(key: "seat.backrest_angle[主驾]", actualValue: "50", revision: 1, visualState: .satisfied),
        ]
    }

    // 🔴 P4-D2②：座椅 5 cell 展开行分 3 类（stepper×3 → percent → badge）
    func testSeatCompositeRowsGroupedByValueType() {
        let display = ExpandedFamilyDisplay.make(for: .seat, from: seatCells, catalog: catalog)
        XCTAssertEqual(display.rows.count, 5)
        XCTAssertEqual(display.rows.map(\.valueType), [.stepper, .stepper, .stepper, .percent, .badge],
                       "座椅展开按 valueType 分组：stepper(加热/通风/按摩力度)→percent(靠背)→badge(按摩模式)")
        XCTAssertEqual(display.title, "座椅")
    }

    // 控件参数派生（range/numericValue/displayText/stepCount 从 contract + valueText 复用）
    func testRowControlParams() {
        let display = ExpandedFamilyDisplay.make(for: .seat, from: seatCells, catalog: catalog)
        let heat = display.rows.first { $0.id == "seat.heat_level[主驾]" }
        XCTAssertEqual(heat?.valueType, .stepper)
        XCTAssertEqual(heat?.range, 0.0...3.0)
        XCTAssertEqual(heat?.stepCount, 3)
        XCTAssertEqual(heat?.numericValue, 2)
        XCTAssertEqual(heat?.displayText, "2挡")
        XCTAssertEqual(heat?.label, "主驾座椅加热")

        let backrest = display.rows.first { $0.id == "seat.backrest_angle[主驾]" }
        XCTAssertEqual(backrest?.valueType, .percent)
        XCTAssertEqual(backrest?.range, 0.0...100.0)
        XCTAssertEqual(backrest?.numericValue, 50)
        XCTAssertEqual(backrest?.displayText, "50%")

        let mode = display.rows.first { $0.id == "seat.massage_mode" }
        XCTAssertEqual(mode?.valueType, .badge)
        XCTAssertEqual(mode?.badgeStyle, .mode("波浪模式"))
        XCTAssertEqual(mode?.displayText, "波浪模式")
        XCTAssertEqual(mode?.rawValue, "波浪模式")
    }

    // toggle cell 派生 isOn（雨刮 power on → 开）
    func testToggleRowIsOn() {
        let display = ExpandedFamilyDisplay.make(
            for: .wiper,
            from: [DemoVehicleStateCell(key: "wiper.power", actualValue: "on", revision: 1, visualState: .satisfied)],
            catalog: catalog
        )
        let power = display.rows.first { $0.id == "wiper.power" }
        XCTAssertEqual(power?.valueType, .toggle)
        XCTAssertTrue(power?.isOn ?? false)
        XCTAssertEqual(power?.displayText, "开")
    }

    func testAcModeRowUsesModeBadgeAndChineseAutoDisplayText() {
        let cooling = ExpandedFamilyDisplay.make(
            for: .ac,
            from: [DemoVehicleStateCell(key: "ac.mode", actualValue: "制冷", revision: 1, visualState: .satisfied)],
            catalog: catalog
        ).rows.first { $0.id == "ac.mode" }
        XCTAssertEqual(cooling?.valueType, .badge)
        XCTAssertEqual(cooling?.badgeStyle, .mode("制冷"))
        XCTAssertEqual(cooling?.displayText, "制冷")

        let auto = ExpandedFamilyDisplay.make(
            for: .ac,
            from: [DemoVehicleStateCell(key: "ac.mode", actualValue: "auto", revision: 1, visualState: .satisfied)],
            catalog: catalog
        ).rows.first { $0.id == "ac.mode" }
        XCTAssertEqual(auto?.badgeStyle, .mode("自动"))
        XCTAssertEqual(auto?.displayText, "自动")
        XCTAssertEqual(auto?.rawValue, "auto")
    }

    func testInteractiveEnumModeRowsUseModeBadges() {
        let cells = [
            DemoVehicleStateCell(key: "volume.mode", actualValue: "现代", revision: 1, visualState: .satisfied),
            DemoVehicleStateCell(key: "wiper.mode", actualValue: "自动模式", revision: 1, visualState: .satisfied),
            DemoVehicleStateCell(key: "fragrance.mode", actualValue: "白茶模式", revision: 1, visualState: .satisfied),
        ]

        let volume = ExpandedFamilyDisplay.make(for: .volume, from: cells, catalog: catalog)
            .rows.first { $0.id == "volume.mode" }
        let wiper = ExpandedFamilyDisplay.make(for: .wiper, from: cells, catalog: catalog)
            .rows.first { $0.id == "wiper.mode" }
        let fragrance = ExpandedFamilyDisplay.make(for: .fragrance, from: cells, catalog: catalog)
            .rows.first { $0.id == "fragrance.mode" }

        XCTAssertEqual(volume?.badgeStyle, .mode("现代"))
        XCTAssertEqual(wiper?.badgeStyle, .mode("自动模式"))
        XCTAssertEqual(fragrance?.badgeStyle, .mode("白茶模式"))
    }

    // 空族 → rows 空（展开无 cell 族不崩）
    func testEmptyFamilyNoRows() {
        let display = ExpandedFamilyDisplay.make(for: .fragrance, from: [], catalog: catalog)
        XCTAssertTrue(display.rows.isEmpty)
        XCTAssertEqual(display.title, "香氛")
    }

    // 只取该族 cell（不混入别族）
    func testOnlyFamilyCells() {
        let cells = [
            DemoVehicleStateCell(key: "seat.heat_level[主驾]", actualValue: "2", revision: 1, visualState: .satisfied),
            DemoVehicleStateCell(key: "ac.power", actualValue: "on", revision: 1, visualState: .satisfied),
        ]
        let display = ExpandedFamilyDisplay.make(for: .seat, from: cells, catalog: catalog)
        XCTAssertEqual(display.rows.count, 1)
        XCTAssertEqual(display.rows.first?.id, "seat.heat_level[主驾]")
    }
}
