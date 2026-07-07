# B5 就绪报告：macOS demo convergence lane

status: `READINESS_REPORT_ONLY`（零 commit 权，不写脚本/不编码，只写本档）
by: hermes glm-5.2 (pane %31, B5 就绪核查)
spec: 执行单 B5 就绪报告
cwd: `/Users/wanglei/workspace/MAformac`
head: `8554aa3b7016b87415acf453ff6e42cf3bc6f015`
branch: `opt/streamline-macos-20260707`（精简批 B0-B4c 已执行，10 commit）
basis: live probe 2026-07-07 16:29 + codex 草稿计划 `docs/superpowers/plans/2026-07-07-macos-demo-convergence-baseline.md`

---

## ① Task1 truth probe 复核（亲跑）

### Step 1.1 repo truth（live 亲跑）

| 项 | codex 草稿计划值 | live 值 | stale? |
|---|---|---|---|
| cwd | `/Users/wanglei/workspace/MAformac` | `/Users/wanglei/workspace/MAformac` | ✅ 一致 |
| branch | `codex/rebuild-c6-doc-absorption-20260624` | `opt/streamline-macos-20260707` | 🔴 stale（精简批已切分支） |
| HEAD | `f2ec2497dbf2b6f751fa6f377105b6646371954c` | `8554aa3b7016b87415acf453ff6e42cf3bc6f015` | 🔴 stale（落后 10 commit） |
| dirty | `M docs/CURRENT.md` | `?? docs/superpowers/plans/2026-07-07-macos-demo-convergence-baseline.md` | 🔴 stale（dirty 项完全不同——CURRENT.md 已 commit，plan 仍 untracked） |

证据：`git log --oneline f2ec2497..HEAD` = 10 commit（dc86b1c8 B0 no-touch 门 → 8554aa3b B4a T5 banner 清单 refresh）。

### Step 1.2 Mac target/scheme truth（live 亲跑）

**Targets（xcodebuild -list 亲跑）**：
- `MAformacMac` ✅
- `MAformacIOS` ✅
- `MAformacIOSUITests` ✅
- `MAformacCoreTests` ✅
- Schemes: `MAformacIOS` / `MAformacMac`（均 xcodebuild 可见）

**Shared scheme 文件现状（关键发现）**：
- `MAformac.xcodeproj/xcshareddata/xcschemes/` 只有 **`MAformacIOS.xcscheme`**（4789 bytes，Jul 7 12:14）
- **`MAformacMac.xcscheme` 不存在**——`xcodebuild -list` 能列出 `MAformacMac` scheme 是因为 Xcode inferred/generated it，但 **repo-owned shared scheme 文件缺失**
- Task2.0 要创建 `MAformacMac.xcscheme`——**这是 Task2 的第一个动作，且必须 commander 批**（改 pbxproj/xcshareddata = 动 Xcode 工程，synthesis §1 结论 2 iOS 冻结边界不含 Mac scheme，但创建新 shared scheme 文件是工程改动）

证据：`ls -la MAformac.xcodeproj/xcshareddata/xcschemes/` = 只有 MAformacIOS.xcscheme；`xcodebuild -list` = Schemes 列 MAformacMac（inferred）。

### Step 1.3 Mac layout contract truth（live 亲跑）

`swift test --filter U14MacLayoutContractTests` = **5 tests passed, 0 failures** in 0.009s。

**M.36 假绿防范**：输出尾段有 `Test run with 0 tests in 0 suites passed`——这是 Swift Testing runner 空段（非 XCTest），不是假绿。XCTest 段 `Executed 5 tests, with 0 failures` 才是真的。grep XCTest 段确认 5>0。

证据：`Tests/MAformacCoreTests/U14MacLayoutContractTests.swift` 存在；`swift test --filter U14MacLayoutContractTests` stdout（2026-07-07 16:29:20 亲跑）。

### ContentView usesMacSplit + launch args（live 亲跑）

