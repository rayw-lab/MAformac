---
status: ready_for_dispatch
artifact_kind: implementation_dispatch
date: 2026-06-27
repo: /Users/wanglei/workspace/MAformac-uiue
branch: uiue/phase4-default-scope-presentation
target_session: 019f0915-dedd-7623-9fbf-89614088f16e
base_head_when_authored: 4a4aabb
parent_authorities:
  - docs/grill-tournament/uiue-r0-r2-grill-decisions-2026-06-27.md
  - docs/grill-tournament/uiue-r1-interaction-integrity-matrix-2026-06-27.md
  - docs/grill-tournament/uiue-r2b-layout-spacing-checker-spec-2026-06-27.md
  - openspec/changes/ui-presentation/specs/ui-presentation/spec.md
  - openspec/changes/ui-presentation/tasks.md
proof_class: local/docs-only
hermes_audit: pass_with_notes
audit_history:
  - Reports/uiue-r1-r2b-dispatch-hermes-audit-20260627-204619/hermes-audit.md
  - Reports/uiue-r1-r2b-dispatch-hermes-audit-20260627-204619/hermes-rerun-audit.md
non_claims:
  - no 8.C2 closure
  - no V-PASS
  - no mobile
  - no true_device
  - no runtime-ready
  - no voice-ready
  - no A-2 complete
---

# UIUE R1/R2b Implementation Dispatch

## 0. Routing

- **TO**: Codex session `019f0915-dedd-7623-9fbf-89614088f16e`.
- **FROM**: UIUE commander.
- **MODE**: single-owner implementation with verification, then read-only audit gates.
- **PRIORITY**: P0 for `8.C2` unblock preparation; still no `8.C2` closure.
- **Deliverable**: implement the first UIUE post-cascade implementation slice needed before rerunning `8.C2`: R1 interaction integrity projection/checks plus R2b layout/spacing checker receipt foundation, with tests, receipts, Hermes audit, and no over-claim.

This dispatch is an execution prompt. It is not a new SSOT, not an acceptance receipt, and not implementation proof.

Authorization boundary: parent docs are authority/gate definitions and still say implementation is not authorized by them alone. This audited dispatch is the commander authorization for the first implementation slice only when `hermes_audit` is `pass` or `pass_with_notes`. If this header says `pending` or `fail`, do not implement.

## 1. Cold Start Context

Project: MAformac UIUE isolated worktree, a SwiftUI presentation lane for the offline car-control demo assistant. This is a demo/presentation lane, not production car control.

Current state at authoring:

- Repo: `/Users/wanglei/workspace/MAformac-uiue`
- Branch: `uiue/phase4-default-scope-presentation`
- HEAD: `4a4aabb docs(uiue): define pre-ui interaction and layout gates`
- `8.C2` visual acceptance remains open in `openspec/changes/ui-presentation/tasks.md`.
- The worktree is dirty with unrelated UI/asset/test candidates and old evidence. You must re-probe live status before acting.

Read these first, in order:

1. `CLAUDE.md`
2. `docs/CURRENT.md`
3. `docs/README.md`
4. `docs/grill-tournament/uiue-r0-r2-grill-decisions-2026-06-27.md`
5. `docs/grill-tournament/uiue-r1-interaction-integrity-matrix-2026-06-27.md`
6. `docs/grill-tournament/uiue-r2b-layout-spacing-checker-spec-2026-06-27.md`
7. `openspec/changes/ui-presentation/specs/ui-presentation/spec.md`
8. `openspec/changes/ui-presentation/tasks.md`
9. `Tools/agent-platform-plugin-refs/README.md`
10. `.xcodebuildmcp/README.md`

## 2. Live Truth Start Gate

Run and record:

```bash
cd /Users/wanglei/workspace/MAformac-uiue
pwd
git rev-parse --abbrev-ref HEAD
git rev-parse --short HEAD
git status --short --branch
openspec validate ui-presentation --strict
if ! rg -n '^- \[ \] 8\.C2' openspec/changes/ui-presentation/tasks.md >/dev/null; then
  echo "BLOCKED: 8.C2 is not open"
  exit 65
fi
if rg -n '^- \[x\] 8\.C2' openspec/changes/ui-presentation/tasks.md >/dev/null; then
  echo "BLOCKED: 8.C2 is checked"
  exit 65
fi
test "$(rg -n '^- \[[ x]\] 8\.C2' openspec/changes/ui-presentation/tasks.md | wc -l | tr -d ' ')" = "1"
```

