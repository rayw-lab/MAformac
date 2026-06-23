---
type: pre-mortem-research
status: 综合报告（二手派生综合；一手见 oracle-findings.md）
date: 2026-06-24
topic: 锁 iOS26 + macOS26 demo 目标版本 + Phase 3 D7 视觉消费
owner: UIUE 链路A（worktree uiue/visual-ssot-state-consume）
method: pre-mortem skill（scout 本机 + oracle 4 路 CC subagent 联网搜证，不派 Codex/GPT Pro）
oracle_agents:
  - oracle1 Liquid Glass 官方边界（agentId ad3b5d8134b9d8a50, 14 tool_uses, 7 WebSearch+4 WebFetch+1 curl）
  - oracle2 SwiftUI API 引入版本（agentId a00368a613b1fb4f0, 9 tool_uses, 7 WebSearch+1 WebFetch）
  - oracle3 Xcode26 SPM deployment bug（agentId a22b9ec67faba9ea9, 9 tool_uses, 5 WebSearch+3 WebFetch）
  - oracle4 iOS26 稳定性+截图管线（agentId a2c1cbdf77fd7df63, 10 tool_uses, 8 WebSearch）
note: 一手 full return 见 oracle-findings.md（保 source URL+日期）。本 README = 综合判断，驱动 spec/design/tasks/tokens/hig 级联 + Phase 3 D7。
---

# Pre-Mortem：锁 iOS26 + Phase 3 D7（综合报告）

> 触发：磊哥拍「demo 锁 iOS26+macOS26」（A 方案）+ 给 3 处加强（带 cite）+ 打 `/pre-mortem`。本机 = macOS 26 Tahoe（Darwin 25.6.0）+ iPhone iOS26 + Xcode 26.5。
> 核心：辩证 check 磊哥 3 加强（不盲吸收）+ 搜 iOS26/D7 坑。**A 方向稳，带 3 refinement + 1 HIGH。**

## 一、磊哥 3 加强核验（cite-verified）

### 加强 1 — Liquid Glass 边界 = CONFIRMED 实质 / PARTIAL 措辞
- **Apple 官方 verbatim**（oracle1 curl `developer.apple.com/.../materials.json` HTTP200 坐实）：
  - *"Liquid Glass forms a distinct functional layer for controls and navigation elements — like tab bars and sidebars — that floats above the content layer..."*
  - *"**Don't use Liquid Glass in the content layer.** ... use standard materials for elements in the content layer, such as app backgrounds."*
  - *例外*：*"An exception... for controls in the content layer with a transient interactive element like sliders and toggles; ... the element takes on a Liquid Glass appearance to emphasize its interactivity when a person activates it."*
  - *"Use Liquid Glass effects sparingly... Limit these effects to the most important functional elements."*
- 🔴 **refinement 1**：磊哥引的 "exclusively / best reserved for" 是**社区措辞（conorluddy）非 Apple 逐字原话**。spec/hig 要用 Apple verbatim，标社区措辞为我方工程表述（防伪官方引文固化，elephant）。
- 🎁 **利好（磊哥没提）**：Apple 官方**唯一例外 = transient 交互控件（slider/toggle）激活时可用 glass** → 正好车控 demo 的温度滑块/风量 toggle。「调节控件激活态用 glass」是 Apple 点名正确用法，写进 spec。

### 加强 2 — SwiftUI API 版本 = 完全正确，2 处纠正
oracle2 Apple 官方文档 URL 坐实：

| API | iOS | macOS | 锁 iOS26+macOS26 后 |
|---|---|---|---|
| MeshGradient | 18 | 15 | 无需 `#available` |
| `.glassEffect()`/GlassEffectContainer | **26** | **26** | 无需 `#available` |
| matchedGeometryEffect | 14 | 11 | 无需 |
| Gauge.accessoryCircular | 16 | 13 | 无需 |
| navigationTransition(.zoom) | 18 | **unavailable** | **需平台守卫 `#if !os(macOS)`**（非版本守卫） |

