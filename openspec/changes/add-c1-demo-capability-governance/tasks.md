## 1. Carrier and ownership gates

- [ ] 1.1 In a dedicated clean worktree, validate this change with `openspec validate add-c1-demo-capability-governance --strict` and `openspec validate --all --strict`; record the exact base SHA and command outputs. **Superpowers: verification-before-completion.**
- [ ] 1.2 Add a mechanical ownership audit that fails if governance owns presentation fields, execution owns customer copy, the bridge owns matrix eligibility, either MODIFIED delta is absent, or any `runtime-presentation-payload` capability appears. Write failing fixtures first, then the checker. **Superpowers: test-driven-development.**
- [ ] 1.3 Add a 38-ID coverage assertion for `CG-002,004,005,007,008,009,014,015,019,022,023,024,025,026,027,028,036,038,039,041,044,045,048,049,050,053,054,055,057,058,059,060,063,065,068,074,076,080`; fail on missing, duplicate or extra P1/D0G IDs. **Superpowers: test-driven-development.**
- [ ] 1.4 Before each implementation slice, create an isolated worktree from the recorded implementation base, list owned/no-touch paths, and keep all commits limited to that slice; never use `git add .`. **Superpowers: using-git-worktrees.**

## 2. Matrix source, schema and checker

- [ ] 2.1 Write failing checker fixtures for missing same-cell basis, unknown `primary_class`, duplicate identity, FastPath-only `canDemo=true`, dropped no-representative cell and free-string reason; then add `contracts/demo-capability-matrix.json`, its schema and checker. **Superpowers: test-driven-development.**
- [ ] 2.2 Make the checker preserve exactly 120 cells, recompute the ratified class counts and derive `canDemo` only from mounted/semantic/state-cell/local-runtime-readback evidence; emit a conflict receipt instead of a hand-edited green exception. **Superpowers: test-driven-development.**
- [ ] 2.3 Write failing deterministic-generation tests before adding the Swift matrix catalog; assert 120 cells, source digest, closed enums, conditional-lane separation and byte-identical regeneration. **Superpowers: test-driven-development.**
- [ ] 2.4 Run task-specific tests, GitNexus `detect_changes` against the slice base, and commit only matrix-owned files with a receipt containing base/head SHA, touched paths, commands and proof class. **Superpowers: verification-before-completion.**

## 3. Fallback catalog and enum projection

- [ ] 3.1 Write failing tests for missing/duplicate 10-family×4-class pairs, unknown/free-string enums, raw `finiteReason` in customer copy, missing dialog/TTS, generic leakage and generated-copy drift; then add the authoritative fallback source, schema, checker and generated catalog. **Superpowers: test-driven-development.**
- [ ] 3.2 Assert the locked internal reason → `fallback_reason` → safe `reasonKind` mapping, including `fast_path_no_match -> unsupported_no_available_tool`, attributable unmounted `name_rejected`, typed safety gap and clarification-not-refusal behavior. **Superpowers: test-driven-development.**
- [ ] 3.3 Keep UI badge labels separate from authoritative dialog/TTS and report in-scope execution pass rate separately from out-of-scope fallback quality/generic leakage. **Superpowers: test-driven-development.**
- [ ] 3.4 Run task-specific tests, deterministic regeneration, GitNexus `detect_changes`, and commit only fallback-owned files with a source/generated digest receipt. **Superpowers: verification-before-completion.**

## 4. Router ingress and bounded CG-036 execution

- [ ] 4.1 Before editing any existing function/class/method, run GitNexus impact and write a receipt; HIGH/CRITICAL runner or trace surfaces require exact commander risk acknowledgement before edits. **Superpowers: verification-before-completion.**
- [ ] 4.2 Write a failing router test proving two frames survive in order and zero frames remain fail-closed; then add a plan-level ingress while preserving any required single-frame compatibility wrapper. **Superpowers: test-driven-development.**
- [ ] 4.3 Write failing execution tests for accepted+unmounted, accepted+safety-denied, refused-only no-mutation, stale/unknown/length failure and unreviewed-extra-action rejection; then implement the smallest bounded multi-intent seam. **Superpowers: test-driven-development.**
- [ ] 4.4 Write failing trace tests for item identity, accepted readback, refused internal reason, observed calls, canonical before/after state and one-turn correlation; then extend only internal execution trace facts. **Superpowers: test-driven-development.**
- [ ] 4.5 Run targeted router/runner/trace tests, GitNexus `detect_changes`, and commit each LOW/HIGH slice separately with touched-symbol and residual-risk receipts. **Superpowers: verification-before-completion.**

