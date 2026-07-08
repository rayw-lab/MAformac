import AVFoundation
import Foundation

enum T5RuntimePresentationFault: Equatable, Hashable, Sendable {
    case timeout
    case emptyResponse
    case malformedPayload
    case unknownTool
    case safetyRefusal(cardKey: String)
    case ttsFailure

    static let allReceiptCases: [T5RuntimePresentationFault] = [
        .timeout,
        .emptyResponse,
        .malformedPayload,
        .unknownTool,
        .safetyRefusal(cardKey: "__sample_related_card__"),
        .ttsFailure
    ]
}

enum T5ErrorScope: Equatable, Sendable {
    case globalRetryableCrash
    case unsupportedLocked
    case relatedCardOnly(String)
    case ttsDegraded
}

struct T5ErrorVisualReceiptRow: Equatable, Sendable {
    var fault: T5RuntimePresentationFault
    var visualState: DemoVisualState
    var isRetryable: Bool
    var scope: T5ErrorScope
    var receiptKind: String
}

enum T5RuntimeErrorVisualMapper {
    static func map(_ fault: T5RuntimePresentationFault) -> T5ErrorVisualReceiptRow {
        switch fault {
        case .timeout:
            return retryableCrash(fault, receiptKind: "crash_retryable_timeout")
        case .emptyResponse:
            return retryableCrash(fault, receiptKind: "crash_retryable_empty")
        case .malformedPayload:
            return retryableCrash(fault, receiptKind: "crash_retryable_malformed")
        case .unknownTool:
            return T5ErrorVisualReceiptRow(
                fault: fault,
                visualState: .blocked_hard,
                isRetryable: false,
                scope: .unsupportedLocked,
                receiptKind: "unsupported_unknown_tool"
            )
        case .safetyRefusal(let cardKey):
            return T5ErrorVisualReceiptRow(
                fault: fault,
                visualState: .unsafe,
                isRetryable: false,
                scope: .relatedCardOnly(cardKey),
                receiptKind: "safety_related_card_only"
            )
        case .ttsFailure:
            return T5ErrorVisualReceiptRow(
                fault: fault,
                visualState: .blocked_with_alternative,
                isRetryable: false,
                scope: .ttsDegraded,
                receiptKind: "tts_degraded_non_crash"
            )
        }
    }

    private static func retryableCrash(
        _ fault: T5RuntimePresentationFault,
        receiptKind: String
    ) -> T5ErrorVisualReceiptRow {
        T5ErrorVisualReceiptRow(
            fault: fault,
            visualState: .unknown,
            isRetryable: true,
            scope: .globalRetryableCrash,
            receiptKind: receiptKind
        )
    }
}

enum T5PresentationSource: String, Equatable, Sendable {
    case idlePanorama
    case demoForce
    case runtime
}

struct T5PresentationEvent: Equatable, Sendable {
    var source: T5PresentationSource
    var snapshot: StagePresentationSnapshot
    var readbackID: String?
    var sourceMarker: String?

    static func idlePanorama() -> T5PresentationEvent {
        T5PresentationEvent(
            source: .idlePanorama,
            snapshot: MockPresentationSnapshotProvider.coldStart(),
            readbackID: nil,
            sourceMarker: nil
        )
    }

    static func forceState(_ state: DemoVisualState) -> T5PresentationEvent {
        T5PresentationEvent(
            source: .demoForce,
            snapshot: StagePresentationSnapshot(
                storeCells: FamilyCardID.displayOrder.map {
                    DemoVehicleStateCell(
                        key: "\($0.rawValue).force_state",
                        actualValue: "DEMO_FORCE",
                        visualState: state
                    )
                },
                dialogText: "DEMO_FORCE \(state.rawValue)"
            ),
            readbackID: nil,
            sourceMarker: "DEMO_FORCE"
        )
    }

    static func runtime(snapshot: StagePresentationSnapshot, readbackID: String) -> T5PresentationEvent {
        T5PresentationEvent(
            source: .runtime,
            snapshot: snapshot,
            readbackID: readbackID,
            sourceMarker: nil
        )
    }
}

struct T5PresentationOrchestrator: Sendable {
    func firstFrame() -> T5PresentationEvent {
        .idlePanorama()
    }

    func resolve(current: T5PresentationEvent?, incoming: T5PresentationEvent) -> T5PresentationEvent {
        if incoming.source == .runtime { return incoming }
        if let current, current.source == .runtime { return current }
        return incoming
    }
}

struct T5CardChange: Equatable, Sendable {
    var cardID: String
    var state: DemoVisualState
    var readbackID: String
    var revision: Int
    var isCrash: Bool

    init(
        cardID: String,
        state: DemoVisualState,
        readbackID: String,
        revision: Int,
        isCrash: Bool = false
    ) {
        self.cardID = cardID
        self.state = state
        self.readbackID = readbackID
        self.revision = revision
        self.isCrash = isCrash
    }
}