Stop before editing if any of these are false:

- branch is not `uiue/phase4-default-scope-presentation`;
- OpenSpec is invalid at start;
- `8.C2` is not `[ ]`;
- the current dirty files cannot be separated into owned/no-touch pathspecs.

Before and after any commit, rerun the two fail-closed `8.C2` commands above. If `openspec/changes/ui-presentation/tasks.md` is edited, inspect the diff and prove no hunk changes the `8.C2` checkbox.

## 2.1 Dirty Ownership Gate

Before editing, create a short ownership table in your working notes or closeout:

| bucket | paths | allowed action |
|---|---|---|
| `owned_new` | files you will create in this dispatch | edit/stage only by exact pathspec |
| `owned_existing_clean` | clean files you will edit | edit/stage only by exact pathspec |
| `preexisting_dirty_reowned` | existing dirty files you must take over for R1/R2b | snapshot pre-edit diff, then edit only owned hunks |
| `no_touch_dirty` | dirty files unrelated to this dispatch | do not edit/stage |
| `generated_evidence` | fresh receipts/screenshots/reports from this dispatch | keep under a fresh dated directory |

This dispatch pre-authorizes re-owning only these currently dirty implementation candidates, and only if your live probe shows they are necessary for Task A/B:

- `App/ContentView.swift`
- `App/ContextCapsule.swift`
- `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift`
- `App/Assets.xcassets/ContextCapsule.imageset/context-capsule.png`

For each re-owned dirty candidate, save the pre-edit diff before touching it:

```bash
mkdir -p Reports/uiue-r1-r2b-implementation-preedit-diffs
git diff -- App/ContentView.swift > Reports/uiue-r1-r2b-implementation-preedit-diffs/App-ContentView.preexisting.diff
git diff -- App/ContextCapsule.swift > Reports/uiue-r1-r2b-implementation-preedit-diffs/App-ContextCapsule.preexisting.diff
git diff -- MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift > Reports/uiue-r1-r2b-implementation-preedit-diffs/UIC2VisualAcceptanceUITests.preexisting.diff
git diff -- App/Assets.xcassets/ContextCapsule.imageset/context-capsule.png > Reports/uiue-r1-r2b-implementation-preedit-diffs/context-capsule.preexisting.diff
```

If you need any other dirty/no-touch path, stop and ask commander. Closeout must distinguish preexisting hunks from new hunks. Commit must use exact pathspecs, never `git add .`.

## 3. Scope Contract

### Goal

Make the smallest implementation step that turns the pre-UI preparation docs into enforceable local/simulator evidence without closing visual acceptance.

### Scope In

Prefer this order:

1. R1 interaction projection/checks derived from existing mapper/contract/catalog/store.
2. R1 tests or receipt that prove no fake affordance, no third value/range/enum SSOT, and mock writeback/readback path integrity.
3. R2b layout/spacing checker foundation that emits a structural receipt using UI tree/screenshot metadata.
4. Minimal docs/router/evidence updates needed to explain exactly what was implemented and what remains open.

Allowed path families, only as needed:

- `Core/Presentation/`
- `App/` files that already own UIUE presentation controls
- `MAformacIOSUITests/`
- `Tests/MAformacCoreTests/`
- `Tools/checks/`
- `docs/grill-tournament/`
- `docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/`
- `docs/CURRENT.md`
- `docs/README.md`
- `openspec/changes/ui-presentation/`

### Scope Out

- No `8.C2` closure.
- No L3 signing.
- No push unless 磊哥 explicitly authorizes it in your thread.
- No mainline merge.
- No voice/runtime/model/backend readiness.
- No global `make verify-all` integration for `verify-uiue-interactions`.
- No final capsule art signoff.
- No broad UI redesign beyond the R1/R2b defects you can prove.

### No-Touch Unless Explicitly Re-owned

At authoring, these are dirty/no-touch candidates and must not be swept into a mixed commit:

- `App/Assets.xcassets/ContextCapsule.imageset/context-capsule.png`
- `App/ContentView.swift`
- `App/ContextCapsule.swift`
- `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift`
- `docs/research/2026-06-25-cc-harness-mechanism-review/harness-upgrade.spec.md`
- `docs/uiue-roadmap-2026-06-23.md`
- `docs/handoffs/*`
- `docs/loop-competition/2026-06-27-uiue-r0-r2-grill-matrix/`
- old visual evidence dirs under `docs/research/2026-06-25-a2-execution/`
- `docs/research/2026-06-26-ios2026-frontend-trends-migration/`
- `docs/superpowers/plans/2026-06-27-uiue-8c2-l0-l3-visual-acceptance.md`