- `usesMacSplit(size:)` 在 `App/ContentView.swift` 5 处调用（:84/:142/:197/:254/:703）——Mac 布局契约已实装
- `App/MAformacApp.swift` 有 7+ launch args（`-showGallery`/`-showDemoControlPanel`/`-showDemoAllStates`/`-spikeControls`/`-spikeExpanded`/`-spikeSequencer`/`-showAmbientBurst`/`-forceReduceMotion`）——Mac demo shell 启动入口已存在

**Task1 verdict：GO**（probe 全绿，唯一 stale 是 HEAD/branch/dirty 三个快照值，不影响 Mac target/scheme/test 真态）。

---

## ② Task2-5 逐 Task 就绪清单

### Task2: Minimal macOS Demo Shell Evidence

**要创建的文件**：
| 文件 | 状态 | 工作量 | 风险 | 依赖 |
|---|---|---|---|---|
| `MAformac.xcodeproj/xcshareddata/xcschemes/MAformacMac.xcscheme` | 不存在，需创建 | 低（codex 计划给了完整 XML 模板 :128-242） | 中（动 Xcode 工程文件，BlueprintIdentifier 必须与 pbxproj 一致） | commander 批（动 xcshareddata） |
| `Tools/checks/capture-macos-demo-evidence.sh` | 不存在 | 中（capture 脚本，要 xcodebuild build + run + screenshot） | 低（新增脚本不改现有代码） | Task2.0 shared scheme 先落 |
| `Tools/checks/check-macos-demo-evidence.py` | 不存在 | 中（validator，fail-closed 字段校验） | 低（新增脚本） | evidence.json schema 定义 |
| `docs/research/2026-07-07-macos-demo-convergence/evidence.json` | 目录不存在 | 低（capture 脚本生成） | 低 | capture 脚本先跑 |
| `docs/research/2026-07-07-macos-demo-convergence/README.md` | 不存在 | 低（human-readable index + non-claim ledger） | 低 | evidence 包先有 |

**输入齐吗**：
- ✅ Mac target `MAformacMac` 存在
- ✅ `usesMacSplit` 已实装（ContentView 5 处）
- ✅ launch args 已存在（MAformacApp 7+ args）
- ✅ U14 layout contract 5/5 PASS
- ⚠️ shared scheme 文件缺失（Task2.0 创建）
- ⚠️ codex 计划 XML 模板的 `BlueprintIdentifier`（A50000000000000000000001）需核实与 pbxproj 一致——live pbxproj 的 MAformacMac BlueprintIdentifier 是什么？`grep "MAformacMac" MAformac.xcodeproj/project.pbxproj` 显示 `A10000000000000000000001`（file ref），但 scheme 要的是 **target** BlueprintIdentifier，需 `grep "MAformacMac.*isa = PBXNativeTarget" -A2 pbxproj` 确认

**风险**：
- Task2.0 创建 shared scheme 文件 = 动 Xcode 工程（xcshareddata）——synthesis §1 结论 2 iOS 冻结边界不含 Mac scheme，但创建新文件仍需 commander 批
- capture 脚本要 xcodebuild build + run + screenshot——`xcodebuild -scheme MAformacMac -destination 'platform=macOS'` build 可能慢（首次 build 全量编译）
- screenshot 需要 `screencapture` 命令或 Xcode UI 自动化——脚本化 screenshot 可能不稳

**依赖**：Task2.0（shared scheme）→ Task2.1（validator）→ Task2.2（capture 脚本）→ evidence.json → README.md

### Task3: OpenSpec Reconciliation Without Claim Upgrade

**要修改的文件**：
| 文件 | 动作 | 工作量 | 风险 | 依赖 |
|---|---|---|---|---|
| `openspec/changes/ui-presentation/tasks.md` | 在 8.C2 下加 dated note | 低（加注释行） | 低（不改 8.C2 状态，只加 note） | Task2 evidence 包先有 |
| `openspec/changes/define-runtime-presentation-bridge/tasks.md` | 在 Gate4 下加 dated note | 低（加注释行） | 低 | bridge validate 绿 |

