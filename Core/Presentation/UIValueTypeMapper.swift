import Foundation

enum UIValueType: Equatable {
    case dial
    case toggle
    case stepper
    case percent
    case badge
}

enum ScopeBadgeStyle: Equatable {
    case dim
    case emphasized
}

struct ScopeBadge: Equatable {
    var text: String
    var style: ScopeBadgeStyle
}

struct VehicleCardDisplay: Identifiable, Equatable {
    var id: String
    var title: String
    var valueText: String
    var scopeBadge: ScopeBadge?
    var visualState: DemoVisualState
    var revision: Int
    var accessibilityKey: String
    var reason: String?

    static func displays(
        from cells: [DemoVehicleStateCell],
        catalog: StateCellPresentationCatalog = .shared,
        reasons: (String) -> String? = { _ in nil }
    ) -> [VehicleCardDisplay] {
        let grouped = Dictionary(grouping: cells, by: { ScopedStateKey($0.key).base })
        let aggregateDisplays = grouped.compactMap { base, group in
            aggregateDisplay(base: base, cells: group, catalog: catalog, reasons: reasons)
        }
        let aggregatedKeys = Set(aggregateDisplays.flatMap { $0.id.components(separatedBy: "|").dropFirst() })

        let individualDisplays = cells
            .filter { !aggregatedKeys.contains($0.key) }
            .map { individualDisplay(for: $0, catalog: catalog, reasons: reasons($0.key)) }

        return (aggregateDisplays + individualDisplays).sorted { lhs, rhs in
            if lhs.revision != rhs.revision {
                return lhs.revision > rhs.revision
            }
            return lhs.id < rhs.id
        }
    }

    private static func individualDisplay(
        for cell: DemoVehicleStateCell,
        catalog: StateCellPresentationCatalog,
        reasons: String?
    ) -> VehicleCardDisplay {
        let key = ScopedStateKey(cell.key)
        let baseTitle = catalog.displayTitle(for: key.base)
        let defaultScope = catalog.defaultScope(for: key.base)
        let title: String
        let badge: ScopeBadge?

        if let scope = key.scope, scope == defaultScope {
            title = baseTitle
            badge = ScopeBadge(text: scope, style: .dim)
        } else if let scope = key.scope {
            title = "\(scope)\(baseTitle)"
            badge = nil
        } else {
            title = baseTitle
            badge = nil
        }

        return VehicleCardDisplay(
            id: cell.key,
            title: title,
            valueText: valueText(for: cell.actualValue, base: key.base, type: UIValueTypeMapper.uiValueType(for: cell)),
            scopeBadge: badge,
            visualState: cell.visualState,
            revision: cell.revision,
            accessibilityKey: cell.key,
            reason: reasons
        )
    }

    private static func aggregateDisplay(
        base: String,
        cells: [DemoVehicleStateCell],
        catalog: StateCellPresentationCatalog,
        reasons: (String) -> String?
    ) -> VehicleCardDisplay? {
        let scopedActive = cells
            .filter { cell in
                ScopedStateKey(cell.key).scope != nil &&
                    (cell.visualState != .normal || cell.revision > 0)
            }
        guard scopedActive.count > 1 else { return nil }

        let valueSet = Set(scopedActive.map(\.actualValue))
        guard valueSet.count == 1, let value = valueSet.first else { return nil }

        let scopes = scopedActive.compactMap { ScopedStateKey($0.key).scope }
        guard let range = catalog.aggregateScopeLabel(base: base, scopes: scopes) else { return nil }

        let visualState = dominantVisualState(scopedActive.map(\.visualState))
        let title: String
        let badge: ScopeBadge?
        if range == "全车" {
            title = catalog.displayTitle(for: base)
            badge = ScopeBadge(text: range, style: .emphasized)
        } else {
            title = "\(range)\(catalog.displayTitle(for: base))"
            badge = nil
        }

        let first = scopedActive.sorted { $0.key < $1.key }.first!
        return VehicleCardDisplay(
            id: "aggregate|\(scopedActive.map(\.key).sorted().joined(separator: "|"))",
            title: title,
            valueText: valueText(for: value, base: base, type: UIValueTypeMapper.uiValueType(for: first)),
            scopeBadge: badge,
            visualState: visualState,
            revision: scopedActive.map(\.revision).max() ?? 0,
            accessibilityKey: "\(base)[\(range)]",
            reason: scopedActive.compactMap { reasons($0.key) }.first
        )
    }

