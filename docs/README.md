# MAformac 技术架构基座 — 文档地图

> **MA = Master Agent**(MAformac = Master Agent for macOS/iOS)。
> **北极星**:方案经理给客户演示用,客户现场 5 分钟内——听懂中文、反应快、不崩、看着惊艳、断网也能跑。
> **形态**:纯端侧(iOS/macOS)、离线、Qwen3-1.7B + LoRA 大脑(0.6B 仅作真机吃紧时的轻量备选)、mock 车控、可插拔多技能(Phase1 车控 → 导航/音乐/外卖 via MCP)。

> 🔴🔴 **范式翻案 + 决策统一(2026-06-22~23,最新基线,优先于下方 v3)**:① **范式翻案** —— model-visible surface 从 generic frame(`tool_call_frame`)否决 → **D-domain 具名工具**(value 形态编码进工具名);canonical IR 仍 device×action(「对模型像具名工具,对系统像 device×action IR」);工具数未拍待 value-form 实算(**562=intent 非工具数**)。范式权威 = ⭐`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`(§1-§17:翻案/三层模型/demo 特性/多语种/21 主议题全收口/A2 盘点)。② **口径终拍(磊哥 2026-06-23 亲拍 562 终结纠结)**:10 族 = **191 device / 562 intent / 2159 行 / 54.1%**;族外 480 device / 976 intent / 1831 行;全集 3990 行 / 671 device / 1538 unique intent。**534 / 2086 / 52.3% / 族外 1004 / 1904 系列全废,禁再引**。③ **范式三层模型**:canonical IR(device×action×value) / surface(D-domain 具名工具) / runtime(MVP 10 族:空调/座椅/车窗/车门/灯光氛围/屏幕/音量/雨刮/天窗遮阳/香氛,HUD 不做;mock,族外 unsupported)。④ **决策统一索引**:`docs/grill-tournament/final-grill-list.md`(41 题运行清单)+ paradigm §1-§17(拍板清单)+ UIUE 31 条(`raw/.../2026-06-22-uiue-ultracode/GRILL-MASTER.md`)同源。
>
> ⚠️ **路线 v3 历史基线(2026-06-20,surface 已被上方范式翻案演进,IR/路线骨架仍有溯源价值)**:C1/C2、C3 execution、C6 vehicle-tool-bench 均已 archived → `openspec/specs/`;C6 base Qwen3-1.7B 无 LoRA hard_fail 0.789 是 C5 提升判据。`docs/roadmap-2026-06-20-from-c6-done.md` 已是 **historical / provenance source**,不再是唯一推进事实源或必读第一。当前推进事实源以 `CLAUDE.md §9` 指向的 grill SSOT、范式权威、级联账本、Phase 0 manifests、active OpenSpec drafts 为准。范围真值:空调 **18-32℃** / 风量 **1-10 档**(旧 16-30/0-5 拍错)。

## ⭐ 当前文档地图 / 唯一基线入口（discoverability map；权威基线定义见 `CLAUDE.md §9` + 下表，非本标题「以此为准」一刀切）

