import SwiftUI

struct ContentView: View {
    @Bindable var store: DemoVehicleStateStore
    let traceLogger: InMemoryTraceLogger
    let speech: any SpeechSynthesisEngine

    @State private var commandText = "打开空调"
    @State private var lastReadback = "等待指令"
    @State private var errorText: String?

    // 10 族全景常驻摘要（消费侧派生；过滤 vehicle.*，遍历 allCases 出 10 卡，AD-9/10/11）
    private var familyDisplays: [VehicleCardDisplay] {
        VehicleCardDisplay.familyDisplays(from: store.presentationCells)
    }

    var body: some View {
        ZStack {
            DeepSpaceBackground()
            // 三屏分层（深空辉光暗底，tokens INDEX）：顶=输入/orb · 中=对话流 · 下=车控卡片
            VStack(alignment: .leading, spacing: 16) {
                brandHeader            // 顶层品牌（Phase 5 上方接 orb）
                commandBar             // 顶层临时输入（Phase 5 → 语音 orb）
                readbackPanel          // 中层 readback/对话流（Phase 5 扩对话流）
                VehicleCardsGrid(displays: familyDisplays)   // 下层车控卡片（10 族常驻）
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .padding(20)
        }
    }

    private var brandHeader: some View {
        Text("MAformac")
            .font(.title3.weight(.bold))
            .foregroundStyle(DesignTokens.inkPrimary)
            .accessibilityAddTraits(.isHeader)
    }

    // 顶层：临时指令输入（Phase 5 替换为语音 orb，三屏分层顶层）
    private var commandBar: some View {
        HStack(spacing: 12) {
            TextField("输入车控指令", text: $commandText)
                .textFieldStyle(.plain)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(DesignTokens.inkDim2.opacity(0.14), in: Capsule())
                .foregroundStyle(DesignTokens.inkPrimary)
            Button {
                Task { await runCommand() }
            } label: {
                Label("执行", systemImage: "play.fill").font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.borderedProminent)
            .tint(DesignTokens.glowCyan)
        }
        .accessibilityIdentifier("command-bar")
    }

    // 中层：readback + trace（Phase 5 扩为对话流，三屏分层中层）
    private var readbackPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(lastReadback)
                .font(.headline)
                .foregroundStyle(DesignTokens.inkPrimary)
                .contentTransition(.opacity)
                .animation(.snappy, value: lastReadback)
            if let errorText {
                Text(errorText).font(.caption).foregroundStyle(DesignTokens.safetyRed)
            }
            // 限近 6 条防 append-only trace 溢出顶出下方车控 grid（Task5 审计 P2-3；Phase 5 对话流套 ScrollView 完整化）
            ForEach(Array(traceLogger.entries.suffix(6).enumerated()), id: \.offset) { _, entry in
                Text("\(entry.stage.rawValue): \(entry.message)")
                    .font(.caption.monospaced())
                    .foregroundStyle(DesignTokens.inkDim)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("trace-panel")
    }

    @MainActor
    private func runCommand() async {
        errorText = nil
        let skeleton = DemoWalkingSkeleton(
            store: store,
            guardrail: DemoFastPathGuard(),
            traceLogger: traceLogger,
            speech: speech
        )
        do {
            let readback = try await skeleton.handle(text: commandText)
            lastReadback = "\(readback.key): \(readback.actualValue)"
        } catch {
            errorText = "\(error)"
        }
    }
}

// MARK: - 深空辉光暗底（tokens.md §1.1/§1.2，U11 halation 控 .10-.14 不铺满）

struct DeepSpaceBackground: View {
    var body: some View {
        ZStack {
            DesignTokens.bgBase.ignoresSafeArea()
            // 顶部青紫辉光雾（径向，控占屏 30-60%，高饱和只在激活强调）
            RadialGradient(colors: [DesignTokens.glowViolet.opacity(0.14), .clear],
                           center: .init(x: 0.18, y: 0.0), startRadius: 0, endRadius: 480)
                .ignoresSafeArea()
            RadialGradient(colors: [DesignTokens.glowCyan.opacity(0.10), .clear],
                           center: .init(x: 0.92, y: 0.04), startRadius: 0, endRadius: 460)
                .ignoresSafeArea()
        }
    }
}

// MARK: - 10 族车控卡片网格（Grid 固定列非 LazyVGrid.adaptive，spec R3/C22；ContentView + force-state 复用）

struct VehicleCardsGrid: View {
    let displays: [VehicleCardDisplay]

    #if !os(macOS)
    @Environment(\.horizontalSizeClass) private var sizeClass
    #endif

    // 固定列（离散稳定，非连续 adaptive 漂移，C22）：iPhone 2 / iPad 4 / Mac 5
    private var columnCount: Int {
        #if os(macOS)
        return 5
        #else
        return sizeClass == .compact ? 2 : 4
        #endif
    }

