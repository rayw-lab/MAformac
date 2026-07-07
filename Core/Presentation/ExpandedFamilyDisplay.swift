import Foundation

/// 展开层单 device cell 的控件渲染参数（4b 触发聚焦展开，每 cell 一行 ValueControlView）。
struct ExpandedCellRow: Identifiable, Equatable {
    var id: String                 // cell.key
    var label: String              // device + scope（如「主驾座椅加热」）
    var valueType: UIValueType
    var numericValue: Double
    var range: ClosedRange<Double>
    var stepCount: Int
    var displayText: String
    var rawValue: String
    var isOn: Bool
    var badgeStyle: BadgeRenderStyle
    var visualState: DemoVisualState
}

/// 展开层族卡 device composite（4b 触发聚焦展开，AD-11/AD-13 展开层 + P4-D2②座椅 composite）。
/// 族 → 该族所有 device cell 的控件参数；按 valueType 分组排序（同类聚合 → 座椅自然 stepper×3→percent→badge = 行分 3 类）。
struct ExpandedFamilyDisplay: Equatable {
    var family: FamilyCardID
    var title: String
    var rows: [ExpandedCellRow]

    /// valueType 展示分组序（同类聚合；座椅 stepper(heat/vent/massage_force)→percent(backrest)→badge(massage_mode) = P4-D2②行分3类）。
    private static func groupOrder(_ type: UIValueType) -> Int {
        switch type {
        case .dial:    return 0   // 温度环置顶
        case .stepper: return 1   // 档位
        case .percent: return 2   // 开度
        case .toggle:  return 3   // 开关
        case .badge:   return 4   // 模式/色块/只读
        }
    }

    static func make(
        for family: FamilyCardID,
        from cells: [DemoVehicleStateCell],
        catalog: StateCellPresentationCatalog = .shared
    ) -> ExpandedFamilyDisplay {
        let familyCells = cells.filter {
            FamilyCardIDMapper.familyCardID(forBase: ScopedStateKey($0.key).base) == family
        }
        let rows = familyCells
            .map { row(for: $0, catalog: catalog) }
            .sorted { lhs, rhs in
                let lo = groupOrder(lhs.valueType), ro = groupOrder(rhs.valueType)
                return lo != ro ? lo < ro : lhs.id < rhs.id
            }
        return ExpandedFamilyDisplay(family: family, title: family.displayName, rows: rows)
    }

    private static func row(for cell: DemoVehicleStateCell, catalog: StateCellPresentationCatalog) -> ExpandedCellRow {
        let key = ScopedStateKey(cell.key)
        let base = key.base
        let valueType = UIValueTypeMapper.uiValueType(forBase: base)
        let range = ValueRangeMapper.range(forBase: base, catalog: catalog) ?? 0...1
        let stepCount = ValueRangeMapper.stepCount(forBase: base, catalog: catalog)
        // 数值提取（dial/percent/stepper）+ 数据层一处归一 clamp（环/文本/段共用）。
        // 🔴 codex P1-3：坏值/空串 fallback 下界（非 0，避免起始非0 range 越界绕路）；toggle/badge 不读 numericValue 无害。
        let numericValue = (Double(cell.actualValue.filter { $0.isNumber || $0 == "." || $0 == "-" }) ?? range.lowerBound).clamped(to: range)
        // displayText / badgeStyle 复用 4a 摘要格式化（§28 不重复格式化逻辑）
        let displayText = VehicleCardDisplay.valueText(for: cell.actualValue, base: base, type: valueType)
        let isOn = ["on", "open", "unlocked", "unmuted"].contains(cell.actualValue)
        let badgeStyle = VehicleCardDisplay.badgeRenderStyle(forBase: base, value: cell.actualValue)
        // label = scope 前缀 + base 标题（如「主驾座椅加热」），展开行明确每 device 范围
        let baseTitle = catalog.displayTitle(for: base)
        let label = key.scope.map { "\($0)\(baseTitle)" } ?? baseTitle
        return ExpandedCellRow(
            id: cell.key,
            label: label,
            valueType: valueType,
            numericValue: numericValue,
            range: range,
            stepCount: stepCount,
            displayText: displayText,
            rawValue: cell.actualValue,
            isOn: isOn,
            badgeStyle: badgeStyle,
            visualState: cell.visualState
        )
    }
}
