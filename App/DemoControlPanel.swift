import SwiftUI

enum DemoSpeedPreset: String, CaseIterable, Identifiable {
    case staticRun
    case parking
    case city
    case highway

    var id: String { rawValue }

    var label: String {
        switch self {
        case .staticRun: return "静态"
        case .parking: return "泊车"
        case .city: return "城市"
        case .highway: return "高速"
        }
    }

    var speed: Int {
        switch self {
        case .staticRun: return 0
        case .parking: return 5
        case .city: return 30
        case .highway: return 100
        }
    }
}

enum DemoGear: String, CaseIterable, Identifiable {
    case p = "P"
    case r = "R"
    case n = "N"
    case d = "D"

    var id: String { rawValue }
    var label: String { rawValue }
}

enum DemoWeather: String, CaseIterable, Identifiable {
    case sunny
    case rainy

    var id: String { rawValue }
    var label: String { self == .sunny ? "晴天" : "雨天" }
}

enum DemoTimePeriod: String, CaseIterable, Identifiable {
    case day
    case night

    var id: String { rawValue }
    var label: String { self == .day ? "白天" : "夜晚" }
}

enum CabinSceneMacro: String, CaseIterable, Identifiable {
    case boarding
    case leaving
    case rainy
    case drowsy

    var id: String { rawValue }

    var label: String {
        switch self {
        case .boarding: return "上车"
        case .leaving: return "离车"
        case .rainy: return "雨天"
        case .drowsy: return "困了"
        }
    }

    var symbol: String {
        switch self {
        case .boarding: return "figure.seated.side.air.upper"
        case .leaving: return "lock.car"
        case .rainy: return "cloud.rain"
        case .drowsy: return "moon.zzz"
        }
    }
}

struct DemoControlPanelState: Equatable {
    var speedPreset: DemoSpeedPreset = .staticRun
    var gear: DemoGear = .p
    var weather: DemoWeather = .sunny
    var timePeriod: DemoTimePeriod = .day

    var context: DemoContext {
        DemoContext(
            vehicle: DemoVehicleContext(speed: speedPreset.speed, gear: gear.rawValue),
            environment: DemoEnvironmentContext(weather: weather.label, timePeriod: timePeriod.label)
        )
    }
}

struct DemoControlPanel: View {
    @Binding var theme: PresentationTheme
    @Binding var state: DemoControlPanelState
    var snapshot: PresentationSnapshot
    var onApplyContext: (DemoControlPanelState) -> Void
    var onResetNormal: () -> Void
    var onApplyMacro: (CabinSceneMacro) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showAllStates = false

