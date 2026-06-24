# Phase 0 Grill Loop Competition Contract

## Contract

- Repository: `/Users/wanglei/workspace/MAformac`
- Output directory: `/Users/wanglei/workspace/MAformac/docs/loop-competition/2026-06-24-phase0-grill`
- Mode: fixed 24-candidate blind scoring
- Rounds: 2
- Reviewers per round: 3 real subagents
- Required core deliverables: `round-01/brain-1.md`, `round-01/brain-2.md`, `round-01/brain-3.md`, `round-01/judge.md`, `round-02/brain-1.md`, `round-02/brain-2.md`, `round-02/brain-3.md`, `round-02/judge.md`
- Scoring formula: `Importance + Verifiability + NonDuplication + DecisionLeverage + RiskRevelation`, each 1-5, total 5-25
- Web research: optional, only when needed for time-sensitive external facts; local source verification is required

## Mandatory Source Pool

Reviewers should read enough of these files to score the candidates with file-line evidence:

- `CLAUDE.md`
- `docs/README.md`
- `CONTEXT.md`
- `docs/grill-tournament/grill-decisions-master.md`
- `docs/grill-tournament/cascade-inventory.md`
- `docs/research/2026-06-23-a2-post-roadmap-audit-vs-home-llm.md`
- `docs/c5-recovery-2026-06-22/roadmap.md`
- `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`
- `docs/srd-three-layer-intent-routing.md`
- `docs/research/2026-06-23-a2-execution/S_CLOSE-audit-absorption.md`
- `docs/handoffs/2026-06-24-a2-merged-d-domain.md`
- `openspec/changes/retrain-c5-lora-d-domain/proposal.md`
- `openspec/changes/retrain-c5-lora-d-domain/tasks.md`
- `openspec/changes/rebuild-c6-four-layer-bench/proposal.md`
- `openspec/changes/rebuild-c6-four-layer-bench/tasks.md`

## Reviewer Rules

- Read `candidates-blind.md`; score all 24 candidates.
- Do not read other `brain-*.md` files or judge files.
- Do not include the main agent's previous recommendations; evaluate the questions as if fresh.
- Local verification is required: cite `file:line` for material claims.
- Web verification is optional and should be cited with URL and date if used.
- Write the assigned markdown file directly to disk and return only the path plus a short summary.
- Do not modify any repository files outside the assigned output file.

## Reviewer File Schema

```markdown
# Brain N - Round XX

## Scope And Evidence
- ...

## Keep
| Candidate | Score | Reason |

## Delete
| Candidate | Reason |

## Merge
| Candidates | Proposed canonical wording | Reason |

## Rewrite
| Candidate | Proposed wording | Reason |

## Missing Risks
- ...

## Scores
| Candidate | Importance | Verifiability | NonDuplication | DecisionLeverage | RiskRevelation | Total | Priority | Needs User Grill? |

## Candidate Notes
| Candidate | Verdict | Evidence | Recommended Conclusion |

## Rationale
...
```
