# RECEIPT-M1BG — g8 PR + baseline docs consolidation

status: DONE_WITH_LOCAL_VERIFY_CAVEAT  
captured_at: 2026-07-02 Asia/Shanghai  
role: W-A / M1-β+γ executor  
repo: `/Users/wanglei/workspace/MAformac`  
proof_class: local_git + github_pr + github_actions_success + local_verify_partial  

## Scope

- β: push `c5gate/g8-tool-count` and create PR to `main`; do not merge.
- γ: create new branch off `main`, port specified docs by content extraction/semantic comparison; do not merge.
- R7: docs/construction only. No training, no generation, no C6 acceptance, no model eval, no candidate signoff.

## Starting truth

- main: `ab355f6cdb82f6ec5e1b22ec2af2c4ae07c31d6c`
- current main worktree HEAD before work: `3c9d4a14f04f191e5bcb1b67e9df93cb9275a627`
- current main worktree dirty before work: `.xcodebuildmcp/`, `Tools/agent-platform-plugin-refs/` untracked only.
- SPEC: `SPEC-M1BG-g8-pr-docs-port.md`

## β — g8 tool-count PR

Result: DONE.

- Worktree: `/Users/wanglei/workspace/MAformac-g8-tool`
- Branch: `c5gate/g8-tool-count`
- Head: `64c6f62fbb9b65c41dad08612164be53525c56e8`
- Pre-push state: clean, `main...HEAD = 0 / 1`
- Push: `git push -u origin c5gate/g8-tool-count` succeeded with proxy env unset.
- PR: https://github.com/rayw-lab/MAformac/pull/12
- PR title: `M1-beta gate8 tool_count 562 + E-2 prompt budget warning`
- CI: `Verify` run `28560025461`, head `64c6f62fbb9b65c41dad08612164be53525c56e8`, conclusion `success`.
- Merge state at check: `CLEAN`

Non-claims:

- Not merged.
- Does not unlock training or candidate signoff.

## γ — docs consolidation PR

Result: DONE.

- New worktree: `/Users/wanglei/workspace/MAformac-m1g`
- Branch: `docs/m1-gamma-baseline-consolidation`
- Base: `main@ab355f6cdb82f6ec5e1b22ec2af2c4ae07c31d6c`
- Commit: `b9b221bf120b63326d0f74c97efca0aef1883bae`
- Push: `git push -u origin docs/m1-gamma-baseline-consolidation` succeeded with proxy env unset.
- PR: https://github.com/rayw-lab/MAformac/pull/14
- PR title: `M1-gamma baseline docs consolidation`
- CI: `Verify` run `28560247291`, head `b9b221bf120b63326d0f74c97efca0aef1883bae`, conclusion `success`.

## γ port/reconcile list

