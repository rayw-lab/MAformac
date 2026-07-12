## 1. D16 Gate 1 Authority

> The checked items in Sections 1–4R are historical D16 evidence only: `HISTORICAL_CHECKBOX_ONLY`. They do not satisfy M16-011/M16-012 and do not prove production force write enforcement.

- [x] 1.1 Create proposal, design, and `core-config-force-state` spec for `C018` and `C052` main-owned authority.
- [x] 1.2 Record D17 consumer allow/deny boundaries and D15 proof cap preservation.
- [x] 1.3 Write Gate 1 receipt with live repo truth, dirty split, harness, validation, audit results, and non-claims.
- [x] 1.4 Run `git diff --check`, `openspec validate define-core-config-force-state-authority --strict`, and `openspec validate --all --strict`.
- [x] 1.5 Run Hermes hard audit and require anchored PASS with empty P0/P1 findings.
- [x] 1.6 Exact-stage only Gate 1 owned paths and commit `docs(main): define d16 core config force-state authority`.

## 2. D16 Gate 2 Core Config Code

> `HISTORICAL_CHECKBOX_ONLY`: these checks record the earlier D16 slice and are not the M16-011 catalog/migration contract.

- [x] 2.1 Before editing Swift symbols, run GitNexus impact/context for each target symbol or record an exact GitNexus blocker.
- [x] 2.2 Implement finite main-owned Core config / scene macro registry code under local project conventions.
- [x] 2.3 Add local/unit tests for stable known names, unknown-name fail-closed behavior, and no readiness/proof promotion.
- [x] 2.4 Run targeted Swift tests, OpenSpec validation, `git diff --check`, GitNexus `detect_changes`, and Hermes audit.

## 3. D16 Gate 3 Force-State Boundary Code

> `HISTORICAL_CHECKBOX_ONLY`: these checks record the earlier D16 boundary slice. They do not prove a production single write owner; live production `CALLS=0` remains a separate fact.

- [x] 3.1 Before editing Swift symbols, run GitNexus impact/context for each target symbol or record an exact GitNexus blocker.
- [x] 3.2 Implement demo/debug-isolated force-state boundary with bridge event provenance and no direct state-cell contract mutation.
- [x] 3.3 Add local/unit tests proving production/customer-facing path is unavailable or fails closed.
- [x] 3.4 Run targeted Swift tests, OpenSpec validation, `git diff --check`, GitNexus `detect_changes`, and Hermes audit.

## 4. D16 Gate 4 Upstream Verifier

> `HISTORICAL_CHECKBOX_ONLY`: Gate 4/4R history remains visible, including 4.4 open. It does not close M16-012.

- [x] 4.1 Verify committed D16 diff from clean-worktree perspective and refresh GitNexus if needed.
- [x] 4.2 Verify UIUE has not consumed D16 config/force-state names before release.
- [x] 4.3 Record proof cap, non-claims, and `d17_release_gate: closed`.
- [ ] 4.4 Run required validation, Hermes audit, exact-stage verifier receipt, and commit. Gate4 Hermes returned FAIL/P1; D17 release is closed pending a separate fix/reopen decision.

## 4R. D16 Gate 4R Force-State Codable Bypass Repair And Reopen

> `HISTORICAL_CHECKBOX_ONLY`: 4R hardening is retained as historical value and is not a W9 production-authority receipt.

- [x] 4R.1 Re-probe main/UIUE live truth and confirm D17 has not started.
- [x] 4R.2 Remove or harden external construction paths for `DemoForceStateContext`, including synthesized `Decodable` / `Codable`.
- [x] 4R.3 Add local/unit and external package proof that `DemoForceStateContext` is not externally decodable.
- [x] 4R.4 Preserve fail-closed tests for `.customerFacing`, empty context, duplicate dimensions, and missing `.demoHarness` provenance.
- [x] 4R.5 Run local validation, OpenSpec validation, GitNexus context/detect, and UIUE read-only bounded grep.
- [x] 4R.6 Run one audit pass, record audit result, decide `d17_release_gate: open`, exact-stage Gate4R owned paths, and commit.

## 5. Wave2-M16-011/012 W9 Carrier Amend

> This unchecked section is the only task group that represents the D-152 W9 delta. It is carrier/spec work only; implementation, apply, coding, merge, package transition, and gate materialization require separate keys.

- [ ] 5.1 Reconcile the live five requirements and Gate1–4R checkbox history against M16-011/M16-012; preserve `KEEP`, `KEEP_WITH_NOTE`, `AMEND_TEXT`, and `HISTORICAL_CHECKBOX_ONLY` dispositions without claiming historical closure.
- [ ] 5.2 Add the M16-011 one-physical-catalog contract with explicit `debug`/`demo` kind-and-namespace values, stable identity, owner/version fields, duplicate rejection, and no second authority.
- [ ] 5.3 Add the M16-011 declared digest/canonicalization contract with complete-entry coverage, stable canonical output, and mismatch fail-closed behavior.
- [ ] 5.4 Add the M16-011 exact versioned migration ledger contract; reject missing/duplicate/ambiguous/fuzzy mappings and forbid `4↔5` mapping.
- [ ] 5.5 Amend M16-012 force-state ownership to boundary validator → Core applier → projection-only, including direct App/customer mutation and missing-provenance deletion negatives.
- [ ] 5.6 Preserve W8 lifecycle/fence ownership and keep `verify-force-state-source` / `verify-force-state-authority` marked `PLANNED_GATE_NOT_YET_EXECUTABLE` until their surfaces materialize.
- [ ] 5.7 Run W9 change strict validation and exact diff checks, then bind the four amended artifacts, pinned plan, key receipt, current HEAD, and unchanged shared-plan status in the W9 pair receipt.
