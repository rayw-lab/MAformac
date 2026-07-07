---
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# GPT Pro Audit Request - Rebuild-C6 Scoring Foundation

## Audit Target

repo: /Users/wanglei/workspace/MAformac
github_repo: https://github.com/rayw-lab/MAformac
branch: codex/rebuild-c6-doc-absorption-20260624
branch_url: https://github.com/rayw-lab/MAformac/tree/codex/rebuild-c6-doc-absorption-20260624
change: rebuild-c6-four-layer-bench
scope: post-A2 / post-PR4 default_scope / post-R-L17 route-only rebuild-C6 Sections 1-3 construction scoring foundation

Local closeout: /Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-scoring-foundation-closeout-2026-06-25.md
Lessons: /Users/wanglei/workspace/MAformac/docs/project/phase0/rebuild-c6-scoring-foundation-lessons-2026-06-25.md

## What To Audit

- shared `VehicleToolBehaviorClass` taxonomy and C6 case adapter
- two-axis C6 reporting
- denominator selector shell with no thresholds/base recalibration
- apply `StateWrite` facts and write_kind semantics
- C6 applied-write consumption and dependency `dependsOn` proof
- readback split from model hard pass
- forbidden-work boundaries
- closeout evidence completeness

## What Is Not Authorized

- retrain-C5
- C6 acceptance
- D-domain base recalibration
- Section 4 candidate comparison
- model evaluation
- golden-run
- voice
- endpoint readiness
- UIUE merge
- R-L17 candidate signoff

## Required Verdict

Return:
- status: PASS / PASS_WITH_FIXES / FAIL
- P0/P1/P2 findings with file:line anchors
- teardown: top 3 fake-green paths still possible
- whether this branch is ready for the next long-run, Phase 4-6 identity and shape closeout

## Controller Notes

- Treat this as local construction proof only: `local_static_contract`, `local_unit`, `local_receipt_consistency`.
- Do not judge model quality, C6 acceptance, endpoint readiness, voice, UIUE merge, or demo readiness.
- `GPT Pro request pushed` is not `GPT Pro audit passed`; this branch remains local-pass pending external audit until a real verdict is returned and P0/P1 findings are absorbed.
