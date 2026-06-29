## 1. Gate 1 OpenSpec Authority

- [x] 1.1 Create `define-runtime-adapter-execution` OpenSpec change.
- [x] 1.2 Define stable command identity, request fingerprint, in-memory ledger, adapter-owned mock write path, retry replay, already-state no-op, failure behavior, and provenance requirements.
- [x] 1.3 Record D12 pre-mortem, lessons learned, local/web cross-search, and iceberg teardown.
- [x] 1.4 Validate with `git diff --check`, `openspec validate define-runtime-adapter-execution --strict`, and `openspec validate --all --strict`.
- [x] 1.5 Run Hermes Gate 1 audit and require `HERMES_R5_D12_GATE_1_OPENSPEC_AUTHORITY_VERDICT: PASS`.

## 2. D12 Gate 2 Runtime Adapter V0 Code

Historical D12 row closed by the D12 Gate 2 receipt. It remains local/unit only and does not include C3 wiring.

- [x] 2.1 Run GitNexus impact before editing Swift symbols.
- [x] 2.2 Implement minimal `DemoRuntimeAdapter` or equivalent mainline execution boundary.
- [x] 2.3 Add local/unit tests for first execution write, retry replay no second write, already-state no-op, failed command no success ledger, and reused identity with changed request fails closed.
- [x] 2.4 Validate with OpenSpec and target Swift tests.
- [x] 2.5 Run GitNexus `detect_changes(scope=staged)` before commit.
- [x] 2.6 Run Hermes Gate 2 audit and require `HERMES_R5_D12_GATE_2_RUNTIME_ADAPTER_V0_VERDICT: PASS`.

## 3. D12 Gate 3 UIUE Consumer Guard

Historical D12 row closed by the UIUE D12 Gate 3 receipt. It remains docs/local guard proof only and does not mean UIUE consumes Runtime Adapter V0.

- [x] 3.1 Re-read Gate 1 and Gate 2 outputs.
- [x] 3.2 Decide whether any stable UIUE-facing names were introduced.
- [x] 3.3 Write docs-only guard receipt or minimal UIUE consumer guard, without inventing shared fields.
- [x] 3.4 Run validation and Hermes Gate 3 audit.

## 4. D12 Gate 4 Commander Reconcile

Historical D12 row closed by the UIUE D12 commander reconcile receipt. It remains docs/local reconcile proof only.

- [x] 4.1 Reconcile D12 into UIUE commander receipt, R5 map, and burndown according to actual Gate 2 proof.
- [x] 4.2 Preserve proof caps, non-claims, and residuals.
- [x] 4.3 Run validation and Hermes Gate 4 audit.

## 5. D13 Gate 1 C3 Integration Authority

- [x] 5.1 Re-probe main/UIUE HEAD and dirty split before Gate 1 writes.
- [x] 5.2 Re-read D13 dispatch, authority docs, D1-D12 phase review, D12 receipts, and relevant C3/adapter/frame surfaces.
- [x] 5.3 Refresh GitNexus main index and verify `DemoRuntimeAdapter` and `C3ExecutionPipeline` are visible.
- [x] 5.4 Run GitNexus impact for C3/adapter/store/frame candidate surfaces and record high-risk no-touch decisions.
- [x] 5.5 Run Codex native subagent plan audit for Gate 1.
- [x] 5.6 Update OpenSpec C3-path authority for per-transition identity, adapter-local frame construction, retry proof cap, and UIUE no-payload-contract boundary.
- [x] 5.7 Validate with `git diff --check`, `openspec validate define-runtime-adapter-execution --strict`, and `openspec validate --all --strict`.
- [x] 5.8 Run Hermes Gate 1 audit and require `HERMES_R5_D13_GATE_1_C3_AUTHORITY_VERDICT: PASS`.

## 6. D13 Gate 2 Main C3 Runtime Adapter Integration Code

- [x] 6.1 Reconfirm Gate 1 Hermes PASS before Swift edits.
- [x] 6.2 Run GitNexus impact before touching any Swift symbol, and require extra audit for any touched HIGH/CRITICAL symbol.
- [x] 6.3 Integrate Runtime Adapter V0 into `C3ExecutionPipeline` without editing `ToolCallFrame`.
- [x] 6.4 Add local/unit tests for C3 adapter routing, per-transition identity, retry replay, conflict fail-closed, and failed-attempt no-success-ledger behavior.
- [x] 6.5 Validate with target Swift tests, `git diff --check`, `openspec validate define-runtime-adapter-execution --strict`, and `openspec validate --all --strict`.
- [x] 6.6 Run GitNexus `detect_changes(scope=staged)` before commit.
- [x] 6.7 Run Hermes Gate 2 audit and require `HERMES_R5_D13_GATE_2_C3_INTEGRATION_VERDICT: PASS`.

