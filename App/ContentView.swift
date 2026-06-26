import SwiftUI

struct ContentView: View {
    @Bindable var store: DemoVehicleStateStore
    let traceLogger: InMemoryTraceLogger
    let speech: any SpeechSynthesisEngine

    @State private var snapshot: PresentationSnapshot
    @State private var theme: PresentationTheme
    @State private var focus = FocusController()
    @State private var presentedSheet: PresentationSheet?
    @State private var controlPanelState = DemoControlPanelState()
    @State private var messages: [DialogueMessage]
    @State private var ambientBurst: AmbientBurstTrigger?
    @State private var didTriggerInitialAmbientBurst = false
    private let initialAmbientBurstColor: String?
    private let contextCapsuleRoute: ContextCapsuleRoute

    init(
        store: DemoVehicleStateStore,
        traceLogger: InMemoryTraceLogger,
        speech: any SpeechSynthesisEngine,
        initialPreset: SnapshotPreset = .cooling,
        initialTheme: PresentationTheme = .ivory,
        initialAmbientBurstColor: String? = nil,
        initialContext: DemoContext? = nil,
        contextCapsuleRoute: ContextCapsuleRoute = .cLite
    ) {
        self.store = store
        self.traceLogger = traceLogger
        self.speech = speech
        self.initialAmbientBurstColor = initialAmbientBurstColor
        self.contextCapsuleRoute = contextCapsuleRoute
        let initial = Self.phase2State(for: initialPreset)
        var snapshot = initial.snapshot
        if let initialContext {
            snapshot.context = initialContext
        }
        _snapshot = State(initialValue: snapshot)
        _theme = State(initialValue: initialTheme)
        _messages = State(initialValue: initial.messages)
    }

    private var familyDisplays: [VehicleCardDisplay] {
        VehicleCardDisplay.familyDisplays(from: snapshot.storeCells, activeCells: snapshot.activeCells, reasons: presentationReason(for:))
    }

    private func presentationReason(for key: String) -> String? {
        guard key == snapshot.refusedCell else { return nil }
        switch snapshot.resultKind {
        case .refusalSafetyOrPolicy:
            return "为您的安全已锁定"
        case .refusalNoAvailableTool:
            return "暂不支持该控制"
        case .clarifyMissingSlot:
            return "需要确认后执行"
        case .runtimeError:
            return "演示状态异常"
        case .acceptedToolCall, .alreadyStateNoop, .cancelled, .partialAcceptPartialRefuse, .none:
            return nil
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack(alignment: .topTrailing) {
                DeepSpaceBackground(theme: theme)
                StageAtmosphereLayer(theme: theme, orbState: snapshot.orbState)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                stageBody(size: size)
                    .padding(.horizontal, horizontalPadding(for: size))
                    .padding(.top, stageTopPadding(for: size))
                    .padding(.bottom, 8)

                SettingsRefreshControls(
                    theme: theme,
                    onReset: handleReset,
                    onSettings: { presentedSheet = .settings }
                )
                .padding(.top, topControlsTopPadding(for: size))
                .padding(.trailing, topControlsTrailingPadding(for: size))
                .zIndex(8)

                if let family = focus.focusedFamily {
                    expandedOverlay(family)
                        .zIndex(10)
                        .transition(.opacity.combined(with: .scale(scale: 0.92)))
                }

            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                bottomMicDock(size: size)
            }
            .overlay {
                if let ambientBurst {
                    AmbientEdgeBurst(trigger: ambientBurst, theme: theme, onFinished: clearAmbientBurst)
                        .ignoresSafeArea()
                        .zIndex(12)
                        .transition(.opacity)
                }
            }
        }
        .preferredColorScheme(theme.colorScheme)
        .onAppear(perform: triggerInitialAmbientBurstIfNeeded)
        .animation(.snappy(duration: 0.32), value: focus.focusedFamily)
        .animation(.snappy(duration: 0.32), value: theme)
        .sheet(item: $presentedSheet) { sheet in
            switch sheet {
            case .settings:
                SettingsPanel(
                    theme: $theme,
                    onReset: handleReset,
                    onSnapshot: applySnapshot,
                    onDemoControl: { presentedSheet = .demoControl }
                )
            case .demoControl:
                DemoControlPanel(
                    theme: $theme,
                    state: $controlPanelState,
                    snapshot: snapshot,
                    onApplyContext: applyControlPanelState,
                    onResetNormal: applyNormalRunPreset,
                    onApplyMacro: applyCabinSceneMacro
                )
            }
        }
    }