| 文档 | 是什么 |
|---|---|
| `docs/CURRENT.md` | **当前路由牌(router only,not SSOT)**:新窗口先看当前阶段/下一步/禁止动作/活跃 blockers;若与 CLAUDE/OpenSpec/grill 冲突则作废并更新 |
| `docs/superpowers/plans/2026-06-25-post-c6-backend-training-uiue-roadmap.md` | **Post Long-run 2 parent roadmap**:bridge contract first, model/C6 next, full backend/UIUE connection later under child plans; implementation_plan_not_ssot |
| `openspec/changes/define-runtime-presentation-bridge/` | **Runtime -> Presentation bridge carrier**: contract-only mainline mapping authority for UIUE provenance, runtime result vocabulary, presentation snapshot, `ScopeOrigin` disposition, and proof-class display caps; not runtime implementation |
| `docs/project/phase0/r5-d24-uiue-absorption-manifest-2026-06-30.md` | **D24 UIUE absorption manifest**: main-traceable inventory for local dirty split, PR #7/#6 file surfaces, UIUE source dispositions, route-control merge gates, and no-claim boundaries before PR merge |
| `docs/project/phase0/mainline-runtime-presentation-bridge-unblock-2026-06-28.md` | **Phase 0 bridge owner-gate unblock receipt**: records HR-01/02/03 acceptance, C01/C03/C06/C18 dispatch-readiness disposition, dirty ownership, validation, and non-claims |
| `docs/project/phase0/post-c6-roadmap-gptpro-architecture-audit-request-2026-06-25.md` | **GPT Pro architecture audit request**: asks external review to challenge the post-C6 roadmap for downgrade risk and over-engineering risk |
| `docs/project/phase0/post-c6-roadmap-gptpro-architecture-absorption-ledger-2026-06-25.md` | **Post-C6 architecture audit absorption ledger**: absorbed route/plan and C6 bench/source-free P1/P2 fixes; local proof only, not C6 acceptance/model-quality |
| `docs/project/phase0/rebuild-c6-identity-shape-closeout-2026-06-25.md` + `docs/project/phase0/rebuild-c6-identity-shape-gptpro-absorption-ledger-2026-06-25.md` | **Long-run 2 closeout evidence**: `external-pass-with-absorbed-fixes` for rebuild-C6 identity + behavior-shape construction only; not C6 acceptance/model-quality/retrain/golden/voice/UIUE/V-PASS |
| ⭐`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` | **范式 + surface 权威 SSOT**(§1-§17:generic frame 否决→D-domain 具名工具/canonical IR 仍 device×action/三层模型/demo 取巧特性/口径终拍 562/21 主议题全收口/A2 盘点) — **范式翻案权威** |
| `docs/grill-tournament/final-grill-list.md` + `docs/grill-tournament/cascade-inventory.md` | **决策统一**(41 题运行清单 + 文档级联 inventory) |
| `docs/roadmap-2026-06-20-from-c6-done.md` | **historical / provenance source**(五件套 harness 骨架 OpenSpec/Pocock/Superpowers/Pi/Mastra + P0-P2 执行序 + 7 HIGH 已拍 + 一手 file:line + 依赖图;surface 已被范式翻案演进) — 只作溯源,不作当前路线事实源 |
| `CLAUDE.md` (§9) | 项目宪法 + 新基线指针 + 下一步 P1 |
| `Tools/agent-platform-plugin-refs/README.md` + `.xcodebuildmcp/README.md` | **Codex iOS/macOS build 入口**:插件引用 + 本 worktree 默认 `build-ios-apps` profile。main 固定 `MAformacIOS` + `iPhone 17 Pro`;新窗口先看这里再跑 `session_show_defaults` / `build_run_sim()` |
| `docs/project/phase0/` | **Phase 0 route-control manifests**(authority/stage/decision/status/gate materialization; not runtime contracts; filled docs must carry status/retire metadata) |
| `docs/superpowers/plans/` | **implementation plans only**(Superpowers 执行计划; not SSOT; must carry authority/retire metadata) |
| `docs/srd-three-layer-intent-routing.md` | **架构事实源**(三层意图路由/意图收缩/落域/LoRA 慢路 + §12 实装锚点) |
| `docs/research/INDEX.md` | 调研/teardown 索引 + 应用机制(架构验证6流/home-llm深拆/ASR选型/C5配方/C6评测) |
| `docs/c1-q1-q10-claude-oracle-grill-2026-06-19.md` + `docs/adr/0001-*` + `CONTEXT.md` | C1/C2 决策全料(Q1–Q15) |
| `contracts/semantic-function-contract.jsonl`(C1) + `state-cells.yaml`(C2) + `risk-policy.yaml` | **契约 SSOT**(其余派生) |

> 下方「文档清单 / 基座内化 / Decisions待拍 / ABC候选」多为 **v1 历史快照 + P0 调研归档**(部分被 v2 supersede),作上下文保留,**当前以上表为准**。

## 文档清单(v1 调研/基座归档 · 部分被 v2 supersede)

