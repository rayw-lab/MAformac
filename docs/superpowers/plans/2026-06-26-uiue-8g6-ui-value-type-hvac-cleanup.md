# UIUE 8.G6 UI Value Type Projection + Active HVAC Cleanup Plan

Date: 2026-06-26
Repo: `/Users/wanglei/workspace/MAformac-uiue`
Branch: `uiue/phase4-default-scope-presentation`
Task: 8.G6 only
Proof class target: `local` + `unit`; no `runtime`, no `mobile`, no `true_device`, no `V-PASS`

## Goal

Close 8.G6 without violating the existing UI presentation spec:

1. Add a consumer-side `ui_value_type` projection over all `state-cells` bases.
2. Keep `contracts/state-cells.yaml` producer schema unchanged because the active spec says this capability SHALL NOT require producer/contract fields.
3. Clean active Core/Tests `hvac.*` residuals so current runtime state no longer carries an HVAC legacy key.
4. Mark only `8.G6` complete in `openspec/changes/ui-presentation/tasks.md`.

## Authority Reconciliation

There is a wording conflict:

- `openspec/changes/ui-presentation/tasks.md:151` currently says 8.G6 should add a `ui_value_type` derived field to `state-cells`.
- `openspec/changes/ui-presentation/specs/ui-presentation/spec.md:83` says card value rendering SHALL derive `ui_value_type` on the consumer side and SHALL NOT require producer/contract fields.
- `openspec/changes/ui-presentation/design.md:27` says the physical implementation is `Core/Presentation/UIValueTypeMapper.swift`; it explicitly says do not write back to `contracts/state-cells.yaml` and do not add a field to `DemoVehicleStateCell`.
- `docs/handoffs/2026-06-26-uiue-visual-gate-grill-closeout-3in1-change.md` says reuse the existing `UIValueTypeMapper.swift` mapping and verify `hvac.*` status rather than inventing another mapper.

Decision for implementation:

- Treat the 8.G6 task wording as stale shorthand.
- Implement a typed consumer-side projection named around `state-cells` so every known contract base can expose a derived `ui_value_type` without mutating producer YAML.
- Update the 8.G6 task line when checking it so the final task wording matches spec/design authority.

If you believe a literal `ui_value_type` field must be added to `contracts/state-cells.yaml`, stop and return `PARTIAL`; do not violate spec R2/AD-2 silently.

## Current Truth Snapshot

Live verified before writing this plan:

- Branch HEAD includes 8.G7 commit `6a1b975`.
- 8.G6 is open; 8.G1/8.G2/8.G3/8.G4/8.G5/8.G7 are checked complete.
- `UIValueTypeMapper.mapping` already covers contract bases and existing tests already guard mapping closure.
- Active `hvac.*` residuals in Core/Tests are:
  - `/Users/wanglei/workspace/MAformac-uiue/Core/State/DemoVehicleStateStore.swift`: `hvac.temperature` in `legacyDisplayCompatibilityKeys`
  - `/Users/wanglei/workspace/MAformac-uiue/Core/State/DemoVehicleStateStore.swift`: `hvac.temperature` in `defaultCells()`
  - `/Users/wanglei/workspace/MAformac-uiue/Tests/MAformacCoreTests/VehicleStateStoreContractTests.swift`: tests still require `hvac.temperature` in default state
- Historical tracked files still contain `hvac.*`:
  - `/Users/wanglei/workspace/MAformac-uiue/contracts/function-spec-full-v0.yaml`
  - `/Users/wanglei/workspace/MAformac-uiue/contracts/capabilities.yaml`
  - historical docs under `docs/`
- `contracts/function-spec-full-v0.yaml` has a `HISTORICAL / reference_template` banner. `contracts/capabilities.yaml` also has a `HISTORICAL / v1-B-frame-archived` banner. Do not rewrite those in 8.G6.

## Writable Paths

- `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/UIValueTypeMapper.swift`
- `/Users/wanglei/workspace/MAformac-uiue/Core/State/DemoVehicleStateStore.swift`
- `/Users/wanglei/workspace/MAformac-uiue/Tests/MAformacCoreTests/UIValueTypeMappingTests.swift`
- `/Users/wanglei/workspace/MAformac-uiue/Tests/MAformacCoreTests/VehicleStateStoreContractTests.swift`
- `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/tasks.md`

