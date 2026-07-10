## Context

D-123 ratified the 120-cell `DemoCapabilityMatrix` content truth and left its repository carrier/checker to C1 (`docs/commander-log/decisions.md:1112-1116`). D-133 ratified all 38 C1 P0 decisions, including matrix source/derivation, four-source `actionDemoProven`, fallback catalog, CG-036, probes, prelay and CG-080 (`docs/grill-tournament/c1-capability-grill-ratified-2026-07-10.md:14-18,24-61`). D-134 selected B: add independent C1 governance, modify `tool-execution` for execution facts, and reuse the existing `runtime-presentation-bridge` for presentation; a same-meaning presentation SSOT is forbidden (`docs/commander-log/decisions.md:1196-1201`).

The existing bridge is already concrete authority, not a placeholder. It declares the mainline Runtime → Presentation mapping and forbids a second same-meaning bridge SSOT (`openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md:3-19`); owns the result vocabulary (`:39-69`), presentation snapshot/readback/safe trace (`:71-151`) and main-owned payload/schema (`:164-223`). The archived `tool-execution` spec still rejects every multi-tool turn (`openspec/specs/tool-execution/spec.md:18-35`), so CG-036 cannot be closed by presentation fixtures alone.

The runtime remains fully offline and mock-only: text → intent → reviewed ToolCall plan → DemoGuard → mock state → readback → trace. Safety checks are code gates, not prompt instructions, and success requires verified mock-state readback.

## Goals / Non-Goals

**Goals:**

- Establish one governance owner for matrix eligibility, fallback taxonomy/catalog, probe coverage and mounted-expansion policy.
- Preserve one execution owner for accepted/refused action facts and one presentation owner for public payload/readback/trace projection.
- Lock the enum projection before implementation so matrix, runtime, bridge and UI cannot invent meanings independently.
- Give every D-133 CG an explicit contract/task owner and test-first handoff.

**Non-Goals:**

- No parallel `runtime-presentation-payload` capability or new shared presentation schema.
- No mounted 1→N authorization, S9/S10 execution, C5/C6 signoff or proof-class upgrade.
- No UIUE, iOS signing, model/training, raw-source or real-vehicle change.
- No runtime code is implemented by this T0 artifact commit.

## Decisions

### AD-001 — D-134 B creates governance, execution and presentation owners

| Concern | Sole owner | Other surfaces may | Forbidden |
|---|---|---|---|
| 120-cell matrix, `primary_class`, `actionDemoProven` basis, fallback taxonomy/catalog, probe policy, S10/mounted/rollback gates | `demo-capability-governance` | execution/bridge consume classifications and policy decisions | governance cannot define public payload fields, schema versions, readback rendering or safe trace envelopes |
| bounded multi-intent gates, accepted/refused identity, state mutation, observed tool calls, accepted readback, internal finite reasons and execution receipt | `tool-execution` | governance requires coverage; bridge consumes facts | execution cannot define customer copy or public payload schema |
| result vocabulary, partial composite projection, customer-safe `reasonKind`, payload version, cards/readbacks, proof cap and presentation-safe trace | `runtime-presentation-bridge` | governance/execution reference existing bridge semantics | governance/execution/UIUE cannot invent same-meaning fields or a second presentation SSOT |

Alternative A—placing all C1 behavior in the bridge—was rejected by D-134 because matrix eligibility and expansion policy are not presentation semantics. Alternative “new C1 payload capability” was rejected because it duplicates the bridge’s existing authority.

### AD-002 — `actionDemoProven` is computed from same-cell evidence and never opens mounted catalog

`actionDemoProven=true` requires mounted/explicitly approved action, semantic contract, state/readback cell and local runtime emission+execution+readback proof for the same cell. FastPath is only `entrypointAlias`; conditional injected proof is a separate lane. The matrix is derived from mounted/semantic/state/proof sources and cannot write back to mounted authority.

### AD-003 — Enum projection is closed before coding

`primary_class` is restricted to:

- `safety_or_clarify_reject`
- `unmounted_name_rejected`
- `fast_path_no_match_fallback`
- `default_executable`
- `conditional_ddomain_executable`

Fallback coverage uses four closed governance classes:

- `safety_or_clarify_reject`
- `unmounted_name_rejected`
- `fast_path_no_match_fallback`
- `unknown_no_representative_entry`

Internal `finiteReason` is a closed ten-value enum. Its only members are `safety_or_policy_refusal`, `clarify_missing_slot`, `unmounted_tool_name`, `name_rejected`, `fast_path_no_match`, `unsupported_tool_plan`, `no_representative_tool`, `runtime_execution_error`, `stale_state_revision`, and `already_state_noop`. No free string, implicit alias or implementation-only addition is permitted; a membership change requires an explicit change and simultaneous projection update. `partial_accept_partial_refuse` is a bridge result wrapper, not a `finiteReason` member.

The normative projection is:

| Condition | `primary_class` / fallback class | internal `finiteReason` | contract `fallback_reason` | bridge-owned safe `reasonKind` | bridge-owned result |
|---|---|---|---|---|---|
| safety/policy denies | `safety_or_clarify_reject` | `safety_or_policy_refusal` | `safety_policy_refused` | `safety_policy` | `refusal_safety_or_policy` |
| required slot missing/ambiguous | `safety_or_clarify_reject` | `clarify_missing_slot` | `clarify_missing_slot` | `clarification_required` | `clarify_missing_slot` |
| semantic action exists but is not mounted | `unmounted_name_rejected` | `unmounted_tool_name` or attributable `name_rejected` | `unmounted_name_rejected` | `capability_not_mounted` | `refusal_no_available_tool` |
| FastPath miss or unsupported plan | `fast_path_no_match_fallback` | `fast_path_no_match` or `unsupported_tool_plan` | `unsupported_no_available_tool` | `not_available_in_demo` | `refusal_no_available_tool` |
| no representative semantic action | fallback `unknown_no_representative_entry` | `no_representative_tool` | `no_representative_tool__default_fallback` | `not_available_in_demo` | `refusal_no_available_tool` |
| selected action throws typed runtime error | not a 40-grid fallback cell | `runtime_execution_error` | `runtime_error_typed` | `runtime_unavailable` | `runtime_error` |
| selected action fails the stale-state gate | not a 40-grid fallback cell | `stale_state_revision` | `runtime_error_typed` | `runtime_unavailable` | `runtime_error` |
| requested state already holds | `default_executable` outcome | `already_state_noop` | `already_state_noop` | `already_done` | `already_state_noop` |
| accepted and refused subactions coexist | wrapper; each refused item uses a row above | per item | `partial_accept_partial_refuse` wrapper + typed subreason | per refused item | `partial_accept_partial_refuse` |

Raw `finiteReason` stays internal. The governance table fixes classification and mapping inputs; the final public result, payload field names, redaction and display remain bridge-owned.

### AD-004 — CG-036 is one turn with two owner-specific deltas

`tool-execution` replaces all-multi-tool rejection only for a bounded, independently gated plan. Every subaction still passes schema, semantic, precondition, stale-state, DemoGuard, execution and readback gates. Accepted items may mutate only approved cells; refused items never execute or mutate.

The bridge projects those facts through its existing terminal partial outcome, accepted readbacks, mixed card state and safe reasons. Neither delta alone claims end-to-end closure.

### AD-005 — Probe and expansion governance is fail-closed

The fallback source covers 10 families × 4 governance classes. Every pair needs catalog copy and a probe; pure fallback/refusal probes must observe zero tool calls and identical canonical before/after state. `joint_strike_rate=min(hedged_strike_rate, can_question_strike_rate)` drives only later expansion eligibility. Missing joint rate, fallback-quality failure or missing matrix/readback/golden evidence blocks expansion but does not erase valid prelay.

## CG Coverage

| Requirement area | Covered CG |
|---|---|
| matrix source/basis/derivation/proof lanes | CG-002,004,005,007,008,009,014,015,019,063,065 |
| enum/reason mapping and safe projection | CG-022,023,024,025,038,039,068,074 |
| fallback source, 10×4 coverage and metrics | CG-026,027,028,041,059 |
| partial execution and trace evidence | CG-036,044,076 |
| expansion, Q-SR, prelay, rollback and authority | CG-045,048,049,050,053,054,055,057,058,060,080 |

The union is the exact 38-item D-133 set; CG-021 and the 39-item P1/D0G batch remain outside this change.

## Risks / Trade-offs

- **Parallel SSOT reappears through copied payload language** → Specs modify the existing bridge requirement names and design records a sole-owner map; any `runtime-presentation-payload` capability is a hard failure. Evidence: existing bridge explicitly forbids a second same-meaning SSOT at `:14-19`.
- **CG-036 fixtures go green while runtime still drops frames** → Tasks require router/runtime producer tests before bridge fixture acceptance; execution and bridge audits remain separate. Evidence: archived execution contract currently rejects all multi-tool output at `openspec/specs/tool-execution/spec.md:18-24`.
- **FastPath/prose manually promotes `actionDemoProven`** → Matrix checker recomputes same-cell four-source basis and emits conflict instead of exceptions. Evidence: D-133 CG-004/007/014/065.
- **Internal finite reasons leak to users** → Only bridge-owned `reasonKind`/copy crosses the public boundary; negative fixture tests reject raw `finiteReason`. Evidence: bridge safe payload/redaction requirements at `:164-223`.
- **Prelay is misreported as mounted expansion** → CG-045/054/080 are explicit stop lines and mounted delta must remain zero in C1.

## Migration Plan

1. Land this change carrier and strict validation.
2. Implement matrix and fallback source/checkers/codegen in isolated test-first slices.
3. Implement router ingress and bounded execution facts after GitNexus impact/risk acknowledgement.
4. Modify the existing bridge projection and public fixtures without creating new presentation authority.
5. Add 40 no-mutation probes, mounted no-delta, S10 fixture and CI gates.
6. Integrate in dependency order; run OpenSpec strict validation, targeted tests, full verification, GitNexus `detect_changes`, then independent audit.

Rollback is slice-based: revert governance source, execution delta implementation or bridge projection independently. Rollback must preserve fallback catalog and downgrade any affected matrix eligibility; it must never leave mounted growth without its matrix/golden/readback evidence.

## Open Questions

None for T0. D-123, D-133 and D-134 close the authority, enum and CG-080 decisions needed to start downstream slices. Any request to change enum membership, payload version or mounted scope requires a new decision/change rather than an implementation-time exception.