    private var palette: ThemePalette { DesignTokens.palette(for: theme) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    normalRunCard
                    vehicleCard
                    environmentCard
                    cabinMacroCard
                }
                .padding(18)
            }
            .scrollContentBackground(.hidden)
            .background(DeepSpaceBackground(theme: theme))
            .navigationTitle("演绎控制台")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                        .font(.body.weight(.semibold))
                }
            }
            .sheet(isPresented: $showAllStates) {
                AllStateSheet(snapshot: snapshot, controlState: state, theme: theme)
                    .preferredColorScheme(theme.colorScheme)
            }
        }
        .preferredColorScheme(theme.colorScheme)
        .onChange(of: state) { _, newState in
            onApplyContext(newState)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Mock Force")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(palette.inkDim)
            Text("方案经理幕后工具")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(palette.inkPrimary)
            Text("只切 mock context/state，不接真 runtime")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(palette.inkDim)
        }
        .padding(.bottom, 2)
    }

    private var normalRunCard: some View {
        DemoPanelCard(title: "常态运行", symbol: "checkmark.seal", theme: theme) {
            HStack(spacing: 10) {
                Label("当前常态", systemImage: "circle.fill")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(palette.inkPrimary)
                Spacer()
                Button {
                    showAllStates = true
                } label: {
                    Label("查看全部", systemImage: "list.bullet.rectangle")
                }
                .buttonStyle(DemoPanelPillButtonStyle(theme: theme))
            }
            Button {
                onResetNormal()
            } label: {
                Label("一键复位常态", systemImage: "arrow.counterclockwise.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(DemoPanelPrimaryButtonStyle(theme: theme))
        }
    }

    private var vehicleCard: some View {
        DemoPanelCard(title: "整车运行", symbol: "car.side", theme: theme) {
            DemoSegmentedPicker(title: "时速", selection: $state.speedPreset)
            DemoSegmentedPicker(title: "挡位", selection: $state.gear)
        }
    }

    private var environmentCard: some View {
        DemoPanelCard(title: "环境情境", symbol: "cloud.sun", theme: theme) {
            DemoSegmentedPicker(title: "天气", selection: $state.weather)
            DemoSegmentedPicker(title: "时段", selection: $state.timePeriod)
        }
    }

    private var cabinMacroCard: some View {
        DemoPanelCard(title: "座舱场景", symbol: "sparkles", theme: theme) {
            Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                GridRow {
                    macroButton(.boarding)
                    macroButton(.leaving)
                }
                GridRow {
                    macroButton(.rainy)
                    macroButton(.drowsy)
                }
            }
            Text("宏只写 mock store，设备端态回到主界面 10 族卡片继续调。")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(palette.inkDim)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func macroButton(_ macro: CabinSceneMacro) -> some View {
        Button {
            onApplyMacro(macro)
        } label: {
            VStack(spacing: 8) {
                Image(systemName: macro.symbol)
                    .font(.system(size: 22, weight: .semibold))
                Text(macro.label)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            .frame(maxWidth: .infinity, minHeight: 76)
        }
        .buttonStyle(DemoPanelTileButtonStyle(theme: theme))
        .accessibilityLabel("执行\(macro.label)场景宏")
    }
}

private protocol DemoSegmentOption: CaseIterable, Identifiable, Hashable {
    var label: String { get }
}

extension DemoSpeedPreset: DemoSegmentOption {}
extension DemoGear: DemoSegmentOption {}
extension DemoWeather: DemoSegmentOption {}
extension DemoTimePeriod: DemoSegmentOption {}

private struct DemoSegmentedPicker<Option: DemoSegmentOption>: View where Option.AllCases: RandomAccessCollection {
    var title: String
    @Binding var selection: Option
    private var options: Option.AllCases { Option.allCases }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
            HStack(spacing: 7) {
                ForEach(options) { option in
                    Button {
                        selection = option
                    } label: {
                        Text(option.label)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                            .frame(maxWidth: .infinity, minHeight: 40)
                    }
                    .buttonStyle(SegmentOptionButtonStyle(isSelected: option == selection))
                    .accessibilityLabel("\(title)\(option.label)")
                }
            }
        }
    }
}

private struct SegmentOptionButtonStyle: ButtonStyle {
    var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isSelected ? Color.white : DesignTokens.inkDim)
            .background {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(isSelected ? DesignTokens.semanticCool : DesignTokens.inkDim2.opacity(0.15))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .strokeBorder(isSelected ? DesignTokens.semanticCoolBright.opacity(0.55) : Color.white.opacity(0.12), lineWidth: 0.6)
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.snappy(duration: 0.16), value: configuration.isPressed)
            .animation(.snappy(duration: 0.18), value: isSelected)
    }
}

private struct DemoPanelCard<Content: View>: View {
    var title: String
    var symbol: String
    var theme: PresentationTheme
    @ViewBuilder var content: () -> Content

    private var palette: ThemePalette { DesignTokens.palette(for: theme) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: symbol)
                    .font(.system(size: 19, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(DesignTokens.semanticCool)
                    .frame(width: 28)
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.inkPrimary)
                Spacer(minLength: 0)
            }
            content()
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .glassEffect()
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(palette.hairline, lineWidth: 0.6)
        }
        .shadow(color: palette.softShadow.opacity(theme == .ivory ? 0.10 : 0.24), radius: 18, y: 8)
    }
}