If your implementation genuinely must own one of the currently dirty UI/asset/test files, first write an ownership note in the closeout and keep it in a separate pathspec slice. Do not imply old dirty code was introduced by this dispatch unless you can prove it.

## 4. Implementation Tasks

### Task A - R1 Interaction Integrity

Implement the smallest R1 mechanism that makes interaction claims checkable.

Acceptable shapes:

- A read-only `StateCellInteractionPolicy`-equivalent projection derived from existing sources; or
- A matrix-driven checker/test that proves the same facts without introducing a new Swift type.

Hard requirements:

- `family` derives from `FamilyCardIDMapper`.
- primary/default cell derives from `FamilyPrimaryCellMapper`.
- `ui_value_type` derives from `UIValueTypeMapper`.
- range/step/snap derives from `ValueRangeMapper` and `StateCellPresentationCatalog.executionRange`.
- enum/options derives from `StateCellPresentationCatalog.enumValues` and `BadgeOptionMapper`.
- writeback reaches `ExpandedFamilyCard` -> `ContentView.applyMockTransition` -> `DemoVehicleStateStore.applyMockTransition`.
- summary/readback uses the existing presentation/store path; do not add view-local readback formatting.
- proof class remains `local`, `unit`, or `simulator`; never L3.

Minimum test targets:

- projection does not define its own ranges/options;
- process/read-only cells do not expose fake selectable options;
- at least one representative row for dial, percent, stepper, toggle, and badge proves gesture/writeback/readback;
- ambient/wiper active-cell vs baseline primary ambiguity is documented or tested;
- stepper drag and ring boundary remain explicit gaps unless actually covered.

Do not add `verify-uiue-interactions` to global `make verify-all`. If you add a local command, make it UIUE-scoped and documented as candidate only.

### Task B - R2b Layout Integrity / Visual Spacing

Implement the smallest structural checker or receipt path that can block layout bugs without pretending to judge aesthetics.

Preferred path:

- `Tools/checks/check-uiue-layout-spacing.py` or equivalent local checker;
- consumes exported UI tree frames and screenshot metadata;
- emits one JSON receipt matching `docs/grill-tournament/uiue-r2b-layout-spacing-checker-spec-2026-06-27.md`.

Required output fields:

- `status`
- `threshold_source`
- `proof_class`
- `source_ui_tree`
- `source_screenshot_metadata`
- `overlap_pairs`
- `min_gaps`
- `zone_budget`
- `safe_area_violations`
- `crop_paths`
- `warnings`
- `non_claims`

Required structural checks:

- overlap among capsule, right controls, orb, dialogue/cards, and mic dock;
- blank/white-edge leakage from capsule crop;
- zone budget and safe-area;
- right-side settings/refresh outside capsule and aligned;
- capsule centered;
- mic dock not occluding cards;
- orb spacing/halo budget.

This checker must not consume GPT Image 2 / anchor images as geometry truth. Anchors are direction, composition intent, and aesthetic bar for human L3 only.

If a threshold is not yet defined for a check, that check must return `WARN` or `BLOCKED_FOR_THRESHOLD`, not `PASS`. Every threshold must cite a source: formal spec, checker spec, UI design decision, measured baseline, or explicit dispatch default.

This dispatch intentionally tightens the parent checker spec for the first implementation slice by adding `threshold_source` and `BLOCKED_FOR_THRESHOLD`. If the checker lands, update `docs/grill-tournament/uiue-r2b-layout-spacing-checker-spec-2026-06-27.md` or the new checker receipt docs so the stricter schema does not remain dispatch-only.

### Task C - Evidence Package

If you produce new local/simulator evidence, place it under a fresh, dated subdirectory:

`docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/`

Each evidence package must record:

- `captured_at`
- command used
- device/simulator
- scheme
- launch args
- proof class
- source UI tree path
- screenshot/metadata path
- checker receipt path
- non-claims

Evidence may support R1/R2b readiness. It does not close `8.C2`.

### Task D - Minimal Cascade

Only update docs/OpenSpec when behavior or gates actually changed.

Allowed:

- add a short implementation receipt link to the relevant R1/R2b docs;
- update `docs/CURRENT.md` / `docs/README.md` if there is a new authority/receipt;
- update OpenSpec only for observable behavior/gate/proof boundary changes.

Forbidden:

- dumping matrices into OpenSpec;
- ticking `8.C2`;
- writing structural checker PASS as L3/aesthetic pass;
- changing storyboard narrative decisions unless a design boundary changed.

## 5. Bug Iceberg Trigger

Use `/Users/wanglei/.codex/skills/bug-iceberg-teardown/SKILL.md` immediately when you find any bug, failed fix, surprising test failure, fake affordance, stale readback, layout collapse, proof mismatch, or dirty-tree provenance conflict.

Do not just patch the visible bug. Produce a short teardown note in the closeout with this shape:

```md
## Bug Iceberg Teardown

### 结论
一句话判断：是不是冰山一角，以及冰山是什么。

### 可见 bug
- 用户看到什么:
- 系统本应怎样:
- 当前修复声称解决什么:

### 证据链
| Evidence | Location | What it proves |
|---|---|---|

### 链路 teardown
Expected chain:
Observed break:
Hidden seams:

### 冰山扩散
| Direction | Risk | Evidence | Severity |
|---|---|---|---|

### Tiger / Paper-tiger / Elephant

### Immediate / Class-level / Governance fixes
```

Minimum same-class lenses:

- same family;
- same value type / enum / schema;
- same writeback path;
- same snapshot/readback path;
- same verification gap;
- same fake-affordance pattern;
- same proof/status overclaim pattern.

Meta-cognitive rule: a bug is not only a bug if it exposes an authority gap, duplicated SSOT, missing gate, or proof-class upgrade risk. Fix the instance, then block recurrence at the smallest class-level gate.

If no bug is found, say `no bug found during this dispatch` in the final closeout. If any bug is found, include the teardown note inline or link to its receipt path.

## 6. Metacognitive Guardrails

Carry these lessons into every decision:

- **Truth before transcript**: repo/config/test stdout outranks previous agent prose.
- **Authority typing**: every artifact is one of authority, dispatch, receipt, or evidence. Do not mix roles.
- **Proof-class honesty**: local/unit/simulator proof cannot become L3, mobile, true-device, or V-PASS.
- **No third SSOT**: projection is allowed only if it derives from existing mapper/contract/catalog/store.
- **No fake affordance**: if a control cannot write back and read back, it must not look actionable.
- **No screenshot-as-semantics**: visual screenshot can prove pixels/layout, not state semantics or product acceptance.
- **Dirty tree discipline**: pathspec first, closeout second, commit last. Never `git add .`.
- **Contradiction handling**: if live evidence contradicts this dispatch, stop and report the contradiction with file/line/command output.
- **Hermes is a critic, not a rubber stamp**: absorb true findings, refute false positives with evidence, and do not green yourself while P0/P1 remains unresolved.

## 7. Validation Gates

Run the smallest relevant gate first, then broaden.

Always required:

```bash
git diff --check
openspec validate ui-presentation --strict
if ! rg -n '^- \[ \] 8\.C2' openspec/changes/ui-presentation/tasks.md >/dev/null; then exit 65; fi
if rg -n '^- \[x\] 8\.C2' openspec/changes/ui-presentation/tasks.md >/dev/null; then exit 65; fi
test "$(rg -n '^- \[[ x]\] 8\.C2' openspec/changes/ui-presentation/tasks.md | wc -l | tr -d ' ')" = "1"
```

Changed-path gates:

| changed path | required validation |
|---|---|
| `Core/Presentation/**` | `swift test` plus the relevant test class/filter if available. |
| `Tests/MAformacCoreTests/**` | `swift test`; report the exact test count/output tail. |
| `App/**` with interaction/layout claims | iOS simulator build plus the relevant UI smoke, UI tree, screenshot, and receipt evidence. Build-only is not enough for interaction/layout claims. |
| `MAformacIOSUITests/**` | run the relevant UI test with `xcodebuild test` or the repo-documented equivalent; if environment blocks it, report the exact blocker and next-best proof. |
| `Tools/checks/**` | run `--help` plus at least one fixture or fresh evidence receipt. |
| `openspec/changes/ui-presentation/**` | `openspec validate ui-presentation --strict`. |
| `docs/**` only | `git diff --check`, owned markdown trailing whitespace scan, and link integrity by grep where relevant. |

If Swift/Core changes:

```bash
swift test
```

