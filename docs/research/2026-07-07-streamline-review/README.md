---
authority: streamline_review_index
status: active_index
date: 2026-07-07
repo: /Users/wanglei/workspace/MAformac
branch: opt/streamline-macos-20260707
proof_class: local_repo_truth
---

# Streamline Review Index

本文件是 2026-07-07 streamline / macOS convergence 收口总入口。它索引已落成果、commit 账、残余风险和下一步实施顺序；不替代 `CLAUDE.md`、`docs/CURRENT.md`、OpenSpec specs 或 run-dir receipt。

## 1. 双任务成果索引

### 1.1 本目录 7 个成果文件

| 文件 | authority/status | 内容 | 当前动作 |
|---|---|---|---|
| `reports-migration-plan.md` | `migration_plan_not_executed` / `PLAN_ONLY_NOT_EXECUTED` | `Reports/` tracked evidence 迁移计划与 digest 索引；口径 `32 tracked / 31 force-add excluding .gitkeep`。 | 不退仓；等磊哥单独点头。 |
| `frozen-duplicate-manifest.md` | `duplicate_manifest_only_no_action` | frozen code-basis 与 live docs 的重复清单；`72` same-hash + `1` drift。 | 不 tarball、不删除；等磊哥单独点头。 |
| `contracts-header-and-orphan-generated.md` | `RESEARCH_ONLY` | `contracts/capabilities.yaml` header 矛盾澄清；`generated/10-family-device-boundary.md` orphan generated 定性与三档方案。 | 预研档；后续处置需 commander 批。 |
| `t5-banner-refresh.md` | B4a preflight | 重验 `cascade-inventory.md §T5`：49 可 banner、24 已有 banner、2 复核。 | B4b 已据此给 49 件加 HISTORICAL banner。 |
| `architecture-roadmap.md` | `design_note_not_ssot` | B6 架构 roadmap：C5/C6/Gate7 拆分、runtime primitives、target split、MCP 成本、双 SSOT。 | 设计档；正式编码另立单。 |
| `macos-lane-readiness.md` | `READINESS_REPORT_ONLY` | B5 macOS lane 就绪报告：Task1 probe 绿，Task2-5 可执行但需前置。 | 正式编码另立单。 |
| `reduction-table.md` | `reduction_table_v1` | B7① reduction table：吸收 synthesis v2 后的 disposition 终版；不授权删除、退仓、重构或 MCP runtime 接入。 | 本 README 的直接上游成果之一。 |

`README.md` 是第 8 个同目录文件，但角色是总入口索引，不计入上表“7 个成果文件”。

### 1.2 Repo / OpenSpec / Verify 成果

| 成果 | 落点 | 状态 | 备注 |
|---|---|---|---|
| B3a external ToolProvider boundary | `openspec/changes/define-external-tool-provider-boundary/{proposal.md,design.md,tasks.md,specs/external-tool-provider/spec.md}` | `active_contract_carrier` | 明确从旧“Capability 同构”改为 `vehicle Capability + domain-neutral ToolProvider` 并行；代码 Slice A/C 尚未实现。 |
| Makefile register gate | `Makefile` target `verify-register` + `verify` 链 | landed | `verify-register` 跑 `scripts/test_register_classifier_lib.py` 与 `scripts/test_register_classifier_golden.py`；golden 50 rows / 10 pairs / 10 boundary。 |
| 11 change status 字段 | 11 个 `openspec/changes/*/proposal.md` | landed | `define-core-config-force-state-authority`、`define-demo-default-scope`、`define-demo-golden-run-and-voice`、`define-lora-data-gate`、`define-runtime-adapter-execution`、`define-runtime-presentation-bridge`、`migrate-d-domain-tool-surface`、`rebuild-c6-four-layer-bench`、`retrain-c5-lora-d-domain`、`run-lora-candidate-training`、`ui-presentation`。 |
| T5 49 banner | `docs/{research,second-review,repo-intelligence,handoffs,dispatches}/...` 49 文件 | landed | 每文件头部加 HISTORICAL banner；B4b receipt scoped diff 为 `49 files changed, 196 insertions(+)`，numstat 删除数 0。 |
| B0 no-touch gate | `Tools/checks/check-streamline-notouch.sh` | landed | 对 no-touch 路径做 staged diff 防线，含 evidence、contracts/generated、iOS 面、训练 grill、openspec specs。 |

## 2. Commit 账（12 sha）

