---
status: active_plan_audit_absorbed
artifact_kind: superpowers_implementation_plan
authority: implementation_plan_not_ssot
baseline_status: apply_authorized_after_phase_minus_one_closeout
retire_trigger: "Retire after default-scope apply closeout receipt records all three mechanical gates passing or this plan is superseded by a newer accepted apply plan."
expires: "2026-07-15"
---

# Default Scope Apply Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply the accepted `define-demo-default-scope` contract into C2, C3, state application, readback metadata, C5 candidate rendering, C6 gold cases, and tests without starting training, model-quality evaluation, golden-run execution, voice work, or UIUE merge.

**Architecture:** C2 owns `default_scope` as the only authority for omitted target scope. C3 resolves omitted, explicit, and fan-out targets once, emits a typed `ScopeOrigin`, and downstream state application, readback, C5, C6, and presentation evidence consume that source instead of recomputing scope policy. Three mechanical gates close the apply: `default_scope` SSOT, C5/C2 scope parity, and ScopeOrigin single-source.

**Tech Stack:** Swift, XCTest, YAML contracts, Python stdlib plus existing PyYAML/jsonschema dependencies, Makefile, OpenSpec.

---

## Same-Vendor Audit Absorption

Codex same-vendor pre-check verdict: `CLEAR_WITH_FIXES`. This plan absorbs those fixes before implementation. The audit does **not** close R-L17; it only hardens this implementation plan against fake-green execution.

Absorbed fixes:

- Gate B now has a physical C5/C2 parity script and Makefile hook; it is not only a prose gate.
- `ScopeOrigin` external vocabulary is aligned to the OpenSpec carrier: `defaulted`, `explicit`, `fanout`.
- C5 omitted-scope targets must omit executable scope arguments; explicit-scope targets must derive candidates from C2.
- Legacy unscoped UI keys have an explicit disposition task instead of being left as "compatibility" prose.
- C6 JSONL must be regenerated from Swift source plus trap append workflow, not hand-edited row-by-row.
- Receipt evidence must record actual command outputs, paths, hashes, and exit codes; hardcoded pass receipts are forbidden.
- `contracts/demo-scenarios.yaml` and `contracts/l1-demo-allowlist.yaml` must be included or explicitly deferred in the closeout receipt.

## Scope Boundaries

This plan is for apply implementation after `define-demo-default-scope` is human-accepted. It is not permission to train LoRA, run real model-quality evaluation, execute demo-golden-run, claim endpoint readiness, run voice, or merge UIUE.

The plan treats `docs/CURRENT.md` as a router only. It receives one small route update during apply and must not become a progress ledger, receipt store, or second SSOT.

`make receipt` stays a schema draft in this apply. The implementation creates a receipt schema and, at closeout, writes a manual receipt conforming to that schema. The `make receipt` target and `scripts/write_local_receipt.py` are created only after this apply proves the evidence shape is right.

## Pre-Apply Conditions

The executor must check these before touching implementation files:

- `openspec validate define-demo-default-scope --strict` passes.
- The stale UIUE reference fix is already accepted or committed: `external_reference_unverified_current_head=17f2af1`.
- The D2 route-matrix mismatch is resolved in the carrier: task 1.6 says five routes, so design/spec must cover fast, slow, ambiguous, rejected, and passthrough.
- `define-demo-default-scope` is accepted for apply by the human owner.
- R-L17 remains open unless separately closed. This apply may produce evidence for later review, but it must not claim R-L17 pass.

## Mechanical Gates

### Gate A: `default_scope` SSOT

After implementation, a mechanical check must fail closed when omitted-scope target resolution or state application still defaults through:

- `scope.first`
- `?? "全车"`
- `?? "all"`

The gate must allow explicit fan-out strings such as `全车` when they come from accepted collection aliases. It must also validate that every scoped C2 demo-execution cell has `default_scope`, and that `default_scope` is a member of `scope`.

### Gate B: C5/C2 Scope Parity

C5 fallback slot candidates and rendered tool-call scope arguments must derive from C2 `scope` and `default_scope`. C5 must not own a second scope vocabulary. Raw/source synonyms such as `左前` are allowed only as input variants when canonicalized before target rendering; executable rendered scope values must match C2 scopes such as `主驾`, `副驾`, `左后`, `右后`, `全车`.

### Gate C: ScopeOrigin Single-Source

Target resolution must emit one typed source of truth:

```swift
public enum ScopeOrigin: String, Equatable, Sendable {
    case defaulted
    case explicit
    case fanout
}
```

Readback, TTS/readback policy, verifier evidence, trace output, C6 verification, and UIUE handoff metadata must consume this type or an equivalent closed type. They must not infer defaulted scope by string-matching `主驾`, `全车`, or rendered text.

## File Structure

| Path | Role |
|---|---|
| `docs/CURRENT.md` | Small route update only: active apply plan pointer and no new SSOT content. |
| `docs/project/receipts/local-receipt.schema.json` | Draft schema for closeout receipts. No `make receipt` target in this apply. |
| `openspec/changes/define-demo-default-scope/{design.md,tasks.md,specs/tool-execution/spec.md}` | Carrier D2 route-matrix self-consistency before implementation. |
| `contracts/state-cells.yaml` | Adds `default_scope` to scoped demo-execution cells. |
| `scripts/verify_refs.py` | Extends existing C2 validation for `default_scope`. |
| `scripts/check_default_scope_ssot.py` | Mechanical Gate A for forbidden omitted-scope fallbacks plus C2 default-scope membership. |
| `scripts/check_c5_c2_scope_parity.py` | Mechanical Gate B for C5 executable scope vocabulary and omitted-scope target rendering. |
| `scripts/check_scope_origin_single_source.py` | Mechanical Gate C for typed `ScopeOrigin` source and forbidden recomputation patterns. |
| `Makefile` | Adds `verify-default-scope`; does not add `make receipt`. |
| `Core/Contracts/ContractLookups.swift` | Parses `default_scope`, renders readback with `ScopeOrigin`, exposes C2 scope metadata. |
| `Core/Execution/ScopeResolution.swift` | New focused resolver for omitted, explicit, fan-out, and rejected scope targets. |
| `Core/Execution/C3ExecutionPipeline.swift` | Consumes `ScopeResolution`; stops using `?? "全车"`; passes origin into readback. |
| `Core/Contracts/ToolContractCompiler.swift` | State applier consumes C2 `default_scope`; stops using `scope.first` and `?? "all"`. |
| `Core/State/DemoVehicleStateStore.swift` | Carries `scopeOrigin` in `DemoActionReadback`; keeps legacy cells as compatibility only. |
| `App/ContentView.swift` | Consumes scoped state keys or an explicit compatibility adapter; it must not silently prefer legacy unscoped keys after `default_scope`. |
| `Core/Training/C5LoRATraining.swift` | Derives fallback scope candidates from C2 instead of a hardcoded list. |
| `Core/Bench/C6VehicleToolBench.swift` | Updates C6-MP default-scope gold for omitted vs explicit vs fan-out. |
| `contracts/demo-scenarios.yaml` | Include or explicitly defer default-scope scenario updates in the receipt. |
| `contracts/l1-demo-allowlist.yaml` | Include or explicitly defer default-scope allowlist updates in the receipt. |
| `Tests/MAformacCoreTests/*` | Adds red tests and closeout tests for C2, C3, state applier, readback, C5, C6, and gates. |
| `Reports/default-scope-apply-<timestamp>/receipt.json` | Manual closeout receipt matching the schema after all gates pass. |

---

## Task 0: Pre-Apply Router, Receipt Schema, and Carrier Self-Consistency

**Files:**
- Modify: `docs/CURRENT.md`
- Create: `docs/project/receipts/local-receipt.schema.json`
- Modify: `openspec/changes/define-demo-default-scope/design.md`
- Modify: `openspec/changes/define-demo-default-scope/tasks.md`
- Modify: `openspec/changes/define-demo-default-scope/specs/tool-execution/spec.md`

- [ ] **Step 0.1: Confirm the working tree before implementation**

Run:

```bash
git status --short --branch
openspec validate define-demo-default-scope --strict
openspec validate --all --strict
```

Expected: branch is `main`; OpenSpec validation passes. Existing D1/UIUE-head edits may be present and must be understood before staging.

- [ ] **Step 0.2: Keep `docs/CURRENT.md` as a small router**

Add only this short row to `docs/CURRENT.md` under `## Do Now`:

```markdown
5. If `define-demo-default-scope` is accepted, execute `docs/superpowers/plans/2026-06-24-default-scope-apply.md`; keep this route board router-only and put evidence in receipts, tests, and OpenSpec closeout files.
```

