import Foundation

/// 10 控制族 family_card_id（消费侧派生，AD-9）。
///
/// spec ui-presentation R2 锁「10 族 family_card 全景常驻」，producer（`state-cells.yaml`）无 `family_card_id` 字段
/// → 消费侧从 `cell.key` 前缀派生（同 `ui_value_type` 派生纪律，不写回 yaml / 不给 Core struct 加字段）。
///
/// `allCases` 顺序 = 排序兜底（`family-device-allowlist.json row_count` 缺失时），常驻骨架稳定性依赖此固定序。
enum FamilyCardID: String, CaseIterable, Equatable, Hashable {
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

// MARK: - 族元数据（family card 标题 + 排序 + allowlist 桥接）

extension FamilyCardID {
    /// 族中文显示名（family card 标题）。源 = `generated/family-device-allowlist.json` `zh`，
    /// 消费侧适配：allowlist `light`/灯光氛围 → 设备前缀 `ambient` → 「氛围灯」；`sunroof`/天窗遮阳帘 → 「天窗遮阳」。
    var displayName: String {
        switch self {
        case .ac: return "空调"
        case .seat: return "座椅"
        case .window: return "车窗"
        case .screen: return "屏幕"
        case .ambient: return "氛围灯"
        case .door: return "车门"
        case .volume: return "音量"
        case .wiper: return "雨刮"
        case .sunroofShade: return "天窗遮阳"
        case .fragrance: return "香氛"
        }
    }

    /// A2 allowlist 族 key（消费侧 `FamilyCardID` → allowlist key 桥；2 处命名差异：
    /// `ambient`(设备前缀) ↔ `light`(allowlist 族) / `sunroofShade`(合并族) ↔ `sunroof`(allowlist 族)）。
    var allowlistKey: String {
        switch self {
        case .ambient: return "light"
        case .sunroofShade: return "sunroof"
        default: return rawValue
        }
    }

    /// family card 常驻骨架显示序 = allowlist `row_count` 降序（C8 高频代理，verified 2026-06-25）。
    /// 静态序（不运行时读 JSON 防 hot-path IO），由 `FamilyDisplaysTests.testDisplayOrderMatchesAllowlistRowCountSource`
    /// 对 allowlist 源做一致性 enforce（A2 改 row_count → 测试红 → 更新此序）。
    static let displayOrder: [FamilyCardID] = [
        .seat,         // row_count 696
        .ambient,      // light 468
        .ac,           // 212
        .screen,       // 205
        .volume,       // 153
        .door,         // 129
        .sunroofShade, // sunroof 102
        .window,       // 82
        .wiper,        // 80
        .fragrance     // 32
    ]
}