    private static func valueText(for rawValue: String, base: String, type: UIValueType) -> String {
        switch type {
        case .dial:
            return rawValue.hasSuffix("℃") ? rawValue : "\(rawValue)℃"
        case .percent:
            return rawValue.hasSuffix("%") ? rawValue : "\(rawValue)%"
        case .stepper:
            return rawValue.hasSuffix("挡") ? rawValue : "\(rawValue)挡"
        case .toggle:
            switch rawValue {
            case "on", "open", "unlocked", "unmuted": return "开"
            case "off", "closed", "locked", "muted": return "关"
            default: return rawValue
            }
        case .badge:
            if base == "vehicle.speed" {
                return rawValue.hasSuffix("km/h") ? rawValue : "\(rawValue)km/h"
            }
            return rawValue
        }
    }

    private static func dominantVisualState(_ states: [DemoVisualState]) -> DemoVisualState {
        for state in [DemoVisualState.unsafe, .blocked_with_alternative, .blocked_hard, .unknown, .changing, .satisfied] {
            if states.contains(state) {
                return state
            }
        }
        return .normal
    }
}

enum UIValueTypeMapper {
    static func uiValueType(for cell: DemoVehicleStateCell) -> UIValueType {
        uiValueType(forBase: ScopedStateKey(cell.key).base)
    }

    static func uiValueType(forBase base: String) -> UIValueType {
        switch base {
        case "ac.temp_setpoint":
            return .dial
        case "ac.power", "wiper.power", "door.central_lock", "door.child_lock", "volume.mute", "fragrance.power":
            return .toggle
        case "ac.fan_speed", "seat.heat_level", "seat.vent_level", "seat.massage_force", "wiper.speed", "fragrance.intensity":
            return .stepper
        case "window.position", "screen.brightness", "ambient.brightness", "seat.backrest_angle", "door.tailgate_height", "volume.level", "sunroof.position", "sunshade.position":
            return .percent
        default:
            return .badge
        }
    }
}

struct ScopedStateKey: Equatable {
    var base: String
    var scope: String?

    init(_ key: String) {
        guard let open = key.firstIndex(of: "["),
              let close = key.firstIndex(of: "]"),
              open < close else {
            self.base = key
            self.scope = nil
            return
        }
        self.base = String(key[..<open])
        self.scope = String(key[key.index(after: open)..<close])
    }
}

struct StateCellPresentationCatalog {
    static let shared = StateCellPresentationCatalog.load()

    private var titlesByBase: [String: String]
    private var defaultScopeByBase: [String: String]
    private var scopesByBase: [String: [String]]

    init(titlesByBase: [String: String], defaultScopeByBase: [String: String], scopesByBase: [String: [String]]) {
        self.titlesByBase = titlesByBase
        self.defaultScopeByBase = defaultScopeByBase
        self.scopesByBase = scopesByBase
    }

    func displayTitle(for base: String) -> String {
        titlesByBase[base] ?? fallbackTitle(for: base)
    }

    func defaultScope(for base: String) -> String? {
        defaultScopeByBase[base]
    }

    func aggregateScopeLabel(base: String, scopes: [String]) -> String? {
        let unique = Set(scopes)
        guard unique.count > 1 else { return nil }

        let executable = Set((scopesByBase[base] ?? []).filter { !Self.collectionScopes.contains($0) })
        if !executable.isEmpty, unique == executable {
            return "全车"
        }
        if unique == Set(["主驾", "副驾"]) {
            return "前排"
        }
        if unique == Set(["左后", "右后"]) {
            return "后排"
        }
        if unique == Set(["前排", "后排"]) {
            return "全车"
        }
        return nil
    }

    static func load() -> StateCellPresentationCatalog {
        guard let yaml = loadStateCellsYAML() else {
            return fallback
        }
        let parsed = parse(yaml: yaml)
        guard !parsed.titlesByBase.isEmpty else {
            return fallback
        }
        return parsed
    }

    private static let fallback = StateCellPresentationCatalog(
        titlesByBase: [:],
        defaultScopeByBase: [:],
        scopesByBase: [:]
    )

    private static let collectionScopes: Set<String> = ["全车", "全车屏", "前后"]

