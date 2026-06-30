# Rebuild C6 Scoring Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. This is a harness-driven implementation contract, not a discussion note.

**Goal:** Implement the first rebuild-C6 construction coding pass after post-A2, post-PR4 `default_scope`, and R-L17 route-only signoff: the C6 scoring foundation. The pass must remove the current fake-green scoring roots by adding a shared behavior taxonomy, two-axis C6 reporting, selector/denominator shells, descriptive apply write facts, C6 replay consumption of those facts, dependency-write provenance, and readback hard-pass separation.

**Architecture:** Rebuild-C6 consumes upstream facts instead of becoming a second runtime. `BehaviorClass` is shared by C5 data receipts, C6 denominator/selector reporting, and apply/execution no-effect reasoning. Apply/execution owns `StateWrite` facts and keeps throwing fail-closed; C6 consumes `appliedWrites` and derives unexpected mutation evidence without passing expected C6 sets into apply. Readback remains renderer-owned and is reported separately from model hard pass.

**Tech Stack:** Swift, XCTest, OpenSpec, Makefile, existing Python surface scripts, `rg`, `git`, local markdown receipts. No model runtime, no training runtime, no endpoint runtime.

**Global Constraints:** This plan authorizes only local construction code for scoring foundation. It forbids retrain-C5, C6 acceptance, D-domain base recalibration, `rebuild-c6` §4 candidate comparison, model-quality evaluation, training data generation, LoRA artifact changes, demo golden-run, voice, endpoint readiness, UIUE merge claims, R-L17 candidate signoff, and any `V-PASS`/`S-PASS`/`U-PASS` claim. Allowed proof classes are only `local_static_contract`, `local_unit`, and `local_receipt_consistency`; `local_shape_no_model_baseline_unchanged` is an optional unchanged-baseline guard, not proof that D-domain C6 JSONL shape migration is complete.

**Metadata**

| Field | Value |
|---|---|
| `change_id` | `rebuild-c6-four-layer-bench` |
| `plan_date` | `2026-06-25` |
| `route` | `post-A2 / post-PR4 default_scope / post-R-L17 route-only rebuild-C6 construction apply` |
| `long_run_slice` | Long-run 1 of 2 |
| `local_ends_at` | Phase 3 scoring foundation plus L3 local closeout |
| `external_audit_gate` | Push GitHub branch after L3, then request GPT Pro audit before handoff to implementation consumers |
| `next_long_run` | Phase 4-6 identity and shape closeout: `contract_bundle_fingerprint`, D-domain C6 case shape migration, final closeout |

---

## Scope Contract

### Scope In

- L0 live baseline and harness proof.
- Phase 1A: shared behavior taxonomy and `C6BenchCase.behavior_class` compatibility.
- Phase 1B: two-axis reporting DTOs: external layer and internal behavior class.
- Phase 1C: selector/denominator shell with no active thresholds and no base recalibration.
- Phase 2: apply/execution descriptive write facts: `StateWrite`, `StateWriteKind`, `appliedWrites`.
- Phase 3: C6 replay consumption of applied writes, dependency provenance, unexpected mutation checks, and readback Plan P hard-pass split.
- Phase-level read-only Codex subagent audits.
- Local unit/static/shape verification and durable closeout receipt.
- Post-local GitHub push solely to make the branch reviewable by GPT Pro, followed by GPT Pro external audit.
- Continuous pre-mortem and lessons capture during execution.

### Scope Out

- No retrain-C5.
- No C6 acceptance run.
- No D-domain base recalibration.
- No `rebuild-c6` §4 candidate comparison.
- No model-quality evaluation.
- No training data generation.
- No LoRA adapter or checkpoint changes.
- No demo golden-run.
- No voice, ASR, endpoint readiness, or UI automation claim.
- No UIUE merge or UIUE mainline assertion.
- No R-L17 candidate signoff.
- No `V-PASS`, `S-PASS`, `U-PASS`, endpoint-pass, or demo-ready claim.
- No `contract_bundle_fingerprint` implementation in this long-run.
- No C6 JSONL D-domain shape migration in this long-run.
- No GitHub push before L3 local gates pass. The only planned push is the final GPT Pro audit handoff push.

### Expected Starting Write Set

Start from these paths:

- `/Users/wanglei/workspace/MAformac/Core/Bench/C6VehicleToolBench.swift`
- `/Users/wanglei/workspace/MAformac/Core/Contracts/ToolContractCompiler.swift`
- `/Users/wanglei/workspace/MAformac/Core/Contracts/VehicleToolBehaviorClass.swift`
- `/Users/wanglei/workspace/MAformac/Core/Contracts/StateWrite.swift`
- `/Users/wanglei/workspace/MAformac/Core/Contracts/*`
- `/Users/wanglei/workspace/MAformac/Core/Bench/*`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/ToolContractCompilerTests.swift`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/*`
- `/Users/wanglei/workspace/MAformac/scripts/*`
- `/Users/wanglei/workspace/MAformac/Makefile`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-scoring-foundation-closeout-2026-06-25.md`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-scoring-foundation-lessons-2026-06-25.md`
- `/Users/wanglei/workspace/MAformac/Reports/rebuild-c6-scoring-foundation-<timestamp>/VERIFY.md`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-scoring-foundation-gptpro-audit-request-2026-06-25.md`

This is a starting write set, not a cage. GPT-5.5/Codex has authority to add or modify adjacent implementation, tests, scripts, and docs when live repo truth shows that doing so is the smaller, cleaner, or safer implementation. Every expansion must be recorded in `VERIFY.md` under `Scope Expansion Record` with: path, reason, invariant protected, tests added, and why no no-touch path was needed.

If implementation can keep `VehicleToolBehaviorClass` or `StateWrite` inside existing files without reducing clarity, that is allowed, but the public API must remain shared and not C6-private. If a better file name emerges from repo inspection, use it and record the rename rationale.

### No-Touch Paths

- `/Users/wanglei/workspace/MAformac/contracts/c6-bench-cases.jsonl`
- `/Users/wanglei/workspace/MAformac/generated/D_domain.tools.demo.json`
- `/Users/wanglei/workspace/MAformac/contracts/semantic-function-contract.jsonl`
- `/Users/wanglei/workspace/MAformac/contracts/state-cells.yaml`
- `/Users/wanglei/workspace/MAformac/Core/Training/*`
- `/Users/wanglei/workspace/MAformac/Models/*`
- `/Users/wanglei/workspace/MAformac/Voice/*`
- `/Users/wanglei/workspace/MAformac/openspec/changes/retrain-c5-lora-d-domain/*`
- `/Users/wanglei/workspace/MAformac/openspec/changes/rebuild-c6-four-layer-bench/tasks.md`, unless a human asks for a task status update after code closes
- `/Users/wanglei/workspace/MAformac-uiue/*`

No-touch paths are hard route boundaries for this long-run. If GPT-5.5 concludes a no-touch path is truly necessary, stop and produce a pre-mortem amendment instead of silently editing it.

### Proof Classes Allowed

- `local_static_contract`
- `local_unit`
- `local_receipt_consistency`

Optional unchanged-baseline guard:

- `local_shape_no_model_baseline_unchanged`

Any proof involving model inference, C6 acceptance, golden-run, endpoint, voice, or UI must stop and be recorded as forbidden for this long-run.

---

## Decisions Already Absorbed

This implementation plan absorbs the Q1-Q5 grill decisions and the two-pass harness review.

| Source | Absorbed decision |
|---|---|
| Q1 R-L17 | Route-only signoff unlocks only `rebuild-c6-four-layer-bench` §1/§2/§3 construction. Retrain-C5, C6 acceptance, §4 candidate comparison, and R-L17 candidate signoff remain blocked. |
| Q2.1 | Paper absorption is mechanism-first: value-in-source, algorithm constraints, fail-closed. Naked fields are fake absorption. |
| Q2.2 | Internal behavior classes are exactly five: `tool_call`, `clarify_missing_slot`, `refusal_no_available_tool`, `refusal_safety_or_policy`, `already_state_noop`. `direct_no_call` is rejected for MAformac. |
| Q2.3 | Freeze denominator logic, not thresholds or active base anchors. Selector mechanics wait until behavior taxonomy and `C6Bucket` reconcile. |
| Q2.4 | C5 data receipt implementation remains retrain-C5 work, but the shared taxonomy and anti-metadata proof boundary are rebuild-C6 inputs. |
| Q2.5 | ToolRAG, description-free, and DoRA are deferred or conditional spikes, not part of scoring foundation. |
| Q3.1-Q3.2 | C6 consumes ScopeOrigin/apply facts and must not rebuild runtime. Delta ownership is taxonomy / apply / rebuild-C6, not only rebuild-C6. |
| Q3.3 | `StateApplyDiagnostics` is minimal descriptive evidence: `appliedWrites` and `unexpectedMutations`-derived facts. No planner, no errors list, no no-effect semantic enum inside apply. |
| Q3.4 | `write_kind = direct | dependency`; `noop` is not a write kind. Dependency and enum writes must first produce evidence. |
| Q3.5-Q3.6 | Fingerprint aggregation is later; readback hard-pass split is in this scoring foundation. |
| Q4 | `rebuild-C6` construction lane is independent of retrain-C5 candidate. §4 candidate comparison remains later. |
| Q5.1 | Route-only construction can proceed, but only for local construction proof. |
| Q5.2 | Shared type should be named `VehicleToolBehaviorClass` or `BehaviorClass`, not C6-private `C6BehaviorClass`. |
| Q5.3 | `ScopedStateKey` helper is conditional. Do not create it unless this pass introduces duplicated scoped-key parsing. |
| Q5.4 | Selector work is classification and denominator shell only. No thresholds, no base run, no recalibration. |
| Q5.5 | `StateWrite` has only `stateKey`, `beforeValue?`, `afterValue`, `scopeOrigin?`, and `writeKind`. |
| Q5.6 | Dependency side effects must be proven from applied-write provenance, not guessed from final-state dependency expansion. |
| Q5.7 | Readback is excluded from model hard pass and reported separately. |
| Q5.10 | Reporting must be two-axis: external layer and internal behavior class. |
| Q5.11 | Static/unit/shape proof only. No runtime/eval inflation. |
| Q5.12 | UIUE read-only impact check is conditional on touching shared state/contracts/generated/golden/readback surfaces. No UIUE merge claim. |
| Q5.13 | Use staged commits; no giant mixed commit. |

---

## Harness Rules From Two-Pass Review

These rules are binding for the executor.

1. This is a finite-state dispatch, not a loose checklist. Every phase must have L1 step verification, L2 phase gate, and subagent audit.
2. Every Q5 P0 decision must cash out as either a red test, a static check, or a closeout assertion with command evidence.
3. `Core/Bench/C6VehicleToolBench.swift` is a same-file write hotspot. Only one writer may edit it at a time. Subagents may audit it read-only after each phase.
4. `Reports/` is ignored by git. `Reports/rebuild-c6-scoring-foundation-*/VERIFY.md` is allowed as scratch evidence, but durable closeout must also live at `/Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-scoring-foundation-closeout-2026-06-25.md`.
5. Do not summarize verification as "passed" without stdout. The executor must paste the relevant command, exit code, and high-signal output into `VERIFY.md`.
6. `make verify` can fail on dirty-tree policy during active edits. Use focused tests during phases; reserve full route-level validation for a clean or intentionally staged state.
7. Static teardown is not validation. Teardown can justify scope, but closeout needs commands.
8. A field name is not absorption. A field only counts when derived from source truth, tested, and fail-closed.
9. Code snippets in this plan are target shapes, not paste contracts. Inspect the current helper/API signatures first, then choose the smallest repo-native implementation that satisfies the tests and invariants.
10. GPT-5.5/Codex has broad implementation authority inside the route boundaries: it may improve names, file placement, helper decomposition, test strategy, scripts, and local structure when that produces a simpler or more reliable result. Do not mechanically follow a snippet if repo truth suggests a better implementation.
11. Harness cannot be downgraded. Phase subagent audit is a hard gate. If Codex subagents are unavailable, stop at `BLOCKED: missing phase audit lane`; do not replace it with same-thread self-audit unless the human owner explicitly changes this plan.
12. GitHub push is forbidden until L3 local closeout passes and all implementation commits are present. After L3, push the branch only to enable GPT Pro audit; do not merge, archive, or claim product readiness from the push.
13. GPT Pro external audit is a hard post-local gate. If push or GPT Pro audit is unavailable, stop at `local-pass pending external audit`; do not hand off as fully closed.
14. Run a short pre-mortem at the start of every phase and record the top 3 expected failure modes in `VERIFY.md` before editing that phase.
15. Record lessons as they happen. Any surprising failure, false-green risk, bad assumption, helper mismatch, flaky command, or scope expansion must be written immediately to `VERIFY.md` and then summarized in the durable lessons file during L3.

---

## Autonomy Contract For GPT-5.5/Codex

The executor is expected to think, not transcribe. Use repo truth, tests, and local architecture to choose the best implementation that satisfies the invariants.

Allowed autonomy:

- Replace suggested snippets with a cleaner repo-native design.
- Add small helper types, files, scripts, or test helpers when they reduce coupling or improve proof quality.
- Split a phase into smaller commits if the same-file change grows too large.
- Add stronger red tests than the plan lists.
- Add static checks when a false-green path is easier to prevent mechanically than by review.
- Update closeout and lessons docs with evidence discovered during implementation.
- Reorder micro-steps within a phase when TDD or compiler feedback demands it.

Hard invariants:

- The five behavior classes remain the shared source: `tool_call`, `clarify_missing_slot`, `refusal_no_available_tool`, `refusal_safety_or_policy`, `already_state_noop`.
- No `direct_no_call`.
- No `StateWriteKind.noop`.
- No C6-owned apply engine.
- No expected C6 sets passed into `ToolContractStateApplier.applyWithEvidence`.
- Dependency side effects require both applied-write provenance and `stateCells.dependsOn` proof.
- Readback does not set model hard pass/fail.
- No forbidden work or readiness claims.
- No harness downgrade: phase subagent audit and GPT Pro audit remain hard gates.

Deviation rule:

If the implementation chooses a better path than the snippet, write this to `VERIFY.md`:

```markdown
### Scope/Design Deviation