Do not add implementation logs, command transcripts, or gate results to `docs/CURRENT.md`.

- [ ] **Step 0.3: Create the receipt schema draft**

Create `docs/project/receipts/local-receipt.schema.json`:

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://maformac.local/schemas/local-receipt.schema.json",
  "title": "MAformac Local Receipt",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "receipt_id",
    "created_at",
    "change_id",
    "proof_class",
    "base_commit",
    "head_commit",
    "dirty_worktree",
    "commands",
    "mechanical_gates",
    "claim_boundaries"
  ],
  "properties": {
    "receipt_id": { "type": "string", "minLength": 1 },
    "created_at": { "type": "string", "format": "date-time" },
    "change_id": { "type": "string", "minLength": 1 },
    "proof_class": {
      "type": "string",
      "enum": ["openspec_apply_local", "local_tests_only", "manual_review_evidence"]
    },
    "base_commit": { "type": "string", "pattern": "^[0-9a-f]{7,40}$" },
    "head_commit": { "type": "string", "pattern": "^[0-9a-f]{7,40}$" },
    "dirty_worktree": { "type": "boolean" },
    "commands": {
      "type": "array",
      "minItems": 1,
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": ["cmd", "exit_code", "verdict", "evidence_path", "sha256"],
        "properties": {
          "cmd": { "type": "string", "minLength": 1 },
          "exit_code": { "type": "integer" },
          "verdict": { "type": "string", "enum": ["pass", "fail", "blocked"] },
          "evidence_path": { "type": "string", "minLength": 1 },
          "sha256": { "type": "string", "pattern": "^[0-9a-f]{64}$" },
          "notes": { "type": "string" }
        }
      }
    },
    "mechanical_gates": {
      "type": "object",
      "additionalProperties": false,
      "required": ["default_scope_ssot", "c5_c2_parity", "scope_origin_single_source"],
      "properties": {
        "default_scope_ssot": { "type": "string", "enum": ["pass", "fail", "blocked"] },
        "c5_c2_parity": { "type": "string", "enum": ["pass", "fail", "blocked"] },
        "scope_origin_single_source": { "type": "string", "enum": ["pass", "fail", "blocked"] }
      }
    },
    "claim_boundaries": {
      "type": "array",
      "items": { "type": "string" },
      "contains": { "const": "no_training_no_c6_acceptance_no_golden_no_voice_no_uiue_merge" }
    }
  }
}
```

- [ ] **Step 0.4: Confirm D2 route matrix is already five states**

Do not rewrite AD-DS-009 unless validation shows drift. Confirm the existing carrier already covers:

```bash
rg -n "fast \\| accepted deterministic|slow \\| accepted Qwen|ambiguous \\| candidate not accepted|rejected \\| safety|passthrough \\| non-state" openspec/changes/define-demo-default-scope/design.md
rg -n "Rejected route does not default omitted scope|Passthrough route does not create scope metadata" openspec/changes/define-demo-default-scope/specs/tool-execution/spec.md
```

Expected: both grep checks find the five-route matrix and the rejected/passthrough scenarios. If either check fails, stop and repair the carrier before implementation.

This step is currently expected to pass because Phase -1 closeout already landed the D2 rejected/passthrough repair.

- [ ] **Step 0.5: Validate and commit Task 0**

Run:

```bash
openspec validate define-demo-default-scope --strict
openspec validate --all --strict
git diff --check
```

Expected: all pass.

Commit:

```bash
git add docs/CURRENT.md docs/project/receipts/local-receipt.schema.json openspec/changes/define-demo-default-scope
git commit -m "docs(default-scope): prepare apply gates and receipt schema"
```

---

## Task 1: C2 `default_scope` Contract Tests

**Files:**
- Modify: `Tests/MAformacCoreTests/C3ContractLookupTests.swift`
- Modify: `scripts/verify_refs.py`

- [ ] **Step 1.1: Add failing Swift tests for C2 default scopes**

Append these tests to `Tests/MAformacCoreTests/C3ContractLookupTests.swift`:

```swift
func testScopedStateCellsExposeDefaultScopeFromC2() throws {
    let lookup = try StateCellContractLookup(yaml: readRepoFile("contracts/state-cells.yaml"))

    XCTAssertEqual(lookup.cell(id: "ac.temp_setpoint")?.defaultScope, "主驾")
    XCTAssertEqual(lookup.cell(id: "ac.fan_speed")?.defaultScope, "主驾")
    XCTAssertEqual(lookup.cell(id: "window.position")?.defaultScope, "主驾")
    XCTAssertEqual(lookup.cell(id: "screen.brightness")?.defaultScope, "中控屏")
    XCTAssertEqual(lookup.cell(id: "ambient.brightness")?.defaultScope, "面发光氛围灯")
    XCTAssertEqual(lookup.cell(id: "seat.heat_level")?.defaultScope, "主驾")
    XCTAssertEqual(lookup.cell(id: "seat.vent_level")?.defaultScope, "主驾")
    XCTAssertEqual(lookup.cell(id: "seat.backrest_angle")?.defaultScope, "主驾")
    XCTAssertEqual(lookup.cell(id: "wiper.speed")?.defaultScope, "前")
    XCTAssertEqual(lookup.cell(id: "sunroof.position")?.defaultScope, "前排")
    XCTAssertEqual(lookup.cell(id: "sunshade.position")?.defaultScope, "前排")
}

func testDefaultScopeMustBeInsideScope() throws {
    let yaml = """
    meta:
      source_kind_enum: [c2_demo_decision]
      state_kinds_vocab: [stable]
      c1_c2_closure: {status: deferred}
    devices:
      window:
        state_cells:
          - id: window.position
            type: int
            source_kind: c2_demo_decision
            state_kinds: [stable]
            scope: [主驾, 副驾]
            default_scope: 左后
            execution_range: {min: 0, max: 100, step: 1}
    """

    let lookup = try StateCellContractLookup(yaml: yaml)
    let cell = try XCTUnwrap(lookup.cell(id: "window.position"))
    XCTAssertFalse(cell.scope.contains(cell.defaultScope ?? ""))
}
```

Expected before implementation: compile fails because `defaultScope` does not exist.

- [ ] **Step 1.2: Add failing Python validation in `verify_refs.py`**

In `scripts/verify_refs.py`, inside `check_cell`, add the validation after the `state_kinds` block:

```python
        scope = cell.get("scope") or []
        default_scope = cell.get("default_scope")
        if scope:
            if not isinstance(default_scope, str) or not default_scope:
                raise C1Error(f"state-cells: scoped cell {cid} missing default_scope")
            if default_scope not in scope:
                raise C1Error(f"state-cells: {cid} default_scope {default_scope!r} not in scope {scope!r}")
        elif "default_scope" in cell:
            raise C1Error(f"state-cells: unscoped cell {cid} must not declare default_scope")
```

- [ ] **Step 1.3: Run tests to verify failure**

Run:

```bash
swift test --filter C3ContractLookupTests
.venv/bin/python scripts/verify_refs.py
```

Expected: Swift fails on missing `defaultScope`; Python fails until YAML contains `default_scope`.

---

## Task 2: C2 `default_scope` Implementation

**Files:**
- Modify: `contracts/state-cells.yaml`
- Modify: `Core/Contracts/ContractLookups.swift`
- Modify: `scripts/verify_refs.py`
- Test: `Tests/MAformacCoreTests/C3ContractLookupTests.swift`

- [ ] **Step 2.1: Add `defaultScope` to `StateCellDefinition`**

In `Core/Contracts/ContractLookups.swift`, update `StateCellDefinition`:

```swift
public struct StateCellDefinition: Equatable, Sendable {
    public var id: String
    public var type: String
    public var unit: String?
    public var values: [String]
    public var scope: [String]
    public var defaultScope: String?
    public var executionRange: ExecutionRange?
    public var expStepLittle: Int?
    public var gearMap: [String: Int]
    public var extremeMap: [String: Int]
    public var readbackTemplate: String?
    public var defaultValue: String?
    public var dependsOn: [String]

