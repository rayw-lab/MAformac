---
status: active
authority: accepted_grill_decision_pack
accepted_by: user
accepted_at: 2026-06-24
scope: non-UIUE mainline demo default-scope semantics
retire_trigger: "OpenSpec change for demo default_scope is archived and C2/C3/C5/C6/readback/demo-scenarios are implemented and verified."
---

# Demo Default Scope Grill Decisions — G01-G28

> This is a decision pack, not an implementation patch and not an archived OpenSpec spec.
> G28 is retained as a UIUE merge check only; it is not a mainline blocker unless state, C3-C6, or golden-run contracts diverge.
> Implementation plan: `docs/superpowers/plans/2026-06-24-phase0-d1-d10-openspec-gates.md` Phase -1.

## 0. Executive Decision

When a demo utterance omits seat/zone/screen/light scope, the system must not interrupt the end-to-end flow by asking whether the user means driver, passenger, rear, or all. It must resolve the omitted scope through an explicit C2 `default_scope` per scoped state cell.

This does not delete scoped state. Internal state keys remain scoped, explicit user scope still wins, and explicit collection scopes such as `全车` still fan out. Customer-facing presentation must receive structured scope-origin metadata so UI, TTS/readback, and verifier assertions can render defaulted, explicit, and fan-out scopes differently without asking a driver/passenger clarification.

The current codebase already proves this is not a pure UI concern:

- `contracts/state-cells.yaml:59`, `:80`, `:97`, `:132`, `:159`, `:182`, `:193`, `:221`, `:318`, `:342`, `:361` define scoped cells but no explicit `default_scope`.
- `Core/Execution/C3ExecutionPipeline.swift:170-179` falls back to `全车` and fans out for omitted scope.
- `Core/Contracts/ToolContractCompiler.swift:466-470` uses `scope.first` for most cells, but makes `window` omitted scope become `all`.
- `Core/Contracts/ToolContractCompiler.swift:553-565` maps default/unknown/all to four-window fan-out.
- `Core/Bench/C6VehicleToolBench.swift:370-373` and `contracts/c6-bench-cases.jsonl:21-24` encode omitted window utterances as `position=全车`, with cases 016/017 internally expecting only driver state deltas.
- `Core/Training/C5LoRATraining.swift:1898-1899` hardcodes `["主驾", "副驾", "左前", "右前", "后排", "全车"]`, which is not the C2 window scope list.

## 1. Vocabulary

| Term | Decision |
|---|---|
| `scope` | The executable C2 dimension for a state cell, such as `主驾`, `中控屏`, `前排`, or `全车`. It is not automatically a visible UI control. |
| `default_scope` | The C2-owned target used only when the utterance and tool arguments omit a scope. It must be a member of that cell's `scope`. |
| explicit scope | A user- or tool-provided scope, such as `主驾`, `副驾`, `左后`, `全车`, `中控屏`, or `前排`. Explicit scope overrides `default_scope`. |
| collection alias | A closed, accepted phrase that maps to a collection scope token, such as `所有车窗`, `四个车窗`, or `车窗都` mapping to `全车` for `window.position`. Collection-like wording outside this alias set must reject/clarify or route to slow-path evidence; it must not silently default. |
| fan-out | A deliberate collection action from an explicit collection scope or accepted collection alias, such as `全车`, `所有车窗`, or `前后雨刮`. Omitted scope is not fan-out. |
| scope-origin presentation | Customer-facing channels receive `scope_origin`, `resolved_scope`, and presentation policy metadata. Defaulted scope may be low-emphasis, compact, or elided by channel; explicit non-default scope and explicit fan-out remain explicit. Internal state and tests still keep scoped keys. |

## 2. G01-G28 Decisions

