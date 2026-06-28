---
status: partial_local_unit_checker_receipt
artifact_kind: implementation_receipt
date: 2026-06-27
repo: /Users/wanglei/workspace/MAformac-uiue
branch: uiue/phase4-default-scope-presentation
base_head: 4a4aabb
proof_classes:
  - local
  - unit
non_claims:
  - no 8.C2 closure
  - no V-PASS
  - no mobile
  - no true_device
  - no runtime-ready
  - no voice-ready
  - no A-2 complete
---

# UIUE R1/R2b First Implementation Slice Receipt

## Verdict

本 receipt 记录 R1/R2b 第一实现切片：R1 增加 read-only `StateCellInteractionPolicy` projection 与 unit proof；R2b 增加 local layout/spacing checker foundation 与 fixture receipt。它只证明 local + unit + checker 基础，不关闭 `8.C2`，不替代 L3。

## Implemented

| Slice | Path | Proof class | What changed |
|---|---|---|---|
| R1 interaction projection | `Core/Presentation/StateCellInteractionPolicy.swift` | local + unit | 从 `FamilyCardIDMapper`、`FamilyPrimaryCellMapper`、`UIValueTypeMapper`、`ValueRangeMapper`、`StateCellPresentationCatalog`、`BadgeOptionMapper` 派生可交互性、range/options/readback/proof boundary。 |
| R1 unit tests | `Tests/MAformacCoreTests/StateCellInteractionPolicyTests.swift` | unit | 覆盖 projection derivation、read-only/process no fake options、dial/percent/stepper/toggle/badge representative writeback/readback、ambient/wiper active-cell gap、ring cross-zero delta。 |
| R2b checker | `Tools/checks/check-uiue-layout-spacing.py` | local | 从 UI tree frames + screenshot metadata 输出 structural receipt：missing_identifiers、overlap_pairs、min_gaps、zone_budget、safe_area_violations、threshold_source、warnings、non_claims。 |
| R2b fixture receipt | `layout-spacing-receipt.json` | local | fixture run 输出 `WARN`；white-edge leakage 保持 `BLOCKED_FOR_THRESHOLD`。 |
| Grill burndown | `docs/grill-tournament/uiue-r0-r2-grill-burndown-2026-06-27.md` | local/docs | 记录 Cxx/canonical group 的 resolved/partial/deferred/still_open/not_touched，不消减未验证项。 |
| Current router readback | `docs/CURRENT.md` | local/docs | 更新 R1/R2b 第一实现切片状态为 PARTIAL local + unit + checker foundation，避免后续窗口读到 stale pre-implementation state。 |

## Validation Snapshot

| Command | Result | Proof class |
|---|---|---|
| `Tools/checks/check-uiue-layout-spacing.py --help` | pass | local |
| `Tools/checks/check-uiue-layout-spacing.py --ui-tree docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/fixtures/layout-ui-tree.json --screenshot-metadata docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/fixtures/layout-screenshot-metadata.json --crop-dir docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/crops --output docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/layout-spacing-receipt.json` | pass, receipt status `WARN` | local |
| `Tools/checks/check-uiue-layout-spacing.py --ui-tree docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/fixtures/layout-ui-tree-missing-target.json --screenshot-metadata docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/fixtures/layout-screenshot-metadata.json --crop-dir docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/crops --output docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/r1-r2b-implementation/layout-spacing-missing-target-receipt.json; code=$?; test "$code" -eq 1` | pass as fail-closed check: command exits 1 and receipt status `FAIL` | local |
| `swift test --filter StateCellInteractionPolicyTests` | pass, 5 tests / 0 failures | unit |
| `swift test` in main worktree | fail, `U44LiquidGlassHardeningInventoryTests.testSourceFilesStillContainOnlyInventoryGlassSurfaces` | integration/local; blocked by unowned dirty App file |
| `swift test` in detached clean-baseline worktree with only owned Swift files copied | pass, 315 tests / 0 failures / 3 skipped | integration/local |
| `git diff --check` | pass | local |
| `openspec validate ui-presentation --strict` | pass | local |
| `8.C2` fail-closed gate from dispatch | pass; `8.C2` remains open and single unchecked row | local |

This table records the latest validation summary. The final closeout and Hermes audit path remain the definitive run-level receipt.

## Grill Burndown

本轮 burndown 账本：`docs/grill-tournament/uiue-r0-r2-grill-burndown-2026-06-27.md`。

Resolved-with-proof is intentionally narrow. Most R1/R2b items remain `partially_resolved`, `deferred`, or `still_open` until simulator UI evidence, fresh crops, L3 punchlist, or pre-mortem decisions exist.

## Bug Iceberg Teardown

### 结论

是冰山一角，但范围是 checker/test/docs/dirty-provenance 自身的 proof 健康，不是产品 UI 链路已坏：新增 checker、新增 unit test、配套 receipt 和主工作树 full-test failure 都暴露了“验证工具、状态叙述、dirty ownership 必须先自证一致”的治理风险。

### 可见 bug