phase: <phase>
decision: <what changed from plan>
reason: <repo truth / compiler / test / simpler design>
invariant_protected: <which Q/Q5/OpenSpec invariant>
files_touched: <paths>
tests_added_or_changed: <tests>
residual_risk: <risk or none>
```

---

## Continuous Premortem And Lessons

At the start of each phase, write a short phase pre-mortem into `VERIFY.md`:

```markdown
## Phase <N> Pre-Mortem

1. likely failure:
   prevention:
   detection:
2. likely failure:
   prevention:
   detection:
3. likely failure:
   prevention:
   detection:
```

During the phase, append lessons immediately:

```markdown
### Lesson

phase:
trigger:
bad_assumption:
repo_truth:
fix:
future_guard:
```

At L3, create the durable lessons file and copy the high-signal lessons from `VERIFY.md`.

---

## Pre-Dispatch Audit Absorption

Two pre-dispatch audits were absorbed before this plan was frozen:

| Auditor | Verdict | Absorbed fixes |
|---|---|---|
| Codex subagent `Euler` | `PASS_WITH_FIXES` | dependency side-effect proof must bind `appliedWrites` and `stateCells.dependsOn`; phase gates need Pass/Fail and Failure Action; route-only wording must not imply candidate/training/C6 acceptance unlock; final diff must use `BASE_SHA`; forbidden scans must be touched-file scoped. |
| GLM heterogeneous audit | `PASS_WITH_FIXES` | add B0 plan freeze; avoid over-prescriptive snippets; make helper/API baseline explicit; remove forbidden-scan false positives; keep subagent/GPT Pro audit as hard gates; record lessons continuously; give GPT-5.5 autonomy inside route boundaries without weakening harness. |

The remaining implementation authority belongs to the executing GPT-5.5/Codex agent, constrained by hard invariants and proof gates rather than by paste-ready snippets.

---

## B0: Plan Freeze Before Execution

**Purpose:** Make the implementation plan stable before L0. This avoids the clean-tree paradox where the executor starts from an untracked plan file and then has to decide whether that dirty file is evidence or prompt input.

- [ ] **B0.1 Commit this plan by itself**

Command:

```bash
git status --short --branch
git diff --check
git add docs/superpowers/plans/2026-06-25-rebuild-c6-scoring-foundation.md
git commit -m "docs(rebuild-c6): add scoring foundation execution plan"
git status --short --branch
```

Expected:

- Only `/Users/wanglei/workspace/MAformac/docs/superpowers/plans/2026-06-25-rebuild-c6-scoring-foundation.md` is staged in this bootstrap commit.
- Any other dirty file is explicitly listed, owned, and excluded from the plan-freeze commit.
- L0 starts from a committed plan hash.

Pass/Fail:

- Pass if the plan commit succeeds and `git status --short --branch` shows no unrelated dirty files.
- Fail if unrelated dirty files would be staged, or if the plan has not passed `git diff --check`.

Failure Action:

- Do not start Swift edits.
- Resolve the dirty-tree ownership first, then rerun B0.

---

## L0: Live Baseline And Harness Preflight

**Purpose:** Establish current repo truth before code. If L0 fails, do not start Phase 1A.

**Files read only:** project root, OpenSpec change, Makefile, current tests.

- [ ] **L0.1 Reconfirm git and OpenSpec baseline**

Command:

```bash
git fetch origin --prune
git status --short --branch
git rev-parse --short HEAD
git log --oneline -5 --decorate
openspec validate rebuild-c6-four-layer-bench --strict
openspec validate --all --strict
```

Expected:

- Branch is a rebuild-C6 working branch, not the UIUE worktree.
- Working tree is clean before Phase 1A, or all dirty files are explicitly owned by this run.
- OpenSpec validation passes.

Pass/Fail:

- Pass if both OpenSpec commands exit `0`.
- Fail if validation fails; fix only docs/spec drift if it is in scope. Otherwise stop.

Failure Action:

- Record stdout in `Reports/rebuild-c6-scoring-foundation-<timestamp>/VERIFY.md`.
- Do not start Swift edits until L0 is green.

- [ ] **L0.2 Create scratch evidence directory and confirm ignored-report hazard**

Command:

```bash
RUN_DIR="Reports/rebuild-c6-scoring-foundation-$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$RUN_DIR"
: > "$RUN_DIR/VERIFY.md"
BASE_SHA="$(git rev-parse HEAD)"
printf '%s\n' "$BASE_SHA" > "$RUN_DIR/BASE_SHA"
printf 'BASE_SHA=%s\n' "$BASE_SHA" >> "$RUN_DIR/VERIFY.md"
git check-ignore -v "$RUN_DIR/VERIFY.md" || true
printf '%s\n' "$RUN_DIR"
```

Expected:

- `git check-ignore` shows `Reports/` or an equivalent ignore rule.
- The executor records the printed `RUN_DIR`.
- `BASE_SHA` is recorded in `$RUN_DIR/BASE_SHA` and `VERIFY.md`; final diff and UIUE impact checks must use this value instead of a fixed `HEAD~N` window.

Pass/Fail:

- Pass if `VERIFY.md` exists.
- If `Reports/` is not ignored, still use `RUN_DIR`, but closeout must record that the assumption changed.

Failure Action:

- If the directory cannot be created, stop. A run without evidence capture is not allowed.

- [ ] **L0.3 Confirm existing surface scripts and generated catalog**

Command:

```bash
test -f scripts/surface_consistency.py
test -f scripts/verify_gold.py
test -f generated/D_domain.tools.demo.json
make verify-surface || SURFACE_STATUS=$?
printf 'SURFACE_STATUS=%s\n' "${SURFACE_STATUS:-0}"
```

Expected:

- All three files exist.
- `make verify-surface` normally exits `0`; if it fails before any code edits, record it as baseline drift because this long-run does not modify JSONL/generated shape.

Pass/Fail:

- Pass if the files exist and `SURFACE_STATUS=0`.
- Warning-pass if the files exist but `SURFACE_STATUS` is nonzero and the failure is unrelated to touched scoring/apply files; record it in `VERIFY.md` and continue only with human or controller acknowledgement.
- Fail if scripts or generated catalog are missing. Do not recreate them in this long-run; stop and report baseline drift.

Failure Action:

- Record the failure in `VERIFY.md`.
- Do not start Phase 1A if files are missing. If only `make verify-surface` fails, decide whether the failure is unrelated baseline drift before proceeding.

- [ ] **L0.4 Capture current helper/API signatures**

Command:

```bash
sed -n '840,910p' Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift
rg -n "func summarize|func evaluate|struct C6Summary|struct C6GateResult|static func fixture|func stateCellsYAML|func goldValidation" Core/Bench/C6VehicleToolBench.swift Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift Tests/MAformacCoreTests/ToolContractCompilerTests.swift
```

Expected:

- The current `C6BenchCase.fixture`, `evaluate`, `summarize`, `C6Summary`, `C6GateResult`, `stateCellsYAML`, and `goldValidation` shapes are copied into `VERIFY.md`.
- Later snippets are adapted to these signatures instead of forcing production APIs to match the plan text.

Pass/Fail:

- Pass if the helper/API anchors are captured.
- Fail if the files are missing or the anchors cannot be found.

Failure Action:

- Stop and refresh the plan against current repo truth. Do not infer helper shape from memory.

- [ ] **L0.5 Record the implementation scope in `VERIFY.md`**

Append this exact scope block to `VERIFY.md`:

```markdown
## Scope

