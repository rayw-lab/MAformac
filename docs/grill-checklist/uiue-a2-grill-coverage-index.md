# UIUE A-2 grill 覆盖索引（canonical 全集 × A-2 分组消减）

---
status: coverage_index_live_tracking
artifact_kind: grill_coverage_matrix
authority: tracking_not_ssot
created_at: 2026-06-25
plan: docs/superpowers/plans/2026-06-25-a2-step2-uipresentation.md
canonical_inputs: [docs/UIUE-checklist.md canonical≈240+, runtime-bridge RPB-01~53（含追加补漏 51-53）, SD1-25, V1-12, CC*, AD-1~14, U1-31, D1-8, E0-8, 锦标赛41, G01-28]
stale_inputs: [docs/grill-checklist/UIUE-checklist.md redirect stub（旧 SD1-SD20/≈234，不能作为当前精确分母）]
granularity: series_full_coverage_plus_grouped_phase_checkpoints_not_one_id_one_row
---

> 磊哥 2026-06-25：plan 对比 canonical UIUE grill checklist **≈240+ 主清单系列 + runtime RPB-01~53**，判断哪些纳入 A-2，哪些已落/DEFERRED，并随 Phase 做**分组 checkpoint 消减**。
> 🔴 **用法**：① 每个系列/分组标 Phase 映射 + 状态 ② Phase 做完 → 对应 checkpoint `- [ ]`→`- [x]` 消减 ③ derived-tracking-writeback gate：每 Phase 后回写本索引。
> SSOT 指针：`grill-decisions-master.md` / `uiue-storyboard-grill-decisions.md` / `uiue-runtime-bridge-decisions-2026-06-25.md`（RPB）；本文 = 消减跟踪非 SSOT。
> 图例：⬜纳入A-2待消减 / ✅已落(4a-c/main archived) / ⏳DEFERRED(Phase5/voice/训练/main) / 🔪superseded(S1-S10) / 🟡部分。

## 口径校正（防 fake-green）

| 问题 | 当前口径 |
|---|---|
| “234 主清单”还能作为当前分母吗？ | **不能**。`docs/grill-checklist/UIUE-checklist.md` 已是 redirect stub，注明旧副本停在 SD1-SD20/≈234；当前 canonical 是 `docs/UIUE-checklist.md`，口径为 **≈240+**。 |
| 本文是否识别了全集系列？ | **是**。canonical 主清单的大系列 + RPB-01~53 都在本文总账中有落点。 |
| 本文是否已经是 one-id-one-row 机械 ledger？ | **不是**。本文是 A-2 执行用 tracking index，V/CC/RPB/U/D/G/Q 等采用分组 checkpoint；checkbox 数不等于 A-2 项数。 |
| “A-2 实装 ~110 项”怎么理解？ | 是按系列拆分后的**估算覆盖目标**，不是当前文件里的独立 checkbox 数。Phase 7 可统计分组通过率；若要严格逐项 V-PASS，需要另展开 one-id-one-row ledger。 |

---

## 〇、全集覆盖总账（系列识别层：各系列 × 数量 × A-2 纳入 × 状态）

| 系列 | 数量 | 落点 | A-2 纳入 | 非 A-2 | 状态 |
|---|---|---|---|---|---|
| **SD 用户故事** | 25 | storyboard | 21（P0-P6）| SD16 orb⏳ / SD12 宏部分⏳ | ⬜ 主体待消减 |
| **V 视觉块** | 12 | SD18+tokens | 12（P2/P7）| — | ⬜ |
| **CC corner case** | ~18 | SD18-25 | ~15（P1-P3）| CC2 think⏳ | ⬜ |
| **AD 架构** | 14 | design | AD-9~14（6，P1-P6）| AD-1~8 已落 4a-c | 🟡 |
| **RPB runtime（含追加 51-53）** | **53** | runtime-bridge | **53 全识别（contract done，code 消费 P0-P4）** | RPB-16·21-23·33·37-38 voice·orb⏳ | ⬜ 按组消减，非 53 个独立 checkbox |
| **U UIX 续批** | 31 | grill-master | ~7 视觉相关（P2-P6）| 余已落/voice/Phase5⏳ | 🟡 |
| **D 交互核心** | 14+子题53 | grill-master | 承接 SD/AD（已落 4a-c）| D8.3 think⏳ | ✅🟡 |
| **E orb/思考链路** | 9 | grill-master §4 | mic/对话流/氛围灯已拆入 A-2 | E0-8 orb 本体⏳Phase5 | ⏳ |
| **锦标赛 R1-R5** | 41 | final-grill | — | A2/范式/口径 已落 main | ✅ |
| **G default_scope** | 28 | G-decisions | — | 已落 main（17ae332）| ✅ |
| **Q30-Q41** | 12 | grill-master §2 | 承接 SD | 部分续批 | 🟡 |
| **合计** | **canonical ≈240+ + RPB 53** | — | A-2 实装目标约 110 项 | 余已落/DEFERRED | 随 Phase 分组消减 |

> 🔴 **A-2 实装目标 ≈ 110 项**（SD 21 + V 12 + CC 15 + AD 6 + RPB 53 + U 7 - 重叠）。本文当前提供**分组 checkpoint**；非 A-2 ≈130 项只做系列状态确认，不逐项消减。

---

## 一、A-2 直接实装覆盖矩阵（分组 checkpoint 消减）

### SD 系列（25 → Phase）

| SD | 内容 | Phase | 状态 | 消减 |
|---|---|---|---|---|
| SD1 idle 全景开场 | P0 coldStart | ✅ | - [x] |
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

