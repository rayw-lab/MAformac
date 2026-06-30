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

    // 🔴 gptpro 第6点：第二份 SSOT 契约存在性——每族主 cell base 必存在于 state-cells.yaml。
    // 防 A2 改/删 contract base 后，摘要层主 cell 引用幽灵 base 静默漂移（族卡退化无主 cell 不被发现）。
    func testPrimaryCellBaseExistsInContract() {
        let bases = StateCellPresentationCatalog.load().knownBases
        XCTAssertGreaterThanOrEqual(bases.count, 30, "catalog 未加载，契约存在性测试无法执行")
        for f in FamilyCardID.allCases {
            let base = FamilyPrimaryCellMapper.primaryCellBase(for: f)
            XCTAssertTrue(bases.contains(base),
                          "族 \(f) 主 cell 「\(base)」不在 state-cells.yaml（A2 改契约后漂移？）")
        }
    }

    // 🔴 gptpro 第6点：每族主 cell base 必显式映射 UIValueType（非 default unmapped fallback）。
    func testPrimaryCellBaseIsExplicitlyTyped() {
        for f in FamilyCardID.allCases {
            let base = FamilyPrimaryCellMapper.primaryCellBase(for: f)
            XCTAssertTrue(UIValueTypeMapper.isMapped(base),
                          "族 \(f) 主 cell 「\(base)」未显式登记 UIValueType（会落 assertionFailure）")
        }
    }
}