    public init(
        id: String,
        type: String = "",
        unit: String? = nil,
        values: [String] = [],
        scope: [String] = [],
        defaultScope: String? = nil,
        executionRange: ExecutionRange? = nil,
        expStepLittle: Int? = nil,
        gearMap: [String: Int] = [:],
        extremeMap: [String: Int] = [:],
        readbackTemplate: String? = nil,
        defaultValue: String? = nil,
        dependsOn: [String] = []
    ) {
        self.id = id
        self.type = type
        self.unit = unit
        self.values = values
        self.scope = scope
        self.defaultScope = defaultScope
        self.executionRange = executionRange
        self.expStepLittle = expStepLittle
        self.gearMap = gearMap
        self.extremeMap = extremeMap
        self.readbackTemplate = readbackTemplate
        self.defaultValue = defaultValue
        self.dependsOn = dependsOn
    }
}
```

- [ ] **Step 2.2: Parse `default_scope`**

In `parseCells(yaml:)`, after the `scope:` branch, add:

```swift
            } else if trimmed.hasPrefix("default_scope: ") {
                current?.defaultScope = cleanValue(String(trimmed.dropFirst("default_scope: ".count)))
```

- [ ] **Step 2.3: Add `default_scope` to C2 scoped cells**

In `contracts/state-cells.yaml`, add these fields under the existing scoped cells:

```yaml
        default_scope: 主驾
```

for:

- `ac.temp_setpoint`
- `ac.fan_speed`
- `window.position`
- `seat.heat_level`
- `seat.vent_level`
- `seat.backrest_angle`

Add:

```yaml
        default_scope: 中控屏
```

for `screen.brightness`.

Add:

```yaml
        default_scope: 面发光氛围灯
```

for `ambient.brightness`.

Add:

```yaml
        default_scope: 前
```

for `wiper.speed`.

Add:

```yaml
        default_scope: 前排
```

for:

- `sunroof.position`
- `sunshade.position`

- [ ] **Step 2.4: Run C2 validation**

Run:

```bash
swift test --filter C3ContractLookupTests
.venv/bin/python scripts/verify_refs.py
```

Expected: both pass.

- [ ] **Step 2.5: Commit C2 default-scope contract**

```bash
git add contracts/state-cells.yaml Core/Contracts/ContractLookups.swift scripts/verify_refs.py Tests/MAformacCoreTests/C3ContractLookupTests.swift
git commit -m "feat(c2): add default scope to state cells"
```

---

## Task 3: Shared Scope Resolution and ScopeOrigin

**Files:**
- Create: `Core/Execution/ScopeResolution.swift`
- Modify: `Tests/MAformacCoreTests/C3ExecutionPipelineTests.swift`
- Modify: `Tests/MAformacCoreTests/ToolContractCompilerTests.swift`

- [ ] **Step 3.1: Add failing resolver tests**

Add these tests to `Tests/MAformacCoreTests/C3ExecutionPipelineTests.swift`:

```swift
func testOmittedWindowScopeResolvesToC2DefaultScope() throws {
    let pipeline = try makePipeline(intentConfirmed: true)
    let cell = try XCTUnwrap(pipeline.stateCells.cell(id: "window.position"))
    let frame = ToolCallFrame.fixture(device: "window", actionPrimitive: "power_on", stateRevision: 0)

    let resolution = try C2ScopeResolver.resolve(frame: frame, cell: cell)

    XCTAssertEqual(resolution.origin, .defaulted)
    XCTAssertEqual(resolution.keys, ["window.position[主驾]"])
    XCTAssertEqual(resolution.resolvedScopes, ["主驾"])
}

func testExplicitAllWindowScopeFansOut() throws {
    let pipeline = try makePipeline(intentConfirmed: true)
    let cell = try XCTUnwrap(pipeline.stateCells.cell(id: "window.position"))
    let frame = ToolCallFrame.fixture(device: "window", actionPrimitive: "power_on", slots: ["position": "全车"], stateRevision: 0)

    let resolution = try C2ScopeResolver.resolve(frame: frame, cell: cell)

    XCTAssertEqual(resolution.origin, .fanout)
    XCTAssertEqual(Set(resolution.keys), Set([
        "window.position[主驾]",
        "window.position[副驾]",
        "window.position[左后]",
        "window.position[右后]"
    ]))
}

func testExplicitDriverScopeRemainsExplicit() throws {
    let pipeline = try makePipeline(intentConfirmed: true)
    let cell = try XCTUnwrap(pipeline.stateCells.cell(id: "window.position"))
    let frame = ToolCallFrame.fixture(device: "window", actionPrimitive: "power_on", slots: ["position": "主驾"], stateRevision: 0)

    let resolution = try C2ScopeResolver.resolve(frame: frame, cell: cell)

    XCTAssertEqual(resolution.origin, .explicit)
    XCTAssertEqual(resolution.keys, ["window.position[主驾]"])
}
```

Expected before implementation: compile fails because `C2ScopeResolver`, `ScopeOrigin`, and `ScopeResolution` do not exist.

- [ ] **Step 3.2: Create the shared resolver**

Create `Core/Execution/ScopeResolution.swift`:

```swift
import Foundation

public enum ScopeOrigin: String, Equatable, Sendable {
    case defaulted
    case explicit
    case fanout
}

public struct ScopeResolution: Equatable, Sendable {
    public var keys: [String]
    public var resolvedScopes: [String]
    public var origin: ScopeOrigin

    public init(keys: [String], resolvedScopes: [String], origin: ScopeOrigin) {
        self.keys = keys
        self.resolvedScopes = resolvedScopes
        self.origin = origin
    }
}

public enum C2ScopeResolver {
    public static func resolve(frame: ToolCallFrame, cell: StateCellDefinition) throws -> ScopeResolution {
        guard !cell.scope.isEmpty else {
            return ScopeResolution(keys: [cell.id], resolvedScopes: [], origin: .explicit)
        }

        if let requested = requestedScope(from: frame), !requested.isEmpty {
            if isCollectionAlias(requested, cell: cell) {
                let scopes = executableScopes(for: cell)
                return ScopeResolution(
                    keys: scopes.map { scopedKey(cell.id, scope: $0) },
                    resolvedScopes: scopes,
                    origin: .fanout
                )
            }
            guard cell.scope.contains(requested) else {
                throw ToolExecutionError.semanticInvalid("slot_out_of_scope")
            }
            return ScopeResolution(
                keys: [scopedKey(cell.id, scope: requested)],
                resolvedScopes: [requested],
                origin: .explicit
            )
        }

        guard let defaultScope = cell.defaultScope, cell.scope.contains(defaultScope) else {
            throw ToolExecutionError.semanticInvalid("missing_default_scope")
        }
        return ScopeResolution(
            keys: [scopedKey(cell.id, scope: defaultScope)],
            resolvedScopes: [defaultScope],
            origin: .defaulted
        )
    }

    public static func requestedScope(from frame: ToolCallFrame) -> String? {
        frame.slots["direction"]
            ?? frame.slots["position"]
            ?? frame.slots["screen_type"]
            ?? frame.slots["name"]
    }

    private static func isCollectionAlias(_ value: String, cell: StateCellDefinition) -> Bool {
        if value == "全车" && cell.scope.contains("全车") {
            return true
        }
        if cell.id == "window.position" {
            return ["所有车窗", "四个车窗", "车窗都"].contains(value)
        }
        return false
    }

    private static func executableScopes(for cell: StateCellDefinition) -> [String] {
        cell.scope.filter { scope in
            scope != "全车" && !scope.hasSuffix("屏") && !scope.hasSuffix("氛围灯")
        }
    }

    private static func scopedKey(_ cellID: String, scope: String) -> String {
        "\(cellID)[\(scope)]"
    }
}
```

- [ ] **Step 3.3: Run resolver tests**

Run:

```bash
swift test --filter C3ExecutionPipelineTests
```

Expected: resolver tests pass or fail only because C3 still uses its private target function. That private C3 usage is fixed in Task 4.

---

## Task 4: C3 Execution Uses Shared Resolution

**Files:**
- Modify: `Core/Execution/C3ExecutionPipeline.swift`
- Modify: `Core/State/DemoVehicleStateStore.swift`
- Modify: `Tests/MAformacCoreTests/C3ExecutionPipelineTests.swift`

- [ ] **Step 4.1: Add `scopeOrigin` to readbacks**

In `Core/State/DemoVehicleStateStore.swift`, update `DemoActionReadback`:

```swift
public struct DemoActionReadback: Equatable, Sendable {
    public var key: String
    public var actualValue: String
    public var revision: Int
    public var spokenText: String
    public var scopeOrigin: ScopeOrigin?

    public init(
        key: String,
        actualValue: String,
        revision: Int,
        spokenText: String,
        scopeOrigin: ScopeOrigin? = nil
    ) {
        self.key = key
        self.actualValue = actualValue
        self.revision = revision
        self.spokenText = spokenText
        self.scopeOrigin = scopeOrigin
    }
}
```

The existing `applyMockTransition` initializer remains valid because `scopeOrigin` defaults to nil.

- [ ] **Step 4.2: Replace C3 private target resolution**

In `Core/Execution/C3ExecutionPipeline.swift`, change `planTransitions` to carry origins:

```swift
private struct PlannedTransition: Equatable {
    var transition: DemoMockTransition
    var scopeOrigin: ScopeOrigin?
}
```

Replace `planTransitions(for:store:)` with:

```swift
@MainActor
private func planTransitions(for frame: ToolCallFrame, store: DemoVehicleStateStore) throws -> [PlannedTransition] {
    guard let cellID = executionCellID(for: frame) else {
        throw ToolExecutionError.semanticInvalid("no_execution_cell")
    }
    guard let cell = stateCells.cell(id: cellID) else {
        throw ToolExecutionError.semanticInvalid("missing_c2_cell:\(cellID)")
    }

    var transitions: [PlannedTransition] = []
    if frame.device == "ac_temperature",
       frame.actionPrimitive != "query",
       store.cell(for: "ac.power")?.actualValue != "on" {
        transitions.append(PlannedTransition(
            transition: DemoMockTransition(key: "ac.power", desiredValue: "on"),
            scopeOrigin: nil
        ))
    }

    let resolution = try C2ScopeResolver.resolve(frame: frame, cell: cell)
    for key in resolution.keys {
        let desiredValue = try normalizeValue(frame: frame, cell: cell, key: key, store: store)
        transitions.append(PlannedTransition(
            transition: DemoMockTransition(key: key, desiredValue: desiredValue),
            scopeOrigin: resolution.origin
        ))
    }
    return transitions
}
```

Update the execution loop:

```swift
for planned in transitions {
    let transition = planned.transition
    let applied = store.applyMockTransition(transition)
    traceLogger.recordExecute(traceID: frame.traceID, message: "\(applied.key)=\(applied.actualValue)")
    var verified = try C2ReadbackVerifier.verify(store: store, key: transition.key, expectedValue: transition.desiredValue)
    verified.scopeOrigin = planned.scopeOrigin
    if let rendered = stateCells.renderReadback(
        stateKey: transition.key,
        scope: scope(forKey: transition.key),
        value: verified.actualValue,
        scopeOrigin: planned.scopeOrigin
    ) {
        verified.spokenText = rendered
    }
    traceLogger.recordReadback(
        traceID: frame.traceID,
        message: verified.spokenText,
        attributes: TraceAttributes(readbackResult: .verified)
    )
    readbacks.append(verified)
}
```

Update `recordPlan` to use:

```swift
traceLogger.recordPlan(
    traceID: frame.traceID,
    message: transitions.map { "\($0.transition.key)=\($0.transition.desiredValue)" }.joined(separator: ",")
)
```

Remove the private `targetKeys(for:cell:)` and `scopedKey(_:scope:)` methods from `C3ExecutionPipeline.swift`.

- [ ] **Step 4.3: Run C3 tests**

Run:

```bash
swift test --filter C3ExecutionPipelineTests
```

Expected: C3 tests pass, and omitted `打开车窗` resolves to `window.position[主驾]` with `scopeOrigin == .defaulted`.

- [ ] **Step 4.4: Commit C3 target resolution**

```bash
git add Core/Execution/ScopeResolution.swift Core/Execution/C3ExecutionPipeline.swift Core/State/DemoVehicleStateStore.swift Tests/MAformacCoreTests/C3ExecutionPipelineTests.swift
git commit -m "feat(c3): resolve omitted scope from c2 default scope"
```

---

## Task 5: State Applier Uses C2 Resolution

**Files:**
- Modify: `Core/Contracts/ToolContractCompiler.swift`
- Modify: `Tests/MAformacCoreTests/ToolContractCompilerTests.swift`

- [ ] **Step 5.1: Add failing state-applier tests**

Add these tests to `Tests/MAformacCoreTests/ToolContractCompilerTests.swift`:

```swift
func testStateApplierUsesC2DefaultScopeForOmittedWindow() throws {
    let stateCells = try StateCellContractLookup(yaml: readRepoFile("contracts/state-cells.yaml"))
    let irMap = try ToolContractNormalizer.loadIRMap(repoRoot: repoRoot())
    let preState: [String: String] = [
        "window.position[主驾]": "0",
        "window.position[副驾]": "0",
        "window.position[左后]": "0",
        "window.position[右后]": "0"
    ]

    let state = ToolContractStateApplier.apply(
        toolCalls: [C6ToolCall(name: "open_window", arguments: [:])],
        to: preState,
        stateCells: stateCells,
        irMap: irMap
    )

    XCTAssertEqual(state["window.position[主驾]"], "100")
    XCTAssertEqual(state["window.position[副驾]"], "0")
    XCTAssertEqual(state["window.position[左后]"], "0")
    XCTAssertEqual(state["window.position[右后]"], "0")
}

func testStateApplierFansOutOnlyForExplicitCollectionAlias() throws {
    let stateCells = try StateCellContractLookup(yaml: readRepoFile("contracts/state-cells.yaml"))
    let irMap = try ToolContractNormalizer.loadIRMap(repoRoot: repoRoot())
    let preState: [String: String] = [
        "window.position[主驾]": "0",
        "window.position[副驾]": "0",
        "window.position[左后]": "0",
        "window.position[右后]": "0"
    ]

    let state = ToolContractStateApplier.apply(
        toolCalls: [C6ToolCall(name: "open_window", arguments: ["position": "全车"])],
        to: preState,
        stateCells: stateCells,
        irMap: irMap
    )

    XCTAssertEqual(state["window.position[主驾]"], "100")
    XCTAssertEqual(state["window.position[副驾]"], "100")
    XCTAssertEqual(state["window.position[左后]"], "100")
    XCTAssertEqual(state["window.position[右后]"], "100")
}
```

Expected before implementation: omitted window still fans out because of `?? "all"`.

- [ ] **Step 5.2: Replace state-applier defaulting**

In `Core/Contracts/ToolContractCompiler.swift`, replace the body of `applyNumericCell` with:

```swift
private static func applyNumericCell(
    _ ir: ToolContractIR, cellID: String, cell: StateCellDefinition, state: inout [String: String]
) {
    let resolutionFrame = ToolCallFrame(
        traceID: "state-applier",
        agentID: "vehicle-control",
        capabilityID: "cabin.\(ir.device)",
        toolName: "vehicle_control",
        device: ir.device,
        actionPrimitive: ir.actionPrimitive,
        slots: ir.slots,
        value: ir.value,
        stateRevision: 0,
        candidateSource: .upstreamToolCall
    )
    let resolution = (try? C2ScopeResolver.resolve(frame: resolutionFrame, cell: cell))
        ?? ScopeResolution(keys: [cellID], resolvedScopes: [], origin: .explicit)
    let currentKey = resolution.keys.first ?? cellID
    let writeKeys = resolution.keys
    let initial = Int(cell.defaultValue ?? "") ?? 0
    let newValue: String?
    if let target = targetNumber(ir) {
        if let targetInt = Int(target), cell.executionRange != nil {
            newValue = String(clampLower(clampUpper(targetInt, cell.executionRange), cell.executionRange))
        } else {
            newValue = target
        }
    } else if isOff(ir.actionPrimitive, value: ir.value) {
        newValue = String(cell.executionRange?.min ?? 0)
    } else if ir.actionPrimitive == "increase_by_exp" {
        let current = Int(state[currentKey] ?? "") ?? initial
        newValue = String(clampUpper(current + (cell.expStepLittle ?? 0), cell.executionRange))
    } else if ir.actionPrimitive == "decrease_by_exp" {
        let current = Int(state[currentKey] ?? "") ?? initial
        newValue = String(clampLower(current - (cell.expStepLittle ?? 0), cell.executionRange))
    } else if ir.device == "window" {
        newValue = String(cell.executionRange?.max ?? 100)
    } else {
        newValue = nil
    }
    guard let value = newValue else { return }
    for key in writeKeys {
        state[key] = value
    }
    for dependency in cell.dependsOn {
        state[dependency] = "on"
    }
}
```

Delete `windowKeys(for:)`. No state-applier path may default through `all`.

- [ ] **Step 5.3: Preserve omitted window in the normalizer**

In `Core/Contracts/ToolContractCompiler.swift`, replace:

```swift
var slots = call.arguments
if slots["position"] == nil {
    slots["position"] = "all"
}
```

with:

```swift
let slots = call.arguments
```

This makes omitted tool-call scope remain omitted until `C2ScopeResolver` applies C2 `default_scope`.

- [ ] **Step 5.4: Run state-applier tests**

Run:

```bash
swift test --filter ToolContractCompilerTests
```

Expected: tests pass.

- [ ] **Step 5.5: Commit state-applier resolution**

```bash
git add Core/Contracts/ToolContractCompiler.swift Tests/MAformacCoreTests/ToolContractCompilerTests.swift
git commit -m "feat(state): apply omitted scope from c2 defaults"
```

---

## Task 6: Readback ScopeOrigin Policy

**Files:**
- Modify: `Core/Contracts/ContractLookups.swift`
- Modify: `Tests/MAformacCoreTests/C3ReadbackTemplateTests.swift`

- [ ] **Step 6.1: Preserve explicit-scope readback tests and add omitted-scope tests**

Keep the existing explicit tests:

- `testTemperatureReadbackUsesC2TemplateWithScopeAndValue`
- `testWindowReadbackUsesC2PercentTemplate`

Add this omitted-scope test:

```swift
@MainActor
func testOmittedWindowReadbackElidesDefaultDriverScopeButCarriesOrigin() throws {
    let pipeline = try makePipeline()
    let store = DemoVehicleStateStore()
    let frame = ToolCallFrame.fixture(
        device: "window",
        actionPrimitive: "power_on",
        value: ContractValue(),
        stateRevision: 0
    )

    let result = try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())
    let readback = try XCTUnwrap(result.readbacks.first { $0.key == "window.position[主驾]" })

    XCTAssertEqual(readback.scopeOrigin, .defaulted)
    XCTAssertEqual(readback.spokenText, "车窗开度100%")
}

