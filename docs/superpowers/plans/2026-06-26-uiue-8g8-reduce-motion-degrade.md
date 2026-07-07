# UIUE 8.G8 Reduce Motion 降级实施计划

日期：2026-06-26
仓库：`/Users/wanglei/workspace/MAformac-uiue`
分支：`uiue/phase4-default-scope-presentation`
任务范围：仅 8.G8
目标证明等级（proof class）：`local` + `unit`；可补 `simulator` 证据，但不得声明 `mobile` / `true_device` / `V-PASS`

## 目标

完成 8.G8：Reduce Motion 降级路径（U35）。

必须做到：

1. 粒子、氛围灯、orb、卡片呼吸/脉冲在 Reduce Motion 下有静态降级，不继续依赖连续动画表达状态。
2. 禁动效态仍能读出状态：颜色、数值、图标、文案至少双通道可见。
3. orb `think` 在 Reduce Motion 下有静态“在思考/正在确认”反馈，不靠粒子或呼吸动效证明。
4. 加机械化测试锁住 motion policy，避免后续又把未知动效静默放行。
5. 只勾选 `8.G8`，不提前关闭 `8.G9`，不声明 L3/V-PASS。

## STEP 0：文档级联前置

先做文档级联判断，再写代码。不要把这步省掉。

读取并核对：

- `/Users/wanglei/workspace/MAformac-uiue/docs/handoffs/2026-06-26-uiue-visual-gate-grill-closeout-3in1-change.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/GRILL-SYSTEM.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-visual-gate-harden-grill-decisions.md`
- `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/design.md`
- `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/specs/ui-presentation/spec.md`
- `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/tasks.md`

级联规则：

- 如果实现只是在现有 U35/AD-15 口径下补代码和测试，只更新 `tasks.md` 勾选 `8.G8`，并在最终 verdict 写“文档级联核对：无需改 spec/design”。
- 如果实现发现 U35 需要更精确契约，例如新增“Reduce Motion SHALL static feedback”之类硬约束，则必须同步改 `spec.md` 或 `design.md`，再跑 `openspec validate ui-presentation --strict`。
- 不要重写旧 receipt、旧 visual evidence 目录或研究归档；只改 load-bearing 文档。
- 文档和最终 verdict 必须中文。

## 当前代码锚点

现状不是空白，但未闭合：

- `App/ContentView.swift:1013` / `1025`：`DemoOrbView` 已读 `accessibilityReduceMotion`，但仍走 `TimelineView`，只是把 `phase` 固定为 0。
- `App/ContentView.swift:1113`：orb caption 已有 `think -> "让我确认下..."`，需要把 Reduce Motion 下的静态思考反馈纳入可测 policy。
- `App/ContentView.swift:1198` / `1205`：`StageAtmosphereLayer` 已读 Reduce Motion，但仍用 `TimelineView` 包 Canvas。
- `App/ContentView.swift:1559` / `2082`：`VehicleStateCard` 已在 `updateBreathe()` 对 Reduce Motion 关呼吸，但 `isHero`、value 动画等仍需核。
- `App/ContentView.swift:991` / `1001`：`WaveformMark` 有 `repeatForever`，还没有 Reduce Motion 降级入口。
- `App/AmbientEdgeBurst.swift:15`：`AmbientEdgeBurst` 当前没有 `accessibilityReduceMotion`。
- `App/AmbientEdgeBurst.swift:50`：`PhaseAnimator` 仍会跑边缘 burst。
- `App/AmbientEdgeBurst.swift:217` / `223`：`TimedAmbientEdgeGlow` 用 `TimelineView`。
- `App/AmbientEdgeBurst.swift:324` / `330`：`AmbientParticleCanvas` 用 `TimelineView`，Reduce Motion 下应禁粒子或改静态光晕。
- `Core/Presentation/DemoRuntimeResultPresentationMatrix.swift:3`：`PresentationMotionKind` 已是 8.G2 的 motion 契约入口，可复用来加 reduced-motion policy 测试。

## 允许范围

允许修改：

- `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/`
- `/Users/wanglei/workspace/MAformac-uiue/App/ContentView.swift`
- `/Users/wanglei/workspace/MAformac-uiue/App/AmbientEdgeBurst.swift`
- `/Users/wanglei/workspace/MAformac-uiue/App/ContextCapsule.swift`
- `/Users/wanglei/workspace/MAformac-uiue/Tests/MAformacCoreTests/`
- `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/tasks.md`
- 必要时：`openspec/changes/ui-presentation/design.md` 或 `specs/ui-presentation/spec.md`

## 禁止范围

禁止：

- 不做 8.G9。
- 不接真 NLU / ASR / TTS / LoRA / runtime backend。
- 不碰 `contracts/`、`generated/`、Xcode project、真机配置、客户物料。
- 不改视觉证据旧目录，不新增 L0/L3 acceptance package。
- 不把 Reduce Motion 做成“关掉所有状态表达”。降级后状态仍必须能读。
- 不声明 `V-PASS`、`mobile`、`true_device`。

## 实施步骤

### Step 1：加 reduced-motion policy 契约

