import Foundation

struct RuntimeReadbackEventStep: Equatable, Sendable {
    var event: T5PresentationEvent
    var speechText: T5ReadbackText
}

struct RuntimeReadbackEventQueue: Equatable, Sendable {
    private(set) var inFlight: RuntimeReadbackEventStep?
    private var pending: [RuntimeReadbackEventStep] = []

    var inFlightReadbackID: String? {
        inFlight?.event.readbackID
    }

    var pendingCount: Int {
        pending.count
    }

    var isIdle: Bool {
        inFlight == nil && pending.isEmpty
    }

    mutating func start(_ steps: [RuntimeReadbackEventStep]) -> RuntimeReadbackEventStep? {
        inFlight = nil
        pending = steps
        return advanceIfIdle()
    }

    mutating func completeInFlight(readbackID: String? = nil) -> RuntimeReadbackEventStep? {
        guard let current = inFlight else { return nil }
        if let readbackID, current.event.readbackID != readbackID {
            return nil
        }
        inFlight = nil
        return advanceIfIdle()
    }

    mutating func cancel() {
        inFlight = nil
        pending = []
    }

    private mutating func advanceIfIdle() -> RuntimeReadbackEventStep? {
        guard inFlight == nil, !pending.isEmpty else { return nil }
        let next = pending.removeFirst()
        inFlight = next
        return next
    }
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
        steps(
            snapshot: finalSnapshot,
            initialStoreCells: finalSnapshot.storeCells,
            priorReadbacks: priorReadbacks,
            readbacks: readbacks
        )
    }

    static func steps(
        snapshot finalSnapshot: StagePresentationSnapshot,
        initialStoreCells: [DemoVehicleStateCell],
        priorReadbacks: [DemoActionReadback],
        readbacks: [DemoActionReadback]
    ) -> [RuntimeReadbackEventStep] {
        var prefixReadbacks = priorReadbacks
        var prefixCellsByKey = Dictionary(
            initialStoreCells.map { ($0.key, $0) },
            uniquingKeysWith: { _, new in new }
        )
        let finalCellsByKey = Dictionary(
            finalSnapshot.storeCells.map { ($0.key, $0) },
            uniquingKeysWith: { _, new in new }
        )

        return readbacks.map { readback in
            prefixReadbacks.append(readback)
            prefixCellsByKey[readback.key] = prefixCell(
                for: readback,
                existing: prefixCellsByKey[readback.key],
                finalCell: finalCellsByKey[readback.key]
            )

            var eventSnapshot = finalSnapshot
            eventSnapshot.storeCells = prefixCellsByKey.values.sorted { $0.key < $1.key }
            eventSnapshot.activeCells = activeCells(
                from: finalSnapshot.activeCells,
                currentReadbackKey: readback.key
            )
            eventSnapshot.readbacks = prefixReadbacks
            let readbackID = readbackRuntimeID(readback)
            return RuntimeReadbackEventStep(
                event: T5PresentationEvent.runtime(snapshot: eventSnapshot, readbackID: readbackID),
                speechText: T5ReadbackText(id: readbackID, text: readback.spokenText)
            )
        }
    }

    private static func prefixCell(
        for readback: DemoActionReadback,
        existing: DemoVehicleStateCell?,
        finalCell: DemoVehicleStateCell?
    ) -> DemoVehicleStateCell {
        if let finalCell {
            return finalCell
        }

        var cell = existing ?? DemoVehicleStateCell(
            key: readback.key,
            actualValue: readback.actualValue,
            revision: readback.revision
        )
        cell.actualValue = readback.actualValue
        cell.desiredValue = readback.actualValue
        cell.source = .mock
        cell.revision = readback.revision
        return cell
    }

    private static func activeCells(
        from finalActiveCells: [FamilyCardID: String],
        currentReadbackKey: String
    ) -> [FamilyCardID: String] {
        var activeCells = finalActiveCells
        if let family = FamilyCardIDMapper.familyCardID(forBase: ScopedStateKey(currentReadbackKey).base) {
            activeCells[family] = currentReadbackKey
        }
        return activeCells
    }
}
