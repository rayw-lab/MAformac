import Foundation

/// 族 → 摘要层主状态 cell base（AD-10）。
///
/// 二级摘要模型每族显 1 主 cell（信息量优先）。独立 SSOT，**不复用 readback[0]**——
/// readback 顺序与摘要主 cell 不一致（如 ac readback[0]=power，但主 cell=temp_setpoint）。
///
/// 穷尽 switch（无 default）：新增 `FamilyCardID` case 时编译器强制此处补主 cell。
enum FamilyPrimaryCellMapper {
    static func primaryCellBase(for family: FamilyCardID) -> String {
        switch family {
        case .ac: return "ac.temp_setpoint"
        case .seat: return "seat.heat_level"
        case .window: return "window.position"
        case .screen: return "screen.brightness"
        case .ambient: return "ambient.color"
        case .door: return "door.central_lock"
        case .volume: return "volume.level"
        case .wiper: return "wiper.power"
        case .sunroofShade: return "sunroof.position"
        case .fragrance: return "fragrance.power"
        }
    }
}
