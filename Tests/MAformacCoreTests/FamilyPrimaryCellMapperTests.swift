import XCTest
@testable import MAformacCore

final class FamilyPrimaryCellMapperTests: XCTestCase {
    // AD-10 主 cell 表（信息量优先，非 readback[0]）—— 全 10 族穷尽断言
    func testPrimaryCellPerFamily() {
        XCTAssertEqual(FamilyPrimaryCellMapper.primaryCellBase(for: .ac), "ac.temp_setpoint")
        XCTAssertEqual(FamilyPrimaryCellMapper.primaryCellBase(for: .seat), "seat.heat_level")
        XCTAssertEqual(FamilyPrimaryCellMapper.primaryCellBase(for: .window), "window.position")
        XCTAssertEqual(FamilyPrimaryCellMapper.primaryCellBase(for: .screen), "screen.brightness")
        XCTAssertEqual(FamilyPrimaryCellMapper.primaryCellBase(for: .ambient), "ambient.color")
        XCTAssertEqual(FamilyPrimaryCellMapper.primaryCellBase(for: .door), "door.central_lock")
        XCTAssertEqual(FamilyPrimaryCellMapper.primaryCellBase(for: .volume), "volume.level")
        XCTAssertEqual(FamilyPrimaryCellMapper.primaryCellBase(for: .wiper), "wiper.power")
        XCTAssertEqual(FamilyPrimaryCellMapper.primaryCellBase(for: .sunroofShade), "sunroof.position")
        XCTAssertEqual(FamilyPrimaryCellMapper.primaryCellBase(for: .fragrance), "fragrance.power")
    }

    // 每族都有非空主 cell（穷尽性保护，新增族编译器逼补）
    func testAllFamiliesHaveNonEmptyPrimary() {
        for f in FamilyCardID.allCases {
            XCTAssertFalse(FamilyPrimaryCellMapper.primaryCellBase(for: f).isEmpty, "family \(f) 缺主 cell")
        }
    }

    // 主 cell base 必属其所声明的 family（AD-9/AD-10 闭环一致性，防主 cell 写错族）
    func testPrimaryCellBaseMapsBackToSameFamily() {
        for f in FamilyCardID.allCases {
            let base = FamilyPrimaryCellMapper.primaryCellBase(for: f)
            XCTAssertEqual(FamilyCardIDMapper.familyCardID(forBase: base), f, "主 cell \(base) 不归族 \(f)")
        }
    }
}
