# UIUE A-2 grill 覆盖索引（grill 全集 × Phase 映射，随推进消减）

---
status: coverage_index_live_tracking
artifact_kind: grill_coverage_matrix
authority: tracking_not_ssot
created_at: 2026-06-25
plan: docs/superpowers/plans/2026-06-25-a2-step2-uipresentation.md
inputs: [UIUE-checklist.md 主清单 234+, runtime-bridge RPB-01~53（53 含追加补漏 51-53）, SD1-25, V1-12, CC*, AD-1~14, U1-31, D1-8, E0-8, 锦标赛41, G01-28]
---

> 磊哥 2026-06-25：plan 对比 grill checklist **234 主清单 + runtime 53（RPB）+ 追加补漏**，哪些纳入 A-2，做索引跟进，**随任务推进一个个消减**。
> 🔴 **用法**：① 每条标 Phase 映射 + 状态 ② Phase 做完 → 该 Phase grill 项 `- [ ]`→`- [x]` 消减 ③ derived-tracking-writeback gate：每 Phase 后回写本索引。
> SSOT 指针：`grill-decisions-master.md` / `uiue-storyboard-grill-decisions.md` / `uiue-runtime-bridge-decisions-2026-06-25.md`（RPB）；本文 = 消减跟踪非 SSOT。
> 图例：⬜纳入A-2待消减 / ✅已落(4a-c/main archived) / ⏳DEFERRED(Phase5/voice/训练/main) / 🔪superseded(S1-S10) / 🟡部分。

---

## 〇、全集覆盖总账（各系列 × 数量 × A-2 纳入 × 状态，一眼看全集都有交代）

| 系列 | 数量 | 落点 | A-2 纳入 | 非 A-2 | 状态 |
|---|---|---|---|---|---|
| **SD 用户故事** | 25 | storyboard | 21（P0-P6）| SD16 orb⏳ / SD12 宏部分⏳ | ⬜ 主体待消减 |
| **V 视觉块** | 12 | SD18+tokens | 12（P2/P7）| — | ⬜ |
| **CC corner case** | ~18 | SD18-25 | ~15（P1-P3）| CC2 think⏳ | ⬜ |
| **AD 架构** | 14 | design | AD-9~14（6，P1-P6）| AD-1~8 已落 4a-c | 🟡 |
| **RPB runtime（含追加 51-53）** | **53** | runtime-bridge | **53 全（contract done，code 消费 P0-P4）** | RPB-16·21-23·33·37-38 voice·orb⏳ | ⬜ 53 逐组见下 |
| **U UIX 续批** | 31 | grill-master | ~7 视觉相关（P2-P6）| 余已落/voice/Phase5⏳ | 🟡 |
| **D 交互核心** | 14+子题53 | grill-master | 承接 SD/AD（已落 4a-c）| D8.3 think⏳ | ✅🟡 |
| **E orb/思考链路** | 9 | grill-master §4 | mic/对话流/氛围灯已拆入 A-2 | E0-8 orb 本体⏳Phase5 | ⏳ |
| **锦标赛 R1-R5** | 41 | final-grill | — | A2/范式/口径 已落 main | ✅ |
| **G default_scope** | 28 | G-decisions | — | 已落 main（17ae332）| ✅ |
| **Q30-Q41** | 12 | grill-master §2 | 承接 SD | 部分续批 | 🟡 |
| **合计** | **≈240 + RPB 53** | — | A-2 实装 ~110 项 | 余已落/DEFERRED | 随 Phase 消减 |

> 🔴 **A-2 实装消减目标 ≈ 110 项**（SD 21 + V 12 + CC 15 + AD 6 + RPB 53 + U 7 - 重叠）；非 A-2 ≈ 130 项已落/DEFERRED 不消减。

---

## 一、A-2 直接实装覆盖矩阵（逐项消减）

### SD 系列（25 → Phase）

