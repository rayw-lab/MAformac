## Implementation

- [x] 1. Add `Core/Contracts/RouteValuePrimitive.swift` — typed enums for `ref/direct/offset/type` per `docs/baseline-semantic-protocol-2026-06-19.md:53-57` §2②.
- [x] 2. Add `Core/Contracts/RouteError.swift` — closed error enum covering R0-R3 per `CLAUDE.md:109`.
- [x] 3. Add `Core/Contracts/RouteContract.swift` — closed axis enums (`RouteExecTier`, `RouteOutcome`, `RouteClarifyTag`, `RouteService`) + `RouteSourceIdentity` + `RouteSubject` + canonical JSON encoding helpers.
- [x] 4. Add `Core/Contracts/RouteResult.swift` — `ActionCandidate` + `RouteTrace` + `RouteResult` + `RouteContractValidator` (total validator, precedence-ordered rejection).
- [x] 5. Add `contracts/schemas/typed-route-contract.v1.schema.json` — JSON schema for `RouteResult` canonical wire form.
- [x] 6. Add `contracts/fixtures/typed-route-contract/` positive fixtures (5, incl. 3 service-covering airControl/carControl/cmd from real jsonl rows plus reject_R0 and clarify_R2) + negative fixtures (11 covering unknown-enum × 3 axes, illegal-combination, unmounted tool, out-of-catalog service, EXP-non-experiential-offset, session_id leak, schema_version drift, reject-missing-reason, digest mismatch, widened_clarify_tag).
- [x] 7. Add `Tests/MAformacCoreTests/RouteContractTests.swift` — Codable round-trip, three-axis independence, mounted tool binding, canonical digest, rejection precedence, error enum coverage. 31 tests / 31 PASS.
- [x] 8. Add `Tests/python/contracts/test_route_fixtures.py` — JSON schema validation, fixture ↔ jsonl `contract_row_id` cross-check, positive rc0 / negative rc≠0. 25 tests / 25 PASS.
- [x] 9. Run producer gates (see §Validation).
- [x] 10. Commit in semantic-complete slices (openspec carrier → Swift core → schema → fixtures → tests).

## grok-4.5 xAI review P1 fix pass (2026-07-13)

- [x] 11. P1-A1: Replace `airControl_candidate.json` positive fixture with real jsonl row `c1_airControl_000164` where `intent==mounted_tool_name=adjust_ac_temperature_to_number` (grep-verified). Recompute trace_digest.
- [x] 12. P1-A2: Add `MountedToolServiceMap` peer projection + `RouteError.crossDomainMountedTool` case + validator kinship gate + `cross_service_mount_binding.json` negative fixture.
- [x] 13. P1-B6: Add `RouteError.forbiddenKey` case + `RouteWireGuard.rejectForbiddenKeys` + `decodeRejectingForbiddenKeys(from:)` on `RouteResult`/`RouteSubject`/`RouteTrace`/`ActionCandidate` + 4 forbidden-key Swift tests.
- [x] 14. P1-B2: Add `ActionCandidateSummary` + extend `RouteTrace.LoadBearing` to include summary + candidate-summary sync check in joint validator + tampering-detection Swift tests + digest-parity verification for extended load-bearing.

## Validation

- [x] `openspec validate add-w6-typed-route-contract --strict` rc0.
- [x] `openspec validate --all --strict` — 31/31 passed.
- [x] `swift test --filter RouteContractTests` rc0 — 42 tests, 0 failures (was 32; +10 for P1 fixes).
- [x] `python3 -m unittest -v Tests.python.contracts.test_route_fixtures` rc0 — 27 tests, 0 failures (was 25; +2 for P1 fixes).
- [x] `git status --short` clean.
- [x] Owned-paths audit: no forbidden paths touched (Makefile / closure checker / generated Swift / App / parked change tree).

## Explicitly deferred (NOT in this change)

- [ ] BLOCKED_HANDOFF_W6_B1B: `Makefile` targets, `Tests/test_closure_work_packages.py` registry entry, closure checker/registry/index wiring — deferred to B1b integration owner per V9 dispatch §4 B1b.
- [ ] BLOCKED_HANDOFF_W5A: `FrontstageRouteResultConsumer` and the four-case matrix (stale-session/stale-turn/stale-event/correlation-mismatch) — deferred to W5a follow-up owner after this change is accepted.
- [ ] BLOCKED_HANDOFF_T04A_UNBLOCK: flipping `openspec/changes/add-t04a-customer-ingress/tasks.md:6` from `BLOCKED_WAIT_W6_TYPES` — deferred to a follow-up change owner; not touched here.
- [ ] BLOCKED_HANDOFF_W6_2: canonical alias artifact, L1 normalization oracle, L1-L5 actual policy, fast-slow selection.
