import XCTest
@testable import MAformacCore

final class FamilyCardIDMapperTests: XCTestCase {
    // 全 10 控制族 base 前缀 → 对应 family（穷尽，非 happy subset）
    func testDeviceBaseMapsToFamily() {
        XCTAssertEqual(FamilyCardIDMapper.familyCardID(forBase: "ac.temp_setpoint"), .ac)
        XCTAssertEqual(FamilyCardIDMapper.familyCardID(forBase: "ac.power"), .ac)
        XCTAssertEqual(FamilyCardIDMapper.familyCardID(forBase: "seat.heat_level"), .seat)
        XCTAssertEqual(FamilyCardIDMapper.familyCardID(forBase: "window.position"), .window)
        XCTAssertEqual(FamilyCardIDMapper.familyCardID(forBase: "screen.brightness"), .screen)
        XCTAssertEqual(FamilyCardIDMapper.familyCardID(forBase: "ambient.color"), .ambient)
        XCTAssertEqual(FamilyCardIDMapper.familyCardID(forBase: "ambient.brightness"), .ambient)
        XCTAssertEqual(FamilyCardIDMapper.familyCardID(forBase: "door.central_lock"), .door)
        XCTAssertEqual(FamilyCardIDMapper.familyCardID(forBase: "volume.level"), .volume)
        XCTAssertEqual(FamilyCardIDMapper.familyCardID(forBase: "wiper.power"), .wiper)
        XCTAssertEqual(FamilyCardIDMapper.familyCardID(forBase: "sunroof.position"), .sunroofShade)
        XCTAssertEqual(FamilyCardIDMapper.familyCardID(forBase: "sunshade.position"), .sunroofShade)
        XCTAssertEqual(FamilyCardIDMapper.familyCardID(forBase: "fragrance.power"), .fragrance)
    }

    // 🔴 P0-1：vehicle.* 车辆仪表不归任何控制族（返 nil，⭐ 摘要层过滤，禁 default→.ac 静默错归）
    func testVehicleNotMappedToControlFamily() {
        XCTAssertNil(FamilyCardIDMapper.familyCardID(forBase: "vehicle.speed"))
        XCTAssertNil(FamilyCardIDMapper.familyCardID(forBase: "vehicle.gear"))
        XCTAssertNil(FamilyCardIDMapper.familyCardID(forBase: "unknown.foo"))
        XCTAssertNil(FamilyCardIDMapper.familyCardID(forBase: ""))
    }

    // 10 控制族（不含 vehicle）全可达 + allCases 稳定枚举顺序（常驻骨架排序依赖）
    func testAllTenFamiliesReachable() {
        XCTAssertEqual(FamilyCardID.allCases.count, 10)
        // enum 序作排序兜底（family-device-allowlist row_count 缺失时）—— 锁定顺序防漂移
        XCTAssertEqual(FamilyCardID.allCases, [.ac, .seat, .window, .screen, .ambient, .door, .volume, .wiper, .sunroofShade, .fragrance])
    }
}
