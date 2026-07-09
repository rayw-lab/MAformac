import Foundation

struct RuntimeReadbackEventStep: Equatable, Sendable {
    var event: T5PresentationEvent
    var speechText: T5ReadbackText
}

enum RuntimeReadbackEventSequence {
    static func readbackRuntimeID(_ readback: DemoActionReadback) -> String {
        "\(readback.key)#\(readback.revision)"
    }

    static func steps(
        snapshot finalSnapshot: StagePresentationSnapshot,
        priorReadbacks: [DemoActionReadback],
        readbacks: [DemoActionReadback]
    ) -> [RuntimeReadbackEventStep] {
        var prefix = priorReadbacks
        return readbacks.map { readback in
            prefix.append(readback)
            var eventSnapshot = finalSnapshot
            eventSnapshot.readbacks = prefix
            let readbackID = readbackRuntimeID(readback)
            return RuntimeReadbackEventStep(
                event: T5PresentationEvent.runtime(snapshot: eventSnapshot, readbackID: readbackID),
                speechText: T5ReadbackText(id: readbackID, text: readback.spokenText)
            )
        }
    }
}
