# Tasks: implement-t09-session-lifecycle-schema-core (K1 schema-only)

```text
change_id: implement-t09-session-lifecycle-schema-core
authority: W8-K0-HUMAN-AGREE-PACKET (B2 exact K1 schema-only bind)
documentary_basis: define-t09-session-lifecycle-recovery (contract only; not coding authority)
basis_head_expected: f5c963fcb5d48a5d7c0ace67a423ac1a39517313
proof_ceiling: PARTIAL_SCHEMA_ONLY
future_create_count: 5
future_modify_count: 0
status: K1_CLOSEOUT_PARTIAL_SCHEMA_ONLY
self_signed_review_clear: false
coding_writer: single Grok code writer (K1 CREATE complete; mechanical gates 5.2–5.5 archived); mutation writer remains Grok; released at closeout
independent_reviewer: non-producer Claude; verifies only, does not write production Core; released at closeout
revision: REVISION_1
```

> 格式：numbered `##` 段；每任务 `- [ ] X.Y …`；全部初始 unchecked。
> 每条目标 = 单 session 可完成；写清 **产出 + 验收**；需要时标注 Superpowers：`[TDD]` / `[verification]` / `[debugging-if-red]`。
> 本 artifact **不** self-CLEAR；独立审通过前 coding 仍受 agree-before-build 约束。

## 1. Preflight / authority