## 5. Existing bridge projection only

- [ ] 5.1 Before editing bridge symbols, run GitNexus impact on the partial adapter and public payload types; if existing schema cannot express the required projection, stop and create an explicit versioned migration decision rather than adding an ad-hoc field. **Superpowers: verification-before-completion.**
- [ ] 5.2 Write failing bridge/fixture tests for missing accepted readback, lost refused identity, wrong safe reason, raw internal reason leakage, unknown top-level field and proof-cap upgrade; then project execution facts through existing bridge-owned fields. **Superpowers: test-driven-development.**
- [ ] 5.3 Preserve main-owned schema/version, customer-safe `reasonKind`, cards/readbacks, private-marker redaction and UIUE consumer fail-closed behavior; do not create any C1-owned payload field. **Superpowers: test-driven-development.**
- [ ] 5.4 Run bridge/public-fixture/consumer tests, record fixture digests, run GitNexus `detect_changes`, and commit only bridge-owned files. **Superpowers: verification-before-completion.**

## 6. Fallback probes and no-action proof

- [ ] 6.1 Write failing fixtures for missing/duplicate family-reason pairs, forced state delta, forced tool call count 1, missing trace, safe-copy mismatch and raw-reason leakage; then define 40 probes referencing the authoritative fallback catalog. **Superpowers: test-driven-development.**
- [ ] 6.2 Generate receipts from observed canonical before/after mock state and tool calls; require `case_count=40`, complete pair coverage, zero calls and no state mutation for pure fallback/refusal/clarify paths. **Superpowers: test-driven-development.**
- [ ] 6.3 Run probe tests and checker, capture the durable run-dir receipt, run GitNexus `detect_changes`, and commit only probe-owned files. **Superpowers: verification-before-completion.**

## 7. S10 prelay, mounted no-delta and rollback guards

- [ ] 7.1 Write failing S10 checker fixtures for missing joint rate, stale run identity, prose-only rate and wrong min formula; then enforce `joint=min(hedged,can_question)` without claiming S10 ran. **Superpowers: test-driven-development.**
- [ ] 7.2 Write failing mounted-policy fixtures for growth without matrix evidence, `canDemo` growth without S10/owner gates, missing golden/readback and rollback that drops fallback; then implement the guard. **Superpowers: test-driven-development.**
- [ ] 7.3 Compare mounted authority at implementation base and head and require zero delta for C1; keep matrix/fallback/probe prelay allowed and record CG-080 non-claims. **Superpowers: verification-before-completion.**

## 8. CI, anchor comparison and closeout

- [ ] 8.1 Write failing tests for generic/dynamic CI receipt identity, then wire governance, matrix, fallback, probe, S10 and mounted gates into source-free verification without hardcoding one change ID. **Superpowers: test-driven-development.**
- [ ] 8.2 Add a durable anchor checker that compares base/head matrix counts and digests, mounted delta, 40-pair coverage, partial producer/consumer evidence and separate execution/fallback metrics; reject stale base or proof-class upgrade. **Superpowers: test-driven-development.**
- [ ] 8.3 Integrate slice commits in dependency order and run `openspec validate --all --strict`, targeted tests, `swift test`, `make verify-all`, the MAformacMac Xcode build, `make verify-ci`, `git diff --check`, and GitNexus `detect_changes`. **Superpowers: verification-before-completion.**
- [ ] 8.4 Have an independent auditor rerun authority, 38/38 coverage, partial execution+bridge, 40 probes, mounted no-delta, CI and final gates; only P0/P1=0 may close this change. **Superpowers: requesting-code-review + verification-before-completion.**
- [ ] 8.5 Keep closeout proof classes separate and retain non-claims: no mounted 1→N, S9/S10 execution, C5/C6 acceptance, candidate, mobile, true-device, live API, operator-pass or V-PASS. **Superpowers: verification-before-completion.**
