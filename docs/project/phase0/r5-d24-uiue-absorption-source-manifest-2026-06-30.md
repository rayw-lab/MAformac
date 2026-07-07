---
status: d24a_source_inventory_live_verified
artifact_kind: uiue_absorption_source_manifest
authority: d24_execution_receipt
created_at: 2026-06-30
owner: codex_d24_executor
repo: /Users/wanglei/workspace/MAformac-uiue
proof_class: local_static + github_api_remote_truth + docs_local
retire_when: "D24 closeout lands and PR #6 merge evidence is recorded, or a newer D24 source manifest supersedes this file."
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# R5 D24 UIUE Absorption Source Manifest

## 0. Verdict

This file records the UIUE-side source inventory for D24. It does not claim UIUE completion, mainline runtime readiness, mobile proof, true-device proof, live API proof, or V/S/U-PASS.

Current source-side verdict: `PASS_FOR_D24A_CONTINUE`.

## 1. Live UIUE Truth

| Field | Live value |
|---|---|
| path | `/Users/wanglei/workspace/MAformac-uiue` |
| branch | `uiue/phase4-default-scope-presentation` |
| local HEAD | `4c7da7167a64f79839327d9f11d633aa2948f171` |
| upstream relation | ahead of `origin/uiue/phase4-default-scope-presentation` by 4 |
| PR | `#6` `https://github.com/rayw-lab/MAformac/pull/6` |
| PR head | `1b84af5f08bc0ac188c01b53ca888b0eb3d13c1c` |
| PR base | `main` at `c1e7d58d281d0256d29034c1d120cefe0bf5a033` |
| PR state | `OPEN`, draft `false`, `mergeStateStatus=CLEAN` |
| PR checks | `verify` `SUCCESS` at `2026-06-30T05:29:44Z` |
| PR file count | `1130` from paginated GitHub PR files API |

## 2. Local Dirty And Untracked Inputs

| Path | state | source class | disposition | destination / handling |
|---|---|---|---|---|
| `AGENTS.md` | modified | route entry | `absorb_summary_index` | reconcile entry rules in D24C; do not treat as standalone authority over main `CLAUDE.md` |
| `CLAUDE.md` | modified | project constitution | `absorb_summary_index` | preserve UIUE-specific build/simulator/route deltas in D24C |
| `docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md` | modified | route-control | `absorb_full` | current UIUE R5 route map update candidate |
| `docs/dispatches/2026-06-29-uiue-r5-d12-runtime-adapter-v0-code-train-dispatch.md` | untracked | dispatch provenance | `historical_reference_only` | index as D12 provenance, not current route authority |
| `docs/dispatches/2026-06-29-uiue-r5-d13-c3-runtime-adapter-integration-dispatch.md` | untracked | dispatch provenance | `historical_reference_only` | index as D13 provenance, not current route authority |
| `docs/dispatches/2026-06-29-uiue-r5-d14-runtime-adapter-residual-train-dispatch.md` | untracked | dispatch provenance | `historical_reference_only` | index as D14 provenance, not current route authority |
| `docs/dispatches/2026-06-29-uiue-r5-d15-runtime-presentation-payload-contract-dispatch.md` | untracked | dispatch provenance | `historical_reference_only` | index as D15 provenance, not current route authority |
| `docs/dispatches/2026-06-29-uiue-r5-d16-d17-core-config-force-state-uiue-consumer-supertrain-dispatch.md` | untracked | dispatch provenance | `historical_reference_only` | index as D16-D17 provenance, not current route authority |
| `docs/dispatches/2026-06-29-uiue-r5-d18-d19-runtime-durability-uiue-guard-dispatch.md` | untracked | dispatch provenance | `historical_reference_only` | index as D18-D19 provenance, not current route authority |
| `docs/research/2026-06-29-visual-acceptance-standard/INDEX.md` | untracked | visual research index | `absorb_summary_index` | summarize in main D24 manifest/closeout unless user asks for full copy |
| `docs/research/2026-06-29-visual-acceptance-standard/README.md` | untracked | visual research report | `absorb_summary_index` | summarize; keep UIUE as source |
| `docs/research/2026-06-29-visual-acceptance-standard/lens-h1-vlm-mechanism.md` | untracked | visual research lens | `absorb_summary_index` | summarize; keep UIUE as source |
| `docs/research/2026-06-29-visual-acceptance-standard/lens-h2-quantified-contract.md` | untracked | visual research lens | `absorb_summary_index` | summarize; keep UIUE as source |
| `docs/research/2026-06-29-visual-acceptance-standard/lens-h3-geometry-frameworks.md` | untracked | visual research lens | `absorb_summary_index` | summarize; keep UIUE as source |
| `docs/research/2026-06-29-visual-acceptance-standard/lens-h4-two-adapters.md` | untracked | visual research lens | `absorb_summary_index` | summarize; keep UIUE as source |
| `docs/research/2026-06-29-visual-acceptance-standard/lens-h5-pitfalls-orchestration.md` | untracked | visual research lens | `absorb_summary_index` | summarize; keep UIUE as source |
| `docs/research/2026-06-29-visual-acceptance-standard/lens-h6-cross-language.md` | untracked | visual research lens | `absorb_summary_index` | summarize; keep UIUE as source |
| `docs/research/2026-06-29-visual-acceptance-standard/skill-design-spec.md` | untracked | visual skill design | `absorb_summary_index` | summarize; do not make it current implementation authority |
| `docs/research/2026-06-29-visual-acceptance-standard/teardown-notes.md` | untracked | visual teardown notes | `absorb_summary_index` | summarize; keep proof-cap wording |

