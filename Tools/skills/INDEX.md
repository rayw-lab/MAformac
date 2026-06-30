# MAformac Skills — 沉淀技能索引

> 从 MAformac 项目**反复动作**抽象的可复用 skill。落点 `Tools/skills/<name>/SKILL.md`（项目内沉淀为 source，后续可 install 到 `~/.claude/skills/`）。
> **沉淀方法 = superpowers v6 `writing-skills`（TDD-for-skills）**：先有 baseline failure（无 skill 时 agent 怎么错）再写 skill。本批 baseline 用项目 **production 实证**（git log / lessons-learned / 0-34 灾难）。
> 🔴 **description 铁律**（`writing-skills`:150-158）：只写 `Use when...` 触发条件，**不写 workflow 摘要**（否则 agent 照 description 走捷径不读 body）。

---

## 0. superpowers v6 是什么（前置说明）

- **形态**：Claude Code **plugin**（`superpowers@claude-plugins-official`），**非** `~/.claude/skills/` 独立 skill。本机 **6.0.3**（obra/superpowers，237k★，2026-06-18）。
- **调用**：`Skill` tool，名字 `superpowers:<name>`（或 v6 直接 `<name>`）。安装目录 `~/.claude/plugins/cache/claude-plugins-official/superpowers/6.0.3/skills/`。
- **v6 关键变化**：① one-set-skills-every-harness（vendor-neutral，6 harness：claude-code/codex/copilot/gemini/pi/antigravity）② 两 reviewer prompt 合一（`task-reviewer-prompt.md`）③ SDD scratch 移出 `.git/` 到工作树顶层 `.superpowers/sdd/`（git-ignored）④ subagent-driven-development 重写（省 ~50% token）。
- **升级无 breaking 影响**：MAformac 零引用旧 `~/.config/superpowers/worktrees/` 和旧双 reviewer prompt。

### v6 14 个 skill 速查（干什么 / 何时触发）

| skill | 干什么（一句话） | 触发 when |
|---|---|---|
| `brainstorming` | 创意/功能/设计前探索意图需求 | 任何 creative work 之前 |
| `writing-plans` | 写实现 plan（Global Constraints + per-task Interfaces + bite-sized TDD steps） | 有 spec/多步任务，动代码前 |
| `test-driven-development` | RED→GREEN→REFACTOR，先写 failing test | 实现任何 feature/bugfix 前 |
| `subagent-driven-development` | 当前 session 执行 plan：fresh implementer/task + task-reviewer 双 verdict + final review | 执行有独立 task 的 plan |
| `executing-plans` | 在独立 session 执行 plan（带 review checkpoint，批量） | plan 在另一 session 执行 |
| `using-git-worktrees` | 确保隔离 workspace（原生工具优先，git fallback `.worktrees/`） | feature work 需隔离/执行 plan 前 |
| `requesting-code-review` | 派 reviewer subagent（精确 context，非 session 历史） | 完成任务/重大功能/merge 前 |
| `receiving-code-review` | 收 review 反馈，实施前技术严谨核验（非迎合） | 收到 code review feedback |
| `verification-before-completion` | claim 完成前跑验证命令确认 output（evidence before claims） | 断言完成/修复/通过前 |
| `finishing-a-development-branch` | 测试过后结构化 4 选项（merge/PR/keep/discard） | 实现完，决定如何集成 |
| `systematic-debugging` | 系统调试（先复现再 fix，不瞎猜） | 任何 bug/测试失败/异常 |
| `dispatching-parallel-agents` | 并行派 agent | 2+ 独立任务无共享状态 |
| `writing-skills` | 创建/编辑/验证 skill（TDD-for-skills） | 建/改/验 skill |
| `using-superpowers` | 元 skill：怎么找用 skill | 任何对话起手 |

---

## 1. BUILD — superpowers 无对应、MAformac 独有（本目录建 4 个）