    @ViewBuilder
    private func stageBody(size: CGSize) -> some View {
        if usesMacSplit(size: size) {
            let layout = AnyLayout(HStackLayout(alignment: .top, spacing: 24))
            layout {
                macConversationColumn(size: size)
                    .frame(width: max(420, min(560, size.width * 0.40)))
                    .frame(maxHeight: .infinity, alignment: .top)
                VehicleCardsGrid(displays: familyDisplays,
                    theme: theme,
                    layout: .macPanorama,
                    bottomInset: 0,
                    onTapFamily: { focus.toggle($0) },
                    onValueScrub: applyMockTransition
                )
                .padding(.top, 64)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        } else {
            VStack(alignment: .leading, spacing: 10) {
                topContextBand(size: size)
                DemoOrbView(theme: theme, state: snapshot.orbState)
                    .frame(maxWidth: .infinity)
                    .frame(height: orbHeight(for: size))
                DialogueStream(messages: messages, theme: theme)
                    .frame(height: dialogueHeight(for: size))
                VehicleCardsGrid(displays: familyDisplays,
                    theme: theme,
                    layout: .phoneScroll,
                    bottomInset: bottomDockInset(for: size),
                    onTapFamily: { focus.toggle($0) },
                    onValueScrub: applyMockTransition
                )
                .padding(.top, vehicleControlsTopPadding(for: size))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
    }

    private func macConversationColumn(size: CGSize) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            topContextBand(size: size)
                .padding(.trailing, 86)
            Spacer(minLength: 12)
            DemoOrbView(theme: theme, state: snapshot.orbState)
                .frame(maxWidth: .infinity)
            DialogueStream(messages: messages, theme: theme)
                .frame(minHeight: 240, maxHeight: 330)
            Spacer(minLength: 28)
            MicDock(theme: theme, state: snapshot.voiceState)
                .frame(maxWidth: .infinity, minHeight: 76, maxHeight: 80)
                .padding(.bottom, 10)
        }
    }

    private func topContextBand(size: CGSize) -> some View {
        HStack(spacing: 0) {
            ContextCapsuleView(theme: theme, context: snapshot.context, route: contextCapsuleRoute)
                .frame(width: contextCapsuleWidth(for: size), height: contextCapsuleHeight(for: size))
                .padding(.leading, usesMacSplit(size: size) ? 0 : 28)
            Spacer(minLength: usesMacSplit(size: size) ? 0 : 86)
        }
        .accessibilityIdentifier("context-band")
    }

    @ViewBuilder
    private func bottomMicDock(size: CGSize) -> some View {
        let split = usesMacSplit(size: size)
        if !split {
            HStack {
                MicDock(theme: theme, state: snapshot.voiceState)
                    .frame(maxWidth: min(780, size.width - 70), minHeight: 70, maxHeight: 74)
            }
            .padding(.horizontal, horizontalPadding(for: size))
            .padding(.bottom, 0)
            .offset(y: 24)
            .zIndex(7)
            .accessibilityIdentifier("mic-dock-safe-area")
        }
    }

    @ViewBuilder
    private func expandedOverlay(_ family: FamilyCardID) -> some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture { focus.dismiss() }
                .accessibilityLabel("收起展开卡")
            ExpandedFamilyCard(
                display: ExpandedFamilyDisplay.make(for: family, from: snapshot.storeCells),
                onDismiss: { focus.dismiss() },
                onMockTransition: { key, desiredValue in
                    applyMockTransition(family: family, key: key, desiredValue: desiredValue)
                }
            )
        }
    }

    private func handleReset() {
        store.reset()
        applySnapshot(.coldStart)
    }

    private func applySnapshot(_ preset: SnapshotPreset) {
        withAnimation(.snappy(duration: 0.32)) {
            let state = Self.phase2State(for: preset)
            snapshot = state.snapshot
            messages = state.messages
        }
    }

    private func applyMockTransition(family: FamilyCardID, key: String, desiredValue: String) {
        let previousAmbientColor = ambientColorValue(in: snapshot.storeCells)
        var cells = snapshot.storeCells
        if !cells.contains(where: { $0.key == key }) {
            let base = ScopedStateKey(key).base
            cells.append(DemoVehicleStateCell(
                key: key,
                actualValue: StateCellPresentationCatalog.shared.defaultValue(for: base) ?? desiredValue,
                revision: nextRevision(in: cells),
                visualState: .normal
            ))
        }
        store.replaceCells(cells)
        let readback = store.applyMockTransition(
            DemoMockTransition(key: key, desiredValue: desiredValue, source: .user)
        )
        let burstColor = AmbientBurstTriggerPolicy.triggerColor(
            key: key,
            previousValue: previousAmbientColor,
            nextValue: desiredValue
        )
        var scopeOrigins = snapshot.scopeOrigins
        scopeOrigins[key] = .explicit
        withAnimation(.snappy(duration: 0.28)) {
            snapshot = PresentationSnapshot.from(
                store: store,
                activeCells: [family: key],
                context: snapshot.context,
                resultKind: .acceptedToolCall,
                traceId: snapshot.traceId,
                scopeOrigins: scopeOrigins,
                orbState: snapshot.orbState,
                voiceState: snapshot.voiceState,
                dialogText: snapshot.dialogText,
                readbacks: snapshot.readbacks + [readback],
                proofClass: .simulatorMock
            )
        }
        if let burstColor {
            triggerAmbientBurst(colorName: burstColor)
        }
    }

    private func applyControlPanelState(_ state: DemoControlPanelState) {
        var cells = snapshot.storeCells
        let revision = nextRevision(in: cells)
        upsertCell(key: "vehicle.speed", value: "\(state.speedPreset.speed)", visualState: .satisfied, revision: revision, in: &cells)
        upsertCell(key: "vehicle.gear", value: state.gear.rawValue, visualState: .satisfied, revision: revision, in: &cells)
        applySnapshotCells(cells, context: state.context, activeCells: snapshot.activeCells, dialogText: snapshot.dialogText)
    }

    private func applyNormalRunPreset() {
        controlPanelState = DemoControlPanelState()
        let cells = normalRunCells()
        applySnapshotCells(
            cells,
            context: controlPanelState.context,
            activeCells: [:],
            dialogText: "已恢复常态运行"
        )
        messages = [DialogueMessage(role: .assistant, text: "已恢复常态运行")]
    }

    private func applyCabinSceneMacro(_ macro: CabinSceneMacro) {
        var cells = snapshot.storeCells
        let previousAmbientColor = ambientColorValue(in: cells)
        let revision = nextRevision(in: cells)
        var activeCells: [FamilyCardID: String] = [:]
        var nextControlState = controlPanelState
        var nextAmbientColor: String?

        func apply(_ key: String, _ value: String, family: FamilyCardID, state: DemoVisualState = .changing) {
            upsertCell(key: key, value: value, visualState: state, revision: revision, in: &cells)
            activeCells[family] = activeCells[family] ?? key
        }

        switch macro {
        case .boarding:
            nextControlState.weather = .sunny
            nextControlState.timePeriod = .day
            apply("door.central_lock", "unlocked", family: .door, state: .satisfied)
            apply("ac.power", "on", family: .ac, state: .satisfied)
            nextAmbientColor = "浅蓝紫"
            apply("ambient.color", "浅蓝紫", family: .ambient, state: .satisfied)
            apply("ambient.brightness[面发光氛围灯]", "70", family: .ambient, state: .satisfied)
        case .leaving:
            nextControlState.speedPreset = .staticRun
            nextControlState.gear = .p
            apply("door.central_lock", "locked", family: .door, state: .satisfied)
            apply("ac.power", "off", family: .ac, state: .normal)
            apply("ambient.brightness[面发光氛围灯]", "0", family: .ambient)
            apply("window.position[主驾]", "0", family: .window)
        case .rainy:
            nextControlState.weather = .rainy
            apply("window.position[主驾]", "0", family: .window)
            apply("window.position[副驾]", "0", family: .window)
            apply("window.position[左后]", "0", family: .window)
            apply("window.position[右后]", "0", family: .window)
            apply("sunroof.position[前排]", "0", family: .sunroofShade)
            apply("wiper.power", "on", family: .wiper, state: .satisfied)
            apply("wiper.speed[前]", "1", family: .wiper)
        case .drowsy:
            nextControlState.timePeriod = .night
            let currentTemp = Int(cellValue("ac.temp_setpoint[主驾]", in: cells) ?? "") ?? 24
            let targetTemp = Int(ValueRangeMapper.clamp(Double(currentTemp - 2), forBase: "ac.temp_setpoint"))
            apply("window.position[主驾]", "50", family: .window)
            apply("ac.temp_setpoint[主驾]", "\(targetTemp)", family: .ac)
            apply("seat.backrest_angle[主驾]", "65", family: .seat)
            apply("seat.vent_level[主驾]", "1", family: .seat)
        }

        controlPanelState = nextControlState
        upsertCell(key: "vehicle.speed", value: "\(nextControlState.speedPreset.speed)", visualState: .satisfied, revision: revision, in: &cells)
        upsertCell(key: "vehicle.gear", value: nextControlState.gear.rawValue, visualState: .satisfied, revision: revision, in: &cells)
        applySnapshotCells(
            cells,
            context: nextControlState.context,
            activeCells: activeCells,
            dialogText: "已 force \(macro.label) 场景"
        )
        messages = [DialogueMessage(role: .assistant, text: "已 force \(macro.label) 场景")]
        if let nextAmbientColor,
           let burstColor = AmbientBurstTriggerPolicy.triggerColor(
               key: "ambient.color",
               previousValue: previousAmbientColor,
               nextValue: nextAmbientColor
           ) {
            triggerAmbientBurst(colorName: burstColor)
        }
    }

    private func applySnapshotCells(
        _ cells: [DemoVehicleStateCell],
        context: DemoContext,
        activeCells: [FamilyCardID: String],
        dialogText: String
    ) {
        store.replaceCells(cells)
        withAnimation(.snappy(duration: 0.28)) {
            snapshot = PresentationSnapshot.from(
                store: store,
                activeCells: activeCells,
                context: context,
                resultKind: .acceptedToolCall,
                traceId: snapshot.traceId,
                scopeOrigins: snapshot.scopeOrigins,
                orbState: snapshot.orbState,
                voiceState: snapshot.voiceState,
                dialogText: dialogText,
                readbacks: snapshot.readbacks,
                proofClass: .simulatorMock
            )
        }
    }

    private func normalRunCells() -> [DemoVehicleStateCell] {
        let catalog = StateCellPresentationCatalog.shared
        var cells = catalog.cellDefinitions.compactMap { definition -> DemoVehicleStateCell? in
            guard let value = definition.defaultValue else { return nil }
            let key = definition.defaultScope.map { "\(definition.id)[\($0)]" } ?? definition.id
            return DemoVehicleStateCell(key: key, actualValue: value, visualState: .normal)
        }
        upsertCell(key: "vehicle.speed", value: "0", visualState: .normal, revision: 0, in: &cells)
        return cells
    }

    private func nextRevision(in cells: [DemoVehicleStateCell]) -> Int {
        (cells.map(\.revision).max() ?? 0) + 1
    }

    private func cellValue(_ key: String, in cells: [DemoVehicleStateCell]) -> String? {
        cells.first { $0.key == key }?.actualValue
    }

    private func ambientColorValue(in cells: [DemoVehicleStateCell]) -> String? {
        cells.first { ScopedStateKey($0.key).base == "ambient.color" }?.actualValue
    }

    private func triggerInitialAmbientBurstIfNeeded() {
        guard !didTriggerInitialAmbientBurst, let color = initialAmbientBurstColor else { return }
        didTriggerInitialAmbientBurst = true
        triggerAmbientBurst(colorName: color)
    }

    private func triggerAmbientBurst(colorName: String) {
        ambientBurst = AmbientBurstTrigger(colorName: colorName)
    }

    private func clearAmbientBurst(id: UUID) {
        guard ambientBurst?.id == id else { return }
        withAnimation(.easeOut(duration: 0.18)) {
            ambientBurst = nil
        }
    }

    private func upsertCell(
        key: String,
        value: String,
        visualState: DemoVisualState,
        revision: Int,
        in cells: inout [DemoVehicleStateCell]
    ) {
        if let index = cells.firstIndex(where: { $0.key == key }) {
            cells[index].actualValue = value
            cells[index].desiredValue = value
            cells[index].source = .user
            cells[index].revision = max(cells[index].revision + 1, revision)
            cells[index].timestamp = Date()
            cells[index].visualState = visualState
        } else {
            cells.append(
                DemoVehicleStateCell(
                    key: key,
                    actualValue: value,
                    desiredValue: value,
                    source: .user,
                    revision: revision,
                    visualState: visualState
                )
            )
        }
    }

    private static func phase2State(for preset: SnapshotPreset) -> (snapshot: PresentationSnapshot, messages: [DialogueMessage]) {
        switch preset {
        case .coldStart:
            return (
                Self.phase2IdleBaselineSnapshot(),
                [DialogueMessage(role: .assistant, text: "我在听...")]
            )
        case .cooling:
            return (
                Self.phase2CoolingSnapshot(),
                [
                    DialogueMessage(role: .user, text: "我有点冷"),
                    DialogueMessage(role: .assistant, text: "已为您调到 26℃", emphasis: "26℃", emphasisTint: .cooling)
                ]
            )
        case .heating:
            return (
                Self.heatingSnapshot(),
                [
                    DialogueMessage(role: .user, text: "我有点热"),
                    DialogueMessage(role: .assistant, text: "已为您调到 28℃", emphasis: "28℃", emphasisTint: .heating)
                ]
            )
        case .safetyRefusal:
            return (
                MockPresentationSnapshotProvider.safetyRefusal(),
                [
                    DialogueMessage(role: .user, text: "行驶中打开后备箱"),
                    DialogueMessage(role: .assistant, text: "行驶中为了安全暂时不能开尾门，停稳后我再帮您")
                ]
            )
        }
    }

    private static func heatingSnapshot() -> PresentationSnapshot {
        phase2Snapshot(acMode: "制热", temperature: "28", thermalState: .changing)
    }

    private static func phase2IdleBaselineSnapshot() -> PresentationSnapshot {
        var snapshot = phase2Snapshot(acMode: "制冷", temperature: "26", thermalState: .normal)
        snapshot.orbState = .idle
        snapshot.dialogText = "我在听..."
        snapshot.resultKind = nil
        return snapshot
    }

    private static func phase2CoolingSnapshot() -> PresentationSnapshot {
        phase2Snapshot(acMode: "制冷", temperature: "26", thermalState: .changing)
    }

    private static func phase2Snapshot(
        acMode: String,
        temperature: String,
        thermalState: DemoVisualState
    ) -> PresentationSnapshot {
        PresentationSnapshot(
            storeCells: [
                demoCell("seat.heat_level", "2", revision: 2, state: .normal),
                demoCell("seat.vent_level", "1", revision: 2, state: .normal),
                demoCell("ambient.color", "浅蓝紫", revision: 3, state: .satisfied),
                demoCell("ambient.brightness", "62", revision: 3, state: .normal),
                demoCell("ac.temp_setpoint", temperature, revision: 4, state: thermalState),
                demoCell("ac.mode", acMode, revision: 4, state: .satisfied),
                demoCell("ac.fan_speed", "2", revision: 4, state: .normal),
                demoCell("screen.brightness", "65", revision: 2, state: .normal),
                demoCell("volume.level", "38", revision: 2, state: .normal),
                demoCell("door.central_lock", "locked", revision: 2, state: .normal),
                demoCell("sunroof.position", "0", revision: 2, state: .normal),
                demoCell("window.position", "60", revision: 2, state: .satisfied),
                demoCell("wiper.power", "on", revision: 2, state: .normal),
                demoCell("wiper.speed", "1", revision: 2, state: .normal),
                demoCell("fragrance.power", "off", revision: 2, state: .normal)
            ],
            activeCells: [.ac: "ac.temp_setpoint"],
            scopeOrigins: ["ac.temp_setpoint": .defaulted],
            context: DemoContext(
                vehicle: DemoVehicleContext(speed: 0, gear: "P"),
                environment: DemoEnvironmentContext(weather: "晴", timePeriod: "日间")
            ),
            orbState: .listen,
            voiceState: .idle,
            dialogText: acMode == "制热" ? "已为您升温" : "已为您调到舒适温度",
            resultKind: .acceptedToolCall
        )
    }

    private static func demoCell(
        _ key: String,
        _ value: String,
        revision: Int,
        state: DemoVisualState
    ) -> DemoVehicleStateCell {
        DemoVehicleStateCell(key: key, actualValue: value, revision: revision, visualState: state)
    }

    private func usesMacSplit(size: CGSize) -> Bool {
        #if os(macOS)
        return size.width >= 820
        #else
        return false
        #endif
    }

    private func horizontalPadding(for size: CGSize) -> CGFloat {
        usesMacSplit(size: size) ? 30 : 22
    }

    private func stageTopPadding(for size: CGSize) -> CGFloat {
        usesMacSplit(size: size) ? 12 : -6
    }

    private func topControlsTopPadding(for size: CGSize) -> CGFloat {
        usesMacSplit(size: size) ? 14 : -4
    }

    private func topControlsTrailingPadding(for size: CGSize) -> CGFloat {
        usesMacSplit(size: size) ? 30 : 8
    }

    private func contextCapsuleWidth(for size: CGSize) -> CGFloat {
        if usesMacSplit(size: size) {
            return max(360, min(520, size.width * 0.34))
        }
        return max(282, min(size.width * 0.64, 650))
    }

    private func contextCapsuleHeight(for size: CGSize) -> CGFloat {
        usesMacSplit(size: size) ? 102 : 108
    }

    private func vehicleControlsTopPadding(for size: CGSize) -> CGFloat {
        usesMacSplit(size: size) ? 0 : 14
    }

    private func orbHeight(for size: CGSize) -> CGFloat {
        switch snapshot.orbState {
        case .idle:
            return min(max(size.height * 0.135, 122), 136)
        case .listen:
            return min(max(size.height * 0.164, 152), 166)
        case .think, .speak:
            return min(max(size.height * 0.168, 154), 172)
        }
    }

    private func dialogueHeight(for size: CGSize) -> CGFloat {
        switch snapshot.orbState {
        case .idle:
            return min(max(size.height * 0.105, 98), 110)
        case .listen, .think, .speak:
            return min(max(size.height * 0.138, 124), 140)
        }
    }

    private func bottomDockInset(for size: CGSize) -> CGFloat {
        usesMacSplit(size: size) ? 104 : 96
    }
}

