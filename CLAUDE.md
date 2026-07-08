---
project: MAformac — Master Agent for macOS / iOS
mode: solo / demo-tool          # 激活 fresheveryday-mode 轻治理（见全局 rules）
methodology: OpenSpec(做什么) + Pocock(哪阶段) + Superpowers(怎么执行)
status: 契约 SSOT 重构(define-c1c2-contract C1+C2 propose done,待 GPT Pro 审 + 拍 open question);路线 v2(旧 7-change 已物理 park)
updated: 2026-06-24
---

# MAformac — 项目宪法

> 项目入口与规矩。新 session 起手**先读本文件 → `docs/CURRENT.md`(当前路由牌,非SSOT) → `docs/README.md` → `docs/project/collaboration-and-roles.md` → 最近 `docs/handoffs/`** 即恢复上下文。细节指向 `docs/`,本文件只放"宪法级"约定。
> 🔴 **经常看 `docs/lessons-learned.md`(持续维护的坑点 & 教训,每遇坑/纠错就追加)——起手必读、动手前回看,别重蹈已记录的坑。**

## 0.1 跨厂商 tmux 蜂群入口

需要在本项目里启动 Claude Code + Codex + Hermes 的跨厂商 tmux 蜂群时，先加载 Claude 命令 `/swarm-commander`，不要用 `/swarm`；`/swarm` 只用于 Claude in-session Agent Teams。

默认输出落点是 `/Users/wanglei/Projects/agent-tmux-stack-research/runs/<run-id>/`。除非本轮任务合同明确写出 writable paths，否则蜂群默认只读 MAformac，不写业务代码。收稿以 run 目录里的 output files 和 file evidence 为准，不信 worker ack 或 pane prose。

跨厂商蜂群的权威索引是 `/Users/wanglei/Projects/agent-tmux-stack-research/SWARM-AUTHORITY-INDEX.md`；具体需求与验收门见 `/Users/wanglei/Projects/agent-tmux-stack-research/07-swarm-hardening-spec.md`。

## 1. 这是什么（北极星）

MAformac 是**纯端侧（macOS + iOS）、完全离线、Qwen3 小模型 + LoRA 为大脑、mock 车控、可插拔多技能的「方案演示助手」**——给方案经理在客户现场做销售演示,替代"把样车开过去"。

**北极星 = 客户现场 5 分钟内:听懂中文、反应快、不崩、看着惊艳、断网也能跑。** 不能在断网 Mac/iPhone 上 5 分钟炸场的复杂度,延后或砍掉。**不是**量产座舱 / 真车控制 / 多租户 SaaS / 聊天机器人。

## 2. 推进方法论:OpenSpec + Pocock + Superpowers（核心）

三工具分层(详见 `docs/project/collaboration-and-roles.md §7`):
- **Pocock**(`~/.codex/skills/pocock`)管**现在哪一阶段**:二开路由器,先分诊(S0 intake/S1 grill/S2 design/S3 spec/S4 build/S5 diagnose/S6 close),只推一个主技能,grill-first。
- **OpenSpec** 管**做什么**:变更与行为契约事实源。`/opsx:explore`(脑暴)→ `propose`(proposal/specs/design/tasks)→ `apply`(实现)→ `sync`/`archive`。
- **Superpowers** 管**怎么高质量执行**:brainstorming / writing-plans / TDD / systematic-debugging / verification。

**OpenSpec 核心机制**:`openspec/specs/` = 唯一事实源(行为契约);`openspec/changes/` = 提议(自包含文件夹,archive 才 merge)。Spec 只写可观察行为(Requirement SHALL + Scenario GIVEN/WHEN/THEN),不写实现。Delta(ADDED/MODIFIED/REMOVED)。Artifact 流是依赖图不是死门(可迭代回改),但守 **agree before build**。

### MAformac 默认路线（v2,2026-06-19 全量重构;方向非瀑布门）

旧 8 能力扁平契约 + 二分路由被基座内化推翻 → 新路线以**契约 SSOT 为根**(C1 全集语义契约 + C2 场景端态),后续执行/路由/LoRA/bench/voice 在其上 rebase。

