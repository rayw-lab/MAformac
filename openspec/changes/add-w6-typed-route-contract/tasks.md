## Implementation

- [ ] 1. Add `Core/Contracts/RouteValuePrimitive.swift` — typed enums for `ref/direct/offset/type` per `docs/baseline-semantic-protocol-2026-06-19.md:53-57` §2②.
- [ ] 2. Add `Core/Contracts/RouteError.swift` — closed error enum covering R0-R3 per `CLAUDE.md:109`.
- [ ] 3. Add `Core/Contracts/RouteContract.swift` — closed axis enums (`RouteExecTier`, `RouteOutcome`, `RouteClarifyTag`, `RouteService`) + `RouteSourceIdentity` + `RouteSubject` + canonical JSON encoding helpers.
- [ ] 4. Add `Core/Contracts/RouteResult.swift` — `ActionCandidate` + `RouteTrace` + `RouteResult` + `RouteContractValidator` (total validator, precedence-ordered rejection).
- [ ] 5. Add `contracts/schemas/typed-route-contract.v1.schema.json` — JSON schema for `RouteResult` canonical wire form.
- [ ] 6. Add `contracts/fixtures/typed-route-contract/` positive fixtures (≥3, one per service; each with `_source.contract_row_id` from a real `contracts/semantic-function-contract.jsonl` row) + negative fixtures (unknown-enum × 3 axes, illegal-combination, unmounted tool, out-of-catalog service, stale source, digest mismatch, session_id leak, EXP-non-experiential-offset).
- [ ] 7. Add `Tests/MAformacCoreTests/RouteContractTests.swift` — Codable round-trip, three-axis independence, mounted tool binding, canonical digest, rejection precedence, error enum coverage.
- [ ] 8. Add `Tests/python/contracts/test_route_fixtures.py` — JSON schema validation, fixture ↔ jsonl `contract_row_id` cross-check, positive rc0 / negative rc≠0.
- [ ] 9. Run producer gates (see §Validation).
- [ ] 10. Commit in semantic-complete slices (Swift core → schema+fixtures → tests → openspec).

## Validation

- [ ] `openspec validate add-w6-typed-route-contract --strict` rc0.
- [ ] `swift test --filter RouteContractTests` rc0.
- [ ] `python3 -m unittest -v Tests/python/contracts/test_route_fixtures.py` rc0 (or `python3 -m pytest Tests/python/contracts/test_route_fixtures.py -q` rc0 depending on runner availability).
- [ ] `git status --short` clean of untracked garbage in owned paths (allowed paths only).
- [ ] Owned-paths audit: `git diff --stat` shows only the paths listed in the SHALL "SHALL NOT modify" filter's complement.

## Explicitly deferred (NOT in this change)

- [ ] BLOCKED_HANDOFF_W6_B1B: `Makefile` targets, `Tests/test_closure_work_packages.py` registry entry, closure checker/registry/index wiring — deferred to B1b integration owner per V9 dispatch §4 B1b.
- [ ] BLOCKED_HANDOFF_W5A: `FrontstageRouteResultConsumer` and the four-case matrix (stale-session/stale-turn/stale-event/correlation-mismatch) — deferred to W5a follow-up owner after this change is accepted.
- [ ] BLOCKED_HANDOFF_T04A_UNBLOCK: flipping `openspec/changes/add-t04a-customer-ingress/tasks.md:6` from `BLOCKED_WAIT_W6_TYPES` — deferred to a follow-up change owner; not touched here.
- [ ] BLOCKED_HANDOFF_W6_2: canonical alias artifact, L1 normalization oracle, L1-L5 actual policy, fast-slow selection.
