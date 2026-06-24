# Rebuild C6 Identity And Shape Closeout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Complete Long-run 2 for `rebuild-c6-four-layer-bench`: contract bundle identity, D-domain C6 case shape migration, and branch-source closeout evidence without starting candidate comparison or model-quality evaluation.

**Architecture:** Long-run 1 already landed scoring foundation and reached `external-pass-with-absorbed-fixes`. This plan builds the remaining construction-lane identity and shape layer: a deterministic contract-bundle manifest/fingerprint, explicit C6 case `behavior_class` shape, source-free shape checks, UIUE impact review, durable lessons, GitHub push, and GPT Pro external audit. Implementation must be repo-native and may improve local structure, but it must preserve the OpenSpec construction/comparison split.

**Tech Stack:** Swift, XCTest, JSONL, Python stdlib, Makefile, OpenSpec, GitHub branch push, GPT Pro external review.

**Metadata**

| Field | Value |
|---|---|
| `authority` | `implementation_plan_not_ssot` |
| `change_id` | `rebuild-c6-four-layer-bench` |
| `plan_date` | `2026-06-25` |
| `route` | `post-A2 / post-PR4 default_scope / post-R-L17 route-only / post-scoring-foundation external-pass-with-absorbed-fixes` |
| `long_run_slice` | Long-run 2 of 2 for rebuild-C6 construction-lane closeout |
| `local_ends_at` | Contract bundle identity, explicit D-domain C6 case shape, local closeout |
| `external_audit_gate` | Push GitHub branch after local closeout, then request GPT Pro audit before external-pass claim |
| `retire_trigger` | Retire or supersede after GPT Pro verdict is absorbed into tracked closeout, or after a newer implementation plan explicitly supersedes this file |
| `expiry_trigger` | Expires if OpenSpec `rebuild-c6-four-layer-bench` construction/comparison topology changes, if route-only R-L17 status changes, or if implementation starts from a different audited baseline without updating L0 |

## Global Constraints

- Route: `post-A2 / post-PR4 default_scope / post-R-L17 route-only / post-scoring-foundation external-pass-with-absorbed-fixes`.
- Current audited scoring HEAD before this plan: `02317a6933ce2f8f8a61c183e13528eb459fb127`.
- Allowed proof classes: `local_static_contract`, `local_unit`, `local_shape_no_model`, `local_receipt_consistency`, and GPT Pro external audit over a pushed GitHub branch.
- Forbidden: retrain-C5, C6 acceptance, D-domain base recalibration, `rebuild-c6` §4 candidate comparison, model-quality evaluation, training data generation, LoRA artifact changes, demo golden-run, voice, endpoint readiness, UIUE merge claims, R-L17 candidate signoff, and any `V-PASS`/`S-PASS`/`U-PASS` claim.
- Harness cannot be downgraded: phase subagent audits and final GPT Pro audit are hard gates.
- GPT-5.5/Codex has broad implementation authority inside route boundaries. Suggested names and snippets are target shapes, not paste contracts.
- Every phase starts with a short pre-mortem and records lessons immediately in `VERIFY.md`.

---

## User Image Requirements Absorbed

The requirements in `/var/folders/_s/cgbbydhx4m7cd_c_2j14v9b00000gn/T/codex-clipboard-e705d927-b3b4-494d-b909-1d1ec475cf5b.png` are binding:

- Integrate project metacognition, harness, and the earlier two-pass audit opinion.
- Arrange subagent Codex audit for the plan and for execution phases.
- Do not over-constrain the implementation plan. Maximize GPT-5.5/Codex reasoning and implementation ability.
- Read and absorb heterogeneous GLM audit-style feedback when available.
- Include GPT Pro audit as a final hard gate; push GitHub branch before requesting GPT Pro review.
- Give the executor strong route-bounded authority.
- Run active pre-mortems when problems appear, not only after failure.
- Record lessons continuously.
- Do not downgrade the harness.

---

## Heterogeneous Audit Inputs To Carry Forward

