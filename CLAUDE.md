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
| `.xcodebuildmcp/` | **本 worktree 的 Codex iOS build 默认项**:`config.yaml` 固化 `build-ios-apps` profile; `README.md` 写新窗口使用顺序。UIUE 默认 profile=`ios` → scheme=`MAformacIOS` → simulator=`iPhone 17 Pro Max` |

> `docs/` 放**设计资产**(相对稳定);`openspec/` 放**活的推进事实源**(随 archive 生长)。互补不重复。

### 技能沉淀与验证门(2026-06-24,superpowers v6.0.3)

- **沉淀技能** `Tools/skills/`(symlink 到 `.claude/skills/`,source 在 Tools/):4 BUILD = `archive-research-pack` / `verify-external-claims` / `doc-cascade-sweep` / `closeout-receipt-writer`(用 superpowers `writing-skills` 的 TDD-for-skills 法建,baseline 取 production 实证)。**通用流程直接用 superpowers v6**(`writing-plans` / `subagent-driven-development` / `test-driven-development` / `verification-before-completion` / `using-git-worktrees`;plugin `superpowers@claude-plugins-official` **6.0.3** enabled)。索引 + adopt 组合替代链路 = ⭐`Tools/skills/INDEX.md`。
- **平台插件引用** `Tools/agent-platform-plugin-refs/`:本机软链接索引,不是项目源代码。后续前端/后端运行时/UIUE/视觉/打包相关 agent 起手应读取其中 `build-ios-apps-*` 和 `build-macos-apps-*` 的 `SKILL.md`/references,再写实现或评审。
- **Codex iOS build 默认项**:本 worktree 已固化 `.xcodebuildmcp/config.yaml` + `.xcodebuildmcp/README.md`; 新 Codex 窗口先 `session_show_defaults`,若 profile 不是 `ios` 就 `session_use_defaults_profile({ profile: "ios" })`,然后 `build_run_sim()`。UIUE 默认 simulator 固定 `iPhone 17 Pro Max`; main worktree 用独立 simulator,不要共用同一台(同 bundle id 会互相覆盖)。
- 🔴 **make-verify-gate = 已自动化,不做 skill**:改 `contracts/` / codegen / spec 后**必跑** `make verify`(verify-source→regen→verify-refs→verify-cross-section→verify-surface→diff→test)或 `make verify-all`(+`swift test`)——mechanical fail-closed 门(claim-vs-reality 机械化),非文档技能。
- 🔴 **项目 build / test 命令**(实证过,UIUE/前端实装验收用;主线已配 scheme + build 插件引用):
  - **单测**:`swift test`(Core 单元测试,实证 222/0)。
  - **本地验收门**:`make verify`(无 swift test) / `make verify-all`(= swift test + make verify,完整门,D1 决策本地替 CI)。
  - **双端 build**:`xcodebuild -scheme **MAformacMac** -destination 'platform=macOS' build` / `xcodebuild -scheme **MAformacIOS** -destination 'platform=iOS Simulator,name=<sim>' build`——🔴 **scheme 是 `MAformacMac`/`MAformacIOS`,不是 `MAformac`**(codex 曾用错 scheme)。
  - **iOS 模拟器 build+视觉验证**:`Tools/skills/ios-simulator-skill/scripts/build_and_test.py` + `simctl`(force-state 截图:launch arg `-forceVisualState <态>`,见 `App/DebugGallery.swift`)。
  - **实装前先读** `Tools/agent-platform-plugin-refs/build-{ios,macos}-apps-skills/` 的 `swiftui-liquid-glass`/`liquid-glass`/`swiftui-ui-patterns`/`build-run-debug`/`ios-simulator-browser` SKILL.md(CLAUDE §73 纪律)。
- **maformac-onboard = 起手读链**(本文件顶部 + §9 已定),不另做 skill。

## 4. 技术栈 & 架构（已锁,改动走 openspec change + 入 decisions）