enum SnapshotPreset: String, CaseIterable, Identifiable {
    case coldStart
    case cooling
    case heating
    case safetyRefusal

    var id: String { rawValue }

    var label: String {
        switch self {
        case .coldStart: return "复位"
        case .cooling: return "制冷"
        case .heating: return "制热"
        case .safetyRefusal: return "安全拒识"
        }
    }
}

enum PresentationSheet: String, Identifiable {
    case settings
    case demoControl

    var id: String { rawValue }
}

struct SettingsRefreshControls: View {
    var theme: PresentationTheme
    var onReset: () -> Void
    var onSettings: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            iconButton(systemName: "arrow.clockwise", label: "复位", action: onReset)
            iconButton(systemName: "gearshape", label: "设置", action: onSettings)
        }
        .accessibilityIdentifier("settings-refresh-controls")
    }

    private func iconButton(systemName: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 21, weight: .medium))
                .frame(width: 46, height: 46)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(DesignTokens.palette(for: theme).inkPrimary)
        .background(DesignTokens.palette(for: theme).surface.opacity(theme == .ivory ? 0.001 : 0.10), in: Circle())
        .accessibilityLabel(label)
    }
}

struct SettingsPanel: View {
    @Binding var theme: PresentationTheme
    var onReset: () -> Void
    var onSnapshot: (SnapshotPreset) -> Void
    var onDemoControl: () -> Void = {}
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Picker("主题", selection: $theme) {
                    ForEach(PresentationTheme.allCases) { item in
                        Text(item.label).tag(item)
                    }
                }
                .pickerStyle(.segmented)

                #if DEMO_MODE || DEBUG
                Section("演绎状态") {
                    Button {
                        onDemoControl()
                    } label: {
                        Label("演绎控制台", systemImage: "slider.horizontal.3")
                    }
                    ForEach(SnapshotPreset.allCases) { preset in
                        Button(preset.label) {
                            onSnapshot(preset)
                            dismiss()
                        }
                    }
                }
                #endif

                Button("复位") {
                    onReset()
                    dismiss()
                }
            }
            .navigationTitle("设置")
        }
        .preferredColorScheme(theme.colorScheme)
    }
}

struct DialogueMessage: Identifiable, Equatable {
    enum Role: Equatable {
        case user
        case assistant
    }

    let id = UUID()
    var role: Role
    var text: String
    var emphasis: String?
    var emphasisTint: ThermalTint = .cooling
}

struct DialogueStream: View {
    let messages: [DialogueMessage]
    var theme: PresentationTheme
    @State private var isAtBottom = true

    private var palette: ThemePalette { DesignTokens.palette(for: theme) }

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(messages) { message in
                            DialogueBubble(message: message, theme: theme)
                                .id(message.id)
                        }
                    }
                    .frame(minHeight: max(0, geometry.size.height - 8), alignment: .bottom)
                    .padding(.vertical, 4)
                }
                .scrollIndicators(.hidden)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 4)
                        .onChanged { _ in isAtBottom = false }
                        .onEnded { _ in
                            Task { @MainActor in
                                try? await Task.sleep(nanoseconds: 700_000_000)
                                isAtBottom = true
                            }
                        }
                )
                .onChange(of: messages.last?.id) { _, id in
                    guard isAtBottom, let id else { return }
                    withAnimation(.snappy(duration: 0.22)) {
                        proxy.scrollTo(id, anchor: .bottom)
                    }
                }
            }
        }
        .clipped()
        .accessibilityIdentifier("dialogue-stream")
    }
}