- 🔴 **refinement 2（我自己的错）**：已 commit 的 `spec.md:102/117` 把 **glassEffect 误归 iOS18**，实际 iOS26 → 级联改。
- 🔴 **refinement 3（磊哥符号方向）**：zoom 守卫磊哥写 `#if os(macOS)`，正解 **`#if !os(macOS)`**（macOS 无此类型 = 平台缺失非版本落后，"非 macOS 才编译"）。

### 加强 3 — Core/App deployment 隔离 = paper-tiger（方案安全）
- oracle3：Swift forums **thread 81601 真实存在但零回复孤帖（2025-08-11，未确认 bug/未 fixed）**，且讲 **unified-build 编译期 deprecation 警告，非「Package.swift 声明被抬高导致 import 炸」**（SE-0236 明文：编译策略不改 platforms 声明/不改 API 可用性）。
- → **磊哥「Package.swift 留 v17 + 只提 App target v26」隔离安全**，CLI/A2 import Core 不炸（paper-tiger）。唯一真影响 = v26 graph 编 Core 可能冒 deprecation 警告（tiger，默认不阻断）。
- 🔴 **elephant**：真正挡构建的是 **toolchain 错配 + warnings-as-errors**（swift#84379 / spm#9517）→ **别在 Core 的 Package.swift 塞全局 warnings-as-errors**。
- 核验命令：`xcodebuild -showBuildSettings -scheme MAformacCore | grep DEPLOYMENT_TARGET`（期望 Core=17/App=26）。

## 二、🔴 HIGH（pre-mortem catch，改变 5-gate 验收方法）

**ImageRenderer 截不出 Liquid Glass / material / blur**（Apple 官方：Core Animation 合成内容不进 raster，oracle4 坐实）→ 用 ImageRenderer/snapshot 做 5-gate 截图 = 假绿（撞飞书白皮书「看自己导出图≠用户实查」同根因）。

- **唯一稳路 = `simctl` 启动整 app 后截图**（截真实合成画面，Liquid Glass 在）。但「态导航」（开到 7 态各截）是无人值守 70% 工作量（elephant）。
- **⭐ 解法（绕态导航）**：`#if DEBUG` 「7 态 gallery」视图（一屏并列 7 态卡片）→ simctl 启动后**一张含全 7 态**（×2 端 = 2 张，非 14 张）。
- 待磊哥拍（①）：gallery ⭐ vs 14 张逐态。

## 三、其他 tigers（awareness，mitigation 已知）

| tiger | 威胁 | mitigation | 来源 |
|---|---|---|---|
| TabBar release iPhone17 启动 SIGABRT | 原生 tab 才中 | demo 不用复杂 tab 可避 | rn-screens#3940 |
| glass-on-glass 采样错乱 | 堆叠 glass 不一致 | 必包 `GlassEffectContainer` | WWDC25 #323 |
| Clear glass 默认可读性差 | 投屏看不清 | 设备设 Tinted + 核心读数绝不放 glass 上（=U2 content_glow） | iOS26.1 加 Tinted / NN-g |
| Tahoe 可读性塌陷 | macOS 窗口标题看不清 | 浅色高对比 + 逐张核 | mjtsai 2025-12-29 |
| ImageRenderer @Observable 渲染 | 缺环境崩 | re-inject `.environment(model)`+@MainActor+displayScale（但仍截不出 glass，故弃用此路） | Apple forums 726757 |

## 四、级联待执行清单（砍 fallback 锁 iOS26，按加强2 三 axis 分类）