> K1 preflight evidence: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-13-w8-single-lane/reports/W8-K1-PREFLIGHT-AND-OPENSPEC-AGREE.md` (`W8_K1_PREFLIGHT|PASS_OPEN_RED|DONE`).

- [x] 1.1 Capture fresh git identity for this worktree and compare to basis.
  - Output: receipt snippet with `git rev-parse HEAD`, `git rev-parse @{u}` (or documented no-upstream), `git status --short --branch`, `git rev-parse --show-toplevel`.
  - Acceptance: HEAD equals basis `f5c963fcb5d48a5d7c0ace67a423ac1a39517313` (full sha) **or** document exact divergence and **HOLD** coding until re-agree; worktree is the authorized K1 lane path; main / other trees are **no-touch**.
  - Superpowers: `[verification]`

- [x] 1.2 Verify exact five future code paths are **absent** (pre-CREATE).
  - Output: command log proving non-existence of:
    1. `Core/Lifecycle/SessionLifecycleTypes.swift`
    2. `Core/Lifecycle/SessionLifecycleFacts.swift`
    3. `Core/Lifecycle/SessionLifecycleCoordinator.swift`
    4. `Tests/MAformacCoreTests/SessionLifecycleFixtures.swift`
    5. `Tests/MAformacCoreTests/SessionLifecycleCoordinatorTests.swift`
  - Acceptance: all five absent; any pre-existing copy → **HOLD / re-agree** (not silent overwrite).
  - Superpowers: `[verification]`

- [x] 1.3 Confirm main / production / sibling surfaces remain no-touch (read-only probe).
  - Output: short NOT_TOUCH checklist covering `DemoRuntimeSessionRunner`, `C3ExecutionPipeline`, `DemoSliceRoute`, `FrontstageRuntimeComposition`, `FrontstageVoiceSession`, `ContentView`, `Package.swift`, `Makefile`, `Tools/checks/**`, W7/W9/W10/W5c/V2 trees.
  - Acceptance: no plan to MODIFY any of the above; probes only.
  - Superpowers: `[verification]`

- [x] 1.4 Confirm GitNexus index equality policy for preflight (no code edits yet).
  - Output: GitNexus status / indexed-commit readback vs live HEAD (or explicit “index tool unavailable” blocker note with retry plan).
  - Acceptance: indexed commit equals coding HEAD **or** HOLD until reindex policy satisfied; do not invent LOW risk from absence of new symbols.
  - Superpowers: `[verification]`

- [x] 1.5 Confirm **no existing symbols** are planned for edit → **no HIGH/CRITICAL risk-ack required** for K1.
  - Output: statement `risk_ack_high_critical: NONE_EXACT / OPEN_INDEPENDENT` with planned op table CREATE×5 / MODIFY×0.
  - Acceptance: zero existing-symbol edits in plan; if any MODIFY to existing production appears later → immediate **HOLD / re-agree** (task 7.x).
  - Superpowers: `[verification]`

- [x] 1.6 Gate coding: OpenSpec agree-before-build checklist still holds.
  - Output: checklist state for independent artifact review, `openspec validate` readiness, tasks ready, fresh rehash, zero HIGH/CRITICAL edits.
  - Acceptance: coding steps (section 2+) start only when gates closed or explicit controller key; otherwise remain blocked with exact open gate listed.
  - Superpowers: `[verification]`

## 2. RED — fixtures + focused XCTest (before production Core types)

> Single later Grok code writer. RED must be **real** compile/test failure (stdout + rc), not prose.

- [x] 2.1 CREATE `Tests/MAformacCoreTests/SessionLifecycleFixtures.swift` — immutable fixtures only.
  - Output: new file with **exact** fixture ids **F01, F02, F03, F09, F10, F11** only (no F04–F08/F12–F14).
  - Content rules: immutable inputs + expected outcomes only; table-driven or constants; no production types beyond what tests need to compile against stub/import surface; no shared static mutable lifecycle state.
  - Fixture semantics (must match B2 / design / delta):
    - **F01** non-owner mutation vs live owner → rejected; snapshot/generation unchanged
    - **F02** forbidden source→target (incl. recoveryReady entry / new-generation) → rejected; zero mutation
    - **F03** start+cancel same logical batch (any input order) → one deterministic immutable final outcome; start before cancel-as-terminal
    - **F09** settled first cause + later terminal/cancel → original preserved; later duplicate/rejected
    - **F10** unknown / cross-session / unknown generation → fail-closed; zero partial mutation
    - **F11** refused/cancelled/unsupported/timeout/failure → never accepted/success fact classification (schema-only; no UI strings)
  - Acceptance: file exists; only those six ids; inputs/expected are immutable and reviewable without App runtime.
  - Superpowers: `[TDD]`

- [x] 2.2 CREATE `Tests/MAformacCoreTests/SessionLifecycleCoordinatorTests.swift` — focused XCTest suite.
  - Output: new XCTestCase covering at least:
    - wrong authority → zero mutation (F01)
    - illegal / recoveryReady / new-generation → zero mutation (F02)
    - unknown / cross-session / unknown generation → fail-closed (F10)
    - compound batch order input-independent → single final immutable snapshot (F03)
    - duplicate terminal → first cause immutable (F09)
    - error classes never success (F11)
    - parent session vs child turn non-claim: K1 does not register children / no fan-out / no fence join
  - Rules: per-test **fresh** coordinator/owner; XCTest (not forced Swift Testing); no SwiftUI; no shared static mutable owner.
  - Acceptance: suite discovers tests; names/assertions map 1:1 to fixtures above.
  - Superpowers: `[TDD]`

- [x] 2.3 Run exact targeted RED and archive failure evidence **before** production Core types exist.
  - Output: command log for targeted filter (e.g. `swift test --filter SessionLifecycleCoordinatorTests`) with **non-zero rc** and failing stdout/stderr saved to W8 run-dir evidence path (path named in implementation report).
  - Acceptance:
    - failure is **compile and/or test red** because Core production types/coordinator are absent or stubs insufficient — **not** a hand-written “expected red” prose claim
    - while types are still absent / insufficient to run the suite, **compile-red is a legitimate RED** stage (document command + compiler diagnostics)
    - **once types are sufficient for the suite to run**, discovered test count **MUST be > 0**
    - discovered test count **= 0 is always a hard fail** (never green; **no** “compile-red **or** count>0” escape that treats count=0 as acceptable after the suite can run)
  - Superpowers: `[TDD]` `[verification]`

- [x] 2.4 If RED is “false green” or “silent skip”, treat as blocker.
  - Output: diagnosis: empty suite, disabled tests, or stubs that make assertions pass without Core.
  - Acceptance: must not proceed to GREEN until RED is real; use `[debugging-if-red]` to fix harness, not to weaken fixtures.
  - Superpowers: `[debugging-if-red]` `[verification]`

## 3. GREEN — types and facts (CREATE only)

- [x] 3.1 CREATE `Core/Lifecycle/SessionLifecycleTypes.swift`.
  - Output: identity / generation / owner authority / observable states (`ready`, `active`, `terminal`, `recoveryReady`) / dispositions / causes / rejection types as value types; `Sendable` / `Equatable` where appropriate; `recoveryReady` **observable** but not K1-executable entry.
  - Acceptance: compiles with Package directory sources; no SwiftUI; no global singleton; no MainActor requirement on K1 owner types.
  - Superpowers: `[TDD]` (implements against fixture expectations)

- [x] 3.2 CREATE `Core/Lifecycle/SessionLifecycleFacts.swift`.
  - Output: events; immutable snapshot / result / fact / outcome classification; explicit non-success classes at least refused / cancelled / unsupported / timeout / failure; F11 schema-only (no UI strings, no presentation matrix import).
  - Acceptance: error-class facts cannot be typed as accepted/success; types do **not** detect runtime mock vs real vehicle-control context; any non-authorization of real vehicle control is **evidence claim classification** (see delta K1 evidence), not a schema runtime-context branch — no production seam.
  - Superpowers: `[TDD]`

- [x] 3.3 Re-run targeted suite after types/facts exist (may still red on coordinator).
  - Output: intermediate test log.
  - Acceptance: progress toward GREEN documented; no MODIFY of existing production files.
  - Superpowers: `[verification]` `[debugging-if-red]`

## 4. GREEN — coordinator + suite green

- [x] 4.1 CREATE `Core/Lifecycle/SessionLifecycleCoordinator.swift`.
  - Output: **synchronous `final class`** single owner; **no** global shared, **no** internal `Task`, **no** `actor` owner; owner-bound apply with authority identity; executable transition table **only** `ready→active` and `active→terminal`; recoveryReady entry / new-generation / other transitions **rejected** with zero mutation; **unique batch API** = single **`apply(batch:)`** (no submit+commit dual API); batch path = **canonicalize** (start before terminal/cancel) → **scratch-snapshot** simulation in **canonical order** validating the **whole** batch (must **not** judge each event independently against the initial state alone) → on full validity **one-shot commit** of authoritative snapshot/fact; **no** intermediate authoritative snapshot exposure mid-batch; **one** final immutable snapshot only; once-write first cause/disposition; **parent session** layer cancel disposition/cause only — **no** children registry, **no** fan-out, **no** parent schema hierarchy model; **no** ledger/event stream requirement, **no** required wall-clock / dependency injection pin.
  - Acceptance: matches design D1–D7 (esp. D4 batch shape) and delta requirements; still CREATE-only path; no dual batch API; no mid-batch snapshot.
  - Superpowers: `[TDD]`

- [x] 4.2 Drive targeted suite to GREEN.
  - Output: `swift test --filter SessionLifecycleCoordinatorTests` rc0 log; note discovered test count.
  - Acceptance: all F01/F02/F03/F09/F10/F11 paths green; per-test fresh owner still holds; no production file MODIFY; discovered test count **> 0** (count=0 hard fail).
  - Superpowers: `[TDD]` `[verification]` `[debugging-if-red]`

- [x] 4.3 Confirm parent/child non-claim in code surface.
  - Output: grep/scan of new Core files for child registry / fan-out / fence join APIs — expect **absent**.
  - Acceptance: no child registration API; cancel is parent **session**-layer disposition/cause only (no fan-out, no hierarchy).
  - Superpowers: `[verification]`

- [x] 4.4 Dedicated batch guards: no intermediate snapshot + order independence (F03 / D4).
  - Output: focused tests (may live in `SessionLifecycleCoordinatorTests` + fixtures F03) proving:
    1. same logical batch in **any input order** → **identical** final immutable outcome (start-before-cancel canonical)
    2. **no** intermediate authoritative snapshot is observable between batch start and final commit (scratch-only until commit)
    3. validation path is **not** equivalent to “each event judged only against the pre-batch initial state independently” when later events depend on earlier canonical transitions inside the batch
  - Acceptance: all three guards green; dual-API / mid-batch publish paths absent; failure of any guard → suite red, not documentation-only.
  - Superpowers: `[TDD]` `[verification]`

## 5. Verification (mechanical gates)

- [x] 5.1 Targeted filter: `swift test --filter SessionLifecycleCoordinatorTests`.
  - Output: full stdout/stderr + rc; **exact discovered test count**.
  - Acceptance: rc0 **and** discovered test count **> 0** (count=0 is hard fail / HOLD).
  - Superpowers: `[verification]`

- [x] 5.2 Full Core test target / package suite as project convention.
  - Output: `swift test` (full) log + rc (or documented exact package/target command used).
  - Acceptance: rc0 or exact residual failure listed; do not hide unrelated pre-existing failures; do not fake green.
  - Superpowers: `[verification]`
  - Evidence: controller full suite **rc0** — executed **837** / skipped **6** / failures **0** (`W8-K1-MECHANICAL-GATES-EVIDENCE`).

- [x] 5.3 OpenSpec strict validation.
  - Output: `openspec validate implement-t09-session-lifecycle-schema-core --strict` rc + `openspec validate --all --strict` rc (or project-required equivalent).
  - Acceptance: change-level strict rc0 required for apply-ready claim; if `--all` has pre-existing unrelated failure, **record exact residual** — do not invent green.
  - Superpowers: `[verification]`
  - Evidence: change strict **rc0**; all strict **31/31** (`W8-K1-MECHANICAL-GATES-EVIDENCE`).

- [x] 5.4 Exact diff scan (CREATE five / MODIFY none).
  - Output: `git status` + `git diff --name-status` (and untracked list) relative to basis; classification table for every path.
  - Acceptance:
    - future code CREATE **exactly** the five paths in §3.2 of B2 / design D8
    - **MODIFY none** of existing tracked production/test sources
    - OpenSpec carrier files (`openspec/changes/implement-t09-session-lifecycle-schema-core/**`) counted **separately** from the five code CREATE
    - no `Package.swift` / `Makefile` / App / existing production edits
    - `git diff --check` clean (no whitespace errors on owned diffs)
  - Superpowers: `[verification]`
  - Evidence: tracked diff **none**; untracked exact **5 Swift + 5 OpenSpec**; `git diff --check` **rc0** (`W8-K1-MECHANICAL-GATES-EVIDENCE`).

- [x] 5.5 Fresh GitNexus reindex / index equality + `detect_changes` (when tooling available).
  - Output: reindex command log if needed; index equality; detect_changes summary for new symbols / expected flows only.
  - Acceptance: new symbols only / expected flows; **no CRITICAL smuggle** via existing-symbol edits; absence of new symbols must not be reported as LOW risk for unedited CRITICAL seams.
  - Superpowers: `[verification]`
  - Evidence: indexed=current=`f5c963f…`; detect_changes on exact 5 Swift temporary intent-to-add → 202 changed symbols / 5 affected / 5 files / risk medium; 5 new lifecycle internal flows; no existing production consumer; exact reset after; analyze auto-touch AGENTS/CLAUDE restored no-diff (`W8-K1-MECHANICAL-GATES-EVIDENCE`).

- [x] 5.6 Deliberate-red mutations in a **disposable copy only** (never the authoritative worktree).
  - Output: disposable copy path + five variant logs, each with command / rc / output proving suite **red**:
    - (a) bypass authority (accept non-owner mutation)
    - (b) allow recoveryReady executable entry
    - (c) overwrite first cause on duplicate terminal
    - (d) map error-class fact to success/accepted
    - (e) remove/empty exact suite so discovery count = 0 **or** equivalent empty-suite red
  - Acceptance: each variant shows red; evidence preserved; copy **disposed** after; authoritative worktree untouched by mutations; **mutation writer remains Grok**; independent verifier **only runs/checks**, does not author mutation code in authority tree.
  - Superpowers: `[verification]` `[TDD]`

## 6. Independent review / closeout

- [x] 6.1 Code writer emits implementation report to W8 run-dir via Grok secretary.
  - Output: report under `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-13-w8-single-lane/` (or active W8 run-dir) with: five CREATE paths, zero MODIFY claim, test commands/rc, fixture list, deliberate-red summary pointers, claim ceiling.
  - Acceptance: report exists; does not claim W8 DONE / production / runtime / operator / V-PASS.
  - Superpowers: `[verification]`
  - Evidence: `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-13-w8-single-lane/reports/W8-SINGLE-SLICE-IMPLEMENTATION-REPORT.md`

- [x] 6.2 Independent non-producer reviewer verifies status / diff / tests / negatives / detect_changes.
  - Output: independent review note (producer ≠ auditor) with PASS/HOLD and P0/P1 ledger.
  - Acceptance: reviewer does not implement Core; any self-CLEAR by producer is invalid; OPEN findings → HOLD apply claim.
  - Superpowers: `[verification]`
  - Evidence: independent review path `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-13-w8-single-lane/reports/W8-SINGLE-SLICE-INDEPENDENT-REVIEW.md` sha256 `95ec70515f07797af0d825494c3d004f869e36c48aa692b58894c0e46d9cbe78`; Claude session `a97d574b-c2f2-4f88-bc99-04af47f722d0`; P0/P1=0.

- [x] 6.3 Grok secretary writes closeout receipt.
  - Output: receipt with HEAD, five paths, test counts, openspec rc, deliberate-red disposition, residual risks (K2–K6 deferred, production seam open, risk-ack open).
  - Acceptance: receipt hashable; final claim text **exactly** `PARTIAL_SCHEMA_ONLY`.
  - Superpowers: `[verification]`
  - Evidence: receipt path `/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-13-w8-single-lane/receipts/W8-SINGLE-SLICE-CLOSEOUT.md`

- [x] 6.4 Final claim freeze.
  - Output: explicit non-claims block in report/receipt.
  - Acceptance: **exactly** `PARTIAL_SCHEMA_ONLY`; **not** W8 DONE; **not** production/runtime/operator/V-PASS; K2–K6 and production seam remain **deferred / risk-ack open**.
  - Superpowers: `[verification]`
  - Evidence: exact claim **`PARTIAL_SCHEMA_ONLY`** (K1 schema-only closeout; not W8 DONE / production / runtime / operator / V-PASS).

## 7. Stoplines

- [ ] 7.1 Any existing-file **MODIFY** appears → **HOLD / PARTIAL** with exact path list; no commit/push/PR/merge.
  - Output: blocker record + restore plan (delete accidental edits or re-agree expanded scope).
  - Acceptance: coding does not continue until scope re-agreed or tree restored to CREATE-only five.

- [ ] 7.2 Any HIGH/CRITICAL existing-symbol edit path proposed or detected → **HOLD**; risk-ack remains OPEN_INDEPENDENT; do not self-sign.
  - Output: GitNexus impact (if any) + stopline.
  - Acceptance: no silent “accept runner risk”.

- [ ] 7.3 Production seam attempt (Runner/Pipeline/UI/composition/voice) → **HOLD**; out of K1.
  - Output: rejected scope note.

- [ ] 7.4 Discovered targeted test count **= 0** → **HOLD** (not green).
  - Output: discovery dump + fix task back to section 2/5.

- [ ] 7.5 `openspec validate … --strict` failure → **HOLD**; do not invent repair outside carrier; record exact errors.
  - Output: validate log.

- [ ] 7.6 Deliberate-red variant fails to go red (mutation still green) → **HOLD / PARTIAL**; treat as missing enforce; fix production or tests before closeout.
  - Output: variant id + unexpected green log.
  - Superpowers: `[debugging-if-red]` `[verification]`

- [ ] 7.7 Governance stopline: no commit / push / PR / merge from this tasks list unless a **separate** explicit key is issued.
  - Output: non-action confirmation in closeout.
  - Acceptance: K1 schema-only may leave uncommitted CREATE files until authorized; never push on this task sheet alone.

---

```text
tasks_status: K1_CLOSEOUT_PARTIAL_SCHEMA_ONLY
self_signed_review_clear: false
proof_ceiling: PARTIAL_SCHEMA_ONLY
marker: K1_CLOSEOUT_PARTIAL_SCHEMA_ONLY
fixtures: F01,F02,F03,F09,F10,F11
tasks_3_1: [x] SessionLifecycleTypes.swift CREATE
tasks_3_2: [x] SessionLifecycleFacts.swift CREATE
tasks_3_3: [x] intermediate RED archived
tasks_4_1: [x] SessionLifecycleCoordinator.swift CREATE
tasks_4_2: [x] targeted GREEN rc0 16/0 (controller 2026-07-13 16:31:14 +08:00)
tasks_4_3: [x] parent/child non-claim scan clean (controller readback)
tasks_4_4: [x] F03 batch order-independence + final-only green
tasks_5_1: [x] targeted filter rc0 count=16
tasks_5_2: [x] full package suite rc0 837/6skip/0fail
tasks_5_3: [x] openspec change strict rc0 + all 31/31
tasks_5_4: [x] exact diff: tracked none; untracked 5 Swift+5 OpenSpec; diff --check rc0
tasks_5_5: [x] gitnexus indexed=f5c963f; detect_changes 5 files medium; reset empty
tasks_5_6: [x] deliberate-red 5/5 PASS (A–D suite red; E count gate 97); copies disposed
tasks_6_1: [x] implementation report frozen
tasks_6_2: [x] independent review PASS P0/P1=0 (Claude a97d574b…; sha 95ec7051…)
tasks_6_3: [x] closeout receipt path receipts/W8-SINGLE-SLICE-CLOSEOUT.md
tasks_6_4: [x] exact claim PARTIAL_SCHEMA_ONLY
tasks_7_x: [ ] stoplines remain unchecked (no fire)
future_create:
  - Core/Lifecycle/SessionLifecycleTypes.swift   (CREATED; frozen)
  - Core/Lifecycle/SessionLifecycleFacts.swift   (CREATED; frozen)
  - Core/Lifecycle/SessionLifecycleCoordinator.swift  (CREATED; frozen)
  - Tests/MAformacCoreTests/SessionLifecycleFixtures.swift
  - Tests/MAformacCoreTests/SessionLifecycleCoordinatorTests.swift
future_modify: none
revision_note: |
  K1 closeout partial schema-only. 6.2 independent review PASS (P0/P1=0).
  Accepted P2 residual: empty batch + duplicate batch tests (coverage residual, not blocker).
  K2-K6 deferred. No production seam. No commit/merge/push.
  Does NOT self-sign CLEAR beyond independent review PASS; claim ceiling PARTIAL_SCHEMA_ONLY.
touched_path: openspec/changes/implement-t09-session-lifecycle-schema-core/tasks.md
```