@MainActor
func testExplicitDriverWindowReadbackKeepsDriverTextAndOrigin() throws {
    let pipeline = try makePipeline()
    let store = DemoVehicleStateStore()
    let frame = ToolCallFrame.fixture(
        device: "window",
        actionPrimitive: "power_on",
        slots: ["position": "主驾"],
        value: ContractValue(),
        stateRevision: 0
    )

    let result = try pipeline.execute(frame, store: store, traceLogger: InMemoryTraceLogger())
    let readback = try XCTUnwrap(result.readbacks.first { $0.key == "window.position[主驾]" })

    XCTAssertEqual(readback.scopeOrigin, .explicit)
    XCTAssertEqual(readback.spokenText, "主驾车窗开度100%")
}
```

- [ ] **Step 6.2: Update readback renderer signature**

In `Core/Contracts/ContractLookups.swift`, replace `renderReadback(stateKey:scope:value:)` with:

```swift
public func renderReadback(stateKey: String, scope: String?, value: String, scopeOrigin: ScopeOrigin? = nil) -> String? {
    let baseID = stateKey.contains("[") ? String(stateKey.prefix(while: { $0 != "[" })) : stateKey
    guard let cell = cellsByID[baseID], let template = cell.readbackTemplate else {
        return nil
    }
    var result = template
    let renderedScope = shouldElide(scope: scope, origin: scopeOrigin, cell: cell) ? "" : (scope ?? "")
    for placeholder in ["{温区}", "{位置}", "{屏幕}", "{氛围灯}", "{区域}", "{位}"] {
        result = result.replacingOccurrences(of: placeholder, with: renderedScope)
    }
    result = result.replacingOccurrences(of: "{值}", with: value)
    result = result.replacingOccurrences(of: "空调温度", with: "空调温度")
    result = result.replacingOccurrences(of: "车窗开度", with: "车窗开度")
    result = Self.resolveEnumBranch(result, value: value, values: cell.values)
    return result.trimmingCharacters(in: .whitespacesAndNewlines)
}

