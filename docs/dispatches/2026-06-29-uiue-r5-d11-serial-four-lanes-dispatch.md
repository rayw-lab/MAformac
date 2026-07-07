---
status: DISPATCH_READY
artifact_kind: commander_dispatch
dispatch_id: R5-D11-serial-four-lanes-with-hermes-and-harness
created_at: 2026-06-29
from: UIUE R5 commander
target_thread: 019f0ebc-8e13-74a0-a2fb-7a8d402645bf
brief_verdict_target: 019f10df-8ebc-7c71-b026-f3dbc0262153
source_checkpoint: D10 accepted under proof cap
mode: strict_serial
runtime_audit: hermes_required_after_each_step
hermes_timeout_seconds: 1200
proof_class_ceiling: docs/local + local_static + local_unit + openspec_contract + simulator_mock
no_push: true
non_claims:
  - no R5 complete
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

# Dispatch 11 - R5 Serial Four Lanes With Hermes Gates And Harness

## 0. Mode And Ordering

This is **D11**. Execute four lanes in strict serial order:

1. **Step 1 - UIUE human/art-threshold formalization lane**
2. **Step 2 - main C061 runtime adapter idempotency lane**
3. **Step 3 - main C018 SceneMacroRegistry/Core config authority lane**
4. **Step 4 - read-only UIUE/main merge-readiness audit lane**

Do not run these lanes in parallel. Do not start the next lane unless the current lane has:

- local validation PASS;
- Hermes audit PASS with the required step anchor;
- exact-path commit or explicit no-commit DONE justification;
- a brief verdict sent to `019f10df-8ebc-7c71-b026-f3dbc0262153`.

You should send 3 brief step verdicts after Steps 1-3, then one final full verdict after Step 4. Continue automatically after each brief `DONE` verdict. If a step is `PARTIAL` or `BLOCKED`, stop and return the blocker; do not continue.

## 1. Live Truth To Reconfirm Before Step 1

Reconfirm before any edit:

| repo | expected truth |
|---|---|
| UIUE | `/Users/wanglei/workspace/MAformac-uiue`, branch `uiue/phase4-default-scope-presentation`, HEAD `08e515f34a9af95661e7422495b03ffea90a998c`, clean except this source dispatch may be untracked before D11 starts |
| main | `/Users/wanglei/workspace/MAformac`, branch `codex/rebuild-c6-doc-absorption-20260624`, HEAD `8c81d130fe51399b73f20644529fcf2d74e35328`, preserve-unowned dirty only |

Main preserve-unowned paths must remain unstaged unless a step explicitly owns a different main path:

- `AGENTS.md`
- `CLAUDE.md`
- `docs/CURRENT.md`
- `docs/README.md`
- `.xcodebuildmcp/`
- `Tools/agent-platform-plugin-refs/`

If live truth differs, stop as `PARTIAL`. The only allowed pre-D11 UIUE exception is this source dispatch file being untracked and later staged by exact pathspec if Step 1 commits it.

## 2. Required Read-First Evidence

Read these before Step 1:

