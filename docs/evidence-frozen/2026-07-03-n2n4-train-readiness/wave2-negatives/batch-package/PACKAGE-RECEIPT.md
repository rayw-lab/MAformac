# R2b S1 Batch Package Receipt

status: package_ready_no_generation
artifact_kind: r2b_s1_package_receipt
proof_class: local_spec_instantiation_pre_generation
created_by: %45
created_at: 2026-07-03

## Scope

Prepared the R2b S1 negative-repair calibration package under:

`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness/wave2-negatives/batch-package/`

This package is ready for later subCC generation dispatch. It does not generate rows, run DataGate, run judge, or authorize training.

## Package Files

| file | purpose |
|---|---|
| `r2b-s1-batch-order.json` | machine-readable 150-row S1 order, split into 2 lanes x 75 |
| `lane-prompt-package.md` | paste-ready lane generation instructions and inline hard clauses |
| `MECHANICAL-GATES-r2b-s1.md` | full mechanical gate checklist before judge |
| `JUDGE-SPEC-r2b-s1-template.md` | OpenAI-family judge template, instantiated per lane after output lands |
| `PACKAGE-RECEIPT.md` | this receipt |
| `SHA256SUMS.txt` | current package file hashes |

## Bound Evidence

| evidence | verified fact |
|---|---|
| `WAVE2-RECIPE-PLAN.md` | R2b recipe SSOT accepted by commander; S1 total 150, 2 lanes x 75; family/class table and tool floor constraints |
| `BATCH-CONTRACT-rev2.md` | status `rev2.1_locked_aligned`; ledger, derived hash recompute, artifact SHA, `paused_diversity` are hard clauses |
| `WAVE2-GENERATOR-HARDENING.md` | query expected shape is `query_*`; refusal/unsupported/already_state expected shape is `NO_TOOL` |
| `C5LoRATraining.swift:280-326` | current sample structure carries `expected_tool_calls` and `no_call` metadata |
| `C5LoRATraining.swift:1854-1858` | current protocol render includes `action=` segment |
| `C5LoRATraining.swift:2645-2670` | current no-call builder writes assistant content `NO_TOOL` |

## Lane Split

| lane | target rows | families | class quota |
|---|---:|---|---|
| `r2b-s1-lane-a` | 75 | ac, seat, window, door, atmosphere_lamp | 45 positive / 10 query / 5 refusal / 5 already_state / 5 unsupported / 5 followup |
| `r2b-s1-lane-b` | 75 | screen, volume, wiper, sunroof_sunshade, fragrance | 45 positive / 10 query / 5 refusal / 5 already_state / 5 unsupported / 5 followup |

## Important Constraint Note

R2b S1 preserves the 15-row-per-family calibration shape. Some W2 full tool-floor requirements cannot be fully exhausted inside a single 15-row family slice without breaking the S1 class mix. The order therefore records S1 high-risk coverage plus explicit `s2_floor_carry_forward_required` items instead of claiming full W2 floor completion.

## Validation

Local pre-generation checks performed:

- `r2b-s1-batch-order.json` parses with `jq`.
- Required package files exist.
- Key anchors exist for `RER-6`, `query_*`, `NO_TOOL`, `tool_pair_floor_id`, `contrastive_pair_id`, `near_neighbor_group_id`, `paused_diversity`, and judge sample formula.

No generation, judge, DataGate, training, or repo code edit was run.