- 用户看到什么：实现过程中发现 checker JSON decode error 分支引用了未导入异常名；首次 `swift test --filter StateCellInteractionPolicyTests` 失败在 `DemoVehicleStateStore` MainActor 隔离。
- 自审又发现什么：R2b checker spec 顶部仍保留旧的 no-checker 叙述，和已落地 checker/fixture receipt 不一致。
- Codex 只读审计又发现什么：R2b checker 对缺失 required target frame 没有独立 fail-closed；C34 `resolved_with_proof` 只证明 store/summary unit path，未证明完整 UI bridge path。
- 验证又暴露什么：主工作树全量 `swift test` 失败在 `U44LiquidGlassHardeningInventoryTests.testSourceFilesStillContainOnlyInventoryGlassSurfaces`，根因是未接管 dirty `App/ContextCapsule.swift` 把 `.glassEffect()` 改成 `.glassEffect(.regular, in: Capsule())`，和测试硬编码不匹配。
- 系统本应怎样：checker 应在无效 JSON 时稳定 fail-closed；unit proof 应尊重 store 的 MainActor 边界。
- 当前修复声称解决什么：修正 checker 异常类型为 `json.JSONDecodeError`；给新增测试类加 `@MainActor`；更新 R2b spec 顶部状态，避免 stale receipt；新增 clean-baseline worktree full-test proof 以隔离本轮 owned Swift 与未接管 App dirty。

### 证据链

| Evidence | Location | What it proves |
|---|---|---|
| checker fix | `Tools/checks/check-uiue-layout-spacing.py` | JSON parse failure path 不再依赖未定义异常名。 |
| targeted test first failure | final closeout validation log | 新测试最初违反 MainActor，不能把初跑失败藏掉。 |
| targeted test rerun | `swift test --filter StateCellInteractionPolicyTests` | MainActor 修复后 R1 unit proof 通过。 |
| stale spec fix | `docs/grill-tournament/uiue-r2b-layout-spacing-checker-spec-2026-06-27.md` | R2b spec 状态与实际 checker foundation 对齐。 |
| missing target fix | `Tools/checks/check-uiue-layout-spacing.py`; `layout-spacing-missing-target-receipt.json` | 缺 required target frame 时 receipt `FAIL` 且命令 exit 1。 |
| C34 downgrade | `docs/grill-tournament/uiue-r0-r2-grill-burndown-2026-06-27.md` | C34 从 `resolved_with_proof` 降为 `partially_resolved`，避免 UI bridge proof 过报。 |
| main worktree full-test failure | `swift test` | 未接管 App dirty 触发 U44 glass inventory assertion，主工作树不能声明 full green。 |
| isolated clean-baseline full-test | detached worktree at base `4a4aabb` + owned Swift files only | 本轮 Core/test owned Swift 不破坏 full suite：315 tests / 0 failures / 3 skipped。 |

### 链路 teardown

Expected chain: checker/test implementation -> fail-closed validation -> receipt proof -> burndown -> spec/status readback -> dirty provenance split。
Observed break: checker error branch、新增 test actor boundary、R2b spec 顶部状态、主工作树 full-test failure provenance 未在写入前完全自证。
Hidden seams: 新 gate 若没有 `--help` + fixture + targeted compile + stale-status grep + clean-baseline comparison，容易成为“看似有门，实际门自身脆弱”的 fake safety。

### 冰山扩散

| Direction | Risk | Evidence | Severity |
|---|---|---|---|
| same checker family | 证据 checker 自身未覆盖 malformed input、threshold-missing path 或 target-missing path | 本轮 checker bug + Codex audit finding | P1 |
| same proof/status pattern | checker `PASS` 可能被误写成 L3 或 8.C2 close | R2b spec non-claims | P1 |
| same stale-readback family | spec/receipt 顶部状态可能落后于实现 | R2b spec stale sentence | P1 |
| same dirty-provenance family | 主工作树 full-test 失败可能被误归因给本轮 owned Swift 或被直接忽略 | U44 failure on unowned App dirty | P1 |
| same test architecture | 新 Core tests 调 main-actor store 需显式隔离 | first targeted test failure | P2 |

### Tiger / Paper-tiger / Elephant

- Tiger: gate 自身不自证会制造 fake green。
- Paper-tiger: 当前缺陷已在本轮 targeted validation 前被修复，且未进入 commit。
- Elephant: 派单要求 cross-vendor audit 是合理的；新增 checker/burndown 必须进 Hermes 输入，防止 controller 自签。

### Immediate / Class-level / Governance fixes

- Immediate: 修 checker exception、修 MainActor test、修 R2b stale spec，补 clean-baseline full-test comparison，重跑 targeted gate。
- Class-level: 保留 checker `--help` + fixture receipt + stale-status grep + dirty provenance comparison 作为最小自证；white-edge threshold 不签 PASS。
- Governance: burndown 只允许带 proof path + proof class + validation command 的项写 `resolved_with_proof`。

## Residual Risks

- R1 没有声明完整 10 族 x 全 value type x 全 gesture UI proof。
- R2b checker 还没有真实 simulator UI tree/screenshot/crops；fixture proof 只算 `local`。
- Capsule asset、VPA 四态、halo/theme proof、L3 punchlist 均仍 open。
- 主工作树 `swift test` 仍受未接管 dirty `App/ContextCapsule.swift` 影响而失败；本轮只证明 owned Swift 在 clean-baseline worktree 全量通过。
- `8.C2` 仍 open。
