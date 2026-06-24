> This draft does not authorize implementation. It defines the required contract before C2/C3/C5/C6/golden/UIUE work proceeds.

## 1. Contract Authority

- [ ] 1.1 Add C2 `default_scope` requirement and validation rule for every scoped demo-execution state cell.
- [ ] 1.2 Add omitted vs explicit vs fan-out scenarios to the `tool-execution` spec delta.
- [ ] 1.3 Add scope-origin metadata requirement for readback, TTS/readback channel policy, verifier evidence, and UIUE presentation.
- [ ] 1.4 Add legacy unscoped-key disposition: demo UI/state presentation must explicitly use scoped C2 keys or a one-way compatibility adapter after `default_scope`.
- [ ] 1.5 Add closed collection-alias rules for fan-out phrases; unresolved collection-like wording must not silently default.
- [ ] 1.6 Add omitted-scope x `clarify_tag` route matrix covering fast path, slow path, ambiguous, rejected, and passthrough contexts.

## 2. Downstream Blockers

- [ ] 2.1 Retrain C5 SHALL depend on this change for omitted-scope target rendering and C2-derived scope candidates; C5 must not redefine default-scope behavior.
- [ ] 2.2 Rebuild C6 SHALL depend on this change for C6-MP-014/016/017 and any default-scope gold; C6 must not redefine default-scope behavior.
- [ ] 2.3 Demo golden-run SHALL depend on this change before freezing golden-run IDs, readback text, `scope_origin` policy, C6 case IDs, or UIUE scene tags; golden-run must not redefine default-scope behavior.
- [ ] 2.4 UIUE merge SHALL depend on this change only at state/C3-C6/golden intersections; UIUE visual work remains otherwise isolated.
- [ ] 2.5 G28 remains a UIUE merge check. Current UIUE evidence is recorded as `external_reference_unverified_current_head=17f2af1`; no UIUE file:line evidence or UIUE-ready claim may be made until a separate UIUE reconfirm pass.
- [ ] 2.6 C5 scope-candidate parity gate：C5 fallback candidates and rendered tool-call scope args must derive from C2 `scope` / `default_scope`, not a hardcoded list. Add or update tests so `window.position` candidate scopes match C2 executable scopes (`主驾`, `副驾`, `左后`, `右后`, `全车`) and any raw/source synonym such as `左前` canonicalizes before target rendering. This gate blocks C5 data generation and retrain until green. AD：`AD-DS-010`。

## 3. Verification

- [ ] 3.1 `openspec validate define-demo-default-scope --strict` passes.
- [ ] 3.2 `openspec validate --all --strict` passes.
- [ ] 3.3 `rg -n "scope.first|\\?\\? \\\"全车\\\"|\\?\\? \\\"all\\\"" Core contracts openspec docs/project docs/grill-tournament` is recorded as pre-implementation evidence, not claimed fixed.
- [ ] 3.4 Legacy-key evidence must include both legacy keys and scoped C2 keys. Run `rg -n "hvac.temperature|seat.driver.heat|seat.driver.ventilation|window.driver|lighting.ambient|screen.brightness|fan.speed" Core App Tests` plus scoped-key checks such as `rg -n "ac.temp_setpoint\\[|window.position\\[|ambient.brightness\\[" Core App Tests`. Apply closeout must prove UI/state presentation reads scoped C2 keys or a one-way compatibility adapter; recording grep output alone is not pass evidence.
- [ ] 3.5 `git -C /Users/wanglei/workspace/MAformac-uiue rev-parse --short HEAD` is recorded before using UIUE evidence; if the result is not the accepted pin for that future pass, UIUE file:line evidence remains unavailable.
- [ ] 3.6 Apply-closeout default-scope SSOT gate：after implementation, a mechanical check must fail closed if omitted-scope resolution or state-application paths still use `scope.first`, `?? "全车"`, or `?? "all"` as default fallback. The gate must be narrow enough to allow explicit `全车` / accepted collection aliases for fan-out. C2 validation must also fail if any scoped demo-execution state cell lacks `default_scope` or has `default_scope` outside `scope`. AD：`AD-DS-001`, `AD-DS-002`。
- [ ] 3.7 Apply-closeout scope-origin single-source gate：prove a single typed `ScopeOrigin` source, or equivalent closed type, is produced at target resolution and consumed by readback, TTS/readback policy, verifier evidence, and UIUE presentation metadata. Tests must distinguish omitted/defaulted scope from explicit `主驾` scope; explicit-scope readback tests must not be rewritten as defaulted-scope tests. AD：`AD-DS-003`, `AD-DS-004`。
