import Foundation

/// 招牌① 能量线的 **runtime 事件缝**（对齐 T5RuntimePresentation 的 readback 流形态）。
///
/// 🔴 T5 未 merge 留缝（T7 从 T1 切）：本类型对齐 `T5PresentationEvent.runtime(snapshot:readbackID:)`
/// 的 readback 语义（`readbackID` + 命中目标），作为**当前 stub 注入点**。T5 合并后由
/// `T5PresentationEvent(source:.runtime, readbackID:)` 驱动，`targetFamilyID` 从 readback 命中卡派生。
///
/// 语义：识别完成（command-accepted）→ 发 signal（readbackID + 目标卡）→ 能量线从 orb 射向该卡。
struct RuntimeReadbackSignal: Equatable, Sendable {
    /// readback 标识（对齐 T5 `readbackID`）。
    var readbackID: String
    /// 命中的目标卡 family id（能量线终点）；空 = 无明确目标（不触发能量线）。
    var targetFamilyID: String

    /// stub 注入（demo / 单测用；T5 merge 后由 runtime readback 驱动）。
    static func stub(readbackID: String, target targetFamilyID: String) -> RuntimeReadbackSignal {
        RuntimeReadbackSignal(readbackID: readbackID, targetFamilyID: targetFamilyID)
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