private struct DemoPanelPillButtonStyle: ButtonStyle {
    var theme: PresentationTheme
    private var palette: ThemePalette { DesignTokens.palette(for: theme) }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(palette.inkPrimary)
            .padding(.horizontal, 12)
            .frame(minHeight: 40)
            .background(palette.surfaceElevated.opacity(0.56), in: Capsule())
            .overlay { Capsule().strokeBorder(palette.hairline, lineWidth: 0.5) }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

private struct DemoPanelPrimaryButtonStyle: ButtonStyle {
    var theme: PresentationTheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .frame(minHeight: 48)
            .background(LinearGradient(colors: [DesignTokens.semanticCool, DesignTokens.glowViolet],
                                       startPoint: .leading, endPoint: .trailing),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: DesignTokens.semanticCool.opacity(theme == .ivory ? 0.20 : 0.34), radius: 12, y: 5)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

private struct DemoPanelTileButtonStyle: ButtonStyle {
    var theme: PresentationTheme
    private var palette: ThemePalette { DesignTokens.palette(for: theme) }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(palette.inkPrimary)
            .background(palette.surfaceElevated.opacity(theme == .ivory ? 0.72 : 0.46),
                        in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(palette.hairline, lineWidth: 0.6)
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

struct AllStateSheet: View {
    var snapshot: PresentationSnapshot
    var controlState: DemoControlPanelState
    var theme: PresentationTheme
    @Environment(\.dismiss) private var dismiss

    private var palette: ThemePalette { DesignTokens.palette(for: theme) }
    private var sections: [AllStateSection] {
        AllStateSection.make(snapshot: snapshot, controlState: controlState)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(sections) { section in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(section.title)
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundStyle(palette.inkPrimary)
                            VStack(spacing: 9) {
                                ForEach(Array(section.rows.enumerated()), id: \.offset) { _, row in
                                    AllStateRowView(entries: row, theme: theme)
                                }
                            }
                        }
                    }
                }
                .padding(18)
            }
            .background(DeepSpaceBackground(theme: theme))
            .navigationTitle("全部端状态")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                        .font(.body.weight(.semibold))
                }
            }
        }
    }
}

private struct AllStateRowView: View {
    var entries: [AllStateEntry]
    var theme: PresentationTheme

    var body: some View {
        HStack(spacing: 9) {
            ForEach(entries) { entry in
                AllStateCellView(entry: entry, theme: theme)
            }
            if entries.count == 1 {
                Color.clear
                    .frame(maxWidth: .infinity, minHeight: 64)
            }
        }
    }
}

private struct AllStateSection: Identifiable {
    var id: String { title }
    var title: String
    var entries: [AllStateEntry]

    var rows: [[AllStateEntry]] {
        stride(from: 0, to: entries.count, by: 2).map { index in
            Array(entries[index..<min(index + 2, entries.count)])
        }
    }

    static func make(snapshot: PresentationSnapshot, controlState: DemoControlPanelState) -> [AllStateSection] {
        let entries = AllStateEntry.make(snapshot: snapshot, controlState: controlState)
        let order = ["整车", "环境"] + FamilyCardID.displayOrder.map(\.displayName)
        return order.compactMap { title in
            let group = entries.filter { $0.group == title }
            return group.isEmpty ? nil : AllStateSection(title: title, entries: group)
        }
    }
}

private struct AllStateEntry: Identifiable {
    var id: String
    var group: String
    var title: String
    var value: String
    var visualState: DemoVisualState

    static func make(snapshot: PresentationSnapshot, controlState: DemoControlPanelState) -> [AllStateEntry] {
        let catalog = StateCellPresentationCatalog.shared
        let exactCells = Dictionary(uniqueKeysWithValues: snapshot.storeCells.map { ($0.key, $0) })
        let cellsByBase = Dictionary(grouping: snapshot.storeCells, by: { ScopedStateKey($0.key).base })
        var result = catalog.cellDefinitions.map { definition -> AllStateEntry in
            let base = definition.id
            let preferredKey = definition.defaultScope.map { "\(base)[\($0)]" } ?? base
            let cell = exactCells[preferredKey] ?? cellsByBase[base]?.sorted { $0.key < $1.key }.first
            let rawValue = cell?.actualValue ?? defaultValue(for: definition)
            let type = UIValueTypeMapper.uiValueType(forBase: base)
            let value = rawValue == "待命" ? rawValue : VehicleCardDisplay.valueText(for: rawValue, base: base, type: type)
            return AllStateEntry(
                id: base,
                group: groupTitle(forBase: base),
                title: catalog.displayTitle(for: base),
                value: value,
                visualState: cell?.visualState ?? .normal
            )
        }
        result.append(
            AllStateEntry(
                id: "environment.weather",
                group: "环境",
                title: "天气",
                value: controlState.weather.label,
                visualState: .normal
            )
        )
        result.append(
            AllStateEntry(
                id: "environment.time_period",
                group: "环境",
                title: "时段",
                value: controlState.timePeriod.label,
                visualState: .normal
            )
        )
        return result
    }