| 状态 | 目标 | openspec 落点 |
|---|---|---|
| S0 资料堆 ✅ | 调研/基座/4 金钥匙内化 | `docs/` |
| S1 建项契约 ✅ | demo 做什么/成功标准/行为契约(骨架) | `define-demo-mvp-contract`(archive) |
| **S2 契约 SSOT 重构**(当前) | 全集语义契约 + 场景端态(推翻扁平 8 能力) | **`define-c1c2-contract`(C1 semantic-function-contract + C2 scenario-state-protocol)** |
| S3 执行契约层 + 文本 mock 闭环 | 核心链路可跑 | C3(文本→意图→ToolCall→DemoGuard→mock state→trace) |
| S4 三层路由 + 意图收缩 + LoRA 全量 | 语义广听懂 + 分层兜底 | C4 + C5 |
| S5 bench 不丢脸基线 + 离线语音 | 全集覆盖死门 + push-to-talk | C6 + C7 |
| S6 个人演示包 | iPhone 可装、断网可演 | — |

PRD/SRD/ARCH **映射到 OpenSpec artifact**(不另起):PRD≈proposal / SRD≈specs+contracts / ARCH≈design.md / 任务≈tasks.md / 决策≈design 内 Architecture Decisions(承接 D1–D37 + Q1–Q15)。

> **想清楚先行**(2026-06-17/19 教训):起任何 change 前先 brainstorm/grill;**不跳过 explore 直奔 propose,也不跳过 propose 直奔代码**。C1/C2 经 Q1–Q15 脑暴(CC↔codex,2 轮 oracle)定稿。

## 3. 文档与工作区

| 位置 | 职责 |
|---|---|
| `CLAUDE.md` | 本文件,项目宪法 |
| `AGENTS.md` | Codex 入口(路由到 CLAUDE.md) |
| `docs/CURRENT.md` | **当前路由牌**(router only,not SSOT;只写当前阶段/下一步/禁止动作/活跃 blockers;phase transition 必须更新或过期) |
| `docs/README.md` | 文档地图(短入口) |
| `docs/project/collaboration-and-roles.md` | **协作分工 + 三工具协作(§7)** |
| `docs/project/phase0/` | **Phase 0 route-control manifests**(authority/stage/decision/status/gate materialization; not runtime contracts; must carry retire/expiry metadata once filled) |
| `docs/superpowers/plans/` | Superpowers implementation plans(执行计划,not SSOT; plans must say authority=`implementation_plan_not_ssot` and define retire/expiry trigger) |
| `docs/c1-q1-q10-claude-oracle-grill-2026-06-19.md` + `docs/adr/0001-*` + `CONTEXT.md` | **C1/C2 决策全料**(Q1–Q15 + oracle + 领域语言) |
| `docs/research-archive-*.md` / `tech-baseline-*` / `integration-blueprint.md` | P0 调研/基座/蓝图(部分被 v2 supersede,见各文件标注) |
| `openspec/config.yaml` | 项目上下文 + artifact 硬规则(propose 防漂移,已 v2) |
| `openspec/specs/` | **行为契约事实源**(capabilities) |
| `openspec/changes/` | 进行中变更;`_parked/` = 旧 7-change 暂缓(见其 README) |
| `contracts/semantic-function-contract.jsonl` *(C1 建)* | **唯一契约源**(源行级全集;`function-spec-full.yaml`/规则/LoRA/bench 皆生成物) |
| `docs/handoffs/` | session 交接(收工 ≤ 40 行) |
| `Tools/skills/` *(symlink `.claude/skills/`)* | **MAformac 沉淀技能**(2026-06-24 起);索引 + 组合替代见 `Tools/skills/INDEX.md` |
| `Tools/agent-platform-plugin-refs/` | **本机 iOS/macOS build 插件引用**:软链接到 Codex `build-ios-apps` / `build-macos-apps` 插件与 skills;做 SwiftUI、iOS、macOS、Liquid Glass、模拟器、性能或打包任务前先读 |
| `.xcodebuildmcp/` | **本 worktree 的 Codex iOS build 默认项**:`config.yaml` 固化 `build-ios-apps` profile; `README.md` 写新窗口使用顺序。main 默认 profile=`ios` → scheme=`MAformacIOS` → simulator=`iPhone 17 Pro` |
| `docs/roadmap-2026-07-07-macos-closure-baseline.md` | 三线融合基线(baseline_roadmap) |
| `docs/research/2026-07-07-streamline-review/` | 任务①整改方案组(README 总入口) |
| `docs/evidence-frozen-archive/` | 证据 tarball 归档(restore: zstd -dc <tar.zst> \| tar -xf -) |

