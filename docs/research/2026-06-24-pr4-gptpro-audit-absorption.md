---
status: active_absorption_record
artifact_kind: audit_absorption
language: zh
created_at: 2026-06-24
change_id: define-demo-default-scope
proof_class: local_review_plus_local_tests
retire_trigger: "PR #4 merged through GitHub and final head-bound receipt/CI evidence is linked from closeout."
---

# PR #4 GPT Pro 审计吸收记录

## 0. 输入与边界

本记录吸收两份手动下载的 GPT Pro 审计报告。它不是新的 OpenSpec 行为契约；行为事实仍以 active change、C2/C3/C5/C6 实现、测试和最终 receipt 为准。

| 输入 | 本地路径 | sha256 | 关键结论 |
|---|---|---:|---|
| GPT Pro 窗口1 | `/Users/wanglei/Downloads/pr_audit_4(GPTPRO窗口1).md` | `831f0a29a58b8311426668f5155725e80d4b4202347f5f0ac63739b1b34ad6f8` | `REQUEST_CHANGES`，风险来自 P1 fake-green，不是 secret/RCE。见报告1:5、:180-193。 |
| GPT Pro 窗口2 | `/Users/wanglei/Downloads/pr_audit_4(gptpro窗口2).md` | `d3eea30674b0f95dd0c9616e49acf9e99f8fb953d33a8f63769020a7ea5820c5` | `REQUEST_CHANGES`；把当前 head clean receipt + GitHub CI/status 提升为合并门 P0。见报告2:93-106、:193-205。 |

审计 proof class 只能作为 `local_review`。两份报告均明确不证明 LoRA training、真实模型 eval、C6 acceptance、demo-golden-run、voice/ASR/TTS readiness、UIUE merge 或 R-L17 closure：报告1:11-13，报告2:11-15。

## 1. 总体判定

- **未发现 CRITICAL/P0 代码安全漏洞**：报告1:193，报告2:189。
- **接受合并门 P0**：PR #4 不能在缺少当前 head clean receipt 与 GitHub CI/status 留痕时 merge。报告2:195-196。
- **接受 domain P1**：state-applier fail-closed、C6 scopeOrigin 单源、C6 readback/C3 drift、C5/C2 全设备 parity、unknown state key 动态创建均是必须修的 correctness/fake-green 缺口。
- **修正吸收默认 scope readback 建议**：GPT 基于旧 C3 test 推“defaulted scope 完全省略主驾”。UIUE AD-8.7 已拍“默认 scope 淡显、非完全省略”，因此本轮 domain plain readback 选择保留 `主驾` 文本；UIUE 后续把默认 scope 低强调展示。default_scope 决策包 G18 允许按 channel policy 呈现 metadata；UIUE 外部证据见 `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/design.md:84-88`。
- **UI finding 移交 UIUE**：`App/ContentView.swift` 的 `lastReadback` 与 presentation view model 属 UIUE 链路 A；PR #4 domain 不改 `ContentView`，只保证结构化字段和 scoped state/readback path 可供 UIUE 消费。

## 2. P0/P1/P2 吸收清单

