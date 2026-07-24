import SwiftUI

/// Core `MotionCurve`（纯值 SSOT）→ SwiftUI `Animation` 映射桥。
///
/// 🔴 view 里禁手填时长/曲线，只经此从 `MotionTimings` / `MotionCurve` 取（token=floor 同源纪律）。
/// 招牌/基础动效的 ms/曲线全部单源自 `Core/Presentation/MotionTimings.swift`。
extension MotionCurve {
    /// 转 SwiftUI `Animation`（时长参数已内含于曲线值）。
    var swiftUIAnimation: Animation {
        switch self {
        case let .cubic(c0, c1, c2, c3):
            // cubic 曲线时长由调用方 `.duration(...)` 决定；此处给单位曲线，默认 0.24s。
            return .timingCurve(c0, c1, c2, c3, duration: 0.24)
        case let .spring(response, damping):
            return .spring(response: response, dampingFraction: damping)
        case let .easeOut(durationMS):
            return .easeOut(duration: durationMS / 1000.0)
        case let .easeIn(durationMS):
            return .easeIn(duration: durationMS / 1000.0)
        }
    }

    /// cubic 曲线 + 指定时长（ms）。
    func cubicAnimation(durationMS: Double) -> Animation {
        if case let .cubic(c0, c1, c2, c3) = self {
            return .timingCurve(c0, c1, c2, c3, duration: durationMS / 1000.0)
        }
        return swiftUIAnimation
    }
}

enum MotionAnimationFactory {
    /// ms → 秒。
    static func seconds(_ ms: Double) -> Double { ms / 1000.0 }

    /// reduceMotion 守卫：RM 时返回 nil（无动画），否则返回给定动画（D0G-002 统一守卫）。
    static func guarded(_ animation: Animation, reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : animation
    }
}