route: post-A2 / post-PR4 default_scope / post-R-L17 route-only rebuild-C6 construction apply
allowed_proof_classes:
- local_static_contract
- local_unit
- local_receipt_consistency

optional_baseline_guard:
- local_shape_no_model_baseline_unchanged

forbidden:
- retrain-C5
- C6 acceptance
- D-domain base recalibration
- rebuild-C6 §4 candidate comparison
- model-quality evaluation
- training
- golden-run
- voice
- endpoint readiness
- UIUE merge claim
- R-L17 candidate signoff
```

---

## Phase 1A: Shared Behavior Taxonomy

**Purpose:** Create the shared internal behavior taxonomy before any selector mechanics. This prevents C5 receipts, C6 denominators, and apply no-effect reasoning from inventing separate enums.

**Writable files:**

- `/Users/wanglei/workspace/MAformac/Core/Contracts/VehicleToolBehaviorClass.swift`
- `/Users/wanglei/workspace/MAformac/Core/Bench/C6VehicleToolBench.swift`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift`

### Red Tests

- [ ] **1A.1 Add behavior-class codec and non-inference tests first**

Add tests to `C6VehicleToolBenchTests.swift` before implementation:

```swift
func testDatasetCodecDecodesExplicitBehaviorClass() throws {
    let jsonl = """
    {"case_id":"C6-BC-001","behavior_class":"already_state_noop","source_refs":{"semantic_contract_ids":["c1_fixture"],"state_cell_ids":["ac.power"],"scenario_ids":["scene1"],"risk_rule_ids":[]},"tags":{"bucket":"no_call","must_pass":true,"must_not_train":true,"contract_device":"fixture","scenario_id":"scene1","sample_kind":"fixture"},"pre_state":{"ac.power":"on"},"input_zh":"打开空调","expected_tool_calls":[],"expect_no_call":true,"expected_state_delta":{"ac.power":"on"},"readback_assertion":{"contains":[]},"clarify_tag":"implicit","failure_class":"none"}
    """

    let item = try XCTUnwrap(try C6DatasetCodec().decodeJSONL(jsonl).first)

    XCTAssertEqual(item.behaviorClass, .alreadyStateNoop)
}

func testNoCallBucketDoesNotImplyAlreadyStateNoop() throws {
    let item = C6BenchCase.fixture(
        bucket: .noCall,
        expectedToolCalls: [],
        expectNoCall: true,
        expectedStateDelta: [:],
        readbackContains: [],
        clarifyTag: .rejected
    )

    XCTAssertNil(C6CaseBehaviorClassResolver.resolve(item))
}

func testCoverageBucketDoesNotMapToBehaviorClass() throws {
    let item = C6BenchCase.fixture(
        bucket: .coverage,
        expectedToolCalls: [],
        expectNoCall: true,
        expectedStateDelta: [:],
        readbackContains: [],
        clarifyTag: .ambiguous
    )

    XCTAssertNil(C6CaseBehaviorClassResolver.resolve(item))
}

func testSafetyRefusalResolvesOnlyFromRiskRuleEvidence() throws {
    let item = C6BenchCase.fixture(
        bucket: .refusal,
        expectedToolCalls: [],
        expectNoCall: true,
        expectedStateDelta: ["vehicle.speed": "30"],
        readbackContains: ["行驶中"],
        clarifyTag: .rejected,
        preState: ["vehicle.speed": "30", "vehicle.gear": "D"],
        sourceRefs: C6SourceRefs(riskRuleIDs: ["door_open_while_moving"])
    )

    XCTAssertEqual(C6CaseBehaviorClassResolver.resolve(item), .refusalSafetyOrPolicy)
}
```

Extend the local `C6BenchCase.fixture` test helper before running these red tests. Replace the helper signature with this shape, preserving existing defaults:

```swift
static func fixture(
    bucket: C6Bucket = .action,
    expectedToolCalls: [C6ToolCall],
    expectNoCall: Bool = false,
    expectedStateDelta: [String: String],
    readbackContains: [String],
    clarifyTag: C6ClarifyTag = .implicit,
    preState: [String: String] = [
        "ac.power": "off",
        "screen.brightness[中控屏]": "70"
    ],
    alternatives: [C6GoldAlternative] = [],
sourceRefs: C6SourceRefs = C6SourceRefs(
    semanticContractIDs: ["c1_fixture"],
    stateCellIDs: ["ac.power"],
    scenarioIDs: ["scene1"]
),
behaviorClass: VehicleToolBehaviorClass? = nil
) -> C6BenchCase
```

Inside the helper, pass those values into `C6BenchCase(...)`:

```swift
sourceRefs: sourceRefs,
...
behaviorClass: behaviorClass
```

This helper extension is test-only. It must not add production defaults that infer `already_state_noop` from `.noCall`.

Command:

```bash
swift test --filter C6VehicleToolBenchTests/testDatasetCodecDecodesExplicitBehaviorClass
swift test --filter C6VehicleToolBenchTests/testNoCallBucketDoesNotImplyAlreadyStateNoop
swift test --filter C6VehicleToolBenchTests/testCoverageBucketDoesNotMapToBehaviorClass
swift test --filter C6VehicleToolBenchTests/testSafetyRefusalResolvesOnlyFromRiskRuleEvidence
```

Expected:

- These tests fail before implementation.

Failure Action:

- If a test passes before implementation, inspect for a pre-existing equivalent and record the current source of truth in `VERIFY.md`.

### Implementation

- [ ] **1A.2 Add shared enum outside C6-private namespace**

Create `/Users/wanglei/workspace/MAformac/Core/Contracts/VehicleToolBehaviorClass.swift`:

```swift
import Foundation

public enum VehicleToolBehaviorClass: String, Codable, CaseIterable, Equatable, Sendable {
    case toolCall = "tool_call"
    case clarifyMissingSlot = "clarify_missing_slot"
    case refusalNoAvailableTool = "refusal_no_available_tool"
    case refusalSafetyOrPolicy = "refusal_safety_or_policy"
    case alreadyStateNoop = "already_state_noop"
}
```

- [ ] **1A.3 Add optional `behavior_class` to `C6BenchCase`**

Modify `C6BenchCase`:

```swift
public var behaviorClass: VehicleToolBehaviorClass?
```

Add coding key:

```swift
case behaviorClass = "behavior_class"
```

Decode with compatibility:

```swift
self.behaviorClass = try container.decodeIfPresent(VehicleToolBehaviorClass.self, forKey: .behaviorClass)
```

Encode only when present:

```swift
try container.encodeIfPresent(behaviorClass, forKey: .behaviorClass)
```

Extend the public initializer with:

```swift
behaviorClass: VehicleToolBehaviorClass? = nil
```

- [ ] **1A.4 Add C6-case adapter with fail-closed non-inference**

Add near the C6 dataset types. The exact placement is implementation choice; the invariant is that this adapter maps C6 legacy case fields into the shared `VehicleToolBehaviorClass` without becoming a separate taxonomy owner:

```swift
public enum C6CaseBehaviorClassResolver {
    public static func resolve(_ item: C6BenchCase) -> VehicleToolBehaviorClass? {
        if let behaviorClass = item.behaviorClass {
            return behaviorClass
        }
        if !item.expectedToolCalls.isEmpty && !item.expectNoCall {
            return .toolCall
        }
        if item.clarifyTag == .ambiguous && item.expectedToolCalls.isEmpty {
            return .clarifyMissingSlot
        }
        if item.expectNoCall && !item.sourceRefs.riskRuleIDs.isEmpty {
            return .refusalSafetyOrPolicy
        }
        return nil
    }
}
```