> `docs/` 放**设计资产**(相对稳定);`openspec/` 放**活的推进事实源**(随 archive 生长)。互补不重复。

### 技能沉淀与验证门(2026-06-24,superpowers v6.0.3)

- **沉淀技能** `Tools/skills/`(symlink 到 `.claude/skills/`,source 在 Tools/):4 BUILD = `archive-research-pack` / `verify-external-claims` / `doc-cascade-sweep` / `closeout-receipt-writer`(用 superpowers `writing-skills` 的 TDD-for-skills 法建,baseline 取 production 实证)。**通用流程直接用 superpowers v6**(`writing-plans` / `subagent-driven-development` / `test-driven-development` / `verification-before-completion` / `using-git-worktrees`;plugin `superpowers@claude-plugins-official` **6.0.3** enabled)。索引 + adopt 组合替代链路 = ⭐`Tools/skills/INDEX.md`。
- **平台插件引用** `Tools/agent-platform-plugin-refs/`:本机软链接索引,不是项目源代码。后续前端/后端运行时/UIUE/视觉/打包相关 agent 起手应读取其中 `build-ios-apps-*` 和 `build-macos-apps-*` 的 `SKILL.md`/references,再写实现或评审。
- **Codex iOS build 默认项**:本 worktree 已固化 `.xcodebuildmcp/config.yaml` + `.xcodebuildmcp/README.md`; 新 Codex 窗口先 `session_show_defaults`,若 profile 不是 `ios` 就 `session_use_defaults_profile({ profile: "ios" })`,然后 `build_run_sim()`。main 默认 simulator 固定 `iPhone 17 Pro`; UIUE worktree 用独立 simulator,不要共用同一台(同 bundle id 会互相覆盖)。
- 🔴 **make-verify-gate = 已自动化,不做 skill**:改 `contracts/` / codegen / spec 后**必跑** `make verify`(verify-source→regen→verify-refs→verify-cross-section→verify-surface→diff→test)或 `make verify-all`(+`swift test`)——mechanical fail-closed 门(claim-vs-reality 机械化),非文档技能。
- **maformac-onboard = 起手读链**(本文件顶部 + §9 已定),不另做 skill。

## 4. 技术栈 & 架构（已锁,改动走 openspec change + 入 decisions）

