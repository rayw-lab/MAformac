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
            ForcedStateScreen(state: forced)
        } else if ProcessInfo.processInfo.arguments.contains("-showGallery") {
            DemoVisualStateGallery()
        } else {
            mainView
        }
        #else
        mainView
        #endif
    }

    private var mainView: some View {
        ContentView(store: vehicleStore, traceLogger: traceLogger, speech: speech)
    }
}

