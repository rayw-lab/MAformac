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
            ForEach(store.cells) { cell in
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

private struct VehicleStateCard: View {
    let cell: DemoVehicleStateCell

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(cell.actualValue)
                .font(.title2.weight(.semibold))
            Text("rev \(cell.revision)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(borderColor, lineWidth: 1)
        }
        .accessibilityIdentifier("vehicle-card-\(cell.key)")
    }

    private var title: String {
        switch cell.key {
        case "hvac.ac": return "空调"
        case "hvac.temperature": return "温度"
        case "seat.driver.heat": return "座椅加热"
        case "seat.driver.ventilation": return "座椅通风"
        case "window.driver": return "车窗"
        case "lighting.ambient": return "氛围灯"
        case "screen.brightness": return "屏幕亮度"
        case "fan.speed": return "风量"
        default: return cell.key
        }
    }

    private var background: Color {
        cell.visualState == .satisfied ? Color.green.opacity(0.18) : Color.gray.opacity(0.10)
    }

    private var borderColor: Color {
        cell.visualState == .satisfied ? .green : .gray.opacity(0.35)
    }
}

#Preview {
    ContentView(
        store: DemoVehicleStateStore(),
        traceLogger: InMemoryTraceLogger(),
        speech: RecordingSpeechSynthesisEngine()
    )
}