Executor must treat these prior audit inputs as route context, not as stale implementation truth. Reconfirm repo facts before code edits.

- GLM audit of the first rebuild-C6 scoring plan: `/Users/wanglei/.codex/attachments/66ff086a-03e1-4819-a3e9-6dd7656c8912/pasted-text.txt`.
- Earlier two-pass harness critique: `/Users/wanglei/.codex/attachments/14088040-a318-41ed-a9a7-850e518ccee4/pasted-text.txt`.
- Duplicate available copy of the same critique: `/Users/wanglei/.codex/attachments/3c4a03c9-8457-4e38-9689-c7fbc931327c/pasted-text.txt`.

Carry-forward rules from those audits:

- Treat implementation plans as finite-state harnesses: each phase needs entry state, exit gate, proof class, stop condition, and receipt evidence.
- Commit the plan before L0 implementation work, otherwise the plan itself makes the worktree dirty and the baseline is ambiguous.
- Avoid self-failing scans: forbidden-word checks must not reject legitimate red-line text in the plan or closeout.
- Evidence in ignored `Reports/` is scratch only. External audit must have tracked excerpts.
- Subagent audits are independent evidence. If the audit lane cannot run, stop as blocked; do not replace it with same-thread self-review.
- GPT-5.5/Codex can add adjacent helper files, stronger tests, or small refactors when they reduce fake-green risk and preserve route boundaries.
- Do not paste code snippets blindly. Snippets in this plan express target semantics; repo-native design wins when it records a Scope Expansion Record.

---

## Step 1 Live Audit Result

Live audit before writing this plan:

- `git status --short --branch`: clean on `codex/rebuild-c6-doc-absorption-20260624`.
- `HEAD` and upstream both equal `02317a6933ce2f8f8a61c183e13528eb459fb127`.
- Closeout says `status: external-pass-with-absorbed-fixes`.
- GPT Pro report is tracked at `/Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-scoring-foundation-gptpro-audit-2026-06-25.md`.
- Tracked evidence excerpt is present at `/Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-scoring-foundation-evidence-excerpt-2026-06-25.md`.
- `C6Summary.status` is now `local_construction_report`, with regression coverage in `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift`.

This plan must not re-open Long-run 1 except to consume its artifacts as baseline truth.

---

## Scope Contract

### Scope In

- Contract bundle manifest and fingerprint over stable contract inputs.
- Preservation of existing per-run identity fields: prompt hash, tool-output digest, contract digest, model/tokenizer/LoRA digests.
- C6 JSONL shape migration to explicit `behavior_class` where missing.
- Source-free shape checks for behavior class, layer denominator, D-domain tool names, and gold validity.
- Optional Makefile hook for the new source-free C6 shape check.
- UIUE impact scan because C6 JSONL/shape migration can affect presentation/golden interfaces.
- Durable closeout, lessons, evidence excerpt, GitHub push, and GPT Pro audit verdict handling.

### Scope Out

- No candidate comparison.
- No thresholds, active base anchors, pass^k, McNemar, model-quality run, or C6 acceptance.
- No training or LoRA data changes.
- No UIUE file edits.
- No raw cockpit/customer text import.
- No changes to source snapshots or raw data.

### Starting Write Set

Start from these paths. GPT-5.5 may expand to adjacent files when it records a Scope Expansion Record in `VERIFY.md`.

- `/Users/wanglei/workspace/MAformac/Core/Bench/C6VehicleToolBench.swift`
- `/Users/wanglei/workspace/MAformac/Core/Bench/C6ContractBundleFingerprint.swift`
- `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift`
- `/Users/wanglei/workspace/MAformac/contracts/c6-bench-cases.jsonl`
- `/Users/wanglei/workspace/MAformac/scripts/check_c6_case_shape.py`
- `/Users/wanglei/workspace/MAformac/Makefile`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-identity-shape-closeout-2026-06-25.md`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-identity-shape-lessons-2026-06-25.md`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-identity-shape-evidence-excerpt-2026-06-25.md`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-identity-shape-gptpro-audit-request-2026-06-25.md`
- `/Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-identity-shape-gptpro-audit-2026-06-25.md`
- `/Users/wanglei/workspace/MAformac/Reports/rebuild-c6-identity-shape-<timestamp>/VERIFY.md`