**输入齐吗**：
- ✅ `ui-presentation` change 存在（openspec/changes/ui-presentation/）
- ✅ `define-runtime-presentation-bridge` change 存在
- ⚠️ codex 计划的 note 措辞（:576）需与当前 8.C2 / Gate4 状态对账——live 8.C2 当前是 open（synthesis §1 结论 7 `:16`）

**风险**：低。只加 dated note，不改 task 状态/不关 8.C2。验收 = `openspec validate ui-presentation --strict` + `openspec validate define-runtime-presentation-bridge --strict` 绿。

**依赖**：Task2 evidence 包先有（note 引用 `docs/research/2026-07-07-macos-demo-convergence/`）。

### Task4: Deliverable Demo Package Baseline

**要创建的文件**：
| 文件 | 动作 | 工作量 | 风险 | 依赖 |
|---|---|---|---|---|
| launch checklist | 新建 | 低 | 低 | Task2 evidence 包 |
| non-claim ledger | 新建 | 低 | 低 | Task2 evidence 包 |
| rollback notes | 新建 | 低 | 低 | Task2 evidence 包 |

**输入齐吗**：
- ✅ codex 计划给了模板（:624-660ish）
- ⚠️ non-claim ledger 的 forbidden claims 列表需与 bridge proof-cap 一致（`openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md:218-223`）

**风险**：低。纯 docs 产出。

**依赖**：Task2 evidence 包先有。

### Task5: Independent Read-Only Audit Gate

**要创建的文件**：
| 文件 | 动作 | 工作量 | 风险 | 依赖 |
|---|---|---|---|---|
| `docs/research/2026-07-07-macos-demo-convergence/read-only-audit.md` | 仅 commander 请求时创建 | 低 | 低 | Task2-4 全完成 |

**输入齐吗**：
- ✅ codex 计划给了 audit prompt（:745-768ish）
- ⚠️ audit subagent 需独立 context（read-only，fresh session）

**风险**：低。read-only audit 不改文件。

**依赖**：Task2-4 全完成。

---

## ③ codex 草稿计划 stale 项修正清单

| # | stale 项 | 草稿计划值 | live 值 | 修正 |
|---|---|---|---|---|
| S1 | HEAD snapshot | `f2ec2497`（:28） | `8554aa3b` | 落后 10 commit（B0-B4c 已执行） |
| S2 | branch | `codex/rebuild-c6-doc-absorption-20260624`（:27） | `opt/streamline-macos-20260707` | 精简批已切分支 |
| S3 | dirty | `M docs/CURRENT.md`（:29） | `?? docs/superpowers/plans/2026-07-07-macos-demo-convergence-baseline.md`（untracked plan） | CURRENT.md 已 commit，plan 仍 untracked |
| S4 | B0-B4c 状态 | 草稿计划写时未执行 | 已执行（10 commit dc86b1c8→8554aa3b） | 草稿计划的 Task1 truth probe 要 rebase 到当前 HEAD |
| S5 | Tools/checks/ 现有脚本 | 草稿计划没提现有脚本 | 已有 14 个 check 脚本（含 check-streamline-notouch.sh / check-u14-mac-layout-contract.sh） | Task2 capture/validator 脚本命名应与现有命名一致（capture-*-evidence.sh / check-*-evidence.py 模式） |
| S6 | docs/research/2026-07-07-macos-demo-convergence/ | 草稿计划假设创建 | 不存在 | Task2 仍需从头创建 |
| S7 | MAformacMac.xcscheme | 草稿计划 Step2.0 说"if missing create" | 确实 missing（xcshareddata 只有 IOS） | Task2.0 仍需创建 |
| S8 | BlueprintIdentifier | 草稿计划 XML 用 A5000...01 / D5000...01 | live pbxproj file ref 是 A1000...01（file ref 非 target） | **必须核实 target BlueprintIdentifier**——草稿计划的 A5000...01 可能与 pbxproj 不匹配，需 `grep "MAformacMac.*PBXNativeTarget" -A3 pbxproj` 确认 |