Ignored/generated families observed by `git status --ignored --short`:

| Family | disposition | note |
|---|---|---|
| `.DS_Store`, `__pycache__/`, `.build/`, `.venv/`, `.playwright-mcp/`, `.gitnexus/` | `generated_drop` | local/generated tool state |
| `Reports/*` run directories | `generated_drop` by default | PR #6 already carries selected trackable reports; untracked run directories are not automatically absorbed |
| `docs/research/2026-06-25-a2-execution/shots/*` and `zone-compare-*` | `generated_drop` by default | screenshot/visual run outputs; cite only through curated evidence indexes |
| `Tools/checks/__pycache__/`, `Tools/skills/*/__pycache__/` | `generated_drop` | generated Python bytecode |

No raw/customer/secret/PII candidate is required for D24A. If a later D24 stage needs raw/prohibited content to prove absorption, execution must stop before merge.

## 3. PR #6 Source Surface

PR #6 paginated file API summary:

| top-level | count | source disposition |
|---|---:|---|
| `.claude` | 36 | `already_in_pr`; project-local skills/provenance surface |
| `.githooks` | 1 | `already_in_pr`; D24D must define advisory vs required gate |
| `.gitignore` | 1 | `already_in_pr` |
| `.xcodebuildmcp` | 2 | `already_in_pr`; D24D must define simulator/profile ownership |
| `AGENTS.md` | 1 | `already_in_pr` |
| `App` | 14 | `already_in_pr`; UI presentation implementation surface |
| `CLAUDE.md` | 1 | `already_in_pr` |
| `Core` | 24 | `already_in_pr`; UI presentation/state mapping surface |
| `MAformac.xcodeproj` | 3 | `already_in_pr` |
| `MAformacIOSUITests` | 2 | `already_in_pr` |
| `Makefile` | 1 | `already_in_pr`; includes UIUE verification surface |
| `Reports` | 16 | `already_in_pr`; selected trackable evidence receipts only, not product proof |
| `Tests` | 38 | `already_in_pr` |
| `Tools` | 350 | `already_in_pr`; checks and skill/reference surface |
| `docs` | 632 | `already_in_pr`; route/research/grill/provenance surface |
| `openspec` | 8 | `already_in_pr`; includes `ui-presentation` and bridge context |

Key PR #6 code/test/config paths that D24D must account for:

- `.githooks/pre-commit`
- `.xcodebuildmcp/README.md`
- `.xcodebuildmcp/config.yaml`
- `App/ContentView.swift`
- `Core/Presentation/*`
- `Core/State/DemoVehicleStateStore.swift`
- `MAformac.xcodeproj/*`
- `MAformacIOSUITests/*`
- `Makefile`
- `Tests/Fixtures/RuntimePresentationPayload/*`
- `Tests/MAformacCoreTests/*Presentation*`
- `Tools/checks/*`
- `Tools/skills/INDEX.md`
- `openspec/changes/ui-presentation/*`
- `openspec/changes/define-runtime-presentation-bridge/*`

## 4. Initial Source Disposition Counts

