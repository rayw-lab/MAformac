import Foundation

public struct DialogueTurn: Codable, Equatable, Sendable {
    public enum Role: String, Codable, Equatable, Sendable {
        case user
        case assistant
    }

    public var role: Role
    public var text: String

    public init(role: Role, text: String) {
        self.role = role
        self.text = text
    }
}

/// D1 wire outcome of `DialogueState.recordTypedFacts`.
///
/// The runner (or any producer) uses this to react to a fail-closed reducer decision.
/// The reducer refuses to record when the incoming correlation is not schema-supported
/// or does not pass `DialogueRouteCorrelationValidator.validate` — the window state
/// is not mutated in that case. See D1 dispatch §4.D1 (`~/.claude/rules/claim-vs-reality-gap.md`
/// 铁律 2 — deliberate negatives required).
public enum DialogueTypedFactsRecordResult: Equatable, Sendable {
    /// Recorded `count` facts into `typedFactsWindow`; state may have been trimmed
    /// to `maxTypedFacts` suffix. `count == 0` means the input was empty (no-op).
    case accepted(count: Int)
    /// Reducer refused to record because at least one input fact was invalid.
    /// The window is unchanged; caller may raise, log, or record a diagnostic.
    /// `reason` is a stable machine-readable tag.
    case deniedContextInvalid(reason: String)
}

public struct DialogueState: Codable, Equatable, Sendable {
    public private(set) var turns: [DialogueTurn]
    public private(set) var focusEntity: String?
    public private(set) var lastReadback: DemoActionReadback?
    /// W7 P2 typed correlation window (D1 wire consumer target). Empty until
    /// `recordTypedFacts` accepts a batch. Kept parallel to `turns` — recording
    /// typed facts never mutates the legacy dialogue turns/readback path.
    ///
    /// 🔴 D1 wire is **opt-in**, not always-on production surface (grok-4.5
    /// D1/D2 short review P1-3 non-claim). The producer contract is:
    /// `DemoRuntimeSessionRunner.correlationProvider` is optional and defaults
    /// to `nil`; when `nil`, `consumeTypedFactsIfWired` early-exits and this
    /// window stays empty across every turn. D1's goal was to prove the
    /// typed-facts consumption contract (reducer API + fail-closed atomicity +
    /// runner call-site wire on both partial and normal paths) and to back it
    /// with deliberate-negative evidence — NOT to promise that every
    /// production runner records typed facts. Wiring a real correlation
    /// provider at the App composition layer is a follow-on RISK-ACK-W7 slice.
    /// Any downstream text that reads "typedFactsWindow always populated in
    /// production" is a false-green surface unless it also names the composed
    /// provider. See CLOSEOUT.md v2 §"P1 Fix Section" for the non-claim
    /// boundary the D1 wire dispatch operated under.
    public private(set) var typedFactsWindow: [RouteToDialogueCorrelation]
    public var maxTurns: Int
    /// Retention cap for `typedFactsWindow`. Mirrors `maxTurns` semantics: the
    /// last N are kept. Set independently to decouple from turn retention.
    public var maxTypedFacts: Int

    public init(
        turns: [DialogueTurn] = [],
        focusEntity: String? = nil,
        lastReadback: DemoActionReadback? = nil,
        typedFactsWindow: [RouteToDialogueCorrelation] = [],
        maxTurns: Int = 3,
        maxTypedFacts: Int = 8
    ) {
        self.turns = Array(turns.suffix(max(1, maxTurns)))
        self.focusEntity = focusEntity
        self.lastReadback = lastReadback
        self.maxTypedFacts = max(1, maxTypedFacts)
        self.typedFactsWindow = Array(typedFactsWindow.suffix(self.maxTypedFacts))
        self.maxTurns = max(1, maxTurns)
    }

    public mutating func recordUserText(_ text: String) {
        appendTurn(role: .user, text: text)
    }

    public mutating func recordAssistantText(_ text: String) {
        appendTurn(role: .assistant, text: text)
    }

    public mutating func recordReadbacks(_ readbacks: [DemoActionReadback]) {
        guard let latest = readbacks.last else { return }
        lastReadback = latest
        focusEntity = Self.entityName(forStateKey: latest.key)
    }

    public mutating func clearTransientContext() {
        focusEntity = nil
        lastReadback = nil
    }

    /// D1 wire entry point: consume W7 P2 typed correlations produced by the
    /// runtime session runner (or any producer holding both W6 route identity
    /// and W7 dialogue group identity). Fail-closed at reducer boundary — see
    /// `~/.claude/rules/claim-vs-reality-gap.md` 铁律 1 (enforce, not declare)
    /// and 铁律 2 (deliberate negatives required, not just fixture green).
    ///
    /// Semantics:
    ///   - empty input → `.accepted(count: 0)`, window unchanged (no-op).
    ///   - any input fact fails `DialogueRouteCorrelationValidator.validate` →
    ///     `.deniedContextInvalid(reason:)`; **no fact is appended** even if
    ///     other facts in the batch are individually valid (atomic).
    ///   - all facts valid → appended in order, window trimmed to `maxTypedFacts`.
    @discardableResult
    public mutating func recordTypedFacts(
        _ facts: [RouteToDialogueCorrelation]
    ) -> DialogueTypedFactsRecordResult {
        guard !facts.isEmpty else {
            return .accepted(count: 0)
        }
        for fact in facts {
            switch DialogueRouteCorrelationValidator.validate(fact) {
            case .success:
                continue
            case .failure(let error):
                return .deniedContextInvalid(reason: Self.reasonTag(for: error))
            }
        }
        typedFactsWindow.append(contentsOf: facts)
        if typedFactsWindow.count > maxTypedFacts {
            typedFactsWindow = Array(typedFactsWindow.suffix(maxTypedFacts))
        }
        return .accepted(count: facts.count)
    }

    private mutating func appendTurn(role: DialogueTurn.Role, text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        turns.append(DialogueTurn(role: role, text: trimmed))
        if turns.count > maxTurns {
            turns = Array(turns.suffix(maxTurns))
        }
    }

    private static func entityName(forStateKey key: String) -> String {
        key.split(separator: ".").first.map(String.init) ?? key
    }

    private static func reasonTag(for error: DialogueRouteCorrelationError) -> String {
        switch error {
        case .unsupportedSchemaVersion:
            return "unsupported_schema_version"
        case .missingRouteTurnID:
            return "missing_route_turn_id"
        case .missingRouteTraceID:
            return "missing_route_trace_id"
        case .routeAndCorrelationVersionMismatch:
            return "route_correlation_version_mismatch"
        case .dialogueGroupRefMissingIdentity:
            return "dialogue_group_ref_missing_identity"
        }
    }
}