| G | Priority | Status | Decision | Physical Landing | Evidence |
|---:|---|---|---|---|---|
| G01 | P0 | accepted | This pack is an accepted grill decision record, not a live implementation contract. OpenSpec must still carry observable behavior before code changes. | Add pointer from grill master, phase0 index, cascade inventory; next OpenSpec change should carry design/tasks/spec deltas. | `CLAUDE.md:24-27`, `CLAUDE.md:99`; this file frontmatter. |
| G02 | P0 | accepted | Demo default interaction uses per-cell semantic defaulting. Driver-oriented defaults apply only to human-zone cells whose C2 `default_scope` is `主驾`; screen/ambient/wiper/sunroof/sunshade use their own semantic default. Do not clarify driver/passenger for ordinary omitted-scope commands. | C2 `default_scope`; C3/C6/C5 follow it. | `docs/tech-baseline-supplement-v0.2.md:302-304` and `:323` are older/historical conflict points, not current demo default behavior. |
| G03 | P0 | accepted | Defaulting is per-cell, not per-family. Screen, ambient, wiper, sunroof, and sunshade have different defaults than driver-zone cabin controls. | Add `default_scope` to each scoped C2 cell. | `contracts/state-cells.yaml:59`, `:132`, `:159`, `:318`, `:342`. |
| G04 | P0 | accepted | Explicit scope remains executable. `打开主驾车窗`, `副驾车窗开一半`, `左后车窗打开`, and `关上所有车窗` must keep explicit behavior. | C3/C6 cases and tests must distinguish omitted scope from explicit scope. | `Core/Bench/C6VehicleToolBench.swift:371`, `:374-377`; `contracts/c6-bench-cases.jsonl:22`, `:25-28`. |
| G05 | P0 | accepted | Omitted scope is not `全车`. Only explicit collection scope or accepted collection aliases may fan out; unresolved collection-like wording must reject/clarify or route to slow path, not silently default. | C3 target resolution and ToolContractStateApplier must not use `全车`/`all` as missing-scope fallback; OpenSpec must define the collection alias policy. | `Core/Execution/C3ExecutionPipeline.swift:170-179`; `Core/Contracts/ToolContractCompiler.swift:468-470`, `:553-565`. |
| G06 | P0 | accepted | `scope.first` is not an authority source. It happens to match several defaults today but is brittle and must be replaced by explicit `default_scope`. | C2 schema plus Swift lookup field; tests for default determinism independent of YAML order. | `Core/Contracts/ToolContractCompiler.swift:466-470`. |
| G07 | P0 | accepted | Driver-default scoped cells: `ac.temp_setpoint`, `ac.fan_speed`, `window.position`, `seat.heat_level`, `seat.vent_level`, `seat.backrest_angle` default to `主驾`. | `contracts/state-cells.yaml` default_scope rows; state applier/C3/C6/C5 derive from them. | `contracts/state-cells.yaml:59`, `:80`, `:97`, `:182`, `:193`, `:221`. |
| G08 | P0 | accepted | Non-driver scoped cells default to their demo object: `screen.brightness=中控屏`, `ambient.brightness=面发光氛围灯`, `wiper.speed=前`, `sunroof.position=前排`, `sunshade.position=前排`. | Same C2 default_scope mechanism. | `contracts/state-cells.yaml:132`, `:159`, `:318`, `:342`, `:361`. |
| G09 | P1 | accepted | Unscoped cells are unaffected. Do not invent hidden zone fields for `ac.power`, `ambient.color`, volume, fragrance, or mode cells just for symmetry. | C2 schema should allow `default_scope` only when `scope` exists. | `contracts/state-cells.yaml:52-54`, `:147-153`, `:325-331`. |
| G10 | P0 | accepted | C3 execution target resolution must read C2 `default_scope` for omitted `direction`/`position`/`screen_type`/`name`. | `Core/Execution/C3ExecutionPipeline.swift` implementation and tests. | Current fallback is `?? "全车"` at `Core/Execution/C3ExecutionPipeline.swift:170-174`. |
| G11 | P0 | accepted | State applier must use the same C2 default_scope as C3; no separate window special-case default. | `Core/Contracts/ToolContractCompiler.swift` numeric-cell write path. | Current window omitted scope goes through `ir.slots["position"] ?? "all"` at `Core/Contracts/ToolContractCompiler.swift:468-470`. |
| G12 | P0 | accepted | `all`/`全车` and unknown must be split: explicit all fans out; unknown/out-of-scope rejects or clarifies; missing scope defaults. | Replace `windowKeys(default:)` catch-all behavior with explicit cases. | `Core/Contracts/ToolContractCompiler.swift:553-565`. |
| G13 | P0 | accepted | C6 gold must be rewritten before retrain/rebuild. Omitted window cases should expect default_scope; explicit all cases remain all. | `Core/Bench/C6VehicleToolBench.swift` plus regenerated `contracts/c6-bench-cases.jsonl`. | `Core/Bench/C6VehicleToolBench.swift:370-373`; `contracts/c6-bench-cases.jsonl:21-24`. |
| G14 | P0 | accepted | The C6 016/017 contradiction is a hard catch: `position=全车` while state delta only writes driver is not an acceptable alternative. | Fix by default_scope semantics, not by adding broad alternatives that hide inconsistency. | `Core/Bench/C6VehicleToolBench.swift:372-373`; `contracts/c6-bench-cases.jsonl:23-24`. |
| G15 | P0 | accepted | Corrected finding: window is the only current true omitted-to-all bug in the compiler; other scoped cells are accidentally defaulting through `scope.first`. Still replace all of them with explicit default_scope. | `ToolContractStateApplier` default resolution plus tests across window, ac, screen, ambient, seat, wiper, sunroof. | `Core/Contracts/ToolContractCompiler.swift:466-470`; `:553-565`. |
| G16 | P0 | accepted | D-domain generated argument schema should keep zone fields optional. Current generated demo catalog already has zero required zone-ish fields; preserve this and add a proof gate. | `scripts/gen_tool_contract.py`; generated catalog verification; do not hand-edit generated JSON. | `scripts/gen_tool_contract.py:124-134`; jq check on `generated/D_domain.tools.demo.json` = `zoneish_tools:457`, `zoneish_with_required:0`. |
| G17 | P0 | accepted | C5 training targets for omitted-scope utterances must omit `position`/`direction`/`screen_type`/`name`; explicit-scope utterances may include them. | C5 renderer/data builder and C5/C6 parity tests. | A2 handoff defers retrain at `docs/handoffs/2026-06-24-a2-merged-d-domain.md:17-19`; C5 fallback currently hardcodes scope at `Core/Training/C5LoRATraining.swift:1898-1899`. |
| G18 | P0 | accepted | Readback/presentation policy: defaulted scope must not trigger clarification, but it must stay available as structured metadata. UI may show a low-emphasis default badge; TTS/plain readback may use compact, low-emphasis, or elided wording by channel policy. Explicit non-default scope and explicit fan-out remain explicit. Internal verifier remains keyed by scoped state. | `ContractLookups.renderReadback` and UIUE presentation need scope-origin awareness; tests split channel presentation from state assertion. | Current renderer always substitutes scope at `Core/Contracts/ContractLookups.swift:166-179`; tests expect `主驾空调温度26度` and `主驾车窗开度30%` at `Tests/MAformacCoreTests/C3ReadbackTemplateTests.swift:20-23`, `:55-58`; external UIUE worktree records default-scope badge/readback/TTS policy at `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/design.md:84-88`. |
| G19 | P0 | accepted | Demo scenario scene3 is the default-scope story; scene4 is the explicit-scope generalization story. Do not merge them. | Update `contracts/demo-scenarios.yaml` scene3 expected behavior/readback and scene4 explicit wording. | `contracts/demo-scenarios.yaml:111-119`, `:127-133`. |
| G20 | P1 | accepted | L1 allowlist wording must stop describing omitted/default behavior as position fan-out. | Update `contracts/l1-demo-allowlist.yaml` examples after OpenSpec proposal. | Current text says `打开主驾车窗(position fan-out 泛化)` at `contracts/l1-demo-allowlist.yaml:72-74`. |
| G21 | P0 | accepted | OpenSpec `tool-execution` must add an omitted-slot default scenario; current slot fan-out requirement is not enough and can be misread as clarify/reject on omission. | Modify spec/design/tasks in the next OpenSpec carrier. | `openspec/specs/tool-execution/spec.md:62-73`. |
| G22 | P1 | accepted | Older docs that require object clarification for driver/passenger must be marked as historical or scoped to non-demo/high-risk contexts; they cannot override this demo default decision. | Cascade docs cleanup, not runtime code. | `docs/tech-baseline-supplement-v0.2.md:302-304`, `:319-325`; `docs/c5-recovery-2026-06-22/grill-decisions.md:265-270`. |
| G23 | P1 | accepted | UI app card rendering should not expose passenger/rear controls as default controls. State may stay scoped; UI may show a single family card for demo. Legacy unscoped demo keys must be deprecated or bridged explicitly before `default_scope` apply closeout, otherwise UI can read stale state. | OpenSpec Phase -1 task; App/UIUE implementation later. This is a default_scope apply blocker, not a Phase -1 code-change blocker. | Legacy keys coexist at `Core/State/DemoVehicleStateStore.swift:150-156`; `App/ContentView.swift:107-117` maps those legacy keys to friendly card titles; A2 S3 deferred UI title cleanup at `docs/research/2026-06-23-a2-execution/S3-statecells-c3-naming-INDEX.md:30-34`. |
| G24 | P2 | accepted | Prototype `副驾红衣` / multi-seat hero examples are explicit-scope/multimodal showcase material only, not default behavior. | Mark prototype path as historical or keep as explicit hero case. | `prototypes/scheme1-deep-space-interactive.html:98`, `:109-110`, `:161`; `prototypes/ui-concepts-3-schemes.html:139`, `:162-184`. |
| G25 | P0 | accepted | Add C2 `default_scope` as the SSOT and derive C3, compiler/state applier, C6, and C5 from it. | OpenSpec proposal plus C2 schema/code changes. | C2 currently has scope without default at `contracts/state-cells.yaml:59`, `:97`, `:132`, `:159`, `:318`. |
| G26 | P0 | accepted | C5 scope candidates must derive from C2 `scope`/`default_scope`, not from hardcoded fallback candidates. | C5 data builder/renderer changes; parity test against C2. | `Core/Training/C5LoRATraining.swift:1898-1899` uses `左前/右前/后排`, while C2 window uses `左后/右后` at `contracts/state-cells.yaml:97`. |
| G27 | P0 | accepted | Demo scenarios are first-class contract seeds, not prose examples. They must be updated alongside C6 before retrain. | `contracts/demo-scenarios.yaml`; scenario verifier if present. | Scene3/scene4 split at `contracts/demo-scenarios.yaml:104-133`; A2 handoff says retrain uses post-roadmap context at `docs/handoffs/2026-06-24-a2-merged-d-domain.md:17-18`. |
| G28 | P1 | retained | UIUE branch must consume the final state contract/golden IDs after default_scope lands. Until then, keep this as a merge check, not a mainline blocker. | UIUE branch/spec later; no duplicate mainline blocker now. | UIUE state consumption path is described at `docs/uiue-roadmap-2026-06-23-draft.md:128-140`, with UIUE/mainline dependency split at `:61-64`, `:198-199`. |

