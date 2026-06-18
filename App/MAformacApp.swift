import SwiftUI

@main
struct MAformacApp: App {
    @State private var vehicleStore = DemoVehicleStateStore()
    @State private var traceLogger = InMemoryTraceLogger()
    private let speech = AVSpeechSynthesisEngine()

    var body: some Scene {
        WindowGroup {
            ContentView(
                store: vehicleStore,
                traceLogger: traceLogger,
                speech: speech
            )
        }
    }
}