This intentionally does not infer `already_state_noop` from `C6Bucket.noCall`, and does not infer unsupported refusal from the current broad `.refusal` bucket. The `C6Case...` prefix is allowed only because this is a C6 case adapter; the SSOT enum remains `VehicleToolBehaviorClass`.

### Phase Gate

- [ ] **1A.5 Run Phase 1A verification**

Command:

```bash
swift test --filter C6VehicleToolBenchTests/testDatasetCodecDecodesExplicitBehaviorClass
swift test --filter C6VehicleToolBenchTests/testNoCallBucketDoesNotImplyAlreadyStateNoop
swift test --filter C6VehicleToolBenchTests/testCoverageBucketDoesNotMapToBehaviorClass
swift test --filter C6VehicleToolBenchTests/testSafetyRefusalResolvesOnlyFromRiskRuleEvidence
rg -n "enum C6BehaviorClass|typealias C6BehaviorClass|struct C6BehaviorClass\\b|direct_no_call|StateWriteKind\\.noop" Core Tests && exit 65 || true
```

Expected:

- All four tests pass.
- `rg` finds no forbidden private taxonomy or rejected class.

Pass/Fail:

- Pass if every command exits `0` and the Phase 1A subagent audit returns `PASS`, or `PASS_WITH_FIXES` with only P2 items already resolved in the same phase.
- Fail if any command exits nonzero, or if the audit returns any unresolved P0/P1.

Failure Action:

- Append command stdout, exit codes, and the subagent verdict to `VERIFY.md`.
- Fix within route boundaries, record any scope expansion in `VERIFY.md`, rerun the full Phase 1A gate, and do not commit or proceed to Phase 1B until the rerun passes.

Subagent Audit:

- Run a read-only Codex audit with the prompt in "Subagent Audit Template" and scope set to Phase 1A.

Commit:

```bash
git status --short
git add Core/Contracts/VehicleToolBehaviorClass.swift Core/Bench/C6VehicleToolBench.swift Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift
git commit -m "test(c6): add shared behavior taxonomy"
```

---

## Phase 1B: Two-Axis Reporting DTOs

**Purpose:** Split C6 reporting into external layer and internal behavior class. This prevents the old `IrrelAcc`/negative aggregate from hiding unsupported, safety, clarify, already-state, and tool-call behavior under one no-call denominator.

**Writable files:**

- `/Users/wanglei/workspace/MAformac/Core/Bench/C6VehicleToolBench.swift`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift`

### Red Tests

- [ ] **1B.1 Add report-shape tests**

Add:

```swift
func testSummaryReportsExternalLayerAndBehaviorClassSeparately() throws {
    let runner = try makeRunner()
    let safety = C6BenchCase.fixture(
        bucket: .refusal,
        expectedToolCalls: [],
        expectNoCall: true,
        expectedStateDelta: ["vehicle.speed": "30"],
        readbackContains: ["行驶中"],
        clarifyTag: .rejected,
        preState: ["vehicle.speed": "30", "vehicle.gear": "D"],
        sourceRefs: C6SourceRefs(riskRuleIDs: ["door_open_while_moving"]),
        behaviorClass: .refusalSafetyOrPolicy
    )
    let already = C6BenchCase.fixture(
        bucket: .noCall,
        expectedToolCalls: [],
        expectNoCall: true,
        expectedStateDelta: ["ac.power": "on"],
        readbackContains: [],
        clarifyTag: .implicit,
        preState: ["ac.power": "on"],
        behaviorClass: .alreadyStateNoop
    )

    let runs = try [
        runner.evaluate(case: safety, output: C6RuntimeOutput(toolCalls: [], text: "行驶中不能开门"), runIndex: 0),
        runner.evaluate(case: already, output: C6RuntimeOutput(toolCalls: [], text: ""), runIndex: 1)
    ]
    let summary = runner.summarize(cases: [safety, already], runs: runs, validation: goldValidation(caseCount: 2))

    XCTAssertEqual(summary.behaviorClassStats.first { $0.behaviorClass == .refusalSafetyOrPolicy }?.caseCount, 1)
    XCTAssertEqual(summary.behaviorClassStats.first { $0.behaviorClass == .alreadyStateNoop }?.caseCount, 1)
    XCTAssertEqual(summary.externalLayerStats.first { $0.layer == .safety }?.caseCount, 1)
}
```

Command:

```bash
swift test --filter C6VehicleToolBenchTests/testSummaryReportsExternalLayerAndBehaviorClassSeparately
```

Expected:

- Fails before DTO implementation.

### Implementation

- [ ] **1B.2 Add reporting DTOs**

Add:

```swift
public enum C6ExternalLayer: String, Codable, CaseIterable, Equatable, Sendable {
    case golden
    case demoFuzz = "demo_fuzz"
    case unsupported
    case safety
}

public struct VehicleToolBehaviorClassStats: Codable, Equatable, Sendable {
    public var behaviorClass: VehicleToolBehaviorClass
    public var caseCount: Int
    public var runCount: Int
    public var hardFailureCount: Int

    enum CodingKeys: String, CodingKey {
        case behaviorClass = "behavior_class"
        case caseCount = "case_count"
        case runCount = "run_count"
        case hardFailureCount = "hard_failure_count"
    }
}

public struct C6ExternalLayerStats: Codable, Equatable, Sendable {
    public var layer: C6ExternalLayer
    public var caseCount: Int
    public var runCount: Int
    public var hardFailureCount: Int

    enum CodingKeys: String, CodingKey {
        case layer
        case caseCount = "case_count"
        case runCount = "run_count"
        case hardFailureCount = "hard_failure_count"
    }
}
```

Add to `C6Summary`:

```swift
public var behaviorClassStats: [VehicleToolBehaviorClassStats]
public var externalLayerStats: [C6ExternalLayerStats]
```

with coding keys:

```swift
case behaviorClassStats = "behavior_class_stats"
case externalLayerStats = "external_layer_stats"
```

Update the memberwise initializer call at the end of `summarize` to pass both fields explicitly. Do not rely on default empty arrays; missing stats would recreate the old aggregate-only fake green.

- [ ] **1B.3 Populate stats without thresholds**

Add helper:

```swift
public enum C6ExternalLayerSelector {
    public static func layer(for item: C6BenchCase) -> C6ExternalLayer {
        if !item.sourceRefs.riskRuleIDs.isEmpty || item.behaviorClass == .refusalSafetyOrPolicy {
            return .safety
        }
        if item.behaviorClass == .refusalNoAvailableTool {
            return .unsupported
        }
        if item.tags.bucket == .coverage || item.tags.sampleKind.contains("coverage") || item.tags.sampleKind.contains("fuzz") {
            return .demoFuzz
        }
        return .golden
    }
}
```

In `summarize`, compute counts from cases and runs by case ID. Do not add pass thresholds, active base anchors, McNemar, or pass^k.

### Phase Gate

- [ ] **1B.4 Run Phase 1B verification**

Command:

```bash
swift test --filter C6VehicleToolBenchTests/testSummaryReportsExternalLayerAndBehaviorClassSeparately
swift test --filter C6VehicleToolBenchTests/testSummaryKeepsCoverageAndScenarioAxesSeparateAndSupportsBaseLoRADiffIndex
swift test --filter C6VehicleToolBenchTests/testSummaryRecordsArtifactDigestsAtTopLevelAndEachEvalRun
```

Expected:

- New stats test passes.
- Existing summary tests still pass.

Pass/Fail:

- Pass if every command exits `0` and the Phase 1B subagent audit returns `PASS`, or `PASS_WITH_FIXES` with only P2 items already resolved in the same phase.
- Fail if any command exits nonzero, stats are empty/default-only, or the audit reports active thresholds/base anchors/model-eval leakage.

Failure Action:

- Append command stdout, exit codes, and the subagent verdict to `VERIFY.md`.
- Fix within route boundaries, record any scope expansion in `VERIFY.md`, rerun the Phase 1B gate, and do not commit or proceed to Phase 1C until the rerun passes.

Subagent Audit:

- Read-only audit Phase 1B for "two-axis stats are additive reporting only; no active threshold or base run was added".

Commit:

```bash
git status --short
git add Core/Bench/C6VehicleToolBench.swift Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift
git commit -m "feat(c6): add two-axis scoring reports"
```

---

## Phase 1C: Selector And Denominator Shell

**Purpose:** Freeze classification logic while keeping thresholds and active base anchors deferred. This is the Q2.3/Q5.4 boundary: selector shell is allowed; acceptance/recalibration is not.

**Writable files:**

- `/Users/wanglei/workspace/MAformac/Core/Bench/C6VehicleToolBench.swift`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift`

### Red Tests

- [ ] **1C.1 Add selector-shell tests**

Add:

```swift
func testLayerSelectorDoesNotUseMustPassAsGoldenDenominator() throws {
    let coverage = C6BenchCase.fixture(
        bucket: .coverage,
        expectedToolCalls: [],
        expectNoCall: true,
        expectedStateDelta: [:],
        readbackContains: [],
        clarifyTag: .ambiguous,
        behaviorClass: .clarifyMissingSlot
    )

    XCTAssertEqual(C6ExternalLayerSelector.layer(for: coverage), .demoFuzz)
}

func testSafetyAndUnsupportedAreSeparateLayers() throws {
    let safety = C6BenchCase.fixture(
        bucket: .refusal,
        expectedToolCalls: [],
        expectNoCall: true,
        expectedStateDelta: [:],
        readbackContains: ["行驶中"],
        clarifyTag: .rejected,
        sourceRefs: C6SourceRefs(riskRuleIDs: ["door_open_while_moving"]),
        behaviorClass: .refusalSafetyOrPolicy
    )
    let unsupported = C6BenchCase.fixture(
        bucket: .refusal,
        expectedToolCalls: [],
        expectNoCall: true,
        expectedStateDelta: [:],
        readbackContains: [],
        clarifyTag: .rejected,
        behaviorClass: .refusalNoAvailableTool
    )

    XCTAssertEqual(C6ExternalLayerSelector.layer(for: safety), .safety)
    XCTAssertEqual(C6ExternalLayerSelector.layer(for: unsupported), .unsupported)
}
```

