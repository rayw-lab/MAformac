## Decisions

### Three-axis independence, not one collapsed enum

`exec_tier` (five-layer routing model per `docs/srd-three-layer-intent-routing.md:40-49`), `outcome` (candidate/clarify/reject/fallback verdict), and `clarify_tag` (jsonl row-level 2-value alphabet at `contracts/semantic-function-contract.jsonl`) are independent axes. Collapsing them into a single sum type would prevent expressing legitimate combinations (e.g. `L2 + candidate + implicit` for a slow-path candidate) and re-introduce the θ-α judgment-surface explosion that `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:29-31` §3 identified as the root of 0/23.

### D-domain named tool surface, no parallel registry

`ActionCandidate.mounted_tool_name` binds against the SSOT catalog at `Core/Contracts/DDomainMountedToolCatalog.swift:12-14` `mountedToolNames`. This preserves the paradigm reversal decided in `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md:10-27` §1-§2 (model-visible surface = D-domain named tools; generic frame rejected). A local `Set<String>` literal that duplicates the catalog would be a second SSOT and is explicitly forbidden by the No-Second-Registry SHALL Requirement.

### `RouteValuePrimitive.swift` fills a live gap, does not mutate existing types

`Core/Contracts/ContractLookups.swift:3-15` `ContractValue` uses raw `String` fields today (live-cored line 3-15). Adding typed primitive enums for `ref/direct/offset/type` inside `ContractValue` would break the archived `define-c1c2-contract` proof surface. Instead, `Core/Contracts/RouteValuePrimitive.swift` introduces `RouteValueRef`, `RouteValueDirect`, `RouteValueType`, `RouteValueOffset`, `RouteValueExperiential` as new peer types. `ActionCandidate.value` (inside `RouteResult.swift`) uses these enums directly; downstream code that still holds a `ContractValue` can convert without disturbing the archived struct.

### `clarify_tag` alphabet stays at jsonl level (two values), routing states move to `outcome` / `RouteError`

Coordinator supplementary S3 requires strict alignment: `clarify_tag ∈ {explicit, implicit}` verbatim from jsonl. `docs/srd-three-layer-intent-routing.md:66-72` §1.3 documents five *runtime* clarifyTag values (adding `ambiguous`, `rejected`, `passthrough`). Rather than widening the enum and drifting from the SSOT, we express those runtime states orthogonally:
- `ambiguous` → `outcome=clarify` with a clarification reason.
- `rejected` → `outcome=reject` with a `RouteError`.
- `passthrough` → out of B1a scope; belongs to `dialogue-state-semantic-consumption` and W7 follow-up.

### Rejection precedence is a fixed total order

The 14-slot ordering fixed in the SHALL Requirement matches the risk-policy amend at `CLAUDE.md:109` (`R0 forbidden` first) and generalises the priority `safety → policy → rejected_nonsense_or_chat → unsupported` inherited from `docs/c1-q1-q10-claude-oracle-grill-2026-06-19.md` grill G1-019. Runtime consumers can rely on a single reason emitted; no `Set<RouteError>` or ordered list is produced by the validator.

### RouteSubject and RouteTrace are separate, RouteTrace produces the digest

`RouteSubject` carries identity (`turn_id`, `trace_id`, `source_identity`, `contract_digest`); `RouteTrace` carries the redacted decision trail (`exec_tier` fact, `outcome` fact, `clarify_tag` fact, `rejection_reason` fact, `redaction_policy_id`, `stale_marker`, `trace_digest`). The `RouteResult` embeds identity via `RouteSubject` and refers to trace via `trace_digest` only — the digest is the load-bearing bind, the full trace is a sibling artifact.

Canonical JSON encoding (sorted keys, no whitespace, deterministic Number formatting) is used for `trace_digest` computation. SHA-256 is the hash (matches the existing pattern in `Core/Contracts/DDomainMountedToolCatalog.swift:22-26` `C6Hash.sha256Hex`).

## Consumer handoff (informative, not implemented in B1a)

The exact handoff for W5a follow-up (stale-session / stale-turn / stale-event / correlation-mismatch) matches the four-case matrix at `openspec/changes/add-t04a-customer-ingress/specs/frontstage-admission/spec.md:25-41`. W5a will build a pending-correlation record `{session_id, turn_id, event_id, sequence, expected_trace_id, route_schema, contract_digest, source_revision}` at dispatch time. When a `RouteResult` returns, W5a joins by `turn_id`, then checks the four cases outside this contract. `session_id`, `event_id`, `sequence` deliberately stay out of `RouteResult` per the ontology-narrowing SHALL Requirement.

This design does NOT implement `FrontstageRouteResultConsumer`, does NOT flip `openspec/changes/add-t04a-customer-ingress/tasks.md:6` from `BLOCKED_WAIT_W6_TYPES`, and does NOT touch `int-v5b` receipt schema.

## Risks

- **Digest drift under Swift Codable evolution.** If a load-bearing field's Codable encoding changes (e.g. enum raw value renamed) the digest of previously-recorded traces will not match. Mitigation: `schema_version` const `typed_route_contract.v1`; a schema bump forces a new digest namespace and downstream re-verification.
- **Fixture drift under jsonl codegen.** Positive fixtures record `contract_row_id`. If the jsonl is regenerated with different row IDs, the fixture checker will red. Mitigation: fixtures pin the `contract_row_id` verbatim; regen-driven drift surfaces at check time rather than silently.
- **Enum widening pressure.** Downstream consumers may pressure widening `clarify_tag` to the five runtime values. Mitigation: SHALL Requirement pins the alphabet to jsonl; runtime states go through `outcome` / `RouteError`.

## Non-goals in this change (also in proposal.md)

- No B1b (Makefile / shared checker / App composition wiring / build gates).
- No W6-2 (alias artifact, L1 normalization oracle, L1-L5 actual policy).
- No W7 / W8 / W9 downstream implementation.
- No production consumer, no T04a task flip.
- No `openspec/changes/_parked/**` revival.