    private static func defaultValue(for definition: StateCellDefinition) -> String {
        if definition.id == "vehicle.speed" {
            return "0"
        }
        return definition.defaultValue ?? "待命"
    }

    private static func groupTitle(forBase base: String) -> String {
        if base.hasPrefix("vehicle.") {
            return "整车"
        }
        return FamilyCardIDMapper.familyCardID(forBase: base)?.displayName ?? "其他"
    }
}

private struct AllStateCellView: View {
    var entry: AllStateEntry
    var theme: PresentationTheme

    private var palette: ThemePalette { DesignTokens.palette(for: theme) }
    private var appearance: CardAppearance { CardAppearance.of(entry.visualState, theme: theme) }
    private var strokeOpacity: Double {
        switch entry.visualState {
        case .normal:
            return 0.16
        case .satisfied:
            return 0.42
        case .changing:
            return 0.5
        case .blocked_with_alternative:
            return 0.56
        case .blocked_hard:
            return 0.6
        case .unsafe:
            return 0.66
        case .unknown:
            return 0.48
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(palette.inkDim)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(entry.value)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(palette.inkPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.58)
        }
        .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
        .padding(12)
        .background(palette.surfaceElevated.opacity(theme == .ivory ? 0.74 : 0.48),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(appearance.border.opacity(strokeOpacity), lineWidth: 0.6)
        }
    }
}

#Preview {
    DemoControlPanel(
        theme: .constant(.ivory),
        state: .constant(DemoControlPanelState()),
        snapshot: MockPresentationSnapshotProvider.coolingMode(),
        onApplyContext: { _ in },
        onResetNormal: {},
        onApplyMacro: { _ in }
    )
}

#if DEBUG
struct DemoControlPanelHarnessScreen: View {
    @State private var theme: PresentationTheme
    @State private var state = DemoControlPanelState()
    @State private var snapshot = MockPresentationSnapshotProvider.coolingMode()

    init(initialTheme: PresentationTheme) {
        _theme = State(initialValue: initialTheme)
    }

    var body: some View {
        DemoControlPanel(
            theme: $theme,
            state: $state,
            snapshot: snapshot,
            onApplyContext: applyContext,
            onResetNormal: resetNormal,
            onApplyMacro: applyMacro
        )
    }

    private func applyContext(_ nextState: DemoControlPanelState) {
        snapshot.context = nextState.context
        snapshot.proofClass = .simulatorMock
    }

    private func resetNormal() {
        state = DemoControlPanelState()
        snapshot = MockPresentationSnapshotProvider.coolingMode()
        snapshot.context = state.context
        snapshot.proofClass = .simulatorMock
    }

    private func applyMacro(_ macro: CabinSceneMacro) {
        switch macro {
        case .boarding:
            snapshot.dialogText = "已切到上车场景"
        case .leaving:
            snapshot.dialogText = "已切到离车场景"
        case .rainy:
            state.weather = .rainy
            snapshot.dialogText = "已切到雨天场景"
        case .drowsy:
            state.timePeriod = .night
            snapshot.dialogText = "已切到困了场景"
        }
        snapshot.context = state.context
        snapshot.proofClass = .simulatorMock
    }
}

struct DemoAllStatesHarnessScreen: View {
    @State private var theme: PresentationTheme
    @State private var state = DemoControlPanelState()

    init(initialTheme: PresentationTheme) {
        _theme = State(initialValue: initialTheme)
    }

    var body: some View {
        AllStateSheet(
            snapshot: MockPresentationSnapshotProvider.coolingMode(),
            controlState: state,
            theme: theme
        )
    }
}
#endif