No-touch paths:

- `/Users/wanglei/workspace/MAformac-uiue/contracts/state-cells.yaml`
- `/Users/wanglei/workspace/MAformac-uiue/contracts/capabilities.yaml`
- `/Users/wanglei/workspace/MAformac-uiue/contracts/function-spec-full-v0.yaml`
- `/Users/wanglei/workspace/MAformac-uiue/generated/`
- `/Users/wanglei/workspace/MAformac-uiue/App/`
- `/Users/wanglei/workspace/MAformac-uiue/docs/research/2026-06-25-a2-execution/`

## Stop Conditions

- If `git status --short` shows tracked dirty files before you start, stop and report.
- If any change requires mutating `contracts/`, `generated/`, or `App/`, stop and return `PARTIAL`.
- If `rg -n "\\bhvac\\." Core Tests App` still finds active code after the cleanup, do not check 8.G6.
- If `swift test` or `make verify-all` fails outside the allowed write set, stop after two scoped fix attempts and report `PARTIAL`.

## Implementation Step 1: Add Consumer-Side Projection

Edit:

`/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/UIValueTypeMapper.swift`

Change `UIValueType` to a stable raw-value enum:

```swift
enum UIValueType: String, CaseIterable, Codable, Equatable, Sendable {
    case dial
    case toggle
    case stepper
    case percent
    case badge
}
```

Add a projection type near `UIValueTypeMapper`:

```swift
struct StateCellUIValueTypeProjection: Equatable, Sendable {
    var base: String
    var uiValueType: UIValueType

    var uiValueTypeFieldValue: String {
        uiValueType.rawValue
    }
}

enum StateCellUIValueTypeProjector {
    static func projections(
        catalog: StateCellPresentationCatalog = .shared
    ) -> [StateCellUIValueTypeProjection] {
        catalog.knownBases.sorted().map { base in
            StateCellUIValueTypeProjection(
                base: base,
                uiValueType: UIValueTypeMapper.uiValueType(forBase: base)
            )
        }
    }
}
```

Notes:

- This is the `ui_value_type` derived field, but in the consumer layer.
- Do not add `ui_value_type` to `DemoVehicleStateCell`.
- Do not add `ui_value_type` to `contracts/state-cells.yaml`.
- Keep `UIValueTypeMapper.mapping` as the SSOT; do not create a second mapping table.

## Implementation Step 2: Strengthen UI Value Type Tests

Edit:

`/Users/wanglei/workspace/MAformac-uiue/Tests/MAformacCoreTests/UIValueTypeMappingTests.swift`

Add tests:

```swift
func testUIValueTypeRawValuesAreStable() {
    XCTAssertEqual(
        UIValueType.allCases.map(\.rawValue),
        ["dial", "toggle", "stepper", "percent", "badge"]
    )
}

func testStateCellUIValueTypeProjectionCoversEveryKnownBase() {
    let catalog = StateCellPresentationCatalog.load()
    let projections = StateCellUIValueTypeProjector.projections(catalog: catalog)

    XCTAssertGreaterThanOrEqual(projections.count, 30)
    XCTAssertEqual(projections.map(\.base), catalog.knownBases.sorted())
    XCTAssertTrue(projections.allSatisfy { !$0.uiValueTypeFieldValue.isEmpty })
}

func testStateCellsYAMLDoesNotCarryProducerUIValueTypeField() throws {
    let yaml = try loadStateCellsYAML()

    XCTAssertFalse(
        yaml.contains("ui_value_type"),
        "ui_value_type must remain consumer-side per ui-presentation spec R2 / AD-2"
    )
}
```

Keep the existing semantic alignment test. It is still the key guard that the projection does not drift from `state-cells` type/unit/values semantics.

## Implementation Step 3: Clean Active HVAC Legacy Key

Edit:

`/Users/wanglei/workspace/MAformac-uiue/Core/State/DemoVehicleStateStore.swift`