### No-Touch Without New Human Approval

- `/Users/wanglei/workspace/MAformac/Core/Training/*`
- `/Users/wanglei/workspace/MAformac/Models/*`
- `/Users/wanglei/workspace/MAformac/Voice/*`
- `/Users/wanglei/workspace/MAformac/openspec/changes/retrain-c5-lora-d-domain/*`
- `/Users/wanglei/workspace/MAformac-uiue/*`
- Raw/source-snapshot inputs outside committed repo artifacts.

---

## Autonomy And Harness Rules

GPT-5.5/Codex should choose the best repo-native implementation, not mechanically paste snippets. It may split files, add helper scripts, strengthen tests, or add static gates when doing so reduces fake-green risk. The hard invariants are:

- `contract_bundle_fingerprint` is a component manifest fingerprint, not a replacement for per-run prompt/output/model/tokenizer/LoRA identity fields.
- D-domain shape migration adds explicit shape evidence; it does not authorize C6 acceptance or model-quality thresholds.
- `behavior_class` remains the five-class taxonomy from Long-run 1; no `direct_no_call`.
- C6 JSONL shape changes must be source-free, committed, diffable, and validated.
- `Reports/` remains scratch only; branch-source evidence must be tracked.
- Subagent audits and GPT Pro audit cannot be replaced by same-thread self-review.

At the start of each phase, write this to `VERIFY.md`:

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

When a lesson appears, append immediately:

```markdown
### Lesson

phase:
trigger:
bad_assumption:
repo_truth:
fix:
future_guard:
```

---

## B0: Plan Freeze

**Files:** this plan only.

- [ ] **Step 1: Verify plan hygiene**

Run:

```bash
git add --intent-to-add docs/superpowers/plans/2026-06-25-rebuild-c6-identity-shape-closeout.md
git diff --check
python3 - <<'PY'
from pathlib import Path

path = Path("docs/superpowers/plans/2026-06-25-rebuild-c6-identity-shape-closeout.md")
terms = [
    "TO" + "DO",
    "TB" + "D",
    "PLACE" + "HOLDER",
    "\u5f85" + "\u8865",
    "\u5f85" + "\u5b9a",
    "\u5360" + "\u4f4d",
    "fall" + "back",
    "Inline " + "Execution",
]
hits = []
for line_no, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
    for term in terms:
        if term in line:
            hits.append(f"{path}:{line_no}: contains {term!r}: {line}")
if hits:
    raise SystemExit("\n".join(hits))
PY
```

Expected:

- `git diff --check` exits `0`, including this plan file even when it started untracked.
- Python hygiene check exits `0` with no matches.
- `direct_no_call` is checked semantically by the Phase 5 shape script, so this hygiene grep does not reject legitimate prohibition text.

- [ ] **Step 2: Commit plan alone**

Run:

```bash
git status --short --branch
git add docs/superpowers/plans/2026-06-25-rebuild-c6-identity-shape-closeout.md
git commit -m "docs(rebuild-c6): add identity shape closeout plan"
git status --short --branch
```

Expected:

- Only this plan file is committed.
- Worktree is clean or dirty files are explicitly unrelated and not staged.

---

## L0: Baseline Reconfirmation

**Files:** read-only baseline.

- [ ] **Step 1: Create run directory and record baseline**

Run:

```bash
RUN_DIR="Reports/rebuild-c6-identity-shape-$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$RUN_DIR"
: > "$RUN_DIR/VERIFY.md"
BASE_SHA="$(git rev-parse HEAD)"
printf '%s\n' "$BASE_SHA" > "$RUN_DIR/BASE_SHA"
printf 'BASE_SHA=%s\n' "$BASE_SHA" >> "$RUN_DIR/VERIFY.md"
git status --short --branch | tee -a "$RUN_DIR/VERIFY.md"
git rev-parse HEAD | tee -a "$RUN_DIR/VERIFY.md"
git rev-parse @{u} | tee -a "$RUN_DIR/VERIFY.md"
for input in \
  /Users/wanglei/.codex/attachments/66ff086a-03e1-4819-a3e9-6dd7656c8912/pasted-text.txt \
  /Users/wanglei/.codex/attachments/14088040-a318-41ed-a9a7-850e518ccee4/pasted-text.txt \
  /Users/wanglei/.codex/attachments/3c4a03c9-8457-4e38-9689-c7fbc931327c/pasted-text.txt
do
  test -f "$input"
  shasum -a 256 "$input" | tee -a "$RUN_DIR/VERIFY.md"
done
```

Expected:

- Local HEAD and upstream match before implementation.
- `RUN_DIR` and `BASE_SHA` are available for final diff and evidence.
- Heterogeneous audit inputs exist and their hashes are recorded, while their distilled rules in this plan remain the durable branch-source input.

- [ ] **Step 2: Reconfirm Long-run 1 closeout**

Run:

```bash
rg -n "external-pass-with-absorbed-fixes|local_construction_report|P1-1|P1-2|final_external_audit_status" \
  docs/project/phase0/rebuild-c6-scoring-foundation-closeout-2026-06-25.md \
  docs/project/phase0/rebuild-c6-scoring-foundation-evidence-excerpt-2026-06-25.md \
  Core/Bench/C6VehicleToolBench.swift \
  Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift
```

Expected:

- Long-run 1 is externally closed with absorbed fixes.
- `C6Summary.status` remains `local_construction_report`.

- [ ] **Step 3: Reconfirm current OpenSpec construction lane**

Run:

```bash
openspec validate rebuild-c6-four-layer-bench --strict
openspec validate --all --strict
rg -n "AD-C6-009|contract_bundle_fingerprint|D-domain C6 JSONL shape migration|Candidate Comparison Lane|No C6 acceptance" \
  openspec/changes/rebuild-c6-four-layer-bench/design.md \
  openspec/changes/rebuild-c6-four-layer-bench/tasks.md \
  docs/project/phase0/rebuild-c6-scoring-foundation-closeout-2026-06-25.md
```

Expected:

- OpenSpec remains valid.
- Identity and shape are the remaining construction-lane work.
- Candidate comparison remains blocked.

- [ ] **Step 4: Confirm human OpenSpec propose/apply authorization**

Run:

```bash
rg -n "OpenSpec propose review.*accepted|propose/apply authorization.*accepted|accepted_for_apply|construction apply authorized|human.*accept.*rebuild-c6" \
  docs/CURRENT.md \
  docs/project/phase0 \
  openspec/changes/rebuild-c6-four-layer-bench
```

Expected:

- A tracked file explicitly records that human OpenSpec propose/apply authorization is accepted for `rebuild-c6-four-layer-bench` construction.
- If evidence is absent or only says `unlocked_not_yet_closed`, stop before Phase 4 and report `BLOCKED: missing human OpenSpec propose/apply authorization evidence`.
- OpenSpec validation alone is not sufficient authorization to implement.

---

## Phase 4: Contract Bundle Identity

**Files:**

- Create or modify: `/Users/wanglei/workspace/MAformac/Core/Bench/C6ContractBundleFingerprint.swift`
- Modify: `/Users/wanglei/workspace/MAformac/Core/Bench/C6VehicleToolBench.swift`
- Modify: `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift`

**Interfaces:**

- Consumes existing `C6Hash.sha256Hex`, `C6Hash.fileHash`, `C6CanonicalJSON`.
- Produces a versioned manifest and `contract_bundle_fingerprint` field while preserving existing `contract_digest`.

- [ ] **Step 1: Add red tests for manifest determinism and component sensitivity**

Add tests proving:

- manifest components are ordered deterministically;
- fingerprint changes when a component digest changes;
- fingerprint does not remove or overwrite existing per-run identity fields;
- missing component fails closed.

Suggested test names:

```swift
func testContractBundleFingerprintIsDeterministicAndOrdered() throws
func testContractBundleFingerprintChangesWhenComponentDigestChanges() throws
func testEvalRunCarriesContractBundleFingerprintWithoutReplacingPerRunDigests() throws
func testContractBundleFingerprintFailsClosedOnMissingComponent() throws
```

Run:

```bash
swift test --filter C6VehicleToolBenchTests/testContractBundleFingerprintIsDeterministicAndOrdered
swift test --filter C6VehicleToolBenchTests/testContractBundleFingerprintChangesWhenComponentDigestChanges
swift test --filter C6VehicleToolBenchTests/testEvalRunCarriesContractBundleFingerprintWithoutReplacingPerRunDigests
swift test --filter C6VehicleToolBenchTests/testContractBundleFingerprintFailsClosedOnMissingComponent
```

Expected:

- Fails before implementation or reports equivalent existing coverage.

- [ ] **Step 2: Implement manifest/fingerprint**

Target components:

| component_id | path/source | version |
|---|---|---|
| `c1.semantic_function_contract` | `contracts/semantic-function-contract.jsonl` | `v1` |
| `c2.state_cells_renderer` | `contracts/state-cells.yaml` | `v1` |
| `c6.bench_cases` | `contracts/c6-bench-cases.jsonl` or dataset text passed to runner | `v1` |
| `qwen.tool_call_format` | `contracts/qwen-tool-call-format.yaml` | `v1` |
| `d_domain.ir_map` | `generated/d_domain_ir_map.json` | `v1` |
| `d_domain.demo_tool_catalog` | `generated/D_domain.tools.demo.json` | `v1` |

Target data shape:

```swift
public struct C6ContractBundleComponent: Codable, Equatable, Sendable {
    public var componentID: String
    public var version: String
    public var contentDigest: String
}

public struct C6ContractBundleManifest: Codable, Equatable, Sendable {
    public var manifestVersion: String
    public var components: [C6ContractBundleComponent]
}
```

Implementation may use different file placement if it records the deviation and preserves the manifest semantics.

- [ ] **Step 3: Thread fingerprint into run/summary identity**

Add `contract_bundle_fingerprint` without deleting:

- `prompt_hash`
- `tool_output_digest`
- `contract_digest`
- `model_artifact_digest`
- `tokenizer_digest`
- `lora_adapter_digest`

Run:

```bash
swift test --filter C6VehicleToolBenchTests/testReplayFingerprintRecordsArtifactDigestsAsRequiredFields
swift test --filter C6VehicleToolBenchTests/testSummaryRecordsArtifactDigestsAtTopLevelAndEachEvalRun
swift test --filter C6VehicleToolBenchTests/testEvalRunCarriesContractBundleFingerprintWithoutReplacingPerRunDigests
```

Expected:

- Existing identity tests still pass.
- New fingerprint is present and nonempty.

- [ ] **Step 4: Phase 4 audit and commit**

Run:

```bash
swift test --filter C6VehicleToolBenchTests
rg -n "contract_bundle_fingerprint|contractBundleFingerprint" Core/Bench Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift
```

Expected:

- Tests pass.
- Contract bundle identity appears in code/tests.
- No model eval, candidate comparison, or acceptance path appears.

Subagent audit:

- Read-only audit Phase 4: contract bundle is a component manifest, not a replacement for per-run identity fields.

Commit:

```bash
git add Core/Bench/C6VehicleToolBench.swift Core/Bench/C6ContractBundleFingerprint.swift Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift
git commit -m "feat(c6): add contract bundle fingerprint"
```

---

## Phase 5: D-Domain C6 Case Shape Migration

**Files:**