Phase 1 sub-checkpoints（receipt: `docs/research/2026-06-25-a2-execution/phase-1-receipt.md`；full visual rows stay unchecked until UI consumption + anchor gate）:
- [x] SD20/P1 thermal tint mapper from `ac.mode` sibling cells.
- [x] SD19/P1 activeCell + siblingCells carriage for family cards.
- [x] SD4/P1 ambient 8-color burst gradient mapper.
- [x] V9/P1 exhaustive 10-family SF Symbol mapper.

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

### 🔴 RPB 系列（53 全识别，按组消减；含追加补漏 51-53）

| RPB 组（覆盖 53 全集）| 内容 | Phase | 消减 |
|---|---|---|---|
| **RPB-01~08** 基础 vocabulary | snapshot / scope_origin 单源 / refusal class / proof class / 主线程不阻塞 / source⊥scope_origin（RPB-08）| P0 容器 | - [x] |
| **RPB-09~17** result 分类 | refusal(unsupported·safety RPB-09·10) / already_state_noop(RPB-14) / partial-deny(RPB-17·CC-A4) / splitter(RPB-16 ⏳DEFERRED) | P0 + P2 边界 + P3 mock | - [ ] |
| **RPB-18~25** snapshot 字段/context/边界 | force-context 四维(RPB-19·AD-RPB-014) / think 事件门(RPB-21 ⏳Phase5) / voice·orb 边界(RPB-22·23) / 已落字段 | P0 + P4 force + ⏳Phase5 | - [ ] |
| **RPB-26~40** P1 contract 字段 | snapshot card schema(RPB-30 + sibling·activeCell) / orb 状态源(RPB-33 ⏳Phase5) / 其余字段 | P0 容器 freeze + 消费各 Phase | - [ ] |
| **RPB-41~50** P2 contract 字段 | 其余 vocabulary 字段（finite enum / redaction / timestamps…）| P0 容器 freeze | - [ ] |
| **RPB-51（追加）** card sibling/secondary cells | 制冷热色 + CC1 依赖（修正「制冷热=纯 visual」分类）| P0 + P1 + P2 | - [ ] |
| **RPB-52（追加）** 演绎控制台 force-state context | A 整车 + C 环境 force（segmented 暴露）| P0 + **P4** | - [ ] |
| **RPB-53（追加）** think 两语义张力 | analyzing 事件驱动 vs 安全固定 1.0s | ⏳ Phase5 think | - [ ] |

> RPB 全 53 项已在 `uiue-runtime-bridge-decisions-2026-06-25.md` one-id-one-row 决策完成；本文只做 A-2 执行分组消减。P0 一次 freeze vocabulary 容器（snapshot/result_kind 8 类/context 四维/proof_class/source·scope_origin）；code 消费按 Phase（sibling→P1/P2 制冷热·activeCell / force-context→P4 演绎控制台 / voice·orb·think·splitter→⏳Phase5/voice/post-model）。

Phase 0 receipt: `docs/research/2026-06-25-a2-execution/phase-0-receipt.md`（TDD + full `swift test` + 双端 build；anchor pixel compare skipped because this phase has no UI delta）。
Phase 1 receipt: `docs/research/2026-06-25-a2-execution/phase-1-receipt.md`（TDD + full `swift test` + SF Symbol probe + 双端 build；RPB-51 P1 slice done, full row remains open until visual consumption）。

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

## 三、机械完整性状态（本文件能证明什么 / 不能证明什么）

| 层级 | 当前状态 | 可声称 | 不可声称 |
|---|---|---|---|
| 全集系列识别 | ✅ 完整 | canonical 主清单系列 + RPB-01~53 都有归类 | 不能说旧 234 是当前精确分母 |
| A-2 Phase 映射 | ✅ 分组完成 | A-2 目标约 110 项已映射到 Phase/checkpoint | 不能说已有约 110 个独立 checkbox |
| RPB 覆盖 | ✅ 53 决策全 + 本文分组消费 | RPB-01~53 已决策，A-2 消费按组跟踪 | 不能把 8 个 RPB checkpoint 当 53 个独立消减 |
| 非 A-2 | 🟡 系列状态确认 | 已落/DEFERRED/非本轮范围有交代 | 不能说非 A-2 ≈130 项已逐项复核 |

## 四、消减跟踪规则（derived-tracking-writeback gate）

1. **每 Phase 做完** → 该 Phase checkpoint `- [ ]`→`- [x]`，状态 ⬜→✅。
2. **每 Phase codex 审计后** → 审计发现某项未真落（假绿）→ 保持 `- [ ]` 不消减。
3. **Phase 7 收口** → 统计「A-2 checkpoint X 消减 / 当前 checkpoint 总数」+ 「A-2 目标约 110 项 residual」+ 非 A-2 状态确认。
4. **若需要 one-id-one-row 验收** → 另起或扩展本表，把 RPB-01~53、CC-A/B/C、U1-U31、G01-G28、Q01-Q41 展开成独立行后再声称逐项 V-PASS。
5. **新增 grill** → 追加本索引对应系列 + Phase 映射；若影响 A-2，补入 checkpoint 或 one-id-one-row 子表。
6. 与 `landing matrix` 关系：landing = 粗粒度落地态；本索引 = 细粒度 grill × Phase 消减。每 Phase 后同步。

---
*as-of 2026-06-25 · 配套 plan v3 · 随 Phase 推进分组消减（A-2 目标约 110 项 / canonical 全集 ≈240+ + RPB 53）*
