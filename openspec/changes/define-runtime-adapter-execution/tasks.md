## 1. Gate 1 OpenSpec Authority

- [x] 1.1 Create `define-runtime-adapter-execution` OpenSpec change.
- [x] 1.2 Define stable command identity, request fingerprint, in-memory ledger, adapter-owned mock write path, retry replay, already-state no-op, failure behavior, and provenance requirements.
- [x] 1.3 Record D12 pre-mortem, lessons learned, local/web cross-search, and iceberg teardown.
- [x] 1.4 Validate with `git diff --check`, `openspec validate define-runtime-adapter-execution --strict`, and `openspec validate --all --strict`.
- [x] 1.5 Run Hermes Gate 1 audit and require `HERMES_R5_D12_GATE_1_OPENSPEC_AUTHORITY_VERDICT: PASS`.

## 2. Gate 2 Runtime Adapter V0 Code

- [ ] 2.1 Run GitNexus impact before editing Swift symbols.
- [ ] 2.2 Implement minimal `DemoRuntimeAdapter` or equivalent mainline execution boundary.
- [ ] 2.3 Add local/unit tests for first execution write, retry replay no second write, already-state no-op, failed command no success ledger, and reused identity with changed request fails closed.
- [ ] 2.4 Validate with OpenSpec and target Swift tests.
- [ ] 2.5 Run GitNexus `detect_changes(scope=staged)` before commit.
- [ ] 2.6 Run Hermes Gate 2 audit and require `HERMES_R5_D12_GATE_2_RUNTIME_ADAPTER_V0_VERDICT: PASS`.

## 3. Gate 3 UIUE Consumer Guard

- [ ] 3.1 Re-read Gate 1 and Gate 2 outputs.
- [ ] 3.2 Decide whether any stable UIUE-facing names were introduced.
- [ ] 3.3 Write docs-only guard receipt or minimal UIUE consumer guard, without inventing shared fields.
- [ ] 3.4 Run validation and Hermes Gate 3 audit.

## 4. Gate 4 Commander Reconcile

- [ ] 4.1 Reconcile D12 into UIUE commander receipt, R5 map, and burndown according to actual Gate 2 proof.
- [ ] 4.2 Preserve proof caps, non-claims, and residuals.
- [ ] 4.3 Run validation and Hermes Gate 4 audit.