Command:

```bash
swift test --filter C6VehicleToolBenchTests/testLayerSelectorDoesNotUseMustPassAsGoldenDenominator
swift test --filter C6VehicleToolBenchTests/testSafetyAndUnsupportedAreSeparateLayers
```

Expected:

- Fails until selector behavior exists.

### Implementation

- [ ] **1C.2 Add explicit denominator report**

Add:

```swift
public struct C6DenominatorReport: Codable, Equatable, Sendable {
    public var unresolvedBehaviorClassCaseIDs: [String]
    public var layerCaseIDs: [String: [String]]

    enum CodingKeys: String, CodingKey {
        case unresolvedBehaviorClassCaseIDs = "unresolved_behavior_class_case_ids"
        case layerCaseIDs = "layer_case_ids"
    }
}
```

Add to `C6Summary`:

```swift
public var denominatorReport: C6DenominatorReport
```

Add coding key:

```swift
case denominatorReport = "denominator_report"
```

Update the `C6Summary` return call to pass the computed report explicitly.

Populate:

```swift
let unresolvedBehaviorClassCaseIDs = cases
    .filter { C6CaseBehaviorClassResolver.resolve($0) == nil && $0.tags.bucket != .coverage }
    .map(\.caseID)
    .sorted()
let layerCaseIDs = Dictionary(grouping: cases, by: { C6ExternalLayerSelector.layer(for: $0).rawValue })
    .mapValues { $0.map(\.caseID).sorted() }
```

Do not fail the run solely because unresolved current legacy rows exist; record them. Active blocking belongs to the later D-domain shape migration.

- [ ] **1C.3 Mark legacy aggregate compatibility**

Keep existing `IrrelAcc` fields for backward compatibility in this pass, but add comments and tests making clear they are legacy summary fields and not a four-layer acceptance gate:

```swift
// Legacy compatibility field. Rebuild-C6 construction reports per-layer stats in
// `externalLayerStats`; active thresholds and base anchors remain deferred.
public var IrrelAcc: Double
```

Do not add new active thresholds.

### Phase Gate

- [ ] **1C.4 Run Phase 1C verification**

Command:

```bash
swift test --filter C6VehicleToolBenchTests/testLayerSelectorDoesNotUseMustPassAsGoldenDenominator
swift test --filter C6VehicleToolBenchTests/testSafetyAndUnsupportedAreSeparateLayers
swift test --filter C6VehicleToolBenchTests/testSummaryReportsExternalLayerAndBehaviorClassSeparately
rg -n "McNemar|pass\\^k|base recalibration|golden-run|acceptance" Core/Bench/C6VehicleToolBench.swift Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift && exit 65 || true
```

Expected:

- Selector tests pass.
- Forbidden future-comparison vocabulary is absent from touched Swift/tests.

Pass/Fail:

- Pass if every command exits `0` and the Phase 1C subagent audit returns `PASS`, or `PASS_WITH_FIXES` with only P2 items already resolved in the same phase.
- Fail if any command exits nonzero, any threshold/base/candidate-comparison logic appears, or unresolved behavior classes become an active pass/fail threshold.

Failure Action:

- Append command stdout, exit codes, and the subagent verdict to `VERIFY.md`.
- Fix within route boundaries, record any scope expansion in `VERIFY.md`, rerun the Phase 1C gate, and do not commit or proceed to Phase 2 until the rerun passes.

Subagent Audit:

- Read-only audit Phase 1C for "selector shell only, no acceptance threshold, no base run, no model eval".

Commit:

```bash
git status --short
git add Core/Bench/C6VehicleToolBench.swift Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift
git commit -m "feat(c6): add denominator selector shell"
```

---

## Phase 2: Apply Write Facts

**Purpose:** Upgrade apply/execution evidence from `scopeOriginEvidence` only to source-derived `appliedWrites`. This fixes the current evidence black holes: dependency writes and enum writes mutate state but do not produce write facts.

**Writable files:**

- `/Users/wanglei/workspace/MAformac/Core/Contracts/StateWrite.swift`
- `/Users/wanglei/workspace/MAformac/Core/Contracts/ToolContractCompiler.swift`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/ToolContractCompilerTests.swift`

### Red Tests

- [ ] **2.1 Add apply evidence tests**

Add:

```swift
func testStateApplierEvidenceIncludesDirectAndDependencyWrites() throws {
    let stateCells = try StateCellContractLookup(yaml: stateCellsYAML())
    let result = try ToolContractStateApplier.applyWithEvidence(
        toolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["target_temperature": "24"])],
        to: ["ac.power": "off", "ac.temp_setpoint[主驾]": "22"],
        stateCells: stateCells
    )

    XCTAssertTrue(result.appliedWrites.contains {
        $0.stateKey == "ac.temp_setpoint[主驾]" &&
        $0.beforeValue == "22" &&
        $0.afterValue == "24" &&
        $0.writeKind == .direct
    })
    XCTAssertTrue(result.appliedWrites.contains {
        $0.stateKey == "ac.power" &&
        $0.beforeValue == "off" &&
        $0.afterValue == "on" &&
        $0.writeKind == .dependency
    })
}

func testStateApplierEvidenceIncludesEnumDirectWrites() throws {
    let stateCells = try StateCellContractLookup(yaml: stateCellsYAML())
    let result = try ToolContractStateApplier.applyWithEvidence(
        toolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])],
        to: ["ac.power": "off"],
        stateCells: stateCells
    )

    XCTAssertEqual(result.appliedWrites, [
        StateWrite(stateKey: "ac.power", beforeValue: "off", afterValue: "on", scopeOrigin: nil, writeKind: .direct)
    ])
}
```

Command:

```bash
swift test --filter ToolContractCompilerTests/testStateApplierEvidenceIncludesDirectAndDependencyWrites
swift test --filter ToolContractCompilerTests/testStateApplierEvidenceIncludesEnumDirectWrites
```

Expected:

- Fails before implementation because `appliedWrites` does not exist and enum/dependency evidence is missing.

### Implementation

- [ ] **2.2 Add minimal write fact types**

Create `/Users/wanglei/workspace/MAformac/Core/Contracts/StateWrite.swift`:

```swift
import Foundation

public enum StateWriteKind: String, Codable, Equatable, Sendable {
    case direct
    case dependency
}

public struct StateWrite: Codable, Equatable, Sendable {
    public var stateKey: String
    public var beforeValue: String?
    public var afterValue: String
    public var scopeOrigin: ScopeOrigin?
    public var writeKind: StateWriteKind

    public init(
        stateKey: String,
        beforeValue: String?,
        afterValue: String,
        scopeOrigin: ScopeOrigin? = nil,
        writeKind: StateWriteKind
    ) {
        self.stateKey = stateKey
        self.beforeValue = beforeValue
        self.afterValue = afterValue
        self.scopeOrigin = scopeOrigin
        self.writeKind = writeKind
    }
}
```

There is no `noop`, no semantic reason, no error list, and no expected-set field.

- [ ] **2.3 Extend apply result**

Modify `ToolContractStateApplyResult`:

```swift
public var appliedWrites: [StateWrite]

