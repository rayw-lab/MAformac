## Context

G01-G28 are accepted grill decisions for non-UIUE mainline demo default-scope semantics. They are not yet archived OpenSpec behavior, and they do not authorize implementation, training, C6 acceptance, golden-run execution, voice work, or UIUE merge.

The current mainline problem is cross-cutting: omitted scoped commands can be interpreted as `全车`/`all`, inferred from YAML order, or copied into C5/C6/golden/UIUE drafts with subtly different meanings. The carrier must make the observable behavior explicit once, then let downstream changes depend on it.

UIUE is external to this mainline change. The expected pin from Phase0 docs was `f1096d7`, but the current external worktree HEAD is `17f2af1`. Therefore UIUE is recorded only as `external_reference_unverified_current_head=17f2af1`; this design does not cite UIUE file:line evidence and does not claim UIUE is aligned.

## Goals / Non-Goals

**Goals:**

- Carry G01-G28 default-scope observable behavior in one OpenSpec change.
- Define C2 `default_scope` authority for omitted scoped targets.
- Split missing, explicit, and fan-out scope states.
- Preserve explicit non-default scope and explicit collection fan-out.
- Require scope-origin metadata for readback and presentation.
- Keep G28 as a UIUE merge check without making current UIUE state a mainline readiness claim.
- Add dependency boundaries for C5, C6, and demo-golden-run.

**Non-Goals:**

- No Swift runtime implementation.
- No contract YAML or generated artifact edit.
- No archived spec edit.
- No training, data generation, model-quality evaluation, endpoint smoke, demo-golden-run execution, or voice work.
- No UIUE file edit, UIUE merge, UIUE-ready claim, or UIUE file:line evidence claim.

## Decisions

> Derivation rule: AD-DS rows below are derived from G01-G28. UIUE-related rows carry only `external_reference_unverified_current_head=17f2af1` and G28 merge-check intent; they are not current UIUE evidence claims. If an AD-DS row conflicts with G01-G28, G01-G28 wins and the AD-DS row must be rewritten.

### AD-DS-001: C2 `default_scope` is the authority

Trace: G06, G25.

Every scoped C2 state cell that participates in demo execution SHALL define `default_scope`. Runtime code SHALL NOT infer omitted scope from YAML order, `scope.first`, `all`, or `全车`.

Apply closeout SHALL include a mechanical SSOT gate scoped to default-resolution paths: omitted-scope resolution and state application SHALL NOT use fallback expressions such as `scope.first`, `?? "全车"`, or `?? "all"`. Explicit `全车` and accepted collection aliases remain legal fan-out inputs; the gate MUST NOT ban legitimate explicit collection tokens. C2 validation SHALL fail if a scoped demo-execution cell lacks `default_scope` or if `default_scope` is not a member of that cell's `scope`.

### AD-DS-002: Missing, explicit, and fan-out scopes are different states

Trace: G04, G05, G12.

Missing scope SHALL resolve to the cell's `default_scope`. Explicit non-default scope SHALL target that scope. Explicit collection scope such as `全车` SHALL fan out to supported cells. Unknown scope SHALL reject or clarify; it SHALL NOT silently fan out and SHALL NOT silently default.

### AD-DS-003: Readback carries scope origin

Trace: G18; UIUE intersection is `external_reference_unverified_current_head=17f2af1`.

The system SHALL track whether scope was `defaulted`, `explicit`, or `fanout`. Scope origin SHALL be produced once at target resolution as a typed value, such as a `ScopeOrigin` enum or equivalent closed type, and propagated to downstream consumers. Readback, TTS/readback policy, verifier evidence, and UIUE presentation SHALL consume that shared typed origin rather than recomputing origin from visible text, string matching, or independent `"主驾"` checks. Internal state assertions SHALL keep scoped keys. Presentation SHALL receive structured `scope_origin`, `resolved_scope`, and `presentation_scope_policy` metadata. Channel renderers MAY choose low-emphasis, compact, or elided default-scope wording, but SHALL preserve explicit non-default scope and explicit fan-out.

### AD-DS-004: UIUE low-emphasis is channel policy, not SSOT

Trace: G18, G23, G28; UIUE intersection is `external_reference_unverified_current_head=17f2af1`.

A low-emphasis default-scope badge is a presentation policy, not a second source of truth. TTS, plain readback, verifier text, and card badges SHALL derive from the same structured scope metadata, but they are not required to render identical text. Defaulted scope SHALL NOT trigger a driver/passenger clarification. Explicit non-default scope and explicit fan-out SHALL remain explicit across card, TTS/readback policy, and verifier evidence.

### AD-DS-005: Fan-out presentation is aggregate-first

Trace: G05, G18, G28; UIUE intersection is `external_reference_unverified_current_head=17f2af1`.

Explicit fan-out such as `关上所有车窗` SHALL execute over multiple state cells. Presentation SHOULD be aggregate-first, such as one aggregate card with a `全车` badge, rather than forcing per-cell expansion as the default channel behavior. Backend state remains per-cell.