## 3. Default Scope Matrix

| Cell | Existing scope evidence | Accepted default_scope | Why |
|---|---|---|---|
| `ac.temp_setpoint` | `contracts/state-cells.yaml:55-69` | `主驾` | Phone/demo assistant defaults to driver cabin comfort. |
| `ac.fan_speed` | `contracts/state-cells.yaml:76-86` | `主驾` | Same driver cabin comfort rule. |
| `window.position` | `contracts/state-cells.yaml:93-104` | `主驾` | Omitted `打开车窗` should open the driver's window, not all four windows. |
| `screen.brightness` | `contracts/state-cells.yaml:128-139` | `中控屏` | Demo screen control defaults to center screen, not driver screen. |
| `ambient.brightness` | `contracts/state-cells.yaml:155-166` | `面发光氛围灯` | Current demo ambient brightness cell is light-type scoped, not seat scoped. |
| `seat.heat_level` | `contracts/state-cells.yaml:178-188` | `主驾` | Driver seat default. |
| `seat.vent_level` | `contracts/state-cells.yaml:189-199` | `主驾` | Driver seat default. |
| `seat.backrest_angle` | `contracts/state-cells.yaml:217-226` | `主驾` | Driver seat default. |
| `wiper.speed` | `contracts/state-cells.yaml:314-324` | `前` | Default windshield-facing wiper. |
| `sunroof.position` | `contracts/state-cells.yaml:338-348` | `前排` | Demo defaults to front sunroof segment. |
| `sunshade.position` | `contracts/state-cells.yaml:357-365` | `前排` | Demo defaults to front sunshade segment. |

