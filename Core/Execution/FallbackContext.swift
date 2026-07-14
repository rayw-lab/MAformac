import Foundation

public struct FallbackOutcomeSummary: Codable, Equatable, Sendable {
    public let resultKind: FallbackResultKind
    public let safeReasonKind: FallbackSafeReasonKind

    public init(resultKind: FallbackResultKind, safeReasonKind: FallbackSafeReasonKind) {
        self.resultKind = resultKind
        self.safeReasonKind = safeReasonKind
    }
}

/// Finite disposition for the context-aware completion-phrase hard gate (AD-7 / S5).
/// Scans only reject/clarify/safety/unsupported/unmounted/cancel-like error outcomes.
/// Does not blanket-scan badge labels, accepted, alreadyDone, or partial accept/refuse.
public enum FallbackCompletionPhraseGateDisposition: String, Codable, Equatable, Sendable {
    /// Outcome family is outside the TTS hard-gate scan surface.
    case notInScope = "not_in_scope"
    /// In-scope error speech contains no forbidden completion phrase.
    case pass
    /// In-scope error speech contains a forbidden completion phrase.
    case fail
}

/// Context-aware completion-phrase hard gate for FallbackContext error speech.
public enum FallbackCompletionPhraseGate {
    /// Forbidden whole-phrase completion promises for error-state dialog/tts only.
    public static let forbiddenCompletionPhrases: [String] = [
        "已完成",
        "已设置成功",
        "设置成功",
        "操作成功",
        "执行成功",
        "已成功",
        "已为您完成",
        "控制成功",
    ]

    /// Evaluate a fully resolved FallbackContext (badgeLabel is never scanned).
    public static func evaluate(_ context: FallbackContext) -> FallbackCompletionPhraseGateDisposition {
        evaluate(
            resultKind: context.outcome.resultKind,
            safeReasonKind: context.outcome.safeReasonKind,
            dialogText: context.dialogText,
            ttsText: context.ttsText
        )
    }

    /// Typed, testable evaluation surface: disposition is finite, not regex-only.
    public static func evaluate(
        resultKind: FallbackResultKind,
        safeReasonKind: FallbackSafeReasonKind,
        dialogText: String,
        ttsText: String
    ) -> FallbackCompletionPhraseGateDisposition {
        guard isErrorOutcomeInScope(resultKind: resultKind, safeReasonKind: safeReasonKind) else {
            return .notInScope
        }
        if containsForbiddenCompletionPhrase(dialogText) || containsForbiddenCompletionPhrase(ttsText) {
            return .fail
        }
        return .pass
    }

    /// reject / clarify / safety / unsupported / unmounted / cancel-like only.
    public static func isErrorOutcomeInScope(
        resultKind: FallbackResultKind,
        safeReasonKind: FallbackSafeReasonKind
    ) -> Bool {
        // Explicit exclusions from the product-operator TTS hard gate.
        if safeReasonKind == .alreadyDone {
            return false
        }
        switch resultKind {
        case .acceptedToolCall, .alreadyStateNoop, .partialAcceptPartialRefuse, .interrupted:
            return false
        case .clarifyMissingSlot, .refusalNoAvailableTool, .refusalSafetyOrPolicy, .cancelled, .runtimeError:
            return true
        }
    }

    public static func containsForbiddenCompletionPhrase(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        return forbiddenCompletionPhrases.contains { trimmed.contains($0) }
    }
}

/// Presentation-safe fallback facts produced by Core.
/// Raw model output, raw tool names, ledger state, and finite runtime reasons do not belong here.
public struct FallbackContext: Codable, Equatable, Sendable {
    public let family: FallbackScriptFamily?
    public let outcome: FallbackOutcomeSummary
    public let dialogText: String
    public let ttsText: String
    public let badgeLabel: String

    static func resolve(
        family: FallbackScriptFamily?,
        reasonKind: FallbackGovernanceReason
    ) -> FallbackContext {
        if let family,
           let entry = FallbackScriptCatalog.entry(
               for: family,
               governanceReason: reasonKind
           ) {
            return FallbackContext(entry: entry)
        }
        return FallbackContext.noRepresentative(reasonKind: reasonKind)
    }

    static func resolve(userText: String?, finiteReason: RuntimeFiniteReason) -> FallbackContext {
        let resolvedFamily = family(in: userText)
        let projection = RuntimePresentationReasonAuthority.projection(for: finiteReason)
        let governanceReason = RuntimePresentationReasonAuthority.fallbackBucket(for: finiteReason)
        if let resolvedFamily,
           let governanceReason,
           let entry = FallbackScriptCatalog.entry(
               for: resolvedFamily,
               governanceReason: governanceReason
           ),
           entry.safeReasonKind == projection.safeReasonKind,
           entry.resultKind == projection.result {
            return FallbackContext(entry: entry)
        }
        if let governanceReason {
            let fallback = FallbackContext.noRepresentative(reasonKind: governanceReason)
            if fallback.outcome.safeReasonKind == projection.safeReasonKind,
               fallback.outcome.resultKind == projection.result {
                return fallback
            }
        }
        return FallbackContext.noRepresentative(
            family: resolvedFamily,
            projection: projection
        )
    }