- **平台**:macOS + iOS,SwiftUI 一套,无后端。
- **大脑**:Qwen3-**1.7B + LoRA = 候选主线**(先 1.7B 推进,**不前置 benchmark**;0.6B 为轻量 fallback;FoundationModels 仅 baseline/逃生口)。`LLMBackend` 协议可换 → 主 `mlx-swift-lm`,备 `llama.swift`/llamafile。
- **语音**:ASR 走 `ASRBackend` 抽象——**系统 SFSpeechRecognizer 系统识别为主(demo 取巧,on-device 离线)+ sherpa-onnx/WhisperKit fallback(不砍,要开发)**(🔴 D14 已 amend:sherpa 主→系统主,见 `docs/grill-tournament/grill-decisions-master.md:203` §4.6 + U28;旧 Paraformer≫Whisper 中文抗噪依据降为 fallback 选型理由保留:热词仅 transducer 模型可选门,Paraformer 路线靠拼音 fuzzy+封闭词表+LoRA音近);**文本先行**(开发序,D15)、ASR 必交付;barge-in 首版按钮打断(D13)。
- **车控**:全 mock(D16)——**端状态自包含 = UI 卡片亮暗 + TTS 模拟**,无外部系统方。
- **架构**:理解→**三层路由(规则 NLU / 意图收缩 clarifyTag→FC 泛化 / 慢思考)**→规划→安全门→**分层执行兜底(L1 精做 / L2 通用 mock / L3 越界 / L4 安全)**+ barge-in 包裹 + DialogueState 贯穿。
- **核心抽象**:`Capability` + 统一 `Tool` schema + **契约 SSOT = `semantic-function-contract`(C1,源行级全集)+ `scenario-state-protocol`(C2,场景端态)**(模型/规则/UI/eval/LoRA 数据皆派生;`value` 四件套 + device×动作原语×槽三元 + clarifyTag)。
- **规则 vs 模型**:规则吃 80% 高频明确,LLM 只碰 20% 模糊/跨域;**LoRA 全量必做**(练"模糊说→跨域映射",加权采样非笛卡尔积)。
- **不丢脸**:客户随意说全集 → 语义广听懂(LoRA)+ mock 分层兜底(L1 ~10 精做 / L2 广覆盖),不只 8 个窄 case。
- **多 domain**:P1 车控;导航/音乐/外卖 via MCP 二期。

## 5. 关键已锁决策

D1–D37 + **Q1–Q15**(C1/C2 契约,见 grill/ADR)。铁律:规则吃 80% / 安全检查是代码不是 prompt / 验收以读回 mock 态为准 / 错误用枚举 / 工具 ≤10 参数 ≤5 / Python 库零进 iOS / runtime 抽象先行 / LoRA Day1 埋 trace。

**v2 重审(2026-06-19)**:D16 端态 8→102 原子能力 P0 子集(C2)/ D30 训练栈 adopt unsloth+Hammer+xLAM(C5)/ D35 must-pass→全集覆盖率双轴 bench(C6)/ D37 安全门→risk-policy 单源(R0–R3 收 ASIL/forbidden)+ clarifyTag/ **D14 ASR→系统 SFSpeechRecognizer 主(demo 取巧 on-device 离线)+sherpa-onnx/WhisperKit fallback(不砍)+ASRBackend 抽象(C7;已 amend:sherpa 主→系统主,见 grill-decisions-master §4.6 + U28)**。**范围真值纠错**(端态打点为准,旧 16-30/0-5 是拍错):空调温度 **18-32℃**(车型相关)、风量 **1-10 档**、座椅 0-3、车窗 0-100%。**契约 SSOT 全集精确靠 codegen 从冻结快照派生(非手写)+ 分流账本(unclassified=0,quarantine≠drop)**。

## 6. 边界红线（硬约束,无例外）

