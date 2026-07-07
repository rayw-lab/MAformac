# RUNS-CASCADE - Commander Runs Tree Index

status: ACTIVE_POINTER_ONLY
updated_at: 2026-07-06T（D-111 收尾亲落：加 c5-runtime-mainpath-grill + c5-training-vpass 行，formal-1800 lane 标 parallel-pending-run-auth）
authority_class: commander_run_tree_lifecycle_doc
proof_class: local_filesystem_inventory
external_runs_root: `/Users/wanglei/Projects/agent-tmux-stack-research/runs`
repo_pointer: `runs/README.md`

Non-claims: this document is not a raw artifact copy, not a training launch, not an eval pass, not a candidate signature, not C6, not UIUE/voice readiness, and not V-PASS.

## Purpose

`/Users/wanglei/Projects/agent-tmux-stack-research/runs` is the commander nest for lifecycle execution evidence. This repo keeps only discoverability pointers and cascade rules. Raw run artifacts stay outside the repo unless a later, explicit, reviewed decision says otherwise.

`runs/README.md` is the repo-local backstop. Non-README contents under repo `runs/` are local residue by default and must not be promoted with `git add .`.

## Ground Rules

- Do not copy raw adapters, checkpoints, metrics dumps, training logs, browser captures, generated media, or ad hoc run directories into MAformac.
- Worker output files and receipts are evidence. Pane prose and ack text are coordination signals, not final truth.
- Every cascade update must preserve proof class and non-claims. A `runtime` train receipt cannot become behavior pass, candidate, C6, UIUE/voice readiness, or V-PASS without the corresponding downstream proof.
- Historical run dirs are not deleted for cleanup. Mark them retired or superseded in docs, then leave the raw tree intact.
- Before any push or closeout, scan both tracked files and local residue under repo `runs/`.

## Recursive Inventory Method

Use this as the bounded maintenance probe before updating project pointers:

```bash
RUN_ROOT=/Users/wanglei/Projects/agent-tmux-stack-research/runs
find "$RUN_ROOT" -maxdepth 2 -type d | sort
find "$RUN_ROOT" -maxdepth 4 -type f \( \
  -name 'STATUS-BOARD.md' -o \
  -name 'EVIDENCE-INDEX.md' -o \
  -name 'COMMANDER-LIVE-STATUS.md' -o \
  -name '*RECEIPT*.md' -o \
  -name '*audit*.md' \
\) | sort
git ls-files runs
find runs -maxdepth 4 -type f -print | sort
```

Expected repo result: `git ls-files runs` should show only intentional pointer docs, ideally `runs/README.md`. Any tracked raw run file is a FINDINGS condition. Do not stage or delete it inside the scan; write a receipt and let the dirty-tree gate decide.

## Artifact Taxonomy

| Class | Examples | Default location | Cascade rule |
| --- | --- | --- | --- |
| Status boards | `STATUS-BOARD.md`, `COMMANDER-LIVE-STATUS.md` | external run dir | May be referenced by repo docs with absolute path and claim ceiling. |
| Evidence indexes | `EVIDENCE-INDEX.md` | external run dir | Use as run-dir table of contents; do not flatten into repo. |
| Receipts | `*-RECEIPT*.md`, lane receipts, hold receipts | external run dir | May be summarized in repo docs; keep proof class and non-claims. |
| Audits | `*-audit*.md`, grill/reduction audits | external run dir | Reference verdict and blocker only; preserve file:line evidence in the source. |
| Host/watchdog/launch probes | host baselines, watchdog proof, command candidates | external run dir | Treat as runtime gate evidence, not training/eval completion. |
| Raw training artifacts | adapters, checkpoints, metrics JSONL, logs | external run dir | Do not copy into repo. Hash and point only. |
| Repo pointers | `runs/README.md`, this file, commander index rows | tracked repo docs | Pointer-only; no raw payloads. |

## Current Important Run Dirs

