import Foundation

/// 招牌微交互 + 基础动效的**时长 / 曲线 SSOT**（纯值，swift test 可断言参数与上限不变量）。
///
/// 参数源 = `showcase-microinteraction-teardown.md §5` + dispatch D-126 拍定内联。
/// App 层的 Canvas / SwiftUI 渲染只从此取时长/曲线，**禁在 view 里手填 ms/曲线**（token=floor 同源纪律）。
///
/// 🔴 横切上限（teardown §6 guardrail）：**重复微交互 ≤ 240ms**；仅开场瀑布 / hero 招牌可用 300-420ms。
/// 动画只动 `transform / opacity`，禁 layout 动画（premeasured frame）。

/// 动效曲线（纯值；App 映射成 SwiftUI `Animation`）。
enum MotionCurve: Equatable, Sendable {
    case cubic(Double, Double, Double, Double)
    case spring(response: Double, damping: Double)
    case easeOut(durationMS: Double)
    case easeIn(durationMS: Double)
}

enum MotionTimings {
    /// 重复微交互硬上限（ms）。
    static let maxRepeatedDurationMS: Double = 240
    /// hero / 开场招牌上限（ms）。
    static let heroMaxDurationMS: Double = 420

    // MARK: 招牌① orb → 卡片能量流动线（D-126 拍①；teardown §5.1）

    enum EnergyLine {
        static let orbGlowMS: Double = 90               // 0-90 orb glow scale 1→1.08 +0.18 opacity
        static let orbGlowScale: Double = 1.08
        static let lineTrimStartMS: Double = 70         // 70-260 line trim 0→1, blur 10→2
        static let lineTrimEndMS: Double = 260
        static let cardPulseStartMS: Double = 210       // 210-340 target card ring pulse 0→.22→0
        static let cardPulseEndMS: Double = 340
        static let cardPulseDurationMS: Double = 100    // pulse 100ms
        static let lineCurve: MotionCurve = .cubic(0.16, 1, 0.3, 1)
        static let cardPulseCurve: MotionCurve = .easeOut(durationMS: 100)
        /// 招牌 hero moment（总 340ms，> 240 允许，≤ 420 hero 上限内）。
        static let totalMS: Double = 340
        static let isHero: Bool = true
        /// 单 Canvas/ShapeLayer 层实现，禁 per-pixel SwiftUI layout（dispatch 硬规则）。
        static let rendersInSingleCanvasLayer: Bool = true
    }

    // MARK: 招牌② 10 卡入场瀑布（D-126 拍②；teardown §5.2）

    enum Waterfall {
        static let perCardStaggerMS: Double = 18
        static let staggerCapMS: Double = 120           // delay = min(i*18, 120)
        static let cardSpringMS: Double = 180
        static let cardSpring: MotionCurve = .spring(response: 0.28, damping: 0.9)
        static let cardStartTranslateY: Double = 8      // translateY 8→0
        static let cardStartScale: Double = 0.985       // scale .985→1
        static let contentAtOpacityFraction: Double = 0.70  // icon/value 在卡 70% opacity 时入场
        static let contentFadeMS: Double = 80
        static let reduceMotionFadeMS: Double = 100     // RM 降级 = 单次 100ms fade
        /// 卡 i 的入场延迟（ms），封顶 120。
        static func cardDelayMS(index: Int) -> Double {
            min(Double(index) * perCardStaggerMS, staggerCapMS)
        }
        /// 最后一张卡总时长 = 延迟封顶 120 + spring 180 = 300ms（开场，允许 300-420）。
        static let totalMS: Double = 300
        static let isOpener: Bool = true
    }

    // MARK: 基础 · 数值滚动确认（teardown §5.3）

    enum ValueScroll {
        static let oldOutTranslateY: Double = -8        // old y 0→-8
        static let oldOutMS: Double = 90
        static let newInStartMS: Double = 40            // new 起 40ms
        static let newInTranslateY: Double = 8          // new y 8→0
        static let newInMS: Double = 120
        static let borderPulseMS: Double = 100
        static let bigJumpThresholdUnits: Int = 10      // >10 单位
        static let bigJumpRollSteps: Int = 3            // 3 步滚
        static let bigJumpRollMS: Double = 220          // 封顶 220
        /// 常规总时长 = 起 40 + 120 = 160ms（≤ 240）。
        static let totalMS: Double = 160
        /// 值跳变是否走 3 步滚动。
        static func usesRollingSteps(delta: Int) -> Bool { abs(delta) > bigJumpThresholdUnits }
    }

    // MARK: 基础 · fallback 不丢脸卡（teardown §5.4）

    enum Fallback {
        static let tintFadeStartMS: Double = 0          // 0-80 tint
        static let tintFadeEndMS: Double = 80
        static let badgeSlideStartMS: Double = 40       // 40-160 badge 滑入 x -4→0
        static let badgeSlideEndMS: Double = 160
        static let badgeStartTranslateX: Double = -4
        static let chipStartMS: Double = 120            // 120-240 建议 chip（无执行按钮）
        static let chipEndMS: Double = 240
        /// safety 变体：红只在相关卡，无全局红洗（D0G-001 红只给 unsafe）。
        static let safetyRedScopedToCardOnly: Bool = true
        /// 总时长 = 240ms（正好 ≤ 240 上限）。
        static let totalMS: Double = 240
    }

    // MARK: 基础 · MicDock 拾起（teardown §5.5）

    enum MicDock {
        static let pressScale: Double = 1.035           // press scale 1→1.035
        static let pressGlowOpacity: Double = 0.16      // glow 0→.16
        static let pressMS: Double = 80
        static let waveBarCount: Int = 3                // 三柱波形
        static let wavePhaseOffsetsMS: [Double] = [0, 80, 160]  // phase 0/80/160ms
        static let waveAmplitudeCapPT: Double = 24      // 振幅随输入电平，cap 24px
        static let cancelHueShiftMS: Double = 120       // drag-out glow→amber
        static let releaseSpringMS: Double = 180        // release outside 回弹
        /// 拾起总时长 = 80ms（≤ 240）。
        static let totalMS: Double = 80
        /// 波形 Canvas 实现（非重复 SwiftUI stack）；RM = static level meter。
        static let rendersInCanvas: Bool = true
    }
}
