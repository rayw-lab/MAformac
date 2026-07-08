import XCTest
@testable import MAformacCore

/// D1a T7 —— 动效预算三档 + 招牌微交互时长 SSOT 单测（RSB §3.4 / teardown §5-6 / D-126）。
///
/// 纯值放 Core，故 `swift test` 可断言三档映射、reduceMotion 覆盖、≤240ms 上限不变量，
/// 不需模拟器。App 层 Canvas/SwiftUI 渲染消费这些值（Xcode 编译验证）。
final class MotionBudgetAndTimingsTests: XCTestCase {

    // MARK: RS-B1 —— 三档预算映射（§3.4 表）

    func testFullShowcasePresetMatchesTable() {
        let b = PresentationMotionBudget.preset(.fullShowcase)
        XCTAssertEqual(b.fps, 30)
        XCTAssertEqual(b.orbParticleCount, 72)
        XCTAssertEqual(b.stageParticleCount, 138)
        XCTAssertEqual(b.burstParticleCount, 250)
        XCTAssertEqual(b.contextCapsuleMode, .animated)
        XCTAssertTrue(b.allowLargeBlurAndShadow)
        XCTAssertTrue(b.allowBurstParticles)
    }

    func testBalancedDemoPresetMatchesTable() {
        let b = PresentationMotionBudget.preset(.balancedDemo)
        XCTAssertEqual(b.orbParticleCount, 48)
        XCTAssertEqual(b.stageParticleCount, 64)
        XCTAssertEqual(b.burstParticleCount, 120)
        XCTAssertEqual(b.contextCapsuleMode, .lowFPS)
        XCTAssertFalse(b.allowLargeBlurAndShadow, "L1 减少大 blur/shadow")
        XCTAssertTrue(b.allowBurstParticles)
    }

    func testTrainSafeStaticPresetMatchesTable() {
        let b = PresentationMotionBudget.preset(.trainSafeStatic)
        XCTAssertEqual(b.fps, 15)
        XCTAssertEqual(b.orbParticleCount, 24)
        XCTAssertEqual(b.stageParticleCount, 0)
        XCTAssertEqual(b.burstParticleCount, 0)
        XCTAssertEqual(b.contextCapsuleMode, .staticImage)
        XCTAssertFalse(b.allowLargeBlurAndShadow)
        XCTAssertFalse(b.allowBurstParticles, "L2 禁 burst 粒子")
        XCTAssertFalse(b.allowMeshAnimation)
    }

    func testParticleCountMonotonicDegrade() {
        // 降档时各类粒子数单调不增（L0 ≥ L1 ≥ L2）。
        let l0 = PresentationMotionBudget.preset(.fullShowcase)
        let l1 = PresentationMotionBudget.preset(.balancedDemo)
        let l2 = PresentationMotionBudget.preset(.trainSafeStatic)
        for kind in MotionParticleKind.allCases {
            XCTAssertGreaterThanOrEqual(l0.particleCount(for: kind), l1.particleCount(for: kind), "\(kind) L0≥L1")
            XCTAssertGreaterThanOrEqual(l1.particleCount(for: kind), l2.particleCount(for: kind), "\(kind) L1≥L2")
        }
    }

    // MARK: reduceMotion 覆盖（§5.3：与 GPU budget 独立，任一降级都降到最保守）

    func testReduceMotionForcesTrainSafeStatic() {
        // 即便请求 fullShowcase，reduceMotion 开 → 强制 trainSafeStatic + reason=reduceMotion。
        let requested = PresentationMotionBudget.preset(.fullShowcase)
        let effective = PresentationReducedMotionPolicy.effectiveBudget(reduceMotion: true, requested: requested)
        XCTAssertEqual(effective.level, .trainSafeStatic)
        XCTAssertEqual(effective.reason, .reduceMotion)
        // reduceMotion 关 → 透传请求档。
        let passthrough = PresentationReducedMotionPolicy.effectiveBudget(reduceMotion: false, requested: requested)
        XCTAssertEqual(passthrough.level, .fullShowcase)
    }

    func testAllowsContinuousAnimationRespectsReduceMotionAndBudget() {
        let full = PresentationMotionBudget.preset(.fullShowcase)
        let safe = PresentationMotionBudget.preset(.trainSafeStatic)
        // D0G-002：RM 停循环
        XCTAssertFalse(PresentationReducedMotionPolicy.allowsContinuousAnimation(reduceMotion: true, budget: full))
        // L2 静态也停
        XCTAssertFalse(PresentationReducedMotionPolicy.allowsContinuousAnimation(reduceMotion: false, budget: safe))
        // L0 无 RM → 允许
        XCTAssertTrue(PresentationReducedMotionPolicy.allowsContinuousAnimation(reduceMotion: false, budget: full))
    }

