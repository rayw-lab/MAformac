# AGENTS.md — MAformac

> **本项目的权威宪法是 [`CLAUDE.md`](./CLAUDE.md)。任何 agent(Codex / Claude / 其它)起手必须先完整读 `CLAUDE.md`——本文件只是路由入口 + 铁律摘要,不是权威源。**
>
> 单一权威源 = `CLAUDE.md`;本文件刻意保持简短,只为让读 `AGENTS.md` 的 agent(如 Codex)被正确导航,并给工具(OpenSpec 等)留 managed block 注入空间。两份不重复全文,避免漂移。

## 起手三步(任何 agent)

1. 读 **`CLAUDE.md`**(项目定位 / 推进方法论 / 技术栈 / 边界 / 决策)
2. 读 **`docs/CURRENT.md`**(当前路由牌,非 SSOT;只用于判断当前该读什么/做什么/禁止什么)
3. 读 **`docs/README.md`**(文档地图)
4. 读最近 **`docs/handoffs/`**(若有)

## 一句话项目

MAformac = 纯端侧(macOS/iOS)、离线、Qwen3 小模型 + LoRA 的车控**方案演示助手**(给客户现场演示,**非量产/非真车控**)。北极星:**现场 5 分钟内听懂中文、反应快、不崩、看着惊艳、断网也能跑**。

## 不可违反的铁律(完整见 `CLAUDE.md`)

- **推进 = OpenSpec SDD**:`/opsx:propose` 起 change → `specs/`(行为契约,事实源)→ `design` → `tasks` → `archive`;**agree before build**(spec 对齐前不写实现)。
- **边界红线**:源料(真实座舱项目 + repo 研究)**只抽象、绝不复制**真实客户名(一律「某车厂」)/ 报价成本 / 密钥 PII / 标注「禁止外传/对内」的原文。RAW 与下载目录只读,不进仓、不入训练集。
- **技术锁定**:Qwen3-1.7B + LoRA(0.6B 备选,`LLMBackend` 可换)/ **端状态 mock 车控**(执行端=UI 卡片亮暗 + TTS 反馈;**音频/ASR/LLM/指令/安全检查都是真实的**,只车控执行端不真控车)/ 规则吃 80% · LLM 碰 20% · LoRA 必做 / 安全检查是代码不是 prompt / 验收以读回 mock 态为准 / 错误用枚举 / 工具 ≤10 参数 ≤5 / Python 库零进 iOS。
- **决策 D1–D37 已锁**(见 `docs/tech-baseline-from-raw.md §12` + `supplement §17`)。
- **模式**:solo / demo-tool 轻治理——能取巧的运行时灵活取巧,但 LoRA / 安全门控 / 能力治理不省。

## OpenSpec

本项目已全局适配 OpenSpec:Codex 用 `~/.codex/prompts/opsx-*` + `~/.codex/skills/openspec-*`;Claude 用 `~/.claude/commands/opsx/` + `~/.claude/skills/openspec-*`。项目级工作区在 `openspec/`(`init` 后)。命令:`/opsx:propose · explore · apply · sync · archive`。

<!-- OPENSPEC:START 工具可在此注入 managed guidance block,不影响 CLAUDE.md -->
<!-- OPENSPEC:END -->
