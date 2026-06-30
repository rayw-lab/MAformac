---
status: DISPATCH_READY
artifact_kind: implementation_dispatch
created_at: 2026-06-28
from: UIUE R5 commander
to: mainline Codex window
target_thread: 019f0c69-972a-7f61-9515-3a101d5c0131
priority: P1
dispatch_id: R5-D2-mainline-contract-test-hardening
proof_class_ceiling: docs/local + openspec_contract + local_unit
source_map:
  - /Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md
  - /Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dual-branch-coordination-spec.md
  - /Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/burndown-dispatch-plan.md
  - /Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-presentation-bridge/
non_claims:
  - no R5 execution complete
  - no runtime-ready
  - no mobile proof
  - no true_device proof
  - no voice-ready
  - no model-ready
  - no golden-ready
  - no endpoint-ready
  - no UIUE merge
  - no V-PASS
  - no S-PASS
  - no U-PASS
  - no A-2
  - no A-2 ready
  - no A-2 complete
---

# Dispatch 2 - UIUE R5 Mainline Contract/Test Hardening

## 0. Route Metadata

- **TO**: mainline Codex window `019f0c69-972a-7f61-9515-3a101d5c0131`
- **FROM**: UIUE R5 commander
- **MODE**: bounded mainline implementation / deferral proof + audit loop
- **PRIORITY**: P1. Dispatch 1 has already given local/unit terminal snapshot adapter proof, but UIUE still cannot safely consume several contract behaviors until mainline locks or defers them with tests/receipts.
- **One-line deliverable**: for `C005`, `C006`, `C007`, `C018`, `C024`, `C029`, `C030`, `C052`, `C061`, and `C143`, create the smallest mainline OpenSpec/test/receipt hardening that makes each row either falsifiably covered or explicitly deferred with owner, proof cap, and next gate.
- **Proof ceiling**: `docs/local + openspec_contract + local_unit`. This dispatch cannot produce runtime/mobile/true_device/live/V/S/U proof.
- **Dispatch class**: implementation/contract-hardening dispatch with mandatory grill burndown, Codex subagent audit, and Hermes P0/P1 audit.

## 1. Cold-Start Context

MAformac is a pure-device macOS/iOS offline vehicle-control demo assistant, not production vehicle control. UIUE R5 consumes mainline Runtime-Presentation bridge contracts; UIUE must not invent shared fields, enum names, proof classes, or runtime payload parsing.

STEP0 and Dispatch 1 current truth:

- UIUE baseline frozen at `/Users/wanglei/workspace/MAformac-uiue` commit `926dec8311c63a7b51cd1a1a5f633009e25cf7d2`.
- Main calibration base was `/Users/wanglei/workspace/MAformac` HEAD `0a2ff0f7d30d6caf2d48f018f6b874828fb70c03`.
- Dispatch 1 locally covered `C012`, `C060`, `C017`, and `C022` for terminal snapshot adapter/factory behavior only. It did not prove real C3 runtime wiring.
- Main may currently contain uncommitted Dispatch 1 owned changes. Treat them as existing owned baseline for this main window; do not revert them and do not mix them with unrelated dirty files.

This Dispatch 2 focuses the remaining mainline contract/test hardening rows:

| Row | Current calibration | Dispatch 2 expected disposition |
|---|---|---|
| `C005` | Touch/event write ownership through executor/runtime adapter not behavior-proven. | Cover with contract/test/receipt, or explicitly defer to runtime adapter wiring with owner and proof gate. |
| `C006` | Event set closure is ambiguous if timeout is required as an event kind. | Rewrite into a falsifiable mainline assertion: timeout is either a closed event kind or an explicit terminal stop/result, with tests/spec proving the chosen contract. |
| `C007` | Event payload provenance vs scope split not fully locked at event level. | Cover with typed contract/test, or explicitly state that provenance/scope belongs in snapshot/outcome instead of event payload. |
| `C018` | `SceneMacroRegistry` is not present in live mainline Core; UIUE docs mention it only as candidate/historical concept. | Create mainline owner decision/receipt; do not let UIUE treat it as shared runtime config until mainline owns it. |
| `C024` | `TraceEnvelope` shape exists, but redaction lock/test is not proven. | Add redaction contract/test or bounded deferral; no raw model/store/training leakage. |
| `C029` | Active/refused priority semantics are unproven. | Rewrite to one falsifiable aggregation/priority assertion and cover or defer it. |
| `C030` | Card schema has DTO capacity, but scope/reason/active/sibling semantics are not fully locked. | Cover with schema/test/fixture or defer semantics that are outside bridge ownership. |
| `C052` | Force-state context gate lacks mainline proof. | Do not create production force-state behavior. Either lock `DEMO_MODE`/trace/provenance gating or defer behind explicit owner gate. |
| `C061` | Retry/idempotency no-double-write/no-swallowed-no-op proof is absent. | Add a bounded idempotency contract/test where bridge ownership exists, or defer runtime execution semantics. |
| `C143` | `TraceEnvelope.entries` append-only/time monotonic semantics are not locked. | Add append/monotonic contract/test or defer if current envelope is intentionally passive data. |