    public var runtimeResult: DemoRuntimeResult {
        outcome.resultKind
    }

    /// Context-aware TTS hard-gate disposition for this fallback speech surface.
    public var completionPhraseGateDisposition: FallbackCompletionPhraseGateDisposition {
        FallbackCompletionPhraseGate.evaluate(self)
    }

    private init(entry: FallbackScriptCatalogEntry) {
        family = entry.family
        outcome = FallbackOutcomeSummary(
            resultKind: entry.resultKind,
            safeReasonKind: entry.safeReasonKind
        )
        dialogText = entry.dialogText
        ttsText = entry.ttsText
        badgeLabel = entry.badgeLabel
    }

    private init(
        family: FallbackScriptFamily?,
        outcome: FallbackOutcomeSummary,
        dialogText: String,
        ttsText: String,
        badgeLabel: String
    ) {
        self.family = family
        self.outcome = outcome
        self.dialogText = dialogText
        self.ttsText = ttsText
        self.badgeLabel = badgeLabel
    }

    private static func noRepresentative(reasonKind: FallbackGovernanceReason) -> FallbackContext {
        let safeReasonKind: FallbackSafeReasonKind
        let resultKind: FallbackResultKind
        let dialogText: String
        let badgeLabel: String

        switch reasonKind {
        case .safetyOrClarifyReject:
            safeReasonKind = .clarificationRequired
            resultKind = .clarifyMissingSlot
            dialogText = "需要确认具体能力后我再执行，当前状态保持不变。"
            badgeLabel = "需确认"
        case .unmountedNameRejected:
            safeReasonKind = .capabilityNotMounted
            resultKind = .refusalNoAvailableTool
            dialogText = "这项能力暂未接入演示版，我先保持当前状态。"
            badgeLabel = "暂未接入"
        case .fastPathNoMatchFallback:
            safeReasonKind = .notAvailableInDemo
            resultKind = .refusalNoAvailableTool
            dialogText = "这个说法还没稳稳接住，请换个车控说法再试。"
            badgeLabel = "换个说法"
        case .unknownNoRepresentativeEntry:
            safeReasonKind = .notAvailableInDemo
            resultKind = .refusalNoAvailableTool
            dialogText = "这项能力不在本轮演示范围，我先保持原样。"
            badgeLabel = "不在范围"
        }

        return FallbackContext(
            family: nil,
            outcome: FallbackOutcomeSummary(
                resultKind: resultKind,
                safeReasonKind: safeReasonKind
            ),
            dialogText: dialogText,
            ttsText: dialogText,
            badgeLabel: badgeLabel
        )
    }

    private static func noRepresentative(
        family: FallbackScriptFamily?,
        projection: RuntimePresentationReasonProjection
    ) -> FallbackContext {
        let dialogText: String
        let badgeLabel: String
        switch projection.safeReasonKind {
        case .safetyPolicy:
            dialogText = "当前状态下不能执行这项操作，车辆状态保持不变。"
            badgeLabel = "安全限制"
        case .clarificationRequired:
            dialogText = "还需要确认具体信息，当前状态保持不变。"
            badgeLabel = "需确认"
        case .capabilityNotMounted:
            dialogText = "这项能力暂未接入演示版，我先保持当前状态。"
            badgeLabel = "暂未接入"
        case .notAvailableInDemo:
            dialogText = "这项能力不在本轮演示范围，我先保持原样。"
            badgeLabel = "不在范围"
        case .runtimeUnavailable:
            dialogText = "当前运行状态不可用，请稍后重试。"
            badgeLabel = "暂不可用"
        case .alreadyDone:
            dialogText = "当前已经是目标状态，无需重复操作。"
            badgeLabel = "已完成"
        }
        return FallbackContext(
            family: family,
            outcome: FallbackOutcomeSummary(
                resultKind: projection.result,
                safeReasonKind: projection.safeReasonKind
            ),
            dialogText: dialogText,
            ttsText: dialogText,
            badgeLabel: badgeLabel
        )
    }

    private static func family(in userText: String?) -> FallbackScriptFamily? {
        guard let userText else { return nil }
        let text = userText.lowercased()
        let mappings: [(FallbackScriptFamily, [String])] = [
            (.sunroofShade, ["sunroof_shade", "sunroof shade", "遮阳帘", "天窗"]),
            (.ambient, ["ambient_light", "ambient light", "氛围灯"]),
            (.fragrance, ["fragrance", "香氛"]),
            (.wiper, ["wiper", "雨刷", "雨刮"]),
            (.screen, ["screen", "中控屏", "屏幕"]),
            (.volume, ["volume", "音量", "音乐", "歌曲", "首歌"]),
            (.window, ["window", "车窗", "窗户"]),
            (.door, ["door", "车门", "尾门", "后备箱"]),
            (.seat, ["seat", "座椅"]),
            (.ac, ["air_conditioner", "air conditioner", "空调", "温度"]),
        ]
        return mappings.first { _, aliases in aliases.contains { text.contains($0) } }?.0
    }
}