- **平台**:macOS 主演示面（Q2=C 2026-07-07：iOS 一律冻结不动,实机演示废弃,门与 UITests 保留不删）+ SwiftUI 一套,无后端。
- **大脑**:Qwen3-**1.7B + LoRA = 候选主线**(先 1.7B 推进,**不前置 benchmark**;0.6B 为轻量 fallback;FoundationModels 仅 baseline/逃生口)。`LLMBackend` 协议可换 → 主 `mlx-swift-lm`,备 `llama.swift`/llamafile。
- **语音**:ASR 走 `ASRBackend` 抽象——**系统 SFSpeechRecognizer 系统识别为主(demo 取巧,on-device 离线)+ sherpa-onnx/WhisperKit fallback(不砍,要开发)**(🔴 D14 已 amend:sherpa 主→系统主,见 `docs/grill-tournament/grill-decisions-master.md:203` §4.6 + U28;旧 Paraformer≫Whisper 中文抗噪依据降为 fallback 选型理由保留:热词仅 transducer 模型可选门,Paraformer 路线靠拼音 fuzzy+封闭词表+LoRA音近);**文本先行**(开发序,D15)、ASR 必交付;barge-in 首版按钮打断(D13)。
- **车控**:全 mock(D16)——**端状态自包含 = UI 卡片亮暗 + TTS 模拟**,无外部系统方。
- **架构**:理解→**三层路由(规则 NLU / 意图收缩 clarifyTag→FC 泛化 / 慢思考)**→规划→安全门→**分层执行兜底(L1 精做 / L2 通用 mock / L3 越界 / L4 安全)**+ barge-in 包裹 + DialogueState 贯穿。
- **核心抽象**:`Capability` + 统一 `Tool` schema + **契约 SSOT = `semantic-function-contract`(C1,源行级全集)+ `scenario-state-protocol`(C2,场景端态)**(模型/规则/UI/eval/LoRA 数据皆派生;`value` 四件套 + device×动作原语×槽三元 + clarifyTag)。
- **规则 vs 模型**:规则吃 80% 高频明确,LLM 只碰 20% 模糊/跨域;**LoRA 全量必做**(练"模糊说→跨域映射",加权采样非笛卡尔积)。
- **不丢脸**:客户随意说全集 → 语义广听懂(LoRA)+ mock 分层兜底(L1 ~10 精做 / L2 广覆盖),不只 8 个窄 case。
- **多 domain**:P1 车控;导航/音乐/外卖 via MCP 二期。
**全功能闭环定义（MG-7=C,D-117）**：Phase1 车控+文本主交互+AVSpeechSynthesizer TTS;真 ASR 与 MCP 不进硬门;惊艳只进 operator review。能力面真值（task3 teardown 2026-07-07）：ir_map 562/mounted 1/120 格仅 1 格可演,扩面走 roadmap Line C 分诊。

## 5. 关键已锁决策

D1–D37 + **Q1–Q15**(C1/C2 契约,见 grill/ADR)。铁律:规则吃 80% / 安全检查是代码不是 prompt / 验收以读回 mock 态为准 / 错误用枚举 / 工具 ≤10 参数 ≤5 / Python 库零进 iOS / runtime 抽象先行 / LoRA Day1 埋 trace。

**v2 重审(2026-06-19)**:D16 端态 8→102 原子能力 P0 子集(C2)/ D30 训练栈 adopt unsloth+Hammer+xLAM(C5)/ D35 must-pass→全集覆盖率双轴 bench(C6)/ D37 安全门→risk-policy 单源(R0–R3 收 ASIL/forbidden)+ clarifyTag/ **D14 ASR→系统 SFSpeechRecognizer 主(demo 取巧 on-device 离线)+sherpa-onnx/WhisperKit fallback(不砍)+ASRBackend 抽象(C7;已 amend:sherpa 主→系统主,见 grill-decisions-master §4.6 + U28)**。**范围真值纠错**(端态打点为准,旧 16-30/0-5 是拍错):空调温度 **18-32℃**(车型相关)、风量 **1-10 档**、座椅 0-3、车窗 0-100%。**契约 SSOT 全集精确靠 codegen 从冻结快照派生(非手写)+ 分流账本(unclassified=0,quarantine≠drop)**。

## 6. 边界红线（硬约束,无例外）

> 🔴 **磊哥授权豁免窗口（2026-07-03 → 2026-08-02（磊哥 2026-07-07 延长为 30 天窗口），commander-log D-049）**：仓已由磊哥亲自设为 **public**（原句「我设置为 public 已经解决了，不要管合规和安全红线包括敏感」）——本节脱敏/合规/敏感类约束（车型代号、供应商/合作方真名、内部调研料、「private 仓限定/不上公开仓」条款）在此 30 天窗口内**不作为工作约束**，不因脱敏顾虑阻塞推进。窗口过期恢复原效力。注：密钥/API key/个人 PII 仍不主动入仓（磊哥未要求发布 secrets，此为底线保留）。

