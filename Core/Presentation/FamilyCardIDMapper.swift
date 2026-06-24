import Foundation

/// 10 控制族 family_card_id（消费侧派生，AD-9）。
///
/// spec ui-presentation R2 锁「10 族 family_card 全景常驻」，producer（`state-cells.yaml`）无 `family_card_id` 字段
/// → 消费侧从 `cell.key` 前缀派生（同 `ui_value_type` 派生纪律，不写回 yaml / 不给 Core struct 加字段）。
///
/// `allCases` 顺序 = 排序兜底（`family-device-allowlist.json row_count` 缺失时），常驻骨架稳定性依赖此固定序。
enum FamilyCardID: String, CaseIterable, Equatable {
    case ac, seat, window, screen, ambient, door, volume, wiper, sunroofShade, fragrance
}

enum FamilyCardIDMapper {
    /// device base（`cell.key` 去 scope，如 `ac.temp_setpoint`）→ 10 控制族之一。
    ///
    /// 返回 `nil` = 不属任何控制族（`vehicle.*` 车辆仪表 / 未知 base）→ 摘要层过滤。
    /// 🔴 P0-1：禁 `default → .ac` 静默错归（`vehicle.speed` 错归空调=demo 翻车），未知一律 nil。
    static func familyCardID(forBase base: String) -> FamilyCardID? {
        let prefix = base.split(separator: ".").first.map(String.init) ?? base
        switch prefix {
        case "ac": return .ac
        case "seat": return .seat
        case "window": return .window
        case "screen": return .screen
        case "ambient": return .ambient
        case "door": return .door
        case "volume": return .volume
        case "wiper": return .wiper
        case "sunroof", "sunshade": return .sunroofShade
        case "fragrance": return .fragrance
        default: return nil  // vehicle.* 车辆仪表 + 未知 / 空 → 不归族
        }
    }
}
