# Dispatch - C3 debt cleanup + C6 OpenSpec archive long run

> 派 Codex(long-runner)。磊哥手动粘贴。
> 目标 = 结束 P0 C6 收尾后的 OpenSpec archive：先诚实处理 C3 `7.3 Qwen3 sampling` 剩余任务，再 archive C3；随后复核 P0-3/P0-4 closeout，archive C6。不要把 `Complete` 状态词当成 archive 证据，必须实跑 archive + 对账。

---

## 0. 当前判断

**结论：C6 可以进入 archive 长任务，但不要跳过 C3 债。**

写作时真态参考：
- branch: `codex/p0-2-c6-model-fingerprint`
- HEAD: `607dbe3 Close out C6 trap gold verification`
- `openspec list`: `define-vehicle-tool-bench ✓ Complete`；`define-execution-contract 37/38 tasks`
- C6 final `verify-gold`: `Reports/c6-gold-verify-final-post-audit-fix-20260620-183639/c6-gold-verify.md`，`status=pass`，`cases=57`，`candidate_count=59`，`gold_replay_fail_count=0`
- C6 handoff: `docs/handoffs/2026-06-20-p0-3-p0-4-c6-trap-gold-closeout.md`，`Ready for archive: true`
- C3 open debt: `openspec/changes/define-execution-contract/tasks.md` 仅 `7.3 Qwen3 sampling` 未勾

这些是历史参考，不得直接信。真实值以 Prerequisite Check 输出为准。

---

## 1. 红线

- 不启动 C5 LoRA train。
- 不新增模型运行，不下载权重，不改 Hugging Face / MLX cache。
- 不假装跑过 Qwen3 sampling 对照。若没有真实 runtime path，就把 C3 7.3 明确迁移到 P1-B Qwen spike。
- 不改 C6 gold、trap cases、verify-gold 逻辑，除非 archive 前验证暴露 blocker。
- 不扩大 C2 delta。`contracts/state-cells.yaml` 只允许保留已授权的 readback-only 修复：`ac.fan_speed` 与 `ambient.color` 的 `readback_zh`。
- `openspec archive` 必须实跑，不能只说 `Complete`。

---

## 2. Prerequisite Check

```bash
cd /Users/wanglei/workspace/MAformac
pwd
git status --short --branch
git branch --show-current
git rev-parse HEAD
git rev-parse origin/main
git log --oneline --decorate -8
openspec list
openspec validate define-execution-contract --strict
openspec validate define-vehicle-tool-bench --strict
sed -n '1,120p' openspec/changes/define-execution-contract/tasks.md
sed -n '1,220p' openspec/changes/define-vehicle-tool-bench/tasks.md
sed -n '1,120p' docs/handoffs/2026-06-20-p0-3-p0-4-c6-trap-gold-closeout.md
sed -n '1,80p' Reports/c6-gold-verify-final-post-audit-fix-20260620-183639/c6-gold-verify.md
git diff -- contracts/state-cells.yaml
```

如果工作树不干净，先判定是否全是本任务相关变更。遇到未知用户改动，停下报告，不要 reset、checkout 或清理。

---

## 3. Pre-mortem

| 风险 | 失败形态 | 防护 |
|---|---|---|
| C3 7.3 机械勾掉 | 后续以为 sampling 对照已实测，P1-B 选型信号污染 | 只允许写 `superseded/moved to P1-B Qwen spike`，并引用证据 |
| 只 archive C6 留 C3 dangling | roadmap 上 P0 收尾仍有旧债，下一阶段入口不干净 | 先清 C3，再 archive C6 |
| archive C6 前忽略 C2 delta | `state-cells.yaml` 被 C6 顺手改，可能污染 C2 事实源 | diff 只允许 readback-only 两行；否则 blocker |
| `openspec validate` 绿但 archive 失败 | archive 会更新 specs / 移动 change，validate 不等于 archive 成功 | 必须实跑 `openspec archive ... -y` 并 `git status` 对账 |
| final verify-gold 报告过期 | 当前 HEAD 与报告不一致 | archive 前重跑 `verify-gold` 或至少核报告路径来自当前 HEAD；推荐重跑 |

---

## 4. Step A - 清 C3 7.3 债

目标文件：
- `/Users/wanglei/workspace/MAformac/openspec/changes/define-execution-contract/tasks.md`
- `/Users/wanglei/workspace/MAformac/docs/research/2026-06-20-c3-home-llm-adopt-spike.md`
- `/Users/wanglei/workspace/MAformac/docs/roadmap-2026-06-20-from-c6-done.md`

判断：
- `docs/research/2026-06-20-c3-home-llm-adopt-spike.md` 已写明：C3 当前没有 model runtime path 来测 Qwen3 sampling；C3 不 hard-code sampling；等 C7/runtime backend active 后测 trigger rate、format legality、semantic accuracy、latency。
- roadmap P1-B 已承接 Qwen spike：parser / GDN / model backend / latency 是 P1-B gate，在 train 前完成。

执行：
1. 修改 C3 tasks 7.3，不要假装已完成 sampling 实测。
2. 把 unchecked 改为 checked，但正文必须写清：

