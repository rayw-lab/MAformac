import Foundation

/// 三档动效降级预算（RSB §3.4）—— **纯值 SSOT，挂 `PresentationReducedMotionPolicy` 扩展，
/// 不散落到每个 View**。GPU/MLX 共存靠减负 + 测量，不幻想抢占（RSB §3.3/§5 红线）。
///
/// 🔴 三档语义（RSB §0 表）：
/// - `fullShowcase`(L0)：无训练 / 窗口稳定 —— demo 展示档，30fps，orb 72 / stage 138 / burst 250。
/// - `balancedDemo`(L1)：S8/MLX active 或 resize/thermal —— 默认共存档，orb 48 / stage 64 / burst 120，减大 blur/shadow。
/// - `trainSafeStatic`(L2)：MLX active + frame miss / 用户要训练优先 —— 训练优先档，orb 0-24 / stage 0 / burst 0，静态。
///   **L2 不是审美失败**（RSB §5.5）：是训练共存档，proof class = runtime/receipt policy，非 90 分展示档。
enum PresentationMotionBudgetLevel: String, CaseIterable, Codable, Sendable {
    case fullShowcase
    case balancedDemo
    case trainSafeStatic
}

/// 降级触发原因（RSB §3.3）。reduceMotion 是 accessibility，budget 是 runtime policy —— **两者独立**
/// （RSB §5.3：用户未开 reduceMotion 但 MLX active 时仍要降级）。
enum PresentationBudgetReason: String, CaseIterable, Codable, Sendable {
    case normal
    case mlxTrainingActive
    case resizeInProgress          // D0G-012：resize 暂停/降级非关键粒子
    case frameMiss
    case thermalOrMemoryWarning
    case reduceMotion
}

/// ContextCapsule 动效档（RSB §3.4）。
enum ContextCapsuleMotionMode: String, CaseIterable, Codable, Sendable {
    case animated       // L0：Vortex / 全动效
    case lowFPS         // L1：低帧 Canvas fallback
    case staticImage    // L2：强制静态 image
}

/// 粒子系统种类（budget 分别控制）。
enum MotionParticleKind: String, CaseIterable, Codable, Sendable {
    case orb
    case stage
    case burst
}

/// 单档动效预算快照（Codable → receipt 可落 `motion_budget_level` 等字段）。
struct PresentationMotionBudget: Codable, Equatable, Sendable {
    var level: PresentationMotionBudgetLevel
    var reason: PresentationBudgetReason
    var fps: Double
    var orbParticleCount: Int
    var stageParticleCount: Int
    var burstParticleCount: Int
    var contextCapsuleMode: ContextCapsuleMotionMode
    var allowLargeBlurAndShadow: Bool
    var allowBurstParticles: Bool
    var allowMeshAnimation: Bool

    /// 每帧间隔（秒）—— `TimelineView(.animation(minimumInterval:))` 消费。fps<=0 → 视为暂停（大间隔）。
    var frameInterval: Double {
        fps > 0 ? 1.0 / fps : 1.0
    }

    /// 是否暂停（L2 可 paused）。
    var isPaused: Bool { fps <= 0 }

    /// 按种类取有效粒子数。
    func particleCount(for kind: MotionParticleKind) -> Int {
        switch kind {
        case .orb: return orbParticleCount
        case .stage: return stageParticleCount
        case .burst: return burstParticleCount
        }
    }

    /// 三档预设值（RSB §3.4 建议值表）。
    static func preset(_ level: PresentationMotionBudgetLevel,
                       reason: PresentationBudgetReason = .normal) -> PresentationMotionBudget {
        switch level {
        case .fullShowcase:
            return PresentationMotionBudget(
                level: .fullShowcase, reason: reason,
                fps: 30,
                orbParticleCount: 72, stageParticleCount: 138, burstParticleCount: 250,
                contextCapsuleMode: .animated,
                allowLargeBlurAndShadow: true, allowBurstParticles: true, allowMeshAnimation: true)
        case .balancedDemo:
            return PresentationMotionBudget(
                level: .balancedDemo, reason: reason,
                fps: 30,
                orbParticleCount: 48, stageParticleCount: 64, burstParticleCount: 120,
                contextCapsuleMode: .lowFPS,
                allowLargeBlurAndShadow: false, allowBurstParticles: true, allowMeshAnimation: true)
        case .trainSafeStatic:
            return PresentationMotionBudget(
                level: .trainSafeStatic, reason: reason,
                fps: 15,
                orbParticleCount: 24, stageParticleCount: 0, burstParticleCount: 0,
                contextCapsuleMode: .staticImage,
                allowLargeBlurAndShadow: false, allowBurstParticles: false, allowMeshAnimation: false)
        }
    }

    /// receipt 六件（RSB §3.4 改造位 d1a-harness）。
    var receiptFields: [String: String] {
        [
            "motion_budget_level": level.rawValue,
            "budget_reason": reason.rawValue,
            "particle_count_effective": "orb=\(orbParticleCount);stage=\(stageParticleCount);burst=\(burstParticleCount)",
            "large_blur_shadow_disabled": (!allowLargeBlurAndShadow).description,
            "context_capsule_mode": contextCapsuleMode.rawValue,
            "fps_target": String(format: "%.0f", fps)
        ]
    }
}

enum MotionBudgetLaunchArgumentSelector {
    static let flag = "-motionBudget"

    static func requestedBudget(arguments: [String]) -> PresentationMotionBudget {
        .preset(requestedLevel(arguments: arguments))
    }

    static func requestedLevel(arguments: [String]) -> PresentationMotionBudgetLevel {
        guard let rawValue = value(after: flag, in: arguments) else {
            return .fullShowcase
        }
        switch rawValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "full":
            return .fullShowcase
        case "balanced":
            return .balancedDemo
        case "static":
            return .trainSafeStatic
        default:
            return .fullShowcase
        }
    }

    private static func value(after flag: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: flag), index + 1 < arguments.count else {
            return nil
        }
        return arguments[index + 1]
    }
}

/// budget 决议：把 reduceMotion（accessibility）+ runtime reason 合成有效档（RSB §3.3/§5.3）。
extension PresentationReducedMotionPolicy {
    /// reduceMotion 开 → 强制 `trainSafeStatic`（无循环、静态，保语义可读）；
    /// 否则用 runtime 请求档。**reduceMotion 与 GPU budget 独立**：任一要降级都降到更保守档。
    static func effectiveBudget(reduceMotion: Bool,
                                requested: PresentationMotionBudget) -> PresentationMotionBudget {
        if reduceMotion {
            return .preset(.trainSafeStatic, reason: .reduceMotion)
        }
        return requested
    }

    /// budget 感知的连续动画开关（D0G-002：RM 停循环；L2 静态也停）。
    static func allowsContinuousAnimation(reduceMotion: Bool,
                                          budget: PresentationMotionBudget) -> Bool {
        if reduceMotion { return false }
        return budget.level != .trainSafeStatic
    }

    /// budget 感知的粒子数（0 = 不画）。
    static func particleCount(kind: MotionParticleKind,
                              reduceMotion: Bool,
                              budget: PresentationMotionBudget) -> Int {
        effectiveBudget(reduceMotion: reduceMotion, requested: budget).particleCount(for: kind)
    }

    /// budget 感知的帧间隔。
    static func frameInterval(reduceMotion: Bool,
                              budget: PresentationMotionBudget) -> Double {
        effectiveBudget(reduceMotion: reduceMotion, requested: budget).frameInterval
    }
}
