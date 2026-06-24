---
status: active_disposition
artifact_kind: roadmap_disposition
authority: route_control_not_ssot
retire_trigger: "Retire after all referenced roadmaps have stable historical/live banners and the next accepted live roadmap or OpenSpec exec plan supersedes this disposition."
expires: "2026-07-15"
---

# C5 Recovery And A2 Roadmap Disposition

## Verdict

Keep the old roadmaps for evidence and history, but do not use them as live route sources.

## Disposition Table

| Document | Current role | Required banner/action | Forbidden use |
|---|---|---|---|
| `docs/roadmap-2026-06-20-from-c6-done.md` | historical / provenance source | Historical banner added; former live instructions marked historical. | Do not use as current progress SSOT, P1-C launch instruction, or training permission. |
| `docs/c5-recovery-2026-06-22/roadmap.md` | historical C5 recovery incident roadmap | Historical banner added; former total-roadmap wording marked historical. | Do not use as live M0-M8 roadmap, UIUE merge plan, or D/B retrain permission. |
| `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md` | research / pre-propose checklist | Keep as input to Phase 0 and OpenSpec draft work. | Do not promote to SSOT or live roadmap. |
| `docs/project/phase0/` | Phase 0 route-control manifests | Keep manifests with status/authority/retire metadata. | Do not use as runtime contract or OpenSpec archive. |
| `docs/superpowers/plans/` | implementation plans | Keep authority=`implementation_plan_not_ssot` and retire triggers. | Do not cite as behavioral contract. |
| `openspec/changes/retrain-c5-lora-d-domain` | active draft OpenSpec carrier | ADs in design, tasks in checklist, specs pending acceptance. | Do not apply/run until decisions and proposal acceptance are complete. |
| `openspec/changes/rebuild-c6-four-layer-bench` | active draft OpenSpec carrier | ADs in design, tasks in checklist, specs pending acceptance. | Do not run base recalibration or evaluate model quality now. |

## Current Live Authority Pointers

- Constitution and route pointer: `CLAUDE.md §9`.
- Decision SSOT: `docs/grill-tournament/grill-decisions-master.md`.
- Paradigm/surface authority: `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`.
- Phase 0 route-control: `docs/project/phase0/README.md`.
- Behavior contracts: `openspec/specs/` only after archive; active changes are proposals.

## No-Launch Rule

Any document that says "next step", "起手第一步", "live roadmap", or "总纲" but is classified above as historical is not sufficient launch authority. Launch authority requires an accepted OpenSpec proposal/tasks set plus non-pending user decisions where required.
