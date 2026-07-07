---
artifact_kind: n5_canary_g3_g6_receipt
status: DONE_LOCAL
proof_class:
  - local_cli
  - local_static
created: 2026-07-03
repo_root: /Users/wanglei/workspace/MAformac
run_dir: /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary
not_claimed:
  - Gate7 pipeline diversity replacement
  - semantic judge pass
  - DataGate pass
  - training readiness
  - CI or merge readiness
---

# N5 Canary G3/G6 Receipt

## Conclusion

DONE_LOCAL. G3 diversity canary guard and G6 exact C6 case-id leakage probe were added under the run directory and executed against:

- `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/canary-anthropic-opus.jsonl`

Results:

- G3 diversity: PASS.
- G6 C6 exact-id leakage: pass, `c6_case_id_intersection_count=0`.

## Scope And No-Touch

- Writable scope used: run directory only.
- Main git tree: read-only for this task.
- Final `git status --short --branch` shows unrelated concurrent main-tree changes (`docs/commander-log/decisions.md`, `docs/c5-training-readiness-grill/n5-expansion-grill-2026-07-03.md`, plus pre-existing untracked paths). This task did not edit them.

## Files Created

- `tools/canary_diversity_check.py`
- `tools/canary_c6_leakage_probe.py`
- `diversity-report.md`
- `diversity-report.json`
- `canary-c6-leakage-probe.json`
- `CANARY-G3-G6-receipt.md`

## Authority/Evidence Read

- N5 canary G3 requires lightweight diversity check: `docs/c5-training-readiness-grill/n5-canary-grill-2026-07-03.md:16`.
- N5 canary G6 requires confirming/re-running C6 leakage probe: `docs/c5-training-readiness-grill/n5-canary-grill-2026-07-03.md:19`.
- Prior proto receipt lists `wave1-proto-c6-leakage-probe.json` as an output and records `c6_case_count=57`, `sample_case_id_count=4500`, `c6_case_id_intersection_count=0`: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/RECEIPT-WAVE1-PROTO-BUILD.md:38-39` and `:87`.
- Current `C5TrainingCLI prepare` reads C6 cases and writes the core training artifacts, but no current code path writes the small `wave1-proto-c6-leakage-probe.json` sidecar directly: `Tools/C5TrainingCLI/main.swift:45-50`, `:147-150`.
- C5 builder still computes DataGate/generalization leakage from C6 cases: `Core/Training/C5LoRATraining.swift:2208-2224`, `:2314-2322`.
- Current C6 source for exact-id probe: `contracts/c6-bench-cases.jsonl` has 57 total cases and 42 `must_not_train`/`must_pass` protected cases.

Path correction:

- The N5 doc names `n4a-wave1-proto-build/` as the same-name proto probe location, but this run found no `wave1-proto-c6-leakage-probe.json` in `n4a-wave1-proto-build/`.
- The same-name artifact exists under `/Users/wanglei/Projects/agent-tmux-stack-research/runs/tiny-ablation-adjudication-A/wave1-proto-build/wave1-proto-c6-leakage-probe.json`.
- G6 adaptation therefore reimplemented the old sidecar JSON field contract as an independent run-dir Python probe.

## Commands Run

```bash
python3 -m py_compile \
  /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/tools/canary_diversity_check.py \
  /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/tools/canary_c6_leakage_probe.py
```

Result: exit 0.

```bash
/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/tools/canary_diversity_check.py \
  --input /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/canary-anthropic-opus.jsonl \
  --output-md /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/diversity-report.md \
  --output-json /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/diversity-report.json
```

Output:

```text
status=PASS records=60 missing_text=0 warning_pairs=0 severe_pairs=0
```

```bash
/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/tools/canary_c6_leakage_probe.py \
  --canary-jsonl /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/canary-anthropic-opus.jsonl \
  --c6-jsonl /Users/wanglei/workspace/MAformac/contracts/c6-bench-cases.jsonl \
  --output /Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/N5-canary/canary-c6-leakage-probe.json
```

Output:

```text
status=pass c6_case_count=57 sample_case_id_count=120 intersections=0
```

## Diversity Result Snapshot

From `diversity-report.md`:

- status: `PASS`
- record_count: 60
- length min/p10/p25/median/p75/p90/max: 4 / 5.0 / 6.0 / 8.0 / 9.2 / 11.1 / 14
- unique_lengths: 11
- warning_pairs_>=0.85: 0
- severe_pairs_>=0.92: 0
- all 11 `subset_group_id` groups PASS.

The script uses these star thresholds:

- length breadth warning if unique input lengths < 5, p90-p10 < 6 chars, or non-empty length buckets < 3.
- near-duplicate warning if char 3-gram Jaccard >= 0.85; severe if >= 0.92.
- group diversity warning if n>=3 and unique ratio < 0.75, or group max pair similarity >= 0.92, or unique length count <= 2.

## C6 Leakage Result Snapshot

From `canary-c6-leakage-probe.json`:

- status: `pass`
- c6_case_count: 57
- c6_protected_case_count: 42
- canary_row_count: 60
- sample_case_id_count: 120
- c6_case_id_intersection_count: 0
- c6_protected_case_id_intersection_count: 0
- first_intersections: []

This is exact case-id leakage only. It does not prove semantic near-duplicate decontamination; that remains DataGate/judge/future leakage hygiene scope.

## Residual Risk

- G3 script is a lightweight canary guard, not the full Gate7 pipeline.
- G6 script checks exact ID intersections against C6 cases; it does not detect paraphrase-level semantic leakage.
- DataGate and OpenAI judge were outside this task.
- The main-tree concurrent changes should be treated as unowned by this task.
