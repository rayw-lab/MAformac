---
status: PASS_WITH_NONCLAIM_MATCHES
artifact_kind: cascade_audit
created_at: 2026-07-06T13:40:00+08:00
proof_class: local receipt consistency audit
scope: tail1200 iter600 final closeout artifacts and sampled run docs
---

# Tail1200 Iter600 Final Cascade Audit L-CO

## Verdict

`PASS_WITH_NONCLAIM_MATCHES`.

The closeout separates old formal 1800 HOLD/PARTIAL from tail1200 iter600 final training artifacts. The tail1200 adapter files are saved and hash-matched. The trainer pid sample is not live. Stronger product/model claims remain explicit non-claims.

## Authority Boundaries Checked

- `CLAUDE.md:133` keeps C5 retrain/C6 acceptance/candidate comparison/model-quality/golden/voice/UIUE/V/S/U-PASS locked behind later gates.
- `docs/CURRENT.md:21-27` records old formal HOLD, current tail1200 as non-true-resume/non-candidate/non-C6/non-V-PASS, and warns not to promote live telemetry into candidate or C6 proof.
- `docs/CURRENT.md:87-90` forbids converting train health into behavior/candidate/C6 acceptance and requires candidate signoff plus proof-class evidence for C6 comparison, demo-golden, voice/live-loop claims.

## Evidence Reconciliation

| Topic | Result | Evidence |
| --- | --- | --- |
| old formal 1800 | `HOLD/PARTIAL` | `FORMAL-TRAIN-RECEIPT.md:1-9`, `:35-40` |
| old formal final tail | stopped before final | old `metrics.jsonl` tail ends at `iteration=1692` / `update_step=423`; old `train.log` tail ends at `Iter 1690`; no `*1800*` adapter file found |
| old formal candidate | unsigned | `FORMAL-TRAIN-RECEIPT.md:8` |
| old formal adapter QA | false | `FORMAL-TRAIN-RECEIPT.md:9` |
| tail1200 iter600 val | `0.01540403999388218` | `metrics.jsonl:217`; `train.log:78` rounded |
| tail1200 iter600 train | `0.009280303120613098` | `metrics.jsonl:220`; `train.log:79` rounded |
| tail1200 final sha | `9373fd4174922c4e697f188e24756758ec5a236eb6ae944dfaf115450363d8d6` | `shasum -a 256` command output |
| tail1200 final save | rolling + `0000600` saved | `train.log:80-81`; `find adapters-rank16` listed both files |
| trainer pid | not live at sample | `ps -p 42505 -o pid=,stat=,command= || true` returned empty stdout |

## Required Validation Commands Recorded

1. `tail -n 12 metrics.jsonl`
   - Found final `val` at iteration `600`, `val_loss=0.01540403999388218`.
   - Found final `optimizer_update` at iteration `600`, `update_step=150`.
   - Found final `train_report` at iteration `600`, `train_loss=0.009280303120613098`.

2. `tail -n 30 train.log`
   - Found `Iter 600: Val loss 0.015`.
   - Found `Iter 600: Train loss 0.009`.
   - Found saved adapter weights to both `adapters.safetensors` and `0000600_adapters.safetensors`.
   - Found saved final rolling weights.

3. `shasum -a 256 adapters-rank16/adapters.safetensors adapters-rank16/0000600_adapters.safetensors`
   - Both files hash to `9373fd4174922c4e697f188e24756758ec5a236eb6ae944dfaf115450363d8d6`.

4. `ps -p 42505 -o pid=,stat=,command= || true`
   - Empty stdout; sampled pid not live.

5. Claim grep command:
   - `rg -n "candidate_status=sign[e]d|adapter_learned_qa=tr[u]e|C6 acceptance|V-PASS|voice ready|UIUE merge" ...`
   - Actual matches are non-claim language or authority quotes. The W11 receipts match `no adapter_learned_qa=true`, `no C6 acceptance`, and `no V-PASS`; these are explicit denials, not positive claims. `docs/CURRENT.md` and `CLAUDE.md` matches are authority stoplines / historical route text. No `candidate_status=signed`, no positive `adapter_learned_qa=true`, no `voice ready`, and no accidental `UIUE merge` readiness claim were found.

## Cascade Fixes Required

None for the three W11 closeout files after this audit, unless the final grep finds a positive claim rather than a non-claim. Any future update must preserve:

- old formal 1800 = HOLD/PARTIAL, no iter1800 final, no checkpoint1800, candidate unsigned
- tail1200 iter600 = runtime/local training artifact final, not candidate
- final sha = `9373fd4174922c4e697f188e24756758ec5a236eb6ae944dfaf115450363d8d6`
- no stronger proof-class claims

## Residual Risk

- This audit does not evaluate model behavior.
- This audit does not run C6.
- This audit does not prove runtime QA safety.
- This audit does not inspect UIUE/voice/mobile/true-device paths.
