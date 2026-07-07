import Foundation

enum UIValueType: String, CaseIterable, Codable, Equatable, Sendable {
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

/// 卡片值二级 badge 渲染形态（spec.md:83 禁 AnyView → enum 穷尽 switch）。
/// `colorSwatch` = ambient.color 炸场色块；`mode` = 枚举模式（如 massage_mode）；`plain` = 普通值。
enum BadgeRenderStyle: Equatable {
    case plain
    case colorSwatch(String)  // 关联色名（白/红色...），消费侧映射 Color 染卡
    case mode(String)         // 关联模式名
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
    /// 10 族归属（`familyDisplays` 设；device 级 `displays()` 输出留 nil）。
    var familyCardID: FamilyCardID? = nil
    /// 值二级 badge 形态（ambient 色块 / mode / plain）。
    var badgeStyle: BadgeRenderStyle = .plain
    /// Bridge-active cell key that currently drives the family card main value.
    var activeCell: String? = nil
    /// Same-family cells carried for semantic styling such as ac.mode cooling/heating.
    var siblingCells: [DemoVehicleStateCell] = []

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

    /// 值文本格式化（4a 摘要 + 4b 展开行共用；internal 供 `ExpandedFamilyDisplay` 复用，不重复格式化逻辑 §28）。
    static func valueText(for rawValue: String, base: String, type: UIValueType) -> String {
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
            if base == "ac.mode", rawValue == "auto" {
                return "自动"
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

    // MARK: - 10 族全景常驻摘要层（AD-9/10/11）

    /// 10 族 family_card 全景常驻摘要：遍历 `FamilyCardID.displayOrder`(10) 固定序，每族 1 卡。
    /// 有 cell → 主 cell 摘要 + 族级 dominant 态 + scope 角标；无 cell → `normal` 占位（冷启动不空屏）。
    /// `vehicle.*`/未知 base 经 `FamilyCardIDMapper` 返 nil 被过滤（P0-1，不创建第 11 族）。
    /// 与 `displays()`（device 级）正交：摘要层是消费侧二级模型，不改 `displays()` 行为。
    static func familyDisplays(
        from cells: [DemoVehicleStateCell],
        activeCells: [FamilyCardID: String] = [:],
        catalog: StateCellPresentationCatalog = .shared,
        reasons: (String) -> String? = { _ in nil }
    ) -> [VehicleCardDisplay] {
        var cellsByFamily: [FamilyCardID: [DemoVehicleStateCell]] = [:]
        for cell in cells {
            guard let family = FamilyCardIDMapper.familyCardID(forBase: ScopedStateKey(cell.key).base) else { continue }
            cellsByFamily[family, default: []].append(cell)
        }
        return FamilyCardID.displayOrder.map { family in
            let familyCells = cellsByFamily[family] ?? []
            guard !familyCells.isEmpty else {
                return placeholderDisplay(for: family)
            }
            return summaryDisplay(
                for: family,
                familyCells: familyCells,
                activeCellKey: activeCells[family],
                catalog: catalog,
                reasons: reasons
            )
        }
    }

    /// 无 cell 族 → `normal` 占位卡（族名 +「待命」就绪态，10 族骨架常驻；scopeBadge nil 不走聚合）。
    /// 🔴 体验审计 P0-1：「未激活」客户读成「demo 没做完」撞惊艳门 → 改「待命」（10 系统就绪非 5 没做）。
    private static func placeholderDisplay(for family: FamilyCardID) -> VehicleCardDisplay {
        VehicleCardDisplay(
            id: "family|\(family.rawValue)",
            title: family.displayName,
            valueText: "待命",
            scopeBadge: nil,
            visualState: .normal,
            revision: 0,
            accessibilityKey: "family.\(family.rawValue)",
            reason: nil,
            familyCardID: family,
            badgeStyle: .plain,
            activeCell: nil,
            siblingCells: []
        )
    }

    /// 有 cell 族 → 主 cell 摘要 + 族级 dominant 态。
    /// title/value/scopeBadge 复用主 cell 现有 `displays()` scope 聚合（**不重写** :54-129）；
    /// title = scope 前缀（从主 display 提取）+ 族名；visualState = 族内 dominant（occupancy，语音点亮哪族哪族变）。
    private static func summaryDisplay(
        for family: FamilyCardID,
        familyCells: [DemoVehicleStateCell],
        activeCellKey: String?,
        catalog: StateCellPresentationCatalog,
        reasons: (String) -> String?
    ) -> VehicleCardDisplay {
        let primaryBase = FamilyPrimaryCellMapper.primaryCellBase(for: family)
        let primaryCells = familyCells.filter { ScopedStateKey($0.key).base == primaryBase }
        let isDegraded = primaryCells.isEmpty   // 主 cell 缺失（族激活但主 cell 未现，force-state 边界）
        // 族态 occupancy：族卡态 = 族内所有 cell dominant（语音点亮哪族哪族变）
        let familyState = dominantVisualState(familyCells.map(\.visualState))
        let activeSource = activeCellKey.flatMap { key in
            familyCells.first { cell in
                cell.key == key || ScopedStateKey(cell.key).base == key
            }
        }
        let shouldUseActive = familyState != .normal && activeSource != nil
        let source: [DemoVehicleStateCell]
        if shouldUseActive, let activeSource {
            source = [activeSource]
        } else {
            source = isDegraded ? familyCells : primaryCells
        }
        // 复用现有 scope 聚合（individualDisplay/aggregateDisplay）出主 cell display（含 dim/emphasized/范围词角标）
        let primary = displays(from: source, catalog: catalog, reasons: reasons).first
        // 🔴 P1-1 修（审计 catch）：actualBase 从 primary.accessibilityKey 反解，保证 title/baseTitle/value/badge **同源一个 device**。
        // 退化多 base 时，旧 representativeBase(max-rev) 与 primary(displays().first 按 id 序) 会选不同 base → title 取 A 设备语义、value 取 B 设备值（串味）。
        let actualBase = primary.map { ScopedStateKey($0.accessibilityKey).base } ?? primaryBase
        let value = primary?.valueText ?? "—"
        // 族名 + scope 前缀：**非退化才提取**（退化=主 cell 缺失边界，不强求 scope 前缀，避免非主 cell 的 scope 串成 "尾门车门"）
        let title: String
        if isDegraded {
            title = family.displayName
        } else {
            let baseTitle = catalog.displayTitle(for: actualBase)
            let primaryTitle = primary?.title ?? family.displayName
            let scopePrefix = primaryTitle.hasSuffix(baseTitle) ? String(primaryTitle.dropLast(baseTitle.count)) : ""
            title = scopePrefix + family.displayName
        }
        return VehicleCardDisplay(
            id: "family|\(family.rawValue)",
            title: title,
            valueText: value,
            scopeBadge: primary?.scopeBadge,
            visualState: familyState,
            revision: familyCells.map(\.revision).max() ?? 0,
            accessibilityKey: "family.\(family.rawValue)",
            reason: primary?.reason ?? familyCells.compactMap { reasons($0.key) }.first,  // P2-1：reason 同源主 cell
            familyCardID: family,
            badgeStyle: badgeRenderStyle(forBase: actualBase, value: value),
            activeCell: shouldUseActive ? activeSource?.key : nil,
            siblingCells: familyCells
        )
    }

    /// 值二级 badge 形态（穷尽，禁 AnyView）：色彩/可选业务模式→专用样式，过程态/只读仪表→plain。
    /// internal 供 `ExpandedFamilyDisplay` 复用（§28 不重复）。
    static func badgeRenderStyle(forBase base: String, value: String) -> BadgeRenderStyle {
        switch base {
        case "ambient.color": return .colorSwatch(value)
        case "ac.mode", "seat.massage_mode", "volume.mode", "wiper.mode", "fragrance.mode":
            return .mode(displayModeValue(for: value, base: base))
        default: return .plain
        }
    }

    static func displayModeValue(for rawValue: String, base: String) -> String {
        if base == "ac.mode", rawValue == "auto" {
            return "自动"
        }
        return rawValue
    }
}

enum BadgeOptionMapper {
    static let interactiveModeBases: Set<String> = [
        "ac.mode",
        "seat.massage_mode",
        "volume.mode",
        "wiper.mode",
        "fragrance.mode",
    ]

    static func options(forBase base: String, catalog: StateCellPresentationCatalog = .shared) -> [String] {
        if base == "ambient.color" {
            return AmbientBurstColorMapper.canonicalColorOptions
        }
        guard interactiveModeBases.contains(base) else {
            return []
        }
        return catalog.enumValues(for: base) ?? []
    }

    static func hasInteractiveOptions(forBase base: String, catalog: StateCellPresentationCatalog = .shared) -> Bool {
        !options(forBase: base, catalog: catalog).isEmpty
    }
}

enum UIValueTypeMapper {
    /// base → UIValueType **显式映射单一 SSOT**（state-cells 全 base 闭合，禁 `default` 吞错）。
    /// 🔴 `derivation-layer-discipline` 铁律1：`default` 不得同表「合法兜底」与「漏配吞错」。
    /// 新增 state-cells base 必在此显式登记，否则 `FamilyDisplaysTests` contract 闭合测试 + fail-closed 双拦。
    /// 🔴 gptpro 跨厂商审第 2 点 catch：原 `default:.badge` 把 `window.lock`（enum locked/unlocked 二值锁，
    ///    实为 `.toggle`）静默吞成 badge → 4b 做 toggle 图形控件时「为什么车窗锁没开关控件」追查灾难。
    static let mapping: [String: UIValueType] = [
        // dial — 温度环形仪表（int celsius）
        "ac.temp_setpoint": .dial,
        // percent — 开度百分比（int percent）
        "window.position": .percent, "screen.brightness": .percent, "ambient.brightness": .percent,
        "seat.backrest_angle": .percent, "door.tailgate_height": .percent, "volume.level": .percent,
        "sunroof.position": .percent, "sunshade.position": .percent,
        // stepper — 档位（int gear）
        "ac.fan_speed": .stepper, "seat.heat_level": .stepper, "seat.vent_level": .stepper,
        "seat.massage_force": .stepper, "wiper.speed": .stepper, "fragrance.intensity": .stepper,
        // toggle — 二值开关（enum 2 values）
        "ac.power": .toggle, "door.central_lock": .toggle, "door.child_lock": .toggle,
        "volume.mute": .toggle, "fragrance.power": .toggle, "wiper.power": .toggle,
        "window.lock": .toggle,   // 🔴 gptpro 第2点修：原 default 吞成 badge，实为二值锁 locked/unlocked
        // badge — intentional allowlist（多值枚举模式 / RGB / 只读仪表 / 多态运动）
        "ac.mode": .badge, "ambient.color": .badge, "seat.massage_mode": .badge,
        "volume.mode": .badge, "wiper.mode": .badge, "fragrance.mode": .badge,
        "door.car_door": .badge,        // 5 态运动枚举 open/closed/opening/closing/paused，非二值
        "window.motion": .badge, "sunroof.motion": .badge,   // 运动态枚举
        "vehicle.speed": .badge, "vehicle.gear": .badge,      // 只读仪表
    ]

    static func uiValueType(for cell: DemoVehicleStateCell) -> UIValueType {
        uiValueType(forBase: ScopedStateKey(cell.key).base)
    }

    static func uiValueType(forBase base: String) -> UIValueType {
        if let type = mapping[base] { return type }
        preconditionFailure("Unmapped UIValueType base: \(base) — 必须在 UIValueTypeMapper.mapping 显式登记（控件类型）或列入 badge allowlist 或标 4b deferred")
    }

    /// 显式可空查询入口：未知 base 只能返回 nil，不能静默降级成 `.badge`。
    static func mappedUIValueType(forBase base: String) -> UIValueType? { mapping[base] }

    /// contract-driven 闭合测试用：base 是否已显式登记（不触发 fail-closed）。
    static func isMapped(_ base: String) -> Bool { mapping[base] != nil }
}

struct StateCellUIValueTypeProjection: Equatable, Sendable {
    let base: String
    let uiValueType: UIValueType

    var uiValueTypeFieldValue: String {
        uiValueType.rawValue
    }
}

enum StateCellUIValueTypeProjector {
    static func projections(
        catalog: StateCellPresentationCatalog = .shared
    ) -> [StateCellUIValueTypeProjection] {
        catalog.knownBases.sorted().map { base in
            StateCellUIValueTypeProjection(
                base: base,
                uiValueType: UIValueTypeMapper.uiValueType(forBase: base)
            )
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
    private let lookup: StateCellContractLookup?

    init(titlesByBase: [String: String], defaultScopeByBase: [String: String], scopesByBase: [String: [String]], lookup: StateCellContractLookup? = nil) {
        self.titlesByBase = titlesByBase
        self.defaultScopeByBase = defaultScopeByBase
        self.scopesByBase = scopesByBase
        self.lookup = lookup
    }

    func displayTitle(for base: String) -> String {
        titlesByBase[base] ?? fallbackTitle(for: base)
    }

    func defaultScope(for base: String) -> String? {
        defaultScopeByBase[base]
    }

    func defaultValue(for base: String) -> String? {
        lookup?.cell(id: base)?.defaultValue
    }

    func enumValues(for base: String) -> [String]? {
        guard let values = lookup?.cell(id: base)?.values, !values.isEmpty else {
            return nil
        }
        return values
    }

    func renderReadback(stateKey: String, scope: String?, value: String, scopeOrigin: ScopeOrigin? = nil) -> String? {
        lookup?.renderReadback(stateKey: stateKey, scope: scope, value: value, scopeOrigin: scopeOrigin)
    }

    var cellDefinitions: [StateCellDefinition] {
        lookup?.cells ?? []
    }

    /// 控件值域（dial/percent/stepper）；委托 A2 `StateCellContractLookup`（execution_range 单一 SSOT，UIUE 不重复手写解析）。
    /// enum/只读 base（无 execution_range）返 nil（toggle/badge 不需范围）。
    func executionRange(for base: String) -> ExecutionRange? {
        lookup?.cell(id: base)?.executionRange
    }

    /// 该 catalog 已知的全 base（contract-driven 闭合测试源：遍历断言 `UIValueTypeMapper.isMapped`）。
    var knownBases: Set<String> { Set(titlesByBase.keys) }

    func aggregateScopeLabel(base: String, scopes: [String]) -> String? {
        // 聚合逻辑提取到 base-aware `ScopeAggregationResolver`（gptpro 第8点）；catalog 仅注入该 base 的 scope 域。
        ScopeAggregationResolver.aggregateLabel(activeScopes: scopes, scopeDomain: scopesByBase[base] ?? [])
    }

    static func load() -> StateCellPresentationCatalog {
        guard let yaml = loadStateCellsYAML() else {
            return fallback
        }
        let parsed = parse(yaml: yaml)
        guard !parsed.titlesByBase.isEmpty else {
            return fallback
        }
        // execution_range 单一源 = A2 StateCellContractLookup（同 yaml；UIUE 委托不重复手写解析，derivation 铁律2）
        let lookup = try? StateCellContractLookup(yaml: yaml)
        return StateCellPresentationCatalog(
            titlesByBase: parsed.titlesByBase,
            defaultScopeByBase: parsed.defaultScopeByBase,
            scopesByBase: parsed.scopesByBase,
            lookup: lookup
        )
    }

    private static let fallback = StateCellPresentationCatalog(
        titlesByBase: [:],
        defaultScopeByBase: [:],
        scopesByBase: [:]
    )

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
