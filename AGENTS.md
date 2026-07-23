# AGENTS.md — MAformac

> `CLAUDE.md` 是稳定项目宪法；本文件是 agent 路由与工具纪律入口。不同真相领域按 `CLAUDE.md §3` authority matrix 分工，不宣称任一文件垄断全部真相。
>
> 本文件刻意保持路由职责，并给工具 managed block 留入口；产品行为、机器语义、运行证据与动态真态分别回到其领域 authority。

## 起手四步（任何 agent）

1. 读 **`CLAUDE.md`**(项目定位 / 推进方法论 / 技术栈 / 边界 / 决策)
2. 读 **`docs/CURRENT.md`**(当前路由牌,非 SSOT;只用于判断当前该读什么/做什么/禁止什么)
3. 读 **`docs/README.md`**(文档地图)
4. 只读 `docs/CURRENT.md` frontmatter 指向的 latest handoff，并核其 predecessor/supersedes；随后 live 核 Git/runtime

若通过外部 orchestrator 收到 worker 派单，还需遵守 `docs/operators/agent-orchestration.md` 与本次任务合同；收稿以指定 output file 和机械证据为准，不靠 ack。

## 一句话项目

MAformac = 纯端侧(macOS/iOS)、离线、Qwen3 小模型 + LoRA 的车控**方案演示助手**(给客户现场演示,**非量产/非真车控**)。北极星:**现场 5 分钟内听懂中文、反应快、不崩、看着惊艳、断网也能跑**。

## 不可违反的铁律(完整见 `CLAUDE.md`)

- **推进 = OpenSpec SDD**:`/opsx:propose` 起 change → `specs/`(行为契约,事实源)→ `design` → `tasks` → `archive`;**agree before build**(spec 对齐前不写实现)。
- **边界红线**：真实客户身份、报价/成本、密钥/PII、标注「禁止外传/对内」的原文和受限源料训练数据永不入仓。公开来源研究材料的窄例外只认 `contracts/governance/public-repo-exceptions.v1.json`，未登记或过期即禁入。
- **技术锁定**:Qwen3-1.7B + LoRA(0.6B 备选,`LLMBackend` 可换)/ **端状态 mock 车控**(执行端=UI 卡片亮暗 + TTS 反馈;**音频/ASR/LLM/指令/安全检查都是真实的**,只车控执行端不真控车)/ 规则吃 80% · LLM 碰 20% · LoRA 必做 / 安全检查是代码不是 prompt / 验收以读回 mock 态为准 / 错误用枚举 / 工具 ≤10 参数 ≤5 / Python 库零进 iOS。
- **决策 D1–D37 已锁**(见 `docs/tech-baseline-from-raw.md §12` + `supplement §17`)。
- **模式**:solo / demo-tool 轻治理——能取巧的运行时灵活取巧,但 LoRA / 安全门控 / 能力治理不省。

## OpenSpec

OpenSpec 命令/技能由各 agent 的全局安装或受管 plugin 提供；仓内只保留 `openspec/` 工作区，不复制同名 project skill。命令：`/opsx:propose · explore · apply · sync · archive`。

<!-- OPENSPEC:START 工具可在此注入 managed guidance block,不影响 CLAUDE.md -->
<!-- OPENSPEC:END -->

<!-- gitnexus:start -->
# GitNexus — Code Intelligence

This project is indexed by GitNexus as **MAformac-r5-main-current** (46088 symbols, 153708 relationships, 300 execution flows). Use the GitNexus MCP tools to understand code, assess impact, and navigate safely.

> Index stale? Run `node .gitnexus/run.cjs analyze` from the project root — it auto-selects an available runner. No `.gitnexus/run.cjs` yet? `npx gitnexus analyze` (npm 11 crash → `npm i -g gitnexus`; #1939).

## Always Do

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