### AD-DS-006: Multi-turn aggregate label is allowed

Trace: G18, G27, G28; UIUE intersection is `external_reference_unverified_current_head=17f2af1`.

When a follow-up expands scope, for example `打开车窗` followed by `副驾也打开`, presentation MAY use an aggregate label such as `前排车窗` when it improves clarity. Backend state remains per-cell; the aggregate label is presentation metadata, not a new C2 cell unless a later accepted spec adds it.

### AD-DS-007: Legacy unscoped demo keys are deprecated or bridged

Trace: G23.

Legacy keys such as `hvac.temperature`, `seat.driver.heat`, `window.driver`, `lighting.ambient`, `screen.brightness`, and `fan.speed` SHALL NOT remain a second UI state source after `default_scope` lands. The implementation SHALL explicitly choose the scoped C2 key path for presentation or define a one-way compatibility adapter. Tests SHALL assert that default-scope actions do not leave demo UI presentation reading stale legacy keys.

Apply closeout evidence SHALL include both legacy-key and scoped-key reads. A grep that merely records legacy keys is not sufficient; the closeout must prove that presentation reads the scoped source of truth or a one-way adapter from scoped C2 state.

### AD-DS-008: Collection aliases are closed

Trace: G05.

Collection-like utterances are fan-out only when they match an accepted collection alias for the cell's collection scope, for example `全车`, `所有车窗`, `四个车窗`, or `车窗都` mapping to `window.position[全车]`. Unknown collection-like wording SHALL reject, clarify, or route to slow-path resolution with evidence; it SHALL NOT silently fall back to `default_scope`.

### AD-DS-009: Omitted scope composes after route acceptance

Trace: G18, G27.

Omitted scope is a target-resolution concern after a candidate exists. The route matrix has five explicit rows:

| Route context | Candidate status | Scope behavior |
|---|---|---|
| fast | Accepted deterministic candidate | Resolve omitted scope through C2 `default_scope`. |
| slow | Accepted Qwen+LoRA candidate | Resolve omitted scope through C2 `default_scope`; the model must not own a second defaulting policy. |
| ambiguous | Candidate not accepted | Clarify before target resolution; do not default silently. |
| rejected | Safety, unsupported, or policy-rejected candidate | Refuse or no-op; do not create a defaulted C2 state target. |
| passthrough | Non-state-changing or out-of-domain response | Preserve passthrough result; do not create a state target, `resolved_scope`, or `scope_origin`. |

The route layer may decide whether a candidate is accepted. Once accepted, target scope is resolved only by C2.

### AD-DS-010: C5 scope candidates derive from C2

Trace: G17, G26.

C5 training target rendering and fallback scope candidates SHALL derive executable scopes from C2 `scope` and omitted-scope behavior from C2 `default_scope`. C5 SHALL NOT keep a hardcoded second scope vocabulary. Tool-call output arguments may only use executable C2 scope tokens or omit the scope when omission is intentional. Raw/source synonyms such as `左前` or `右前` may be accepted as input-language variants only if they canonicalize to C2 executable scopes before target rendering and parity checks.

## Risks / Trade-offs

- [Risk] Default-scope semantics get copied into C5/C6/golden/UIUE and drift again. -> Mitigation: downstream draft changes only depend on this carrier and must not redefine omitted-scope behavior.
- [Risk] UIUE drift gets laundered into mainline evidence. -> Mitigation: record only `external_reference_unverified_current_head=17f2af1`, no UIUE file:line citation, no UIUE-ready claim.
- [Risk] OpenSpec validation is mistaken for implementation readiness. -> Mitigation: proposal, design, and tasks explicitly preserve no-training/no-eval/no-golden/no-voice/no-UIUE boundaries.
- [Risk] Channel policy gets mistaken for state truth. -> Mitigation: require structured scope metadata and keep scoped C2 state as the state assertion surface.
- [Risk] Mechanical enforcement becomes over-broad and bans legitimate explicit `全车` fan-out. -> Mitigation: forbid fallback expressions and independent default-resolution paths, not explicit collection tokens.
- [Risk] C5 fixture tests freeze a non-C2 scope vocabulary. -> Mitigation: require C5/C2 parity tests and canonicalization before target rendering.

## Migration Plan

1. Accept this OpenSpec carrier before applying default-scope code changes.
2. Implement C2 `default_scope`, C3 target resolution, state applier, readback metadata, typed scope-origin propagation, C5 target rendering, C6 gold, and demo scenario updates in a later apply pass.
3. Reconfirm UIUE current head and file evidence in a separate UIUE reconfirm pass before UIUE merge or file:line evidence use.

## Open Questions

- Which exact UIUE current-head file lines still match the G28 merge-check intent after the UIUE reconfirm pass?
- Which channel policy should be chosen as the first implementation default for TTS: elided, compact, or low-emphasis verbal wording?
