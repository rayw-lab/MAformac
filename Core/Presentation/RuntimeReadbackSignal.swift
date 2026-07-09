import Foundation

/// 招牌① 能量线的 **runtime 事件缝**（T5RuntimePresentation readback 流 → UIUE 能量线）。
///
/// 语义：识别完成（command-accepted）→ T5 `.runtime(snapshot:readbackID:)` 发出 readback 事件
/// → 从 readback 命中 cell / activeCells 派生目标卡 → 能量线从 orb 射向该卡。
struct RuntimeReadbackSignal: Equatable, Sendable {
    /// readback 标识（对齐 T5 `readbackID`）。
    var readbackID: String
    /// 命中的目标卡 family id（能量线终点）；空 = 无明确目标（不触发能量线）。
    var targetFamilyID: String

    /// stub 注入（demo / 单测用；T5 merge 后由 runtime readback 驱动）。
    static func stub(readbackID: String, target targetFamilyID: String) -> RuntimeReadbackSignal {
        RuntimeReadbackSignal(readbackID: readbackID, targetFamilyID: targetFamilyID)
    }

    /// T7d 接缝：只从 T5 runtime event 派生；force-state / idle 不触发。
    static func from(event: T5PresentationEvent) -> RuntimeReadbackSignal? {
        guard event.source == .runtime,
              let readbackID = event.readbackID,
              !readbackID.isEmpty,
              let targetFamilyID = targetFamilyID(in: event.snapshot)
        else { return nil }

        return RuntimeReadbackSignal(readbackID: readbackID, targetFamilyID: targetFamilyID)
    }

    private static func targetFamilyID(in snapshot: StagePresentationSnapshot) -> String? {
        if let readbackKey = snapshot.readbacks.last?.key {
            if let family = snapshot.activeCells.first(where: { $0.value == readbackKey })?.key {
                return family.rawValue
            }
            if let family = FamilyCardIDMapper.familyCardID(forBase: ScopedStateKey(readbackKey).base) {
                return family.rawValue
            }
        }

        for family in FamilyCardID.displayOrder {
            if let activeCell = snapshot.activeCells[family], !activeCell.isEmpty {
                return family.rawValue
            }
        }
        return nil
    }
}

/// readback signal → 能量线触发路由（纯值，可测）。
enum RuntimeReadbackSignalRouter {
    /// 是否触发招牌① 能量线（有非空目标卡才触发）。
    static func shouldFireEnergyLine(_ signal: RuntimeReadbackSignal?) -> Bool {
        guard let signal else { return false }
        return !signal.targetFamilyID.isEmpty
    }

    /// 能量线终点目标卡 family id（无则 nil）。
    static func targetFamily(_ signal: RuntimeReadbackSignal?) -> String? {
        guard let signal, !signal.targetFamilyID.isEmpty else { return nil }
        return signal.targetFamilyID
    }
}