private func shouldElide(scope: String?, origin: ScopeOrigin?, cell: StateCellDefinition) -> Bool {
    origin == .defaulted && scope == cell.defaultScope
}
```

The renderer must normalize any leading whitespace created by eliding the defaulted scope inside this function. Do not change C2 YAML templates to hide renderer behavior.

- [ ] **Step 6.3: Run readback tests**

Run:

```bash
swift test --filter C3ReadbackTemplateTests
```

Expected: explicit tests still include `主驾`; omitted tests elide default driver wording and keep `scopeOrigin == .defaulted`.

- [ ] **Step 6.4: Commit readback origin policy**

```bash
git add Core/Contracts/ContractLookups.swift Tests/MAformacCoreTests/C3ReadbackTemplateTests.swift
git commit -m "feat(readback): carry scope origin from c3"
```

- [ ] **Step 6.5: Dispose legacy unscoped UI keys**

Default-scope apply must choose one of two explicit dispositions for legacy keys such as `window.driver`, `seat.driver.heat`, and `seat.driver.vent`:

- Preferred: `App/ContentView.swift` reads scoped keys such as `window.position[主驾]` and `seat.heat_level[主驾]` directly.
- Temporary compatibility: `DemoVehicleStateStore` exposes a named adapter from scoped keys to legacy display keys, and `ContentView` reads only through that adapter.

Add a test or compile-time assertion proving `ContentView` does not silently prefer legacy unscoped state over scoped C2 state after `default_scope` is applied.

Expected: legacy keys may remain as compatibility data, but their UI read path is explicit, tested, and no longer a second SSOT.

Commit:

```bash
git add App/ContentView.swift Core/State/DemoVehicleStateStore.swift Tests/MAformacCoreTests
git commit -m "fix(ui): route legacy demo keys through scoped state"
```

---

## Task 7: C5/C2 Scope Parity

**Files:**
- Modify: `Core/Training/C5LoRATraining.swift`
- Modify: `Tests/MAformacCoreTests/C5LoRATrainingTests.swift`

- [ ] **Step 7.1: Add failing C5 parity tests**

Add these tests to `Tests/MAformacCoreTests/C5LoRATrainingTests.swift`:

```swift
func testOmittedWindowTrainingTargetOmitsPositionScope() {
    let prepared = C5TrainingDatasetBuilder().build(
        seeds: [
            semanticSeed(
                id: "omitted-window-row",
                fuzzy: true,
                free: false,
                slotKeys: [],
                range: "",
                device: "window",
                actionPrimitive: "power_on"
            )
        ],
        c6Cases: [],
        dataGateContext: context(),
        options: C5TrainingBuildOptions(targetPositiveRows: 4, devSelectionRows: 0)
    )

    let rendered = prepared.samples.map(\.assistantPayload).joined(separator: "\n")
    XCTAssertFalse(rendered.contains("\"position\""))
    XCTAssertFalse(rendered.contains("左前"))
    XCTAssertFalse(rendered.contains("右前"))
    XCTAssertFalse(rendered.contains("后排"))
}