struct DialogueBubble: View {
    let message: DialogueMessage
    var theme: PresentationTheme

    private var palette: ThemePalette { DesignTokens.palette(for: theme) }

    var body: some View {
        HStack {
            if message.role == .user {
                Spacer(minLength: 50)
            }
            emphasizedText
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .lineSpacing(2)
                .foregroundStyle(message.role == .user ? DesignTokens.semanticCool : palette.inkPrimary)
                .padding(.horizontal, 17)
                .padding(.vertical, 10)
                .background {
                    ZStack(alignment: message.role == .user ? .bottomTrailing : .bottomLeading) {
                        bubbleBackground
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        bubbleTail
                            .frame(width: 16, height: 11)
                            .offset(x: message.role == .user ? 8 : -8, y: 2)
                    }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(palette.hairline, lineWidth: 0.5)
                }
                .frame(maxWidth: 340, alignment: message.role == .user ? .trailing : .leading)
                .fixedSize(horizontal: false, vertical: true)
            if message.role == .assistant {
                Spacer(minLength: 50)
            }
        }
    }

    @ViewBuilder private var bubbleTail: some View {
        let isUser = message.role == .user
        if isUser {
            DialogueBubbleTail(pointsRight: true)
                .fill(
                    LinearGradient(colors: [palette.userBubbleStart.opacity(0.34), palette.userBubbleEnd.opacity(0.68)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
        } else {
            DialogueBubbleTail(pointsRight: false)
                .fill(palette.assistantBubble.opacity(theme == .ivory ? 0.92 : 1.0))
        }
    }

    private var emphasizedText: Text {
        var attributed = AttributedString(message.text)
        if let emphasis = message.emphasis, let range = attributed.range(of: emphasis) {
            attributed[range].foregroundColor = DesignTokens.thermalAccent(for: message.emphasisTint)
        }
        return Text(attributed)
    }

    @ViewBuilder private var bubbleBackground: some View {
        if message.role == .user {
            LinearGradient(colors: [palette.userBubbleStart.opacity(0.44), palette.userBubbleEnd.opacity(0.68)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        } else {
            palette.assistantBubble.opacity(theme == .ivory ? 0.92 : 1.0)
        }
    }
}

struct DialogueBubbleTail: Shape {
    var pointsRight: Bool

    func path(in rect: CGRect) -> Path {
        let tipX = pointsRight ? rect.maxX : rect.minX
        let rootX = pointsRight ? rect.minX + rect.width * 0.22 : rect.maxX - rect.width * 0.22
        let controlX = pointsRight ? rect.maxX - rect.width * 0.16 : rect.minX + rect.width * 0.16

        var path = Path()
        path.move(to: CGPoint(x: rootX, y: rect.minY + 2))
        path.addCurve(
            to: CGPoint(x: tipX, y: rect.maxY),
            control1: CGPoint(x: controlX, y: rect.minY + 3),
            control2: CGPoint(x: tipX, y: rect.midY + 1)
        )
        path.addCurve(
            to: CGPoint(x: rootX, y: rect.maxY - 3),
            control1: CGPoint(x: controlX, y: rect.maxY - 1),
            control2: CGPoint(x: rootX + (pointsRight ? 3 : -3), y: rect.maxY - 2)
        )
        path.closeSubpath()
        return path
    }
}

struct MicDock: View {
    var theme: PresentationTheme
    var state: PresentationVoiceState
    @State private var isPressing = false

    private var palette: ThemePalette { DesignTokens.palette(for: theme) }
    private var isListening: Bool { state == .listening || isPressing }

    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(isListening ? DesignTokens.glowCyan : DesignTokens.semanticCool)
                .frame(width: 16, height: 16)
                .shadow(color: DesignTokens.glowCyan.opacity(isListening ? 0.65 : 0.35), radius: isListening ? 12 : 6)
            Text(isListening ? "松开发送" : "按住说话")
                .font(.system(size: 21, weight: .semibold, design: .rounded))
                .foregroundStyle(palette.inkPrimary)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
            WaveformMark(active: isListening, theme: theme)
                .frame(width: 58, height: 42)
        }
        .padding(.horizontal, 22)
        .background(.regularMaterial, in: Capsule())
        .glassEffect()
        .overlay {
            Capsule().strokeBorder(palette.hairline, lineWidth: 0.5)
        }
        .shadow(color: DesignTokens.glowCyan.opacity(theme == .ivory ? 0.20 : 0.30), radius: 18, y: 8)
        .scaleEffect(isPressing ? 1.018 : 1.0)
        .onLongPressGesture(minimumDuration: 0.05, maximumDistance: 28) {
        } onPressingChanged: { pressing in
            withAnimation(.snappy(duration: 0.18)) {
                isPressing = pressing
            }
        }
        .accessibilityIdentifier("mic-dock")
        .accessibilityLabel("按住说话")
    }
}

struct WaveformMark: View {
    var active: Bool
    var theme: PresentationTheme

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            ForEach(0..<6, id: \.self) { index in
                Capsule()
                    .fill(DesignTokens.palette(for: theme).inkPrimary.opacity(index == 0 || index == 5 ? 0.46 : 0.92))
                    .frame(width: 4, height: active ? CGFloat([14, 24, 34, 28, 20, 12][index]) : CGFloat([10, 18, 26, 22, 15, 10][index]))
                    .animation(.easeInOut(duration: 0.42).repeatForever(autoreverses: true).delay(Double(index) * 0.04), value: active)
            }
        }
        .padding(.horizontal, 12)
        .background(DesignTokens.palette(for: theme).surface.opacity(theme == .ivory ? 0.48 : 0.10), in: Capsule())
    }
}

struct DemoOrbView: View {
    var theme: PresentationTheme
    var state: PresentationOrbState

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var palette: ThemePalette { DesignTokens.palette(for: theme) }
    private var diameter: CGFloat {
        switch state {
        case .idle: return 96
        case .listen: return 112
        case .think, .speak: return 112
        }
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: reduceMotion ? 1 : 1.0 / 30.0)) { timeline in
            let phase = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            let pulse = 1 + sin(phase * 1.8) * 0.025
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    DesignTokens.semanticCoolBright.opacity(theme == .ivory ? 0.20 : 0.30),
                                    DesignTokens.glowViolet.opacity(theme == .ivory ? 0.13 : 0.22),
                                    .clear
                                ],
                                center: .center,
                                startRadius: diameter * 0.24,
                                endRadius: diameter * 1.05
                            )
                        )
                        .frame(width: diameter * 1.72, height: diameter * 1.72)
                        .blur(radius: 4)
                        .scaleEffect(1 + sin(phase * 0.9) * 0.018)
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(theme == .ivory ? 0.96 : 0.54),
                                    DesignTokens.semanticCoolBright.opacity(theme == .ivory ? 0.46 : 0.58),
                                    DesignTokens.glowViolet.opacity(theme == .ivory ? 0.62 : 0.78)
                                ],
                                center: .init(x: 0.68, y: 0.26),
                                startRadius: 5,
                                endRadius: diameter * 0.78
                            )
                        )
                        .overlay {
                            ZStack {
                                AngularGradient(
                                    colors: [
                                        DesignTokens.semanticCool.opacity(theme == .ivory ? 0.46 : 0.72),
                                        Color.white.opacity(theme == .ivory ? 0.18 : 0.12),
                                        DesignTokens.glowViolet.opacity(theme == .ivory ? 0.54 : 0.68),
                                        DesignTokens.semanticCoolBright.opacity(theme == .ivory ? 0.34 : 0.52),
                                        DesignTokens.semanticCool.opacity(theme == .ivory ? 0.46 : 0.72)
                                    ],
                                    center: .center
                                )
                                .rotationEffect(.degrees(phase * 12))
                                .clipShape(Circle())
                                .blendMode(.plusLighter)
                                Ellipse()
                                    .fill(Color.white.opacity(theme == .ivory ? 0.38 : 0.24))
                                    .frame(width: diameter * 0.34, height: diameter * 0.18)
                                    .blur(radius: 5)
                                    .rotationEffect(.degrees(-28))
                                    .offset(x: diameter * 0.21, y: -diameter * 0.27)
                            }
                        }
                        .frame(width: diameter, height: diameter)
                        .overlay {
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(theme == .ivory ? 0.92 : 0.36),
                                            DesignTokens.semanticCoolBright.opacity(theme == .ivory ? 0.34 : 0.48),
                                            DesignTokens.glowViolet.opacity(theme == .ivory ? 0.22 : 0.46)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2.2
                                )
                        }
                        .shadow(color: DesignTokens.glowCyan.opacity(theme == .ivory ? 0.24 : 0.42), radius: 26)
                        .shadow(color: DesignTokens.glowViolet.opacity(theme == .ivory ? 0.10 : 0.22), radius: 40)
                        .scaleEffect(pulse)
                    OrbParticleField(diameter: diameter, phase: phase, theme: theme)
                }
                .frame(width: diameter, height: diameter)
                Text(orbCaption)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(palette.inkDim)
                    .lineLimit(1)
            }
        }
        .accessibilityIdentifier("demo-orb")
    }

    private var orbCaption: String {
        switch state {
        case .idle: return "我在听..."
        case .listen: return "我在听..."
        case .think: return "让我确认下..."
        case .speak: return "正在回应"
        }
    }
}