## 2. Authority And Source Truth

Read these first, in order:

1. `/Users/wanglei/workspace/MAformac/AGENTS.md`
2. `/Users/wanglei/workspace/MAformac/CLAUDE.md`
3. `/Users/wanglei/workspace/MAformac/docs/CURRENT.md`
4. `/Users/wanglei/workspace/MAformac/docs/README.md`
5. `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-presentation-bridge/`
6. `/Users/wanglei/workspace/MAformac/Core/Presentation/RuntimePresentationBridge.swift`
7. `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift`
8. `/Users/wanglei/workspace/MAformac/Core/Execution/C3ExecutionPipeline.swift`
9. `/Users/wanglei/workspace/MAformac/Core/Execution/ScopeResolution.swift`
10. `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`
11. `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/burndown-dispatch-plan.md`

Authority order:

1. mainline OpenSpec + mainline Swift carrier + mainline tests/receipts
2. this dispatch
3. UIUE R5 coordination docs as provenance/coordination only

UIUE docs are not mainline shared-field authority. If a row requires shared field naming, mainline must decide it or defer it; UIUE cannot fill the gap.

## 3. Mandatory Preflight

Run and record:

```bash
cd /Users/wanglei/workspace/MAformac
pwd
git branch --show-current
git rev-parse HEAD
git status --short --branch
openspec validate define-runtime-presentation-bridge --strict
git diff --check
```

Also confirm UIUE frozen/reference state without modifying UIUE:

```bash
cd /Users/wanglei/workspace/MAformac-uiue
git rev-parse HEAD
git status --short --branch
git log -1 --oneline
```

Before edits, classify dirty state:

- `owned`: files Dispatch 2 will touch.
- `preserve_unowned`: existing dirty files not owned by Dispatch 2.
- `dispatch_1_existing_owned`: prior D1 bridge/test/spec/receipt changes, if present in the same main thread.
- `no_touch`: UIUE repo, unrelated main docs/config/tooling, raw source material.

Do not stage, commit, push, or use `git add .` unless the user separately authorizes git integration. If staging later becomes authorized, use exact pathspecs only.

## 4. Grill / Burndown Source Truth

| Source | Artifact role | Scope | IDs | Authority status |
|---|---|---|---|---|
| `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/burndown-dispatch-plan.md:165-186` | frozen R5 burndown source | M2 | includes `C005`, `C006`, `C007`, `C018`, `C024`, `C029`, `C030`, `C052`, `C061`, `C143` | active input |
| `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md:107-114` | commander decomposition | Dispatch 2 | `C005`, `C006`, `C007`, `C018`, `C024`, `C029`, `C030`, `C052`, `C061`, `C143` | dispatch authority |
| `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md:144-164` | wait gate list | Dispatch 2 | same rows | current wait-state authority |
| `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md:118-123` | K1 ledger | K1 | `C082`, `C083`, `C096`, `C117`, `C182`, `C197`, `C207`, `C208` | spike ledger only |

This dispatch covers only Dispatch 2 rows. K1 remains a spike-before-implementation ledger. Do not promote K1 rows into implementation, and do not hide them by absorbing them into broad wording.

## 5. Task Shape

For each row, choose exactly one disposition:

1. `covered`: a mainline spec/test/receipt now proves the row with local/unit evidence.
2. `deferred_with_owner`: mainline explicitly says the row is real but belongs to a later runtime/client/spike lane, with owner, proof class, and next validator.
3. `non_claim_guard`: the row is a guardrail only and should not become implementation.
4. `blocked`: only after self-service probing proves the row cannot be decided without missing authority.

Do not leave a row as vague `needs-validation`. Convert it to one of the four dispositions above.

Minimum expected hardening:

- `C006`, `C029`, `C052`, and `C061` must be rewritten into falsifiable assertions before any implementation. Keep original IDs as provenance.
- `C018` must not create a hidden UIUE planner. Either mainline owns a Core config concept with tests/spec, or the row is deferred/blocked with reason.
- `C024` and `C143` should be handled together if possible, because both concern trace envelope semantics.
- `C005` and `C061` should be checked for same-class state mutation risk: no direct store writes, no duplicate writes, no swallowed no-op.
- `C030` should not add broad UI-facing copy. It should lock machine-readable card semantics or explicitly defer presentation-only semantics to UIUE.

## 6. Writable And No-Touch Paths

Writable in `/Users/wanglei/workspace/MAformac` only:

- `/Users/wanglei/workspace/MAformac/Core/Presentation/RuntimePresentationBridge.swift`
- `/Users/wanglei/workspace/MAformac/Core/Presentation/`
- `/Users/wanglei/workspace/MAformac/Core/Execution/` only if a minimal ownership/idempotency contract truly belongs there
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/`
- `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-presentation-bridge/`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/`
- `/Users/wanglei/workspace/MAformac/Reports/` for ignored audit artifacts if needed

No-touch:

- `/Users/wanglei/workspace/MAformac-uiue/` except read-only reference.
- raw customer/source materials.
- unrelated main dirty files unless they are explicitly classified as owned by this dispatch.
- C5/C6/model/voice/golden/mobile/true-device/endpoint implementation.
- UIUE consumer mapping code; that is a later UIUE dispatch after mainline verdict.

## 7. Dual-Branch Divergence Rules

Mainline owns:

- shared event/result/snapshot/proof names
- trace envelope semantics
- write ownership and idempotency contracts where they touch runtime bridge boundaries
- any `SceneMacroRegistry` or equivalent Core config authority

UIUE owns later:

- local/simulator presentation consumer mapping
- docs/local matrix and product wording
- visual/layout/a11y presentation behavior after mainline names are stable

UIUE must not:

- invent shared fields
- parse mainline runtime payload before mainline adapter contract exists
- write shared adapter code
- promote local/simulator proof into runtime/mainline proof

Preserve this split in the receipt.

## 8. Harness And Metacognition Requirements

Apply these execution rules:

1. **Truth-first start**: repo, branch, HEAD, dirty, nearest authority, and validation commands before edits.
2. **Scope contract before edits**: goal, non-goals, writable paths, no-touch paths, validation gates, stop conditions.
3. **Read before edit**: cite exact file:line for every load-bearing claim.
4. **No fake green**: if a row lacks proof, mark `deferred_with_owner`, `non_claim_guard`, `blocked`, or `PARTIAL`, not DONE.
5. **Owned/unowned split**: preserve existing dirty residual and prior Dispatch 1 owned changes; do not revert user/other-agent work.
6. **Pathspec only**: if staging later becomes authorized, use exact pathspecs; never `git add .`.
7. **Proof class discipline**: docs/local/unit proof cannot become runtime/mobile/true-device/live/V/S/U proof.
8. **Grill burndown required**: closeout must include before/after status for all 10 rows and mention K1 as untouched spike ledger.
9. **Same-class risk map**: audit related paths for stale async mutation, missing trace identity, raw leak, proof promotion, and direct store writes.
10. **Codex subagent audit required**: after local implementation and before final verdict, run a Codex native subagent audit scoped to P0/P1 risks in Dispatch 2. If unavailable, no evidence, or unresolved P0/P1, final status must be `PARTIAL`.
11. **Hermes audit required**: after local validation, run the Hermes audit loop below.

## 9. Hermes Audit Loop