| 文档 | 内容 | 行数 |
|---|---|---|
| `research-archive-2026-06-17.md` | 调研归档:GitHub repo 调研×3 轮 + 8 周路线图(七节)+ 多 domain 基座架构 + 实时交互三能力(barge-in/快慢/记忆)调研 | ~370 |
| `tech-baseline-from-raw.md` (v0.1, §1–§12) | **主基座**:项目定义/降维映射/7 层架构/Capability+Tool schema/八大垂域+多domain功能清单/FC语义四级/快慢路由+三态推荐/DialogueState/barge-in/repo映射/eval+话术+badcase/decisions D1–D18 + §12.1 磊哥裁决 | 470 |
| `tech-baseline-supplement-v0.2.md` (§13–§17) | **补充**:多阶规划层/中枢调度+Agentic-Skill分工/LoRA 工程化闭环⭐/安全门控+必过集/decisions D19–D37 | 405 |
| `integration-blueprint.md` (§0–§10) | **装配蓝图**:38 肩膀三类分法(进app/开发期/抄思路)+ 模型尺寸(1.7B 主力)+ 7层×repo 装配图 + 端到端数据流 + 骨架目录 + 第一刀 + 对标 AWS AgentCore + 读全报告补漏 | ~230 |
| `voice-pipeline-from-raw.md` | **语音链路专题**(from raw):中文车控热词(promptTokens)+ SpeechTextNormalizer + 8 态机 + 800ms 延迟预算;**顶部有拍板对齐段** | ~350 |
| `qwen3-engineering-notes.md` | **Qwen3 工程专题**:「能 tool call」是表层信号 + 4 隐藏层 + 10 条教训 + 外网/38repo + **change 3-6 硬约束** | ~130 |

## 🔑 基座语义协议内化(2026-06-19,当前主线 · 索引)

> 4 张某车厂金钥匙表(`~/Downloads/`:公版语义四级协议-编辑版 / 车控功能打点表 / 上下文二次交互功能清单 / 多语种展开V1,**只读不进仓**)深度消化 → MAformac 自有语义协议。**这是 LoRA 语料 + 功能清单 + E2E 基线的根。**

| 文档 | 内容 | 用途 |
|---|---|---|
| `baseline-semantic-protocol-2026-06-19.md` | 基座消化:范式 7 要素(value 四件套 ref/direct/offset/type、归一化动作编码 ~114、二次交互矩阵、FC 分流标记)+ `capabilities.yaml` 逐项错对照 + 内化方案 | **语义协议范式权威** |
| `maformac-function-spec-2026-06-19.md` | MAformac 功能清单 v0 + **§5 不丢脸架构**(L1 精做 / L2 通用 mock 兜底 / L3 越界 / L4 安全门 + LoRA 核心) | **功能清单 + 执行分层** |
| `demo-must-pass-candidate-2026-06-19.md` | must-pass 必过集 candidate(扁平契约版,**待基于基座重做**) | E2E/验收(待重做) |
| `baseline-internalization-plan-2026-06-19.md` ⭐ | **总方案**:业内怎么处理巨型表(scout 某车厂 FC 手册:意图收缩+三层路由+分层兜底+安全分级)+ oracle prior art(Hammer/xLAM/unsloth/vLLM-router/typia/outlines/xgrammar/MAC-SLU)+ 6 产物内化方案 + **实施 Roadmap P0-5** + **冻结决策整改清单** + Pre-Mortem 三分类 | **方案+roadmap+整改** |
| `handoffs/2026-06-19-baseline-internalization.md` | 本波 handoff:重大认知 + 下一步 + 工件位置 | session 交接 |
| `~/workspace/raw/00-Inbox/maformac-baseline-digest/` *(raw,不进仓)* | 基座 digest 工件 + 解析脚本(carControl 398 设备/975 intent + airControl 16/51 + cmd 257/512 全景);`python3 parse_devices.py` 可重建 | 全集解析工件 |

> **核心认知**:客户随意说 2655+(甚至超出)→ 语义广听懂(LoRA 的核心价值)+ mock 执行分层兜底 = 不丢脸;功能清单 = **全集语义协议**(非 8 个窄 case)。
> **进行中**:`/pre-mortem` 调研"业内怎么处理巨型协议表"(scout raw 一手做法 + oracle 业内 prior art)→ 待产出 **方案建议 + 实施 roadmap + 冻结决策整改清单**(codex 执行,CC 思考)。