struct OrbParticleField: View {
    var diameter: CGFloat
    var phase: TimeInterval
    var theme: PresentationTheme

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            for index in 0..<112 {
                let xSeed = CGFloat((index * 37 + 19) % 101) / 50.5 - 1
                let ySeed = CGFloat((index * 61 + 7) % 101) / 50.5 - 1
                let drift = CGFloat(sin(phase * 0.34 + Double(index) * 0.71))
                let distance = sqrt(xSeed * xSeed + ySeed * ySeed)
                let particleSize = index.isMultiple(of: 19) ? 4.6 : (index.isMultiple(of: 7) ? 2.2 : 1.35)
                let opacity = max(0.0, min(0.42, 0.38 - Double(abs(distance - 0.74)) * 0.20))
                let point = CGPoint(
                    x: center.x + xSeed * diameter * 1.30 + drift * 2.2,
                    y: center.y + ySeed * diameter * 0.92 + diameter * 0.22 - drift * 1.2
                )

                if index.isMultiple(of: 19) {
                    drawSparkle(in: &context, at: point, size: particleSize, opacity: opacity * 0.82)
                } else {
                    let particleRect = CGRect(
                        x: point.x - particleSize / 2,
                        y: point.y - particleSize / 2,
                        width: particleSize,
                        height: particleSize
                    )
                    let color = index.isMultiple(of: 5) ? Color.white : DesignTokens.semanticCoolBright
                    context.fill(Path(ellipseIn: particleRect), with: .color(color.opacity(opacity)))
                }
            }
        }
        .frame(width: diameter * 3.05, height: diameter * 2.55)
        .blendMode(.plusLighter)
        .allowsHitTesting(false)
    }

    private func drawSparkle(
        in context: inout GraphicsContext,
        at point: CGPoint,
        size: CGFloat,
        opacity: Double
    ) {
        let color = Color.white.opacity(opacity)
        var vertical = Path()
        vertical.move(to: CGPoint(x: point.x, y: point.y - size))
        vertical.addLine(to: CGPoint(x: point.x, y: point.y + size))
        var horizontal = Path()
        horizontal.move(to: CGPoint(x: point.x - size, y: point.y))
        horizontal.addLine(to: CGPoint(x: point.x + size, y: point.y))
        context.stroke(vertical, with: .color(color), lineWidth: 0.75)
        context.stroke(horizontal, with: .color(color), lineWidth: 0.75)
    }
}

struct DeepSpaceBackground: View {
    var theme: PresentationTheme = .deepSpace

    private var palette: ThemePalette { DesignTokens.palette(for: theme) }

    var body: some View {
        ZStack {
            palette.backgroundBase.ignoresSafeArea()
            RadialGradient(colors: [palette.backgroundHaloA.opacity(theme == .ivory ? 0.24 : 0.12), .clear],
                           center: .init(x: 0.10, y: 0.02), startRadius: 0, endRadius: 520)
                .ignoresSafeArea()
            RadialGradient(colors: [palette.backgroundHaloB.opacity(theme == .ivory ? 0.26 : 0.14), .clear],
                           center: .init(x: 0.92, y: 0.05), startRadius: 0, endRadius: 520)
                .ignoresSafeArea()
        }
    }
}