    func testParticleCountViaPolicyReduceMotionZeroesStageAndBurst() {
        let full = PresentationMotionBudget.preset(.fullShowcase)
        // reduceMotion → 有效档 trainSafeStatic：stage/burst = 0
        XCTAssertEqual(PresentationReducedMotionPolicy.particleCount(kind: .stage, reduceMotion: true, budget: full), 0)
        XCTAssertEqual(PresentationReducedMotionPolicy.particleCount(kind: .burst, reduceMotion: true, budget: full), 0)
    }

    func testFrameIntervalFromFPS() {
        XCTAssertEqual(PresentationMotionBudget.preset(.fullShowcase).frameInterval, 1.0/30.0, accuracy: 1e-9)
        XCTAssertEqual(PresentationMotionBudget.preset(.trainSafeStatic).frameInterval, 1.0/15.0, accuracy: 1e-9)
    }

    func testReceiptFieldsPresent() {
        let fields = PresentationMotionBudget.preset(.balancedDemo).receiptFields
        for key in ["motion_budget_level", "budget_reason", "particle_count_effective",
                    "large_blur_shadow_disabled", "context_capsule_mode", "fps_target"] {
            XCTAssertNotNil(fields[key], "receipt 缺字段 \(key)")
        }
        XCTAssertEqual(fields["motion_budget_level"], "balancedDemo")
        XCTAssertEqual(fields["large_blur_shadow_disabled"], "true")
    }

    // MARK: teardown §6 —— ≤240ms 重复上限 / hero 420ms 例外

    func testRepeatedInteractionsWithin240ms() {
        // 重复微交互总时长 ≤ 240ms（value scroll / fallback / MicDock）。
        XCTAssertLessThanOrEqual(MotionTimings.ValueScroll.totalMS, MotionTimings.maxRepeatedDurationMS)
        XCTAssertLessThanOrEqual(MotionTimings.Fallback.totalMS, MotionTimings.maxRepeatedDurationMS)
        XCTAssertLessThanOrEqual(MotionTimings.MicDock.totalMS, MotionTimings.maxRepeatedDurationMS)
        XCTAssertLessThanOrEqual(MotionTimings.ValueScroll.bigJumpRollMS, MotionTimings.maxRepeatedDurationMS)
    }

    func testHeroAndOpenerWithin420msButOver240() {
        // 招牌 hero / 开场瀑布：> 240（招牌感）但 ≤ 420（上限）。
        XCTAssertGreaterThan(MotionTimings.EnergyLine.totalMS, MotionTimings.maxRepeatedDurationMS)
        XCTAssertLessThanOrEqual(MotionTimings.EnergyLine.totalMS, MotionTimings.heroMaxDurationMS)
        XCTAssertTrue(MotionTimings.EnergyLine.isHero)
        XCTAssertLessThanOrEqual(MotionTimings.Waterfall.totalMS, MotionTimings.heroMaxDurationMS)
        XCTAssertTrue(MotionTimings.Waterfall.isOpener)
    }

    // MARK: 招牌参数不变量

    func testWaterfallDelayCapsAt120() {
        XCTAssertEqual(MotionTimings.Waterfall.cardDelayMS(index: 0), 0)
        XCTAssertEqual(MotionTimings.Waterfall.cardDelayMS(index: 5), 90)   // 5*18
        XCTAssertEqual(MotionTimings.Waterfall.cardDelayMS(index: 9), 120)  // 9*18=162 → cap 120
        XCTAssertEqual(MotionTimings.Waterfall.cardDelayMS(index: 20), 120) // 封顶
    }

    func testValueScrollBigJumpThreshold() {
        XCTAssertFalse(MotionTimings.ValueScroll.usesRollingSteps(delta: 5))
        XCTAssertFalse(MotionTimings.ValueScroll.usesRollingSteps(delta: 10))
        XCTAssertTrue(MotionTimings.ValueScroll.usesRollingSteps(delta: 11))
        XCTAssertTrue(MotionTimings.ValueScroll.usesRollingSteps(delta: -30))
        XCTAssertEqual(MotionTimings.ValueScroll.bigJumpRollSteps, 3)
    }

    func testEnergyLineSingleCanvasLayerAndCurve() {
        XCTAssertTrue(MotionTimings.EnergyLine.rendersInSingleCanvasLayer, "招牌①禁 per-pixel SwiftUI layout")
        XCTAssertEqual(MotionTimings.EnergyLine.lineCurve, .cubic(0.16, 1, 0.3, 1))
    }

    func testMicDockWaveParams() {
        XCTAssertEqual(MotionTimings.MicDock.waveBarCount, 3)
        XCTAssertEqual(MotionTimings.MicDock.wavePhaseOffsetsMS, [0, 80, 160])
        XCTAssertEqual(MotionTimings.MicDock.waveAmplitudeCapPT, 24)
        XCTAssertTrue(MotionTimings.MicDock.rendersInCanvas)
    }
}