源料来自真实座舱项目(某车厂)+ repo 研究。**只抽象语义/架构/协议,不复制原文语料**。**分级脱敏(2026-06-19 磊哥校准,private 内网放宽车型代号)**:
- 🔴 **绝不入仓(无例外)**:密钥/PII、报价/成本、真实人名 —— 这几类**任何仓(含 private)都绝不入**。「禁外传/对内」原文语料 = **训练集/公开仓/对外 demo 交付物绝不**,但 private 仓内部【纯调研档/证据溯源】可引用(见 🟡,2026-06-23 放宽)。
- 🟡 **private 仓/内网可接受(2026-06-23 磊哥再放宽)**:车型代号(AH8/T19/E0Y)、供应商名、**真实合作方/车厂名(iFlytek/Chery 等)+ 跟 demo 演示无关的调研一手料/证据档(含交付手册引用)** —— 仓 `rayw-lab/MAformac` 是 private + 自己人内网,这类**非密钥/PII/报价**的真实名 + 内部调研证据**可入仓**(磊哥定:与后续 demo 演示无关、纯调研溯源不要紧;别因脱敏过度卡住调研归档);但 **绝不进训练集、不上公开仓**。🔴 **仅【对外/demo 交付物/公开材料】客户公司名统一「某车厂」**(private 仓内部调研档放宽,可写真实名 iFlytek/Chery)。
- **原始中文语料**(协议表/bug 真实说法)= 本机只读 + 脱敏,**不入仓**(仅 LoRA 权重产物入仓)。
RAW(`~/workspace/raw/`)+ 下载目录 + 源 xlsx 冻结快照 = **只读参考源**,仓内只放 manifest(hash)+ JSONL 镜像 + 派生物。仓已上云 `rayw-lab/MAformac`(private)。

## 7. 协作约定（给未来 Claude）

- 称呼「磊哥」;默认中文;术语首现「中文（English）」。**选择题打字列选项 + ⭐默认,不用 AskUserQuestion 弹窗**(磊哥环境看不到弹窗)。
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

## 9. 下一步:新基线 roadmap(C6 done 起点 → P0 C6 收尾 → P1 C5 数据门)

