import Foundation

public struct FallbackOutcomeSummary: Codable, Equatable, Sendable {
    public let resultKind: FallbackResultKind
    public let safeReasonKind: FallbackSafeReasonKind

    public init(resultKind: FallbackResultKind, safeReasonKind: FallbackSafeReasonKind) {
        self.resultKind = resultKind
        self.safeReasonKind = safeReasonKind
    }
}

/// Presentation-safe fallback facts produced by Core.
/// Raw model output, raw tool names, ledger state, and finite runtime reasons do not belong here.
public struct FallbackContext: Codable, Equatable, Sendable {
    public let family: FallbackScriptFamily?
    public let reasonKind: FallbackGovernanceReason
    public let outcome: FallbackOutcomeSummary
    public let dialogText: String
    public let ttsText: String
    public let badgeLabel: String

    public static func resolve(
        family: FallbackScriptFamily?,
        reasonKind: FallbackGovernanceReason
    ) -> FallbackContext {
        if let family,
           let entry = FallbackScriptCatalog.entries.first(where: {
               $0.family == family && $0.reasonKind == reasonKind
           }) {
            return FallbackContext(entry: entry)
        }
        return FallbackContext.noRepresentative(reasonKind: reasonKind)
    }

    public static func resolve(userText: String?, finiteReason: String) -> FallbackContext {
        resolve(
            family: family(in: userText),
            reasonKind: governanceReason(for: finiteReason)
        )
    }

    public var runtimeResult: DemoRuntimeResult {
        switch outcome.resultKind {
        case .refusalSafetyOrPolicy:
            return .refusalSafetyOrPolicy
        case .clarifyMissingSlot:
            return .clarifyMissingSlot
        case .refusalNoAvailableTool:
            return .refusalNoAvailableTool
        }
    }

    private init(entry: FallbackScriptCatalogEntry) {
        family = entry.family
        reasonKind = entry.reasonKind
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
        reasonKind: FallbackGovernanceReason,
        outcome: FallbackOutcomeSummary,
        dialogText: String,
        ttsText: String,
        badgeLabel: String
    ) {
        self.family = family
        self.reasonKind = reasonKind
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
            reasonKind: reasonKind,
            outcome: FallbackOutcomeSummary(
                resultKind: resultKind,
                safeReasonKind: safeReasonKind
            ),
            dialogText: dialogText,
            ttsText: dialogText,
            badgeLabel: badgeLabel
        )
    }

    private static func governanceReason(for finiteReason: String) -> FallbackGovernanceReason {
        switch finiteReason {
        case "name_rejected":
            return .unmountedNameRejected
        case "fast_path_no_match":
            return .fastPathNoMatchFallback
        case "guard_denied", "safety_rejected", "clarify_required":
            return .safetyOrClarifyReject
        default:
            return .unknownNoRepresentativeEntry
        }
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
