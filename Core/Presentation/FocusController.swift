import Foundation
import Observation

/// 单点聚焦控制器（AD-4：`MAX_CONCURRENT_EXPANSIONS=1` 单点展开，防同时多卡抢视觉）。
///
/// 触发聚焦展开（4b，AD-12 §五）：点族卡 → `focusedFamily` = 该族 → ContentView ZStack overlay 渲展开卡；
/// 再点空白/dismiss → nil 回全景。单值即单点聚焦（不并发多展开）。
@Observable
final class FocusController {
    /// 当前聚焦展开的族（nil = 无展开，grid 全景常驻）。
    var focusedFamily: FamilyCardID?

    func expand(_ family: FamilyCardID) {
        focusedFamily = family
    }

    func dismiss() {
        focusedFamily = nil
    }

    /// toggle：再点同族收起（点已展开族 = dismiss），点别族切换。
    func toggle(_ family: FamilyCardID) {
        focusedFamily = (focusedFamily == family) ? nil : family
    }
}