> 🔁 **C5 状态更新(2026-06-22,P0 路由级联)**:PR5 通宵 wave candidate **`0/34` 已 UNSIGNED/BLOCKED**(重大失误,8D 复盘);**C5 recovery in-grill** —— recovery 推进事实源 = **⭐`docs/c5-recovery-2026-06-22/grill-decisions.md`**(已拍 Q1→ζ+θ-data:C6 真口径=action `hard_pass` 锚 base **10/23** / readback 走 **方案P**(renderer) / 两层 SSOT / `make verify` 门 / 范式据 tiny 对照实验)。下方 `roadmap-2026-06-20-from-c6-done.md` 是 **0/34 之前的旧基线**,**C5 部分以 c5-recovery 为准**(避免拿 PR5 旧定性当 SoT 续推)。**🔴 θ-α 第一刀已执行(2026-06-22):generated-positive 全 checkpoint 实测 FAIL**(训练数值健康但 C6 action 行为全塌,乱调→不调,未过 base 10/23 相对门),诊断假设(training-dynamics collapse vs `tool_call_frame`/D-domain surface mismatch)+ 方向(合θ-β/加监督/改配方/重训/调η)**均待 grill 拍,codex/CC 不自拍**。详 `docs/c5-recovery-2026-06-22/grill-decisions-amend-execution-gap-reconciliation.md §5` + `docs/lessons-learned.md` #49。
>
> 🔴🔴 **范式翻案(2026-06-22晚,第4源真实座舱 TOP技能表 ground-truth,推翻 B-frame)**:θ-α 根因深挖 = **generic frame(`tool_call_frame`)单工具判定面爆炸、1.7B 学不会**(非只 surface mismatch,working diagnosis 待 G6-C 终判)→ **model-visible surface 改 D-domain 具名工具**(value 形态编码进工具名),generic frame 作 surface **否决**(canonical IR 仍 device×action,「**对模型像 D-domain 具名工具,对系统像 device×action IR**」)。demo 取巧 = 借量产「降误吸内核」(具名工具拆判定面+受限解码)+砍量产全链路(FC→NLU→DS→DM/真控)+加炸场包装:**MVP 10 族**(空调/座椅/车窗/车门/灯光氛围/屏幕/音量/雨刮/天窗遮阳/香氛,**HUD不做**)+**单语中文 LoRA**(多语种走协议转换复用非重训)+现场只说10族(族外 unsupported 兜底)+复杂推理**预留场景宏**+多意图**连续两句**+短时记忆 DialogueState(砍长时云框架)。**范式权威 = ⭐`docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`**(§1-§17:翻案/三层模型/demo特性/多语种/过度工程化catch/**C5 LoRA 原始 21 主议题全 grill 收口(第一~四批)**/A2 代码盘点;剩 §15 GOV/CAS/TRN/UIX 35 扩散);**旧 D-vs-B G6-C 框架已 superseded**。
>
> 🔴 **A2 代码盘点完成(2026-06-22,ultracode 8 finder+综合官/9 agent/主线程亲核)**:范式翻案落代码 = **A2 重型重构**(C1→C2→C3→C5→C6 全链路从 generic frame `tool_call_frame`→D-domain 具名工具,~14-16 文件/1500-2500 行/6 步依赖序;=立项至今大部分代码改)。完整归档 ⭐`docs/research/2026-06-22-a2-codebase-audit/`(README 亲核版+lens1-8 一手档+codex-checks+INDEX;**transcript 最一手归档仓外 raw `-transcripts/`**)。🔴 **数字口径坐实**(device **191**/intent **562**(磊哥 2026-06-23 终拍,旧 534/2086/52.3% 系列全废)/工具数未拍实算;generated 旁路 223 device 过期;**562=intent 非工具数**,派单当工具数=口径错全链路)。A2 必 incremental(大爆炸=Netscape 红 flag)+守 rank16Mainline 配方+parity gate 相对不退化(base hard_fail)+frame surface 显式移除;不对齐 16 处全表+8 grill 弹药见 README/§17。**A2 派单前必读 README**。
>
> 🟢 **文档级联长跑收口 + push(2026-06-23)**:范式/口径562/grill SSOT/UIUE U1-31 全量文档级联完成,commit `dca1000` → push **`doc-cascade/paradigm-d-domain-562-contracts`** 分支(private 仓)。grill SSOT 单源 = `docs/grill-tournament/grill-decisions-master.md`(锦标赛41+UIUE U1-31挂Q30-38;§15/GRILL-MASTER 标 historical;Q15/CAS1 已执行)+`cascade-inventory.md`(T0-T6 全量级联清单)+4 OpenSpec change skeleton(DRAFT 待propose)+loopaudit/precommit 各2轮审计留痕。**口径终拍 562**(磊哥2026-06-23,534/2086/52.3% 全废)。§6 脱敏放宽(private仓内部调研档可入真实名 iFlytek/Chery)。`lessons-learned` **G段**(7条本次教训)+ **`~/.claude/skills/loopaudit/`** 已沉淀(维度分工≥3agent+留痕+收敛定律修复+假clean修复)。
>
> 🔴 **下一步 = A2 代码重构(code-only 范式对齐)**(C1→C2→C3→C5→C6 generic frame→D-domain 具名工具):🔴🔴 **A2 边界(磊哥 2026-06-23 校准)= 让代码说 D-domain + 编译/`swift test`/`make verify` 绿,「代码对齐范式文档」**;**不训练/不评测模型性能/不生成语料**。🔴 **训练 + 后端开发 DEFERRED 延后不排期**(C5 数据生成·C5 实际重训·C6 四层门·C6 评测验证模型性能·demo-golden-run·voice ASR/TTS·受限解码 vendor,A2 之后独立重新立项)。**A2 只绑 `migrate-d-domain-tool-surface` change(code-only)**;retrain-c5/rebuild-c6/golden-run 标 DEFERRED(code-only surface 随 A2,训练/评测/数据延后)。磊哥定 **CC 主窗口主持 + 全程 `/goal` 状态自驱 + ultracode(每step 派 workflow+主线程亲核+subagent审并行+loopaudit收口),不派 codex 长跑**。6 步依赖序+横切纪律+enforce 简化(cross-section 扩活基线全/SSOT codegen/减文档数)+ codex/GLM 双源审计 findings(P1 边界/scope_tier 缺字段硬前置/parity gate 重定义)已并入**派单 `docs/dispatches/2026-06-23-a2-code-refactor-cc-ultracode-dispatch.md`(v2)**。起手回看决策文件(codex 失败 lora 至今全链路):grill-decisions-master / paradigm-amend / `~/.claude/rules/claim-vs-reality-gap.md` / cascade-inventory。
>
> 🔴 **Post-A2 default_scope 前置 blocker(2026-06-24,G01-G28 已拍)**:A2 已合 main 后,不得直接 retrain-c5 / rebuild-c6 / demo-golden-run。`define-demo-default-scope` Phase -1 OpenSpec carrier 已 materialize 并获准进入 apply,但物理实现尚未开始。权威决策包 = `docs/grill-tournament/demo-default-scope-grill-decisions-2026-06-24.md`;Phase -1/Phase0 溯源计划 = `docs/superpowers/plans/2026-06-24-phase0-d1-d10-openspec-gates.md`;当前 apply 计划 = `docs/superpowers/plans/2026-06-24-default-scope-apply.md`(same-vendor plan pre-check `CLEAR_WITH_FIXES` 已吸收,不等于 R-L17 通过)。下一步只能按 apply 计划落实 C2 `default_scope`、C3 target resolution、state applier、readback `scope_origin`、C5/C2 parity、C6 default-scope gold 与三道机械门。未完成前不得启动训练、C6 重建验收、真实评测、voice 或 demo-golden-run。
>
> 🔴 **R-L17 deframing blocker(2026-06-24)**:R-L17 不是多模型 majority vote,而是 high-stakes human + heterogeneous deframing gate。D1-D10 已拍,但 R-L17 G1-G5 未全过前,`retrain-c5` / `rebuild-c6` / `demo-golden-run` 仍 BLOCKED/DEFERRED。证据目录 = `docs/project/phase0/r-l17-human-review-evidence/`;R1-R7 每项必须有 artifact,file:line/row id/verdict;≥1 异源判官(非 Claude-family)独立反框审计;Codex/Claude same-vendor 只算 pre-check;4 模型一致 PASS 不放行,反而触发 human-owner R7 复核。

