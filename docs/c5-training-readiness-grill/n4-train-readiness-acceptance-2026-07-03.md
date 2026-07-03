---
authority: n4_train_readiness_acceptance
status: local_mechanical_gates_green_cloud_and_runauth_pending
verdict: N4-ACCEPTED-LOCAL（限定语义见 §3，不得引用为无限定 train-ready）
decision_ref: commander-log D-040~D-043
created: 2026-07-03
run_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/
---

# N4 wave-1 train-readiness 验收（2026-07-03）

## 1. 验收口径（先说不声称什么）

**声称**：wave-1 **local** train-readiness 机械门全绿 + 语义门加固 + 配方锚落档。
**不声称**：无限定 train-ready；云侧就绪（generator/judge 卡凭证=N5）；可开训（卡 run-auth + R7 candidate signoff=N6/N7）；GitHub CI 绿（billing）；GitHub review（latestReviews=0）；模型质量/C6 acceptance/V-S-U-PASS。
**prepare receipt 仍 `status: blocked`**：validator_layer2 / candidate_data_quality / fuse parity / endpoint parity 等 N4 scope 外债如实保留（见 RECEIPT-N4A `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/RECEIPT-N4A-e2-downgrade-preflight.md` Conclusion 段），本验收不清该帐。

## 2. 机械门证据（全部 commander 亲核或独立复跑）

| 门 | 结果 | 一手证据 |
|---|---|---|
| loss-mask preflight strict | **exit0**（commander 独立复跑，与 %45 receipt 逐数一致：records=4628 / trainable_records=4628 / trainable_tokens=44459） | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/commander-recheck-preflight.log` + `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N4A-loss-mask-preflight-summary.json` |
| 长行 | length_violation_count=**0**、max_token_length=**7186**≤8192（修复前 `length_violations=294`、`max_token_length=8982`，见 `docs/c5-training-readiness-grill/v6-tiny-ablation-verdict-2026-07-03.md:55`） | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N4A-loss-mask-preflight-summary.json` |
| C5DataGate（修复后 rerun） | **exit0**：row_count=4500（train 4100 / dev_selection 400）、missing_surface_count=0、surface_field_pass=4500、failures none | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/FIX-PR29-datagate-rerun/c5-data-gate-receipt.md` |
| 语义 surface 门（PR29 P1 修复） | 三组 bypass 对抗探针全 fail-closed exit65（`tools:[{}]`→invalid_tool_schema+count_mismatch+not_mounted+digest_mismatch / wrong-mounted→tool_name_not_mounted / digest-drift→subset_policy_digest_mismatch+tool_schema_digest_mismatch），正样本 exit0；%43 复核 **APPROVE_FOR_PR29_P1_SCOPE** | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/REVIEW-PR29-5c68f945.md` 末段 Fix Re-review @871307d9 + `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/FIX-PR29-871307d9.md` |
| valid/test 监督契约 | dev_selection 投影带 A+ 监督（valid 400 / test 128 trainable records）且不改 must_not_train 语义；消费层坐实 evaluate 吃 `maformac_masked_loss`（p5w 分支 `c5_mlx_train_loop.py`，commander grep 亲核，行锚见 RECEIPT-N4A/FIX-PR29 证据表）；%43 对抗审「dev_selection 无泄漏进 train」（`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/REVIEW-PR31-ac7774e0.md §0 第30行`） | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N4A-loss-mask-preflight-summary.json` |
| E-2 降档挂载 | 仅 `seat.massage_force_time` 组 target+first-sibling（p5w 分支实装，行锚在 receipt Code evidence 段）；surface 字段自洽（%43 审①项） | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/RECEIPT-N4A-e2-downgrade-preflight.md` |
| 配方锚落档 | F-044 默认锁（A 15/15 底线 / B draft 14/15 / D base 18/34 锚 / query→actuation 零容忍）+ 7 条配方锚 | `docs/c5-training-readiness-grill/f044-default-lock-and-wave1-recipe-anchors-2026-07-03.md` |
| 配方锚配置层（N4c） | Gate7RecipeQuotaConfig 显式字段 + early-stop 锚（checkpoints 50/100/150 + task_metric basis）+ mock dry-run exit0；负例配额 **deferred**（refusal_ratio_target=0.0 锁值不动，安全由 F-044 D 轴 eval 门承接） | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/RECEIPT-N4C-recipe-anchors.md` |
| GF reduction rev3 | APPROVE_FOR_UPLIFT，136/136 canonical GF 恰好一次映射，status=default_lock_pending_leige_override | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/gf-reduction-rev3.md` |
| pre-mortem + runbook 门 | 3 tiger（**T1 mlx-lm#1348 hang 触发面 rank16+7modules+8192 与本配置命中**）/3 paper-tiger/1 elephant → 折成训练 runbook 门清单（owner+阈值+可复跑动作） | `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/PREMORTEM-wave1-training.md` + `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/WAVE1-TRAINING-RUNBOOK-GATES.md` |

## 3. 云端 PR 现态（live gh 口径，不写宽）

| PR | head | local 审态 | GitHub 态 |
|---|---|---|---|
| #26 P3H harness | `edfc2198`（P1 consumed-index + P2 raw_output 已修） | %43 Fix Re-review 全 PASS | OPEN / reviews=0 / CI FAILURE（billing） |
| #27 A+ 契约 | `a400b01a` | %44 重审 APPROVE（mirror gate old exit66 / new exit0 复跑） | 同上 |
| #28 v6.1 EOS | `49fa0b9b` | %44 重审 APPROVE（code delta）+ claim correction（3 case observed→empty 非「纯截断」） | 同上 |
| #29 G7 surface+硬门 | `871307d9`（两 P1 已修） | %43 Fix Re-review APPROVE_FOR_PR29_P1_SCOPE | 同上 |
| #31 E-2 降档+valid/test 监督+N4c | `f163eedf`（rebase over `871307d9` + 双 P2 已修：quota_mismatch 硬门 + preflight 旗子校验前移 exit64） | %43 Fix Re-review **APPROVE_FOR_PR31_DELTA**（inherited P1 抽测 exit65 清 / 92 filter tests 0 fail / `--allow-mlx-lm-version-mismatch` 判定=pre-existing `c4a7d1a8` 默认关、仅版本 pin 逃生非 loss-mask 后门，验收/runbook 命令应避免使用） | 同上 |
| #30 commander docs | `ed90fbe9`+ | CONFLICTING，分级整编裁决表已出（keep-main 51 / take-branch 4 / union 11，overlap 66） | 勿直接 merge |

## 4. 正式训练前置差额（elephant 声明，preflight-pass ≠ formal-training-ready）

1. 🔴 run-auth（磊哥显式签）+ R7 candidate signoff（route-only 至 2026-07-23）。
2. 🔴 云凭证（Anthropic generator + OpenAI judge）→ N5 live 生成 + cross-vendor judge + validator_layer2/candidate_data_quality 债。
3. run-auth 后第一动作 = **T1 hang 验证 2-iter 真训 smoke**（runbook 门 T1 清单；R7 边界内不做）。
4. F-044 默认值与 GF lock 均 pending_leige_override（默认已锁，可异步翻）。
5. GitHub billing 修复 → CI 重跑；merge 键（#26→#27→#28→#29→#31 依赖序）在磊哥。