| Run dir | Current role | Claim ceiling |
| --- | --- | --- |
| `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-formal-1800-launch` | C5 formal/tail evidence root。**tail1200 iter600 = current 最优 unsigned artifact**（`formal-run-20260706T090552+0800-tail1200-full-envelope`，adapter_basis_sha `9373fd41…`，trainer 已退 `ps` 空）；旧 formal 1800 fresh 跑 = HISTORICAL HOLD/PARTIAL（`formal-run-20260705T234208`，RC_143，iter1692，无 iter1800）。🔴 **formal 1800 lane = parallel-pending-run-auth（D-111 磊哥拍 A 并行，非 superseded/非 DEFER）**——磊哥保留 goal，与 tail1200 honest-frozen-closeout 收尾并行待 run-auth。`COMMANDER-LIVE-STATUS.md` 头仍写 `LIVE/PID42505` = stale 待 refresh。 | Training artifact evidence only。candidate **unsigned**（tail1200 iter600），`adapter_learned_qa=false`。No candidate/C6/V-PASS by implication。 |
| `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-runtime-mainpath-grill` | C5 收尾主路 grill（runtime 接线 W20A + adapter 缺陷处置 + honest-frozen-closeout 定调 D-111）。关键文件：`STATUS-BOARD.md`、`GRILL-README.md`、`grill-reduction.md`、`impl-plan-honest-frozen-closeout.md`(v3)、`lane-1~4-*.md`、`residual-R1-ddomain-decoder-probe.md`、`ir-map-ios-bundle-probe.md`、`exp-axisD-fail-enumeration.md`、`grill-reduction-audit.md`、`superaudit-impl-plan-v2.md`。 | Planning/grill 证据 only。NOT candidate/V-PASS/C6/runtime readiness。W20A 是**计划未写实现码**（superaudit CONDITIONAL_GO 91/100，实装需 run-auth）；candidate unsigned；不重训 1800。 |
| `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-training-vpass` | C5 tail1200 训练+评测一手证据锚（本 grill 裁决#1/#5 的一手源：`tail1200-original-gate-v3/probe-output-abd/`、`tail1200-original-v3-paired-report.md`、`w12-*-audit.md`、`w15-*-rootcause-grill.md`）。 | Eval 证据 only（axis-D 19/34 是 churn 非健康锚，见 exp-axisD-fail-enumeration）。NOT candidate/V-PASS/C6。 |
| `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-worker-round2` | Closeout worker round and W11/W12/W14 receipts. | Worker receipts and doc maintenance evidence, not product readiness. |
| `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-grill` | Grill lanes, reduction, and reduction audit. | Planning/audit evidence only. |
| `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-plan-audit` | Final/adversarial plan audits. | Plan readiness evidence only. |
| `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-06-c5-closeout-governance` | Governance, dirty-tree, inventory, and push-gate outputs when present. | Governance gate evidence only. |
| `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-05-phase1-scanner-authority-gates` | Phase1 scanner and authority-gate evidence. | Scanner/gate evidence only. |
| `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness` | Historical N2/N4 training readiness receipts. | Historical readiness evidence, superseded where newer receipts say so. |
| `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A` | Historical tiny/probe receipts. | Historical only. Repo-local residue with the same name must remain untracked until separately classified. |
| `/Users/wanglei/Projects/agent-tmux-stack-research/runs/ma-swarm-20260627-*` | Historical swarm smoke/election receipts. | Swarm protocol evidence only. |

## Receipt Naming Conventions

Use stable names that expose lane, topic, and status surface:

- `STATUS-BOARD.md` for current run-dir state.
- `EVIDENCE-INDEX.md` for evidence routing.
- `COMMANDER-LIVE-STATUS.md` for commander-facing live truth.
- `<LANE>-<topic>.md` for worker receipts, for example `w14-runs-recursive-maintenance.md`.
- `*-RECEIPT*.md` for launch, hold, final, or train receipts.
- `*-audit*.md` for independent audit outputs.

Every receipt should include: `status`, `verdict`, `proof_class`, evidence table with commands or file:line references, touched paths, non-claims, residual risk, and next gates.

## Proof-Class And Non-Claim Rules

- `local`, `mock`, `runtime`, `desktop_operator_equivalent`, `mobile`, `true_device`, and `live_api` are not interchangeable.
- `train_health` or a completed training loop is not behavior pass, eval pass, signed candidate, C6, UIUE/voice readiness, or V-PASS.
- A candidate remains unsigned unless a dedicated signing receipt says otherwise.
- Host/watchdog/launch PASS proves only that gate, not model quality.
- A stale run receipt stays historical unless a newer receipt explicitly supersedes it with date, path, and proof class.

## Stale And Retire Rules

Retire, do not delete. A run dir becomes stale when a newer dated run dir supersedes it, when a commander plan marks it historical, or when its proof target is no longer the active gate.

Retire note requirements:

- absolute run dir path;
- latest superseding artifact path;
- status vocabulary such as `superseded`, `historical`, `hold`, or `retired`;
- preserved non-claims.

## Future Commander Cascade

For each new lifecycle run:

1. Create or identify the external run dir under `/Users/wanglei/Projects/agent-tmux-stack-research/runs`.
2. Keep raw logs, adapters, screenshots, and metrics in that external run dir.
3. Require workers to write receipts inside the run dir, not only pane prose.
4. Update run-dir status/evidence indexes first.
5. Update repo docs only with pointers, summaries, proof class, and claim ceiling.
6. Run the repo raw-artifact scan before closeout or push:

```bash
git ls-files runs
find runs -maxdepth 4 -type f -print | sort
```

## W14 Snapshot

At W14, `git ls-files runs` returned no tracked files. Repo-local `runs/tiny-ablation-adjudication-A/DONE-XPR25` and `runs/tiny-ablation-adjudication-A/XAUDIT-PR25.md` existed as local residue; W14 did not stage, delete, or classify them beyond this pointer-only warning.