```markdown
- [x] 7.3 Qwen3 sampling 起点用 home-llm `temp=0.6/top_k=20/top_p=0.95` 做对照,再与低温确定性配置比较。验收:触发率、格式合法率、latency 表格。**Superseded/moved to P1-B Qwen spike**: C3 has no active model runtime path; see `docs/research/2026-06-20-c3-home-llm-adopt-spike.md §7.3` and roadmap P1-B. Do not hard-code sampling in C3.
```

3. 运行：

```bash
openspec validate define-execution-contract --strict
openspec list
```

验收：
- `define-execution-contract` 显示 Complete 或无 unchecked tasks。
- 没有新增 runtime/model code。
- 没有声称采样对照已实测。

---

## 5. Step B - Archive C3

前置：
- Step A 完成。
- `openspec validate define-execution-contract --strict` 通过。

执行：

```bash
openspec archive define-execution-contract -y
git status --short --branch
openspec validate --specs --strict
openspec list
```

验收：
- `openspec/changes/define-execution-contract/` 被移动到 `openspec/changes/archive/<date>-define-execution-contract/`。
- 对应 spec 已进入/更新 `openspec/specs/`。
- `openspec list` 不再显示 `define-execution-contract` 为 active change。
- 若 archive 失败，保留 stdout/stderr，停止，不进入 C6 archive。

---

## 6. Step C - C6 archive readiness audit

前置：
- C3 已 archive 或明确失败并停止。

执行复核：

```bash
openspec validate define-vehicle-tool-bench --strict
swift test
swift run C6BenchCLI verify-gold \
  --repo-root /Users/wanglei/workspace/MAformac \
  --output-dir /Users/wanglei/workspace/MAformac/Reports/c6-gold-verify-archive-check-$(date +%Y%m%d-%H%M%S)
make verify
git diff -- contracts/state-cells.yaml
```

允许的 `contracts/state-cells.yaml` diff 仅限：
- `ac.fan_speed` 增加 `readback_zh`
- `ambient.color` 增加 `readback_zh`

不允许：
- range / enum / default / source_refs 改动
- 新增 raw customer text
- 删除已有 state cell

验收：
- `swift test` 通过。
- `verify-gold` archive-check 报告 pass。
- `make verify` 通过。
- `openspec validate define-vehicle-tool-bench --strict` 通过。
- C6 tasks 0-13 全部 checked。

---

## 7. Step D - Archive C6

前置：
- Step C 全过。
- final/archive-check `verify-gold` pass。
- C2 readback-only delta 被确认只包含授权两项。

执行：

```bash
openspec archive define-vehicle-tool-bench -y
git status --short --branch
openspec validate --specs --strict
openspec validate --all --strict
openspec list
```

验收：
- `openspec/changes/define-vehicle-tool-bench/` 被移动到 `openspec/changes/archive/<date>-define-vehicle-tool-bench/`。
- `openspec/specs/vehicle-tool-bench/` 更新到包含 P0-1/P0-2/P0-3/P0-4 行为契约。
- `openspec list` 不再显示 `define-vehicle-tool-bench` active。
- `_parked` 保持不动。

---

## 8. Step E - Closeout commit / push

执行：

```bash
git status --short --branch
git diff --stat
git diff -- openspec/specs openspec/changes docs/roadmap-2026-06-20-from-c6-done.md CLAUDE.md docs/README.md
```

如 archive 成功，新增 handoff：
- `/Users/wanglei/workspace/MAformac/docs/handoffs/2026-06-20-c3-c6-archive-closeout.md`

handoff 必须写：
- C3 7.3 怎么处理：`moved to P1-B Qwen spike`，不是已实测。
- C3 archive command/result。
- C6 archive command/result。
- final/archive-check `verify-gold` report path。
- `swift test`、`make verify`、`openspec validate --all --strict` 结果。
- 下一步：P1-A C5 数据门 + P1-B Qwen spike，可并行；P1-C train 仍等这两门过。

提交：

```bash
git add openspec docs contracts Core Tests Tools Reports
git commit -m "Archive C3 and C6 OpenSpec changes"
git push origin HEAD
```

如果有无关文件或未知改动，不要 stage。

---

## 9. 完成回报格式

```text
status: V-PASS | partial | blocked
branch:
head_before:
head_after:
c3_debt:
  decision: moved_to_p1_b_qwen_spike | actually_measured | blocked
  evidence:
  archive_result:
c6_archive:
  readiness: pass | fail
  archive_result:
  verify_gold_archive_check:
  c2_readback_delta: readback_only | unexpected
verification:
  - swift test:
  - C6BenchCLI verify-gold archive-check:
  - openspec validate define-execution-contract --strict:
  - openspec validate define-vehicle-tool-bench --strict:
  - openspec validate --all --strict:
  - make verify:
changed_files:
  - <path>: <why>
next:
  - P1-A C5 data gate
  - P1-B Qwen spike
  - P1-C LoRA train only after both pass
```

不要写“完成”单词裸奔。必须写 `V-PASS` / `partial` / `blocked`，并附命令结果摘要。