## 4. File Cascade Impact

### 4.0 Non-UIUE Full-Repo Sweep Summary

Sweep scope: all current repo files except UIUE-named paths and huge generated/report blobs. The sweep searched for default-scope and zone anchors such as `主驾`, `副驾`, `全车`, `driver`, `passenger`, `position`, `direction`, `screen_type`, `scope.first`, `windowKeys`, `对象门`, and `确认主驾`.

| Bucket | Hits | Meaning for G01-G28 |
|---|---:|---|
| `Core/*` | 6 files | Live code impact: C3 execution, compiler/state applier, readback lookup, C5 generator, C6 bench, state store. |
| `Tests/MAformacCoreTests` | 12 files | Test/gold impact: explicit scope tests, readback tests, C6 alternative tests, old-frame fixtures. |
| `contracts` | 9 files | Contract and generated-source impact: C2 state cells, scenarios, allowlist, C6 JSONL, historical capabilities/function specs. |
| `scripts` + `generated` | 11 files | Codegen/proof impact: D-domain optional fields, strangler TODOs, generated maps/catalogs. |
| `openspec/changes` + `openspec/specs` | 21 files | Active specs must get default-scope deltas; archived/parked specs are provenance unless reopened by a new change. |
| `docs/research` | 38 files | Mostly historical/A2/research evidence; use as provenance, not live default-scope authority. |
| `docs/project`, `docs/loop-competition`, `docs/superpowers` | 21 files | Phase0/D1-D10 governance context; this pack should be linked, not merged into D1-D10. |
| `docs/dispatches`, `docs/handoffs`, old roadmap/baseline docs | 20+ files | Historical route artifacts that may mention fan-out/clarify; do not let them override this pack. |
| `dev`, `prototypes`, `referencerepo` | 10 files | Spike/prototype/reference only. They contain useful traps but are not live contracts. |

