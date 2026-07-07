---
authority: reduction_table_v1
status: final_reduction_table_for_streamline_review
proof_class: local_repo_truth_plus_commander_synthesis_v2
claim_cap: docs_local_reduction_only
---

# Reduction Table v1

本表吸收 run-dir hermes v0 reduction table 与 `COMMANDER-SYNTHESIS-v2.md` 的修订后批次。它是精简/架构优化本轮的 disposition 终版，不授权删除、退仓、重构或 MCP runtime 接入。

## 执行态摘要

- B0 done: `dc86b1c8` no-touch 机械门。
- B1a done: `007e528f` Reports migration plan + digest index。
- B1b done: `590ff469` frozen duplicate manifest。
- B1c/B1d research done: `574c8464`; B1c source clarification done: `d7993b60`。
- B2 done: `0056d87d` verify-register + W20A/receipt tests into verify chain。
- B3a done: `31e1576c` external tool provider boundary OpenSpec change; B3b implementation is not claimed done here。
- B4a done: `8554aa3b`; B4b done: `cae99ee1`; B4c done: `5d7a323a`。
- B5 readiness done: `b73b5f71`; formal macOS implementation remains separate lane。
- B6 done: `82cb6367` architecture roadmap design note。

## v2 修订吸收

| v2 修订 | 本表处理 |
|---|---|
| B1 拆为 B1a/B1b/B1c/B1d，避免 proof-domain 混批。 | Reports、frozen、capabilities header、orphan generated 分行标独立现值。 |
| B2 加防自证 gate，并把新增 target 与挂 test 链拆成可核验动作。 | register runner 与 W20A/receipt gate 均标 `done: 0056d87d`，claim cap 限定为 local script gate。 |
| B3/B4 对 D-115 N1/N4 采用“正文过目后落”的依赖序。 | B3 仅标 decision note done；B4 status field 标 done，MCP implementation 不升格。 |
| B0 no-touch 与 register pause/resume 机械化。 | 所有 no-touch/deferred 项保留 owner+trigger，不把 docs plan 写成执行完成。 |

## Final Table