源料来自真实座舱项目(某车厂)+ repo 研究。**只抽象语义/架构/协议,不复制原文语料**。**分级脱敏(2026-06-19 磊哥校准,private 内网放宽车型代号)**:
- 🔴 **绝不入仓(无例外)**:密钥/PII、报价/成本、真实人名 —— 这几类**任何仓(含 private)都绝不入**。「禁外传/对内」原文语料 = **训练集/公开仓/对外 demo 交付物绝不**,但 private 仓内部【纯调研档/证据溯源】可引用(见 🟡,2026-06-23 放宽)。
- 🟡 **private 仓/内网可接受(2026-06-23 磊哥再放宽)**:车型代号(AH8/T19/E0Y)、供应商名、**真实合作方/车厂名(iFlytek/Chery 等)+ 跟 demo 演示无关的调研一手料/证据档(含交付手册引用)** —— 仓 `rayw-lab/MAformac` 是 private + 自己人内网,这类**非密钥/PII/报价**的真实名 + 内部调研证据**可入仓**(磊哥定:与后续 demo 演示无关、纯调研溯源不要紧;别因脱敏过度卡住调研归档);但 **绝不进训练集、不上公开仓**。🔴 **仅【对外/demo 交付物/公开材料】客户公司名统一「某车厂」**(private 仓内部调研档放宽,可写真实名 iFlytek/Chery)。
- **原始中文语料**(协议表/bug 真实说法)= 本机只读 + 脱敏,**不入仓**(仅 LoRA 权重产物入仓)。
RAW(`~/workspace/raw/`)+ 下载目录 + 源 xlsx 冻结快照 = **只读参考源**,仓内只放 manifest(hash)+ JSONL 镜像 + 派生物。仓已上云 `rayw-lab/MAformac`(private)。

## 7. 协作约定（给未来 Claude）

- 称呼「磊哥」;默认中文;术语首现「中文（English）」。所有文档、计划、派单提示词、subagent 提示词、verdict、handoff、receipt、closeout、审计报告和项目内容默认必须用中文写；仅代码标识符、命令、文件路径、API 名、协议字段、外部原文引用和必要英文专有名词可保留英文。该规则同时适用于 main 主线 `/Users/wanglei/workspace/MAformac` 与 UIUE 隔离目录 `/Users/wanglei/workspace/MAformac-uiue`。**选择题打字列选项 + ⭐默认,不用 AskUserQuestion 弹窗**(磊哥环境看不到弹窗)。
- 分工:磊哥拍板;Claude+codex 脑暴定 what(CC↔codex grill);**Claude 管前端+原型 + 契约设计**;Codex 代码长跑(TDD)+ 脑暴对手;GPT Pro 云端审 PR/设计。详见 collaboration-and-roles.md。
- **solo demo 轻治理**:能取巧的运行时灵活取巧,但 **LoRA / 安全门控 / 能力治理 / 契约 SSOT 不省**。
- 选择题给 ⭐ 默认 + 量化,不制造决策疲劳。
- **文档先行 + agree before build**:🔴**文档先行**(磊哥 2026-06-23 定,A2 重型重构实证)=重大重构/派单前先把 spec/契约/级联/grill 文档做对再动代码;**文档级联工作量巨大,务必仔细梳理全仓库**(grep 全仓定位过期锚点,meta 清单逐文件判改);spec 未对齐不写实现代码;**想清楚未做不起 propose**;**重大设计先讨论别急执行**(2026-06-19 教训,见 memory)。

## 8. 维护纪律（经常回忆更新）

本宪法 + `collaboration-and-roles.md` + 默认路线 + decisions + `openspec/config.yaml` 是**活文档**:
- 重大决策/路线调整/协作方式变化 → **立即回写**对应文件(基建文档级联,相关都更新)。
- 新 session 起手回忆;阶段推进(S→S)时复核路线与 decisions 是否仍成立。
- 三工具协作的实际命中与盲点 → 回写 collaboration §7。
- 🟢 **harness enforce 层已上线(2026-06-22)**:cite-verify 纪律从 rule 下沉 hook —— ① 冷开新窗口自动注入最近 handoff(H1 防失忆)② 写进基线文档/contracts 的 load-bearing 数字做 **value-in-source** 核(凭印象/失效引用 flag/block,JSON 数字 source 用 `file.json#字段`)③ `make verify` 跑 `verify-cross-section`(基线文档组段间一致)。逃生 `export HARNESS_ENFORCE_DISABLED=1`。详 `docs/lessons-learned.md #50` + 决策 `docs/c5-recovery-2026-06-22/grill-decisions-amend-harness-audit-enforce.md`(实装状态段)。**它 enforce 的正是本节「基建文档级联」**——写错数字/段间分叉会被机械拦。