- `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-d10-commander-reconcile-2026-06-29.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`
- `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/burndown-dispatch-plan.md`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-mainline-deferred-gates-c005-c018-c061-2026-06-29.md`
- D9/D10 Hermes outputs referenced by the D10 receipt.

D10 accepted D9 under proof cap. Do not relitigate D9 unless a D11 step depends on evidence that is missing or stale.

## 3. Metacognitive Harness For Every Step

Each step must include this harness in its receipt or closeout:

1. **Pre-mortem**: write the top 3 ways this step could fake green.
2. **Goal-drift check**: restate the step goal and explicitly name non-goals.
3. **Authority check**: live repo/config/receipt evidence beats dated prose and subagent/Hermes prose.
4. **Claim-vs-proof check**: every claim must name its proof class.
5. **Boundary check**: no UIUE-created shared fields; no main code edits from UIUE-only lanes; no proof promotion.
6. **Self-question before Hermes**: "If this were wrong, what line/path would prove it?"
7. **Post-Hermes correction rule**: if files change after Hermes PASS, rerun local validation and Hermes for that step.

Record the harness outputs briefly. Do not write long essays; make it auditable.

## 4. Hermes Gate Template

After each step's local validation passes, run Hermes with a hard 1200 second timeout.

Use a step-specific run directory:

`/Users/wanglei/workspace/<repo>/Reports/r5-d11-stepN-<short-label>-20260629T<HHMMSS>/`

Required anchors:

- Step 1: `HERMES_R5_D11_STEP_1_ART_THRESHOLD_VERDICT: PASS|FAIL`
- Step 2: `HERMES_R5_D11_STEP_2_C061_VERDICT: PASS|FAIL`
- Step 3: `HERMES_R5_D11_STEP_3_C018_VERDICT: PASS|FAIL`
- Step 4: `HERMES_R5_D11_STEP_4_MERGE_READINESS_VERDICT: PASS|FAIL`

Hermes timeout, missing anchor, no usable evidence, or unresolved P0/P1 means `PARTIAL`. Stop immediately and send the blocker verdict to `019f10df-8ebc-7c71-b026-f3dbc0262153`.

## 5. Step 1 - UIUE Human/Art-Threshold Formalization Lane

### Goal

Convert the human-approved but lane-ambiguous art/threshold topic into a scoped UIUE decision/threshold lane artifact.

### Scope In

- Formalize whether `final-art capsule` and `white-edge threshold` are:
  - future human/art direction gates;
  - formal measurable threshold work;
  - simulator visual review prep only.
- Preserve D10 truth:
  - final-art capsule is not accepted by D9/D10;
  - white-edge remains `blocked_for_threshold`;
  - Stage 3 screenshot is simulator_mock evidence only.

### Scope Out

- No product final-art acceptance.
- No UI redesign unless the artifact explicitly stops and proposes a later implementation lane.
- No mobile/true-device/runtime proof.
- No main edits.

### Writable Paths

UIUE only:

- `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-d11-step1-human-art-threshold-formalization-2026-06-29.md`
- optionally update map/burndown if needed:
  - `/Users/wanglei/workspace/MAformac-uiue/docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`
  - `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/burndown-dispatch-plan.md`
- this source dispatch file, if it is still untracked:
  - `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-29-uiue-r5-d11-serial-four-lanes-dispatch.md`

### Validation

Run:

```bash
git diff --check
openspec validate ui-presentation --strict
git status --short
git diff --name-only
```

If no Swift/UI source changes, no Swift test is required.

### Hermes

Run Hermes after validation. Required anchor:

`HERMES_R5_D11_STEP_1_ART_THRESHOLD_VERDICT: PASS`

### Brief Verdict After Step 1

Send one short message to `019f10df-8ebc-7c71-b026-f3dbc0262153`:

```yaml
label: D11_STEP_1_ART_THRESHOLD
status: DONE | PARTIAL | BLOCKED
commit:
hermes_anchor:
proof_cap:
next: continuing_to_step_2 | stopped
```

Then continue to Step 2 only if status is `DONE`.

## 6. Step 2 - Main C061 Runtime Adapter Idempotency Lane

### Goal

Move `C061` beyond already-state no-double-write local/store proof by defining and testing the next honest runtime adapter idempotency boundary.

### Scope In

- main repo only.
- First classify whether current main has a runtime adapter surface that can be safely tested.
- If yes, implement the smallest C061 retry/idempotency proof with tests.
- If no, produce a mainline owner receipt/proposal that explains the missing adapter boundary and stop as `DONE` only if no implementation was possible and the no-code owner receipt is the intended output.

### Scope Out

- No UIUE edits.
- No production runtime-ready claim.
- No C005/C018 expansion.
- No new shared field for UIUE.

### Writable Paths

main only, exact paths discovered after impact analysis. Likely candidates include:

- `/Users/wanglei/workspace/MAformac/Core/...`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/...`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-d11-step2-c061-runtime-adapter-idempotency-2026-06-29.md`

Before editing any Swift symbol, run GitNexus impact per `AGENTS.md`. If impact is HIGH/CRITICAL, report the warning and stop unless the narrow edit can be redesigned as docs-only.

### Validation

At minimum:

```bash
git diff --check
openspec validate define-runtime-presentation-bridge --strict
openspec validate --all --strict
swift test --filter 'C3ExecutionPipelineTests|VehicleStateStoreContractTests|RuntimePresentationBridgeTests'
```

Broaden tests if touched files require it.

Run GitNexus `detect_changes(scope=staged)` before commit if code is staged.

### Hermes

Run Hermes after validation. Required anchor:

`HERMES_R5_D11_STEP_2_C061_VERDICT: PASS`

### Brief Verdict After Step 2

Send one short message to `019f10df-8ebc-7c71-b026-f3dbc0262153`:

```yaml
label: D11_STEP_2_C061
status: DONE | PARTIAL | BLOCKED
commit:
hermes_anchor:
changed_paths:
residual:
next: continuing_to_step_3 | stopped
```

Then continue to Step 3 only if status is `DONE`.

## 7. Step 3 - Main C018 SceneMacroRegistry/Core Config Authority Lane

### Goal

Create or formalize the mainline authority for `C018` without allowing UIUE to invent shared config fields.

### Scope In

- main repo only.
- Determine whether `SceneMacroRegistry` should be:
  - a real Core config/API now;
  - an OpenSpec/contract owner proposal first;
  - explicitly deferred with a sharper owner boundary.
- If implementing, keep it minimal and testable.

### Scope Out

- No UIUE shared field invention.
- No merge readiness claim.
- No runtime/mobile/true-device proof.
- No C061 retry work.

### Writable Paths

main only, exact paths discovered during step. Likely candidates:

- `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-presentation-bridge/...`
- `/Users/wanglei/workspace/MAformac/Core/...`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/...`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/r5-d11-step3-c018-core-config-authority-2026-06-29.md`

Run GitNexus impact before editing any Swift symbol. Do not edit main preserve-unowned paths.

### Validation

At minimum:

```bash
git diff --check
openspec validate define-runtime-presentation-bridge --strict
openspec validate --all --strict
swift test --filter RuntimePresentationBridgeTests
```

Broaden tests if touched files require it.

Run GitNexus `detect_changes(scope=staged)` before commit if code is staged.

### Hermes

Run Hermes after validation. Required anchor:

`HERMES_R5_D11_STEP_3_C018_VERDICT: PASS`

### Brief Verdict After Step 3

Send one short message to `019f10df-8ebc-7c71-b026-f3dbc0262153`:

```yaml
label: D11_STEP_3_C018
status: DONE | PARTIAL | BLOCKED
commit:
hermes_anchor:
authority_disposition:
next: continuing_to_step_4 | stopped
```

Then continue to Step 4 only if status is `DONE`.

## 8. Step 4 - Read-Only UIUE/Main Merge-Readiness Audit Lane

### Goal

Assess whether UIUE/main are ready for a future merge-readiness proposal after Steps 1-3. This step is read-only unless it writes a single audit receipt in UIUE.

### Scope In

- Read UIUE and main current heads.
- Read D10 and D11 Step 1-3 receipts/verdicts.
- Check whether main/UIUE have aligned:
  - bridge/snapshot authority;
  - proof class boundaries;
  - UIUE consumer mapping;
  - visual threshold status;
  - C061/C018 residuals.
- Output a merge-readiness audit verdict.

### Scope Out

- No merge.
- No push.
- No PR.
- No code changes.
- No claiming UIUE merge-ready if Steps 1-3 leave hard blockers.

### Writable Paths

UIUE audit receipt only:

- `/Users/wanglei/workspace/MAformac-uiue/docs/project/phase0/r5-d11-step4-merge-readiness-audit-2026-06-29.md`

### Validation

Run:

```bash
git diff --check
openspec validate ui-presentation --strict
```

If this read-only audit writes only UIUE docs, no Swift test is required.

### Hermes

Run Hermes after validation. Required anchor:

`HERMES_R5_D11_STEP_4_MERGE_READINESS_VERDICT: PASS`

Hermes must review:

- whether the audit stays read-only;
- whether merge-readiness is provisional or blocked;
- whether proof caps and non-claims remain intact;
- whether Step 1-3 residuals are correctly carried forward.

## 9. Final Verdict After Step 4

Send the final full YAML to `019f10df-8ebc-7c71-b026-f3dbc0262153`:

```yaml
status: DONE | PARTIAL | BLOCKED
label: UIUE_R5_D11_SERIAL_FOUR_LANES_WITH_HERMES_AND_HARNESS
source_dispatch: /Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-29-uiue-r5-d11-serial-four-lanes-dispatch.md
repo_truth:
  UIUE:
    head:
    status:
  main:
    head:
    status:
steps:
  step_1_art_threshold:
    status:
    receipt:
    hermes_anchor:
    commit:
  step_2_C061:
    status:
    receipt:
    hermes_anchor:
    commit:
  step_3_C018:
    status:
    receipt:
    hermes_anchor:
    commit:
  step_4_merge_readiness:
    status:
    receipt:
    hermes_anchor:
    commit:
validation_summary:
  - command:
    status:
changed_paths:
  UIUE:
    - path
  main:
    - path
non_claims:
  - no R5 complete
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
residual_risks:
  - item
next_step_recommendation:
no_push: true
```

## 10. Stop Conditions

Stop and send `PARTIAL` or `BLOCKED` if:

1. Any step lacks local validation PASS.
2. Any step Hermes audit times out, lacks the required anchor, or reports unresolved P0/P1.
3. Any step needs to edit outside its writable paths.
4. Any UIUE lane tries to invent shared mainline fields.
5. Any main lane touches preserve-unowned files.
6. Merge-readiness audit tries to merge, push, create PR, or claim final merge-ready before carrying Step 1-3 residuals.
7. Any wording claims R5 complete, runtime-ready, mobile, true_device, voice/model/golden/endpoint, UIUE merge, V/S/U-PASS, A-2, A-2 ready, or A-2 complete.