## Decisions 状态总览(D1–D37 + Q1–Q15)

- 🔒 **D1–D37 全锁**(D20/D30/D35/D37 已于 2026-06-17 拍板;权威见 `CLAUDE.md §5`)。
- **v2 重审(2026-06-19)**:D16 端态 8→102 原子能力 P0 子集 / D30 adopt unsloth+Hammer+xLAM / D35 全集覆盖率双轴 bench / D37 risk-policy 单源 / **D14 ASR→系统 SFSpeechRecognizer 主(demo 取巧 on-device 离线)+sherpa-onnx/WhisperKit fallback(不砍)+ASRBackend 抽象(已 amend:sherpa 主→系统主,见 `docs/grill-tournament/grill-decisions-master.md:203` §4.6 + U28)**。范围真值:空调 18-32℃ / 风量 1-10 档(旧 16-30/0-5 拍错)。
- **Q1–Q15** = C1/C2 契约脑暴定稿(见 grill/ADR)。
- **T2 决策统一(2026-06-22~23)**:范式翻案(generic frame→D-domain 具名工具)+ 口径终拍 562 + demo 取巧 10 族,见 paradigm §1-§17(拍板权威)+ `docs/grill-tournament/final-grill-list.md`(41 题运行清单)+ UIUE 31 条(`raw/.../2026-06-22-uiue-ultracode/GRILL-MASTER.md`)。

> ⛔ 下方「下一步候选 ABC / 基座内化进行中」为 v1 历史快照,**已 supersede**(当前路线见 `CLAUDE.md §9` + 上方权威文档表)。

## 关键已锁主线(speed-read)

- 主线模型 = Qwen3-1.7B + LoRA(0.6B 仅作轻量备选;FoundationModels 因不可微调出局,留逃生口)
- 规则吃 80% 高频车控,LLM 只碰 20% 模糊/跨域;**LoRA 必做**,只练「模糊说→跨域映射」
- 端状态**自包含** = UI 卡片亮暗 + TTS 模拟(无外部系统方);执行=改卡片态+播报
- 文本先行(开发顺序)+ ASR 必交付;**ASR = 系统 SFSpeechRecognizer 主(demo 取巧 on-device 离线)+ sherpa-onnx/WhisperKit fallback(不砍,要开发)+ ASRBackend 抽象**(🔴 D14 已 amend:sherpa 主→系统主,见 `docs/grill-tournament/grill-decisions-master.md:203` §4.6 + U28;旧 Paraformer≫Whisper 中文抗噪依据降为 fallback 选型理由保留);barge-in 首版按钮打断,VAD 二期
- 安全/记忆/barge-in 是 38-repo 盲区,需自建

## 边界声明

全部抽象自真实座舱项目资料 + 38 参考 repo。**全文「某车厂」,无真实客户名/报价/密钥/PII/对内禁外传原文。**

## 下一步候选(待磊哥定方向)

> ⚠️ SUPERSEDED(2026-06-23 文档级联):本段为 **v1 历史快照**,方向已早决——现行推进事实源 = `docs/grill-tournament/grill-decisions-master.md`(grill SSOT,Q22 终拍单源) + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`(范式权威);C1/C2/C3/C6 均已 archived,断点 = C5 recovery(范式翻案 D-domain surface),见 `CLAUDE.md §9`。`docs/roadmap-2026-06-20-from-c6-done.md` 已标 **historical(Q22)**,仅供五件套 harness 骨架溯源,勿当现行推进事实源。下方 ABC 仅供溯源,勿据此推进。

- **A) 敲核心契约** ⭐:`tools.json`(八大垂域)+ `DialogueState` schema + `Capability/Tool` 协议落成实际文件——是骨架与 spike 的输入,护城河
- B) 出项目骨架:SwiftUI + AgentCore 目录结构 + 空协议文件
- C) Mac 原型 spike:mlx_lm.server + Qwen3-1.7B 出第一个结构化工具调用,验证链路;llama-server/GGUF 只作 grammar 对照