## 9. 下一步：roadmap v5 daywork 现态（C6 done 起点 -> macOS app 全功能闭环）

> **当前推进事实源 = `docs/roadmap-2026-07-07-macos-closure-baseline.md` active_baseline_v5 + `docs/commander-log/decisions.md` D-114~D-126 + 最新 `docs/handoffs/` + `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-08-daywork/` reports。**
>
> 本段是冷启动路由牌，不替代 OpenSpec specs、grill SSOT 或 run-dir receipts。若 `docs/CURRENT.md`、旧 handoff、旧 memory 与本段冲突，以 live roadmap/decisions/run-dir report 为准，并同笔刷新 stale 指针。
>
> Proof boundary：local/mock/runtime/macOS desktop 证据不得写成 mobile、true-device、C5 V-PASS、C6 acceptance 或 live proof。S8 完成后仍需 S9 三臂 eval -> S9b -> S10 verdict；candidate 在正式签署前恒 unsigned。

### 当前四线

- **Line A / 架构健康**：任务①精简收口后进入小刀阶段。A0 FastPath noMatch crash 已修（commit `7619e591` 在当前分支与 `origin/main`）；A1/A2/A3/A4/A5 仍按 roadmap v5 分刀推进。A3 God-file 拆分已有隔离 worktree/分支执行，主树仍不因该类机械活直接扩 scope。
- **Line B / register-window + 训练链**：S4/S5/S6/S7/S7b/host/RECERT 链已留档。S8 r1/r2 均中断且无 checkpoint，当前仍是 **fresh full 1800 重启待磊哥令**，不是续跑、不是 running、不是 completed。S8C 已把 23:30 前置 checklist 脚本化并 dry-run rc0 输出 READY；S8F 已修一行点火命令分号残余并重核 RECERT sha `44dd5b08...`。当前计划语义 = 今晚约 24:00，磊哥确认不用机后由 commander 跑 preflight，再按终版命令点火。
- **Line B / S9 holdout**：D-122 Opus raw 生成后，J1 全量判 47/64 PASS，触发 D-124 修复战役。D-124 已拍：near-dup 三方合成剔 10 真撞、救 3 FP，register 用既有 `imperative` + `register_subtype` 修 4 行，补 10 行 per-bucket。修复链 J2（剔8）→补5（预检零撞）→J3→args 修正→**J4 全绿 61/61 → 已 sha 冻结**（`77853cae…`，61 行四桶 33/9/10/9，canonical=s9-eval-freeze/holdout/，D-127）。holdout=FROZEN，S9 弹药就绪只等 S8 adapter。
- **Line B / S9 预备 checker**：stop_event / mount-validity 预备件可用；train-eval exposure checker 仍 `STILL_OPEN`，不得写成 repo gate landed 或 GATE_HAS_TEETH。
- **Line C / 能力面**：D-123 已签矩阵 v3 为 **DemoCapabilityMatrix SSOT**。SSOT 内容为 120 守恒四类：`safety_or_clarify_reject=0 / unmounted_name_rejected=36 / fast_path_no_match_fallback=82 / default_executable=1 / conditional_ddomain_executable=1`。落仓位置与 checker 实装留 C1 grill；BATCH2/BATCH-INFRA 已全按星标拍定，Q-SR=A，联合出手率公式 = `min(hedged, can-question)`。
- **Line D / macOS app UIUE + runtime**：roadmap v5 已把 Line D 验收门升为 v2，内联 UIUE 方法论包 P0/P1 与 aesthetic 5 Gate。D-125 已把 D0 UIUE grill 43 题全按星标 RATIFIED；后续先做消减表级联 -> D1a 实施计划修订 -> 红队复审，再编码。D1a 红队 P1×7 已吸收成计划 v2（EXECUTABLE_V2）；D-126 磊哥双拍招牌微交互（①orb→卡片能量流动线 ②10 卡入场瀑布），T1/T4/T6 已开工（资源窗：S8 active 禁 full build）。

