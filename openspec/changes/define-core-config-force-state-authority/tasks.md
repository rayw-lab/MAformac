## 1. D16 Gate 1 Authority

- [x] 1.1 Create proposal, design, and `core-config-force-state` spec for `C018` and `C052` main-owned authority.
- [x] 1.2 Record D17 consumer allow/deny boundaries and D15 proof cap preservation.
- [x] 1.3 Write Gate 1 receipt with live repo truth, dirty split, harness, validation, audit results, and non-claims.
- [x] 1.4 Run `git diff --check`, `openspec validate define-core-config-force-state-authority --strict`, and `openspec validate --all --strict`.
- [x] 1.5 Run Hermes hard audit and require anchored PASS with empty P0/P1 findings.
- [ ] 1.6 Exact-stage only Gate 1 owned paths and commit `docs(main): define d16 core config force-state authority`.

## 2. D16 Gate 2 Core Config Code

- [x] 2.1 Before editing Swift symbols, run GitNexus impact/context for each target symbol or record an exact GitNexus blocker.
- [x] 2.2 Implement finite main-owned Core config / scene macro registry code under local project conventions.
- [x] 2.3 Add local/unit tests for stable known names, unknown-name fail-closed behavior, and no readiness/proof promotion.
- [x] 2.4 Run targeted Swift tests, OpenSpec validation, `git diff --check`, GitNexus `detect_changes`, and Hermes audit.

## 3. D16 Gate 3 Force-State Boundary Code

- [ ] 3.1 Before editing Swift symbols, run GitNexus impact/context for each target symbol or record an exact GitNexus blocker.
- [ ] 3.2 Implement demo/debug-isolated force-state boundary with bridge event provenance and no direct state-cell contract mutation.
- [ ] 3.3 Add local/unit tests proving production/customer-facing path is unavailable or fails closed.
- [ ] 3.4 Run targeted Swift tests, OpenSpec validation, `git diff --check`, GitNexus `detect_changes`, and Hermes audit.

## 4. D16 Gate 4 Upstream Verifier

- [ ] 4.1 Verify committed D16 diff from clean-worktree perspective and refresh GitNexus if needed.
- [ ] 4.2 Verify UIUE has not consumed D16 config/force-state names before release.
- [ ] 4.3 Record proof cap, non-claims, and `d17_release_gate: open|closed`.
- [ ] 4.4 Run required validation, Hermes audit, exact-stage verifier receipt, and commit.
