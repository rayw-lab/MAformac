---
snapshot: true
source: UIUE视觉验收门联网增强建议
date: 2026-06-26 15:16
---

磊哥，ClaudeCode 这组意见**方向对，但还不够工程化**。我联网补了视觉回归、感知 diff、iOS snapshot、Apple HIG/WCAG、车载 HMI 可读性资料后，建议把它加强成一个**“三层视觉验收门 + 一进两出 runtime 接线 + negative-space 矩阵 + 长跑 stop-rule”**的可执行方案。

下面是我的增强版。

---

## 0. 先判 ClaudeCode 方案

### 我同意的部分

ClaudeCode 的核心判断成立：

1. **RMSE 不能做审美硬门**
   纯像素比较容易噪声大、误杀抗锯齿/材质/动态差异，也会诱导 v39→v72 这种局部微调死循环。

2. **Phase 2 的真 gate 应该回到 5-gate + runtime proof**
   也就是：布局不崩、状态语义正确、遮挡/层级正确、投屏可读、人工审美。

3. **proof class 必须继续分层**
   simulator/mock 不能升 true_device / product V-PASS。

4. **long-run 治理要变成硬 stop-rule**
   “两轮无新 proof class 就停”这个方向非常对。

### 我认为还不够的地方

ClaudeCode 的建议仍有三个不足：

1. **“感知级 diff”没定义清楚**
   不能只说感知级 diff，要明确用什么：SSIM / ODiff / LPIPS / OCR / object-level layout，各自干什么、不干什么。

2. **“5-gate”还缺可执行评分表**
   现在是原则，不是门。需要每个 gate 有 PASS/FAIL 条件、证据来源、owner、截图/脚本路径。

3. **“一进两出 runtime 接线”还要防 fake-green**
   一进两出要写成可验证 contract：同一 runtime snapshot 输入，同时派生视觉状态与语音/VUI 输出；禁止 UI 和话术各自重算。

---

## 1. 联网证据摘要

### 1.1 视觉 diff：Exact pixel / RMSE 不推荐作普通验证

Applitools 文档明确说 **Exact pixel-to-pixel** 对人眼不可见的渲染异常也敏感，**不推荐 ordinary verification**；它们推荐按区域/目的使用 Strict / Layout / Ignore Colors / Dynamic / Floating regions。
来源：Applitools Match Levels and Regions。

关键启发：
- Exact/RMSE = 只适合低层回归报警。
- Layout = 验结构。
- Strict = 验人眼可见的文本/字体/颜色/位置。
- Dynamic/Ignore/Floating regions = 处理动态内容、局部位移、时间/粒子等。

### 1.2 SSIM 是感知结构指标，但不能替代审美

SSIM 是 perception-based metric，比较亮度、对比度、结构，比 PSNR/RMSE 更接近人眼。
但它仍是 full-reference image quality metric，不懂产品语义，不懂“这个 UI 更高级”。

所以：
- SSIM 适合作为 **结构/质感 regression sentinel**。
- 不适合作为“审美分数”。

### 1.3 LPIPS 更接近人类感知，但对 UI 不一定稳

LPIPS 是 learned perceptual similarity，用深度特征对齐人类感知。它适合图像生成/照片/复杂视觉质量评估。
但 UI 场景有风险：
- 小文字、细线、按钮可点击性不一定被 LPIPS 正确权重。
- 依赖 Python/PyTorch，项目里“Python 库零进 iOS”，但离线验收脚本可以用；不能进 App target。
- 对设计系统 regression 可能过宽。

建议：
- LPIPS 可作为 **research-only / optional 人眼近似指标**。
- 不进入 hard gate。

### 1.4 iOS snapshot testing 可补组件级回归，但不适合 Liquid Glass 最终验收

`pointfreeco/swift-snapshot-testing` 支持 Swift 任意值/任意格式 snapshot，可测 UIView/UIViewController/UIImage/CALayer，也支持 trait collections、content size categories。
但它有警告：snapshot 必须用同一 simulator 生成/比较，否则图像会有差异。

结合 MAformac：
- 组件级 SwiftUI snapshot 可以测 `ValueControlView`、`DemoControlPanel`、状态卡渲染。
- 但 `ImageRenderer` / unit snapshot 很难完整捕捉 Liquid Glass / material / Core Animation 合成。你们之前已踩过这个坑。
- 最终 visual gate 仍应以 `simctl` full-app runtime 截图为准。