Remove `hvac.temperature` from:

- `legacyDisplayCompatibilityKeys`
- `defaultCells()`

Do not remove the other non-HVAC legacy compatibility keys in this task. Those are a separate legacy adapter question and not 8.G6.

Expected post-clean active grep:

```bash
rg -n "\\bhvac\\." Core Tests App
```

This should return no matches.

## Implementation Step 4: Update Store Tests

Edit:

`/Users/wanglei/workspace/MAformac-uiue/Tests/MAformacCoreTests/VehicleStateStoreContractTests.swift`

Update `testDefaultCellsMatchCapabilityMvpSet()` so it no longer expects `hvac.temperature`.

Add:

```swift
@MainActor
func testDefaultCellsDoNotCarryActiveHvacLegacyKeys() {
    let store = DemoVehicleStateStore()
    let keys = store.cells.map(\.key)

    XCTAssertFalse(keys.contains { $0.hasPrefix("hvac.") })
}
```

The existing `testPresentationCellsUseScopedC2KeysInsteadOfLegacyDisplayKeys()` can keep its `hvac.temperature` negative assertion if desired, but the stronger prefix test should make active cleanup explicit.

## Implementation Step 5: Mark 8.G6 Only

Edit:

`/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/tasks.md`

Change only 8.G6, and update the wording to reflect the authority reconciliation:

```diff
-- [ ] 8.G6 `state-cells` 加 `ui_value_type` 派生字段（D3 C11）+ 清残留 2 处 `hvac.*` 命名债（apply 时核现状）
+ [x] 8.G6 `state-cells` 的 `ui_value_type` 消费侧派生 projection（复用 `UIValueTypeMapper`，不写回 producer contract，守 spec R2/AD-2）+ 清 active Core/Tests 残留 `hvac.*` 命名债（历史 v0/capabilities refs 保留为 archived/historical）
```

Do not check 8.G8 or 8.G9.

## Validation Gates

Run targeted gates:

```bash
rg -n "\\bhvac\\." Core Tests App
swift test --filter UIValueTypeMappingTests
swift test --filter VehicleStateStoreContractTests
```

Run full gates:

```bash
swift test
make verify-all
openspec validate ui-presentation --strict
git diff --check
```

Because `contracts/` should not be changed, no contract diff should exist. If you accidentally touch `contracts/`, stop, inspect, and do not commit until you can justify it against spec R2/AD-2.

Commit only:

```bash
git add Core/Presentation/UIValueTypeMapper.swift \
  Core/State/DemoVehicleStateStore.swift \
  Tests/MAformacCoreTests/UIValueTypeMappingTests.swift \
  Tests/MAformacCoreTests/VehicleStateStoreContractTests.swift \
  openspec/changes/ui-presentation/tasks.md
git commit -m "test(uiue): close ui value type and hvac debt"
```

## Expected Verdict

```text
verdict: DONE | PARTIAL | BLOCKED

Commit:
- <sha> test(uiue): close ui value type and hvac debt

Changed files:
- Core/Presentation/UIValueTypeMapper.swift
- Core/State/DemoVehicleStateStore.swift
- Tests/MAformacCoreTests/UIValueTypeMappingTests.swift
- Tests/MAformacCoreTests/VehicleStateStoreContractTests.swift
- openspec/changes/ui-presentation/tasks.md

Validation:
- rg -n "\\bhvac\\." Core Tests App -> no matches
- swift test --filter UIValueTypeMappingTests -> PASS/FAIL
- swift test --filter VehicleStateStoreContractTests -> PASS/FAIL
- swift test -> PASS/FAIL
- make verify-all -> PASS/FAIL
- openspec validate ui-presentation --strict -> PASS/FAIL
- git diff --check -> PASS/FAIL

Proof class:
- local
- unit

Residual risks:
- Historical `hvac.*` refs remain in archived/reference files such as `contracts/function-spec-full-v0.yaml`, `contracts/capabilities.yaml`, and older docs; not active Core/App/Tests proof.
- No runtime/mobile/true-device/V-PASS claimed.
- 8.C2 remains open.
- 8.G8/8.G9 remain open.
```