struct StageAtmosphereLayer: View {
    var theme: PresentationTheme
    var orbState: PresentationOrbState

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(minimumInterval: reduceMotion ? 1 : 1.0 / 30.0)) { timeline in
            let phase = reduceMotion ? 0 : timeline.date.timeIntervalSinceReferenceDate
            GeometryReader { proxy in
                ZStack {
                    particleCanvas(size: proxy.size, phase: phase)
                    edgeSheen(size: proxy.size, phase: phase)
                }
            }
        }
        .blendMode(theme == .ivory ? .plusLighter : .screen)
        .opacity(theme == .ivory ? 0.76 : 0.62)
    }

    private func particleCanvas(size: CGSize, phase: TimeInterval) -> some View {
        Canvas { context, canvasSize in
            for index in 0..<138 {
                let xSeed = CGFloat((index * 43 + 17) % 997) / 997
                let ySeed = CGFloat((index * 61 + 29) % 991) / 991
                let drift = CGFloat(sin(phase * 0.18 + Double(index) * 0.37))
                let twinkle = 0.58 + 0.42 * sin(phase * 0.9 + Double(index) * 0.73)
                let yBand = yPosition(seed: ySeed, index: index)
                let point = CGPoint(
                    x: xSeed * canvasSize.width + drift * 4.0,
                    y: yBand * canvasSize.height + CGFloat(cos(phase * 0.12 + Double(index))) * 2.0
                )
                let baseOpacity = particleOpacity(y: yBand, twinkle: twinkle, index: index)
                let color = particleColor(index: index).opacity(baseOpacity)
                if index.isMultiple(of: 17) {
                    drawSparkle(in: &context, at: point, size: 3.4 + CGFloat(index % 3), color: color)
                } else {
                    let radius = CGFloat(index.isMultiple(of: 9) ? 1.75 : 1.05)
                    context.fill(
                        Path(ellipseIn: CGRect(x: point.x - radius / 2,
                                               y: point.y - radius / 2,
                                               width: radius,
                                               height: radius)),
                        with: .color(color)
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func edgeSheen(size: CGSize, phase: TimeInterval) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            DesignTokens.semanticCoolBright.opacity(theme == .ivory ? 0.15 : 0.22),
                            Color.white.opacity(theme == .ivory ? 0.18 : 0.06),
                            DesignTokens.glowViolet.opacity(theme == .ivory ? 0.08 : 0.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
                .padding(1)
            LinearGradient(
                colors: [
                    .clear,
                    DesignTokens.semanticCoolBright.opacity(theme == .ivory ? 0.10 : 0.14),
                    .clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 92)
            .blur(radius: 22)
            .offset(y: size.height * 0.25 + CGFloat(sin(phase * 0.15) * 2))
        }
        .allowsHitTesting(false)
    }

    private func yPosition(seed: CGFloat, index: Int) -> CGFloat {
        if index.isMultiple(of: 4) {
            return 0.19 + seed * 0.27
        }
        if index.isMultiple(of: 5) {
            return 0.36 + seed * 0.20
        }
        return 0.24 + seed * 0.48
    }

    private func particleOpacity(y: CGFloat, twinkle: Double, index: Int) -> Double {
        let zoneBoost: Double = y < 0.58 ? 1.0 : 0.55
        let base = index.isMultiple(of: 17) ? 0.42 : 0.26
        return max(0.04, min(0.44, base * zoneBoost * twinkle))
    }

    private func particleColor(index: Int) -> Color {
        if index.isMultiple(of: 11) { return DesignTokens.glowViolet }
        if index.isMultiple(of: 7) { return Color.white }
        return DesignTokens.semanticCoolBright
    }

    private func drawSparkle(
        in context: inout GraphicsContext,
        at point: CGPoint,
        size: CGFloat,
        color: Color
    ) {
        var vertical = Path()
        vertical.move(to: CGPoint(x: point.x, y: point.y - size))
        vertical.addLine(to: CGPoint(x: point.x, y: point.y + size))
        var horizontal = Path()
        horizontal.move(to: CGPoint(x: point.x - size, y: point.y))
        horizontal.addLine(to: CGPoint(x: point.x + size, y: point.y))
        context.stroke(vertical, with: .color(color), lineWidth: 0.75)
        context.stroke(horizontal, with: .color(color), lineWidth: 0.75)
    }
}

enum VehicleCardsGridLayout {
    case phoneScroll
    case macPanorama
}

struct VehicleCardsGrid: View {
    let displays: [VehicleCardDisplay]
    var theme: PresentationTheme = .deepSpace
    var layout: VehicleCardsGridLayout = .phoneScroll
    var bottomInset: CGFloat = 108
    var onTapFamily: (FamilyCardID) -> Void = { _ in }
    var onValueScrub: (FamilyCardID, String, String) -> Void = { _, _, _ in }

    @State private var isUserScrolling = false

    #if !os(macOS)
    @Environment(\.horizontalSizeClass) private var sizeClass
    #endif

    private var columnCount: Int {
        switch layout {
        case .macPanorama:
            return 5
        case .phoneScroll:
            #if os(macOS)
            return 5
            #else
            return sizeClass == .compact ? 2 : 4
            #endif
        }
    }

    private var activeFamilyID: String? {
        activeFamily?.rawValue
    }

    private var activeFamily: FamilyCardID? {
        displays.first { $0.activeCell != nil }?.familyCardID ??
            displays.first { $0.visualState != .normal }?.familyCardID
    }

    private var featuredHeroFamily: FamilyCardID {
        .ac
    }

    private var hasActiveFamily: Bool {
        activeFamilyID != nil
    }

    private var usesPhoneFeaturedLayout: Bool {
        layout == .phoneScroll && columnCount == 2
    }

    private var rows: [[VehicleCardDisplay]] {
        rows(for: displays)
    }

    private func rows(for items: [VehicleCardDisplay]) -> [[VehicleCardDisplay]] {
        let cols = max(1, columnCount)
        return stride(from: 0, to: items.count, by: cols).map {
            Array(items[$0 ..< min($0 + cols, items.count)])
        }
    }

    var body: some View {
        Group {
            if layout == .macPanorama {
                gridContent
                    .accessibilityIdentifier("vehicle-cards-mac-panorama")
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        Group {
                            if usesPhoneFeaturedLayout {
                                phoneFeaturedContent
                            } else {
                                gridContent
                            }
                        }
                        .padding(.vertical, 6)
                        .padding(.bottom, bottomInset)
                    }
                    .contentMargins(.bottom, bottomInset, for: .scrollContent)
                    .scrollIndicators(.hidden)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 4)
                            .onChanged { _ in isUserScrolling = true }
                            .onEnded { _ in
                                Task { @MainActor in
                                    try? await Task.sleep(nanoseconds: 900_000_000)
                                    isUserScrolling = false
                                }
                            }
                    )
                    .onAppear {
                        guard !usesPhoneFeaturedLayout else { return }
                        scrollActiveIntoView(proxy)
                    }
                    .onChange(of: activeFamilyID) { _, id in
                        guard id != nil else { return }
                        guard !usesPhoneFeaturedLayout else { return }
                        scrollActiveIntoView(proxy)
                    }
                    .accessibilityIdentifier("vehicle-cards")
                }
            }
        }
    }

    private var gridContent: some View {
        compactGridContent(for: displays)
    }

    private var phoneFeaturedContent: some View {
        GeometryReader { proxy in
            let sideInset: CGFloat = 16
            let available = proxy.size.width - sideInset * 2
            let gap: CGFloat = 22
            let leftWidth = (available - gap) * 0.515
            let rightWidth = available - gap - leftWidth
            let heroFamily = featuredHeroFamily
            HStack(alignment: .top, spacing: gap) {
                VStack(spacing: phoneFeaturedSpacing) {
                    if let display = display(for: heroFamily) {
                        VehicleStateCard(
                            display: display,
                            theme: theme,
                            isHero: true,
                            isFaded: false,
                            layout: layout,
                            onTap: onTapFamily,
                            onValueScrub: onValueScrub
                        )
                        .id(display.familyCardID?.rawValue ?? display.id)
                    }
                    ForEach(displays(for: leftFeaturedFamilies(excluding: heroFamily))) { display in
                        VehicleStateCard(
                            display: display,
                            theme: theme,
                            isHero: false,
                            isFaded: hasActiveFamily && display.familyCardID?.rawValue != activeFamilyID,
                            layout: layout,
                            onTap: onTapFamily,
                            onValueScrub: onValueScrub
                        )
                        .id(display.familyCardID?.rawValue ?? display.id)
                    }
                }
                .frame(width: leftWidth, alignment: .top)

                VStack(spacing: phoneFeaturedSpacing) {
                    ForEach(displays(for: rightFeaturedFamilies(excluding: heroFamily))) { display in
                        VehicleStateCard(
                            display: display,
                            theme: theme,
                            isHero: false,
                            isFaded: hasActiveFamily && display.familyCardID?.rawValue != activeFamilyID,
                            layout: layout,
                            onTap: onTapFamily,
                            onValueScrub: onValueScrub
                        )
                        .id(display.familyCardID?.rawValue ?? display.id)
                    }
                }
                .frame(width: rightWidth, alignment: .top)
            }
            .padding(.horizontal, sideInset)
        }
        .frame(minHeight: phoneFeaturedHeight)
    }

    private var phoneFeaturedHeight: CGFloat {
        6 * phoneCompactTotalHeight + 5 * phoneFeaturedSpacing
    }

    private var phoneFeaturedSpacing: CGFloat {
        8
    }

    private var phoneCompactTotalHeight: CGFloat {
        64
    }

    private func compactGridContent(for items: [VehicleCardDisplay]) -> some View {
        Grid(alignment: .topLeading, horizontalSpacing: 12, verticalSpacing: layout == .phoneScroll ? 10 : 12) {
            ForEach(Array(rows(for: items).enumerated()), id: \.offset) { _, row in
                GridRow {
                    ForEach(row) { display in
                        VehicleStateCard(
                            display: display,
                            theme: theme,
                            isHero: display.familyCardID?.rawValue == activeFamilyID && layout == .phoneScroll && !usesPhoneFeaturedLayout,
                            isFaded: hasActiveFamily && display.familyCardID?.rawValue != activeFamilyID,
                            layout: layout,
                            onTap: onTapFamily,
                            onValueScrub: onValueScrub
                        )
                        .id(display.familyCardID?.rawValue ?? display.id)
                    }
                }
            }
        }
    }

    private func display(for family: FamilyCardID) -> VehicleCardDisplay? {
        displays.first { $0.familyCardID == family }
    }

    private func displays(for families: [FamilyCardID]) -> [VehicleCardDisplay] {
        families.compactMap { display(for: $0) }
    }

    private func leftFeaturedFamilies(excluding hero: FamilyCardID) -> [FamilyCardID] {
        [.ambient, .wiper, .sunroofShade, .fragrance].filter { $0 != hero }
    }

    private func rightFeaturedFamilies(excluding hero: FamilyCardID) -> [FamilyCardID] {
        [.seat, .window, .volume, .screen, .door].filter { $0 != hero }
    }

    private func scrollActiveIntoView(_ proxy: ScrollViewProxy) {
        guard !isUserScrolling, let id = activeFamilyID else { return }
        DispatchQueue.main.async {
            withAnimation(.snappy(duration: 0.32)) {
                proxy.scrollTo(id, anchor: .top)
            }
        }
    }
}

struct VehicleStateCard: View {
    let display: VehicleCardDisplay
    var theme: PresentationTheme = .deepSpace
    var isHero = false
    var isFaded = false
    var layout: VehicleCardsGridLayout = .phoneScroll
    var onTap: (FamilyCardID) -> Void = { _ in }
    var onValueScrub: (FamilyCardID, String, String) -> Void = { _, _, _ in }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var breathe = false

    private var palette: ThemePalette { DesignTokens.palette(for: theme) }
    private var appearance: CardAppearance { CardAppearance.of(display.visualState, theme: theme) }
    private var effectiveAppearance: CardAppearance {
        isFaded ? CardAppearance.of(.normal, theme: theme) : appearance
    }
    private var glowActive: Bool { !isFaded && (appearance.breathing || appearance.pulsing) }
    private var family: FamilyCardID? { display.familyCardID }
    private var thermalTint: ThermalTint {
        family == .ac ? SemanticColorMapper.acThermalTint(siblingCells: display.siblingCells) : .neutral
    }

    var body: some View {
        Button {
            if let family { onTap(family) }
        } label: {
            cardContent
        }
        .buttonStyle(.plain)
        .opacity(isFaded ? 0.96 : 1.0)
        .scaleEffect(isHero ? 1.018 : 1.0, anchor: .center)
        .animation(.snappy(duration: 0.32), value: isHero)
        .accessibilityIdentifier("vehicle-card-\(display.accessibilityKey)")
        .accessibilityLabel("\(display.title) \(display.valueText) \(a11yState)")
    }