func testExplicitScopeCandidatesDeriveFromC2Vocabulary() {
    let stateCells = try! StateCellContractLookup(yaml: readRepoFile("contracts/state-cells.yaml"))
    let scopeCandidates = C5ScopeCandidateCatalog.scopeCandidatesBySlot(from: stateCells)
    let prepared = C5TrainingDatasetBuilder().build(
        seeds: [
            semanticSeed(
                id: "slot-row",
                fuzzy: true,
                free: false,
                slotKeys: ["position"],
                range: ""
            )
        ],
        c6Cases: [],
        dataGateContext: context(),
        options: C5TrainingBuildOptions(
            targetPositiveRows: 12,
            devSelectionRows: 0,
            scopeCandidatesBySlot: scopeCandidates
        )
    )

    let rendered = prepared.samples.map(\.assistantPayload).joined(separator: "\n")
    XCTAssertTrue(rendered.contains("\"position\":\"主驾\""))
    XCTAssertTrue(rendered.contains("\"position\":\"副驾\""))
    XCTAssertTrue(rendered.contains("\"position\":\"左后\""))
    XCTAssertTrue(rendered.contains("\"position\":\"右后\""))
    XCTAssertFalse(rendered.contains("\"position\":\"左前\""))
    XCTAssertFalse(rendered.contains("\"position\":\"右前\""))
    XCTAssertFalse(rendered.contains("\"position\":\"后排\""))
}
```

Expected before implementation: failure because C5 either hardcodes `左前`/`右前`/`后排` or emits scope values for omitted-scope targets.

- [ ] **Step 7.2: Add C2-derived scope candidate plumbing**

In `Core/Training/C5LoRATraining.swift`, add a public candidate catalog:

```swift
public enum C5ScopeCandidateCatalog {
    public static func scopeCandidatesBySlot(from stateCells: StateCellContractLookup) -> [String: [String]] {
        var result: [String: [String]] = [:]
        if let window = stateCells.cell(id: "window.position") {
            result["position"] = window.scope
            result["direction"] = window.scope
        }
        if let screen = stateCells.cell(id: "screen.brightness") {
            result["screen_type"] = screen.scope
        }
        if let ambient = stateCells.cell(id: "ambient.brightness") {
            result["name"] = ambient.scope
        }
        return result
    }
}
```

Add a field to `C5TrainingBuildOptions`:

```swift
public var scopeCandidatesBySlot: [String: [String]]
```

Add this initializer parameter after `dDomainCatalog`:

```swift
scopeCandidatesBySlot: [String: [String]] = [:]
```

and assign:

```swift
self.scopeCandidatesBySlot = scopeCandidatesBySlot
```

Change `slotAssignments` and `toolCallArguments` to accept `scopeCandidatesBySlot`:

```swift
public static func toolCallArguments(
    seed: C5SemanticSeed,
    value: C5ContractValue,
    slotAssignments: [String: String],
    scopeCandidatesBySlot: [String: [String]] = [:]
) -> [String: JSONValue] {
    var args: [String: JSONValue] = [
        "device": .string(seed.device),
        "action_primitive": .string(seed.actionPrimitive),
        "value.ref": .string(value.ref),
        "value.direct": .string(value.direct),
        "value.offset": .string(value.offset),
        "value.type": .string(value.type),
        "contract_row_id": .string(seed.contractRowID),
        "canonical_semantic_id": .string(seed.canonicalSemanticID)
    ]
    for key in seed.slotKeys {
        if key == "device" || key == "action_primitive" {
            continue
        }
        args[key] = .string(slotAssignments[key, default: fallbackSlotValue(
            key: key,
            seed: seed,
            variant: 0,
            scopeCandidatesBySlot: scopeCandidatesBySlot
        )])
    }
    return args
}
```

```swift
public static func slotAssignments(
    seed: C5SemanticSeed,
    variant: Int,
    value: C5ContractValue,
    scopeCandidatesBySlot: [String: [String]] = [:]
) -> [String: String] {
    var assignments: [String: String] = [:]
    let rangeMap = parseRange(seed.range)
    for key in seed.slotKeys {
        if key == "device" {
            assignments[key] = seed.device
        } else if key == "action_primitive" {
            assignments[key] = seed.actionPrimitive
        } else if let fixed = fixedSemanticSlotValue(seed.semanticSlots[key]) {
            assignments[key] = fixed
        } else if let values = rangeMap[key], !values.isEmpty {
            assignments[key] = values[variant % values.count]
        } else {
            assignments[key] = fallbackSlotValue(
                key: key,
                seed: seed,
                variant: variant,
                value: value,
                scopeCandidatesBySlot: scopeCandidatesBySlot
            )
        }
    }
    return assignments
}
```

Replace the `fallbackSlotValue` signature and first branch:

```swift
private static func fallbackSlotValue(
    key: String,
    seed: C5SemanticSeed,
    variant: Int,
    value: C5ContractValue = C5ContractValue(),
    scopeCandidatesBySlot: [String: [String]] = [:]
) -> String {
    let normalized = key.lowercased()
    let candidates: [String]
    if normalized.contains("position") || normalized.contains("direction") || normalized.contains("screen_type") || normalized.contains("name") {
        candidates = scopeCandidatesBySlot[key] ?? scopeCandidatesBySlot[normalized] ?? []
    } else if normalized.contains("color") {
        candidates = ["蓝色", "暖白", "红色", "紫色"]
    } else if normalized.contains("mode") {
        candidates = ["自动", "强力", "低档", "高档"]
    } else if normalized.contains("temperature") || normalized.contains("temp") {
        candidates = ["22", "24", "26", "20"]
    } else if normalized.contains("percent") {
        candidates = ["25", "50", "75", "100"]
    } else if normalized.contains("action") {
        candidates = [seed.actionPrimitive]
    } else if !value.offset.isEmpty && !value.offset.hasPrefix("<") && !value.offset.hasSuffix(">") {
        candidates = [value.offset]
    } else {
        candidates = ["\(key)_value_\((variant % 4) + 1)"]
    }
    return candidates.isEmpty ? "\(key)_value_\((variant % 4) + 1)" : candidates[variant % candidates.count]
}
```

Update internal call sites in sample generation so they pass `options.scopeCandidatesBySlot`.

- [ ] **Step 7.3: Fix the stale test fixture**

In `Tests/MAformacCoreTests/C5LoRATrainingTests.swift`, change:

```swift
range: "position=主驾|副驾|左前"
```

to:

```swift
range: "position=主驾|副驾|左后"
```

- [ ] **Step 7.4: Run C5 tests**

Run:

```bash
swift test --filter C5LoRATrainingTests
```

Expected: tests pass and rendered assistant payloads no longer use `左前`, `右前`, or `后排` as executable scope values.

- [ ] **Step 7.5: Commit C5 scope parity**

```bash
git add Core/Training/C5LoRATraining.swift Tests/MAformacCoreTests/C5LoRATrainingTests.swift
git commit -m "fix(c5): align scope candidates with c2"
```

---

## Task 8: C6 Default-Scope Gold Alignment

**Files:**
- Modify: `Core/Bench/C6VehicleToolBench.swift`
- Modify: `Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift`
- Modify: `contracts/c6-bench-cases.jsonl`

- [ ] **Step 8.1: Add C6 assertions for omitted vs fan-out windows**

Add this test to `Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift`:

```swift
func testDefaultScopeWindowCasesSeparateOmittedAndFanout() throws {
    let cases = try makeGenerator().generate()
    let mp014 = try XCTUnwrap(cases.first { $0.caseID == "C6-MP-014" })
    let mp015 = try XCTUnwrap(cases.first { $0.caseID == "C6-MP-015" })
    let mp016 = try XCTUnwrap(cases.first { $0.caseID == "C6-MP-016" })
    let mp017 = try XCTUnwrap(cases.first { $0.caseID == "C6-MP-017" })

    XCTAssertEqual(mp014.input, "打开车窗")
    XCTAssertEqual(mp014.expectedToolCalls.first?.arguments["position"], nil)
    XCTAssertEqual(mp014.stateDelta, ["window.position[主驾]": "100"])

    XCTAssertEqual(mp015.input, "关上所有车窗")
    XCTAssertEqual(mp015.expectedToolCalls.first?.arguments["position"], "全车")
    XCTAssertEqual(Set(mp015.stateDelta.keys), Set([
        "window.position[主驾]",
        "window.position[副驾]",
        "window.position[左后]",
        "window.position[右后]"
    ]))

    XCTAssertEqual(mp016.expectedToolCalls.first?.arguments["position"], nil)
    XCTAssertEqual(mp016.stateDelta, ["window.position[主驾]": "50"])

    XCTAssertEqual(mp017.expectedToolCalls.first?.arguments["position"], nil)
    XCTAssertEqual(mp017.stateDelta, ["window.position[主驾]": "20"])
}
```

Expected before implementation: MP-014 uses `position=全车` and fans out.

- [ ] **Step 8.2: Update C6 case specs**

In `Core/Bench/C6VehicleToolBench.swift`, update these rows:

```swift
CaseSpec("C6-MP-014", "scene3", "window", "power_on", "打开车窗", [C6ToolCall(name: "open_window", arguments: [:])], false, ["window.position[主驾]": "100"], ["车窗"], .implicit, .action, ["window.position"], "window-open-default-driver"),
CaseSpec("C6-MP-015", "scene3", "window", "power_off", "关上所有车窗", [C6ToolCall(name: "close_window", arguments: ["position": "全车"])], false, ["window.position[主驾]": "0", "window.position[副驾]": "0", "window.position[左后]": "0", "window.position[右后]": "0"], ["车窗"], .implicit, .action, ["window.position"], "window-close-all"),
CaseSpec("C6-MP-016", "scene3", "window", "by_percent", "车窗开到50%", [C6ToolCall(name: "open_window_to_number", arguments: ["value": "50"])], false, ["window.position[主驾]": "50"], ["50"], .implicit, .action, ["window.position"], "window-half-default-driver"),
CaseSpec("C6-MP-017", "scene3", "window", "increase_by_exp", "再开大点", [C6ToolCall(name: "open_window_little", arguments: [:])], false, ["window.position[主驾]": "20"], ["20"], .implicit, .action, ["window.position"], "window-followup-default-driver"),
```

- [ ] **Step 8.3: Regenerate the committed C6 JSONL from source**

Run:

```bash
swift test --filter C6VehicleToolBenchTests/testDefaultScopeWindowCasesSeparateOmittedAndFanout
swift test --filter C6VehicleToolBenchTests/testGoldReplayPassesForMigratedDDomainDataset
```

Then regenerate the source-derived C6 dataset instead of hand-editing JSONL rows:

```bash
swift run C6BenchCLI generate
python3 scripts/migrate_c6_trap_to_d_domain.py --old-from-git
```

Expected: source-derived must-pass/default-scope rows reflect `Core/Bench/C6VehicleToolBench.swift`, and C6-TRAP rows are appended through the existing migration script. Do not manually replace JSONL lines.

- [ ] **Step 8.4: Run C6 tests**

Run:

```bash
swift test --filter C6VehicleToolBenchTests
```

Expected: gold replay remains pass and default-scope cases distinguish omitted driver default from explicit all-window fan-out.

- [ ] **Step 8.5: Commit C6 alignment**

```bash
git add Core/Bench/C6VehicleToolBench.swift Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift contracts/c6-bench-cases.jsonl
git commit -m "fix(c6): align window gold with default scope"
```

- [ ] **Step 8.6: Include or explicitly defer demo scenarios and L1 allowlist**

Inspect:

```bash
rg -n "打开车窗|所有车窗|全车|主驾|副驾|左后|右后|window|scope" contracts/demo-scenarios.yaml contracts/l1-demo-allowlist.yaml
```

If either file encodes omitted-scope or fan-out examples, update it in the same source-of-truth direction:

- omitted `打开车窗` means default driver scope through C2, not `全车`;
- explicit collection/fan-out requires an accepted collection token such as `全车` or an approved collection alias;
- executable scope values must use C2 canonical values, not `左前`/`右前`/`后排`.

If the files do not currently participate in default-scope acceptance, record `deferred_with_reason` in the final receipt notes. Do not leave them unmentioned.

---

## Task 9: Mechanical Gate Scripts and Makefile Hook

**Files:**
- Create: `scripts/check_default_scope_ssot.py`
- Create: `scripts/check_c5_c2_scope_parity.py`
- Create: `scripts/check_scope_origin_single_source.py`
- Modify: `Makefile`
- Test: `scripts/verify_refs.py`

- [ ] **Step 9.1: Create Gate A script**

Create `scripts/check_default_scope_ssot.py`:

```python
#!/usr/bin/env python3
from __future__ import annotations