| # | sha | 主题 | proof domain |
|---:|---|---|---|
| 1 | `dc86b1c8` | B0 no-touch 机械门 | guardrail |
| 2 | `31e1576c` | B3a `define-external-tool-provider-boundary` 四件套 | OpenSpec contract |
| 3 | `0056d87d` | B2 `verify-register` 接入 `verify` 链 | Makefile / register tests |
| 4 | `5d7a323a` | B4c 11 active change 加 status 字段 | OpenSpec metadata |
| 5 | `007e528f` | B1a Reports migration plan + digest 索引 | evidence migration plan |
| 6 | `590ff469` | B1b frozen duplicate manifest | frozen duplicate manifest |
| 7 | `574c8464` | B1c/B1d 预研档 | contracts/generated research |
| 8 | `8554aa3b` | B4a T5 banner 清单 refresh | docs inventory |
| 9 | `d7993b60` | B1c `contracts/capabilities.yaml` header 澄清 | contracts note |
| 10 | `cae99ee1` | B4b T5 HISTORICAL banner 批 | docs banner |
| 11 | `82cb6367` | B6 architecture roadmap | design note |
| 12 | `b73b5f71` | B5 macOS lane readiness | readiness report |

`68605753` 是 D-115 commander 补记，不计入本 12 项执行成果账。

## 3. 残余风险与延期清单

| 项 | 状态 | 为什么不在本轮做 | 下一步 owner / gate |
|---|---|---|---|
| iOS-only 4 件冻结 | frozen / deferred | Q2=C 冻结 iOS；删或改 iOS-only proof 文件算动 iOS 面。四件：`Core/Presentation/PresentationHapticPolicy.swift`、`Core/Presentation/LiquidGlassHardeningInventory.swift`、`Core/Presentation/DistributionBoundaryGuard.swift`、`Core/Presentation/VisualEvidenceReceipt.swift`。 | 二期 iOS 路线明朗后由磊哥单独拍；本分支 no-touch gate 已纳入。 |
| M.33 iOS `ir_map` |知情冻结 / deferred | D-115 N2 只批“知情冻结、二期再修、成本存档”；本轮不修 iOS loader。 | 二期 iOS 修复单；参考 run-dir `out/m33-ios-irmap-status.md`。 |
| `Reports/` 退仓 | plan-only | 退仓涉及 tracked evidence 删除和引用稳定性；D-115 N3 只批 plan + digest。 | 磊哥单独点头后执行；先复核 `reports-migration-plan.md` 的 A/B/C 分层。 |
| frozen 快照 tarball | manifest-only | tarball 化改变一手证据形态；D-115 N3 只批重复清单，不批删原件。 | 磊哥单独点头后执行；需 tarball digest + restore command + 引用不破。 |
| 47 万行 manifest artifact policy | deferred policy | `generated/subset-policy-manifest.json` 属 active verify surface；不是 deadcode。体量大但入 Makefile generated diff gate。 | 单独 artifact policy：压缩/分片/保留策略须先证明 `make verify`、budget gate 和 downstream tests 不退化。 |
| `generated/10-family-device-boundary.md` | deferred | 预研建议“留 + 加注释 + 纳 diff gate”，但未获本轮执行授权。 | 需 commander 批后改 metadata / Makefile gate；或迁 `docs/research` 并批量修引用。 |
| CROSS-01 register 侧信道 | PR 风险 | 本分支从含 register 相关未合 main commit 的 HEAD 切出，streamline PR 不是纯独立 diff。 | 发 PR 时显式声明：本分支含 register window 基础 commits，review 要按 base/stack 分层看，避免把 register 侧信道混成 streamline 成果。当前本地分支无 upstream。 |
| macOS demo convergence plan | untracked input | `docs/superpowers/plans/2026-07-07-macos-demo-convergence-baseline.md` 仍未跟踪；B5 只做 readiness，不 stage 它。 | Task2-5 独立 lane 决定是否接管/落档。 |

## 4. 按部就班实施指引

### B3b：ToolProvider Slice A/C 编码

前置：
- B3a OpenSpec 四件套已存在且 `define-external-tool-provider-boundary` 为 `active_contract_carrier`。
- 代码前重新跑 `openspec validate define-external-tool-provider-boundary --strict`。
- 确认 proof-class 选型：本 B3a 文档采用 public `PresentationProofClass` Option A；若改 Option B，必须先 amend spec + mapping/fail-closed tests。