### ma9 蜂群与分工

- 旧 ma7/ma8 pane id 全部 historical only，禁止复用。
- 当前 ma9 live readback（2026-07-08 约 19:20）：`%0` commander，`%1/%3/%6` codex，`%8` Opus；Hermes 席已撤。pane roles 会漂移，任何派单前必须重新跑 `tmux list-panes -t ma9:0` 并逐 pane capture 亲核 vendor/model。
- D-125 编码分工令：**Opus = UIUE 视觉代码位**，必须使用 `Tools/agent-platform-plugin-refs/` 与 `Tools/skills/` 的既有肩膀；codex = 交互、逻辑、runtime、机械门、测试与红队；commander = grill 主刀、视觉决策、亲核验收。
- UIUE 视觉不得交给 codex 独立主刀。codex 可做 hover/click/keyboard、MicDock、force-state、runtime event、错误注入、性能采样、测试 harness 等交互/runtime 层。

### 当前待办与人审键

1. **S8 重启令**：今晚约 24:00 磊哥不用机时，commander 先跑 `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-08-daywork/s8-preflight-check.sh`，全部 PASS 后复制终版点火命令。任何 blocker 都 exit 65 停，不真点火绕过。
2. ~~holdout v3 判定链~~ ✅已收官（D-127：J4 61/61 全绿+sha 冻结+canonical 落位）。
3. **D1a 修订**：吸收红队 `EXECUTABLE_WITH_FIXES` 的 P1/P2，尤其 T6 主屏 anchor 与 force-state 证据拆分、90 分 motion/MX1 owner 或等价清单。
4. **C1/C2 后续**：矩阵 v3 已签内容 SSOT，但落仓位置、checker、扩挂载第一批仍按 C1 grill / S10 verdict 承接。
5. **Line A 小刀**：A1/A2/A3/A4/A5 独立分支/receipt/verify-all，不抢 S8 训练资源。

### 起手读链

1. 本文件 `CLAUDE.md`。
2. `docs/CURRENT.md`（router-only；若 stale，以 roadmap/decisions/handoff/run-dir reports 更新）。
3. `docs/roadmap-2026-07-07-macos-closure-baseline.md` active_baseline_v5。
4. `docs/commander-log/decisions.md` D-114~D-126，尤其 D-123/D-124/D-125。
5. `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-08-daywork/` 的 latest reports/receipts。
6. Line D 编码前必须读 `Tools/agent-platform-plugin-refs/` 对应 macOS/iOS skill references 与 `Tools/skills/INDEX.md`；这些是“照做”的肩膀，不是可选参考。

### 训练已锁结论（防失忆）

- 模型：Qwen3-1.7B（不换 2B/LFM2.5；无 Qwen3-1.8B，那是老 Qwen）。
- 训练后端：本机 `mlx-lm 0.31.1`（`omlx` 是推理 GUI 非训练；云 NVIDIA drop）。
- masking 两类机制：`train_on_turn`=loss mask；`function/arg_name` + `arg_value`=受约束数据增广（distractor_only）。
- `argument_value` 按 `value.type` 分流：SLOT 抠槽随机化 / EXP 逆规整感受词变体。
- 端侧 8GB <= 2B；`mlx-swift` 端侧最优。
- value 四件套/抠槽/逆规整范式见 `docs/baseline-semantic-protocol-2026-06-19.md` MASTER + `CONTEXT.md`。
- 范式权威仍是 D-domain 具名工具，见 `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`；562=intent 终盘口径，禁止再用旧 534/2086 系列。

### 架构铁律

大脑是**三层意图路由**：L1 精确指令走规则快路秒回不碰模型；只有 L2-L5 模糊/多意图/记忆/复杂推理走慢路 Qwen+LoRA。两核心能力：**意图收缩**（NLU 主动弃权模糊说法 -> 路由慢路）+ **落域**（分发垂域 + 多轮锁域）。demo 价值 = 路由对 + 泛化 + 拒识 + 安全门。全料见 `docs/srd-three-layer-intent-routing.md`。