Conclusion: this is not only a C6/window cleanup. It is a cross-file contract decision that must land through C2 -> C3 -> compiler/state applier -> C5 -> C6 -> readback -> scenarios/tests, while A2-before artifacts are dispositioned as historical or migration-only.

### 4.1 Code Impact

| File | Phase | Required Change | Evidence |
|---|---|---|---|
| `contracts/state-cells.yaml` | OpenSpec/C2 first | Add `default_scope` to every scoped cell; validate membership in `scope`. | Scoped cells at `:59`, `:80`, `:97`, `:132`, `:159`, `:182`, `:193`, `:221`, `:318`, `:342`, `:361`. |
| `Core/Contracts/StateCellContractLookup.swift` or C2 model owner | implementation | Parse and expose `default_scope`. | Needed because C3/compiler/readback must not infer from YAML order. |
| `Core/Execution/C3ExecutionPipeline.swift` | implementation | Replace omitted-scope fallback `全车` with C2 `default_scope`; keep explicit fan-out. | `:170-179`. |
| `Core/Contracts/ToolContractCompiler.swift` | implementation | Replace `scope.first` and `window position ?? all` with shared C2 default scope; split explicit all from missing/unknown. | `:466-470`, `:553-565`. |
| `Core/Contracts/ContractLookups.swift` | implementation | Pass scope origin or equivalent metadata so channel renderers can low-emphasize, compact, or elide defaulted scope while keeping explicit scope and fan-out explicit. | `:166-179`. |
| `Core/Training/C5LoRATraining.swift` | implementation before retrain | Derive fallback candidates from C2 scope/default_scope; omitted-scope target should omit scope args. | `:1898-1899`. |
| `Core/Bench/C6VehicleToolBench.swift` | implementation before rebuild-c6 | Rewrite C6-MP-014/016/017 and regenerate JSONL; keep C6-MP-015 explicit all. | `:370-373`. |
| `contracts/c6-bench-cases.jsonl` | generated/contract | Regenerate after C6 source change; do not hand-edit. | `:21-24`. |
| `contracts/demo-scenarios.yaml` | contract seed | Scene3 default_scope expectation; scene4 explicit scope expectation. | `:104-133`. |
| `contracts/l1-demo-allowlist.yaml` | contract/doc | Fix wording that implies default/fan-out confusion. | `:56-74`. |
| `scripts/gen_tool_contract.py` | verification/codegen | Keep D-domain zone fields optional; add proof check for required zone fields. | `:124-134`; jq check shows 457 zone-ish tools / 0 with required. |
| `generated/D_domain.tools.demo.json` | generated | Regenerate only through codegen if schema changes; current required state is already correct. | jq proof above; generated file is minified, use tool check rather than line-level manual edit. |
| `Tests/MAformacCoreTests/C3ExecutionPipelineTests.swift` | test | Add omitted-scope default tests and preserve explicit full fan-out tests. | Existing explicit full fan-out checks at `Tests/MAformacCoreTests/C3ExecutionPipelineTests.swift:68-78`. |
| `Tests/MAformacCoreTests/ToolContractCompilerTests.swift` | test | Add compiler default_scope tests, especially window omitted scope. | Current driver default assertions exist at `Tests/MAformacCoreTests/ToolContractCompilerTests.swift:102`, `:121`, `:145-149`. |
| `Tests/MAformacCoreTests/C3ReadbackTemplateTests.swift` | test | Split scope-origin metadata, default-scope channel policy, and explicit-scope readback inclusion. | Current explicit readback expectations at `:20-23`, `:55-58`. |
| `Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift` | test | Review acceptable alternatives that hardcode old `set_cabin_window` plus `position=driver`; keep only if explicitly scoped or migrate to D-domain/default_scope. | Fixture alternative at `Tests/MAformacCoreTests/C6VehicleToolBenchTests.swift:38-46`. |
| `Core/Bench/C6VehicleToolBench.swift` readback renderer | implementation/test | C6 readback render path also needs scope-origin semantics, otherwise gold replay can force one channel's default-scope text policy into all evidence. | `Core/Bench/C6VehicleToolBench.swift:1190-1201`, `:1204-1223`, `:1261-1274`. |
| `Core/State/DemoVehicleStateStore.swift` | implementation/UI support | Keep internal scoped cells; mark legacy unscoped keys deprecated or bridge them one-way from scoped C2 state. They must not remain a parallel UI truth source after `default_scope` lands. | Scoped defaults at `:134-147`; legacy keys at `:150-156`; fallback text at `:160-168`. |
| `App/ContentView.swift` | UI/main-app | Define one presentation source before `default_scope` apply closeout. Current title mapping favors legacy keys, while scoped keys fall through to raw titles. | Legacy title cases at `:107-117`; A2 S3 deferred cleanup cites this class of issue at `S3-statecells-c3-naming-INDEX.md:30-34`. |
| `prototypes/*.html` | prototype/history | Keep passenger examples only as explicit demo hero cases; do not treat as default UX. | `prototypes/scheme1-deep-space-interactive.html:98`, `:161`; `prototypes/ui-concepts-3-schemes.html:139`, `:162-184`. |
| `dev/spike-e3/Sources/SpikeE3/main.swift` | historical spike / migration trap | Old spike tool specs require `position` for seat/window and use old B-frame `set_cabin_*`; do not reuse as current tool schema without migration. | Required position at `:412-420`, `:423-431`, `:433-442`; explicit/passenger eval cases at `:596-610`. |