struct T5ScheduledCardChange: Equatable, Sendable {
    var cardID: String
    var state: DemoVisualState
    var readbackID: String
    var delayMilliseconds: Int
}

struct T5CardChangeScheduler: Sendable {
    func schedule(_ changes: [T5CardChange]) -> [T5ScheduledCardChange] {
        guard !changes.isEmpty else { return [] }
        let latestReadbackID = changes.max { lhs, rhs in
            lhs.revision < rhs.revision
        }?.readbackID ?? changes[changes.endIndex - 1].readbackID

        let nonCriticalCount = changes.filter { !Self.isImmediate($0) }.count
        var nonCriticalIndex = 0

        return changes.map { change in
            let delay: Int
            if Self.isImmediate(change) {
                delay = 0
            } else {
                delay = Self.delay(forIndex: nonCriticalIndex, count: nonCriticalCount)
                nonCriticalIndex += 1
            }
            return T5ScheduledCardChange(
                cardID: change.cardID,
                state: change.state,
                readbackID: latestReadbackID,
                delayMilliseconds: delay
            )
        }
    }

    private static func isImmediate(_ change: T5CardChange) -> Bool {
        change.state == .unsafe || change.isCrash
    }

    private static func delay(forIndex index: Int, count: Int) -> Int {
        guard count > 1 else { return 120 }
        return 120 + Int((Double(index) * 100.0 / Double(count - 1)).rounded())
    }
}

struct T5ReadbackText: Equatable, Sendable {
    var id: String
    var text: String
}

protocol T5CancellableSpeechEngine: AnyObject, Sendable {
    func speak(_ readback: T5ReadbackText)
    func cancel(textID: String)
}

final class T5RecordingCancellableSpeechEngine: T5CancellableSpeechEngine, @unchecked Sendable {
    private(set) var spoken: [T5ReadbackText] = []
    private(set) var cancelledIDs: [String] = []

    func speak(_ readback: T5ReadbackText) {
        spoken.append(readback)
    }

    func cancel(textID: String) {
        cancelledIDs.append(textID)
    }
}

final class T5ReadbackSpeechCoordinator: @unchecked Sendable {
    private let engine: any T5CancellableSpeechEngine
    private(set) var activeTextID: String?

    init(engine: any T5CancellableSpeechEngine) {
        self.engine = engine
    }

    func handle(_ readback: T5ReadbackText) {
        if let activeTextID, activeTextID != readback.id {
            engine.cancel(textID: activeTextID)
        }
        activeTextID = readback.id
        engine.speak(readback)
    }
}

enum T5TTSPreflightStatus: String, Equatable, Sendable {
    case pass
    case passWithWarnings
    case fail
}

enum T5TTSVoiceRoute: String, Equatable, Sendable {
    case preferred
    case fallback
    case unavailable
}

enum T5TTSPreflightWarning: String, Equatable, Hashable, Sendable {
    case premiumVoiceMissing
    case preferredVoiceMissing
    case outputMuted
}

struct T5TTSPreflightReceipt: Equatable, Sendable {
    var status: T5TTSPreflightStatus
    var voiceRoute: T5TTSVoiceRoute
    var warnings: Set<T5TTSPreflightWarning>
}

enum T5TTSPreflight {
    static func check(
        synthesizerAvailable: Bool,
        preferredVoiceAvailable: Bool,
        fallbackVoiceAvailable: Bool,
        outputMuted: Bool,
        premiumVoiceAvailable: Bool
    ) -> T5TTSPreflightReceipt {
        guard synthesizerAvailable else {
            return T5TTSPreflightReceipt(status: .fail, voiceRoute: .unavailable, warnings: [])
        }

        let route: T5TTSVoiceRoute
        var warnings = Set<T5TTSPreflightWarning>()
        if preferredVoiceAvailable {
            route = .preferred
        } else if fallbackVoiceAvailable {
            route = .fallback
            warnings.insert(.preferredVoiceMissing)
        } else {
            return T5TTSPreflightReceipt(status: .fail, voiceRoute: .unavailable, warnings: [])
        }

        if !premiumVoiceAvailable {
            warnings.insert(.premiumVoiceMissing)
        }
        if outputMuted {
            warnings.insert(.outputMuted)
        }

        return T5TTSPreflightReceipt(
            status: warnings.isEmpty ? .pass : .passWithWarnings,
            voiceRoute: route,
            warnings: warnings
        )
    }

    static func live(outputMuted: Bool = false) -> T5TTSPreflightReceipt {
        let preferred = AVSpeechSynthesisVoice(language: "zh-CN") != nil
        let fallback = AVSpeechSynthesisVoice.speechVoices().contains { $0.language.hasPrefix("zh") }
        let premium = AVSpeechSynthesisVoice.speechVoices().contains { voice in
            voice.language == "zh-CN" && voice.quality == .premium
        }
        return check(
            synthesizerAvailable: true,
            preferredVoiceAvailable: preferred,
            fallbackVoiceAvailable: fallback,
            outputMuted: outputMuted,
            premiumVoiceAvailable: premium
        )
    }
}