| File | Status | Source | Reason |
|---|---|---|---|
| `docs/c5-training-readiness-grill/README.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption. |
| `docs/c5-training-readiness-grill/SYNTHESIS-grounded-round.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption. |
| `docs/c5-training-readiness-grill/SYNTHESIS.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption. |
| `docs/c5-training-readiness-grill/data-scoping/ws1-generation-scope.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption. |
| `docs/c5-training-readiness-grill/data-scoping/ws2-bug-mining-10family.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption. |
| `docs/c5-training-readiness-grill/dispatch/RECEIPT-G5.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption. |
| `docs/c5-training-readiness-grill/dispatch/RECEIPT-G6.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption. |
| `docs/c5-training-readiness-grill/dispatch/SPEC-G5-multiaxis-heldout-ablation.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption. |
| `docs/c5-training-readiness-grill/dispatch/SPEC-G6-c6-four-layer-threshold.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption. |
| `docs/c5-training-readiness-grill/dispatch/SPEC-G7-cloud-generator-design.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption. |
| `docs/c5-training-readiness-grill/dispatch/SPEC-W1-data-corpus.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption. |
| `docs/c5-training-readiness-grill/dispatch/SPEC-W2-algo-training.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption. |
| `docs/c5-training-readiness-grill/dispatch/SPEC-W3-eval-paradigm.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption. |
| `docs/c5-training-readiness-grill/landing-matrix.md` | ported | `3c9d4a14` | D-017 locked milestone 3 / Dim10 state carried from source. |
| `docs/c5-training-readiness-grill/reduction-table.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption. |
| `docs/c5-training-readiness-grill/scoring-table.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption. |
| `docs/c5-training-readiness-grill/worker-1-data-decisions.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption; whitespace fixed. |
| `docs/c5-training-readiness-grill/worker-1-data-round2.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption; whitespace fixed. |
| `docs/c5-training-readiness-grill/worker-1-data-round3-grounded.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption. |
| `docs/c5-training-readiness-grill/worker-2-algo-decisions.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption. |
| `docs/c5-training-readiness-grill/worker-2-algo-round2.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption. |
| `docs/c5-training-readiness-grill/worker-2-algo-round3-grounded.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption. |
| `docs/c5-training-readiness-grill/worker-3-eval-decisions.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption. |
| `docs/c5-training-readiness-grill/worker-3-eval-round2.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption. |
| `docs/c5-training-readiness-grill/worker-3-eval-round3-grounded.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption. |
| `docs/c5-training-readiness-grill/worker-commander-dim10-gate-r-l17-deepen.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption; D-017 Dim10 locked source. |
| `docs/c5-training-readiness-grill/worker-commander-failure-defense-decisions.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption. |
| `docs/c5-training-readiness-grill/worker-commander-round3-grounded.md` | ported | `3c9d4a14` | C5 grill corpus from doc-absorption. |
| `docs/c5-training-readiness-grill/gate7-cloud-generator-design.md` | skipped | main | `3c9d4a14` has no source path; main PR #11 version preserved, hash `3723a9c868bf9ac7886cec68e27af6c38cbe2a6c`. |
| `docs/c5-training-readiness-grill/worker-2-algo-dim5-papers-deepen.md` | ported | `MAformac-grill@f9e67901` | Added locked metadata `status: locked_by_magnet_2026-07-02（D-017 ③）`. |
| `docs/c5-training-readiness-grill/worker-commander-dim11-premortem-deepen.md` | ported | `MAformac-grill@f9e67901` | Added locked metadata `status: locked_by_magnet_2026-07-02（D-017 ③）`. |
| `docs/commander-log/COMMANDER-INDEX.md` | ported | `3c9d4a14` | Latest commander-log set; `SOUL.md` intentionally not ported because SPEC says 3 latest files. |
| `docs/commander-log/decisions.md` | ported | `3c9d4a14` | Latest commander-log set including D-017. |
| `docs/commander-log/swarm-runs.md` | ported | `3c9d4a14` | Latest commander-log set; whitespace fixed. |
| `docs/handoffs/2026-07-02-gptpro-audit-3pr-fix-merge.md` | ported | `3c9d4a14` | `git diff --name-only main...3c9d4a14 -- docs/handoffs/` hit. |
| `docs/handoffs/2026-07-02-overnight-pre-lora-push.md` | ported | `3c9d4a14` | `git diff --name-only main...3c9d4a14 -- docs/handoffs/` hit. |
| `docs/baseline-roadmap-2026-07-02-pre-lora.md` | ported | `3c9d4a14` | New baseline roadmap draft. |
| `docs/lora-loop-blueprint-2026-07-02.md` | ported | `3c9d4a14` | New LoRA loop blueprint draft. |
| `docs/CURRENT.md` | reconciled | `3c9d4a14` | Took newer 2026-07-02 route board; replaces stale D24/D25 route from main. |
| `docs/lessons-learned.md` | reconciled | `3c9d4a14` | Source contains main content plus A.7 and masking B.26; took source version. |
| `docs/README.md` | reconciled | `3c9d4a14` | Semantic diff is title correction from misleading “以此为准” to discoverability map; took source version. |

## Validation

β:

```text
git -C /Users/wanglei/workspace/MAformac-g8-tool status --short --branch
## c5gate/g8-tool-count

git -C /Users/wanglei/workspace/MAformac-g8-tool rev-list --left-right --count main...HEAD
0  1

gh pr view 12
head=64c6f62fbb9b65c41dad08612164be53525c56e8
Verify run=28560025461 success
mergeStateStatus=CLEAN
```

γ:

```text
git -C /Users/wanglei/workspace/MAformac-m1g status --short --branch
## docs/m1-gamma-baseline-consolidation...origin/docs/m1-gamma-baseline-consolidation

git diff --cached --check
PASS before commit

git diff --check
PASS after port

git diff --name-only main...HEAD | wc -l
40

git diff --name-only main...HEAD | rg "gate7-cloud-generator-design|Tests/|Core/|generated/|contracts/"
no hits
```

`make verify-ci` local result:

- Source-free/script gates passed through `test_c6_bench_cli=ok`.
- Final `swift test` failed: 472 tests run, 3 skipped, 5 failures.
- Failure is isolated to `RuntimePresentationPayloadFixtureConsumerTests.testLocalSiblingMainFixtureCorpusMatchesCopiedUIUECorpusWhenAvailable`.
- Failing files are sibling UIUE fixture hash mismatches: `manifest.json`, `window_position_runtime_public_payload.v1.json`, `screen_brightness_runtime_public_payload.v1.json`, `ambient_brightness_runtime_public_payload.v1.json`, `window_position_noop_runtime_public_payload.v1.json`.
- Local sibling truth: `/Users/wanglei/workspace/MAformac-uiue` is dirty and `uiue/phase4-default-scope-presentation...origin/uiue/phase4-default-scope-presentation [ahead 6, behind 78]`.
- This PR changes docs only and does not modify `Tests/Fixtures`, `Core`, `generated`, or `contracts`.

## Residual risk

- γ local hard gate is not green because `make verify-ci` failed on local sibling UIUE fixture mismatch. Treat local proof as `PARTIAL`, not PASS.
- γ GitHub PR CI passed source-free and whitespace gates. Local full `make verify-ci` remains partial because local sibling UIUE fixtures differ from copied main fixtures.
- No branch was merged.