### 4.2 Documentation Impact

| File | Required Change | Evidence |
|---|---|---|
| `openspec/specs/tool-execution/spec.md` | Add omitted-slot default behavior and fan-out distinction. | Existing fan-out-only requirement at `:62-73`. |
| `docs/tech-baseline-supplement-v0.2.md` | Mark object-unclear clarification language as historical/non-demo unless risk class still demands confirmation. | `:302-304`, `:319-325`. |
| `docs/c5-recovery-2026-06-22/grill-decisions.md` | Treat "confirm driver/passenger" example as older clarify evidence, not current omitted-scope default. | `:265-270`. |
| `docs/voice-pipeline-from-raw.md` and `docs/tech-baseline-from-raw.md` | Keep DialogueState zone as context memory, not a reason to interrupt omitted-scope commands. | `docs/tech-baseline-from-raw.md:276-285`. |
| `docs/uiue-roadmap-2026-06-23-draft.md` | G28 later: UIUE consumes state contract after default_scope lands; not a mainline blocker now. | `:61-64`, `:128-140`, `:198-199`. |
| `docs/project/phase0/README.md` | Link this accepted pack as a Phase0 route-control decision. | This patch adds the pointer. |
| `docs/grill-tournament/grill-decisions-master.md` | Link this pack as post-Q41 default-scope decision pack; do not fold into Q01-Q41 table. | This patch adds the pointer. |
| `docs/grill-tournament/cascade-inventory.md` | Add 2026-06-24 addendum for default-scope cascade. | This patch adds the pointer. |
| `docs/project/phase0/*D1-D10*` | Keep prior D1-D10 gate baseline intact; this pack is a new default-scope gate, not a rewrite of D1-D10. | Phase0 index lists D1-D10 pack and carrier files; this patch adds a separate default-scope section. |
| `docs/superpowers/plans/2026-06-24-phase0-d1-d10-openspec-gates.md` | Treat as prior plan/provenance for design.md discipline and gate baselines; do not use it as default-scope implementation authority. | Previous decision screenshot points to this D1-D10 baseline; default_scope requires its own OpenSpec carrier. |
| `openspec/changes/retrain-c5-lora-d-domain/{design.md,tasks.md}` | Add blocker tasks/AD before retrain: C2 default_scope, C5 omitted-scope targets, C5/C6 parity. | Active change exists and has design/tasks from prior Phase0 baseline. |
| `openspec/changes/rebuild-c6-four-layer-bench/{design.md,tasks.md}` | Add blocker tasks/AD before C6 acceptance: no omitted-to-all gold, no contradiction, readback scope-origin split. | Active change already references renderReadback in `proposal.md:27`, `tasks.md:24`. |
| `openspec/changes/migrate-d-domain-tool-surface` | Do not reopen A2 migration; add follow-up change instead. | A2 is merged code-only; see handoff `docs/handoffs/2026-06-24-a2-merged-d-domain.md:4-10`. |
| `openspec/changes/define-demo-golden-run-and-voice` | Golden-run must wait for stable default_scope/C6 IDs; do not encode stale all-window defaults. | A2 handoff defers golden/voice at `docs/handoffs/2026-06-24-a2-merged-d-domain.md:17-20`. |
| Archived OpenSpec changes under `openspec/changes/archive/**` | Treat `position fan-out` and old B-frame wording as provenance only. New behavior must be a new active change, not archive edits. | Examples: `openspec/changes/archive/2026-06-19-define-c1c2-contract/design.md:20`; `openspec/changes/_parked/README.md:17`. |
| `contracts/capabilities.yaml` | Historical B-frame capability source; dangerous if reused because it still has `status: active` rows and `position` required. It must not be used as current default-scope authority. | Seat/window required `position` at `contracts/capabilities.yaml:156-184`, `:223-251`, `:290-321`; old state cells at `:200`, `:267`, `:333`. |
| `contracts/function-spec-full-v0.yaml` | Historical reference template with old `positions`/passthrough examples; do not treat as live default-scope contract. | `:49-51`, `:63`, `:80`, `:101-106`. |
| `contracts/function-spec-full.yaml` | Generated full view contains many raw `position/direction/screen_type/name` domains; it is a raw-derived view, not default-scope policy. | Sweep found many raw slot anchors; default_scope belongs in C2 demo cells and generated proof gates, not hand edits here. |
| `generated/strangler_map.json` | Keep as strangler/migration debt; `TODO_GRILL_b_window_position_arg_or_name` is related but not current authority. | `generated/strangler_map.json:44`. |
| `contracts/qwen-tool-call-format.yaml` | No schema change unless tool catalog path/proof is updated; it points to D-domain catalogs, not default_scope policy. | `contracts/qwen-tool-call-format.yaml:19-24`. |