### 1.5 可读性：WCAG + 车载 HMI 要更严

WCAG 2.2 SC 1.4.3：
- normal text ≥ **4.5:1**
- large text ≥ **3:1**
- 不允许把 4.499 四舍五入成 4.5。

车载 HMI 资料：
- ISO 15008 是车载动态显示可读性/图像质量的标准。
- 有研究显示车载中文文本可读性随字号增加改善，约 **7mm 中文字符高度**达到更优表现。
- 汽车 UI 字体设计会影响 glance time；humanist typeface 可降低总 glance time。

对 UIUE 的启发：
- 投屏 V10 不应只看手机截图，要有“远看/投屏/缩放后”可读性 gate。
- 中文文字膨胀、长文案截断、低对比玻璃背景，是 Phase 2 negative space 里最该加的维度。

---

## 2. 我建议的加强版：三层视觉验收门

不要一个 `phase2_zone_compare.py` 包打天下。改成三层：

```text
L0 runtime truth
  ↓
L1 mechanical visual sentinel
  ↓
L2 semantic / perceptual visual gates
  ↓
L3 human 5-gate / projection review
```

### L0：Runtime truth gate

目的：先证明截图不是假图、状态不是假态。

每张截图必须绑定：

| 字段 | 要求 |
|---|---|
| device | iPhone 17 Pro Max simulator / macOS |
| launch args | `-mockSnapshot cooling` / etc |
| theme | ivory / deepSpace |
| snapshot traceId | 若可读，写入 receipt |
| UI tree evidence | 关键 accessibility id 存在 |
| screenshot path | 明确 |
| proof class | runtime/simulator |

**没 L0，就不许进入视觉评分。**

---

### L1：Mechanical sentinel，不再叫 hard visual score

现有 `phase2_zone_compare.py` 保留，但换职责：

| 指标 | 用途 | 是否 hard gate |
|---|---|---|
| RMSE / AE | 明显塌陷报警 | 只做 fail-fast，不做审美分 |
| crop/zone diff | 定位风险区域 | 辅助 |
| masked dynamic region | 排除粒子/capsule/数值滚动 | 必须 |
| status bar normalization | 排噪 | 必须 |

**核心规则：**
- RMSE 只问：有没有比 anchor 明显差到塌？
- 不问：有没有更接近 anchor。
- 一旦通过 sentinel，不再允许为了 RMSE 小数点继续调。

建议新命名：
- 旧：`phase2_zone_compare.py`
- 新概念：`phase2_visual_sentinel.py`

输出不要写：
```text
score = 0.17, better/worse
```

改写：
```text
sentinel = PASS / WARN / FAIL
reason = controls zone major drift / no major collapse
```

---

### L2：Perceptual + semantic gates

这一层比 ClaudeCode 更强。分 5 个 gate：

| Gate | 检查什么 | 自动化建议 |
|---|---|---|
| Layout gate | 四 zone 位置、面积、主锚点是否正确 | 关键区域 bbox / crop + SSIM / object-region rules |
| Semantic state gate | cooling/heating/refusal 是否视觉语义正确 | UI tree + color/token sampling + resultKind |
| Occlusion gate | mic dock、文字、控制区是否被遮挡 | OCR 或 accessibility tree + bbox overlap |
| Motion gate | 动效是否存在且不挡操作 | 录屏抽帧 + frame diff / duration |
| Projection readability gate | 投屏/远看是否可读 | 缩放 50% / blur / contrast / OCR pass |

#### L2 指标组合建议

| 指标 | 适用 | 不适用 |
|---|---|---|
| ODiff / pixelmatch | 快速截图 diff，抗锯齿略友好 | 审美判断 |
| SSIM | 结构/布局/质感相似 | UI 语义 |
| OCR | 文字是否可读/截断/压图 | 视觉高级感 |
| WCAG contrast | 文本可读性 | 玻璃质感 |
| LPIPS | research-only 人眼近似 | hard gate |
| UI tree | 状态/控件存在 | 视觉层级 |

我的建议：**短期别上 LPIPS**。它会引入 PyTorch 依赖，收益不确定。先用：
- `ODiff` 或现有 PIL diff：快速 sentinel
- `SSIM`：结构指标
- `OCR/accessibility tree`：文字可读/存在
- `WCAG contrast sampler`：可读性硬门
- 人工 5-gate：审美门

---

### L3：Human 5-gate / projection review

