# SPEC W1 — C5 grill 数据语料官（worker @ %44 codex-1）

你是 codex worker（pane `%44`），commander 是 Claude（`%42` @ ma-status-swarm）。
任务 = **C5 训练就绪 grill·数据语料线**：脑暴维度 2/3/7 的关键决策（第一轮 ~45 条，每维度 ~15），按 UIUE 215-grill 决策矩阵范式产出。
🔴 **角色 persona**：代入【数据工程师 + 语料标注负责人】视角深 grill——挑剔数据质量/泄漏/分布/标注口径/多样性。
cwd=`/Users/wanglei/workspace/MAformac`（grill 写 docs，不改代码、不实装、不训练、不生成训练数据——守 R7 BLOCKED）。

## 🔴 起手必读（grill 范式 + 论据源，落笔前读）

1. `docs/c5-training-readiness-grill/README.md`（grill SSOT：范式 + 决策矩阵格式 §4 + 双仓惨败纪律 §1）。
2. 上游论据源（cite 一手 file:line，不凭记忆）：`Core/Bench/C5DataGate.swift`（554 行，数据门）+ `docs/research/2026-06-21-c5-generator-selection-probe.md`（generator 三权分立）+ `docs/c5-recovery-2026-06-22/8d-rootcause.md`（0/34 数据契约失守 P1-P5）+ `docs/baseline-semantic-protocol-2026-06-19.md`（3990 语义范式/value 四件套）。

## 你的 3 维度（脑暴关键决策）

### 维度 2 — 数据集 + 语料（~15 决策）
3990 语义范式 / 12000 bug 真实说法 / raw 一手料 / D-domain 具名工具 surface / value 四件套（SPOT 抠槽·EXP 逆规整·PERCENT）/ 四类数据（positive/no-call/coverage-clarify/safety）/ **双仓旧数据集**（0/34 用的旧 jsonl + θ-α generated-positive 集，哪些复用/废弃/重生成）。grill 议题示例：语料来源配比 / 自然中文 utterance 怎么产（云 generator vs 模板）/ D-domain 具名工具命名规则 / value 编码进工具名的粒度。

### 维度 3 — C5 数据 gate（~15 决策）
`C5DataGate.swift` 现状（亲核）：split whitelist + parent_semantic_id 级隔离 + must_not_train + parent_overlap + redaction + masking coverage 统计。🔴 **gate 5 多轴 held-out 未实装**（当前只 parent 级，缺 device/tool/value/template/generator_source 硬切分，`C5DataGate.swift:252` split 白名单）。grill 议题：多轴 held-out 切哪几轴 / 每轴隔离粒度 / label_conflict 硬门怎么加（防 0/34 假删，8d P3）/ redaction 词表 / masking coverage 怎么从统计变 enforce。

### 维度 7 — 云 generator + 异源 judge（~15 决策）
research 已锁方向（`c5-generator-selection-probe.md:117-138`）：多源云 LLM 产 utterance（Claude/GPT-5.5/Codex/GPT Pro）/ label 走 C1 契约 deterministic / validator+judge 异源 / 原文绝不入训练（只喂 device×primitive×value 语义协议）。🔴 **代码未闭环**（gate 7 ❌）。grill 议题：generator 多源怎么编排 / diversity gate / self-bias 防线 / 异源 judge 用谁（非 Claude-family）/ dedupe 粒度 / 三权分立（generator≠label≠judge）落地。

## 🔴 决策矩阵格式（产出 `docs/c5-training-readiness-grill/worker-1-data-decisions.md`）

```
| ID | 议题 | 选项 A/B/C | ⭐推荐 | 论据(file:line/arxiv) | 状态 | 🔴防惨败(cite PCA或新挖) |
```
- **ID 前缀 `D-`**（D-001 起，防撞 W2 `A-`/W3 `E-`/commander `F-`）。
- **状态**：`proposed`（默认，待磊哥拍）。
- **论据必 cite 一手 file:line**（claim-vs-reality；C5DataGate/probe/8d 的真实行号，落笔前 grep 核，别凭记忆）。
- 🔴 **防惨败列非可选**：每条答「这决策怎么防 0/34 + θ-α 重演」，cite P1-P9 PCA（8d §D5：P1 单源派生/P2 真删/P3 label_conflict/P5 C6口径/P7 审计实跑…）或新挖防线。

## 🔴 边界（守 R7 BLOCKED）

- **只 grill 脑暴决策写 docs**，不改代码、不实装 gate、不训练、**不生成训练数据**（R7 forbidden：any retrain-c5 data generation）。
- 论据 cite 一手 file:line，外部 arxiv ID 标注（commander 抽核）。
- 不替别的 worker grill（维度 4/5/8=W2 算法训练 / 6/9/12=W3 评测范式 / 1/10/11=commander）。

## 回执（swarm §3：commander 看文件不信 ack）

完成 `tmux-bridge message %42 'C5-GRILL-W1-DONE 决策数N 落 worker-1-data-decisions.md'`，commander 自核文件 + file:line + subagent CC 审回稿。