### 4.3 Historical And Migration-Only Hits

These files were hit by the non-UIUE sweep but should not become new live blockers:

| Area | Disposition |
|---|---|
| `dev/spike-e3/**` | Historical endpoint/tool-call spike. Keep as evidence for old required-position failure modes; do not reuse embedded tool specs. |
| `prototypes/**` | Visual/demo concept artifacts. Keep explicit passenger examples as showcase-only; no default behavior authority. |
| `referencerepo/**` | External/reference research. No implementation contract. |
| `docs/research/**` | Provenance and audit trail. Only promote a claim through grill master / phase0 / OpenSpec before using it as a live route rule. |
| `docs/dispatches/**` and `docs/handoffs/**` | Execution provenance. Do not use old dispatch wording as current default-scope policy. |
| Archived OpenSpec folders | Do not edit archives for this change. Add active change deltas and archive later. |

## 5. A2 Code-Refactor Impact

### 5.1 What This Does Not Change

A2 remains valid as a code-only D-domain migration. It was merged as PR #3 with tests green, and explicitly deferred training, performance evaluation, demo-golden-run, voice, and restricted decoding. See `docs/handoffs/2026-06-24-a2-merged-d-domain.md:4-10` and `:17-19`.

This decision pack is a post-A2 semantic debt and route-control blocker before retrain-c5/rebuild-c6. It is not evidence that A2 should be reverted.

### 5.2 A2-Before / A2-During / A2-After Split

| Layer | Impact | Evidence | Required Handling |
|---|---|---|---|
| A2-before baseline | Older docs favored object clarification for driver/passenger and R2 confirmation. That is too broad for demo omitted-scope defaults. | `docs/tech-baseline-supplement-v0.2.md:302-304`, `:323`; `docs/c5-recovery-2026-06-22/grill-decisions.md:265-270`. | Mark as historical or constrain to true ambiguity/high-risk/explicit cross-seat contexts. |
| A2-before prototypes | Prototype passenger/red-dress examples exist as explicit multimodal hero cases. | `prototypes/scheme1-deep-space-interactive.html:98`, `:161`. | Keep only as explicit scope/multimodal showcase; not default scope. |
| A2-during S3 | A2 intentionally built representative 6-family cells, not 191 full cells; no `default_scope` field was specified. | `docs/research/2026-06-23-a2-execution/S3-statecells-c3-naming-INDEX.md:14-18`, `:30-35`. | Add `default_scope` to current scoped representative cells first; do not reopen 191 full cell expansion. |
| A2-during C3 | A2 unified device→cell mapping, but omitted-scope target resolution still defaults to `全车`. | `Core/Execution/C3ExecutionPipeline.swift:160-174`. | Fix C3 default resolution before new C6/C5 acceptance. |
| A2-during compiler/applier | A2 moved to D-domain state application but kept a window special-case that turns omitted position into all windows. | `Core/Contracts/ToolContractCompiler.swift:466-470`, `:553-565`. | Replace with C2 default_scope and explicit all handling. |
| A2-during C5 | A2 converted sample generator to D-domain surface but did not settle default-scope training semantics. | `Core/Training/C5LoRATraining.swift:1898-1899`; A2 S5 says C5/C6 parity is the anti-0/34 gate at `docs/research/2026-06-23-a2-execution/S5-c6-bench-INDEX.md:48-52`. | Block retrain until C5 omitted/explicit scope targets match C2/C6. |
| A2-during C6 | A2 migrated C6 expected calls to D-domain but inherited/introduced default-scope contradictions in window cases. | `Core/Bench/C6VehicleToolBench.swift:370-373`; `contracts/c6-bench-cases.jsonl:21-24`. | Rebuild C6 cases before treating C6 as a valid gate for default-scope behavior. |
| A2-after debt | Device-cell codegen, 191 full cells, UI title cleanup, and old/new state key cleanup were already deferred. | `docs/research/2026-06-23-a2-execution/S_CLOSE-audit-absorption.md:19-28`; `S3-statecells-c3-naming-INDEX.md:30-35`. | Keep those deferred; default_scope is narrower and should land before retrain/rebuild. |