import pathlib
import re
import sys
from typing import Iterable

import yaml

ROOT = pathlib.Path(__file__).resolve().parents[1]
STATE_CELLS = ROOT / "contracts" / "state-cells.yaml"
FORBIDDEN = [
    (ROOT / "Core" / "Execution" / "C3ExecutionPipeline.swift", re.compile(r'\?\?\s*"全车"')),
    (ROOT / "Core" / "Contracts" / "ToolContractCompiler.swift", re.compile(r"scope\.first")),
    (ROOT / "Core" / "Contracts" / "ToolContractCompiler.swift", re.compile(r'\?\?\s*"all"')),
]


def fail(message: str) -> None:
    print(f"default-scope-ssot: {message}", file=sys.stderr)
    raise SystemExit(65)


def iter_cells(spec: dict) -> Iterable[dict]:
    for device in (spec.get("devices") or {}).values():
        for cell in device.get("state_cells") or []:
            yield cell
    for section in ("safety_cells", "scenario_cells"):
        for cell in spec.get(section) or []:
            yield cell


def check_forbidden_fallbacks() -> None:
    for path, pattern in FORBIDDEN:
        text = path.read_text(encoding="utf-8")
        for lineno, line in enumerate(text.splitlines(), 1):
            if pattern.search(line):
                fail(f"{path.relative_to(ROOT)}:{lineno} contains forbidden fallback: {line.strip()}")


def check_default_scope_membership() -> None:
    spec = yaml.safe_load(STATE_CELLS.read_text(encoding="utf-8"))
    for cell in iter_cells(spec):
        cid = cell.get("id", "?")
        scope = cell.get("scope") or []
        default_scope = cell.get("default_scope")
        if scope:
            if not isinstance(default_scope, str) or not default_scope:
                fail(f"{cid} missing default_scope")
            if default_scope not in scope:
                fail(f"{cid} default_scope={default_scope!r} not in scope={scope!r}")
        elif "default_scope" in cell:
            fail(f"{cid} declares default_scope without scope")


def main() -> None:
    check_forbidden_fallbacks()
    check_default_scope_membership()
    print("default-scope-ssot: pass")


if __name__ == "__main__":
    main()
```

- [ ] **Step 9.2: Create Gate B script**

Create `scripts/check_c5_c2_scope_parity.py`:

```python
#!/usr/bin/env python3
from __future__ import annotations

import pathlib
import re
import sys

import yaml

ROOT = pathlib.Path(__file__).resolve().parents[1]
STATE_CELLS = ROOT / "contracts" / "state-cells.yaml"
C5_SOURCE = ROOT / "Core" / "Training" / "C5LoRATraining.swift"
C5_TESTS = ROOT / "Tests" / "MAformacCoreTests" / "C5LoRATrainingTests.swift"
STALE_EXECUTABLE_SCOPE = ("左前", "右前", "后排")


def fail(message: str) -> None:
    print(f"c5-c2-scope-parity: {message}", file=sys.stderr)
    raise SystemExit(65)


def c2_window_scopes() -> list[str]:
    spec = yaml.safe_load(STATE_CELLS.read_text(encoding="utf-8"))
    for device in (spec.get("devices") or {}).values():
        for cell in device.get("state_cells") or []:
            if cell.get("id") == "window.position":
                return list(cell.get("scope") or [])
    fail("window.position scope missing from C2")


def main() -> None:
    scopes = c2_window_scopes()
    for required in ("主驾", "副驾", "左后", "右后", "全车"):
        if required not in scopes:
            fail(f"C2 window.position scope missing {required}")

    source = C5_SOURCE.read_text(encoding="utf-8")
    tests = C5_TESTS.read_text(encoding="utf-8")
    if "C5ScopeCandidateCatalog.scopeCandidatesBySlot(from:" not in source + tests:
        fail("C5 scope candidates are not derived from C2")
    if "slotKeys: []" not in tests or "XCTAssertFalse(rendered.contains(\"\\\"position\\\"\"))" not in tests:
        fail("C5 omitted-scope rendering test is missing")

    for token in STALE_EXECUTABLE_SCOPE:
        if re.search(rf'"position"\s*:\s*"{token}"', source) or re.search(rf'range:\s*"[^"]*{token}', tests):
            fail(f"stale executable scope token remains: {token}")

    print("c5-c2-scope-parity: pass")


if __name__ == "__main__":
    main()
```

- [ ] **Step 9.3: Create Gate C script**

Create `scripts/check_scope_origin_single_source.py`:

```python
#!/usr/bin/env python3
from __future__ import annotations

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
REQUIRED = [
    ROOT / "Core" / "Execution" / "ScopeResolution.swift",
    ROOT / "Core" / "Execution" / "C3ExecutionPipeline.swift",
    ROOT / "Core" / "Contracts" / "ContractLookups.swift",
    ROOT / "Core" / "State" / "DemoVehicleStateStore.swift",
    ROOT / "Core" / "Bench" / "C6VehicleToolBench.swift",
]
FORBIDDEN_RECOMPUTE = [
    (ROOT / "Core" / "Contracts" / "ContractLookups.swift", re.compile(r'scope\s*==\s*"主驾"')),
    (ROOT / "Core" / "Execution" / "C3ExecutionPipeline.swift", re.compile(r'scope\s*==\s*"主驾"')),
]


def fail(message: str) -> None:
    print(f"scope-origin-single-source: {message}", file=sys.stderr)
    raise SystemExit(65)


def main() -> None:
    combined = "\n".join(path.read_text(encoding="utf-8") for path in REQUIRED)
    if "enum ScopeOrigin" not in combined:
        fail("ScopeOrigin enum missing")
    for case_name in ("case defaulted", "case explicit", "case fanout"):
        if case_name not in combined:
            fail(f"ScopeOrigin missing {case_name}")
    if combined.count("scopeOrigin") < 4:
        fail("scopeOrigin is not threaded through execution/readback")
    for path, pattern in FORBIDDEN_RECOMPUTE:
        text = path.read_text(encoding="utf-8")
        for lineno, line in enumerate(text.splitlines(), 1):
            if pattern.search(line):
                fail(f"{path.relative_to(ROOT)}:{lineno} recomputes origin from driver string")
    print("scope-origin-single-source: pass")


if __name__ == "__main__":
    main()