- Modify: `/Users/wanglei/workspace/MAformac/contracts/c6-bench-cases.jsonl`
- Create: `/Users/wanglei/workspace/MAformac/scripts/check_c6_case_shape.py`
- Modify: `/Users/wanglei/workspace/MAformac/Makefile`
- Modify: `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift`

**Interfaces:**

- Consumes five-class `VehicleToolBehaviorClass`.
- Produces source-free checks that every C6 row has explicit behavior shape and D-domain tool names.

- [ ] **Step 1: Write shape-check script first**

Create a source-free Python script that validates committed JSONL only:

```bash
python3 scripts/check_c6_case_shape.py contracts/c6-bench-cases.jsonl generated/D_domain.tools.demo.json
```

Required invariants:

- every nonempty row has `behavior_class`;
- `behavior_class` is one of `tool_call`, `clarify_missing_slot`, `refusal_no_available_tool`, `refusal_safety_or_policy`, `already_state_noop`;
- no row has `direct_no_call`;
- `tool_call` rows have nonempty `expected_tool_calls`;
- `clarify_missing_slot`, `refusal_no_available_tool`, `refusal_safety_or_policy`, and `already_state_noop` rows have empty `expected_tool_calls`;
- `already_state_noop` rows prove no-op mechanically: every key in `expected_state_delta` exists in `pre_state` and already equals the expected value; empty `expected_state_delta` for this class fails closed unless a future tracked schema adds an explicit no-op target field;
- `clarify_missing_slot` rows carry `clarify_tag == "ambiguous"` or a tracked accepted equivalent; conflicting clarify/no-call markers fail closed;
- safety rows have nonempty `source_refs.risk_rule_ids`;
- unsupported rows have empty `source_refs.risk_rule_ids`;
- all expected tool call names and alternative tool names are in `generated/D_domain.tools.demo.json`;
- broad `tags.bucket == "no_call"` is not enough to infer `already_state_noop`;
- `expect_no_call == true` is never accepted as a success denominator by itself; it must be paired with explicit behavior class and compatible clarify/refusal/safety/already-state evidence;
- rows with `expected_tool_calls == []` must not be counted as successful unless their explicit behavior class is one of the four no-call success/refusal/clarify classes and passes that class's proof rule;
- `coverage` / demo-fuzz rows must not enter the golden hard-pass denominator unless a future tracked held-out/family-split proof field is added and validated;
- the script prints row counts by `behavior_class` and by external layer candidate (`golden`, `demo_fuzz`, `unsupported`, `safety`, `clarify`) so denominator drift is visible in tracked evidence;
- no aggregate rate, `IrrelAcc`, or empty-tool-call aggregate can satisfy these shape checks.

Expected before migration:

- Script exits nonzero because some current rows lack explicit `behavior_class`.

- [ ] **Step 2: Migrate JSONL behavior_class explicitly**

Use repo-native automation or careful structured edits. Do not import raw text. Do not change user-facing utterances except if a shape check proves a row is malformed.

Suggested classification rules:

- `expected_tool_calls` nonempty -> `tool_call`.
- `source_refs.risk_rule_ids` nonempty and no tool calls -> `refusal_safety_or_policy`.
- no tool calls, `clarify_tag == "ambiguous"` -> `clarify_missing_slot`.
- no tool calls, out-of-domain unsupported cases -> `refusal_no_available_tool`.
- no tool calls and every expected target state value is already satisfied by `pre_state` -> `already_state_noop`.

If any row cannot be classified mechanically, stop and record it as `shape_migration_blocked_row` in `VERIFY.md`; do not invent a class to make the script pass.

- [ ] **Step 3: Add Makefile hook**

Add a source-free target:

```make
verify-c6-shape: .venv/.deps.stamp
	$(PYTHON) scripts/check_c6_case_shape.py contracts/c6-bench-cases.jsonl generated/D_domain.tools.demo.json
```

Do not insert it into raw-dependent gates. It may be included in `verify-ci` only if it stays source-free.

- [ ] **Step 4: Add shape regression tests**

