import Foundation

enum FamilyIconMapper {
    /// Curated stable SF Symbols allowlist for the 10 A-2 control families.
    ///
    /// ac=fan, seat=carseat.left, window=rectangle.split.3x1,
    /// screen=display, ambient=lightbulb, door=door.left.hand.open,
    /// volume=speaker.wave.2, wiper=windshield.front.and.wiper,
    /// sunroofShade=sun.max, fragrance=leaf.
    static func sfSymbol(for family: FamilyCardID) -> String {
        switch family {
        case .ac: return "fan"
        case .seat: return "carseat.left"
        case .window: return "rectangle.split.3x1"
        case .screen: return "display"
        case .ambient: return "lightbulb"
        case .door: return "door.left.hand.open"
        case .volume: return "speaker.wave.2"
        case .wiper: return "windshield.front.and.wiper"
        case .sunroofShade: return "sun.max"
        case .fragrance: return "leaf"
        }
    }
}