| 文件:行 | 现状（过期） | 改为 |
|---|---|---|
| spec.md:102/117/120 | iOS18 API（含 glassEffect）+ iOS17 fallback | glassEffect=iOS26；锁 iOS26 无需 `#available`；zoom 用 `#if !os(macOS)` |
| spec.md:130/138/141 | 动效/glass `#available` 双通道降级 | 保留 ReduceMotion/低电量双通道（a11y 非版本）；砍版本 fallback 措辞 |
| design.md:40 | API 版本门 + iOS17 fallback | glassEffect=iOS26 + 锁 iOS26 无需 `#available` + zoom 平台守卫 |
| tasks.md:2.3/3.5 | Availability.swift（iOS18 #available 封装） | 锁 iOS26 后版本守卫不需要；只留平台守卫(zoom)+ReduceMotion |
| tokens.md:92 | control_glass「iOS18 .glassEffect()+iOS17 fallback」 | glassEffect=iOS26，锁 iOS26 无 fallback |
| hig-liquid-glass-rules.md | 「部署 iOS17/macOS14... iOS18+ 必 #available+iOS17 fallback」全过期 | 大改：锁 iOS26、砍版本 fallback、加 Apple verbatim 4 段 + transient 例外 |

**三 axis 分类（砍 fallback 不一锅端）**：版本差（iOS17/18）→ 砍；平台差（zoom macOS unavailable）→ `#if !os(macOS)` 留；a11y（ReduceMotion/低电量）→ 留（非版本）。

## 五、待磊哥拍（思考中）

- ① 截图方案：⭐ `#if DEBUG` 7 态 gallery + simctl（一张含全 7 态）vs 14 张逐态。
- ② 加强2/3 的 2 个 pre-commit 脚本（check-platform-vs-version-guard / check-core-deployment-isolation）：建 vs demo 轻治理先不建只留 spike 命令。

## 六、关键 source（一手见 oracle-findings.md）
- Apple HIG Materials（Liquid Glass verbatim）：https://developer.apple.com/design/human-interface-guidelines/materials
- WWDC25 #323：https://developer.apple.com/videos/play/wwdc2025/323/
- MeshGradient：https://developer.apple.com/documentation/swiftui/meshgradient ｜ glassEffectContainer：https://developer.apple.com/documentation/swiftui/glasseffectcontainer
- Swift forums 81601：https://forums.swift.org/t/minimum-deployment-target-being-ignored-for-swiftpm-packages-in-xcode-26/81601（2025-08-11）
- SE-0236：https://github.com/swiftlang/swift-evolution/blob/main/proposals/0236-package-manager-platform-deployment-settings.md
- ImageRenderer 限制：https://developer.apple.com/documentation/swiftui/imagerenderer ｜ swift-snapshot-testing#1058
- NN/g Liquid Glass Is Cracked（2025-10-10）：https://www.nngroup.com/articles/liquid-glass/

## 七、引用规范防呆（elephant 防固化伪官方引文，磊哥 2026-06-24 拍）

> 防的坑：28 次 WebSearch + curl 坐实的 Apple verbatim 是**事实层弹药**；若把**社区转述当 Apple 官方原话**固化进 spec/design/hig，下游（LLM/工程师）会拿伪官方引文做权威依据（撞「不编造」铁律 + claim-vs-reality 段间分叉）。

1. 🔴 **写 spec/design/hig 引「Apple 官方 Liquid Glass 边界」时，必引 `oracle-findings.md 节1` 的 Apple verbatim 4 段**（带 `materials.json` URL），**严禁**用社区措辞 "exclusively / best reserved for" 冒充 Apple 原话。Apple 原话是 "floats above the content layer" + "Don't use Liquid Glass in the content layer"。
2. 社区措辞（conorluddy 等）可用，但**必须标为「我方工程表述」**，与 Apple verbatim 分列，不混。
3. **lint 候选（防呆）**：`grep -rE 'exclusively|best reserved for' docs/design/` 命中 → 人工审是不是在冒充 Apple 原话（是 → 改 verbatim 或标社区来源）。
4. 利好别漏：Apple 官方**唯一例外** = transient 交互控件（slider/toggle）激活时可用 glass（车控温度滑块/风量 toggle），写 spec 时带上（是正确用法非违规）。