Add tests proving dataset decode and explicit behavior class shape:

```swift
func testTrackedDatasetRowsCarryExplicitBehaviorClass() throws
func testTrackedDatasetBehaviorClassesMatchFiveClassTaxonomy() throws
```

Run:

```bash
swift test --filter C6VehicleToolBenchTests/testTrackedDatasetRowsCarryExplicitBehaviorClass
swift test --filter C6VehicleToolBenchTests/testTrackedDatasetBehaviorClassesMatchFiveClassTaxonomy
python3 scripts/check_c6_case_shape.py contracts/c6-bench-cases.jsonl generated/D_domain.tools.demo.json
make verify-surface
```

Expected:

- All commands exit `0`.

- [ ] **Step 5: UIUE impact scan**

Because this phase touches `contracts/c6-bench-cases.jsonl`, run read-only UIUE impact review:

```bash
test -f /Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-24-phase4a-cc-window-dispatch.md
rg -n "C6|gold|behavior_class|case_id|readback|state|dispatch|Phase4" /Users/wanglei/workspace/MAformac-uiue/docs/dispatches/2026-06-24-phase4a-cc-window-dispatch.md
```

Expected:

- UIUE impact is recorded as `not_blocking`, `needs_followup`, or `blocked`.
- No UIUE files are edited.

- [ ] **Step 6: Phase 5 audit and commit**

Subagent audit:

- Read-only audit Phase 5: JSONL shape migration is explicit, source-free, D-domain aligned, and does not claim C6 acceptance.

Commit:

```bash
git add contracts/c6-bench-cases.jsonl scripts/check_c6_case_shape.py Makefile Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift
git commit -m "feat(c6): migrate bench cases to explicit behavior shape"
```

---

## Phase 6: Identity + Shape Closeout

**Files:**

- Create: `/Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-identity-shape-closeout-2026-06-25.md`
- Create: `/Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-identity-shape-lessons-2026-06-25.md`
- Create: `/Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-identity-shape-evidence-excerpt-2026-06-25.md`

- [ ] **Step 1: Run final local gates**

Run:

```bash
swift test --filter C6VehicleToolBenchTests
swift test --filter ToolContractCompilerTests
python3 scripts/check_c6_case_shape.py contracts/c6-bench-cases.jsonl generated/D_domain.tools.demo.json
make verify-surface
openspec validate rebuild-c6-four-layer-bench --strict
openspec validate --all --strict
git diff --check
```

Expected:

- All commands exit `0`.
- No command runs model inference, training, C6 acceptance, golden-run, voice, endpoint, or UIUE.

- [ ] **Step 2: Write tracked evidence excerpt**

Create a tracked evidence excerpt containing:

- command;
- exit code;
- high-signal stdout;
- proof class;
- exact commit range from `$RUN_DIR/BASE_SHA` to current HEAD.

The excerpt must be enough for GPT Pro to audit without local ignored `Reports/.../VERIFY.md`.

- [ ] **Step 3: Write closeout and lessons**

Closeout verdict can be at most:

```markdown
status: local-pass-pending-gptpro
proof_class:
- local_static_contract
- local_unit
- local_shape_no_model
- local_receipt_consistency
```

It must also state:

- OpenSpec propose/apply authorization evidence: `<tracked file:line or commit>`, or `BLOCKED` if missing.
- not C6 acceptance;
- not model-quality evaluation;
- not candidate comparison;
- not retrain-C5;
- not endpoint/demo/voice readiness;
- not UIUE merge;
- not R-L17 candidate signoff.

Lessons file must include pre-mortem misses, scope expansions, false-green risks, UIUE impact result, and command surprises.

- [ ] **Step 4: Commit closeout**

Run:

```bash
git add docs/project/phase0/rebuild-c6-identity-shape-closeout-2026-06-25.md \
  docs/project/phase0/rebuild-c6-identity-shape-lessons-2026-06-25.md \
  docs/project/phase0/rebuild-c6-identity-shape-evidence-excerpt-2026-06-25.md
git commit -m "docs(rebuild-c6): close identity shape local pass"
git status --short --branch
```

