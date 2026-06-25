import Foundation

enum FamilyIconMapper {
    /// Curated stable SF Symbols allowlist for the 10 A-2 control families.
    ///
    /// ac=fan.fill, seat=carseat.left.fill, window=rectangle.split.3x1.fill,
    /// screen=display, ambient=lightbulb.led.fill, door=door.left.hand.open,
    /// volume=speaker.wave.2.fill, wiper=windshield.front.and.wiper,
    /// sunroofShade=sun.max.fill, fragrance=leaf.fill.
    static func sfSymbol(for family: FamilyCardID) -> String {
        switch family {
        case .ac: return "fan.fill"
        case .seat: return "carseat.left.fill"
        case .window: return "rectangle.split.3x1.fill"
        case .screen: return "display"
        case .ambient: return "lightbulb.led.fill"
        case .door: return "door.left.hand.open"
        case .volume: return "speaker.wave.2.fill"
        case .wiper: return "windshield.front.and.wiper"
        case .sunroofShade: return "sun.max.fill"
        case .fragrance: return "leaf.fill"
        }
    }
}