**关键 stale**：S8（BlueprintIdentifier）——如果草稿计划 XML 的 `A50000000000000000000001` 与 pbxproj 的 MAformacMac target ID 不匹配，创建的 scheme 文件无效（xcodebuild 找不到 target）。这是 Task2.0 的硬前置。

---

## ④ ⭐建议的执行时机与分支

### 执行时机

**现在可以启动 Task2**（Task1 probe 已绿），但有两个前置：

1. **S8 BlueprintIdentifier 核实**（硬前置）：Task2.0 创建 shared scheme 前，必须 `grep "MAformacMac.*PBXNativeTarget" -A3 MAformac.xcodeproj/project.pbxproj` 确认 target 的 BlueprintIdentifier，与草稿计划 XML 的 `A50000000000000000000001` 对账。如果不匹配，改 XML 模板的 ID。

2. **commander 批 shared scheme 创建**（权限前置）：创建 `MAformacMac.xcscheme` = 动 Xcode 工程（xcshareddata）。虽然 synthesis §1 结论 2 iOS 冻结边界不含 Mac scheme，但创建新工程文件仍需 commander 批。

### 分支策略

⭐建议：**独立 lane `opt/macos-demo-package-*`**（从当前 `opt/streamline-macos-20260707` HEAD `8554aa3b` 切）。

理由：
- synthesis §2 B5 行（`:30`）已说"独立分支独立 commit 序"
- 精简批 B0-B4c 已在 `opt/streamline-macos-20260707` 上，Mac demo package 是独立 proof domain（synthesis §1 结论 6 每 commit 一 proof domain）
- 从当前 HEAD 切（不从 origin/main 切）——因为精简批的 B0 no-touch 门 / B2 verify-register / B3a openspec change 等都是 Mac demo package 的前置依赖（Task2 capture 脚本可能引用 verify-register / check-streamline-notouch.sh）

**正式编码另立单**：B5 就绪报告是预研（本档），正式编码（Task2-5 实现）需 commander 另立执行单。本档只记录就绪状态 + stale 修正 + 建议，不编码。

### Task 执行序建议

```
B5-pre（本档：就绪核查）
  ↓
Task2.0（shared scheme，commander 批 + BlueprintIdentifier 核实）
  ↓
Task2.1-2.2（validator + capture 脚本，新增文件不改现有代码）
  ↓
Task2.3-2.4（evidence.json + README.md，capture 脚本生成）
  ↓
Task3（OpenSpec notes，只加 dated note）
  ↓
Task4（launch checklist + non-claim ledger + rollback notes）
  ↓
Task5（read-only audit subagent，commander 请求时）
```

每 Task 一 commit 一 proof domain。Task2.0 单独 commit（shared scheme = Xcode 工程改动）。Task2.1-2.2 可一个 commit（新增脚本）。Task2.3-2.4 一个 commit（evidence 包）。Task3/4/5 各一个 commit。

---

## 附：live truth snapshot（2026-07-07 16:29 亲核）

- HEAD: `8554aa3b` / branch: `opt/streamline-macos-20260707` / dirty: 1 untracked (codex plan)
- 精简批 B0-B4c 已执行（10 commit: dc86b1c8→8554aa3b）
- xcodebuild -list: 4 targets (MAformacMac/IOS/IOSUITests/CoreTests) + 2 schemes (MAformacIOS/MAformacMac)
- xcshareddata/xcschemes/: 只有 MAformacIOS.xcscheme（MAformacMac.xcscheme 缺失）
- U14MacLayoutContractTests: 5/5 PASS (0.009s)（XCTest 段，M.36 防范已确认）
- usesMacSplit: ContentView 5 处调用
- launch args: MAformacApp 7+ args
- Tools/checks/: 14 个现有脚本（无 capture-macos-demo-evidence.sh / check-macos-demo-evidence.py）
- docs/research/2026-07-07-macos-demo-convergence/: 不存在
- codex 草稿计划: HEAD f2ec2497（stale，落后 10 commit）/ dirty M docs/CURRENT.md（stale）
