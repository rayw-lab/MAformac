import XCTest
@testable import MAformacCore

final class VehicleCardDisplayTests: XCTestCase {
    func testCatalogLoadsCellTitlesWithoutDeviceTitleOverwrite() {
        let catalog = StateCellPresentationCatalog.load()

        XCTAssertEqual(catalog.displayTitle(for: "ac.fan_speed"), "空调风量")
        XCTAssertEqual(catalog.displayTitle(for: "window.position"), "车窗")
        XCTAssertEqual(catalog.displayTitle(for: "screen.brightness"), "屏幕亮度")
        XCTAssertEqual(catalog.displayTitle(for: "ambient.brightness"), "氛围灯亮度")
        XCTAssertEqual(catalog.displayTitle(for: "seat.backrest_angle"), "座椅靠背")
        XCTAssertEqual(catalog.defaultScope(for: "window.position"), "主驾")
    }

    func testCatalogExposesControlPanelDefaultsFromStateCells() {
        let catalog = StateCellPresentationCatalog.load()

        XCTAssertEqual(catalog.cellDefinitions.count, 34)
        XCTAssertEqual(catalog.defaultValue(for: "ac.temp_setpoint"), "24")
        XCTAssertEqual(catalog.defaultValue(for: "window.position"), "0")
        XCTAssertEqual(catalog.defaultValue(for: "vehicle.gear"), "P")
        XCTAssertEqual(catalog.defaultValue(for: "ambient.power"), "off")
        XCTAssertEqual(catalog.defaultValue(for: "seat.heat_level"), "0")
    }

    func testDefaultScopeUsesValueCardWithDimBadge() {
        let displays = VehicleCardDisplay.displays(
            from: [
                DemoVehicleStateCell(
                    key: "window.position[主驾]",
                    actualValue: "100",
                    revision: 1,
                    visualState: .satisfied
                )
            ],
            catalog: StateCellPresentationCatalog.load()
        )

        XCTAssertEqual(displays.count, 1)
        XCTAssertEqual(displays[0].title, "车窗")
        XCTAssertEqual(displays[0].valueText, "100%")
        XCTAssertEqual(displays[0].scopeBadge, ScopeBadge(text: "主驾", style: .dim))
    }

    func testExplicitNonDefaultScopeStaysInTitle() {
        let displays = VehicleCardDisplay.displays(
            from: [
                DemoVehicleStateCell(
                    key: "window.position[副驾]",
                    actualValue: "50",
                    revision: 1,
                    visualState: .satisfied
                )
            ],
            catalog: StateCellPresentationCatalog.load()
        )

        XCTAssertEqual(displays.count, 1)
        XCTAssertEqual(displays[0].title, "副驾车窗")
        XCTAssertEqual(displays[0].valueText, "50%")
        XCTAssertNil(displays[0].scopeBadge)
    }

    func testExplicitAllCarFanoutAggregatesToOneCardWithBadge() {
        let displays = VehicleCardDisplay.displays(
            from: [
                DemoVehicleStateCell(key: "window.position[主驾]", actualValue: "0", revision: 1),
                DemoVehicleStateCell(key: "window.position[副驾]", actualValue: "0", revision: 1),
                DemoVehicleStateCell(key: "window.position[左后]", actualValue: "0", revision: 1),
                DemoVehicleStateCell(key: "window.position[右后]", actualValue: "0", revision: 1)
            ],
            catalog: StateCellPresentationCatalog.load()
        )

        XCTAssertEqual(displays.count, 1)
        XCTAssertEqual(displays[0].title, "车窗")
        XCTAssertEqual(displays[0].valueText, "0%")
        XCTAssertEqual(displays[0].scopeBadge, ScopeBadge(text: "全车", style: .emphasized))
        XCTAssertEqual(displays[0].accessibilityKey, "window.position[全车]")
    }

    func testFrontRowWindowAggregationUsesRangeTitle() {
        let displays = VehicleCardDisplay.displays(
            from: [
                DemoVehicleStateCell(key: "window.position[主驾]", actualValue: "100", revision: 1),
                DemoVehicleStateCell(key: "window.position[副驾]", actualValue: "100", revision: 1)
            ],
            catalog: StateCellPresentationCatalog.load()
        )

        XCTAssertEqual(displays.count, 1)
        XCTAssertEqual(displays[0].title, "前排车窗")
        XCTAssertEqual(displays[0].valueText, "100%")
        XCTAssertNil(displays[0].scopeBadge)
        XCTAssertEqual(displays[0].accessibilityKey, "window.position[前排]")
    }

    func testAcFamilyDisplayCarriesModeSiblingForThermalTint() {
        let cards = VehicleCardDisplay.familyDisplays(
            from: [
                DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: "24", revision: 1),
                DemoVehicleStateCell(key: "ac.mode", actualValue: "制冷", revision: 1)
            ],
            catalog: StateCellPresentationCatalog.load()
        )

        let ac = cards.first { $0.familyCardID == .ac }
        XCTAssertEqual(ac?.siblingCells.contains { $0.key == "ac.mode" }, true)
    }

    func testActiveCellOverridesPrimaryOnlyWhenFamilyIsNonNormal() {
        let cards = VehicleCardDisplay.familyDisplays(
            from: [
                DemoVehicleStateCell(key: "seat.heat_level[主驾]", actualValue: "0", revision: 1, visualState: .normal),
                DemoVehicleStateCell(key: "seat.backrest_angle[主驾]", actualValue: "30", revision: 2, visualState: .changing)
            ],
            activeCells: [.seat: "seat.backrest_angle[主驾]"],
            catalog: StateCellPresentationCatalog.load()
        )

        let seat = cards.first { $0.familyCardID == .seat }
        XCTAssertEqual(seat?.valueText, "30%")
        XCTAssertEqual(seat?.visualState, .changing)
    }

    func testActiveCellDoesNotOverrideWhenFamilyIsNormal() {
        let cards = VehicleCardDisplay.familyDisplays(
            from: [
                DemoVehicleStateCell(key: "seat.heat_level[主驾]", actualValue: "0", revision: 1, visualState: .normal),
                DemoVehicleStateCell(key: "seat.backrest_angle[主驾]", actualValue: "30", revision: 1, visualState: .normal)
            ],
            activeCells: [.seat: "seat.backrest_angle[主驾]"],
            catalog: StateCellPresentationCatalog.load()
        )

        let seat = cards.first { $0.familyCardID == .seat }
        XCTAssertEqual(seat?.valueText, "0挡")
    }
}