## 7. D13 Gate 3 UIUE Boundary Guard

- [x] 7.1 Reconfirm Gate 2 Hermes PASS before UIUE docs work.
- [x] 7.2 Search UIUE for adapter-private field consumption and distinguish existing presentation vocabulary from adapter provenance.
- [x] 7.3 Write UIUE docs-only boundary guard without creating a payload contract.
- [x] 7.4 Validate with `git diff --check`, `openspec validate ui-presentation --strict`, and targeted grep evidence.
- [x] 7.5 Run Hermes Gate 3 audit and require `HERMES_R5_D13_GATE_3_UIUE_BOUNDARY_VERDICT: PASS`.

## 8. D13 Gate 4 Commander Reconcile

- [x] 8.1 Reconfirm Gate 3 Hermes PASS before map/burndown work.
- [x] 8.2 Update UIUE reconcile receipt, decomposition map, and burndown according to actual D13 proof.
- [x] 8.3 Preserve proof caps, non-claims, access gaps, and stop conditions.
- [x] 8.4 Validate with `git diff --check` and `openspec validate ui-presentation --strict`.
- [x] 8.5 Run Hermes Gate 4 audit and require `HERMES_R5_D13_GATE_4_RECONCILE_VERDICT: PASS`.

## 9. D14 Gate 1 Runtime Adapter Residual OpenSpec Authority

- [x] 9.1 Re-probe main/UIUE HEAD and dirty split before Gate 1 writes.
- [x] 9.2 Re-read D14 dispatch, D13 receipts, D1-D12 phase review, active OpenSpec, and runtime adapter/C3/store/test surfaces.
- [x] 9.3 Refresh or verify main GitNexus index and inspect `DemoRuntimeAdapter`, `C3ExecutionPipeline`, `RuntimeAdapterBox`, and `DemoVehicleStateStore.applyMockTransition`.
- [x] 9.4 Record GitNexus impact for Gate 2 candidate symbols and treat HIGH/CRITICAL as explicit audit risk.
- [x] 9.5 Define D14 authority for session-scoped ledger boundary, exact stale retry ordering, failure ledger taxonomy, readback reconciliation, and `RuntimeAdapterBox` concurrency boundary.
- [x] 9.6 Validate with `git diff --check`, `openspec validate define-runtime-adapter-execution --strict`, and `openspec validate --all --strict`.
- [x] 9.7 Run Codex native subagent Gate 1 audit within 1200 seconds and require empty P0/P1.

## 10. D14 Gate 2 Main Code + Tests

- [x] 10.1 Reconfirm Gate 1 Codex subagent audit PASS before Swift edits.
- [x] 10.2 Run GitNexus impact before touching any Swift symbol and require pitfall loop/subagent audit for touched HIGH/CRITICAL symbols.
- [x] 10.3 Implement the D14 session ledger, stale retry ordering, failure ledger, readback reconciliation, and concurrency-boundary slice without editing `ToolCallFrame` or UIUE.
- [x] 10.4 Add/extend targeted local/unit tests for D14 semantics.
- [x] 10.5 Validate with target Swift tests, `git diff --check`, `openspec validate define-runtime-adapter-execution --strict`, and `openspec validate --all --strict`.
- [x] 10.6 Run GitNexus `detect_changes(scope=staged)` before commit.
- [x] 10.7 Run Codex native subagent Gate 2 audit within 1200 seconds and require empty P0/P1.

## 11. D14 Gate 3 GitNexus + Substitute Verifier

- [x] 11.1 Re-check or refresh GitNexus after Gate 2 commit.
- [x] 11.2 Run GitNexus context/impact/detect on the committed D14 surface and explain any HIGH/CRITICAL results.
- [x] 11.3 Record operator Hermes quota override; do not claim Hermes anchor; run substitute Codex verifier requiring empty P0/P1.
- [x] 11.4 Rerun local validation: `git diff --check`, OpenSpec strict validates, and target Swift tests.
- [x] 11.5 Run Codex native subagent Gate 3 audit within 1200 seconds after GitNexus evidence is available.

## 12. D14 Gate 4 Commander Reconcile