| # | 机会点 | 风险级 | disposition 现值 | owner + trigger | claim_cap | regen_dependency | 验收/证据命令 | rollback / no-action |
|---|---|---:|---|---|---|---|---|---|
| 1 | base reconciliation + no-touch gate | 中 | done: `dc86b1c8` | commander；trigger: 每批 commit 前跑 no-touch gate | branch_hygiene_only + local_guard | none | `git rev-parse HEAD @{u}`; `git ls-tree HEAD scripts/test_register_classifier_golden.py`; `Tools/checks/check-streamline-notouch.sh` | revert `dc86b1c8` if guard wrong |
| 2 | untracked macOS 草稿归属 | 低中 | done/contained: no-stage 归属 + B5 readiness `b73b5f71`；当前仍不混进 streamline commit | macOS demo owner；trigger: B5 formal implementation lane | dirty_hygiene_only | none | `git status --porcelain`; `docs/research/2026-07-07-streamline-review/macos-lane-readiness.md` | no stage; formal lane另立单 |
| 3 | success metric / authority coverage 表 | 低 | done in B7 docs: 本 reduction table +后续 checklist/handoff 承接；commit pending by commander | commander；trigger: B7 closeout commit | docs_local_only | none | `git diff --check docs/research/2026-07-07-streamline-review/reduction-table.md` | docs-only revert |
| 4 | register classifier golden/lib runners 接入 Makefile | 低 | done: `0056d87d` | register-window owner；trigger: every verify/register window | local_script_gate | no regen, but `verify-all` runs regen | `make verify-register && make verify-c5-phase1-gates && make verify-all` | revert `0056d87d` |
| 5 | W20A claim envelope / receipt basis gate 接入机械门 | 中 | done: `0056d87d` | W20A/runtime proof owner；trigger: W20A/runtime receipt closeout | local_script_gate | no regen unless `verify-all` runs | `python3 scripts/test_w20a_claim_envelope.py`; `python3 scripts/test_receipt_basis_gate.py`; `make verify-all` | revert `0056d87d` |
| 6 | iOS M.33 known-bad risk ledger | 中 | deferred/no-touch: 本轮仅承认已知风险，不修 iOS | iOS/runtime owner；trigger: iOS phase2 or explicit M.33 repair order | risk_ledger_only | none | `rg -n "loadIRMap|M.33" Core docs/lessons-learned.md` | no code change |
| 7 | iOS/UIUE-only presentation proof files | 中高 | deferred/no-touch | UIUE / presentation owner；trigger: UIUE merge lane or explicit visual proof PR | no_claim | none | `swift test --filter 'U16HapticPolicyTests|U18DistributionBoundaryGuardTests|U44LiquidGlassHardeningInventoryTests|VisualEvidenceReceiptTests'` | do not touch in streamline branch |
| 8 | Reports tracked 32 / force-add 31 | 高 | done as plan/index only: `007e528f`; no退仓 | evidence owner；trigger: 磊哥单独批准 Reports 退仓/迁移 | migration_plan_not_executed | none | `docs/research/2026-07-07-streamline-review/reports-migration-plan.md`; future `rg Reports/ docs openspec` + digest check | no delete/move; restore by path/digest only after approval |
| 9 | frozen code-basis duplicate docs + `docs/evidence-frozen` 551 files | 高 | done as manifest only: `590ff469`; tarball 化未执行 | evidence owner；trigger: 磊哥单独批 D-115 N3 follow-up | duplicate_manifest_only_no_action | none | `docs/research/2026-07-07-streamline-review/frozen-duplicate-manifest.md`; `shasum -a 256` pair scan | no delete/move/tarball in this round |
| 10 | `generated/subset-policy-manifest.json` 47 万行 / 19M | 高 | deferred: artifact policy / split study | contracts owner；trigger: artifact policy change or generated-size remediation order | no_code_change | regen-heavy | `make verify-generated && make verify-all` | no touch |
| 11 | tracked contract weight: `semantic-function-contract.jsonl` / `semantic-followup-transitions.jsonl` | 高 | retained/deferred: keep as C1/generated-chain artifacts | contracts owner；trigger: contract artifact policy decision | no_code_change | regen-heavy | `make verify-source && make verify-generated` | no touch |
| 12 | `generated/10-family-device-boundary.md` orphan generated doc | 低中 | done as research/disposition: `574c8464`; no source move | contracts/docs owner；trigger: later generated policy decides move vs generate | docs_local_orphan_disposition | regen-light if moved into gate later | `docs/research/2026-07-07-streamline-review/contracts-header-and-orphan-generated.md`; future `make verify-generated` | no move/delete in this round |
| 13 | `contracts/capabilities.yaml` header 矛盾 | 中 | research done: `574c8464`; source clarification done: `d7993b60` | contract owner；trigger: any future consumer treating it as active SSOT | docs_header_clarification_only | verify runs regen | `openspec validate --all --strict && make verify`; `rg -n "HISTORICAL|source_of_truth" contracts/capabilities.yaml` | revert `d7993b60` if wording wrong |
| 14 | active OpenSpec 11 changes lack status fields | 中 | done: `5d7a323a` | OpenSpec owner；trigger: active change routing/status review | docs_local_status_inventory | none | `openspec validate --all --strict`; `rg -n "^status:" openspec/changes/*/proposal.md` | revert `5d7a323a` if schema wrong |
| 15 | T5 banner pending vs “不改历史正文”冲突 | 中 | refresh done: `8554aa3b`; banner done: `cae99ee1` for 49 confirmed files | docs owner；trigger: future cascade historical banner batch or drift refresh | historical_banner_only | none | `docs/research/2026-07-07-streamline-review/t5-banner-refresh.md`; `git show --stat cae99ee1`; `git diff --check` | revert `cae99ee1` if banner shape wrong |
| 16 | `Core/Training/C5LoRATraining.swift` 3837 行 | 高 | design done: `82cb6367`; implementation deferred | C5 owner；trigger: C5 收口后 or explicit C5 split order | architecture_candidate_only | verify runs regen | `docs/research/2026-07-07-streamline-review/architecture-roadmap.md`; future `swift test --filter C5 && make verify-all` | no code change |
| 17 | `Core/Bench/C6VehicleToolBench.swift` 2400 行 | 高 | design done: `82cb6367`; implementation deferred | C6 owner；trigger: C6 bench maintenance window or primitives split order | architecture_candidate_only | verify runs regen | future `swift test --filter C6VehicleToolBenchTests`; `python3 scripts/verify_gold.py contracts/c6-bench-cases.jsonl generated/D_domain.tools.demo.json` | no code change |
| 18 | `Core/Generation/Gate7GeneratorPipeline.swift` 1049 行 | 中 | design done: `82cb6367`; implementation deferred | generation owner；trigger: Gate7/dev-time target split order | architecture_candidate_only | none | future `swift test --filter Gate7`; `swift build --product Gate7DryRunCLI` | no code change |
| 19 | `ContentView.swift` monolith / macOS demo lane | 高 | B5 readiness done: `b73b5f71`; implementation deferred to separate branch | macOS demo owner；trigger: formal B5 Task2-5 implementation order | local_mac_runtime_smoke_cap_only | none | `docs/research/2026-07-07-streamline-review/macos-lane-readiness.md`; future `swift test --filter U14MacLayoutContractTests` + macOS build/smoke | no refactor in streamline branch |
| 20 | MCP DomainRegistry / ExternalToolInvocation | 中 | B3a decision/OpenSpec done: `31e1576c`; Slice A/C implementation not claimed | MCP phase2 owner；trigger: note accepted + explicit implementation order | planned_unavailable_only | none | `openspec validate --all --strict`; future no App/C3 callsite diff + targeted unit tests + wording grep | no MCP client, no runtime entrypoint |
| 21 | macOS shared scheme/evidence package | 低中 | readiness done: `b73b5f71`; formal implementation deferred | macOS demo owner；trigger: B5 separate branch `opt/macos-demo-package-20260707` | local_mac_runtime_smoke_only | none | future `xcodebuild -list`; `swift test --filter U14MacLayoutContractTests`; capture/check scripts | separate lane, not cleanup branch |

## Buckets

### 本轮可删

`empty`: 本轮没有任何 code/script/doc 原件删除被授权或执行。

### 接线而非删

- `scripts/test_register_classifier_golden.py` / `scripts/test_register_classifier_lib.py`: wired by `0056d87d`.
- `scripts/test_w20a_claim_envelope.py` / `scripts/test_receipt_basis_gate.py`: wired by `0056d87d`.
- `Tools/checks/check-streamline-notouch.sh`: added by `dc86b1c8`.

### 冻结/延期

- iOS/UIUE-only proof files: no-touch until UIUE/iOS lane.
- `Reports/**`: plan/index only;退仓需磊哥单独批。
- `docs/evidence-frozen/**`: manifest only; tarball 化需磊哥单独批。
- heavy generated/contracts artifacts: retained pending artifact policy.
- C5/C6/Gate7/ContentView code refactors: design/readiness only;正式编码另立单。
- MCP runtime/client: not implemented; B3a only establishes boundary/change carrier.

## Non-Claims

- This table is not a deletion plan.
- This table is not a V-PASS/C5/C6/runtime/mobile/true-device acceptance artifact.
- B3a does not mean MCP is implemented.
- B5 readiness does not mean macOS demo package is implemented.
- B6 design does not authorize code movement.