| skill | 触发（when） | baseline 实证（RED） | 形式（Match-Form） | 状态 |
|---|---|---|---|---|
| `archive-research-pack` | ultracode/多路调研收口归档 | 每次手搓归档、结构不一、transcript 不存 | positive recipe | ✅ 已建 |
| `verify-external-claims` | 调研引 arxiv/精确数字/repo star 需核 | 18 路 catch 1 编造 arxiv `2603.03203` | recipe + red-flags | 🔨 |
| `doc-cascade-sweep` | 范式翻案/口径回写/全仓级联 | cascade 5 轮 self-drift + sed 误改历史档 | conditional（T0-T6 分诊） | 🔨 |
| `closeout-receipt-writer` | 任务收口写 receipt | 0/34 灾难 = receipt 读 metadata flag 翻 pass | structural + prohibition | 🔨 |

---

## 1b. IMPORT — Apple 平台开发 skill 导入（OpenAI curated + Claude Code 社区）

> **装法**（2026-06-24 磊哥定）：source 落 `Tools/skills/<name>/`，`.claude/skills/<name>` symlink **项目级激活**（**不进全局** `~/.claude/skills/`）。社区 repo 必经 github-first 核实（star + 近 60 天活跃）才 adopt；plugin 自带 `hooks/` 一律删（CVE-2025-59536 第三方 hook RCE，hooks.md 红线）。

| skill | 来源（star / 活跃） | 触发（when） | 状态 |
|---|---|---|---|
| `ios-ettrace-performance` | OpenAI curated `build-ios-apps` | iOS Simulator ETTrace launch/runtime profile、符号化 flamegraph JSON 分析 | ✅ |
| `ios-debugger-agent` | OpenAI curated `build-ios-apps` | ETTrace/iOS 调试需 simulator build/install/launch/logs/screenshots | ✅ |
| `ios-simulator-skill` | conorluddy（⭐1105 / 6天前） | iOS app build/run/测试/自动化：**29 scripts**，语义 UI 导航（a11y 树省 token）、build 自动化、simulator 生命周期、hang/性能/截图 | ✅ 新装 |
| `axiom/*`（**27 skills**） | CharlesWiltgen（⭐992 / 4天前） | xOS（iOS/iPadOS/watchOS/tvOS/macOS）全平台开发，见下方清单 | ✅ 新装 |

**axiom 27 skills**（`Tools/skills/axiom/skills/`，全部项目级激活）——纯 6M 知识，已删 plugin 的 `hooks/` + `bin/` 27M 二进制（xclog/xcprof/xcsym/xcui，其能力由 ios-simulator-skill + ios-ettrace 覆盖）+ agents/commands：
- **MAformac 高频相关**：`axiom-swiftui` `axiom-build` `axiom-macos` `axiom-swift` `axiom-testing` `axiom-performance` `axiom-design`（HIG/Liquid Glass/SF Symbols）`axiom-accessibility` `axiom-concurrency` `axiom-data`(SwiftData) `axiom-ai`(Foundation Models) `axiom-apple-docs` `axiom-shipping`
- **全集其余（按需触发）**：`axiom-networking` `axiom-security` `axiom-integration` `axiom-uikit` `axiom-media` `axiom-xcode-mcp` `axiom-tools` `axiom-games` `axiom-health` `axiom-payments` `axiom-vision` `axiom-watchos` `axiom-graphics` `axiom-location`
- 参考源（只读，不入仓）：`~/workspace/raw/05-Projects/MAformac/ref-repos/{ios-simulator-skill,axiom-src}`

---

## 2. ADOPT — 直接用 superpowers v6 现成的（怎么组合替代）

### 2a. `completion-vpass-gate` → `verification-before-completion`（1:1 直接替代）

- superpowers 已有完整 Gate Function（IDENTIFY 命令→RUN→READ output→VERIFY→才 claim）+ Common Failures 表 + Rationalization 表（24 failure 锤炼）。
- **MAformac 补充**（放 CLAUDE.md instructions，非新 skill）：项目特定 verdict 分级 enum —— `OpenSpec-pass / local-pass / train-health / model-quality / V-PASS`，禁互相冒充（completion-claim-triage 计划态≠执行态）。
- **结论**：用 `verification-before-completion` 作通用门，MAformac 分级当它的项目应用清单。

### 2b. `worktree-isolation` → `using-git-worktrees`（替代 + 补并发）