```

- [ ] **Step 9.4: Add Makefile hook**

In `Makefile`, update `.PHONY`:

```make
.PHONY: verify verify-all swift-test verify-generated regen regen-tool-contract verify-source verify-refs verify-cross-section verify-surface verify-default-scope diff test clean-venv
```

Add target:

```make
verify-default-scope: .venv/.deps.stamp
	$(PYTHON) scripts/check_default_scope_ssot.py
	$(PYTHON) scripts/check_c5_c2_scope_parity.py
	$(PYTHON) scripts/check_scope_origin_single_source.py
```

Update `verify`:

```make
verify: .venv/.deps.stamp verify-source regen verify-refs verify-cross-section verify-surface verify-default-scope diff test
```

- [ ] **Step 9.5: Run mechanical gates**

Run:

```bash
make verify-default-scope
.venv/bin/python scripts/verify_refs.py
```

Expected: both pass.

- [ ] **Step 9.6: Commit gates**

```bash
git add scripts/check_default_scope_ssot.py scripts/check_c5_c2_scope_parity.py scripts/check_scope_origin_single_source.py Makefile scripts/verify_refs.py
git commit -m "test(default-scope): add apply mechanical gates"
```

---

## Task 10: Full Verification and Manual Receipt

**Files:**
- Create: `Reports/default-scope-apply-<timestamp>/receipt.json`

- [ ] **Step 10.1: Run focused tests**

Run:

```bash
swift test --filter C3ContractLookupTests
swift test --filter C3ExecutionPipelineTests
swift test --filter C3ReadbackTemplateTests
swift test --filter ToolContractCompilerTests
swift test --filter C5LoRATrainingTests
swift test --filter C6VehicleToolBenchTests
make verify-default-scope
```

Expected: all pass.

- [ ] **Step 10.2: Run full local verification**

Run:

```bash
make verify
make verify-all
openspec validate define-demo-default-scope --strict
openspec validate --all --strict
git diff --check
```

Expected: all pass. `make verify-all` may take longer because it includes `swift test`.

- [ ] **Step 10.3: Capture command evidence and write receipt**

Create the receipt directory and capture each command log before writing `receipt.json`. Do not hardcode pass records without running the command.

```bash
set -euo pipefail
timestamp="$(python3 - <<'PY'
import datetime as dt
print(dt.datetime.now(dt.UTC).strftime("%Y%m%dT%H%M%SZ"))
PY
)"
receipt_dir="Reports/default-scope-apply-${timestamp}"
log_dir="${receipt_dir}/logs"
mkdir -p "${log_dir}"
: > "${receipt_dir}/commands.jsonl"

run_and_record() {
  local slug="$1"
  shift
  local log="${log_dir}/${slug}.log"
  set +e
  "$@" >"${log}" 2>&1
  local code=$?
  set -e
  local sha
  sha="$(shasum -a 256 "${log}" | awk '{print $1}')"
  python3 - <<PY >> "${receipt_dir}/commands.jsonl"
import json
record = {
  "cmd": "${*}",
  "exit_code": ${code},
  "verdict": "pass" if ${code} == 0 else "fail",
  "evidence_path": "${log}",
  "sha256": "${sha}"
}
print(json.dumps(record, ensure_ascii=False, sort_keys=True))
PY
  return "${code}"
}

run_and_record c3_contract swift test --filter C3ContractLookupTests
run_and_record c3_pipeline swift test --filter C3ExecutionPipelineTests
run_and_record c3_readback swift test --filter C3ReadbackTemplateTests
run_and_record state_applier swift test --filter ToolContractCompilerTests
run_and_record c5_training swift test --filter C5LoRATrainingTests
run_and_record c6_bench swift test --filter C6VehicleToolBenchTests
run_and_record verify_default_scope make verify-default-scope
run_and_record make_verify make verify
run_and_record make_verify_all make verify-all
run_and_record openspec_change openspec validate define-demo-default-scope --strict
run_and_record openspec_all openspec validate --all --strict
run_and_record diff_check git diff --check

python3 - <<'PY' "${receipt_dir}"
from __future__ import annotations

import datetime as dt
import json
import pathlib
import subprocess
import sys

receipt_dir = pathlib.Path(sys.argv[1])

def git(*args: str) -> str:
    return subprocess.check_output(["git", *args], text=True).strip()

commands = [json.loads(line) for line in (receipt_dir / "commands.jsonl").read_text(encoding="utf-8").splitlines()]
failed = [record for record in commands if record["exit_code"] != 0]
if failed:
    raise SystemExit(f"receipt cannot be pass; failed commands: {failed}")

receipt = {
    "receipt_id": receipt_dir.name,
    "created_at": dt.datetime.now(dt.UTC).replace(microsecond=0).isoformat().replace("+00:00", "Z"),
    "change_id": "define-demo-default-scope",
    "proof_class": "openspec_apply_local",
    "base_commit": git("rev-parse", "HEAD~1"),
    "head_commit": git("rev-parse", "HEAD"),
    "dirty_worktree": bool(git("status", "--porcelain")),
    "commands": commands,
    "mechanical_gates": {
        "default_scope_ssot": "pass",
        "c5_c2_parity": "pass",
        "scope_origin_single_source": "pass"
    },
    "claim_boundaries": [
        "no_training_no_c6_acceptance_no_golden_no_voice_no_uiue_merge",
        "r_l17_not_closed_by_this_receipt",
        "uiue_not_mainline_evidence",
        "demo_scenarios_and_l1_allowlist_included_or_deferred_with_reason"
    ]
}
(receipt_dir / "receipt.json").write_text(json.dumps(receipt, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(receipt_dir / "receipt.json")
PY
```

- [ ] **Step 10.4: Validate receipt manually with jsonschema**

Run:

```bash
.venv/bin/python - <<'PY'
import json
import pathlib
import jsonschema

schema = json.loads(pathlib.Path("docs/project/receipts/local-receipt.schema.json").read_text())
receipts = sorted(pathlib.Path("Reports").glob("default-scope-apply-*/receipt.json"))
if not receipts:
    raise SystemExit("no default-scope receipt found")
receipt = json.loads(receipts[-1].read_text())
jsonschema.validate(receipt, schema)
print(f"receipt-schema: pass {receipts[-1]}")
PY
```

Expected: `receipt-schema: pass ...`.

- [ ] **Step 10.5: Commit final apply receipt**

```bash
git add Reports/default-scope-apply-*/receipt.json
git commit -m "docs(default-scope): record apply receipt"
```

---

## Final Closeout Rules

Before claiming this apply complete, the executor must be able to state all of the following with file evidence:

- C2 `default_scope` exists for scoped demo-execution cells and is validated by Swift and Python.
- C3 omitted scope no longer defaults to `全车`.
- State application no longer defaults through `scope.first` or `all`.
- Readback distinguishes omitted default driver scope from explicit driver scope.
- C5 rendered scope values do not use stale `左前`, `右前`, or `后排` executable vocabulary.
- C6 default-scope gold distinguishes omitted driver default from explicit all-window fan-out.
- Legacy unscoped UI keys are either removed from the read path or exposed only through a named one-way compatibility adapter.
- `contracts/demo-scenarios.yaml` and `contracts/l1-demo-allowlist.yaml` are updated or explicitly deferred with reason in the receipt.
- `make verify-default-scope`, `make verify`, `make verify-all`, and OpenSpec strict validation pass.
- No training, C6 acceptance, real model-quality evaluation, demo-golden-run, voice, endpoint-ready claim, or UIUE merge was performed.

## Self-Review

Spec coverage:

- C2 authority: Tasks 1, 2, and Gate A.
- C3 target resolution: Tasks 3 and 4.
- State applier: Task 5.
- Readback and ScopeOrigin metadata: Task 6 and Gate C.
- C5/C2 parity: Task 7 and Gate B.
- C6 bench alignment: Task 8.
- Legacy UI key disposition: Task 6.5.
- Demo scenarios / L1 allowlist include-or-defer: Task 8.6.
- Test and closeout proof: Tasks 9 and 10.
- `CURRENT.md` small update only: Task 0.
- Receipt schema draft only: Task 0 and Task 10.

Placeholder scan:

- The plan uses concrete paths, commands, tests, and commit messages.
- It intentionally does not add a `make receipt` target in this apply.
- It intentionally keeps UIUE as external, unverified merge-check context.

Type consistency:

- `ScopeOrigin` is introduced once in `Core/Execution/ScopeResolution.swift`.
- `scopeOrigin` is threaded through `DemoActionReadback` and `renderReadback`.
- `defaultScope` is parsed into `StateCellDefinition` and validated by both Swift and Python gates.
