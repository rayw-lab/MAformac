import SwiftUI

struct ContentView: View {
    @Bindable var store: DemoVehicleStateStore
    let traceLogger: InMemoryTraceLogger
    let speech: any SpeechSynthesisEngine

    @State private var commandText = "打开空调"
    @State private var lastReadback = "等待指令"
    @State private var errorText: String?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                commandBar
                vehicleCards
                tracePanel
            }
            .padding(24)
            .navigationTitle("MAformac")
        }
    }

    private var commandBar: some View {
        HStack(spacing: 12) {
            TextField("输入车控指令", text: $commandText)
                .textFieldStyle(.roundedBorder)

            Button {
                Task { await runCommand() }
            } label: {
                Label("执行", systemImage: "play.fill")
            }
            .buttonStyle(.borderedProminent)
        }
        .accessibilityIdentifier("command-bar")
    }

    private var vehicleCards: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12)], spacing: 12) {
            ForEach(store.presentationCells) { cell in
                VehicleStateCard(cell: cell)
            }
        }
    }

    private var tracePanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(lastReadback)
                .font(.headline)
            if let errorText {
                Text(errorText)
                    .foregroundStyle(.red)
            }
            ForEach(Array(traceLogger.entries.enumerated()), id: \.offset) { _, entry in
                Text("\(entry.stage.rawValue): \(entry.message)")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }
        }
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

struct VehicleStateCard: View {
    let cell: DemoVehicleStateCell
    /// blocked 态原因文案（来自 trace `guardReason`/`readbackResult`，spec R1 §3.3）；nil = 不显示。
    var reason: String? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var breathe = false

    // 7 态视觉外观（穷尽 switch，禁二值/禁 default —— DesignTokens.CardAppearance.of）
    private var appearance: CardAppearance { CardAppearance.of(cell.visualState) }
    private var glowActive: Bool { appearance.breathing || appearance.pulsing }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(DesignTokens.inkPrimary)
                Spacer(minLength: 0)
                if let icon = appearance.icon {
                    Image(systemName: icon)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(appearance.border)
                }
            }
            Text(cell.actualValue)
                .font(.title2.weight(.semibold))
                .foregroundStyle(DesignTokens.inkPrimary)
            if let reason {
                Text(reason)
                    .font(.caption)
                    .foregroundStyle(DesignTokens.inkDim)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text("rev \(cell.revision)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(DesignTokens.inkDim2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(appearance.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(appearance.border, lineWidth: glowActive ? 1.5 : 1)
        }
        // 呼吸/脉冲辉光：ReduceMotion/低电量 → 静态辉光（双通道，态靠 颜色/边框/图标 承载）
        .shadow(color: glowActive ? appearance.border.opacity(0.5) : .clear,
                radius: glowActive ? (breathe ? 16 : 8) : 0)
        .onAppear {
            guard !reduceMotion, glowActive else { return }
            withAnimation(.easeInOut(duration: appearance.pulsing ? 0.9 : 3.4)
                .repeatForever(autoreverses: true)) { breathe = true }
        }
        .accessibilityIdentifier("vehicle-card-\(cell.key)")
        .accessibilityLabel("\(title) \(cell.actualValue) \(accessibilityState)")
    }

    // 标题与 scope 解析（main scoped-state：key 形如 `base[scope]`，D-domain 全集）
    private var title: String {
        let parts = scopedParts(for: cell.key)
        switch parts.base {
        case "ac.power": return "空调"
        case "ac.temp_setpoint": return scopedTitle(parts.scope, suffix: "空调温度")
        case "ac.fan_speed": return scopedTitle(parts.scope, suffix: "空调风量")
        case "window.position": return scopedTitle(parts.scope, suffix: "车窗")
        case "screen.brightness": return scopedTitle(parts.scope, suffix: "屏幕亮度")
        case "ambient.brightness": return scopedTitle(parts.scope, suffix: "氛围灯亮度")
        case "ambient.color": return "氛围灯颜色"
        case "seat.heat_level": return scopedTitle(parts.scope, suffix: "座椅加热")
        case "seat.vent_level": return scopedTitle(parts.scope, suffix: "座椅通风")
        case "seat.backrest_angle": return scopedTitle(parts.scope, suffix: "座椅靠背")
        case "wiper.power": return "雨刮"
        case "wiper.speed": return scopedTitle(parts.scope, suffix: "雨刮速度")
        case "sunroof.position": return scopedTitle(parts.scope, suffix: "天窗")
        case "sunshade.position": return scopedTitle(parts.scope, suffix: "遮阳帘")
        case "vehicle.speed": return "车速"
        case "vehicle.gear": return "挡位"
        default: return cell.key
        }
    }

    private func scopedTitle(_ scope: String?, suffix: String) -> String {
        guard let scope, !scope.isEmpty else {
            return suffix
        }
        return "\(scope)\(suffix)"
    }

    private func scopedParts(for key: String) -> (base: String, scope: String?) {
        guard let open = key.firstIndex(of: "["),
              let close = key.firstIndex(of: "]"),
              open < close else {
            return (key, nil)
        }
        return (
            String(key[..<open]),
            String(key[key.index(after: open)..<close])
        )
    }

    // a11y 态文案（四态分开，与视觉双通道）
    private var accessibilityState: String {
        switch cell.visualState {
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