| SD | 内容 | Phase | 状态 | 消减 |
|---|---|---|---|---|
| SD1 idle 全景开场 | P0 coldStart | ⬜ | - [ ] |
| SD2 push-to-talk + 苹果 ASR | P2 mic dock UI（ASR backend ⏳voice）| 🟡 | - [ ] |
| SD3 对话流 DialogueBubble | P2 | ⬜ | - [ ] |
| SD4 氛围灯 3 动作 | P1 mapper + P2 卡片渐变 + **P5 炸场** | ⬜ | - [ ] |
| SD5 玻璃分层 + material | P2 | ⬜ | - [ ] |
| SD6 点卡展开 composite + 数值控件 | P3（现有 4b 保留 + 触摸）| 🟡 | - [ ] |
| SD7 触摸调节→mock store→语音推理+联动+静默 | **P3**（全 mock）| ⬜ | - [ ] |
| SD8 刷新复位 + 设置（主题/场景宏 force）| P2 + **P4** | ⬜ | - [ ] |
| SD9 拒识/确认/澄清（R0/R1/R2）| P2 边界 + P3 mock 语音 | 🟡 | - [ ] |
| SD10 多意图 + 3s 闭环 + 不打断 | 现有 4b + P3 | ✅🟡 | - [ ] |
| SD11 米白主题（跟随系统 S1🔪→V6 强制色）| P2 + P2 主题切 | ⬜ | - [ ] |
| SD12 不编排台本 + 场景宏 + 端状态模块页 | P4 端状态模块（场景宏 ⏳Phase5）| 🟡 | - [ ] |
| SD13 演绎控制台三大块 | **P4** | ⬜ | - [ ] |
| SD14 控制台布局 + AllStateSheet 33base | **P4** | ⬜ | - [ ] |
| SD15 控制台视觉对齐 + 时段⊥主题 | **P4** | ⬜ | - [ ] |
| SD16 orb 四态视觉 | ⏳ Phase5（E1）| ⏳ | - [ ] |
| SD17 动效块收口 | 散各 Phase | 🟡 | - [ ] |
| SD18 视觉块 V1-V12 + 连续舞台 | **P2**（逐 V 见下）| ⬜ | - [ ] |
| SD19 corner case + CC1 升级 | P1（CC1）+ P2 | ⬜ | - [ ] |
| SD20 制冷蓝/制热红 | P1 + P2 | ⬜ | - [ ] |
| SD21 gptPRO 细节（hero range bar）| P2 | ⬜ | - [ ] |
| SD22 层级 z-order + 滚动 | P2 | ⬜ | - [ ] |
| SD23 边界态 7 类 | P2（去 TextField + portrait）| ⬜ | - [ ] |
| SD24 context capsule 顶部 | **P6** | ⬜ | - [ ] |
| SD25 capsule diorama 定稿 | **P6** | ⬜ | - [ ] |

### V 系列（12 → P2/P7）

| V | Phase | 消减 |
|---|---|---|
| V1 间距 8pt / V2 type scale / V3 圆角 hairline / V6 theme 强制色 / V11 duration | P2（tokens）| - [ ] V1 - [ ] V2 - [ ] V3 - [ ] V6 - [ ] V11 |
| V4 视觉重量 / V8 注意力 | P2 | - [ ] V4 - [ ] V8 |
| V5 Glass 容器 | P2 mic / P4 控制台 / P6 capsule | - [ ] V5 |
| V7 连续舞台 zone | P2 | - [ ] V7 |
| V9 图标 SF Symbols | P1 + P2 | - [ ] V9 |
| V10 可读性 hard gate（投屏）| **P7** | - [ ] V10 |
| V12 Mac/iPhone 密度 | P2（Grid 固定列已实装）| - [ ] V12 |

### CC 系列（~18 → Phase）

| CC | Phase | 消减 |
|---|---|---|
| CC1 + CC1.1 座椅盲区→activeCell | P1 | - [ ] |
| CC2 思考态死寂 | ⏳ Phase5 orb | - [ ] |
| CC3 多 active 错峰 | ✅ 现有 MultiCallSequencer 4b | - [ ] |
| CC4 相对值超界 clamp | P2 + P3 触摸 | - [ ] |
| CC-A1~A6 多意图 | 现有 4b + P3 部分deny mock | - [ ] |
| CC-B1~B4 R2 后备箱 | P2 边界 + P3 mock 语音 + ⏳Phase5 think | - [ ] |
| CC-C1~C4 clarify | P2 | - [ ] |

### AD 系列（A-2 相关 AD-9~14）

| AD | Phase | 状态 | 消减 |
|---|---|---|---|
| AD-9 family_card_id + 10 族常驻 | ✅4a + P2 | ✅🟡 | - [ ] |
| AD-10 族卡聚合 | ✅4a | ✅ | - [ ] |
| AD-11 摘要展开三屏 | ✅4b + P2 | ✅🟡 | - [ ] |
| AD-12 竖屏交互 hero+ScrollViewReader | P2 | ⬜ | - [ ] |
| AD-13 Presentation Contract 三层 | 贯穿 | ⬜ | - [ ] |
| AD-14 连续舞台+注意力+CC1 | **P1-P6** | ⬜ | - [ ] |

### 🔴 RPB 系列（runtime bridge 53 全集，含追加补漏 51-53；contract 已 accepted，code 消费 P0-P4）

