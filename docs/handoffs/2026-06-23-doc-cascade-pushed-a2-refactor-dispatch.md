# Handoff — 文档级联长跑收口 + push + A2 重构 dispatch（2026-06-23）

## 本 session 完成
- 🟢 **文档级联长跑收口 + push**：范式翻案/口径 562/grill SSOT/UIUE U1-31 全量级联完成，commit **`dca1000`** → push **`doc-cascade/paradigm-d-domain-562-contracts`** 分支（private 仓 rayw-lab/MAformac，GitHub PR 链接已出）。
- **口径终拍 562**（磊哥 2026-06-23 亲拍，534/2086/52.3% 系列全废）全仓统一。
- **grill SSOT 单源** = `docs/grill-tournament/grill-decisions-master.md`（锦标赛 41 题 + UIUE U1-31 挂 Q30-38；§15/GRILL-MASTER 标 historical；Q15/CAS1 已执行）。
- **cascade-inventory.md**（T0-T6 全量文档级联清单）+ **4 OpenSpec change skeleton**（DRAFT，守 agree-before-build：migrate-d-domain-tool-surface / retrain-c5-lora-d-domain / rebuild-c6-four-layer-bench / define-demo-golden-run-and-voice）。
- **UIUE U1-U31 全拍**（系统 ASR 主+sherpa/Whisper fallback 不砍+ASRBackend 抽象 / TTS 系统朗读 / U5 Metal 一期 / U6 麦克风 key+memory entitlement / U10·U27 状态四态 / U12 XcodeGen P1 / U19·U30 #available / U28 中文 TTS preflight）。
- **loopaudit skill 沉淀**（`~/.claude/skills/loopaudit/`：维度分工 ≥3 agent + 留痕 round-NN/audit + 收敛定律[修复⊇审计⊇执行] + 假 clean 修复）。
- **lessons-learned G 段**（7 条：多 workflow 狂派乱 / loopaudit 收敛定律 / 假 clean / Reports 2.8G 差点入仓 / 标 modify≠已 modify / 主线程亲核>信 workflow）。
- **§6 脱敏放宽**（private 仓内部调研档可入真实名 iFlytek/Chery）+ Reports θ-α 2.8G 移出跟踪（gitignore）。
- **enforce 现状**：make verify cross-section（c5-recovery + grill-tournament + 口径 562 caliber anchor）+ cite-verify hook + Makefile diff gate；⚠️ 覆盖不全（BASELINE_GLOBS 不含 CLAUDE/SRD/MASTER/CONTEXT/INDEX/research；CALIBER_ANCHORS 只 562）。

## 当前状态
- doc-cascade 分支已 push（private，可建 PR）。HEAD `dca1000`。
- A2 代码重构待启动（文档先行已就绪）。git 工作树：Reports 2.8G 本地保留已 gitignore；h5-preview.png orphan 未入仓。

## 🔴 下一步 = A2 代码重构（code-only 范式对齐，C1→C2→C3→C5→C6 generic frame→D-domain）
- 🔴🔴 **A2 边界（磊哥 2026-06-23 校准）= 让代码说 D-domain + 编译/`swift test`/`make verify` 绿（「代码对齐范式文档」）**；**不训练 / 不评测模型性能 / 不生成语料**。
- 🔴 **训练 + 后端开发 DEFERRED 延后不排期**（C5 数据生成·C5 实际重训·C6 四层门·C6 评测验证模型性能·demo-golden-run·voice ASR/TTS·受限解码 vendor → A2 之后独立重新立项）。
- **A2 只绑 `migrate-d-domain-tool-surface` change**（code-only）；`retrain-c5`/`rebuild-c6`/`golden-run` 标 DEFERRED（其 code-only surface 改随 A2，训练/评测/数据延后）。
- 磊哥定：**CC 主窗口主持 + 全程 `/goal` 自驱 + ultracode（每 step 派 workflow + 主线程亲核 + subagent 审并行 + loopaudit 收口），不派 codex 长跑**。
- 派单 v2 = `~/workspace/raw/05-Projects/MAformac/dispatches/2026-06-23-a2-code-refactor-cc-ultracode-dispatch.md`（融 enforce 现状/简化方案/A2 大纲 6 步/磊哥派单习惯 + **已并入 codex(3 P1+2 P2) + GLM-5.2(0 P0P1+3 P2) 双源审计 findings**）。
- 6 步依赖序（code-only）：[0] 口径锚定 + **scope_tier/allowlist manifest 落盘**（codex P1-2 硬前置，当前 JSONL 无此字段）→ [1] Python codegen 产 D-domain → [2] ToolContractCompiler 消费 → [3] state-cells/executor/命名清债 → [4-code] C5 样本生成器 **surface 改**（预留接口，不生成语料/不训）→ [5-code] C6 bench expected **迁 surface** + 跑 base 验格式（不评性能；parity gate 重定义 = 结构回归门，模型性能 parity 延后）。

## 起手第一步（新 session/A2 主窗口）
读 `CLAUDE.md §9 banner` → **dispatch 文件** → `grill-decisions-master.md` → 回看 codex 失败 lora 至今决策（grill-decisions-master / paradigm-amend / `~/.claude/rules/claim-vs-reality-gap.md` / cascade-inventory）→ 开 `/goal` + ultracode 启动 A2。