- [ ] 12.1 Reconfirm Gate 3 PASS before UIUE docs work.
- [ ] 12.2 Update UIUE reconcile receipt, decomposition map, and burndown according to actual D14 proof.
- [ ] 12.3 Preserve proof caps, non-claims, access gaps, C005/C061/C018/C052 dispositions, and D15 boundary.
- [ ] 12.4 Validate with `git diff --check`, `openspec validate ui-presentation --strict`, `git diff --cached --name-only`, and `git diff --cached --check`.
- [ ] 12.5 Run Codex native subagent Gate 4 audit within 1200 seconds and require empty P0/P1.

## 13. D18 Gate 1 Runtime Durability Authority

- [x] 13.1 Re-probe main/UIUE HEAD, branch, dirty split, and cached state before Gate 1 writes.
- [x] 13.2 Re-read D18+D19 dispatch, D14/D15/D16+D17 authority chain, active Runtime Adapter OpenSpec, and UIUE deny-list residuals.
- [x] 13.3 Re-check external idempotency references for request identity, request fingerprint, failure-after-validation, and safe retry pitfalls.
- [x] 13.4 Define D18 authority for local file-backed durable adapter ledger, cross-adapter reconstruction, C3 cross-pipeline reconstruction, failure/corrupt-entry fail-closed behavior, and private-ledger no-leak boundary.
- [x] 13.5 Preserve proof caps: `local_durable_adapter_ledger` only; no production runtime, mobile, true-device, live, UIUE merge, V-PASS, S-PASS, U-PASS, A-2, voice/model/golden/endpoint readiness, or R5 completion claim.
- [x] 13.6 Validate with `git diff --check`, `openspec validate define-runtime-adapter-execution --strict`, `openspec validate define-runtime-presentation-bridge --strict`, and `openspec validate --all --strict`.

## 14. D18 Gate 2 Durable Ledger Code And Tests

- [x] 14.1 Run GitNexus context/impact for `DemoRuntimeAdapter` and any edited Swift symbol before edits.
- [x] 14.2 Implement the smallest explicit local durable ledger storage boundary for adapter success/failure records using deterministic temporary-directory-friendly storage.
- [x] 14.3 Add local/unit tests for cross-adapter success replay, fingerprint mismatch fail-closed, corrupt/unknown entry fail-closed, failure-not-success replay, and readback reconciliation.
- [x] 14.4 Validate with target Swift tests, OpenSpec strict checks, `git diff --check`, and staged diff checks.
- [x] 14.5 Run GitNexus `detect_changes` on the exact staged Gate 2 diff before commit.

## 15. D18 Gate 3 C3 Reconstruction Integration Tests

- [x] 15.1 Run GitNexus context/impact for `C3ExecutionPipeline`, `RuntimeAdapterBox`, `DemoRuntimeAdapter`, and any edited symbol before edits.
- [x] 15.2 Integrate the local durable ledger boundary into C3 reconstruction with explicit local storage injection that does not leak adapter-private fields.
- [x] 15.3 Add local/integration tests for cross-pipeline settled parent replay, changed parent fingerprint fail-closed, corrupt/missing durable row fail-closed, and D14 stale/readback regression coverage.
- [x] 15.4 Validate with target Swift tests, OpenSpec strict checks, `git diff --check`, and staged diff checks.
- [x] 15.5 Run GitNexus `detect_changes` on the exact staged Gate 3 diff before commit.
- [x] 15.6 Run Hermes round 1 over Gates 1-3 with anchor `HERMES_R5_D18_GATES_1_3_RUNTIME_DURABILITY_VERDICT: FAIL`; fix owned P1/P2 post-audit and proceed under operator no-rerun override.

## 16. D18 Gate 4 Private Payload Boundary Verifier

- [x] 16.1 Re-probe main and UIUE repo truth before verifier writes; keep UIUE read-only and preserve source dispatch artifacts.
- [x] 16.2 Cross-search main presentation payload surfaces and UIUE consumer guard surfaces for private adapter, durable ledger, raw runtime store, raw model output, and training receipt names.
- [x] 16.3 Classify grep hits as implementation-private, sanitizer/deny-list, negative test, OpenSpec authority, or receipt documentation; stop for any UIUE consumption of D18 durable ledger terms.
- [x] 16.4 Fix the main presentation sanitizer gap for `rawRuntimeStore`, which was forbidden by authority/UIUE deny-list but not explicitly redacted by main.
- [x] 16.5 Validate with target main/UIUE tests, OpenSpec strict checks, `git diff --check`, staged diff check, and GitNexus `detect_changes` on the exact staged Gate 4 diff.
- [x] 16.6 Record Gate4 receipt and carry Hermes round 1 truth as `FAIL/P1 fixed post-audit under operator no-rerun override`, not as Hermes PASS.
