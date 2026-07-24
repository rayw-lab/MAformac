import SwiftUI

struct EnergyLineFramePreferences {
    var orb: Anchor<CGRect>?
    var cards: [String: Anchor<CGRect>] = [:]
}

struct EnergyLineFramePreferenceKey: PreferenceKey {
    static let defaultValue = EnergyLineFramePreferences()

    static func reduce(value: inout EnergyLineFramePreferences, nextValue: () -> EnergyLineFramePreferences) {
        let next = nextValue()
        if let orb = next.orb {
            value.orb = orb
        }
        value.cards.merge(next.cards) { _, new in new }
    }
}

extension View {
    /// T7d GeometryReader/anchor seam: capture the visible orb frame in root coordinates.
    func energyLineOrbAnchor() -> some View {
        anchorPreference(key: EnergyLineFramePreferenceKey.self, value: .bounds) { anchor in
            EnergyLineFramePreferences(orb: anchor)
        }
    }

    /// T7d GeometryReader/anchor seam: capture real card frames keyed by `FamilyCardID.rawValue`.
    func energyLineCardAnchor(family: FamilyCardID?) -> some View {
        anchorPreference(key: EnergyLineFramePreferenceKey.self, value: .bounds) { anchor in
            guard let family else { return EnergyLineFramePreferences() }
            return EnergyLineFramePreferences(cards: [family.rawValue: anchor])
        }
    }
}