    private var cardContent: some View {
        cardBody
            .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
            .padding(cardPadding)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                ZStack {
                    cardSpecularLayer
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(effectiveAppearance.border.opacity(borderOpacity),
                                      lineWidth: borderLineWidth)
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(cardRimGradient, lineWidth: rimLineWidth)
                        .blendMode(.plusLighter)
                }
            }
            .shadow(color: shadowColor, radius: glowActive || isHero ? (breathe ? 20 : 12) : 10, y: glowActive || isHero ? 8 : 5)
            .shadow(color: cardLiftShadow, radius: isHero ? 18 : 8, y: isHero ? 10 : 4)
            .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .onAppear { updateBreathe() }
            .onChange(of: glowActive) { _, _ in updateBreathe() }
    }

    private var cardSpecularLayer: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.white.opacity(theme == .ivory ? (isHero ? 0.42 : 0.22) : 0.13),
                    Color.white.opacity(0.04),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .center
            )
            if isHero {
                LinearGradient(
                    colors: [
                        DesignTokens.thermalAccent(for: thermalTint).opacity(theme == .ivory ? 0.14 : 0.22),
                        Color.clear
                    ],
                    startPoint: .bottomLeading,
                    endPoint: .topTrailing
                )
                .blendMode(.plusLighter)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .allowsHitTesting(false)
    }

    @ViewBuilder private var cardBody: some View {
        if !isHero && layout == .phoneScroll {
            phoneCompactCardBody
        } else {
            fullCardBody
        }
    }

    private var fullCardBody: some View {
        VStack(alignment: .leading, spacing: isHero ? 10 : 7) {
            HStack(spacing: 8) {
                if let family, !(isHero && family == .ac) {
                    Image(systemName: FamilyIconMapper.sfSymbol(for: family))
                        .font(.system(size: isHero ? 22 : 18, weight: .semibold))
                        .foregroundStyle(iconColor)
                        .symbolRenderingMode(.hierarchical)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(display.title)
                        .font(.system(size: isHero ? 16 : 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(palette.inkPrimary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    if let badge = display.scopeBadge {
                        scopeBadgeView(badge)
                    }
                }
                Spacer(minLength: 0)
                if isHero && family == .ac {
                    Image(systemName: thermalSymbol)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(DesignTokens.thermalAccent(for: thermalTint))
                        .symbolRenderingMode(.monochrome)
                } else if display.siblingCells.count > 1 {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(palette.inkDim)
                } else if !isFaded, let icon = appearance.icon {
                    Image(systemName: icon)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(appearance.border)
                }
            }

            if family == .ac {
                acHeroValue
            } else {
                standardValue
            }

            if let reason = display.reason {
                Text(reason)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(palette.inkDim)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
    }

    private var phoneCompactCardBody: some View {
        HStack(alignment: .center, spacing: 9) {
            if let family {
                Image(systemName: FamilyIconMapper.sfSymbol(for: family))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(compactIconColor)
                    .symbolRenderingMode(.monochrome)
                    .frame(width: 26)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(phoneTitleText)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(palette.inkPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                compactValueLine
            }
            Spacer(minLength: 4)
            if display.siblingCells.count > 1 {
                Image(systemName: "chevron.right")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(palette.inkPrimary.opacity(0.74))
            } else if !isFaded, let icon = appearance.icon {
                Image(systemName: icon)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(appearance.border)
            }
        }
    }

    @ViewBuilder private var compactValueLine: some View {
        if case .colorSwatch(let name) = display.badgeStyle {
            HStack(spacing: 8) {
                ambientSwatch(name)
                Text(display.valueText)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(valueColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.64)
            }
        } else {
            Text(display.valueText)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(valueColor)
                .contentTransition(.numericText())
                .animation(.snappy, value: display.valueText)
                .lineLimit(1)
                .minimumScaleFactor(0.62)
                .truncationMode(.tail)
        }
    }

    private var standardValue: some View {
        HStack(spacing: 9) {
            if case .colorSwatch(let name) = display.badgeStyle {
                ambientSwatch(name)
            }
            Text(display.valueText)
                .font(.system(size: standardValueSize, weight: standardValueWeight, design: .rounded))
                .foregroundStyle(valueColor)
                .contentTransition(.numericText())
                .animation(.snappy, value: display.valueText)
                .lineLimit(1)
                .minimumScaleFactor(0.58)
                .truncationMode(.tail)
        }
    }

    private var acHeroValue: some View {
        VStack(alignment: .leading, spacing: isHero ? 8 : 10) {
            if let unit = acTemperatureParts.unit {
                HStack(alignment: .firstTextBaseline, spacing: isHero ? 6 : 4) {
                    Text(acTemperatureParts.number)
                        .font(.system(size: isHero ? 62 : 32, weight: .heavy, design: isHero ? .default : .rounded))
                        .foregroundStyle(palette.inkPrimary)
                        .contentTransition(.numericText())
                        .lineLimit(1)
                        .minimumScaleFactor(0.58)
                    Text(unit)
                        .font(.system(size: isHero ? 22 : 18, weight: .medium, design: .rounded))
                        .foregroundStyle(palette.inkPrimary)
                        .baselineOffset(isHero ? 2 : 0)
                }
            } else {
                Text(display.valueText)
                    .font(.system(
                        size: isHero ? standbyValueSize : 21,
                        weight: display.valueText == "待命" ? .medium : .semibold,
                        design: .rounded
                    ))
                    .foregroundStyle(valueColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
                    .truncationMode(.tail)
            }
            ThermalRangeBar(
                valueText: display.valueText,
                tint: thermalTint,
                theme: theme,
                onScrubbedValue: acTemperatureScrubAction
            )
                .frame(height: isHero ? 24 : 18)
            Text(acModeLabel)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(palette.inkDim)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }

    @ViewBuilder private var cardBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.regularMaterial)
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(palette.surfaceElevated.opacity(surfaceOpacity))
            LinearGradient(colors: [
                Color.white.opacity(topGlassOpacity),
                Color.white.opacity(0.02),
                Color.clear
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
            effectiveAppearance.background.opacity(appearanceWashOpacity)
            if case .colorSwatch(let name) = display.badgeStyle {
                LinearGradient(colors: DesignTokens.ambientGradient(named: name).map { $0.opacity(theme == .ivory ? 0.020 : 0.12) },
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            }
            if family == .ac {
                LinearGradient(colors: DesignTokens.thermalGradient(for: thermalTint).map { $0.opacity(theme == .ivory ? (isHero ? 0.022 : 0.030) : 0.12) },
                               startPoint: .leading, endPoint: .trailing)
            }
        }
    }

    private func ambientSwatch(_ name: String) -> some View {
        Circle()
            .fill(LinearGradient(colors: DesignTokens.ambientGradient(named: name), startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: isHero ? 24 : 18, height: isHero ? 24 : 18)
            .overlay(Circle().strokeBorder(Color.white.opacity(0.58), lineWidth: 0.5))
            .shadow(color: DesignTokens.ambientColor(named: name).opacity(0.45), radius: 7)
    }

    private func scopeBadgeView(_ badge: ScopeBadge) -> some View {
        let emphasized = badge.style == .emphasized
        return Text(badge.text)
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .lineLimit(1)
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(
                emphasized ? DesignTokens.glowCyan.opacity(0.18) : palette.inkDim2.opacity(0.16),
                in: Capsule()
            )
            .foregroundStyle(emphasized ? DesignTokens.glowCyan : palette.inkDim)
            .overlay(
                Capsule().strokeBorder((emphasized ? DesignTokens.glowCyan : palette.inkDim2).opacity(0.42), lineWidth: 0.5)
            )
    }

    private var minHeight: CGFloat {
        if layout == .macPanorama {
            return isHero ? 138 : 118
        }
        return isHero ? 158 : 48
    }

    private var standardValueSize: CGFloat {
        if layout == .macPanorama { return 28 }
        if isColorSwatchValue { return 24 }
        return 27
    }

    private var standardValueWeight: Font.Weight {
        isColorSwatchValue ? .semibold : .heavy
    }

    private var isColorSwatchValue: Bool {
        if case .colorSwatch = display.badgeStyle {
            return true
        }
        return false
    }

    private var standbyValueSize: CGFloat {
        display.valueText == "待命" ? 23 : 26
    }

    private var phoneTitleText: String {
        switch family {
        case .some(.ambient): return "氛围"
        default: return display.title
        }
    }

    private var cardPadding: CGFloat {
        if isHero { return 14 }
        return layout == .phoneScroll ? 8 : 12
    }

    private var cornerRadius: CGFloat {
        if isHero { return 22 }
        return layout == .phoneScroll ? 16 : 18
    }

    private var borderOpacity: Double {
        if isHero { return 0.26 }
        if glowActive { return layout == .phoneScroll ? 0.30 : 0.72 }
        return layout == .phoneScroll ? 0.14 : 0.38
    }

    private var borderLineWidth: CGFloat {
        if isHero { return 0.58 }
        if glowActive { return layout == .phoneScroll ? 0.62 : 1.0 }
        return 0.5
    }

    private var rimLineWidth: CGFloat {
        if isHero { return 1.05 }
        return layout == .phoneScroll ? 0.58 : 0.85
    }

    private var cardRimGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(theme == .ivory ? (isHero ? 0.82 : 0.68) : 0.28),
                Color.white.opacity(theme == .ivory ? 0.08 : 0.05),
                effectiveAppearance.border.opacity(glowActive || isHero ? 0.32 : 0.16)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var compactIconColor: Color {
        if isFaded {
            return palette.inkPrimary.opacity(theme == .ivory ? 0.82 : 0.78)
        }
        switch display.visualState {
        case .normal:
            return palette.inkPrimary
        case .satisfied:
            return palette.inkPrimary
        case .changing:
            return palette.inkPrimary
        case .blocked_with_alternative:
            return effectiveAppearance.border
        case .blocked_hard:
            return effectiveAppearance.border
        case .unsafe:
            return effectiveAppearance.border
        case .unknown:
            return effectiveAppearance.border
        }
    }

    private var acTemperatureParts: (number: String, unit: String?) {
        let value = display.valueText
        if value.hasSuffix("℃") {
            return (String(value.dropLast()), "°C")
        }
        if value.hasSuffix("°C") {
            return (String(value.dropLast(2)), "°C")
        }
        return (value, nil)
    }

    private var acTemperatureScrubAction: ((String) -> Void)? {
        guard isHero, family == .ac else { return nil }
        let key = acTemperatureCellKey ?? "ac.temp_setpoint"
        return { next in
            onValueScrub(.ac, key, next)
        }
    }

    private var acTemperatureCellKey: String? {
        display.siblingCells.first { ScopedStateKey($0.key).base == "ac.temp_setpoint" }?.key
    }

    private var valueColor: Color {
        if glowActive {
            return palette.inkPrimary
        }
        switch display.visualState {
        case .normal:
            return display.valueText == "待命" ? palette.inkDim : palette.inkPrimary
        case .satisfied:
            return palette.inkPrimary
        case .changing:
            return palette.inkPrimary
        case .blocked_with_alternative:
            return palette.inkPrimary
        case .blocked_hard:
            return palette.inkPrimary
        case .unsafe:
            return palette.inkPrimary
        case .unknown:
            return palette.inkPrimary
        }
    }

    private var iconColor: Color {
        if isFaded {
            return palette.inkPrimary.opacity(0.72)
        }
        if family == .ac {
            switch display.visualState {
            case .normal:
                return palette.inkDim
            case .satisfied:
                return DesignTokens.thermalAccent(for: thermalTint)
            case .changing:
                return DesignTokens.thermalAccent(for: thermalTint)
            case .blocked_with_alternative:
                return effectiveAppearance.border
            case .blocked_hard:
                return effectiveAppearance.border
            case .unsafe:
                return effectiveAppearance.border
            case .unknown:
                return effectiveAppearance.border
            }
        }
        switch display.visualState {
        case .normal:
            return palette.inkDim
        case .satisfied:
            return effectiveAppearance.border
        case .changing:
            return effectiveAppearance.border
        case .blocked_with_alternative:
            return effectiveAppearance.border
        case .blocked_hard:
            return effectiveAppearance.border
        case .unsafe:
            return effectiveAppearance.border
        case .unknown:
            return effectiveAppearance.border
        }
    }

    private var shadowColor: Color {
        if glowActive || isHero {
            return appearance.border.opacity(theme == .ivory ? 0.16 : 0.52)
        }
        return palette.softShadow.opacity(theme == .ivory ? 0.07 : 0.22)
    }

    private var cardLiftShadow: Color {
        palette.softShadow.opacity(theme == .ivory ? (isHero ? 0.055 : 0.018) : 0.16)
    }

    private var surfaceOpacity: Double {
        if theme != .ivory { return 0.72 }
        if isHero { return 0.58 }
        return layout == .phoneScroll ? 0.52 : 0.62
    }

    private var topGlassOpacity: Double {
        if theme != .ivory { return 0.10 }
        return isHero ? 0.22 : 0.11
    }

    private var appearanceWashOpacity: Double {
        if isHero { return theme == .ivory ? 0.035 : 0.045 }
        if layout == .phoneScroll { return theme == .ivory ? 0.060 : 0.10 }
        return 1.0
    }

    private var thermalSymbol: String {
        switch thermalTint {
        case .cooling: return "snowflake"
        case .heating: return "heat.waves"
        case .neutral: return "fan.fill"
        }
    }

    private var acModeLabel: String {
        let mode = display.siblingCells.first { ScopedStateKey($0.key).base == "ac.mode" }?.actualValue ?? "auto"
        switch mode {
        case "制冷": return "制冷 · 自动"
        case "制热": return "制热 · 自动"
        default: return "自动"
        }
    }

    private func updateBreathe() {
        guard !reduceMotion, glowActive || isHero else {
            breathe = false
            return
        }
        withAnimation(.easeInOut(duration: appearance.pulsing ? 0.9 : 3.4).repeatForever(autoreverses: true)) {
            breathe = true
        }
    }

    private var a11yState: String {
        switch display.visualState {
        case .normal: "待命"
        case .satisfied: "已满足"
        case .changing: "执行中"
        case .blocked_with_alternative: "需澄清"
        case .blocked_hard: "不支持"
        case .unsafe: "安全拦截"
        case .unknown: "错误"
        }
    }
}

struct ThermalRangeBar: View {
    var valueText: String
    var tint: ThermalTint
    var theme: PresentationTheme
    var onScrubbedValue: ((String) -> Void)?

    @State private var scrubbedValue: Double?

    private let temperatureRange: ClosedRange<Double> = 18...32

    private var progress: Double {
        let digits = valueText.filter { $0.isNumber }
        guard let value = Double(digits) else { return 0.5 }
        return progress(for: value)
    }

    private var displayProgress: Double {
        if let scrubbedValue {
            return progress(for: scrubbedValue)
        }
        return progress
    }

    private func progress(for value: Double) -> Double {
        let span = temperatureRange.upperBound - temperatureRange.lowerBound
        guard span > 0 else { return 0 }
        return min(max((value - temperatureRange.lowerBound) / span, 0), 1)
    }

    private var fillColors: [Color] {
        switch tint {
        case .cooling:
            return [DesignTokens.semanticCool, DesignTokens.semanticCool.opacity(0.92)]
        case .heating:
            return DesignTokens.thermalGradient(for: tint)
        case .neutral:
            return DesignTokens.thermalGradient(for: tint)
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            ZStack {
                track(width: width)
                    .frame(height: 6)
                if let onScrubbedValue {
                    Color.clear
                        .contentShape(Rectangle())
                        .highPriorityGesture(scrubGesture(width: width, onScrubbedValue: onScrubbedValue))
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("调节空调温度")
        .accessibilityValue("\(formatTemperature(scrubbedValue ?? currentTemperature))℃")
        .accessibilityAdjustableAction { direction in
            guard let onScrubbedValue else { return }
            switch direction {
            case .increment:
                setScrubbedTemperature((scrubbedValue ?? currentTemperature) + 1, onScrubbedValue: onScrubbedValue)
            case .decrement:
                setScrubbedTemperature((scrubbedValue ?? currentTemperature) - 1, onScrubbedValue: onScrubbedValue)
            @unknown default:
                break
            }
        }
        .accessibilityHidden(onScrubbedValue == nil)
    }

    private func scrubGesture(width: CGFloat, onScrubbedValue: @escaping (String) -> Void) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                scrubTemperature(at: value.location.x, width: width, onScrubbedValue: onScrubbedValue)
            }
    }

    private func scrubTemperature(at locationX: CGFloat, width: CGFloat, onScrubbedValue: (String) -> Void) {
        guard width > 0 else { return }
        let progress = min(max(Double(locationX / width), 0), 1)
        let span = temperatureRange.upperBound - temperatureRange.lowerBound
        let next = temperatureRange.lowerBound + progress * span
        setScrubbedTemperature(next, onScrubbedValue: onScrubbedValue)
    }

    private func setScrubbedTemperature(_ value: Double, onScrubbedValue: (String) -> Void) {
        let snapped = value.rounded().clamped(to: temperatureRange)
        guard scrubbedValue != snapped else { return }
        scrubbedValue = snapped
        onScrubbedValue(formatTemperature(snapped))
    }

    private func track(width: CGFloat) -> some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(DesignTokens.palette(for: theme).inkDim2.opacity(theme == .ivory ? 0.18 : 0.24))
            Capsule()
                .fill(LinearGradient(colors: fillColors,
                                     startPoint: .leading, endPoint: .trailing))
                .frame(width: max(16, width * displayProgress))
            Circle()
                .fill(Color.white)
                .frame(width: 13, height: 13)
                .shadow(color: DesignTokens.thermalAccent(for: tint).opacity(0.45), radius: 5)
                .offset(x: max(0, min(width - 13, width * displayProgress - 6.5)))
        }
    }

    private var currentTemperature: Double {
        let digits = valueText.filter { $0.isNumber }
        guard let value = Double(digits) else {
            return (temperatureRange.lowerBound + temperatureRange.upperBound) / 2
        }
        return value.clamped(to: temperatureRange)
    }

    private func formatTemperature(_ value: Double) -> String {
        String(Int(value.rounded()))
    }
}

#Preview {
    ContentView(
        store: DemoVehicleStateStore(),
        traceLogger: InMemoryTraceLogger(),
        speech: RecordingSpeechSynthesisEngine()
    )
}