**⚠️ 推进事实源已迁移(Q22 已拍,2026-06-23 grill-decisions-master §2 Q22)**:`docs/roadmap-2026-06-20-from-c6-done.md` 是 **`0/34`+范式翻案前的旧基线**,**已标 historical**,不再是「唯一推进事实源/必读第一」。当前推进事实源 = **grill SSOT `docs/grill-tournament/grill-decisions-master.md`(grill 决策单一权威) + 范式翻案权威 `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + 级联账本 `docs/grill-tournament/cascade-inventory.md`**;A2 正式 OpenSpec change 的 exec-plan 收口后转为 progress SSOT(Q22 候选)。下方旧 roadmap 内容(五件套 harness 骨架 + P0/P1/P2 执行序 + file:line + 坑点 + 依赖图)仍有溯源价值,但 C5/范式部分以上述新权威为准。

**新基线快照**:
- ✅ C1 `semantic-function-contract` / C2 `scenario-state-protocol` **archived → `openspec/specs/`**
- ✅ C3 `define-execution-contract` **archived → `openspec/specs/tool-execution/`**;7.3 Qwen sampling 未实测,已迁移到 P1-B Qwen spike,不得写成 C3 已测
- ✅ C6 `define-vehicle-tool-bench` **archived → `openspec/specs/vehicle-tool-bench/`**;P0-1/P0-2/P0-3/P0-4 已收口,archive-check `verify-gold` pass;base Qwen3-1.7B 无 LoRA **hard_fail**(IrrelAcc 0.789<0.9)= C5 提升诚实锚点
- 旧 7-change 已 park → `openspec/changes/_parked/`

**当前断点 = C5 apply 实装(2026-06-21:P1-C grill Q11-Q18 收口 + 派单就绪,等 codex 自主跑)**。P1-A/B 收口(846e40c)后 2026-06-21:① grill Q11-Q18 全收口(数据/masking/generator/validator/lineage/smoke/train/eval/parity,`docs/p1c-training-grill-decisions.md`)② probe generator 三权分立(`docs/research/2026-06-21-c5-generator-selection-probe.md`,本机 generator 错→多源云)③ C5 apply 派单(hermes GLM-5.2 异源 + subagent CC 双审,**2 BLOCKER[B1 enable_thinking offset 过冲 / B2 dev_selection 撞 spec.md:4]已修**,`~/workspace/raw/05-Projects/MAformac/dispatches/2026-06-21-c5-lora-training-apply-dispatch.md`)④ 元认知大沉淀(read-first 四腿 / 顶层 §31)⑤ hermes 调用修复(`.claude` wrapper `--prompt-file` 坏→`--prompt "$(cat)"`)。**下一步=派 codex 自主实装**;handoff `2026-06-21-p1c-grill-closeout-c5-apply-dispatch.md`。**↓以下原『P1-C 需 grill』详情已被 2026-06-21 grill 解决,留史**:
- ✅ **P1-A C5 数据门 V-PASS**(`define-lora-data-gate` change + C5DataGate validator + receipt 3670 行;must_not_train=0/parent_overlap 真 0/C6+12 trap 零进 train/validator exit65 真阻断/raw 只读不入仓)。⚠️ **masking_coverage 全 false 如实记录**(未实现 masking 三形态)= P1-C 硬前置未完。
- ✅ **P1-B Qwen spike BLOCKED → 模型已定=训 Qwen3-1.7B**(S1 实采:Qwen3.5-2B 8/11=72.7% 全面劣于 1.7B 9/11=81.8% + 无真机 S2 blocked + artifact 实为 VL 借文本塔。decision 守 1.7B)。
- ⚠️ **P1-C LoRA train 仍 blocked**,两前置:① **masking 数据生成**(masking_coverage→true,防死记 3HIGH 之一)② **训练环境未定**(unsloth 要 CUDA,Mac M5 无 N 卡 → 云 GPU or mlx-lm 本机训,须联网搜证 Mac 可行性)→ **需 grill 拍**(重大设计先讨论)。
- 两单 CC 二层对抗审计*2 CLEAR(P1-A 无泄漏/真阻断;P1-B 无权重入仓/decision 诚实,修 VL 披露)。合并态实跑 openspec 7 passed/swift test 85/0fail/make verify ok。
→ P2 C4/C7 解冻。**7 HIGH(H1-H7)磊哥已拍,见 roadmap §3。**

起手读:本文件 → **⭐`docs/grill-tournament/grill-decisions-master.md`(grill 决策 SSOT 单一权威,必读第一) + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`(范式翻案权威) + `docs/grill-tournament/cascade-inventory.md`(文档级联账本)** → `docs/roadmap-2026-06-20-from-c6-done.md`(**已标 historical,Q22**,五件套 harness 骨架溯源,C5/范式以新权威为准) → **🔑`docs/baseline-semantic-protocol-2026-06-19.md` MASTER 头 + `contracts/semantic-function-contract.jsonl`(=吃透 3990 语义范式,永不重读金钥匙 xlsx)** → `docs/srd-three-layer-intent-routing.md`(架构铁律) → `docs/research/INDEX.md`(调研/teardown 索引,P1-C 训练/选型 deepdive 在内) → 最近 `docs/handoffs/`。