### 5.3 Stop-The-Train Rule

Do not start retrain-c5, rebuild-c6 as acceptance, or demo-golden-run on current default-scope semantics. Otherwise C5 can learn omitted window as all-window fan-out, C6 can score contradictions as gold, and readback/UI/TTS can disagree about whether defaulted "主驾" is omitted, low-emphasis, or explicit.

## 6. Next OpenSpec Carrier

Recommended carrier: `define-demo-default-scope`.

AD-DS-001 through AD-DS-009 are derived rows for the OpenSpec carrier. They are not new decisions. If an AD-DS row conflicts with this G01-G28 pack, G01-G28 wins and the AD-DS row must be rewritten.

| OpenSpec AD | Derived From |
|---|---|
| AD-DS-001 C2 `default_scope` authority | G06, G25 |
| AD-DS-002 missing vs explicit vs fan-out states | G04, G05, G12 |
| AD-DS-003 readback carries scope origin | G18 and pinned UIUE AD-8.7 evidence |
| AD-DS-004 low-emphasis scope is channel policy | G23 and pinned UIUE AD-8.1/AD-8.7 evidence |
| AD-DS-005 fan-out presentation aggregate-first | pinned UIUE AD-8.7 crack 6 decision |
| AD-DS-006 multi-turn aggregate label | pinned UIUE AD-8.7 user-story 4 decision |
| AD-DS-007 legacy unscoped demo keys deprecated | G23 plus Phase -1 P1-a finding |
| AD-DS-008 closed collection aliases | G05 plus Phase -1 P2-d finding |
| AD-DS-009 omitted scope x `clarify_tag` composition | G18, G27 plus Phase -1 P2-e finding |

Minimum OpenSpec content:

- `design.md`: Architecture Decisions for C2 `default_scope` authority, per-cell semantic defaulting, omitted vs explicit scope, collection aliases, omitted-scope x `clarify_tag` routing, legacy UI key disposition, `scope_origin` plus `presentation_scope_policy`, and generated-catalog optional fields.
- `specs/tool-execution/spec.md`: omitted slot default scenario, explicit scope scenario, collection-alias fan-out scenario, unaccepted collection-like wording scenario, and `clarify_tag` route-composition scenario.
- `tasks.md`: C2 schema, Swift parsing, C3 target resolution, state applier, C6 source + generated JSONL, C5 builder/renderer, readback/UIUE presentation-policy tests, legacy UI key source-choice tests, demo scenario updates, generated proof gate.
- Validation: `swift test`, `make verify`, `verify-gold`, generated catalog zone-field required proof, and a targeted C3/C6 default-scope test receipt.

## 7. Pre-Mortem

| Failure Mode | Why It Matters | Preventive Gate |
|---|---|---|
| Omitted `打开车窗` still opens all windows | Direct demo trust failure and C6/C5 poison. | C3 + state applier tests for omitted vs explicit all. |
| C6 gold keeps `position=全车` while state delta only driver | Fake green; 0/34 pattern in a smaller form. | C6 source and JSONL consistency check. |
| C5 emits hardcoded `左前/右前/后排` | Training/eval/runtime drift. | C2-derived candidates and C5/C6 parity tests. |
| Readback/UI/TTS disagree or force loud `主驾` | Demo either feels interruptive or leaves the customer unsure which window changed. | Scope-origin metadata plus per-channel presentation-policy tests. |
| Legacy UI cards read stale unscoped keys | Demo state can update scoped C2 truth while visible card still shows old `window.driver` / `seat.driver.*` values. | Legacy-key deprecation/adapter task plus ContentView read-path test. |
| `所有/都/四个` collection wording is treated inconsistently | Either all-window requests open only the driver window, or loose regex fans out too broadly. | Closed collection-alias matrix and reject/clarify for unaccepted collection-like wording. |
| Omitted scope is mistaken for a clarifyTag route decision | Fast path and slow path can each invent defaulting behavior. | Omitted-scope x `clarify_tag` route matrix: route first, target default second. |
| UIUE consumes stale all-window state | UI branch appears wrong after merge. | G28 retained as UIUE merge check only. |
| Old docs reintroduce "must clarify driver/passenger" | Route drift back to interruption-heavy UX. | Cascade inventory pointer and OpenSpec design decision. |