| 优先级 | Finding | 判定 | 本轮处理 |
|---|---|---|---|
| P0 | 当前 PR head 缺 clean receipt，旧 receipt `dirty_worktree=true` 且 head 不匹配。报告1:28、:151-162、:208；报告2:93-106、:195。 | **接受，合并门** | 最终必须在 clean tree/current head 重跑本地 hard gates 并生成新 receipt；未完成前不得 merge。 |
| P0 | GitHub head 缺 workflow/status check。报告1:5、:28、:654；报告2:13、:195-196、:255-256。 | **接受，合并门** | 新增 `.github/workflows/verify.yml`；因 GitHub runner 无本机 raw snapshots，新增显式 `make verify-ci` source-free 目标，完整 `make verify-all` 仍由本地 receipt 证明。CI 会上传 `verify-ci-receipt` artifact，绑定 `GITHUB_SHA`。见 `Makefile:38-40`、`.github/workflows/verify.yml:23-56`。branch protection/required check 是 GitHub 设置，不是 repo 文件能强制完成。 |
| P1 | State applier 对 unknown/unmapped/missing/scope failure log+return，形成 fail-open。报告1:34-49、:199；报告2:21-35、:197。 | **接受，已修** | `ToolContractStateApplyError` + throwing `apply/applyWithEvidence`；unknown/unmapped/missing/scope failure 进入 error。见 `Core/Contracts/ToolContractCompiler.swift:375-445`、`:491-551`、`:578-590`。测试改为 `XCTAssertThrowsError`。 |
| P1 | C6 scope_origin_evidence 由 C6 事后重算，不是执行 artifact。报告1:53-68、:201；报告2:197-199。 | **接受，已修** | C6 删除 `C2ScopeResolver.resolve` recompute，只消费 `ToolContractStateApplier.applyWithEvidence` 的 `scopeOriginEvidence`；缺 scoped evidence 则 stateDelta failure。见 `Core/Bench/C6VehicleToolBench.swift:756-774`、`:936-953`、`:1076-1167`；机械门禁止 C6 里出现 `C2ScopeResolver.resolve`。 |
| P1 | C6 readback 与 C3 ScopeOrigin 语义漂移。报告1:72-88、:202；报告2:38-53、:199。 | **接受，但按 UIUE 口径改造** | C6 renderer 传入 `scopeOriginEvidence`；domain readback 保留默认 scope 文本，避免“主驾/全车”歧义。见 `Core/Contracts/ContractLookups.swift:173-186`、`Core/Bench/C6VehicleToolBench.swift:1361-1416`、`:1440-1467`；C3 test 期望 `主驾车窗开度100%`。 |
| P1 | C5/C2 scope parity 只覆盖 window，slot-name 全局候选会污染 sunroof/wiper/seat 等设备。报告1:92-108、:203-204；报告2:57-73、:200。 | **接受，已修** | 新增 device/cell-aware `scopeCandidatesByDeviceSlot`，CLI 注入，renderer 先按 device+slot 取 C2 scope；机械门枚举所有 mapped scoped C2 cells，不再 window-only；测试枚举 `ToolContractStateApplier.deviceCellMap` 的 scoped cells。见 `Core/Training/C5LoRATraining.swift:83-118`、`:1904-2037`、`Tools/C5TrainingCLI/main.swift:46-85`、`scripts/check_c5_c2_scope_parity.py:24-75`、`Tests/MAformacCoreTests/C5LoRATrainingTests.swift:227-242`。 |
| P1 | UI `lastReadback` 未消费 `spokenText`。报告2:77-89、:201。 | **接受，但移交 UIUE** | 不在 PR #4 改 `App/ContentView.swift`，避免与 UIUE worktree 冲突。domain 侧保留 `spokenText/scopeOrigin/default_scope` 结构化输出；UIUE merge 后消费。 |
| P1 | production path 可动态创建未知 state cell。报告1:22、:207；报告2:115-117、:202。 | **接受，已修** | `DemoVehicleStateStore.applyMockTransition` 对未知 key 返回 `missing/状态未定义`，不再插入新 cell；C3 readback verifier 会失败。见 `Core/State/DemoVehicleStateStore.swift:123-132`。 |
| P2 | 抽 `ScopedStateKey`，减少 C3/C6/UI/readback bracket parser 重复。报告2:203、:234-235。 | **接受，延期** | 跨 C3/C6/UIUE 的共享抽象，当前 PR 先封 P0/P1 fake-green；等 UIUE merge 后再统一抽，不在 PR #4 抢改 UI parser。 |
| P2 | C6 JSONL manifest/trap provenance。报告1:112-120、:205；报告2:204、:227。 | **部分吸收** | 最终 receipt 必须记录 generate/migrate logs/hash；完整 per-case manifest 可作为 `rebuild-c6` proposal 前置，不把当前 seed bench 升格为 C6 acceptance。 |
| P2 | 绝对路径/本机 fixture CI-safe。报告1:26、:209。 | **接受，延期** | 本轮新增 CI source-free gate；涉及 tokenizer/外部 fixture 的 integration gating 放后续，不阻断 default_scope domain P1 closeout。 |
| P2/P3 | research/tooling artifacts 拆 PR 或标为 non-runtime。报告1:27、:210；报告2:205。 | **接受边界声明** | 当前 PR 不把 research artifacts 当 runtime proof；最终 closeout/receipt 只把它们列为 non-runtime evidence。拆分可另开 PR，非本轮 P1 hard gate。 |

## 3. 默认 scope readback 冲突处理

GPT 报告认为默认 scope 可完全省略 `主驾`，依据是旧 C3 test：报告1:76-80，报告2:44-53。这个建议不能原样吸收，原因：

1. default_scope G18 的本意是结构化 metadata 供 channel policy 使用，不是内部状态去 scope 化；见 `docs/grill-tournament/demo-default-scope-grill-decisions-2026-06-24.md:40`、`:63`。
2. UIUE AD-8.7 已拍“默认淡显、非完全省略”，并说明后端 readback 策略按此，防客户分不清主驾/全车；见外部 worktree `.../ui-presentation/design.md:84-88`。
3. plain text/TTS 没有“淡显”能力；domain 层若完全省略，只能留下 `车窗开度100%`，这会丢失范围信息。

因此本轮决策是：**domain readback 文本保留默认 scope；UIUE 后续把默认 scope 以低强调角标/文案呈现**。这与“默认 scope 不打断、不澄清”不冲突。

## 4. CI 与 receipt 证明边界

`make verify-all` 是完整本地门，因为它包含 `verify-source`，而 `verify-source` 读取本机 raw source snapshots。GitHub runner 没有这些 raw 文件，也不应把原始 xlsx 快照推入仓。因此：

- GitHub Actions 跑 `make verify-ci`：verify-refs、cross-section、surface、default-scope gates、diff、python tests、swift test，加 `git diff --check`。它不跑 `verify-source`，也不跑 `regen`，因为 `gen_c1.py` 仍读取本机 raw source snapshots。
- 本地 final receipt 跑完整 `make verify-all`、`make verify-default-scope`、`git diff --check`、OpenSpec strict validation，并记录当前 head、dirty 状态、log sha256。
- Actions workflow 文件只能创建 CI run 并上传 `verify-ci-receipt` artifact；“required checks/branch protection”需要 GitHub 仓库设置或人工确认，不能由本文件单方面证明。

## 5. 未升格声明

本轮修复即使全部 local/CI 通过，也只关闭 PR #4 的 default_scope apply 合并门，不关闭：

- LoRA data generation/training；
- 真实模型质量评测；
- C6 acceptance 或四层 bench 重建；
- demo-golden-run；
- voice/ASR/TTS readiness；
- UIUE merge acceptance；
- R-L17 heterogeneous human review gate。

## 6. 当前待最终 closeout 检查

- clean tree/current head receipt 是否生成并可追踪；
- GitHub PR #4 head 是否有 `Verify` workflow run；
- subagent Codex 只读审计是否无 P0/P1；
- PR 合并是否通过 GitHub PR path，而不是本地 `git push origin main`；
- merge 后 local `main` 是否 reset/sync 到 `origin/main`，消除抢跑分叉。