- superpowers v6：Step 0 检测已有隔离（`GIT_DIR` vs `GIT_COMMON` + submodule guard）→ 1a 原生 worktree 工具优先 → 1b git fallback（项目内 `.worktrees/`，verify ignored）→ baseline test。
- **gap**：它解决"**创建**隔离 worktree"；MAformac 痛点是"**单主工作树多 CC 窗口并发**"（别窗口 dirty 区）——v6 Step 0 能识别"是否已在 worktree"，但多窗口共享主工作树的协调它不覆盖。
- **MAformac 补充**（instructions）：memory `maformac-single-worktree-concurrency`（dirty 不 reset / 不 `git add -A` 卷入 / CC doc 产出暂存 raw 错开）。
- **结论**：worktree 创建用 `using-git-worktrees`；单工作树并发协调补 instructions。

### 2c. `apply-preflight-redtest` → 三 skill 组合链路（这是"组合替代"核心）

我们的 apply（frontmatter authority + N Task red-test-first + mechanical gate + closeout）= superpowers **工作流串联**：

```
brainstorming(对齐 what)
  → writing-plans  ……… 造 plan: docs/superpowers/plans/<date>-<feat>.md
  │                     Global Constraints block(项目级 verbatim 约束)
  │                     + per-task Interfaces block(Consumes/Produces 精确签名)
  │                     + bite-sized steps(写failing test→run fail→minimal→run pass→commit)
  → using-git-worktrees(可选,隔离)
  → subagent-driven-development  …… 执行: 每 task fresh implementer + task-reviewer(spec+quality 双 verdict)
  │     ↑ 每 task 内核 = test-driven-development(RED→GREEN→REFACTOR,Iron Law)
  │     + File Handoffs(task-brief/report/review-package 走文件,不 paste)
  │     + progress ledger(.superpowers/sdd/progress.md 防 compaction 丢进度)
  │     + 显式 model(每 subagent 指定,省 token)
  │     + Pre-Flight Plan Review(dispatch Task1 前扫 plan 冲突)
  → requesting-code-review(final whole-branch review)
  → finishing-a-development-branch(merge/PR/cleanup 4 选项)
  全程: verification-before-completion(每次 claim 前 evidence)
```

各司其职：**writing-plans**=plan 骨架 + Global Constraints + Interfaces；**test-driven-development**=每 task red-test-first；**subagent-driven-development**=执行编排 + 双 verdict review + ledger。

**MAformac 在此链路上叠加（superpowers 没有、我们更强的）**：
- **cross-vendor 终审**（GPT Pro/GLM/Codex ≥3 厂商并集，≥1 实跑）——superpowers 只有单 subagent review，叠 `cross-vendor-final-audit` rule 在 final review 之上。
- **3 道 mechanical gate**（`check_default_scope_ssot.py` 等）——放 plan 的 Global Constraints / `make verify` target。
- **closeout receipt**——用本目录 `closeout-receipt-writer`（BUILD）。

---

## 3. 降级 — 不做 skill（`writing-skills`:55-59「mechanical→自动化 / project-specific→instructions」）

| 候选 | 为什么不做 skill | 落点 |
|---|---|---|
| `make-verify-gate` | 已是 `Makefile`+`scripts/` 自动化（mechanical） | `make verify` / `make verify-all`；CLAUDE.md 一句指针 |
| `maformac-onboard` | project-specific convention | CLAUDE.md / instructions（或日后薄 project skill） |

---

## 4. 内化到项目管理体系（v6 机制，非 skill —— adapt 设计智慧）

- **writing-plans v6 结构** → MAformac apply plan 加 **Global Constraints block** + per-task **Interfaces block**。retrain-c5 / rebuild-c6 plan 用此结构。
- **subagent-driven-development File Handoffs**（artifact 走文件不 paste）+ **progress ledger** + **显式 model** → 内化 ultracode workflow / 派单纪律（解决 context 爆炸 + 防 compaction 丢进度 + 省 token）。
- **不 pre-judge findings**（v6 禁 "do not flag / at most Minor"）→ 印证 `cross-vendor-final-audit` 辩证收纪律。

---
*as-of 2026-06-24 · superpowers v6.0.3 · MAformac Tools/skills*
