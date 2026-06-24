---
status: accepted_for_apply_not_implemented
artifact_kind: phase_minus_one_closeout
authority: closeout_record_not_ssot
base_commit: 6763e8a
closed_on: 2026-06-24
retire_trigger: "Retire after define-demo-default-scope is applied and archived, or after a newer default-scope closeout supersedes it."
expires: "2026-07-15"
---

# Phase -1 Default-Scope Closeout

## Verdict

Phase -1 default-scope carrier materialization is accepted for apply.

This closes only the OpenSpec carrier/proposal phase for `define-demo-default-scope`. It does not implement C2 `default_scope`, C3 target resolution, state applier behavior, readback `scope_origin`, C5/C2 parity, C6 default-scope gold, UIUE consumption, training, C6 acceptance, demo-golden-run, voice, endpoint readiness, V-PASS, S-PASS, or U-PASS.

## Closed Scope

- `openspec/changes/define-demo-default-scope/` is the standalone carrier for accepted G01-G28 demo default-scope semantics.
- The carrier owns omitted vs explicit vs fan-out behavior, collection aliases, legacy key disposition, scope-origin presentation metadata, and downstream dependency gates.
- D2 route matrix is physically present in both design and spec:
  - fast
  - slow
  - ambiguous
  - rejected
  - passthrough
- UIUE is recorded only as `external_reference_unverified_current_head=17f2af1`. No UIUE file:line evidence is claimed.
- The next implementation plan is `docs/superpowers/plans/2026-06-24-default-scope-apply.md`.

## Still Open

| Item | Status | Blocking effect |
|---|---|---|
| Default-scope apply-plan audit | same-vendor pre-check absorbed | `docs/project/phase0/default-scope-apply-plan-audit-codex-2026-06-24.md`; does not close R-L17. |
| C2 `default_scope` physical implementation | not started | Blocks retrain-c5, rebuild-c6 acceptance, demo-golden-run freeze, and UIUE merge at the state contract intersection. |
| Default-scope SSOT mechanical gate | not started | Must pass during apply closeout. |
| C5/C2 parity mechanical gate | not started | Must pass before C5 data generation or retrain. |
| ScopeOrigin single-source mechanical gate | not started | Must pass before readback/TTS/verifier/UIUE metadata claims. |
| Legacy UI key disposition | not started | Must prove scoped source or one-way adapter before default-scope apply closeout. |
| R-L17 heterogeneous deframing | open G2-G5 | Still blocks retrain-c5, rebuild-c6, and demo-golden-run readiness claims. |
| UIUE reconfirm | pending | Required before citing UIUE file:line evidence or merging UIUE. |

## Verification Ledger

Main-thread verification on 2026-06-24:

```bash
openspec validate define-demo-default-scope --strict
openspec validate --all --strict
git diff --check
```

Result:

- `openspec validate define-demo-default-scope --strict`: pass.
- `openspec validate --all --strict`: pass, 14 passed, 0 failed.
- `git diff --check`: pass, no output.

## Next Authorized Action

Execute `docs/superpowers/plans/2026-06-24-default-scope-apply.md` in order. The same-vendor pre-check has been absorbed, but physical implementation has not started:

1. C2 `default_scope` schema/parser/validator.
2. C3 target resolution and typed `ScopeOrigin`.
3. State applier default-scope behavior.
4. Readback scope-origin propagation.
5. C5/C2 scope parity.
6. C6 default-scope gold alignment.
7. Mechanical gates and local receipt.

## Forbidden Claims

Do not describe this closeout as:

- Phase 0 fully complete.
- Default-scope implementation complete.
- C5 retrain-ready.
- C6 acceptance-ready.
- demo-golden-ready.
- voice-ready.
- endpoint-ready.
- UIUE-ready.
- V-PASS, S-PASS, or U-PASS.