> **🔴 P1-C 训练已锁结论(防 2 轮 workflow 结论失忆,详见两份 deepdive)**:守 **Qwen3-1.7B**(不换 2B/LFM2.5,"新≠强";无 Qwen3-1.8B 那是老 Qwen)/ 训练后端 **本机 mlx-lm 0.31.1**(omlx=推理 GUI 非训练;云 NVIDIA drop)/ **masking 三形态实为两类机制**:`train_on_turn`=loss mask(走 return_assistant_tokens_mask) + `function/arg_name`+`arg_value`=**受约束数据增广**(distractor_only,正例 device×primitive×value 语义不动)/ `argument_value` 按 **value.type 分流**(SPOT 抠槽随机化值+同步改 query / EXP 逆规整感受词变体)/ 端侧 **8GB≤2B** / **mlx-swift 端侧最优**。value 四件套/抠槽/逆规整范式见 🔑MASTER + `CONTEXT.md`。

> **⚠️ 架构铁律(磊哥 2026-06-19「连续多次失忆」教训,别再拍平成"全 LoRA")**:大脑是**三层意图路由**。**L1 精确指令(动词+对象+参数,如「打开空调」「打开主驾车窗」)走规则快路、秒回、不碰模型**;**只有 L2-L5 模糊/多意图/记忆/复杂推理走慢路 Qwen+LoRA**。两核心能力:**意图收缩**(NLU 主动弃权模糊说法→路由慢路,不硬塞规则——"多一字少一字"靠泛化不靠堆规则)+ **落域**(分发垂域+多轮锁域)。demo 价值=路由对+泛化+拒识+安全门,非命中话术。全料见 SRD。
