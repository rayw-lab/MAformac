## 1. D16 Gate 1 Authority

- [x] 1.1 Create proposal, design, and `core-config-force-state` spec for `C018` and `C052` main-owned authority.
- [x] 1.2 Record D17 consumer allow/deny boundaries and D15 proof cap preservation.
- [x] 1.3 Write Gate 1 receipt with live repo truth, dirty split, harness, validation, audit results, and non-claims.
- [x] 1.4 Run `git diff --check`, `openspec validate define-core-config-force-state-authority --strict`, and `openspec validate --all --strict`.
- [x] 1.5 Run Hermes hard audit and require anchored PASS with empty P0/P1 findings.
- [x] 1.6 Exact-stage only Gate 1 owned paths and commit `docs(main): define d16 core config force-state authority`.

## 2. D16 Gate 2 Core Config Code

- [x] 2.1 Before editing Swift symbols, run GitNexus impact/context for each target symbol or record an exact GitNexus blocker.
- [x] 2.2 Implement finite main-owned Core config / scene macro registry code under local project conventions.
- [x] 2.3 Add local/unit tests for stable known names, unknown-name fail-closed behavior, and no readiness/proof promotion.
- [x] 2.4 Run targeted Swift tests, OpenSpec validation, `git diff --check`, GitNexus `detect_changes`, and Hermes audit.

## 3. D16 Gate 3 Force-State Boundary Code

- [x] 3.1 Before editing Swift symbols, run GitNexus impact/context for each target symbol or record an exact GitNexus blocker.
- [x] 3.2 Implement demo/debug-isolated force-state boundary with bridge event provenance and no direct state-cell contract mutation.
- [x] 3.3 Add local/unit tests proving production/customer-facing path is unavailable or fails closed.
- [x] 3.4 Run targeted Swift tests, OpenSpec validation, `git diff --check`, GitNexus `detect_changes`, and Hermes audit.

## 4. D16 Gate 4 Upstream Verifier

- [x] 4.1 Verify committed D16 diff from clean-worktree perspective and refresh GitNexus if needed.
- [x] 4.2 Verify UIUE has not consumed D16 config/force-state names before release.
- [x] 4.3 Record proof cap, non-claims, and `d17_release_gate: closed`.
- [ ] 4.4 Run required validation, Hermes audit, exact-stage verifier receipt, and commit. Gate4 Hermes returned FAIL/P1; D17 release is closed pending a separate fix/reopen decision.

## 4R. D16 Gate 4R Force-State Codable Bypass Repair And Reopen

- [x] 4R.1 Re-probe main/UIUE live truth and confirm D17 has not started.
- [x] 4R.2 Remove or harden external construction paths for `DemoForceStateContext`, including synthesized `Decodable` / `Codable`.
- [x] 4R.3 Add local/unit and external package proof that `DemoForceStateContext` is not externally decodable.
- [x] 4R.4 Preserve fail-closed tests for `.customerFacing`, empty context, duplicate dimensions, and missing `.demoHarness` provenance.
- [x] 4R.5 Run local validation, OpenSpec validation, GitNexus context/detect, and UIUE read-only bounded grep.
- [x] 4R.6 Run one audit pass, record audit result, decide `d17_release_gate: open`, exact-stage Gate4R owned paths, and commit.