这一层是最终 visual acceptance。你的系统里已有 5 gate，我建议具体化为评分表：

| Gate | PASS 条件 | FAIL 例子 |
|---|---|---|
| 视觉层级 | 0.5 秒一眼看出主元素、次元素、辅助元素 | 卡片/对话/orb/mic 权重相同 |
| 空间/对齐 | 四 zone 边界稳定，主视线自然，8pt grid 基本一致 | 黄框大空白、红框压对话区 |
| 遮挡安全 | 文字/按钮/温度滑块不被粒子/玻璃/胶囊遮挡 | 粒子盖住数值、mic dock 糊末行 |
| 字体可读 | 手机截图 + 50% 缩放 + 投屏模拟均可读 | 待命/范围/温度单位太细或太粗 |
| 视觉重量 | 主卡权重大于次级 ≥1.5x，装饰不抢主内容 | 氛围/粒子比 AC 主值更重 |

**最终结论只能人工给：**
- `V-PASS`
- `V-PASS_WITH_NOTES`
- `PARTIAL`
- `FAIL`

脚本只提供 evidence，不替你拍审美。

---

## 3. “一进两出” runtime 接线范式：我建议写得更硬

ClaudeCode 说“一进两出”，我建议定义成：

```text
RuntimeEvent / PresentationSnapshot
        ↓
  PresentationAdapter
        ↓
 ┌──────────────────────────┬──────────────────────────┐
 │ VisualPresentationModel  │ VerbalPresentationModel  │
 │ 卡片/颜色/动效/层级       │ 话术/静默/确认/拒识/追问   │
 └──────────────────────────┴──────────────────────────┘
        ↓                          ↓
     SwiftUI                    Dialogue/TTS Mock
```

### 关键约束

1. **同一个输入 snapshot** 同时派生 visual 和 VUI。
   禁止 UI 用一套状态、话术再自己读 store 重算一套。

2. **一进：**
   - `PresentationSnapshot`
   - `DemoRuntimeResultKind`
   - `DemoVehicleStateCell`
   - `DemoContext`
   - `proofClass`

3. **两出：**
   - `VisualPresentationModel`
   - `VerbalPresentationModel`

4. **派生层必须穷尽枚举，无 default 吞态。**

---

## 4. VUI 呈现矩阵：建议比 ClaudeCode 版本再细一层

新增一张 “runtime result → visual + verbal + motion + silence” 表：

| Runtime result | 话术 | 视觉态 | 氛围/动效 | 是否 TTS | proof |
|---|---|---|---|---|---|
| acceptedToolCall | “已为您调到 26℃” | satisfied/changing | 数值滚动 + 卡片 glow | 是 | mock/sim |
| alreadyStateNoop | “当前已经是 26℃” | normal + subtle pulse | 轻反馈 | 可选 | mock/sim |
| clarifyMissingSlot | “您是指主驾还是全车？” | clarify amber | 无爆发 | 是 | mock/sim |
| refusalSafetyOrPolicy | “行驶中不建议打开…” | safety red | 安全边框，不炸场 | 是 | mock/sim |
| refusalNoAvailableTool | “这个功能暂不支持” | unsupported gray lock | 无 | 是 | mock/sim |
| runtimeError | “刚才没执行成功” | error neutral | 无 | 是 | mock/sim |
| cancelled | “已取消” | normal/fade | 无 | 可选 | mock/sim |
| partialAcceptPartialRefuse | “空调已调，车窗保持关闭” | mixed | 局部反馈 | 是 | mock/sim |

**这张表是防 fake-green 的核心。**
否则 Phase 2 视觉在动，runtime 语义不一定跟着对。

---

## 5. Negative-space 矩阵：建议扩成 9 维

ClaudeCode 提到投屏/i18n/a11y，我建议加成 9 维：

| 维度 | 为什么重要 | Gate |
|---|---|---|
| 投屏可读 | 客户现场不是贴脸看手机 | 50% 缩放 + blur 后主值可读 |
| 中文文字膨胀 | “当前 26℃，已升到 28℃”可能爆行 | 30 字 truncate / lineLimit |
| 多语言膨胀 | 25+ 语言业务现实，德语/阿语更长 | pseudo-localization |
| RTL | 阿语/希伯来方向 | 不阻塞 A-2，但列 deferred |
| Dynamic Type | iOS 可读性 | 至少 `.large` 不炸 |
| Reduce Motion | Apple/HIG | 粒子/phaseAnimator 有降级 |
| Contrast | WCAG | normal 4.5:1 / large 3:1 |
| Color-blind | 红/绿/蓝不能单独传义 | 图标/文案/形状冗余 |
| Motion sickness | 车载场景更敏感 | 动效不遮挡、不长时间闪烁 |