### Non-claims

- S8 未点火、未 running、未完成。
- S9/S9b/S10 未执行（holdout 已 FROZEN 但 manifest/三臂 eval 未跑）。
- D1a 计划还在吸收红队 fixes；未进入无修编码态。
- exposure checker 未关闭，未落 repo gate。
- macOS UIUE 未达 operator-pass；iOS 实机演示仍废弃，iOS 门与 UITests 仅保 regression。
- candidate 未签；无 C5 V-PASS、无 C6 acceptance、无 mobile/true-device/live proof。

### 历史溯源

2026-06-22 至 2026-07-07 的旧 §9 长历史（0/34 复盘、范式翻案、A2 重构、default_scope、R-L17、Long-run 2、文档级联、旧起手链）应归档为 historical provenance。旧段与现段冲突时，以本段 + roadmap v5 + decisions D-114~D-126 + 最新 handoff/run-dir report 为准。

# GitNexus — Code Intelligence

This project is indexed by GitNexus as **MAformac-r5-main-current** (35887 symbols, 63994 relationships, 300 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.

> Index stale? Run `node .gitnexus/run.cjs analyze` from the project root — it auto-selects an available runner. No `.gitnexus/run.cjs` yet? `npx gitnexus analyze` (npm 11 crash → `npm i -g gitnexus`; #1939).

> ⚠️ 措辞校准（2026-07-07 外审🔴5 吸收，MT5 e6738d6b；本段防 gitnexus rerun 冲掉）：下述条款为**强烈建议（advisory）**，无 hook/CI 机械承接。真机械门 = `make verify` 链 + pre-commit checkers + swift test；GitNexus 是辅助导航层。

## Always Do（advisory）

- **MUST run impact analysis before editing any symbol.** Before modifying a function, class, or method, run `impact({target: "symbolName", direction: "upstream"})` and report the blast radius (direct callers, affected processes, risk level) to the user.
- **MUST run `detect_changes()` before committing** to verify your changes only affect expected symbols and execution flows. For regression review, compare against the default branch: `detect_changes({scope: "compare", base_ref: "main"})`.
- **MUST warn the user** if impact analysis returns HIGH or CRITICAL risk before proceeding with edits.
- When exploring unfamiliar code, use `query({query: "concept"})` to find execution flows instead of grepping. It returns process-grouped results ranked by relevance.
- When you need full context on a specific symbol — callers, callees, which execution flows it participates in — use `context({name: "symbolName"})`.

## Never Do

- NEVER edit a function, class, or method without first running `impact` on it.
- NEVER ignore HIGH or CRITICAL risk warnings from impact analysis.
- NEVER rename symbols with find-and-replace — use `rename` which understands the call graph.
- NEVER commit changes without running `detect_changes()` to check affected scope.

## Resources

| Resource | Use for |
|----------|---------|
| `gitnexus://repo/MAformac-r5-main-current/context` | Codebase overview, check index freshness |
| `gitnexus://repo/MAformac-r5-main-current/clusters` | All functional areas |
| `gitnexus://repo/MAformac-r5-main-current/processes` | All execution flows |
| `gitnexus://repo/MAformac-r5-main-current/process/{name}` | Step-by-step execution trace |

## CLI

| Task | Read this skill file |
|------|---------------------|
| Understand architecture / "How does X work?" | `.claude/skills/gitnexus/gitnexus-exploring/SKILL.md` |
| Blast radius / "What breaks if I change X?" | `.claude/skills/gitnexus/gitnexus-impact-analysis/SKILL.md` |
| Trace bugs / "Why is X failing?" | `.claude/skills/gitnexus/gitnexus-debugging/SKILL.md` |
| Rename / extract / split / refactor | `.claude/skills/gitnexus/gitnexus-refactoring/SKILL.md` |
| Tools, resources, schema reference | `.claude/skills/gitnexus/gitnexus-guide/SKILL.md` |
| Index, status, clean, wiki CLI commands | `.claude/skills/gitnexus/gitnexus-cli/SKILL.md` |

<!-- gitnexus:end -->
