# Dispatch Template（通用跨 agent 派单模板）

> **适用**:CC → Codex / CC → 另一 CC 窗口 / Codex → CC（任意派单方向）。**冷启动**:承接方零上下文也能独立执行。
> **来源**:scout 本机(Codex cold-start 模板 + 全局 hermes/gptpro 派单规则 + codex-metacognition §20/§23)× oracle(agent handoff pattern:TO/FROM/TASK/CONTEXT/DELIVERABLE/CONSTRAINTS + status field;cold-start context loss 解法)。
> **用法**:复制本文件 → 填各段 → 命名 `YYYY-MM-DD-<slug>.md` 放本目录 → 把文件路径/内容交给承接方。**删掉本引言区(`---` 以上)再交付**。

---

## 0. 路由元信息
- **TO**:<承接方:Codex(长跑 TDD)/ Claude-CC 窗口 / GPT Pro / 具体 agent>
- **FROM**:<派单方>
- **MODE / MODEL**:<Codex 长跑 / CC subagent / GPT Pro heavy producer …>
- **PRIORITY**:<P0 阻塞 / P1 / P2>
- **一句话 DELIVERABLE**:<承接方做完要交出什么>

## 1. 冷启动背景(承接方零上下文也能懂)
- **项目**:MAformac = 纯端侧 iOS/macOS 离线车控**方案演示助手**(非量产 / 非真车控)。**起手必读** `CLAUDE.md` → `docs/README.md` →(若有)最近 `docs/handoffs/` → 本 dispatch。
- **本任务处于**:<S几 / 6-change 第几 / change 名>
- **为什么现在做**:<动机,1-2 句>

## 2. 任务(TASK)
<具体做什么。引 OpenSpec change / spec / design / tasks 的**绝对路径**。拆成可独立完成的子项,别写成一个巨型模糊描述(任务分解 > 单体 prompt)。>

## 3. Prerequisite Check(起手必跑,验运行态)
> codex-metacognition §20:引运行态数字必先跑核实命令;所有 hard-code 数字标 disclaimer。
```bash
cd /Users/wanglei/workspace/MAformac
openspec status --change "<name>"     # 验 artifact 状态
git status --short                    # 验工作树
# <其他:xcodebuild -version / find <dir> -type f | wc -l …>
```
下文所有 hard-code 数字标 `(snapshot <时间>,以上方 Check 为准)`。

## 4. 边界(CONSTRAINTS / BOUNDARIES)
- **红线**(完整见 `CLAUDE.md §6`):真实客户名一律「某车厂」;报价 / 密钥 / PII / 车型代号 **绝不入仓**;真实 bug 训练集即便脱敏也**不入仓**(仅 LoRA 权重产物可);**不降级**(Qwen3-1.7B+LoRA 主线,0.6B/FoundationModels/llama.cpp 仅备选对照)。
- **禁区**:<不许动的文件 / 目录>
- **OUT_OF_SCOPE**:超出本 dispatch 范围 → 返回说明 + 建议归属,**不硬扛、不顺手扩**。

## 5. 验收门
> codex-metacognition §23 三硬约束 + OpenSpec tasks 验收 + Pre-Mortem(见 `~/.claude/skills/learned/pre-mortem.md`)。
- 每条 task 的产出 + **可验收标准**(不写「完成 / OK」大词,带证据 / 等级)。
- **failure** → 写 failure receipt(risk_state 枚举 + 实际异常,别静默吞)。
- **smoketest** 实采 ≥N(真实数据 fixture,非 mock / 非 LLM 自造)。
- **必过门**:<如 `openspec validate <name>` 通过 / demo must-pass / 测试全绿 / readback mismatch=0>。
- **新技术点动手前先 Pre-Mortem**(scout 本机历史 + oracle 自己的 subagent+web 搜 failure mode),Risks 填实证坑、非空泛。

## 6. 相关文件(优先读,≤5,绝对路径)
1. <最重要>
2. …(≤5)

## 7. 完成回报格式(DELIVERABLE,带 status field)
> oracle:每个 agent 输出含 status field + 自验,卡住路由不硬扛(coordination failures = prompt failures)。
- **status**:`done` / `blocked` / `partial`
- **产出清单**:<文件 + 每项验收结果(带证据)>
- **BLOCKED**(卡住时):`BLOCKED: <缺什么> FROM: <需谁 / 什么资源>`
- **关键发现 / 偏差**:分清 `introduced`(本次引入)vs `exposed`(旧债暴露)(codex §8)
- **下一步建议**:<具体动作,非空泛方向>