实施：
- Slice A：新增 `DomainDescriptor` / `DomainID` / `DomainRegistry`，只读注册 navigation/music/foodDelivery 三个 disabled planned entry，vehicle 不进 DomainRegistry。
- Slice C：新增 `ExternalToolSchema` / `ExternalToolInvocation` / `ExternalToolResult` / `ExternalToolStatus` / `ToolProviderDescriptor` / `ToolProvider` / `DisabledMcpToolProvider` / `DomainProviderGuard`。
- 不接 App/C3，不导入 MCP SDK，不加 `.success`，不读 `DemoVehicleStateStore`。

验收：
- `swift test --filter DomainRegistryTests`
- `swift test --filter ExternalToolInvocationTests`
- `git diff --check`
- `rg -n "DemoVehicleStateStore|C3ExecutionPipeline|DemoRuntimeSessionRunner|\\.success" Core/Domain` 期望 0 命中。
- 强词 grep：`rg -n "已支持 MCP|已支持导航|已支持音乐|已支持外卖|MCP success|runtime_ready|true_device_ready|V-PASS" openspec/changes/define-external-tool-provider-boundary docs` 期望 0 命中。
- `make verify-all` 或明确降级说明。

### B5：macOS Task2-5 编码

前置：
- 从当前 streamline HEAD 切独立 lane。
- Task2.0 前核 `MAformacMac` target BlueprintIdentifier：`grep "MAformacMac.*PBXNativeTarget" -A3 MAformac.xcodeproj/project.pbxproj`。
- 创建 `MAformacMac.xcscheme` 属 Xcode 工程文件改动，需 commander 批。

实施与验收：
- Task2.0：创建 repo-owned shared scheme；验收 `xcodebuild -list -project MAformac.xcodeproj | rg "MAformacMac"`。
- Task2.1-2.2：新增 `Tools/checks/check-macos-demo-evidence.py` 与 `capture-macos-demo-evidence.sh`；验收 capture 脚本能 build/run/screenshot，若 Accessibility/System Events 阻塞只能写 `NEEDS_EVIDENCE`，不能软化为 pass。
- Task2.3-2.4：生成 `docs/research/2026-07-07-macos-demo-convergence/evidence.json` + README；验收 validator PASS。
- Task3：只给 `ui-presentation` 与 `define-runtime-presentation-bridge` tasks 加 dated note，不关闭 8.C2；验收两个 openspec validate 绿。
- Task4：新增 launch checklist / non-claim ledger / rollback notes；验收 `swift test --filter U14MacLayoutContractTests` + no-claim grep。
- Task5：独立 read-only audit；Task2-4 完成后再开。

### B6 roadmap 各刀

前置：
- `architecture-roadmap.md` 是 `design_note_not_ssot`，正式编码每刀另立执行单。
- 每刀开工前 fresh `git status`，并按触达面跑 impact/调用面扫描。
- 不在 register S7c/run-auth 或 C5 training/evidence 窗口混入高风险架构改动。

建议顺序：
1. Runtime primitives：先抽 `C6ToolCall` / `C6Hash` / `C6CanonicalJSON`，保持 type names 和行为不变。
2. C6 bench types/codec：JSONL gold 仍是 committed gold，Swift default cases 只能是 fixture/generator，不得成为第二 SSOT。
3. Gate7 split：在 primitives 稳定后拆 provider/manifest/pipeline/deterministic gates。
4. C5 Training split：最后做；这是最高风险证据链，需 C5 targeted tests + `make verify-c5-phase1-gates`。
5. SwiftPM target split：先 SwiftPM 后 Xcode membership；`MAformacCore` runtime 与 `MAformacDevToolsCore` dev-time 分离。
6. Xcode membership：单独 commit、单独验收 Mac/iOS app build，禁止混入大文件拆分。
7. SSOT cleanup：`capabilities.yaml` historical test 命名、C6 JSONL vs Swift defaults、generated orphan、compiled/file IR map 分开处理。

验收基线：
- `swift test`
- `make verify-all`
- 相关 targeted tests：C5/C6/Gate7/RuntimePresentationBridge/PresentationSnapshot。
- App build 面：`xcodebuild -scheme MAformacMac -configuration Debug build`；触 shared runtime 时补 `xcodebuild -scheme MAformacIOS -configuration Debug build` 或明确降级。

## 5. Non-claims

- 本目录不是 candidate signoff，不是 C5 V-PASS，不是 C6 acceptance，不是 mobile/true-device/live acceptance。
- B3a 是 contract carrier，不是 MCP runtime support。
- B5 是 readiness report，不是 macOS demo evidence package 完成。
- B6 是 design note，不授权代码拆分。
- Reports/frozen 只出 plan/manifest，没有退仓、删除、tarball 或迁移。
- T5 49 banner 是文档历史标注，不改变正文事实或推进权威。
