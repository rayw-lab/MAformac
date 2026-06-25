import XCTest
@testable import MAformacCore

final class SemanticColorMapperTests: XCTestCase {
    func testACThermalTintFromModeSibling() {
        XCTAssertEqual(
            SemanticColorMapper.acThermalTint(
                siblingCells: [DemoVehicleStateCell(key: "ac.mode", actualValue: "制冷", revision: 1)]
            ),
            .cooling
        )
        XCTAssertEqual(
            SemanticColorMapper.acThermalTint(
                siblingCells: [DemoVehicleStateCell(key: "ac.mode", actualValue: "制热", revision: 1)]
            ),
            .heating
        )
    }

    func testACThermalTintNeutralWhenModeMissingOrAuto() {
        XCTAssertEqual(
            SemanticColorMapper.acThermalTint(
                siblingCells: [DemoVehicleStateCell(key: "ac.temp_setpoint[主驾]", actualValue: "24", revision: 1)]
            ),
            .neutral
        )
        XCTAssertEqual(
            SemanticColorMapper.acThermalTint(
                siblingCells: [DemoVehicleStateCell(key: "ac.mode", actualValue: "auto", revision: 1)]
            ),
            .neutral
        )
    }
}
