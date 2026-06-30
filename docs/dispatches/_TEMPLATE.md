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
- **artifact_kind**:`implementation_dispatch` / `audit_dispatch` / `research_dispatch` / `doc_cascade_dispatch` / `closeout_dispatch`
- **proof_class ceiling**:<本派单最高可声明的 proof class,例如 local/docs-only / unit / simulator;默认不得升级到 V-PASS/mobile/true_device/live>

## 1. 冷启动背景(承接方零上下文也能懂)
- **项目**:MAformac = 纯端侧 iOS/macOS 离线车控**方案演示助手**(非量产 / 非真车控)。**起手必读** `CLAUDE.md` → `docs/README.md` →(若有)最近 `docs/handoffs/` → 本 dispatch。
- **本任务处于**:<S几 / 6-change 第几 / change 名>
- **为什么现在做**:<动机,1-2 句>
- **authority typing**:本 dispatch 是执行/审计/调研指令,不是新的 SSOT,不是验收 receipt。父级 authority / OpenSpec / grill decision 才是事实源。

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

## 3.1 Grill 清单核对门(所有 dispatch 必填)

> 目的:每个 dispatch 都要先确认是否存在 active grill / decision / audit checklist,执行后必须消减待办,不能让 Cxx/Gxx/decision debt 永久悬空。

### 3.1.1 起手查找

派单方写 dispatch 前必须核;承接方开工前必须复核:

```bash
rg -n "grill|decision|checklist|matrix|burndown|C[0-9]{2}|G-[A-Z0-9-]+" docs/ CLAUDE.md openspec/changes 2>/dev/null
find docs/grill-tournament docs/grill-checklist docs/loop-competition -maxdepth 4 -type f 2>/dev/null | sort
```

如果没有 active grill 清单,本节必须写:

```text
active_grill_list: none_found
search_commands: <实际命令>
why_safe_to_skip_burndown: <为什么本任务没有 grill 待办可消减>
```

### 3.1.2 Grill Source Truth 表

有清单时,必须填写:

| source | artifact role | scope | id scheme | item_count | authority status |
|---|---|---|---|---:|---|
| `<path>` | source matrix / formal authority / checklist / decision pack | `<R1/R2/...>` | `Cxx` / `G-*` / `Q*` / custom | `<n>` | active / historical / evidence-only / superseded |

硬规则:

- 不删除、不重写原始 source matrix;原始清单是 evidence/audit input。
- formal/canonical authority 是消减依据;若只有 raw matrix,先建立或指定 canonical mapping,否则不能把 item 标 done。
- 若派单只覆盖子集,明确 `covered_ids` 和 `out_of_scope_ids`。

### 3.1.3 Burndown/消减动作

每个实现、修复、文档级联或 closeout dispatch 都必须要求承接方输出 `Grill Burndown`。推荐写入 closeout;若清单较大或会跨多轮推进,新增专门账本:

`docs/grill-tournament/<slug>-grill-burndown-YYYY-MM-DD.md`

状态枚举:

- `resolved_with_proof`: 已用实现/文档/验证实际消减;必须有 proof path + proof class + validation command。
- `partially_resolved`: 部分消减;必须写剩余 gap。
- `still_open`: 仍阻断当前或后续阶段。
- `deferred`: 有明确 defer reason、owner、trigger。
- `not_touched`: 本派单没有覆盖。
- `rejected`: 经决策拒绝;必须引用 authority。

Burndown 表模板:

| grill_id | canonical_group | before_status | after_status | proof_path | proof_class | validation | remaining_gap | next_owner |
|---|---|---|---|---|---|---|---|---|
| `Cxx/G-*` | `<group>` | `still_open` | `partially_resolved` | `<path>` | `local/unit/simulator/...` | `<command>` | `<gap>` | `<owner>` |

禁止:

- 仅因写了 spec/checker/doc 就标 `resolved_with_proof`。
- 把 local/unit/simulator proof 升级成 L3/V-PASS/mobile/true_device/live。
- 把 `still_open` 写成完成。
- 把 raw 70 条 / checklist 全文倒进 OpenSpec 或 storyboard。
- 用 broad commit (`git add .`) 混入无关 evidence/code/docs。

## 4. 边界(CONSTRAINTS / BOUNDARIES)
- **红线**(完整见 `CLAUDE.md §6`):真实客户名一律「某车厂」;报价 / 密钥 / PII / 车型代号 **绝不入仓**;真实 bug 训练集即便脱敏也**不入仓**(仅 LoRA 权重产物可);**不降级**(Qwen3-1.7B+LoRA 主线,0.6B/FoundationModels/llama.cpp 仅备选对照)。
- **禁区**:<不许动的文件 / 目录>
- **OUT_OF_SCOPE**:超出本 dispatch 范围 → 返回说明 + 建议归属,**不硬扛、不顺手扩**。
- **dirty tree/pathspec**:先列 owned/unowned/no-touch;提交必须 exact pathspec;禁止 `git add .`;不得 reset/checkout 用户或其它 agent 改动。
- **status vocabulary**:缺 hard gate 时只能 `PARTIAL`/`BLOCKED`;不得 fake green。
- **proof-class ceiling**:不得超过本派单的 proof_class ceiling;高阶 claim 必须另有对应 proof。

## 5. 验收门
> codex-metacognition §23 三硬约束 + OpenSpec tasks 验收 + Pre-Mortem(见 `~/.claude/skills/learned/pre-mortem.md`)。
- 每条 task 的产出 + **可验收标准**(不写「完成 / OK」大词,带证据 / 等级)。
- **failure** → 写 failure receipt(risk_state 枚举 + 实际异常,别静默吞)。
- **smoketest** 实采 ≥N(真实数据 fixture,非 mock / 非 LLM 自造)。
- **必过门**:<如 `openspec validate <name>` 通过 / demo must-pass / 测试全绿 / readback mismatch=0>。
- **新技术点动手前先 Pre-Mortem**(scout 本机历史 + oracle 自己的 subagent+web 搜 failure mode),Risks 填实证坑、非空泛。
- **Grill Burndown 验收**:必须输出本轮消减/未消减的 grill IDs;每个 `resolved_with_proof` 都要有 proof path、proof class、validation command。
- **audit 必审 fake burndown**:审计员必须检查有没有把未验证项、文档项、候选项错误标成 resolved。

## 5.1 Bug / Finding 泛化门

若任务中发现 bug、failed fix、surprising test failure、proof mismatch、fake affordance、状态 overclaim、dirty provenance conflict,不得只修表面。必须做同类风险泛化:

```text
visible symptom -> expected chain -> observed break -> same-class risk map -> immediate fix -> class-level gate -> governance fix
```

若项目指定了专门 skill(例如 `bug-iceberg-teardown`),必须按指定 skill 执行,并把 teardown 摘要放入 closeout。

## 6. 相关文件(优先读,≤5,绝对路径)
1. <最重要>
2. …(≤5)

## 7. 完成回报格式(DELIVERABLE,带 status field)
> oracle:每个 agent 输出含 status field + 自验,卡住路由不硬扛(coordination failures = prompt failures)。
- **status**:`done` / `blocked` / `partial`
- **产出清单**:<文件 + 每项验收结果(带证据)>
- **Grill Burndown**:<本轮影响的 grill_id / canonical_group / before_status / after_status / proof_path / proof_class / remaining_gap>
- **BLOCKED**(卡住时):`BLOCKED: <缺什么> FROM: <需谁 / 什么资源>`
- **关键发现 / 偏差**:分清 `introduced`(本次引入)vs `exposed`(旧债暴露)(codex §8)
- **validation**:<命令 + 关键输出,明确 proof class>
- **owned/unowned/no-touch**:<本轮 pathspec 分区>
- **non-claims**:<不得声明的 readiness / acceptance / proof-class 升级>
- **下一步建议**:<具体动作,非空泛方向>