    private func fallbackTitle(for base: String) -> String {
        switch base {
        case "ac.power": return "空调"
        case "ac.temp_setpoint": return "空调温度"
        case "ac.fan_speed": return "空调风量"
        case "window.position": return "车窗"
        case "screen.brightness": return "屏幕亮度"
        case "ambient.brightness": return "氛围灯亮度"
        case "ambient.color": return "氛围灯颜色"
        case "seat.heat_level": return "座椅加热"
        case "seat.vent_level": return "座椅通风"
        case "seat.backrest_angle": return "座椅靠背"
        case "wiper.power": return "雨刮"
        case "wiper.speed": return "雨刮速度"
        case "sunroof.position": return "天窗"
        case "sunshade.position": return "遮阳帘"
        case "volume.level": return "音量"
        case "vehicle.speed": return "车速"
        case "vehicle.gear": return "挡位"
        default: return base
        }
    }

    private static func loadStateCellsYAML() -> String? {
        let bundle = Bundle.main
        let bundleURLs = [
            bundle.url(forResource: "state-cells", withExtension: "yaml"),
            bundle.url(forResource: "state-cells", withExtension: "yaml", subdirectory: "contracts")
        ].compactMap { $0 }
        for url in bundleURLs {
            if let content = try? String(contentsOf: url, encoding: .utf8) {
                return content
            }
        }

        let sourceURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("contracts/state-cells.yaml")
        return try? String(contentsOf: sourceURL, encoding: .utf8)
    }

    private static func parse(yaml: String) -> StateCellPresentationCatalog {
        var titles: [String: String] = [:]
        var defaultScopes: [String: String] = [:]
        var scopes: [String: [String]] = [:]

        var currentID: String?
        var currentItemIndent: Int?
        var currentTitle: String?
        var currentDefaultScope: String?
        var currentScopes: [String] = []

        func finishCurrent() {
            guard let currentID else { return }
            if let currentTitle {
                titles[currentID] = currentTitle.replacingOccurrences(of: "开度", with: "")
            }
            if let currentDefaultScope {
                defaultScopes[currentID] = currentDefaultScope
            }
            if !currentScopes.isEmpty {
                scopes[currentID] = currentScopes
            }
            selfReset()
        }

        func selfReset() {
            currentID = nil
            currentItemIndent = nil
            currentTitle = nil
            currentDefaultScope = nil
            currentScopes = []
        }

        for rawLine in yaml.split(whereSeparator: \.isNewline).map(String.init) {
            let trimmed = stripComment(rawLine).trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }

            if trimmed.hasPrefix("- id: ") {
                finishCurrent()
                currentID = cleanValue(String(trimmed.dropFirst("- id: ".count)))
                currentItemIndent = rawLine.prefix(while: { $0 == " " }).count
                continue
            }
            guard currentID != nil else { continue }
            let indent = rawLine.prefix(while: { $0 == " " }).count
            if let currentItemIndent, indent <= currentItemIndent {
                finishCurrent()
                continue
            }

            if trimmed.hasPrefix("display_zh: ") {
                currentTitle = cleanValue(String(trimmed.dropFirst("display_zh: ".count)))
            } else if trimmed.hasPrefix("default_scope: ") {
                currentDefaultScope = cleanValue(String(trimmed.dropFirst("default_scope: ".count)))
            } else if trimmed.hasPrefix("scope: ") {
                currentScopes = parseArray(after: "scope:", in: trimmed)
            }
        }
        finishCurrent()

        return StateCellPresentationCatalog(titlesByBase: titles, defaultScopeByBase: defaultScopes, scopesByBase: scopes)
    }
}

private func stripComment(_ line: String) -> String {
    var quote: Character?
    var result = ""
    for character in line {
        if character == "\"" || character == "'" {
            if quote == character {
                quote = nil
            } else if quote == nil {
                quote = character
            }
        }
        if character == "#", quote == nil {
            break
        }
        result.append(character)
    }
    return result
}

private func cleanValue(_ raw: String) -> String {
    raw
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
}

private func parseArray(after prefix: String, in line: String) -> [String] {
    guard let range = line.range(of: prefix) else {
        return []
    }
    let rest = line[range.upperBound...].trimmingCharacters(in: .whitespaces)
    guard rest.hasPrefix("["), let end = rest.firstIndex(of: "]") else {
        return []
    }
    return rest[rest.index(after: rest.startIndex)..<end]
        .split(separator: ",")
        .map { cleanValue(String($0)) }
        .filter { !$0.isEmpty }
}