public init(
    state: [String: String],
    scopeOriginEvidence: [String: String] = [:],
    appliedWrites: [StateWrite] = []
) {
    self.state = state
    self.scopeOriginEvidence = scopeOriginEvidence
    self.appliedWrites = appliedWrites
}
```

- [ ] **2.4 Replace private evidence carrier**

Replace `ToolContractStateWriteEvidence` with `StateWrite` usage. `applyWithEvidence` should collect:

```swift
var appliedWrites: [StateWrite] = []
...
let writes = try apply(ir, state: &state, stateCells: stateCells)
appliedWrites.append(contentsOf: writes)
for write in writes {
    if let scopeOrigin = write.scopeOrigin {
        scopeOriginEvidence[write.stateKey] = scopeOrigin.rawValue
    }
}
...
return ToolContractStateApplyResult(
    state: state,
    scopeOriginEvidence: scopeOriginEvidence,
    appliedWrites: appliedWrites
)
```

- [ ] **2.5 Make enum writes produce direct evidence**

Change `applyEnumCell` to return `[StateWrite]` and record before/after:

```swift
private static func applyEnumCell(...) throws -> [StateWrite] {
    let before = state[cellID]
    let after: String
    if isOff(ir.actionPrimitive, value: ir.value) {
        after = "off"
    } else if isOn(ir.actionPrimitive, value: ir.value) {
        after = "on"
    } else if let raw = firstNonEmpty(ir.value.direct, ir.value.offset, ir.slots["color"]) {
        after = c2ColorValue(for: raw, stateCells: stateCells)
    } else {
        throw ToolContractStateApplyError.unsupportedStateMutation(...)
    }
    state[cellID] = after
    return [StateWrite(stateKey: cellID, beforeValue: before, afterValue: after, writeKind: .direct)]
}
```

- [ ] **2.6 Make dependency writes produce dependency evidence**

In `applyNumericCell`, record direct and dependency writes:

```swift
var writes: [StateWrite] = []
for key in writeKeys {
    let before = state[key]
    state[key] = value
    writes.append(StateWrite(stateKey: key, beforeValue: before, afterValue: value, scopeOrigin: resolution.origin, writeKind: .direct))
}
for dependency in cell.dependsOn {
    let before = state[dependency]
    state[dependency] = "on"
    writes.append(StateWrite(stateKey: dependency, beforeValue: before, afterValue: "on", scopeOrigin: nil, writeKind: .dependency))
}
return writes
```

Do not skip `before == after`; descriptive evidence still matters for already-state/no-effect reasoning. C6 decides semantics later.

### Phase Gate

- [ ] **2.7 Run Phase 2 verification**

Command:

```bash
swift test --filter ToolContractCompilerTests/testStateApplierEvidenceIncludesDirectAndDependencyWrites
swift test --filter ToolContractCompilerTests/testStateApplierEvidenceIncludesEnumDirectWrites
swift test --filter ToolContractCompilerTests/testStateApplierDataDrivenEndToEndDDomainTool
swift test --filter ToolContractCompilerTests/testStateApplierUsesC2DefaultScopeForOmittedWindow
rg -n "StateWriteKind\\.noop|noEffectKeys|expectedState|expectedKeys" Core/Contracts/ToolContractCompiler.swift Core/Contracts/StateWrite.swift && exit 65 || true
```

Expected:

- New and existing applier tests pass.
- Forbidden planner/noop/expected-set leakage is absent from apply code.

Pass/Fail:

- Pass if every command exits `0` and the Phase 2 subagent audit returns `PASS`, or `PASS_WITH_FIXES` with only P2 items already resolved in the same phase.
- Fail if any command exits nonzero, enum/dependency writes lack `appliedWrites`, apply stops throwing fail-closed, or expected C6 sets leak into apply.

Failure Action:

- Append command stdout, exit codes, and the subagent verdict to `VERIFY.md`.
- Fix within route boundaries, record any scope expansion in `VERIFY.md`, rerun the Phase 2 gate, and do not commit or proceed to Phase 3 until the rerun passes.

Subagent Audit:

- Read-only audit Phase 2 for "apply producer facts are descriptive, fail-closed, no planner, enum/dependency evidence covered".

Commit:

```bash
git status --short
git add Core/Contracts/StateWrite.swift Core/Contracts/ToolContractCompiler.swift Tests/MAformacCoreTests/ToolContractCompilerTests.swift
git commit -m "feat(apply): emit descriptive state write evidence"
```

---

## Phase 3: C6 Replay Consumption And Readback Split

**Purpose:** Make C6 consume apply write facts to distinguish correct state deltas, dependency side effects, unexpected mutations, already-state no-op facts, and readback-only failures. C6 still must not own a private apply engine.

**Writable files:**

- `/Users/wanglei/workspace/MAformac/Core/Bench/C6VehicleToolBench.swift`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-scoring-foundation-closeout-2026-06-25.md`

### Red Tests

- [ ] **3.1 Add applied-write provenance tests**

Add:

```swift
func testC6StateDeltaUsesAppliedWriteProvenanceForDependencyWrites() throws {
    let runner = try makeRunner()
    let caseItem = C6BenchCase.fixture(
        expectedToolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["target_temperature": "24"])],
        expectedStateDelta: ["ac.temp_setpoint[主驾]": "24"],
        readbackContains: ["24"],
        preState: ["ac.power": "off", "ac.temp_setpoint[主驾]": "22"],
        behaviorClass: .toolCall
    )

    let result = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [
        C6ToolCall(name: "set_cabin_ac", arguments: ["target_temperature": "24"])
    ], text: "主驾空调已设为24度"))

    XCTAssertTrue(result.gateResult.stateDeltaMatch)
    XCTAssertTrue(result.gateResult.appliedWrites.contains { $0.stateKey == "ac.power" && $0.writeKind == .dependency })
    XCTAssertTrue(result.gateResult.dependencyWriteKeys.contains("ac.power"))
    XCTAssertTrue(result.gateResult.unexpectedMutationKeys.isEmpty)
}

func testC6UnexpectedMutationFailsWhenWriteIsNeitherExpectedNorDependency() throws {
    let runner = try makeRunner()
    let caseItem = C6BenchCase.fixture(
        expectedToolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])],
        expectedStateDelta: [:],
        readbackContains: ["空调"],
        preState: ["ac.power": "off"],
        behaviorClass: .toolCall
    )

    let result = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [
        C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])
    ], text: "空调已打开"))

    XCTAssertFalse(result.gateResult.stateDeltaMatch)
    XCTAssertTrue(result.gateResult.failureClasses.contains(.stateDelta))
    XCTAssertEqual(result.gateResult.unexpectedMutationKeys, ["ac.power"])
}

func testC6RejectsDependencyWriteNotDeclaredByExpectedStateCell() throws {
    let writes = [
        StateWrite(stateKey: "ambient.color", beforeValue: "白", afterValue: "红", writeKind: .dependency)
    ]

    let unexpected = C6AppliedWriteComparator.unexpectedMutationKeys(
        expected: ["ac.temp_setpoint[主驾]": "24"],
        writes: writes,
        stateCells: try makeStateCells()
    )

    XCTAssertEqual(unexpected, ["ambient.color"])
}
```

- [ ] **3.2 Add readback hard-pass split test**

Add:

```swift
func testReadbackMismatchDoesNotSetModelHardFailed() throws {
    let runner = try makeRunner()
    let caseItem = C6BenchCase.fixture(
        expectedToolCalls: [C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])],
        expectedStateDelta: ["ac.power": "on"],
        readbackContains: ["空调"],
        behaviorClass: .toolCall
    )

    let result = try runner.evaluate(case: caseItem, output: C6RuntimeOutput(toolCalls: [
        C6ToolCall(name: "set_cabin_ac", arguments: ["power": "on"])
    ], text: "ac.power=on"))

    XCTAssertTrue(result.gateResult.stateDeltaMatch)
    XCTAssertFalse(result.gateResult.readbackMatch)
    XCTAssertFalse(result.gateResult.modelHardFailed)
    XCTAssertTrue(result.gateResult.readbackHardFailed)
    XCTAssertFalse(result.gateResult.failureClasses.contains(.readback))
}
```

Command:

```bash
swift test --filter C6VehicleToolBenchTests/testC6StateDeltaUsesAppliedWriteProvenanceForDependencyWrites
swift test --filter C6VehicleToolBenchTests/testC6UnexpectedMutationFailsWhenWriteIsNeitherExpectedNorDependency
swift test --filter C6VehicleToolBenchTests/testReadbackMismatchDoesNotSetModelHardFailed
```

Expected:

- Fails before implementation because `C6GateResult` does not expose write facts or readback split.

### Implementation

- [ ] **3.3 Extend `C6GateResult` with consumed facts and split hard-pass fields**

Add fields:

```swift
public var modelHardFailed: Bool
public var readbackHardFailed: Bool
public var appliedWrites: [StateWrite]
public var dependencyWriteKeys: [String]
public var unexpectedMutationKeys: [String]
```

Add coding keys:

```swift
case modelHardFailed = "model_hard_failed"
case readbackHardFailed = "readback_hard_failed"
case appliedWrites = "applied_writes"
case dependencyWriteKeys = "dependency_write_keys"
case unexpectedMutationKeys = "unexpected_mutation_keys"
```

Keep existing `hardFailed` for compatibility during this pass, but define it as:

```swift
hardFailed: modelHardFailed
```

Do not include `.readback` in `failureClasses` once readback is split. If preserving a legacy readback list is needed, add a separate `readbackFailureClasses` field instead of mixing it into model failures.

- [ ] **3.4 Replace final-state-only dependency allowance with applied-write provenance**

Add or adapt an equivalent helper. The invariant is stronger than the snippet: dependency writes are allowed only when both conditions hold:

1. the mutation appears in `applyResult.appliedWrites` with `writeKind == .dependency`;
2. the dependency key is declared in `StateCellDefinition.dependsOn` for one of the expected direct state cells.

Suggested shape:

```swift
enum C6AppliedWriteComparator {
    static func unexpectedMutationKeys(
        expected: [String: String],
        writes: [StateWrite],
        stateCells: StateCellContractLookup
    ) -> [String] {
        let expectedKeys = Set(expected.keys)
        let allowedDependencyKeys = allowedDependencyKeys(forExpectedKeys: expectedKeys, stateCells: stateCells)
        return writes
            .filter { write in
                if expectedKeys.contains(write.stateKey) {
                    return false
                }
                if write.writeKind == .dependency && allowedDependencyKeys.contains(write.stateKey) {
                    return false
                }
                return true
            }
            .map(\.stateKey)
            .sorted()
    }

    static func dependencyWriteKeys(_ writes: [StateWrite]) -> [String] {
        writes.filter { $0.writeKind == .dependency }.map(\.stateKey).sorted()
    }

    private static func allowedDependencyKeys(
        forExpectedKeys expectedKeys: Set<String>,
        stateCells: StateCellContractLookup
    ) -> Set<String> {
        var keys: Set<String> = []
        for key in expectedKeys {
            let baseID = splitStateKey(key).baseID
            guard let cell = stateCells.cell(id: baseID) else {
                continue
            }
            keys.formUnion(cell.dependsOn)
        }
        return keys
    }
}
```

If the executor chooses to keep the comparator private, replace the direct comparator red test with a runner-level fixture that produces an unrelated dependency write. Do not keep a direct test against a `fileprivate` helper.

Update state matching:

- Expected final values must match in `applyResult.state`.
- Unexpected mutation keys must be empty.
- Dependency writes are allowed only when they are present in `applyResult.appliedWrites` with `writeKind == .dependency` and also declared by `stateCells.cell(id: expectedBaseID)?.dependsOn`.
- Do not use `expectedKeysIncludingDependencies` as the primary allowance path after Phase 3.
- Do not add `sourceStateKey` to `StateWrite` in this long-run unless a new human-approved grill changes Q5.5. Recompute allowed dependency keys in C6 from expected direct state cells and `stateCells`, not by passing expected sets into apply.

- [ ] **3.5 Split readback from model hard pass**

In `evaluate`, build failures in two lists:

```swift
var modelFailures: [C6FailureClass] = []
let readbackHardFailed = readbackApplicable && !readbackMatch
```

Append `.parser`, `.toolCall`, `.noCall`, `.stateDelta`, `.clarify`, `.refusal` to `modelFailures`. Do not append `.readback` to `modelFailures`.

Return:

```swift
let modelHardFailed = !modelFailures.isEmpty
return C6GateResult(
    ...,
    hardFailed: modelHardFailed,
    failureClasses: modelFailures,
    modelHardFailed: modelHardFailed,
    readbackHardFailed: readbackHardFailed,
    appliedWrites: applyResult.appliedWrites,
    dependencyWriteKeys: C6AppliedWriteComparator.dependencyWriteKeys(applyResult.appliedWrites),
    unexpectedMutationKeys: unexpectedMutationKeys
)
```

If an existing test asserts `.readback` in `failureClasses`, update that test to assert `readbackHardFailed == true` and `modelHardFailed == false` when model/state/tool behavior is correct.

- [ ] **3.6 Keep no-call already-state facts separated**

For `expectNoCall`, do not call apply. Use `preconditionMatch` and `behaviorClass == .alreadyStateNoop` to report correct no-op. Do not turn all `toolCalls == []` into success. `already_state_noop` must come from explicit `behavior_class` or later shape migration, not from broad no-call inference.

### Phase Gate

- [ ] **3.7 Run Phase 3 focused tests**

Command:

```bash
swift test --filter C6VehicleToolBenchTests/testC6StateDeltaUsesAppliedWriteProvenanceForDependencyWrites
swift test --filter C6VehicleToolBenchTests/testC6UnexpectedMutationFailsWhenWriteIsNeitherExpectedNorDependency
swift test --filter C6VehicleToolBenchTests/testC6RejectsDependencyWriteNotDeclaredByExpectedStateCell
swift test --filter C6VehicleToolBenchTests/testReadbackMismatchDoesNotSetModelHardFailed
swift test --filter C6VehicleToolBenchTests/testReadbackGateRejectsMachineStringAndAcceptsC2RenderedChinese
swift test --filter C6VehicleToolBenchTests/testStateDeltaAndReadbackAreSeparateHardGates
rg -n "gateResult\\.failureClasses\\.contains\\(\\.readback\\)" Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift && exit 65 || true
```

Expected:

- New provenance tests pass.
- Existing readback tests are updated to the new split semantics.
- No model gate test still asserts `gateResult.failureClasses.contains(.readback)`.

Pass/Fail:

- Pass if every command exits `0`, dependency allowance is both provenance-based and `dependsOn`-based, and the Phase 3 subagent audit returns `PASS`, or `PASS_WITH_FIXES` with only P2 items already resolved in the same phase.
- Fail if any command exits nonzero, `.readback` remains in model `failureClasses`, C6 introduces a private apply engine, or dependency writes are allowed solely by `writeKind == .dependency`.

Failure Action:

- Append command stdout, exit codes, and the subagent verdict to `VERIFY.md`.
- Fix within route boundaries, record any scope expansion in `VERIFY.md`, rerun Phase 3 focused tests and phase-level suites, and do not commit final closeout until the rerun passes.

- [ ] **3.8 Run phase-level suite**

Command:

```bash
swift test --filter C6VehicleToolBenchTests
swift test --filter ToolContractCompilerTests
```

Expected:

- Both suites pass.

Pass/Fail:

- Pass if both suite commands exit `0`.
- Fail if either suite exits nonzero or if any fix requires touching no-touch paths.

Failure Action:

- Append stdout and exit codes to `VERIFY.md`.
- Fix within route boundaries, record any scope expansion in `VERIFY.md`, rerun Phase 3 focused tests and both suites, and do not proceed to L3 until green.

Subagent Audit:

- Read-only audit Phase 3 for "C6 consumes upstream facts, no C6 private apply engine, dependency side effects are provenance-based, readback excluded from model hard pass".

Commit:

```bash
git status --short
git add Core/Bench/C6VehicleToolBench.swift Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift
git commit -m "feat(c6): consume apply write evidence in scoring"
```

---

## L3 Final Smoke And Closeout

**Purpose:** Prove the long-run is locally coherent and leave a durable receipt. This is not C6 acceptance.

- [ ] **L3.1 Run final local gates**

Command:

```bash
swift test --filter C6VehicleToolBenchTests
swift test --filter ToolContractCompilerTests
make verify-surface
openspec validate rebuild-c6-four-layer-bench --strict
openspec validate --all --strict
git diff --check
```

Expected:

- All commands exit `0`.
- No Swift test invokes model inference, training, C6 acceptance, golden-run, voice, endpoint, or UIUE.

Pass/Fail:

- Pass if all commands exit `0`.
- Fail if any command exits nonzero, except a documented infrastructure interruption retried once.

Failure Action:

- If a SwiftPM helper hangs or infra flakes, record it as infra interruption with command stdout and retry once. Do not relabel it as pass.

- [ ] **L3.2 Run forbidden-action static scan**

Command:

```bash
BASE_SHA="$(cat "$RUN_DIR/BASE_SHA")"
TOUCHED_CODE="$(git diff --name-only "$BASE_SHA"..HEAD -- Core Tests | tr '\n' ' ')"
if [ -n "$TOUCHED_CODE" ]; then
  rg -n "retrain-C5|C6 acceptance|golden-run|voice|endpoint readiness|base recalibration|McNemar|pass\\^k|candidate comparison|V-PASS|S-PASS|U-PASS" $TOUCHED_CODE && exit 65 || true
  rg -n "direct_no_call|StateWriteKind\\.noop|enum C6BehaviorClass|typealias C6BehaviorClass|struct C6BehaviorClass\\b|C6-owned apply|private apply engine" $TOUCHED_CODE && exit 65 || true
fi
rg -n "This is not C6 acceptance" docs/project/phase0/rebuild-c6-scoring-foundation-closeout-2026-06-25.md
rg -n "not model-quality evaluation|not retrain-C5|not golden-run|not voice|not endpoint readiness|not UIUE merge|not R-L17 candidate signoff" docs/project/phase0/rebuild-c6-scoring-foundation-closeout-2026-06-25.md
```

Expected:

- Touched code/tests do not contain forbidden proof implementation or readiness claims.
- Closeout contains the required forbidden-work disclaimer under `## Verdict`.

Pass/Fail:

- Pass if touched code/tests scans do not find forbidden patterns and closeout disclaimer scans find required disclaimers.
- Fail if forbidden implementation/claim text appears in touched code/tests, or if closeout omits the disclaimer.

Failure Action:

- If a scan false-positives on a comment that is explicitly forbidding work, narrow the scan to the touched implementation/test files and record the exact exception in `VERIFY.md`.
- Do not delete the closeout disclaimer just to satisfy the code scan.

- [ ] **L3.3 UIUE impact conditional**

Command:

```bash
BASE_SHA="$(cat "$RUN_DIR/BASE_SHA")"
git diff --name-only "$BASE_SHA"..HEAD
```

Decision:

- If the diff includes `contracts/state-cells.yaml`, `generated/D_domain.tools.demo.json`, `contracts/c6-bench-cases.jsonl`, readback templates, or UI-visible state contracts, run a read-only UIUE impact scan against `/Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-24-phase4a-cc-window-dispatch.md`.
- If the diff only includes C6 scoring and apply evidence structs, record `uiue_impact_check: not_triggered`.

No UIUE files may be edited in this plan.

- [ ] **L3.4 Write durable lessons file**

Create `/Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-scoring-foundation-lessons-2026-06-25.md` from `VERIFY.md`:

```markdown
# Rebuild-C6 Scoring Foundation Lessons - 2026-06-25

## Verdict

status: lessons_captured
source: Reports/rebuild-c6-scoring-foundation-<timestamp>/VERIFY.md

## Lessons

| Phase | Trigger | Bad Assumption | Repo Truth | Fix | Future Guard |
|---|---|---|---|---|---|
|  |  |  |  |  |  |

## Scope Expansions

| Phase | Path | Reason | Invariant Protected | Tests Added/Changed | Residual Risk |
|---|---|---|---|---|---|
|  |  |  |  |  |  |

## Pre-Mortem Accuracy

| Phase | Predicted Failure | Happened? | Prevention Worked? | Follow-Up |
|---|---|---|---|---|
|  |  |  |  |  |
```

Expected:

- The file contains every non-trivial lesson from `VERIFY.md`.
- Blank template rows are replaced with real rows or `none`.

Pass/Fail:

- Pass if lessons and scope expansions are durable in docs.
- Fail if `VERIFY.md` contains lessons that are missing from the durable file.

Failure Action:

- Update the lessons file before closeout commit.

- [ ] **L3.5 Write durable closeout receipt**

Create `/Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-scoring-foundation-closeout-2026-06-25.md`:

```markdown
# Rebuild-C6 Scoring Foundation Closeout - 2026-06-25

## Verdict

status: local-pass
proof_class:
- local_static_contract
- local_unit
- local_receipt_consistency

optional_baseline_check:
- local_shape_no_model_baseline_unchanged

This is not C6 acceptance, not model-quality evaluation, not retrain-C5, not golden-run, not voice, not endpoint readiness, not UIUE merge, and not R-L17 candidate signoff.

## Scope

Implemented Long-run 1 scoring foundation:
- shared behavior taxonomy
- two-axis C6 reporting
- denominator selector shell
- apply descriptive write facts
- C6 replay consumption of applied writes
- dependency-write provenance
- readback split from model hard pass

Deferred to later long-runs:
- contract_bundle_fingerprint aggregation
- D-domain C6 JSONL shape migration
- §4 candidate comparison
- thresholds and base anchors

## Commands

| Command | Exit | Evidence |
|---|---:|---|
| `swift test --filter C6VehicleToolBenchTests` |  | `Reports/.../VERIFY.md` |
| `swift test --filter ToolContractCompilerTests` |  | `Reports/.../VERIFY.md` |
| `make verify-surface` |  | `Reports/.../VERIFY.md` |
| `openspec validate rebuild-c6-four-layer-bench --strict` |  | `Reports/.../VERIFY.md` |
| `openspec validate --all --strict` |  | `Reports/.../VERIFY.md` |
| `git diff --check` |  | `Reports/.../VERIFY.md` |

## Subagent Audits

| Phase | Verdict | Residual Risk |
|---|---|---|
| Phase 1A |  |  |
| Phase 1B |  |  |
| Phase 1C |  |  |
| Phase 2 |  |  |
| Phase 3 |  |  |

## Residual Risk

- Current C6 JSONL rows may still lack explicit `behavior_class`; D-domain shape migration remains deferred.
- Legacy `IrrelAcc` may remain for compatibility but is not an active four-layer acceptance gate.
- Thresholds, base anchors, candidate comparison, and model-quality acceptance remain unauthorized.
- `local_shape_no_model_baseline_unchanged` means surface shape was checked as an unchanged baseline guard only; D-domain C6 JSONL shape migration remains deferred.
```

Fill command exit codes and audit verdicts from actual evidence. Do not leave blank cells.

- [ ] **L3.6 Final staged commit**

Command:

```bash
git status --short
git add docs/project/phase0/rebuild-c6-scoring-foundation-closeout-2026-06-25.md docs/project/phase0/rebuild-c6-scoring-foundation-lessons-2026-06-25.md
git commit -m "docs(rebuild-c6): close scoring foundation local pass"
git status --short --branch
```

Expected:

- Worktree is clean after the final commit.
- Branch is ahead by staged implementation commits.

Pass/Fail:

- Pass if the closeout commit succeeds and `git status --short --branch` is clean.
- Pass with note if the only remaining evidence is ignored `Reports/` scratch output and the durable closeout links it.
- Fail if non-ignored dirty files remain.

Failure Action:

- If non-ignored dirty files remain, identify owner and either commit them in-scope or stop before GPT Pro audit.

---

## L4: GitHub Push And GPT Pro External Audit

**Purpose:** Make the completed local branch available for GPT Pro review after L3 local gates pass. This is an external audit handoff, not a merge or readiness claim.

- [ ] **L4.1 Push the branch for audit**

Command:

```bash
git status --short --branch
BRANCH="$(git branch --show-current)"
git push -u origin "$BRANCH"
```

Expected:

- Worktree is clean before push.
- Push succeeds to the current branch.
- No merge, archive, release, or PR-ready claim is made by this command.

Pass/Fail:

- Pass if push exits `0`.
- Fail if worktree is dirty or push fails.

Failure Action:

- If push fails because remote is unavailable, record the failure and stop at `local-pass pending external audit`.
- Do not force-push unless the human owner explicitly authorizes it.

- [ ] **L4.2 Write GPT Pro audit request**

Create `/Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-scoring-foundation-gptpro-audit-request-2026-06-25.md`:

```markdown
# GPT Pro Audit Request - Rebuild-C6 Scoring Foundation

## Audit Target

repo: /Users/wanglei/workspace/MAformac
branch: <branch pushed to GitHub>
change: rebuild-c6-four-layer-bench
scope: post-A2 / post-PR4 default_scope / post-R-L17 route-only rebuild-C6 §1-§3 construction scoring foundation

## What To Audit

- shared `VehicleToolBehaviorClass` taxonomy and C6 case adapter
- two-axis C6 reporting
- denominator selector shell with no thresholds/base recalibration
- apply `StateWrite` facts and write_kind semantics
- C6 applied-write consumption and dependency `dependsOn` proof
- readback split from model hard pass
- forbidden-work boundaries
- closeout evidence completeness

## What Is Not Authorized

- retrain-C5
- C6 acceptance
- D-domain base recalibration
- §4 candidate comparison
- model evaluation
- golden-run
- voice
- endpoint readiness
- UIUE merge
- R-L17 candidate signoff

## Required Verdict

Return:
- status: PASS / PASS_WITH_FIXES / FAIL
- P0/P1/P2 findings with file:line anchors
- teardown: top 3 fake-green paths still possible
- whether this branch is ready for the next long-run, Phase 4-6 identity and shape closeout
```

Expected:

- Audit request is self-contained and branch-aware.
- It references the pushed branch and local closeout file.

Pass/Fail:

- Pass if the audit request file is committed after the push.
- Fail if it asks GPT Pro to judge training/model acceptance or any forbidden future lane.

Failure Action:

- Fix the request doc only, rerun `git diff --check`, and commit.

- [ ] **L4.3 Commit GPT Pro request**

Command:

```bash
git add docs/project/phase0/rebuild-c6-scoring-foundation-gptpro-audit-request-2026-06-25.md
git commit -m "docs(rebuild-c6): request GPT Pro scoring foundation audit"
git push
git status --short --branch
```

Expected:

- The GPT Pro audit request is pushed to GitHub.
- Worktree is clean.

Pass/Fail:

- Pass if commit and push both exit `0`.
- Fail if either fails.

Failure Action:

- Stop at `local-pass external-audit-request-not-pushed`.

- [ ] **L4.4 Receive and absorb GPT Pro verdict**

Input:

- GPT Pro audit report for the pushed GitHub branch.

Required handling:

```markdown
## GPT Pro Verdict Handling

verdict: PASS | PASS_WITH_FIXES | FAIL
source: <link or local path to GPT Pro report>

P0:
- ...
P1:
- ...
P2:
- ...

absorption:
- ...

final_external_audit_status: external-pass | external-pass-with-absorbed-fixes | external-fail | blocked-pending-gptpro
```

Expected:

- A real GPT Pro verdict is received.
- P0 findings block closeout until fixed and re-audited.
- P1 findings are either fixed in code/docs with evidence and rechecked, or explicitly recorded as blockers.
- P2 findings may be recorded as residual risk only if they do not weaken route boundaries or harness.
- `GPT Pro request pushed` is never treated as `GPT Pro audit passed`.

Pass/Fail:

- Pass if GPT Pro returns `PASS`, or `PASS_WITH_FIXES` and all P0/P1 fixes are absorbed with command evidence.
- Fail if GPT Pro returns `FAIL`, reports any unresolved P0/P1, or the verdict is unavailable.

Failure Action:

- Stop at `local-pass pending external audit` if no report is available.
- Stop at `external-fail` if GPT Pro finds unresolved P0/P1.
- Do not proceed to the next long-run until this gate is resolved or the human owner explicitly supersedes it.

---

## Subagent Audit Template

Use this read-only prompt after each phase:

```text
You are a read-only Codex audit subagent for MAformac.

Scope:
- Repo: /Users/wanglei/workspace/MAformac
- Phase: <PHASE_NAME>
- Read only. Do not edit files.

Audit question:
Does this phase satisfy the rebuild-C6 scoring foundation contract without violating route-only construction boundaries?

Must check:
- git diff for this phase only
- relevant tests added before implementation or clear equivalent already existed
- no training, C6 acceptance, base recalibration, §4 candidate comparison, model eval, golden-run, voice, endpoint, UIUE merge, V/S/U-PASS
- no C6-private behavior taxonomy
- no direct_no_call
- no StateWriteKind.noop
- no C6 private apply engine
- no expected C6 sets passed into applyWithEvidence
- readback is not counted as model hard pass after Phase 3
- proof class remains within `local_static_contract`, `local_unit`, `local_receipt_consistency`, plus optional `local_shape_no_model_baseline_unchanged`
- phase pre-mortem and lessons are recorded in `VERIFY.md`
- no harness downgrade or skipped audit

Return:
- status: PASS / PASS_WITH_FIXES / FAIL / BLOCKED
- evidence table with file:line anchors
- commands inspected
- residual risk
- touched paths
```

Controller rule: subagent output is evidence, not final authority. Live repo/test output wins over prose.

---

## Commit Strategy

Use staged commits, not one giant mixed commit. These are suggested commit boundaries; GPT-5.5 may split a phase further when that improves reviewability, but it must not squash phases together.

1. `docs(rebuild-c6): add scoring foundation execution plan`
2. `test(c6): add shared behavior taxonomy`
3. `feat(c6): add two-axis scoring reports`
4. `feat(c6): add denominator selector shell`
5. `feat(apply): emit descriptive state write evidence`
6. `feat(c6): consume apply write evidence in scoring`
7. `docs(rebuild-c6): close scoring foundation local pass`
8. `docs(rebuild-c6): request GPT Pro scoring foundation audit`

If a phase must be split further because `Core/Bench/C6VehicleToolBench.swift` becomes too large a change, split by behavior-preserving tests first, implementation second.

---

## Execution Mode

Use **single-writer GPT-5.5/Codex execution with mandatory read-only subagent audits** after Phase 1A, 1B, 1C, 2, and 3. This gives the implementation agent full reasoning and design latitude while preserving the harness.

No inline-only execution mode is approved. If subagent audit cannot run, stop and report `BLOCKED: missing phase audit lane`.

Do not start execution until L0 passes.