    var body: some View {
        let cols = max(1, columnCount)
        let rows = stride(from: 0, to: displays.count, by: cols).map {
            Array(displays[$0 ..< min($0 + cols, displays.count)])
        }
        ScrollView {
            Grid(alignment: .topLeading, horizontalSpacing: 12, verticalSpacing: 12) {
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    GridRow {
                        ForEach(row) { display in
                            VehicleStateCard(display: display)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .scrollClipDisabled()   // 防卡片辉光被 ScrollView 裁切
        .accessibilityIdentifier("vehicle-cards")
    }
}

// MARK: - 单族卡（消费 VehicleCardDisplay：族名 + scope 角标 + numericText + breathe + ambient 色块）

struct VehicleStateCard: View {
    let display: VehicleCardDisplay

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var breathe = false

    // 7 态视觉外观（穷尽 switch，DesignTokens.CardAppearance.of，D7 复用）
    private var appearance: CardAppearance { CardAppearance.of(display.visualState) }
    private var glowActive: Bool { appearance.breathing || appearance.pulsing }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 标题行：族名 + scope 淡角标 + 态图标
            HStack(spacing: 6) {
                Text(display.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DesignTokens.inkPrimary)
                    .lineLimit(1)
                if let badge = display.scopeBadge {
                    scopeBadgeView(badge)
                }
                Spacer(minLength: 0)
                if let icon = appearance.icon {
                    Image(systemName: icon)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(appearance.border)
                }
            }
            // 值行：ambient 色块 + numericText 数字动效
            HStack(spacing: 8) {
                if case .colorSwatch(let name) = display.badgeStyle {
                    ambientSwatch(name)
                }
                Text(display.valueText)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(valueColor)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: display.valueText)   // F-LB2：值变更在动画事务内，numericText 才滚动
                    .lineLimit(1).minimumScaleFactor(0.7)
            }
            if let reason = display.reason {
                Text(reason)
                    .font(.caption2)
                    .foregroundStyle(DesignTokens.inkDim)
                    .lineLimit(2).fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 84, alignment: .leading)
        .padding(12)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(appearance.border, lineWidth: glowActive ? 1.5 : 1)
        }
        // content_glow 自研辉光（box-shadow，非 .glassEffect 内容层）；仅激活态 breathe，双通道（ReduceMotion 静态）
        .shadow(color: glowActive ? appearance.border.opacity(0.55) : .clear,
                radius: glowActive ? (breathe ? 18 : 9) : 0)
        .onAppear { updateBreathe() }
        .onChange(of: glowActive) { _, _ in updateBreathe() }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("vehicle-card-\(display.accessibilityKey)")
        .accessibilityLabel("\(display.title) \(display.valueText) \(a11yState)")
    }

    // 激活态值高对比、未激活占位 dim（视觉层级 Gate1）
    private var valueColor: Color {
        glowActive ? DesignTokens.inkPrimary : DesignTokens.inkDim
    }

    // ambient 色块炸场：色名染卡背 + 圆色块（深空暗底上 vivid 高对比）
    @ViewBuilder private var cardBackground: some View {
        if case .colorSwatch(let name) = display.badgeStyle {
            ZStack {
                appearance.background
                DesignTokens.ambientColor(named: name).opacity(0.20)
            }
        } else {
            appearance.background
        }
    }

    private func ambientSwatch(_ name: String) -> some View {
        Circle()
            .fill(DesignTokens.ambientColor(named: name))
            .frame(width: 18, height: 18)
            .overlay(Circle().strokeBorder(.white.opacity(0.4), lineWidth: 0.5))
            .shadow(color: DesignTokens.ambientColor(named: name).opacity(0.6), radius: 5)
    }

    // scope 角标（content_glow 标准 material/色，非 glass）：dim=淡显主驾 / emphasized=青标签全车
    private func scopeBadgeView(_ badge: ScopeBadge) -> some View {
        Text(badge.text)
            .font(.caption2.weight(.medium))
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(
                badge.style == .emphasized ? DesignTokens.glowCyan.opacity(0.20) : DesignTokens.inkDim2.opacity(0.14),
                in: Capsule()
            )
            .foregroundStyle(badge.style == .emphasized ? DesignTokens.glowCyan : DesignTokens.inkDim)
    }

    private func updateBreathe() {
        guard !reduceMotion, glowActive else {
            breathe = false
            return
        }
        withAnimation(.easeInOut(duration: appearance.pulsing ? 0.9 : 3.4).repeatForever(autoreverses: true)) {
            breathe = true
        }
    }

    // a11y 态文案（七态分开，与视觉双通道）
    private var a11yState: String {
        switch display.visualState {
        case .normal: "未激活"
        case .satisfied: "已满足"
        case .changing: "执行中"
        case .blocked_with_alternative: "需澄清"
        case .blocked_hard: "不支持"
        case .unsafe: "安全拦截"
        case .unknown: "错误"
        }
    }
}

#Preview {
    ContentView(
        store: DemoVehicleStateStore(),
        traceLogger: InMemoryTraceLogger(),
        speech: RecordingSpeechSynthesisEngine()
    )
}
