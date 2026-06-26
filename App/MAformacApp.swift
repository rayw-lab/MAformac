import SwiftUI

@main
struct MAformacApp: App {
    @State private var vehicleStore = DemoVehicleStateStore()
    @State private var traceLogger = InMemoryTraceLogger()
    private let speech = AVSpeechSynthesisEngine()

    var body: some Scene {
        WindowGroup {
            rootView
        }
    }

    @ViewBuilder private var rootView: some View {
        #if DEBUG
        // DEBUG 截图脚手架（spec §2.5）：force-state 单态满屏（5-gate）/ gallery（内循环）/ 正常
        if let forced = DebugVisualState.forced {
            ForcedStateScreen(state: forced, theme: DebugVisualState.forcedTheme)
        } else if DebugLaunchArguments.showAmbientBurst {
            AmbientBurstHarnessScreen(
                initialTheme: DebugLaunchArguments.mockTheme,
                initialPreset: DebugLaunchArguments.mockSnapshot,
                colorName: DebugLaunchArguments.ambientBurstColor ?? "紫色"
            )
        } else if ProcessInfo.processInfo.arguments.contains("-showGallery") {
            DemoVisualStateGallery()
        } else if ProcessInfo.processInfo.arguments.contains("-showDemoControlPanel") {
            DemoControlPanelHarnessScreen(initialTheme: DebugLaunchArguments.mockTheme)
        } else if ProcessInfo.processInfo.arguments.contains("-showDemoAllStates") {
            DemoAllStatesHarnessScreen(initialTheme: DebugLaunchArguments.mockTheme)
        } else if ProcessInfo.processInfo.arguments.contains("-spikeControls") {
            ValueControlsSpikeScreen()   // 4b Task11 value.type 控件 spike（Gauge 渲染验收）
        } else if ProcessInfo.processInfo.arguments.contains("-spikeExpanded") {
            ExpandedFamilyCardSpikeScreen()   // 4b Task13 座椅 composite 展开 spike
        } else if ProcessInfo.processInfo.arguments.contains("-spikeSequencer") {
            MultiCallSequencerSpikeScreen()   // 4c Task14 多意图错峰浮现 spike
        } else {
            mainView
        }
        #else
        mainView
        #endif
    }

    private var mainView: some View {
        #if DEBUG
        ContentView(
            store: vehicleStore,
            traceLogger: traceLogger,
            speech: speech,
            initialPreset: DebugLaunchArguments.mockSnapshot,
            initialTheme: DebugLaunchArguments.mockTheme,
            initialAmbientBurstColor: DebugLaunchArguments.ambientBurstColor,
            initialContext: DebugLaunchArguments.mockContext,
            contextCapsuleRoute: DebugLaunchArguments.contextCapsuleRoute
        )
        #else
        ContentView(store: vehicleStore, traceLogger: traceLogger, speech: speech)
        #endif
    }
}

#if DEBUG
enum DebugLaunchArguments {
    static var goldenPath: U17GoldenPathEntry? {
        guard
            let rawValue = value(after: "-goldenPathID"),
            let id = U17GoldenPathID(rawValue: rawValue)
        else {
            return nil
        }

        return U17GoldenPathManifest.entry(for: id)
    }

    static var showAmbientBurst: Bool {
        ProcessInfo.processInfo.arguments.contains("-showAmbientBurst") ||
        ProcessInfo.processInfo.environment["SHOW_AMBIENT_BURST"] == "1"
    }

    static var mockSnapshot: SnapshotPreset {
        if let goldenPath {
            return SnapshotPreset(rawValue: goldenPath.snapshotPresetRawValue) ?? .cooling
        }
        return value(after: "-mockSnapshot").flatMap(SnapshotPreset.init(rawValue:)) ?? .cooling
    }

    static var mockTheme: PresentationTheme {
        if let goldenPath {
            return PresentationTheme(rawValue: goldenPath.themeRawValue) ?? .deepSpace
        }
        return value(after: "-mockTheme").flatMap(PresentationTheme.init(rawValue:)) ?? .ivory
    }

    static var ambientBurstColor: String? {
        guard showAmbientBurst else { return nil }
        return ProcessInfo.processInfo.environment["AMBIENT_BURST_COLOR"] ?? value(after: "-ambientBurstColor") ?? "紫色"
    }

    static var contextCapsuleRoute: ContextCapsuleRoute {
        stringValue(env: "CONTEXT_CAPSULE_ROUTE", flag: "-contextCapsuleRoute")
            .flatMap(ContextCapsuleRoute.init(rawValue:)) ?? .cLite
    }

    static var mockContext: DemoContext? {
        let speed = intValue(env: "CONTEXT_SPEED", flag: "-contextSpeed")
        let gear = stringValue(env: "CONTEXT_GEAR", flag: "-contextGear")
        let weather = stringValue(env: "CONTEXT_WEATHER", flag: "-contextWeather")
        let timePeriod = stringValue(env: "CONTEXT_TIME_PERIOD", flag: "-contextTimePeriod")
        guard speed != nil || gear != nil || weather != nil || timePeriod != nil else { return nil }

        return DemoContext(
            vehicle: DemoVehicleContext(speed: speed ?? 0, gear: gear ?? "P"),
            environment: DemoEnvironmentContext(weather: weather ?? "晴", timePeriod: timePeriod ?? "日间")
        )
    }

    private static func stringValue(env: String, flag: String) -> String? {
        ProcessInfo.processInfo.environment[env] ?? value(after: flag)
    }

    private static func intValue(env: String, flag: String) -> Int? {
        stringValue(env: env, flag: flag).flatMap(Int.init)
    }

    private static func value(after flag: String) -> String? {
        let args = ProcessInfo.processInfo.arguments
        guard let index = args.firstIndex(of: flag), index + 1 < args.count else { return nil }
        return args[index + 1]
    }
}

struct AmbientBurstHarnessScreen: View {
    @State private var store = DemoVehicleStateStore()
    @State private var traceLogger = InMemoryTraceLogger()
    @State private var trigger: AmbientBurstTrigger?
    private let speech = AVSpeechSynthesisEngine()
    let initialTheme: PresentationTheme
    let initialPreset: SnapshotPreset
    let colorName: String

    var body: some View {
        ZStack {
            ContentView(
                store: store,
                traceLogger: traceLogger,
                speech: speech,
                initialPreset: initialPreset,
                initialTheme: initialTheme
            )

            if let trigger {
                AmbientEdgeBurst(trigger: trigger, theme: initialTheme, onFinished: clearAmbientBurst)
                    .ignoresSafeArea()
                    .zIndex(20)
            }
        }
        .onAppear {
            trigger = AmbientBurstTrigger(colorName: colorName)
        }
        .preferredColorScheme(initialTheme.colorScheme)
    }

    private func clearAmbientBurst(id: UUID) {
        guard trigger?.id == id else { return }
        trigger = nil
    }
}
#endif