After implementation and local tests pass, run a GLM/Hermes audit focused on P0/P1. Limit the total audit/fix/rerun loop to **20 minutes wall clock**. Do not rush the implementation; the 20 minute cap is for the Hermes review loop after local validation.

Suggested command shape from `/Users/wanglei/workspace/MAformac`:

```bash
mkdir -p Reports/r5-mainline-contract-hardening-$(date +%Y%m%dT%H%M%S)
/Users/wanglei/.codex/skills/hermes-cli-glm52-code/scripts/hermes_glm52_code.py run \
  --prompt-file /absolute/path/to/hermes-r5-mainline-contract-hardening-audit-prompt.md \
  --timeout 1200
```

Hermes audit prompt must include:

- this dispatch path
- files changed
- `git diff --stat`
- relevant diff or patch
- validation output
- per-row disposition table
- non-claims
- exact ask: identify P0/P1 only, especially vague `needs-validation`, DTO-only fake pass, shared-field invention by UIUE, direct store writes, raw model/store/training leaks, proof promotion, Dispatch 1 regression, dirty/staging risk, and missing row coverage.

Loop rule:

- If Hermes reports P0/P1: fix only in scope, rerun focused validation, rerun Hermes if time remains.
- Continue until no P0/P1 or 20 minutes expires.
- If 20 minutes expires with unresolved P0/P1, final status must be `PARTIAL`, not DONE.
- P2/P3 may be carried as residual risk with owner/trigger.

## 10. Required Validation

Minimum validation:

```bash
cd /Users/wanglei/workspace/MAformac
openspec validate define-runtime-presentation-bridge --strict
openspec validate --all --strict
git diff --check
swift test --filter RuntimePresentationBridgeTests
```

If touched surface expands beyond bridge tests, add the smallest relevant tests. Do not run C5/C6/model/voice/golden/mobile/true-device gates under this dispatch.

## 11. Completion Receipt Format

Return a verdict to the commander with:

```text
status: DONE / PARTIAL / BLOCKED
can_return_to_commander: yes/no
repo_truth:
  main branch:
  main HEAD:
  dirty before:
  dirty after:
  UIUE reference HEAD/status:
owned_paths:
preserve_unowned:
dispatch_1_existing_owned:
no_touch_confirmed:
row_disposition_table:
  row_id | before | after | disposition | proof_path | proof_class | validation | remaining_gap_or_next_owner
rewrite_receipts:
  C006:
  C029:
  C052:
  C061:
K1_status:
  untouched_spike_ledger: yes/no
validation:
  command | result | proof_class
subagent_codex_audit:
  status:
  findings_P0_P1:
  disposition:
  evidence:
hermes_audit:
  status:
  elapsed_minutes:
  findings_P0_P1:
  disposition:
  run_dir:
  output:
non_claims:
residual_risks:
can_UIUE_start_consumer_mapping: yes/no
next_step:
```

`can_UIUE_start_consumer_mapping` may be `yes` only if all Dispatch 2 rows are either covered or explicitly deferred/non-claim with no unresolved P0/P1, Dispatch 1 coverage is preserved, Codex subagent audit returns evidence with no unresolved P0/P1, and Hermes audit returns no unresolved P0/P1. It still does not mean runtime-ready or UIUE merge.

## 12. Stop Conditions

Stop and report `PARTIAL` or `BLOCKED` if:

1. The task requires full runtime backend loop, real model execution, C5/C6, voice, golden, mobile, true-device, endpoint, or UIUE code changes.
2. A row requires a new shared field that mainline cannot justify in OpenSpec or typed carrier.
3. Implementation would require `ScopeOrigin.missing` or equivalent Core enum expansion.
4. The fix only adds DTO/Codable tests while leaving row behavior/contract vague.
5. Any row remains vague `needs-validation` at closeout.
6. Hermes or Codex subagent reports unresolved P0/P1 and time expires, or Codex subagent audit is unavailable / returns no evidence.
7. Dirty tree ownership cannot be separated safely.
8. Any wording claims R5 complete, runtime-ready, mobile, true_device, voice-ready, model-ready, golden-ready, endpoint-ready, UIUE merge, V-PASS, S-PASS, U-PASS, or A-2 complete.