---

## 6. 长跑治理：我建议加一个更硬的 “Proof-Class Budget”

ClaudeCode 的 stop-rule 很好，但可以更工程化。

### 6.1 每个 action 必须声明 proof-class delta

每 10 个工具点后，不只问：
> 当前动作是在推进 goal，还是局部打磨？

要改成三问：

1. **本轮新增了什么 proof class？**
   - none / local / unit / simulator / mobile / true_device / human V-gate
2. **哪个 open gate 被推进？**
   - 8.A / 8.C2 / SD18 / V10 / etc
3. **如果答案是 none，为什么不停止？**

如果连续两轮：
```text
proof_class_delta = none
```
就强制 closeout，不继续微调。

### 6.2 视觉内循环 token/time budget

建议写成：

| 条件 | 动作 |
|---|---|
| 2 轮截图+diff 无 proof-class 增量 | stop local polish |
| 3 个 visual variants 被 reject | 写 rejected-moves ledger |
| 单 turn >180k tokens | compact / receipt first |
| 总 token >230M 或 compaction ≥3 | phase checkpoint commit |
| build+simctl+diff 循环 >3 次 | 必须人工/外部审美 review |
| drag automation失败一次且缺 idb | 降级 operator-pass pending |

---

## 7. UI 操作证据串行链：ClaudeCode 对，但我补完整模板

每个 runtime proof 都按这个顺序，不并行：

```text
1. build/install/launch
2. set status_bar / deterministic env
3. wait readiness / get app state
4. snapshot UI tree BEFORE
5. perform action tap/drag/launchArg
6. snapshot UI tree AFTER
7. screenshot / recording
8. run visual sentinel
9. write receipt with proof_class
```

receipt 必须写：
```text
proof_class: runtime/simulator
not_claimed: true_device, product V-PASS, live ASR/TTS
action_path: tap -> state mutation -> snapshot refresh -> visual/dialogue update
```

---

## 8. 我建议最终 grill 拍板项

你可以让 ClaudeCode grill 前按下面 7 条拍板，不要开放式发散：

### G1：RMSE 降级
`phase2_zone_compare.py` 保留，但改名/改语义为 **visual sentinel**。
结论只输出 PASS/WARN/FAIL，不输出“越低越好”的审美分。

### G2：新增 L2 多指标门
Phase 2 visual gate =
`runtime truth + sentinel + semantic/perceptual gates + human 5-gate`。
SSIM/OCR/contrast/UI tree 进 gate；LPIPS 仅 research optional。

### G3：人工 5-gate 是唯一审美终裁
脚本不能给 V-PASS，只能提供证据。V-PASS 必须人工读图/投屏 review。

### G4：一进两出 runtime 接线
同一个 `PresentationSnapshot` 同时派生 visual + verbal。禁止 UI/话术分叉重算。

### G5：VUI 呈现矩阵落文档
确认/澄清/拒识/安全拒绝/partial/noop/error 都要对应话术、视觉态、氛围/动效、是否静默、proof class。

### G6：negative-space 9 维入 coverage index
投屏、i18n、a11y、contrast、motion、Dynamic Type、RTL、color-blind、文字截断。

### G7：long-run proof-class budget
两轮无新 proof class / 3 个 variant reject / drag tooling 缺失 / token 超阈值 → stop local polish，写 receipt。

---

## 9. 我的最终建议

ClaudeCode 的建议可以采纳，但要**升级为门控规范**，否则还是会变成“又一份理念文档”。

我建议下一步不是继续做 UI，而是起一个**小型 docs-only grill change**：

```text
change: harden-uiue-visual-acceptance-gates
scope:
  - phase2_zone_compare.py 语义降级说明
  - visual acceptance gate matrix
  - VUI runtime 一进两出矩阵
  - coverage index 新列：state/motion/proof class/negative-space
  - long-run proof-class budget
non-goal:
  - 不改 Swift/UI
  - 不跑新视觉探索
  - 不关闭 8.A/8.C2
```

这会真正“解 Phase 2 视觉门开口”：不是把 Phase 2 做完，而是把**以后怎么做完**定义清楚，避免下一个 agent 再烧 14 小时追 RMSE。