If iOS UI changes or R2b checker consumes simulator evidence:

Use the project build profile from `.xcodebuildmcp/README.md` and target `MAformacIOS` on `iPhone 17 Pro Max`. Capture command output and simulator evidence paths. If xcodebuildmcp is available in your surface, first call `session_show_defaults`; otherwise use the repo's documented `xcodebuild`/`simctl` commands.

For UI tests, prefer the narrowest relevant command, for example:

```bash
xcodebuild -scheme MAformacIOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' test -only-testing:MAformacIOSUITests/UIC2VisualAcceptanceUITests
```

If the exact `-only-testing` selector differs, discover the valid target/test name and record the command you actually used.

If a checker script is added:

```bash
python3 Tools/checks/check-uiue-layout-spacing.py --help
# plus one fixture or fresh evidence run that emits a JSON receipt
```

If OpenSpec changes:

`openspec validate ui-presentation --strict` must pass after the change.

## 8. Audit Gates

### 8.1 Codex Read-Only Audit

After implementation and local validation, run or spawn a read-only Codex audit if your surface supports it. The audit must check:

- only owned paths changed;
- no third SSOT;
- no fake affordance;
- no `8.C2` closure;
- no L3/V-PASS/mobile/true_device/runtime/voice/A-2 overclaim;
- R1 source file:line evidence is repo-relative;
- R2b checker remains structural only;
- OpenSpec still validates;
- staged/commit pathspec is exact if committing.

### 8.2 Hermes 20-Minute Cross-Vendor Audit

Hermes audit is mandatory before claiming DONE. It is capped at 20 minutes.

Suggested command:

```bash
mkdir -p Reports/uiue-r1-r2b-implementation-audit-$(date +%Y%m%d-%H%M%S)
# Write prompt to Reports/.../hermes-prompt.md, then:
/Users/wanglei/.codex/skills/hermes-cli-glm52-code/scripts/hermes_glm52_code.py run \
  --prompt-file Reports/<run_dir>/hermes-prompt.md \
  --timeout 1200 > Reports/<run_dir>/hermes-audit.md
```

Hermes prompt must include:

- this dispatch path;
- `git status --short --branch`;
- changed files;
- validation outputs;
- source-file evidence for R1/R2b claims;
- forbidden claims;
- exact question: "Find P0/P1 issues that would make this implementation unsafe to use before rerunning 8.C2."

If Hermes returns P0/P1:

1. verify each finding against repo truth;
2. fix true findings or mark blocked with evidence;
3. rerun relevant validation;
4. if time remains, rerun Hermes or perform a targeted follow-up prompt;
5. do not claim DONE until P0/P1 is resolved or explicitly blocked.

If Hermes times out:

Report `PARTIAL`: `Hermes audit timed out at 20min; local validation status is ...; only missing cross-vendor audit result`.

## 9. Commit / Push Policy

Do not push.

Commit only if:

- scope is clear;
- validation passes;
- audit has no unresolved P0/P1;
- staged paths are exact;
- no old dirty/no-touch files are mixed in.

Required before commit:

```bash
git diff --name-only -- <exact owned paths>
git diff --cached --name-status
git diff --cached --check
```

Suggested commit message:

`fix(uiue): enforce r1 interactions and r2b layout gates`

If the work is split, prefer separate commits:

1. R1 interaction projection/checks;
2. R2b checker/receipt;
3. docs/evidence cascade.

## 10. Final Response Contract

Reply in Chinese with:

- `verdict`: DONE / PARTIAL / BLOCKED;
- base HEAD and final HEAD;
- changed files;
- commit hash if committed;
- validation commands and results;
- Codex audit result;
- Hermes audit result and path;
- proof class;
- owned/unowned/no-touch;
- `8.C2` status;
- non-claims;
- bug iceberg teardown summary if any bug was found;
- residual risks;
- exact next step.

Forbidden final phrasing:

- "8.C2 complete"
- "V-PASS"
- "mobile pass"
- "true-device pass"
- "runtime-ready"
- "voice-ready"
- "A-2 complete"

Allowed phrasing:

- "local/unit/simulator evidence for R1/R2b only"
- "`8.C2` remains open"
- "L3 still requires 磊哥 human 5-gate"

## 11. Dispatcher Notes

This dispatch itself was authored from live repo truth and passed Hermes audit before being sent to the target session. If the copy you receive says `hermes_audit: pending` or `hermes_audit: fail`, ask commander for the audited revision before implementation.