优先在 Core 层加一个小型、可测试的 policy，不要只把逻辑散在 SwiftUI View 里。

建议新增：

- `Core/Presentation/PresentationReducedMotionPolicy.swift`

建议形状：

- `enum PresentationReducedMotionFeedback`
  - `staticState`
  - `staticThinking`
  - `staticWarning`
  - `staticError`
- `struct PresentationReducedMotionPolicy`
  - `static func feedback(for orbState: PresentationOrbState) -> PresentationReducedMotionFeedback`
  - `static func feedback(for motionKind: PresentationMotionKind) -> PresentationReducedMotionFeedback`
  - `static func allowsContinuousAnimation(reduceMotion: Bool) -> Bool`
  - `static func allowsParticles(reduceMotion: Bool) -> Bool`

要求：

- `PresentationOrbState.think` 在 reduced motion 下必须映射到 `staticThinking`。
- `PresentationMotionKind.allCases` 必须全覆盖，无 `default`。
- 8 态矩阵里的每个 `motionKind` 都能拿到 reduced-motion feedback。

### Step 2：补测试

新增或扩展测试文件：

- `Tests/MAformacCoreTests/PresentationReducedMotionPolicyTests.swift`

至少覆盖：

1. `PresentationOrbState.allCases` 每态都有静态反馈。
2. `.think` 返回 `staticThinking`。
3. `PresentationMotionKind.allCases` 每态都有 reduced-motion feedback。
4. `DemoRuntimeResultPresentationMatrix.allEntries` 的 motionKind 全部可降级。
5. `allowsContinuousAnimation(reduceMotion: true) == false`。
6. `allowsParticles(reduceMotion: true) == false`。

### Step 3：App 层接入 Reduce Motion

最小接入，不做大重构。

建议做法：

- `DemoOrbView`
  - Reduce Motion 下不渲染 `OrbParticleField`，不依赖 pulse 传达状态。
  - `think` 下保留静态 caption，例如“正在确认...”或“让我确认下...”，且 accessibility label 能读出。
- `StageAtmosphereLayer`
  - Reduce Motion 下禁连续粒子/漂移；可保留静态渐变、静态边缘 sheen。
  - 如仍使用 Canvas，必须 phase 固定且不高频调度；更优是分支成静态 view。
- `ContextCapsuleView`
  - 现有 Vortex 在 reduceMotion 下已走 canvas 分支，但要核 Canvas 是否仍动态。必要时让 rain/smoke/star/headlight 在 reduceMotion 下固定 phase 且不高频 Timeline。
- `AmbientEdgeBurst`
  - 读取 `@Environment(\.accessibilityReduceMotion)`。
  - Reduce Motion 下禁 `AmbientParticleCanvas`。
  - Reduce Motion 下不要跑 `PhaseAnimator` 多段爆发；改成静态边缘 glow，保留颜色反馈和短时显示，再按原 duration 清理 trigger。
- `WaveformMark`
  - 加 `reduceMotion` 参数或环境读取。
  - Reduce Motion 下不使用 `repeatForever`，改固定柱形。
- `VehicleStateCard`
  - 已有 `updateBreathe()` guard，仍要核 `.animation(.snappy...)` 是否需要 reduced motion 下变成 nil/短 opacity。若改动过大，先保留结构变化动画，确保呼吸/脉冲关掉，并在 verdict 写 residual。

### Step 4：任务勾选

实现和测试通过后，只改：

- `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/tasks.md`

把 `8.G8` 勾选为完成。不要勾 `8.G9`。

若 STEP 0 判定需要 spec/design 级联，则同步更新，并在 verdict 单独列出。

## 验证命令

必须跑：

```bash
swift test --filter PresentationReducedMotionPolicyTests
swift test --filter DemoRuntimeResultPresentationMatrixTests
swift test
make verify-all
openspec validate ui-presentation --strict
git diff --check
```

建议补充：

```bash
rg -n "repeatForever|TimelineView|PhaseAnimator|VortexView|AmbientParticleCanvas|OrbParticleField|accessibilityReduceMotion|reduceMotion" App Core Tests
```

解释扫描结果，不要求零匹配；要求说明哪些匹配在 Reduce Motion 下已被关停或降级。

## 提交要求

只提交 8.G8 允许范围内文件。不要 `git add .`。

建议提交信息：

```bash
git commit -m "feat(uiue): 补齐Reduce Motion静态降级"
```

## 停止条件

遇到以下情况停下并报 `PARTIAL`：

- 需要改 Xcode project、contracts、generated 才能闭合。
- 发现 Reduce Motion 真实行为必须靠 simulator screenshot 或人工 5-gate 才能判断，但本轮没有证据。
- App 层改动会牵连 8.G9 的 Mac AnyLayout、XCUITest、触觉或客户物料。
- 只能通过删除视觉状态表达来“通过” Reduce Motion。

## 最终 verdict 格式

必须中文，格式：

```text
verdict: DONE | PARTIAL | BLOCKED
commit sha:
changed files:
validation:
proof class:
文档级联:
residual risks:
exact remaining 8.G tasks:
```

不得声明 runtime/mobile/true-device/V-PASS。L3 人工 5-gate 仍只能由磊哥签。
