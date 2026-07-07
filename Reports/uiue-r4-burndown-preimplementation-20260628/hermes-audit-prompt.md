# Hermes Audit Prompt: UIUE R4 Burndown Preimplementation

You are a cross-vendor read-only auditor. Audit the UIUE R4 non-code preimplementation package for P0/P1 issues.

Repo: `/Users/wanglei/workspace/MAformac-uiue`
Branch: `uiue/phase4-default-scope-presentation`
HEAD at package creation: `4a4aabbacf0736e5ff6f137be4de6cf5c6d37cb5`
Proof class claimed by package: `docs/local + mainline_readonly_probe`

Mainline read-only comparison repo:
`/Users/wanglei/workspace/MAformac`
Observed branch: `codex/rebuild-c6-doc-absorption-20260624`
Observed HEAD: `de79c653685ff4835cc74b04106120b6e785e491`
Observed truth: mainline bridge change dir is missing and mainline `docs/CURRENT.md` still says `Runtime-Presentation bridge | not_proposed`.

Target verdict options:
- `PASS_WITH_NOTES / R4_BURNDOWN_LEDGER_READY` only if no P0/P1 issues.
- `PARTIAL` if any P0/P1 issue exists or if audit cannot verify key claims.

Files to audit:
- `docs/grill-tournament/uiue-r4-burndown-2026-06-28.md`
- `docs/grill-tournament/uiue-r4-mainline-coauthor-review-request-2026-06-28.md`
- `docs/grill-tournament/uiue-r4-pre-grill-classification-2026-06-28.md`
- `docs/grill-tournament/uiue-r3-residual-routing-to-r4-r5-2026-06-28.md`
- `docs/grill-tournament/uiue-r4-human-review-packet-2026-06-28.md`
- `Reports/uiue-r4-burndown-preimplementation-20260628/dirty-ownership-manifest.md`
- `Reports/uiue-r4-burndown-preimplementation-20260628/validation-summary.md`
- `docs/CURRENT.md`
- `docs/README.md`
- UIUE bridge contract source: `openspec/changes/define-runtime-presentation-bridge/`
- Mainline read-only evidence: `/Users/wanglei/workspace/MAformac/docs/CURRENT.md` and absence/presence of `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-presentation-bridge/`

Audit questions:
1. Does R4 burndown cover C01-C50 exactly once, with no fake burndown?
2. Does every row have owner, required artifact/receipt, fail-closed rule, status, proof class, and source notes?
3. Are P0 statuses limited to `resolved_with_artifact`, `accepted_with_notes_by_human`, `explicitly_deferred_to_R5_with_non_claim`, or `blocked_by_mainline_coauthor`?
4. Are C01/C03/C06/C18 correctly blocked/pending due mainline co-author, rather than falsely accepted?
5. Is mainline co-author acceptance NOT fabricated? The package should say mainline accepted = no evidence found / pending.
6. Is `scope_origin = missing` treated as not locked, bridge-proposed future addition only, with fail-closed route pending mainline co-author?
7. Does dirty ownership manifest prevent `git add .`, broad commit, or accidental ownership of preexisting Swift/assets/test dirty paths?
8. Are proof-class non-claims preserved: no V-PASS, no mobile, no true_device, no runtime-ready, no voice-ready, no model-ready, no golden-ready, no endpoint-ready, no A-2 complete?
9. Does the package correctly state `8.C2` is closed only for R3 simulator/mock visual acceptance and `8.A` remains independent/open?
10. Are there any P0/P1 omissions, stale evidence, inconsistent route/status claims, or status overclaims making this unsafe for commander use?

Expected output format:

```markdown
# Hermes Audit: UIUE R4 Burndown Preimplementation

status: PASS_WITH_NOTES / R4_BURNDOWN_LEDGER_READY | PARTIAL
p0_findings: N
p1_findings: N
p2_findings: N
confidence: high|medium|low

## P0/P1 Findings
- If none, write `None`.
- If any, include file path and exact issue.

## Evidence Table
| Check | Evidence | Result |
|---|---|---|

## Specific Verdicts
- C01-C50 coverage:
- P0 owner/artifact/fail-closed completeness:
- Mainline co-author truth:
- scope_origin missing decision:
- dirty ownership/pathspec:
- proof-class non-claims:

## Residual Risk

## Final Recommendation
```

Do not edit files. Do not assume unstated acceptance. If you cannot read files, say so and return PARTIAL.