Expected:

- Worktree is clean except ignored `Reports/` scratch evidence.

---

## L4: GitHub Push And GPT Pro Audit

**Purpose:** External audit is mandatory and cannot be downgraded.

- [ ] **Step 1: Push branch**

Run:

```bash
git status --short --branch
BRANCH="$(git branch --show-current)"
git push -u origin "$BRANCH"
```

Expected:

- Worktree clean.
- Push succeeds.

- [ ] **Step 2: Write GPT Pro audit request**

Create `/Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-identity-shape-gptpro-audit-request-2026-06-25.md` with:

- branch and HEAD;
- Phase 4 fingerprint diff;
- Phase 5 JSONL shape diff;
- final local evidence excerpt path;
- explicit no-goals;
- required verdict `PASS / PASS_WITH_FIXES / FAIL`;
- required P0/P1/P2 findings with file:line anchors;
- teardown top 3 fake-green paths;
- whether next route may move to candidate comparison only after retrain-C5 candidate signoff.

Commit and push:

```bash
git add docs/project/phase0/rebuild-c6-identity-shape-gptpro-audit-request-2026-06-25.md
git commit -m "docs(rebuild-c6): request GPT Pro identity shape audit"
git push
```

- [ ] **Step 3: Receive and absorb GPT Pro verdict**

Create tracked report:

`/Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-identity-shape-gptpro-audit-2026-06-25.md`

Then update closeout with:

```markdown
final_external_audit_status: external-pass | external-pass-with-absorbed-fixes | external-fail | blocked-pending-gptpro
```

Rules:

- P0 blocks.
- P1 must be fixed or recorded as blocker.
- P2 may remain residual only if it does not weaken harness or route boundaries.
- `GPT Pro request pushed` is not `GPT Pro audit passed`.

Commit and push final absorption:

```bash
git add docs/project/phase0/rebuild-c6-identity-shape-gptpro-audit-2026-06-25.md \
  docs/project/phase0/rebuild-c6-identity-shape-closeout-2026-06-25.md
git commit -m "fix(rebuild-c6): absorb GPT Pro identity shape audit"
git push
```

---

## Subagent Audit Template

Use this after Phase 4, Phase 5, and Phase 6:

```text
You are a read-only Codex audit subagent for MAformac.

Repo: /Users/wanglei/workspace/MAformac
Phase: <Phase 4 | Phase 5 | Phase 6>
Read only. Do not edit files.

Audit question:
Does this phase advance rebuild-C6 identity + shape closeout without violating construction-lane boundaries?

Must check:
- no retrain-C5, C6 acceptance, D-domain base recalibration, §4 candidate comparison, model eval, golden-run, voice, endpoint, UIUE merge, V/S/U-PASS
- contract bundle fingerprint is a component manifest and preserves per-run identity fields
- C6 JSONL rows have explicit behavior_class and no direct_no_call
- shape checks are source-free and branch-trackable
- UIUE impact scan is done when C6 JSONL changes
- evidence excerpt is tracked, not only Reports scratch
- pre-mortem and lessons are recorded

Return:
- status: PASS / PASS_WITH_FIXES / FAIL / BLOCKED
- P0/P1/P2 findings with file:line anchors
- evidence table
- residual risk
- touched paths
```

No inline-only execution mode is approved. If subagent audit cannot run, stop and report `BLOCKED: missing phase audit lane`.

---

## Commit Strategy

Suggested commits:

1. `docs(rebuild-c6): add identity shape closeout plan`
2. `feat(c6): add contract bundle fingerprint`
3. `feat(c6): migrate bench cases to explicit behavior shape`
4. `docs(rebuild-c6): close identity shape local pass`
5. `docs(rebuild-c6): request GPT Pro identity shape audit`
6. `fix(rebuild-c6): absorb GPT Pro identity shape audit`

GPT-5.5 may split commits further for clarity, but must not squash phases together.
