## Context

G01-G28 are accepted grill decisions for non-UIUE mainline demo default-scope semantics. They are not yet archived OpenSpec behavior, and they do not authorize implementation, training, C6 acceptance, golden-run execution, voice work, or UIUE merge.

The current mainline problem is cross-cutting: omitted scoped commands can be interpreted as `全车`/`all`, inferred from YAML order, or copied into C5/C6/golden/UIUE drafts with subtly different meanings. The carrier must make the observable behavior explicit once, then let downstream changes depend on it.

UIUE is external to this mainline change. The expected pin from Phase0 docs was `f1096d7`, but the current external worktree HEAD is `34044e1`. Therefore UIUE is recorded only as `external_reference_unverified_current_head=34044e1`; this design does not cite UIUE file:line evidence and does not claim UIUE is aligned.

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

> Derivation rule: AD-DS rows below are derived from G01-G28. UIUE-related rows carry only `external_reference_unverified_current_head=34044e1` and G28 merge-check intent; they are not current UIUE evidence claims. If an AD-DS row conflicts with G01-G28, G01-G28 wins and the AD-DS row must be rewritten.

### AD-DS-001: C2 `default_scope` is the authority

Trace: G06, G25.

Every scoped C2 state cell that participates in demo execution SHALL define `default_scope`. Runtime code SHALL NOT infer omitted scope from YAML order, `scope.first`, `all`, or `全车`.

### AD-DS-002: Missing, explicit, and fan-out scopes are different states

Trace: G04, G05, G12.

Missing scope SHALL resolve to the cell's `default_scope`. Explicit non-default scope SHALL target that scope. Explicit collection scope such as `全车` SHALL fan out to supported cells. Unknown scope SHALL reject or clarify; it SHALL NOT silently fan out and SHALL NOT silently default.

### AD-DS-003: Readback carries scope origin

Trace: G18; UIUE intersection is `external_reference_unverified_current_head=34044e1`.

The system SHALL track whether scope was `defaulted`, `explicit`, or `fanout`. Internal state assertions SHALL keep scoped keys. Presentation SHALL receive structured `scope_origin`, `resolved_scope`, and `presentation_scope_policy` metadata. Channel renderers MAY choose low-emphasis, compact, or elided default-scope wording, but SHALL preserve explicit non-default scope and explicit fan-out.

### AD-DS-004: UIUE low-emphasis is channel policy, not SSOT

Trace: G18, G23, G28; UIUE intersection is `external_reference_unverified_current_head=34044e1`.

A low-emphasis default-scope badge is a presentation policy, not a second source of truth. TTS, plain readback, verifier text, and card badges SHALL derive from the same structured scope metadata, but they are not required to render identical text. Defaulted scope SHALL NOT trigger a driver/passenger clarification. Explicit non-default scope and explicit fan-out SHALL remain explicit across card, TTS/readback policy, and verifier evidence.

### AD-DS-005: Fan-out presentation is aggregate-first

Trace: G05, G18, G28; UIUE intersection is `external_reference_unverified_current_head=34044e1`.

Explicit fan-out such as `关上所有车窗` SHALL execute over multiple state cells. Presentation SHOULD be aggregate-first, such as one aggregate card with a `全车` badge, rather than forcing per-cell expansion as the default channel behavior. Backend state remains per-cell.

### AD-DS-006: Multi-turn aggregate label is allowed

Trace: G18, G27, G28; UIUE intersection is `external_reference_unverified_current_head=34044e1`.

When a follow-up expands scope, for example `打开车窗` followed by `副驾也打开`, presentation MAY use an aggregate label such as `前排车窗` when it improves clarity. Backend state remains per-cell; the aggregate label is presentation metadata, not a new C2 cell unless a later accepted spec adds it.

### AD-DS-007: Legacy unscoped demo keys are deprecated or bridged

Trace: G23.

Legacy keys such as `hvac.temperature`, `seat.driver.heat`, `window.driver`, `lighting.ambient`, `screen.brightness`, and `fan.speed` SHALL NOT remain a second UI state source after `default_scope` lands. The implementation SHALL explicitly choose the scoped C2 key path for presentation or define a one-way compatibility adapter. Tests SHALL assert that default-scope actions do not leave demo UI presentation reading stale legacy keys.

### AD-DS-008: Collection aliases are closed

Trace: G05.

Collection-like utterances are fan-out only when they match an accepted collection alias for the cell's collection scope, for example `全车`, `所有车窗`, `四个车窗`, or `车窗都` mapping to `window.position[全车]`. Unknown collection-like wording SHALL reject, clarify, or route to slow-path resolution with evidence; it SHALL NOT silently fall back to `default_scope`.

### AD-DS-009: Omitted scope x `clarify_tag` route composition

Trace: G18, G27.

Omitted scope is a target-resolution concern after a candidate exists. `clarify_tag=explicit` plus omitted scope may use fast path and then resolve through `default_scope`. `clarify_tag=implicit` may route through Qwen+LoRA and return a D-domain tool call without a scope slot; after the slow-path candidate is accepted, C3 still resolves omitted scope through `default_scope`. `clarify_tag=ambiguous` or unsupported scope wording SHALL clarify/reject rather than default silently.

## Risks / Trade-offs

- [Risk] Default-scope semantics get copied into C5/C6/golden/UIUE and drift again. -> Mitigation: downstream draft changes only depend on this carrier and must not redefine omitted-scope behavior.
- [Risk] UIUE drift gets laundered into mainline evidence. -> Mitigation: record only `external_reference_unverified_current_head=34044e1`, no UIUE file:line citation, no UIUE-ready claim.
- [Risk] OpenSpec validation is mistaken for implementation readiness. -> Mitigation: proposal, design, and tasks explicitly preserve no-training/no-eval/no-golden/no-voice/no-UIUE boundaries.
- [Risk] Channel policy gets mistaken for state truth. -> Mitigation: require structured scope metadata and keep scoped C2 state as the state assertion surface.

## Migration Plan

1. Accept this OpenSpec carrier before applying default-scope code changes.
2. Implement C2 `default_scope`, C3 target resolution, state applier, readback metadata, C5 target rendering, C6 gold, and demo scenario updates in a later apply pass.
3. Reconfirm UIUE current head and file evidence in a separate UIUE reconfirm pass before UIUE merge or file:line evidence use.

## Open Questions

- Which exact UIUE current-head file lines still match the G28 merge-check intent after the UIUE reconfirm pass?
- Which channel policy should be chosen as the first implementation default for TTS: elided, compact, or low-emphasis verbal wording?