| RPB 组（全 53 覆盖）| 内容 | Phase | 消减 |
|---|---|---|---|
| **RPB-01~08** 基础 vocabulary | snapshot / scope_origin 单源 / refusal class / proof class / 主线程不阻塞 / source⊥scope_origin（RPB-08）| P0 容器 | - [ ] |
| **RPB-09~17** result 分类 | refusal(unsupported·safety RPB-09·10) / already_state_noop(RPB-14) / partial-deny(RPB-17·CC-A4) / splitter(RPB-16 ⏳DEFERRED) | P0 + P2 边界 + P3 mock | - [ ] |
| **RPB-18~25** snapshot 字段/context/边界 | force-context 四维(RPB-19·AD-RPB-014) / think 事件门(RPB-21 ⏳Phase5) / voice·orb 边界(RPB-22·23) / 已落字段 | P0 + P4 force + ⏳Phase5 | - [ ] |
| **RPB-26~40** P1 contract 字段 | snapshot card schema(RPB-30 + sibling·activeCell) / orb 状态源(RPB-33 ⏳Phase5) / 其余字段 | P0 容器 freeze + 消费各 Phase | - [ ] |
| **RPB-41~50** P2 contract 字段 | 其余 vocabulary 字段（finite enum / redaction / timestamps…）| P0 容器 freeze | - [ ] |
| **RPB-51（追加）** card sibling/secondary cells | 制冷热色 + CC1 依赖（修正「制冷热=纯 visual」分类）| P0 + P1 + P2 | - [ ] |
| **RPB-52（追加）** 演绎控制台 force-state context | A 整车 + C 环境 force（segmented 暴露）| P0 + **P4** | - [ ] |
| **RPB-53（追加）** think 两语义张力 | analyzing 事件驱动 vs 安全固定 1.0s | ⏳ Phase5 think | - [ ] |

> RPB 全 53 项：P0 一次 freeze vocabulary 容器（snapshot/result_kind 8 类/context 四维/proof_class/source·scope_origin）；code 消费按 Phase（sibling→P1/P2 制冷热·activeCell / force-context→P4 演绎控制台 / voice·orb·think·splitter→⏳Phase5/voice/post-model）。

### 相关 U 系列（视觉/交互 → Phase；余已落/main/voice）

| U | Phase | 消减 |
|---|---|---|
| U2 Liquid Glass 功能层 | P2 + P4 + P6 | - [ ] |
| U5 Metal 水波一期 | P6 capsule 氛围 / ⏳ | - [ ] |
| U10 四态 / U11 base #121212 / U13 10 族 / U26 enum+switch | ✅ 已落 | - [ ] |
| U30 orb shader（layerEffect GPU 约束）| ⏳ Phase5 orb（约束贯穿 P5/P6）| - [ ] |

---

## 二、非 A-2 范围（状态总览，不逐项消减）

| 系列 | 数量 | 状态 | 说明 |
|---|---|---|---|
| 锦标赛 R1-R5 | 41 | ✅ 已落 main / 部分⏳ | A2 D-domain/范式/口径 → archived；C5/C6/voice ⏳ |
| G01-G28 | 28 | ✅ default_scope 已落 main（17ae332）| R-L17 gate 是训练/评测前置非 UIUE |
| E0-E8 | 9 | ⏳ Phase5 orb/思考链路 | mic dock/对话流/氛围灯不跟 orb defer（已纳 A-2）|
| D1-D6 子题 ~24 + 盲评 5 | 29 | ✅ 已落 4a-c / 纳入 SD | — |
| D1-D8 主 | 14 | ✅ 已落（D7 apply 6a3e3f9）/ D8.3 ⏳Phase5 | — |
| Q30-Q41 | 12 | 🟡 部分续批 / 纳入 SD | — |
| P4-D1·D2·D3 + 4a·4b·4c | 6 | ✅ 已收口 | — |
| 训练/voice/golden-run | — | ⏳ DEFERRED 独立立项 | retrain-c5/rebuild-c6/ASR-TTS/golden-run |

---

## 三、消减跟踪规则（derived-tracking-writeback gate）

1. **每 Phase 做完** → 该 Phase grill 项 `- [ ]`→`- [x]`，状态 ⬜→✅。
2. **每 Phase codex 审计后** → 审计发现某项未真落（假绿）→ 保持 `- [ ]` 不消减。
3. **Phase 7 收口** → 统计「A-2 实装 X 消减 / ~110 总」+ 非 A-2 状态确认。
4. **新增 grill** → 追加本索引对应系列 + Phase 映射。
5. 与 `landing matrix` 关系：landing = 粗粒度落地态；本索引 = 细粒度 grill × Phase 消减。每 Phase 后同步。

---
*as-of 2026-06-25 · 配套 plan v3 · 随 Phase 推进消减（A-2 ~110 项 / 全集 ≈240 + RPB 53）*