```yaml
disposition_counts:
  absorb_full: 1
  absorb_summary_index: 13
  already_in_pr: 16
  historical_reference_only: 6
  generated_drop: 4
  raw_secret_no_touch: 0
  requires_user_decision: 0
```

Counts are source-manifest counts by row/group, not the 1130 individual PR files.

## 5. Risk Skills And Stage Receipt

```yaml
risk_skills:
  pre_mortem:
    used: true
    tiger:
      - "UIUE source docs can be mistaken for mainline runtime proof."
      - "Selected Reports in PR #6 can be over-read as product validation."
      - "Tooling/skill payloads can be merged without ownership notes."
    paper_tiger:
      - "Large UIUE docs/research volume is acceptable if route-control keeps proof class capped."
    elephant:
      - "UIUE value is split between implementation, visual evidence, process receipts, and local generated proof artifacts."
    mitigation:
      - "Keep this source manifest and main absorption manifest paired."
      - "Use D24C/D24D to pin route-control and validation limits."
  iceberg_teardown:
    used: true
    visible_symptom: "UIUE PR #6 has broad code/docs/tools/reports surface under one green check."
    deeper_cause: "Branch-level checks do not classify which artifacts are authority, provenance, generated evidence, or no-claim docs."
    same_class_risk:
      - "R4/R5 evidence treated as current route authority"
      - "simulator/mock visual evidence promoted to mobile/true_device"
      - "local tool defaults promoted to universal build policy"
    fix: "Pair PR merge with source manifest, main absorption manifest, route-board reconciliation, and proof-cap closeout."
```

```yaml
skills_ledger:
  executing_plans: used
  pre_mortem: used_at_stage_start
  bug_iceberg_teardown: used_when_triggered
  oracle_external_truth: used_for_github
  openspec: used
  gitnexus: not_code_change
  github: used
  subagentcodex: post_D24G_only
  github_cloud_audit: post_D24G_only
lessons_learned:
  - "D12-D19 dispatches are useful provenance but should not override D24 live route-control."
metacognitive_check:
  - "Did not equate UIUE source evidence with accepted mainline proof."
goal_drift_check:
  - "No K1/C5/C6/voice/golden/runtime/product work started."
claim_vs_proof_check:
  - "All source claims are local_static, docs_local, or github_api_remote_truth."
boundary_check:
  - "No raw/secret copying and no branch deletion."
self_question:
  - "If a UIUE row is misclassified, `git status --short`, ignored status, or paginated PR files API should expose the counterexample."
```

## 6. D24D Source Validation Receipt

This source repo was validated as PR #6 source/provenance plus local D24 route-control metadata. The D24 local stage did not edit UIUE source, test, Xcode project, Makefile, hook, or tool files.

```yaml
d24d_source_validation:
  repo: /Users/wanglei/workspace/MAformac-uiue
  branch: uiue/phase4-default-scope-presentation
  local_head_at_validation: 4c7da7167a64f79839327d9f11d633aa2948f171
  pr_6_remote_head_at_d24a: 1b84af5f08bc0ac188c01b53ca888b0eb3d13c1c
  local_d24_code_diff: none
  commands:
    git_diff_code_surface:
      command: "git diff --name-status -- App Core Tests MAformacIOSUITests Makefile Package.swift .github .githooks .xcodebuildmcp MAformac.xcodeproj"
      result: PASS_NO_OUTPUT
    git_diff_check:
      command: "git diff --check"
      result: PASS_NO_OUTPUT
    openspec:
      command: "openspec validate --all --strict"
      result: PASS_16_PASSED_0_FAILED
    swift_test:
      command: "swift test"
      result: PASS_348_TESTS_3_SKIPPED_0_FAILURES
    make_verify_ci:
      command: "make verify-ci"
      result: PASS_348_TESTS_3_SKIPPED_0_FAILURES_AND_CONTENTVIEW_WIRING_PASS
    gitnexus_staged:
      command: "mcp__gitnexus.detect_changes(repo=MAformac-r5-uiue-current, scope=staged)"
      result: PASS_LOW_RISK_AFFECTED_PROCESSES_0_CHANGED_FILES_4
  proof_cap:
    - local
    - unit
    - docs_local
    - github_api_remote_truth
  nonclaims:
    - "No mobile/true_device/live_api/product readiness claim."
    - "Selected UIUE reports remain receipts, not V-PASS."
```
