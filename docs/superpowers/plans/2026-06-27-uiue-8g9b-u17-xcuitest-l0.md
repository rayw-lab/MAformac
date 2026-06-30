# UIUE 8.G9b U17 XCUITest L0 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.
>
> **Execution receipt:** implemented by commit `780447c test(uiue): close 8g9b xcuitest l0 harness`. This file is retained as provenance for the scoped U17 plan; checklist boxes below record the original operator plan, not the current live task state. Runtime receipt: `docs/research/2026-06-27-uiue-8g9b-u17-l0/README.md`.

**Goal:** 不降级闭合 UIUE `8.G9b / U17`：冻结黄金路径入口契约，新增真实 iOS UI test target，跑最小黄金路径 XCUITest，并产出 on-screen `simctl io screenshot` L0 证据包。

**Architecture:** 入口契约放在 Core 层，用稳定字符串描述 `golden_path_id -> snapshot/theme/proof_intent`，App DEBUG 启动参数消费该契约进入正常主舞台，不走 force-state 满屏替代。XCUITest 只做最小 UI smoke 和 UI tree evidence，L0 截图由独立 harness 用 `simctl io screenshot` 采集，并由 checker 校验字段和 PNG 文件；SwiftPM/unit、XCUITest、L0 各自保留 proof class，互不冒充。

**Tech Stack:** Swift 6.0, SwiftPM unit tests, Xcode project `MAformac.xcodeproj`, scheme `MAformacIOS`, XCTest/XCUITest, iOS Simulator default `iPhone 17 Pro Max`（允许 `iPhone 17 Pro` 回退）, `xcrun simctl`, shell + Python stdlib evidence checker, OpenSpec.

## Global Constraints

- 默认中文文档、计划、派单、verdict；代码标识符、路径、命令、API 字段保留英文。
- 工作目录固定为 `/Users/wanglei/workspace/MAformac-uiue`，分支应为 `uiue/phase4-default-scope-presentation`。
- 不使用 `git add .`；只 stage 本计划列出的 owned files。
- 不碰既有 untracked visual evidence dirs，尤其 `docs/research/2026-06-25-a2-execution/...`。
- 不接真 NLU / ASR / TTS / LoRA / backend；只走 DEBUG mock-frontstage 和 simulator UI proof。
- 不碰投屏 / AirPlay / 1080p 外屏验收。
- 不声明 `mobile`、`true_device`、L3、V-PASS、A-2 complete。
- `8.C2` 仍保持 open；G9b 完成只证明 U17 simulator L0 smoke。
- L0 截图必须来自 on-screen `xcrun simctl io booted screenshot`；SwiftUI Preview、`ImageRenderer`、XCUITest attachment、静态 snapshot 都不能算 L0。
- G9b 必须包含 UI test target + 最小 XCUITest + on-screen L0 截图包，不能用 unit test 或 manifest 绿替代。
- 执行前必须仔细参考本仓 `Tools/skills`、`Tools/agent-platform-plugin-refs`、Codex 官方 `build-ios-apps` skills、Apple 官方 XCTest/Xcode/Simulator 文档；不能只靠本计划硬写 pbxproj。
- 交付后必须安排独立 subagent Codex 做 read-only 审计，controller 修复审计 findings 后才能 commit。
- 若遇到 HIGH severity pre-mortem 风险，按 `blocked at Stage N after attempts A/B/C; only missing X` 回报并等磊哥拍。

---

## 当前真态

- `xcodebuild -list -project MAformac.xcodeproj` 当前只列出 targets `MAformacMac` / `MAformacIOS`，schemes `MAformacIOS` / `MAformacMac`；没有 UI test target。
- `App/MAformacApp.swift` DEBUG 主舞台消费 `-mockSnapshot` 和 `-mockTheme`；`-mockSnapshot` 真实存在。
- `App/DebugGallery.swift` 的 `-forceVisualState` / `-forceTheme` 服务 force-state 满屏脚手架，不是正常黄金路径主舞台。
- `App/ContentView.swift` 已有稳定 accessibility identifiers：`context-band`、`mic-dock`、`demo-orb`、`dialogue-stream`、`vehicle-cards`、`vehicle-cards-mac-panorama`、`vehicle-card-\(display.accessibilityKey)`。
- `openspec/changes/ui-presentation/specs/ui-presentation/spec.md` 已锁 L0 字段：`device`、`launchArg`、`theme`、`ui_tree_evidence`、`screenshot_path`、`proof_class`。
- `openspec/changes/ui-presentation/tasks.md` 当前 `8.G9a` 已完成，`8.G9b（U17）` open，父级 `8.G9` open。
- `docs/grill-tournament/uiue-8g9-and-liquid-glass-hardening-grill-decisions.md` U39 已拍：U17 拆 `U17a` 入口契约 + `U17b` 最小 XCUITest/L0，但 U17b 不允许无限 deferred。
- `Tools/agent-platform-plugin-refs/README.md` 已说明本 worktree 的 iOS 默认：project `MAformac.xcodeproj`、scheme `MAformacIOS`、dedicated simulator `iPhone 17 Pro Max`，且该目录有四个 Codex 官方 Apple 生态软链接：`build-ios-apps-plugin`、`build-ios-apps-skills`、`build-macos-apps-plugin`、`build-macos-apps-skills`。
- `Tools/skills/INDEX.md` 已列项目内沉淀 skills，G9b 相关优先读 `ios-simulator-skill`、`ios-debugger-agent`、`ios-ettrace-performance`；不要绕过本仓工具经验。

## Pre-Mortem

### scout：本机历史

- 本项目现有 `-mockSnapshot` / `-mockTheme` 是正常主舞台入口；`-forceVisualState` 是 5-gate force-state 入口。
- 本项目已多次因为 local/unit proof 被写成 visual pass 而重开 grill；G9b 必须把 manifest、XCUITest、L0 三层分开写 receipt。
- Xcode project 使用 `PBXFileSystemSynchronizedRootGroup`，新增 target 应跟随现有 project 风格，不引入 XcodeGen。
- 本仓已有 `Tools/agent-platform-plugin-refs/README.md`、`Tools/skills/INDEX.md` 和 `Tools/skills/ios-*`；这些是已有经验教训的入口，不读就容易重复踩坑。

### oracle：外部坑点

- Apple 的 XCUIAutomation 文档把 `XCUIApplication` 定位为启动、监控、终止被测 app 的代理；G9b 用它做 UI smoke，不用它替代 on-screen L0。
- Apple Simulator 资料说明 `simctl` 可从命令行控制 Simulator；G9b 截图必须使用 `xcrun simctl io booted screenshot`。
- WWDC UI automation 资料强调 UI 自动化依赖可访问性与稳定测试报告；G9b 需要稳定 `.accessibilityIdentifier` 和 UI tree evidence。
- Apple `xcodebuild` 文档说明 CLI 可对 project/workspace 执行 build/query/analyze/test/archive；G9b 必须用 `xcodebuild test` 证明真实 UI test target。
- Apple `launchArguments` 文档说明 `XCUIApplication.launchArguments` 可改变 app launch 参数；G9b 以此注入 `-goldenPathID`。
- Apple `accessibilityIdentifier` 文档说明该标识用于 UI automation 脚本唯一识别元素；G9b 必须依赖稳定 identifier，不用视觉坐标。

Reference links:
- https://developer.apple.com/documentation/XCUIAutomation/XCUIApplication
- https://developer.apple.com/documentation/xcuiautomation/xcuiapplication/launcharguments
- https://developer.apple.com/documentation/xcode/running-tests-and-interpreting-results
- https://developer.apple.com/library/archive/technotes/tn2339/_index.html
- https://developer.apple.com/library/archive/documentation/IDEs/Conceptual/iOS_Simulator_Guide/InteractingwiththeiOSSimulator/InteractingwiththeiOSSimulator.html
- https://developer.apple.com/documentation/uikit/uiaccessibilityidentification/accessibilityidentifier

### tiger / paper-tiger / elephant

- tiger：只做 `golden_path_manifest` 和 unit matrix 后误勾 `8.G9b`。验证清单：必须存在 `MAformacIOSUITests` target、`xcodebuild test` 通过、L0 evidence JSON 指向 on-screen screenshot。
- tiger：`-forceVisualState` 满屏脚手架被误当 golden path。验证清单：XCUITest 和 L0 harness 使用 `-goldenPathID uiue_g9b_ac_success_deep_space`，由 DEBUG 主舞台解析到 `-mockSnapshot cooling` + `-mockTheme deepSpace`。
- tiger：XCUITest attachment 被误当 L0 截图。验证清单：`l0-evidence.json.screenshot_path` 必须是 `simctl io booted screenshot` 输出，checker 校验 PNG magic。
- tiger：pbxproj 手改导致 scheme/build 破坏。验证清单：`xcodebuild -list` 必须显示 `MAformacIOSUITests` target，`xcodebuild test -scheme MAformacIOS` 必须通过。
- paper-tiger：新增 `golden_path_id` 不是接真 golden-run/backend；它只是 DEBUG 入口契约，仍使用 mock snapshot。
- paper-tiger：新增 shared scheme 不等于改产品发布配置；它只让 CLI 可复跑 UI tests。
- elephant：G9b 容易被继续延期，因为“UI test target 太麻烦”；本计划把 target、test、harness、docs 做成一个最小闭环，失败就给具体 blocker，不留泛化 deferred。

## File Structure

- Create `Core/Presentation/U17GoldenPathManifest.swift`：U17 黄金路径入口契约，Core 可单测，App DEBUG 可消费。
- Create `Tests/MAformacCoreTests/U17GoldenPathManifestTests.swift`：锁 `golden_path_id`、snapshot/theme、launch args、proof boundary。
- Modify `App/MAformacApp.swift`：DEBUG 下让 `-goldenPathID` 覆盖 `mockSnapshot` / `mockTheme`，仍进入正常 `ContentView` 主舞台。
- Modify `MAformac.xcodeproj/project.pbxproj`：新增 `MAformacIOSUITests` UI test target，依赖 `MAformacIOS`。
- Create `MAformac.xcodeproj/xcshareddata/xcschemes/MAformacIOS.xcscheme`：让 `xcodebuild test -scheme MAformacIOS` 包含 UI test target。
- Create `MAformacIOSUITests/U17GoldenPathUITests.swift`：最小 XCUITest，写 UI tree evidence。
- Create `Tools/checks/capture-u17-l0-evidence.sh`：build/test/install/launch/simctl screenshot/manifest 生成 harness。
- Create `Tools/checks/check-u17-l0-evidence.py`：校验 L0 evidence JSON、UI tree 文件、PNG screenshot。
- Create `docs/research/2026-06-27-uiue-8g9b-u17-l0/README.md`：G9b receipt 与复跑命令。
- Modify `openspec/changes/ui-presentation/tasks.md`：仅在证据齐全后勾选 `8.G9b` 和父级 `8.G9`；`8.C2` 不勾。
- Modify `docs/grill-checklist/uiue-a2-grill-coverage-index.md`：追加 G9b/U17 simulator L0 smoke receipt 指针，保持 `8.C2` residual open。

## Task 0: 真态复核与 quick pre-mortem gate

**Files:**
- Read: `/Users/wanglei/workspace/MAformac-uiue/docs/grill-tournament/uiue-8g9-and-liquid-glass-hardening-grill-decisions.md`
- Read: `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/tasks.md`
- Read: `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/specs/ui-presentation/spec.md`
- Read: `/Users/wanglei/workspace/MAformac-uiue/App/MAformacApp.swift`
- Read: `/Users/wanglei/workspace/MAformac-uiue/App/DebugGallery.swift`
- Read: `/Users/wanglei/workspace/MAformac-uiue/MAformac.xcodeproj/project.pbxproj`
- Read: `/Users/wanglei/workspace/MAformac-uiue/Tools/agent-platform-plugin-refs/README.md`
- Read: `/Users/wanglei/workspace/MAformac-uiue/Tools/skills/INDEX.md`
- Read: `/Users/wanglei/workspace/MAformac-uiue/Tools/skills/ios-simulator-skill/SKILL.md`
- Read: `/Users/wanglei/workspace/MAformac-uiue/Tools/skills/ios-debugger-agent/SKILL.md`
- Read: `/Users/wanglei/workspace/MAformac-uiue/Tools/skills/ios-ettrace-performance/SKILL.md`
- Read: `/Users/wanglei/workspace/MAformac-uiue/Tools/agent-platform-plugin-refs/build-ios-apps-skills/ios-simulator-browser/SKILL.md`
- Read: `/Users/wanglei/workspace/MAformac-uiue/Tools/agent-platform-plugin-refs/build-ios-apps-skills/ios-debugger-agent/SKILL.md`

**Interfaces:**
- Consumes: 当前 repo truth、U39/U45 决策、L0 spec 字段。
- Produces: 可执行前置判断；若 HIGH 风险出现，先停给磊哥拍。

- [ ] **Step 1: 核工作区与 dirty tree**

```bash
cd /Users/wanglei/workspace/MAformac-uiue
git status --short --branch
xcodebuild -list -project MAformac.xcodeproj
```

Expected:
- branch 为 `uiue/phase4-default-scope-presentation`
- `xcodebuild -list` 当前没有 `MAformacIOSUITests`
- 记录既有 dirty/untracked docs/evidence，不 revert，不纳入本任务 commit

- [ ] **Step 2: 读本仓 Tools/skills 与 Codex 官方 iOS 生态软链接**

```bash
cd /Users/wanglei/workspace/MAformac-uiue
sed -n '1,220p' Tools/agent-platform-plugin-refs/README.md
sed -n '1,220p' Tools/skills/INDEX.md
sed -n '1,220p' Tools/skills/ios-simulator-skill/SKILL.md
sed -n '1,220p' Tools/skills/ios-debugger-agent/SKILL.md
sed -n '1,180p' Tools/skills/ios-ettrace-performance/SKILL.md
find Tools/agent-platform-plugin-refs -maxdepth 1 -type l -print -exec ls -l {} \;
sed -n '1,220p' Tools/agent-platform-plugin-refs/build-ios-apps-skills/ios-simulator-browser/SKILL.md
sed -n '1,220p' Tools/agent-platform-plugin-refs/build-ios-apps-skills/ios-debugger-agent/SKILL.md
```

Expected:
- 看到四个官方 Apple 生态软链接：`build-ios-apps-plugin`、`build-ios-apps-skills`、`build-macos-apps-plugin`、`build-macos-apps-skills`
- 确认本 worktree 默认 project/scheme/simulator
- 把与 simulator lifecycle、screenshots、UI automation、logs 相关的可复用脚本/命令写入执行笔记
- 若官方 skill 与本计划冲突，先以 repo truth + Apple 官方文档为准，并在 verdict 写明取舍

- [ ] **Step 3: 联网核 Apple 官方资料和外部 failure modes**

Use Codex web search or browser. Minimum sources:

```text
Apple XCUIApplication
Apple XCUIApplication.launchArguments
Apple xcodebuild running tests
Apple simctl io booted screenshot
Apple accessibilityIdentifier for UI automation
Apple Developer Forums XCUITest launch/simulator failure modes
```

Expected notes:
- `XCUIApplication` 只证明 UI automation，不替代 L0 screenshot
- `launchArguments` 可注入 `-goldenPathID`
- `xcodebuild test -only-testing` 是最小 test gate
- `simctl io booted screenshot` 是 L0 screenshot source
- forum failure modes 只作为风险输入，不作为产品事实

- [ ] **Step 4: 核 launch args 真态**

```bash
cd /Users/wanglei/workspace/MAformac-uiue
rg -n "mockSnapshot|mockTheme|forceVisualState|forceTheme|goldenPathID|accessibilityIdentifier" App Core Tests
```

Expected:
- 看到 `-mockSnapshot` / `-mockTheme` 在 `App/MAformacApp.swift`
- 看到 `-forceVisualState` / `-forceTheme` 在 DEBUG force-state 脚手架
- 若已有 `-goldenPathID`，先读实现再决定复用或调整

- [ ] **Step 5: 跑 quick pre-mortem**

在执行日志或 commit receipt 中记录：

```text
quick pre-mortem:
- 最大风险: pbxproj 手改破 scheme / XCUITest 通过但 L0 证据不合规 / force-state 冒充 golden path
- 外部依赖: Xcode UI test target、iPhone 17 Pro Max simulator（iPhone 17 Pro 可回退）、simctl screenshot
- 回滚可行: 单 commit revert；证据目录单独新增；不碰旧 visual evidence dirs
- 边界 case: simulator 名称不存在、UI tree identifier 不可见、xcodebuild test 未继承 evidence env
- 需求清晰度: G9b 只闭 U17，不关 8.C2/L3/V-PASS
- 工具复用: 已读 Tools/skills + Codex build-ios-apps symlink + Apple 官方资料，采用/不采用原因已记录
```

- [ ] **Step 6: HIGH stop gate**

若出现以下任一项，停止实现并回报：

```text
blocked at Stage 0 after attempts git-status/xcodebuild-list/rg-launch-args; only missing a valid target repo or MAformacIOS scheme
blocked at Stage 0 after attempts simctl-list/iPhone-17-Pro/iPhone-17-Pro-Max; only missing required simulator device
```

## Task 1: U17a 黄金路径 manifest + unit tests

**Files:**
- Create: `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/U17GoldenPathManifest.swift`
- Create: `/Users/wanglei/workspace/MAformac-uiue/Tests/MAformacCoreTests/U17GoldenPathManifestTests.swift`

**Interfaces:**
- Consumes: `DemoVisualState` from `Core/State/DemoVehicleStateStore.swift`
- Produces:
  - `U17GoldenPathID.acSuccessDeepSpace`
  - `U17GoldenPathManifest.Entry`
  - `U17GoldenPathManifest.entry(id:)`
  - `U17GoldenPathManifest.launchArguments(for:)`
  - stable CLI args for Task 2/3/4

- [ ] **Step 1: Write the failing unit tests**

Create `/Users/wanglei/workspace/MAformac-uiue/Tests/MAformacCoreTests/U17GoldenPathManifestTests.swift`:

```swift
import XCTest
@testable import MAformacCore

final class U17GoldenPathManifestTests: XCTestCase {
    func testManifestExposesExactlyOneMinimumGoldenPath() {
        XCTAssertEqual(U17GoldenPathID.allCases.map(\.rawValue), [
            "uiue_g9b_ac_success_deep_space",
        ])
    }

    func testGoldenPathCarriesNormalMainStageLaunchContract() throws {
        let entry = try XCTUnwrap(U17GoldenPathManifest.entry(id: .acSuccessDeepSpace))

        XCTAssertEqual(entry.id, .acSuccessDeepSpace)
        XCTAssertEqual(entry.snapshotPreset, "cooling")
        XCTAssertEqual(entry.theme, "deepSpace")
        XCTAssertEqual(entry.visualState, .changing)
        XCTAssertEqual(entry.requiredAccessibilityIdentifiers, [
            "context-band",
            "demo-orb",
            "dialogue-stream",
            "mic-dock",
            "vehicle-cards",
        ])
        XCTAssertEqual(entry.proofIntent, "simulator_l0_runtime_truth")
    }

    func testLaunchArgumentsUseGoldenPathIDWithoutForceStateShortcut() throws {
        let args = try XCTUnwrap(U17GoldenPathManifest.launchArguments(for: .acSuccessDeepSpace))

        XCTAssertEqual(args, [
            "-goldenPathID", "uiue_g9b_ac_success_deep_space",
        ])
        XCTAssertFalse(args.contains("-forceVisualState"))
        XCTAssertFalse(args.contains("-forceTheme"))
        XCTAssertFalse(args.contains("-showGallery"))
    }

    func testEntryLookupRejectsUnknownID() {
        XCTAssertNil(U17GoldenPathManifest.entry(rawID: "missing"))
    }
}
```

- [ ] **Step 2: Run tests to verify failure**

```bash
cd /Users/wanglei/workspace/MAformac-uiue
swift test --filter U17GoldenPathManifestTests
```

Expected: FAIL because `U17GoldenPathID` / `U17GoldenPathManifest` are not defined.

- [ ] **Step 3: Implement manifest**

Create `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/U17GoldenPathManifest.swift`:

```swift
import Foundation

public enum U17GoldenPathID: String, CaseIterable, Codable, Equatable, Sendable {
    case acSuccessDeepSpace = "uiue_g9b_ac_success_deep_space"
}

public enum U17GoldenPathManifest {
    public struct Entry: Codable, Equatable, Sendable {
        public let id: U17GoldenPathID
        public let snapshotPreset: String
        public let theme: String
        public let visualState: DemoVisualState
        public let requiredAccessibilityIdentifiers: [String]
        public let proofIntent: String

        public init(
            id: U17GoldenPathID,
            snapshotPreset: String,
            theme: String,
            visualState: DemoVisualState,
            requiredAccessibilityIdentifiers: [String],
            proofIntent: String
        ) {
            self.id = id
            self.snapshotPreset = snapshotPreset
            self.theme = theme
            self.visualState = visualState
            self.requiredAccessibilityIdentifiers = requiredAccessibilityIdentifiers
            self.proofIntent = proofIntent
        }
    }

    public static let entries: [Entry] = [
        Entry(
            id: .acSuccessDeepSpace,
            snapshotPreset: "cooling",
            theme: "deepSpace",
            visualState: .changing,
            requiredAccessibilityIdentifiers: [
                "context-band",
                "demo-orb",
                "dialogue-stream",
                "mic-dock",
                "vehicle-cards",
            ],
            proofIntent: "simulator_l0_runtime_truth"
        ),
    ]

    public static func entry(id: U17GoldenPathID) -> Entry? {
        entries.first { $0.id == id }
    }

    public static func entry(rawID: String) -> Entry? {
        U17GoldenPathID(rawValue: rawID).flatMap(entry(id:))
    }

    public static func launchArguments(for id: U17GoldenPathID) -> [String]? {
        guard let entry = entry(id: id) else { return nil }
        return ["-goldenPathID", entry.id.rawValue]
    }
}
```

- [ ] **Step 4: Verify unit tests pass**

```bash
cd /Users/wanglei/workspace/MAformac-uiue
swift test --filter U17GoldenPathManifestTests
```

Expected: PASS, 4 tests.

- [ ] **Step 5: Do not commit yet**

Hold commit until Task 4 evidence and Task 5 docs complete, because G9b should close as one coherent implementation commit.

## Task 2: DEBUG `-goldenPathID` App entry, no force-state shortcut

**Files:**
- Modify: `/Users/wanglei/workspace/MAformac-uiue/App/MAformacApp.swift`
- Test: `/Users/wanglei/workspace/MAformac-uiue/Tests/MAformacCoreTests/U17GoldenPathManifestTests.swift`

**Interfaces:**
- Consumes: `U17GoldenPathManifest.entry(rawID:)`
- Produces: DEBUG launch arg `-goldenPathID uiue_g9b_ac_success_deep_space` maps to normal `ContentView(initialPreset: .cooling, initialTheme: .deepSpace)`.

- [ ] **Step 1: Add manifest coverage tests**

Append to `/Users/wanglei/workspace/MAformac-uiue/Tests/MAformacCoreTests/U17GoldenPathManifestTests.swift`:

```swift
    func testGoldenPathEntryUsesNormalSnapshotAndThemeNames() throws {
        let entry = try XCTUnwrap(U17GoldenPathManifest.entry(rawID: "uiue_g9b_ac_success_deep_space"))

        XCTAssertEqual(entry.snapshotPreset, "cooling")
        XCTAssertEqual(entry.theme, "deepSpace")
        XCTAssertNotEqual(entry.snapshotPreset, "force-state")
        XCTAssertNotEqual(entry.theme, "forceTheme")
    }
```

- [ ] **Step 2: Run tests**

```bash
cd /Users/wanglei/workspace/MAformac-uiue
swift test --filter U17GoldenPathManifestTests
```

Expected: PASS. This test locks the contract before App consumes it.

- [ ] **Step 3: Modify DEBUG launch argument parsing**

In `/Users/wanglei/workspace/MAformac-uiue/App/MAformacApp.swift`, replace the `mockSnapshot` and `mockTheme` computed properties inside `DebugLaunchArguments` with:

```swift
    static var goldenPath: U17GoldenPathManifest.Entry? {
        value(after: "-goldenPathID").flatMap(U17GoldenPathManifest.entry(rawID:))
    }

    static var mockSnapshot: SnapshotPreset {
        if let preset = goldenPath.flatMap({ SnapshotPreset(rawValue: $0.snapshotPreset) }) {
            return preset
        }
        return value(after: "-mockSnapshot").flatMap(SnapshotPreset.init(rawValue:)) ?? .cooling
    }

    static var mockTheme: PresentationTheme {
        if let theme = goldenPath.flatMap({ PresentationTheme(rawValue: $0.theme) }) {
            return theme
        }
        return value(after: "-mockTheme").flatMap(PresentationTheme.init(rawValue:)) ?? .ivory
    }
```

Do not add a new `rootView` branch for `-goldenPathID`. The golden path must continue into `mainView`, not `ForcedStateScreen`, `DemoVisualStateGallery`, or any spike harness.

- [ ] **Step 4: Build iOS app**

```bash
cd /Users/wanglei/workspace/MAformac-uiue
xcodebuild -project MAformac.xcodeproj \
  -scheme MAformacIOS \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  build
```

Expected: BUILD SUCCEEDED.

- [ ] **Step 5: Guard against force-state shortcut**

```bash
cd /Users/wanglei/workspace/MAformac-uiue
rg -n "goldenPath|goldenPathID|forceVisualState|showGallery" App/MAformacApp.swift App/DebugGallery.swift
```

Expected:
- `goldenPathID` only affects `DebugLaunchArguments.mockSnapshot` / `mockTheme`
- no branch like `if ProcessInfo.processInfo.arguments.contains("-goldenPathID") { ForcedStateScreen(...) }`

## Task 3: Add `MAformacIOSUITests` target and minimum XCUITest

**Files:**
- Modify: `/Users/wanglei/workspace/MAformac-uiue/MAformac.xcodeproj/project.pbxproj`
- Create: `/Users/wanglei/workspace/MAformac-uiue/MAformac.xcodeproj/xcshareddata/xcschemes/MAformacIOS.xcscheme`
- Create: `/Users/wanglei/workspace/MAformac-uiue/MAformacIOSUITests/U17GoldenPathUITests.swift`

**Interfaces:**
- Consumes: `-goldenPathID uiue_g9b_ac_success_deep_space`
- Produces:
  - Xcode target `MAformacIOSUITests`
  - scheme `MAformacIOS` with TestAction including `MAformacIOSUITests`
  - `U17GoldenPathUITests.testGoldenPathLaunchesAndCapturesCoreUI()`

- [ ] **Step 1: Add UI test source first**

Create `/Users/wanglei/workspace/MAformac-uiue/MAformacIOSUITests/U17GoldenPathUITests.swift`:

```swift
import XCTest

final class U17GoldenPathUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testGoldenPathLaunchesAndCapturesCoreUI() throws {
        let app = XCUIApplication()
        app.launchArguments = [
            "-goldenPathID", "uiue_g9b_ac_success_deep_space",
        ]
        app.launch()

        XCTAssertTrue(element("context-band", in: app).waitForExistence(timeout: 10))
        XCTAssertTrue(element("demo-orb", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(element("dialogue-stream", in: app).waitForExistence(timeout: 5))
        XCTAssertTrue(element("mic-dock", in: app).waitForExistence(timeout: 5))

        let phoneGrid = element("vehicle-cards", in: app)
        let macGrid = element("vehicle-cards-mac-panorama", in: app)
        XCTAssertTrue(phoneGrid.waitForExistence(timeout: 5) || macGrid.exists)

        let tree = app.debugDescription
        XCTAssertTrue(tree.contains("context-band"))
        XCTAssertTrue(tree.contains("mic-dock"))
        XCTAssertTrue(tree.contains("vehicle-card-"))

        writeUITreeEvidence(tree)
        let attachment = XCTAttachment(string: tree)
        attachment.name = "u17-golden-path-ui-tree"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }

    private func writeUITreeEvidence(_ tree: String) {
        guard let dir = ProcessInfo.processInfo.environment["U17_L0_EVIDENCE_DIR"], !dir.isEmpty else {
            return
        }

        do {
            let directoryURL = URL(fileURLWithPath: dir, isDirectory: true)
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            let fileURL = directoryURL.appendingPathComponent("u17-ui-tree.txt")
            try tree.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            XCTFail("failed to write U17 UI tree evidence: \(error)")
        }
    }
}
```

- [ ] **Step 2: Add pbxproj target using the project’s file-system-synchronized style**

Modify `/Users/wanglei/workspace/MAformac-uiue/MAformac.xcodeproj/project.pbxproj` using deterministic IDs under `B...`:

```text
B10000000000000000000001 /* MAformacIOSUITests.xctest */ = {isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = MAformacIOSUITests.xctest; sourceTree = BUILT_PRODUCTS_DIR; };

B20000000000000000000001 /* MAformacIOSUITests */ = {
    isa = PBXFileSystemSynchronizedRootGroup;
    path = MAformacIOSUITests;
    sourceTree = "<group>";
};

B30000000000000000000001 /* Frameworks */ = {
    isa = PBXFrameworksBuildPhase;
    buildActionMask = 2147483647;
    files = (
    );
    runOnlyForDeploymentPostprocessing = 0;
};

B70000000000000000000001 /* Sources */ = {
    isa = PBXSourcesBuildPhase;
    buildActionMask = 2147483647;
    files = (
    );
    runOnlyForDeploymentPostprocessing = 0;
};

B80000000000000000000001 /* Resources */ = {
    isa = PBXResourcesBuildPhase;
    buildActionMask = 2147483647;
    files = (
    );
    runOnlyForDeploymentPostprocessing = 0;
};

B61000000000000000000001 /* PBXContainerItemProxy */ = {
    isa = PBXContainerItemProxy;
    containerPortal = A60000000000000000000001 /* Project object */;
    proxyType = 1;
    remoteGlobalIDString = A50000000000000000000002;
    remoteInfo = MAformacIOS;
};

B62000000000000000000001 /* PBXTargetDependency */ = {
    isa = PBXTargetDependency;
    target = A50000000000000000000002 /* MAformacIOS */;
    targetProxy = B61000000000000000000001 /* PBXContainerItemProxy */;
};

B50000000000000000000001 /* MAformacIOSUITests */ = {
    isa = PBXNativeTarget;
    buildConfigurationList = B90000000000000000000001 /* Build configuration list for PBXNativeTarget "MAformacIOSUITests" */;
    buildPhases = (
        B70000000000000000000001 /* Sources */,
        B30000000000000000000001 /* Frameworks */,
        B80000000000000000000001 /* Resources */,
    );
    buildRules = (
    );
    dependencies = (
        B62000000000000000000001 /* PBXTargetDependency */,
    );
    fileSystemSynchronizedGroups = (
        B20000000000000000000001 /* MAformacIOSUITests */,
    );
    name = MAformacIOSUITests;
    packageProductDependencies = (
    );
    productName = MAformacIOSUITests;
    productReference = B10000000000000000000001 /* MAformacIOSUITests.xctest */;
    productType = "com.apple.product-type.bundle.ui-testing";
};
```

Also update existing project sections:

```text
main group children: add B20000000000000000000001 /* MAformacIOSUITests */
Products children: add B10000000000000000000001 /* MAformacIOSUITests.xctest */
PBXProject TargetAttributes: add B50000000000000000000001 = { CreatedOnToolsVersion = 26.5; TestTargetID = A50000000000000000000002; };
PBXProject targets: add B50000000000000000000001 /* MAformacIOSUITests */
```

Add build configurations:

```text
B00000000000000000000001 /* Debug */ = {
    isa = XCBuildConfiguration;
    buildSettings = {
        CODE_SIGNING_ALLOWED = NO;
        CODE_SIGNING_REQUIRED = NO;
        CODE_SIGN_IDENTITY = "";
        CODE_SIGN_STYLE = Manual;
        CURRENT_PROJECT_VERSION = 1;
        GENERATE_INFOPLIST_FILE = YES;
        IPHONEOS_DEPLOYMENT_TARGET = 26.0;
        MARKETING_VERSION = 0.1;
        PRODUCT_BUNDLE_IDENTIFIER = lab.rayw.MAformac.iosUITests;
        PRODUCT_NAME = "$(TARGET_NAME)";
        SDKROOT = iphoneos;
        SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
        SWIFT_VERSION = 6.0;
        TARGETED_DEVICE_FAMILY = "1,2";
        TEST_TARGET_NAME = MAformacIOS;
    };
    name = Debug;
};

B00000000000000000000002 /* Release */ = {
    isa = XCBuildConfiguration;
    buildSettings = {
        CODE_SIGNING_ALLOWED = NO;
        CODE_SIGNING_REQUIRED = NO;
        CODE_SIGN_IDENTITY = "";
        CODE_SIGN_STYLE = Manual;
        CURRENT_PROJECT_VERSION = 1;
        GENERATE_INFOPLIST_FILE = YES;
        IPHONEOS_DEPLOYMENT_TARGET = 26.0;
        MARKETING_VERSION = 0.1;
        PRODUCT_BUNDLE_IDENTIFIER = lab.rayw.MAformac.iosUITests;
        PRODUCT_NAME = "$(TARGET_NAME)";
        SDKROOT = iphoneos;
        SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
        SWIFT_COMPILATION_MODE = wholemodule;
        SWIFT_VERSION = 6.0;
        TARGETED_DEVICE_FAMILY = "1,2";
        TEST_TARGET_NAME = MAformacIOS;
    };
    name = Release;
};

B90000000000000000000001 /* Build configuration list for PBXNativeTarget "MAformacIOSUITests" */ = {
    isa = XCConfigurationList;
    buildConfigurations = (
        B00000000000000000000001 /* Debug */,
        B00000000000000000000002 /* Release */,
    );
    defaultConfigurationIsVisible = 0;
    defaultConfigurationName = Release;
};
```

- [ ] **Step 3: Add shared `MAformacIOS` scheme**

Create directory and file:

```bash
cd /Users/wanglei/workspace/MAformac-uiue
mkdir -p MAformac.xcodeproj/xcshareddata/xcschemes
```

Create `/Users/wanglei/workspace/MAformac-uiue/MAformac.xcodeproj/xcshareddata/xcschemes/MAformacIOS.xcscheme`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "2650"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "A50000000000000000000002"
               BuildableName = "MAformacIOS.app"
               BlueprintName = "MAformacIOS"
               ReferencedContainer = "container:MAformac.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES">
      <Testables>
         <TestableReference
            skipped = "NO">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "B50000000000000000000001"
               BuildableName = "MAformacIOSUITests.xctest"
               BlueprintName = "MAformacIOSUITests"
               ReferencedContainer = "container:MAformac.xcodeproj">
            </BuildableReference>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "A50000000000000000000002"
            BuildableName = "MAformacIOS.app"
            BlueprintName = "MAformacIOS"
            ReferencedContainer = "container:MAformac.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "A50000000000000000000002"
            BuildableName = "MAformacIOS.app"
            BlueprintName = "MAformacIOS"
            ReferencedContainer = "container:MAformac.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
```

- [ ] **Step 4: Verify target is visible**

```bash
cd /Users/wanglei/workspace/MAformac-uiue
xcodebuild -list -project MAformac.xcodeproj
```

Expected:
- Targets include `MAformacIOSUITests`
- Schemes include `MAformacIOS`

- [ ] **Step 5: Run the minimum XCUITest**

```bash
cd /Users/wanglei/workspace/MAformac-uiue
rm -rf /tmp/maformac-u17-ui-tree
mkdir -p /tmp/maformac-u17-ui-tree
U17_L0_EVIDENCE_DIR=/tmp/maformac-u17-ui-tree \
xcodebuild test \
  -project MAformac.xcodeproj \
  -scheme MAformacIOS \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -only-testing:MAformacIOSUITests/U17GoldenPathUITests/testGoldenPathLaunchesAndCapturesCoreUI
test -s /tmp/maformac-u17-ui-tree/u17-ui-tree.txt
```

Expected:
- `xcodebuild test` exits 0
- `/tmp/maformac-u17-ui-tree/u17-ui-tree.txt` exists and contains `context-band`, `mic-dock`, `vehicle-card-`

If Xcode cannot compile the UI test file from `PBXFileSystemSynchronizedRootGroup`, stop after one bounded repair attempt and report:

```text
blocked at Stage 3 after attempts file-system-synchronized-target/explicit-source-membership; only missing a compilable UI test target mapping in pbxproj
```

## Task 4: On-screen `simctl` L0 evidence harness and checker

**Files:**
- Create: `/Users/wanglei/workspace/MAformac-uiue/Tools/checks/capture-u17-l0-evidence.sh`
- Create: `/Users/wanglei/workspace/MAformac-uiue/Tools/checks/check-u17-l0-evidence.py`
- Create directory at runtime: `/Users/wanglei/workspace/MAformac-uiue/docs/research/2026-06-27-uiue-8g9b-u17-l0/`

**Interfaces:**
- Consumes: `MAformacIOSUITests/U17GoldenPathUITests`
- Produces:
  - `docs/research/2026-06-27-uiue-8g9b-u17-l0/u17-ui-tree.txt`
  - `docs/research/2026-06-27-uiue-8g9b-u17-l0/u17-golden-path-simctl.png`
  - `docs/research/2026-06-27-uiue-8g9b-u17-l0/l0-evidence.json`

- [ ] **Step 1: Write L0 checker**

Create `/Users/wanglei/workspace/MAformac-uiue/Tools/checks/check-u17-l0-evidence.py`:

```python
#!/usr/bin/env python3
import json
import sys
from pathlib import Path

REQUIRED_FIELDS = {
    "device",
    "launchArg",
    "theme",
    "ui_tree_evidence",
    "screenshot_path",
    "proof_class",
}


def fail(message: str) -> int:
    print(f"FAIL: {message}", file=sys.stderr)
    return 1


def is_png(path: Path) -> bool:
    return path.read_bytes().startswith(b"\x89PNG\r\n\x1a\n")


def main() -> int:
    if len(sys.argv) != 2:
        return fail("usage: check-u17-l0-evidence.py <evidence-dir>")

    evidence_dir = Path(sys.argv[1]).resolve()
    manifest_path = evidence_dir / "l0-evidence.json"
    if not manifest_path.exists():
        return fail(f"missing manifest: {manifest_path}")

    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    missing = sorted(REQUIRED_FIELDS.difference(manifest))
    if missing:
        return fail(f"missing fields: {missing}")

    if manifest["proof_class"] != "simulator_l0_runtime_truth":
        return fail(f"unexpected proof_class: {manifest['proof_class']}")

    if "simctl io booted screenshot" not in manifest.get("capture_command", ""):
        return fail("capture_command must include on-screen simctl screenshot command")

    forbidden = ("ImageRenderer", "Preview", "static snapshot", "XCTAttachment")
    if any(token in manifest.get("screenshot_source", "") for token in forbidden):
        return fail(f"forbidden screenshot_source: {manifest['screenshot_source']}")

    ui_tree_path = (evidence_dir / manifest["ui_tree_evidence"]).resolve()
    screenshot_path = (evidence_dir / manifest["screenshot_path"]).resolve()
    if not ui_tree_path.exists() or ui_tree_path.stat().st_size == 0:
        return fail(f"missing or empty UI tree evidence: {ui_tree_path}")
    if not screenshot_path.exists() or screenshot_path.stat().st_size == 0:
        return fail(f"missing or empty screenshot: {screenshot_path}")
    if not is_png(screenshot_path):
        return fail(f"screenshot is not a PNG: {screenshot_path}")

    tree = ui_tree_path.read_text(encoding="utf-8")
    for token in ("context-band", "mic-dock", "vehicle-card-"):
        if token not in tree:
            return fail(f"UI tree missing token: {token}")

    print("PASS: U17 L0 evidence package is complete")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
```

- [ ] **Step 2: Write capture harness**

Create `/Users/wanglei/workspace/MAformac-uiue/Tools/checks/capture-u17-l0-evidence.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEVICE_NAME="${DEVICE_NAME:-iPhone 17 Pro Max}"
SCHEME="MAformacIOS"
BUNDLE_ID="lab.rayw.MAformac.ios"
GOLDEN_PATH_ID="uiue_g9b_ac_success_deep_space"
THEME="deepSpace"
OUT_DIR="${1:-$ROOT/docs/research/2026-06-27-uiue-8g9b-u17-l0}"
DERIVED_DATA="${DERIVED_DATA:-$ROOT/.derived-data/u17-g9b-l0}"
RESULT_BUNDLE="$OUT_DIR/u17-xcuitest.xcresult"
SCREENSHOT_NAME="u17-golden-path-simctl.png"
UI_TREE_NAME="u17-ui-tree.txt"
MANIFEST_NAME="l0-evidence.json"

mkdir -p "$OUT_DIR"
rm -rf "$RESULT_BUNDLE"

cd "$ROOT"

xcrun simctl list devices | grep -F "$DEVICE_NAME" >/dev/null
xcrun simctl boot "$DEVICE_NAME" 2>/dev/null || true
open -a Simulator

U17_L0_EVIDENCE_DIR="$OUT_DIR" \
xcodebuild test \
  -project MAformac.xcodeproj \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,name=$DEVICE_NAME" \
  -only-testing:MAformacIOSUITests/U17GoldenPathUITests/testGoldenPathLaunchesAndCapturesCoreUI \
  -derivedDataPath "$DERIVED_DATA" \
  -resultBundlePath "$RESULT_BUNDLE"

APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/MAformacIOS.app"
test -d "$APP_PATH"

xcrun simctl install booted "$APP_PATH"
xcrun simctl terminate booted "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl launch booted "$BUNDLE_ID" -goldenPathID "$GOLDEN_PATH_ID"
sleep 3
xcrun simctl io booted screenshot "$OUT_DIR/$SCREENSHOT_NAME"

cat > "$OUT_DIR/$MANIFEST_NAME" <<JSON
{
  "device": "$DEVICE_NAME",
  "launchArg": "-goldenPathID $GOLDEN_PATH_ID",
  "theme": "$THEME",
  "ui_tree_evidence": "$UI_TREE_NAME",
  "screenshot_path": "$SCREENSHOT_NAME",
  "proof_class": "simulator_l0_runtime_truth",
  "screenshot_source": "on-screen Simulator composited output",
  "capture_command": "xcrun simctl io booted screenshot $SCREENSHOT_NAME",
  "xcode_scheme": "$SCHEME",
  "bundle_id": "$BUNDLE_ID",
  "result_bundle": "u17-xcuitest.xcresult",
  "claims_not_made": [
    "mobile",
    "true_device",
    "L3",
    "V-PASS",
    "A-2 complete"
  ]
}
JSON

python3 Tools/checks/check-u17-l0-evidence.py "$OUT_DIR"
```

- [ ] **Step 3: Make scripts executable**

```bash
cd /Users/wanglei/workspace/MAformac-uiue
chmod +x Tools/checks/capture-u17-l0-evidence.sh Tools/checks/check-u17-l0-evidence.py
```

- [ ] **Step 4: Run capture harness**

```bash
cd /Users/wanglei/workspace/MAformac-uiue
Tools/checks/capture-u17-l0-evidence.sh
```

Expected:
- `PASS: U17 L0 evidence package is complete`
- `docs/research/2026-06-27-uiue-8g9b-u17-l0/u17-golden-path-simctl.png` exists
- `docs/research/2026-06-27-uiue-8g9b-u17-l0/u17-ui-tree.txt` exists
- `docs/research/2026-06-27-uiue-8g9b-u17-l0/l0-evidence.json` exists

- [ ] **Step 5: Screenshot comparison discipline**

Open the screenshot once for visual sanity, then record only a local/simulator proof claim:

```bash
cd /Users/wanglei/workspace/MAformac-uiue
python3 Tools/checks/check-u17-l0-evidence.py docs/research/2026-06-27-uiue-8g9b-u17-l0
```

Expected:
- PASS
- Do not claim aesthetic pass, L3, or V-PASS from this visual sanity check.

## Task 5: OpenSpec/grill check/receipt update and final commit

**Files:**
- Create: `/Users/wanglei/workspace/MAformac-uiue/docs/research/2026-06-27-uiue-8g9b-u17-l0/README.md`
- Modify: `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/tasks.md`
- Modify: `/Users/wanglei/workspace/MAformac-uiue/docs/grill-checklist/uiue-a2-grill-coverage-index.md`

**Interfaces:**
- Consumes: L0 evidence package from Task 4.
- Produces: accurate status: `8.G9b` done, parent `8.G9` done, `8.C2` open.

- [ ] **Step 1: Write receipt README**

Create `/Users/wanglei/workspace/MAformac-uiue/docs/research/2026-06-27-uiue-8g9b-u17-l0/README.md`:

```markdown
# UIUE 8.G9b U17 XCUITest + L0 Evidence Receipt

## Conclusion

`8.G9b / U17` is complete for simulator L0 smoke scope: the repository has a real `MAformacIOSUITests` target, a minimum golden path XCUITest, and an on-screen `simctl io screenshot` L0 evidence package.

This receipt does not close `8.C2`, does not claim L3, and does not claim `V-PASS`.

## Evidence

- L0 manifest: `l0-evidence.json`
- UI tree evidence: `u17-ui-tree.txt`
- On-screen screenshot: `u17-golden-path-simctl.png`
- XCUITest result bundle: `u17-xcuitest.xcresult`

## Re-run

```bash
cd /Users/wanglei/workspace/MAformac-uiue
Tools/checks/capture-u17-l0-evidence.sh
python3 Tools/checks/check-u17-l0-evidence.py docs/research/2026-06-27-uiue-8g9b-u17-l0
```

## Proof Class

- `simulator_l0_runtime_truth`
- Supporting proof: local/unit/XCUITest

## Claims Not Made

- No mobile proof
- No true-device proof
- No L3 human 5-gate verdict
- No V-PASS
- No A-2 complete claim
- No real NLU/ASR/TTS/LoRA/backend readiness
```

- [ ] **Step 2: Update `tasks.md` only after evidence passes**

In `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/tasks.md`, change:

```markdown
- [ ] 8.G9 UIUE 工程项实装（U14-U18）：Mac AnyLayout 并排 / HTML+Preview 4 类反例 / iPhone 触觉 / snapshot+黄金路径 XCUITest / 客户物料不上架
```

to:

```markdown
- [x] 8.G9 UIUE 工程项实装（U14-U18）：Mac AnyLayout 并排 / HTML+Preview 4 类反例 / iPhone 触觉 / snapshot+黄金路径 XCUITest / 客户物料不上架
```

and change:

```markdown
  - [ ] 8.G9b（U17）保留 open：必须单独做 UI test target + 最小 XCUITest + on-screen `simctl io screenshot` L0 截图包；8.G9a local/unit 通过不得勾选父级 8.G9。
```

to:

```markdown
  - [x] 8.G9b（U17）：已新增 `MAformacIOSUITests` UI test target + 最小黄金路径 XCUITest + on-screen `simctl io screenshot` L0 截图包；proof class 限 simulator L0 smoke，不关 `8.C2` / L3 / V-PASS。
```

Do not change `8.C2`.

- [ ] **Step 3: Update grill coverage index**

Append this line near the existing A-2 receipts in `/Users/wanglei/workspace/MAformac-uiue/docs/grill-checklist/uiue-a2-grill-coverage-index.md`:

```markdown
UIUE 8.G9b U17 XCUITest/L0 receipt: `docs/research/2026-06-27-uiue-8g9b-u17-l0/README.md`（`MAformacIOSUITests` + minimum golden path XCUITest + on-screen `simctl io screenshot` L0 package；simulator L0 smoke only；`8.C2` / L3 / V-PASS 仍 open）。
```

If this file is already dirty from another agent, inspect its diff, keep their changes, and only add the single receipt line above.

- [ ] **Step 4: Run validation gates**

```bash
cd /Users/wanglei/workspace/MAformac-uiue
swift test --filter U17GoldenPathManifestTests
U17_L0_EVIDENCE_DIR=/tmp/maformac-u17-ui-tree \
xcodebuild test \
  -project MAformac.xcodeproj \
  -scheme MAformacIOS \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -only-testing:MAformacIOSUITests/U17GoldenPathUITests/testGoldenPathLaunchesAndCapturesCoreUI
Tools/checks/capture-u17-l0-evidence.sh
python3 Tools/checks/check-u17-l0-evidence.py docs/research/2026-06-27-uiue-8g9b-u17-l0
swift test
make verify-all
openspec validate ui-presentation --strict
git diff --check
```

Expected:
- all commands exit 0
- `swift test` remains 0 failures
- `make verify-all` remains PASS
- OpenSpec validates
- checker prints `PASS: U17 L0 evidence package is complete`

- [ ] **Step 5: Arrange subagent Codex read-only delivery audit**

Before staging or committing, dispatch an independent Codex subagent with this exact scope:

```text
请在 /Users/wanglei/workspace/MAformac-uiue 做 read-only 审计，目标是 UIUE 8.G9b/U17 交付结果。

只读，不改文件，不 stage，不 commit。

审计依据：
- docs/superpowers/plans/2026-06-27-uiue-8g9b-u17-xcuitest-l0.md
- docs/grill-tournament/uiue-8g9-and-liquid-glass-hardening-grill-decisions.md U39/U45
- openspec/changes/ui-presentation/specs/ui-presentation/spec.md L0-L3
- openspec/changes/ui-presentation/tasks.md 8.G9/8.G9b/8.C2

重点检查：
1. 是否真实新增 `MAformacIOSUITests` UI test target，而不是 SwiftPM/unit 冒充。
2. `MAformacIOS` scheme 是否能跑最小 U17 XCUITest。
3. golden path 是否走正常主舞台 `-goldenPathID` -> `-mockSnapshot cooling` + `-mockTheme deepSpace`，没有用 `-forceVisualState` / gallery / Preview 冒充。
4. L0 evidence 是否包含 `device`、`launchArg`、`theme`、`ui_tree_evidence`、`screenshot_path`、`proof_class`。
5. screenshot 是否来自 on-screen `xcrun simctl io booted screenshot`，不是 `ImageRenderer`、Preview、XCUITest attachment 或静态 snapshot。
6. `8.C2` 是否保持 open，未声明 L3/V-PASS/mobile/true_device/A-2 complete。
7. staged/commit candidates 是否只包含 G9b owned files，不卷入既有 visual evidence dirs 或无关 grill docs。
8. 是否已读并吸收 `Tools/skills`、`Tools/agent-platform-plugin-refs`、Codex 官方 build-ios-apps skills、Apple 官方资料；若未吸收，指出风险。

请输出：
- verdict: PASS | FINDINGS | BLOCKED
- findings: 按 P0/P1/P2 排序，含 file:line
- required fixes: controller 必须修什么
- validation observed: 你实际跑/核了哪些命令或文件
- proof boundary: 哪些能 claim，哪些不能 claim
- confidence: high/medium/low
```

Controller handling:
- If subagent verdict is `PASS`, proceed to staging.
- If subagent verdict is `FINDINGS`, fix the findings, rerun affected tests and L0 checker, then optionally re-audit if P0/P1.
- If subagent verdict is `BLOCKED`, do not commit; report the exact blocker to 磊哥.

- [ ] **Step 6: Stage only owned G9b files**

```bash
cd /Users/wanglei/workspace/MAformac-uiue
git add \
  App/MAformacApp.swift \
  Core/Presentation/U17GoldenPathManifest.swift \
  Tests/MAformacCoreTests/U17GoldenPathManifestTests.swift \
  MAformac.xcodeproj/project.pbxproj \
  MAformac.xcodeproj/xcshareddata/xcschemes/MAformacIOS.xcscheme \
  MAformacIOSUITests/U17GoldenPathUITests.swift \
  Tools/checks/capture-u17-l0-evidence.sh \
  Tools/checks/check-u17-l0-evidence.py \
  docs/research/2026-06-27-uiue-8g9b-u17-l0/README.md \
  docs/research/2026-06-27-uiue-8g9b-u17-l0/l0-evidence.json \
  docs/research/2026-06-27-uiue-8g9b-u17-l0/u17-ui-tree.txt \
  docs/research/2026-06-27-uiue-8g9b-u17-l0/u17-golden-path-simctl.png \
  openspec/changes/ui-presentation/tasks.md \
  docs/grill-checklist/uiue-a2-grill-coverage-index.md
git diff --cached --name-only
git diff --cached --check
```

Expected staged files are exactly the G9b files above, plus no existing visual evidence dirs from older runs.

- [ ] **Step 7: Commit**

```bash
cd /Users/wanglei/workspace/MAformac-uiue
git commit -m "test(uiue): close 8g9b xcuitest l0 harness"
```

Expected:
- commit succeeds
- final status may still show pre-existing unrelated docs/evidence dirty files; list them in verdict as excluded

## Final Verdict Format

```markdown
磊哥，verdict: DONE | PARTIAL | BLOCKED

commit sha: `<sha>`

changed files:
- `<path>`: 中文说明

validation:
- PASS/FAIL `<command>`: 关键结果

proof class:
- local
- unit
- XCUITest
- simulator_l0_runtime_truth

residual risks:
- `8.C2` 仍 open
- L3 / V-PASS 仍需磊哥人工 5-gate
- no mobile / true_device / backend / voice / model readiness claimed

excluded dirty files:
- 列出未纳入本 commit 的既有 dirty/untracked 文件或目录
```

## Self-Review

- Spec coverage: U39 的 `golden_path_manifest`、launch args contract、UI test target、最小 XCUITest、on-screen L0 screenshot package 都有任务覆盖。
- Scope boundary: 计划不接真 NLU/ASR/TTS/LoRA/backend，不碰投屏，不关 `8.C2`，不声明 V-PASS。
- Placeholder scan: 本计划不使用未定义占位；每个新增文件有明确代码或精确字段。
- Type consistency: `U17GoldenPathID.acSuccessDeepSpace`、`U17GoldenPathManifest.Entry`、`-goldenPathID uiue_g9b_ac_success_deep_space` 在 unit、App、XCUITest、harness 中一致。
- Risk handling: HIGH 风险 stop gate、pbxproj bounded repair、L0 screenshot source 校验均已写入。
- Delivery audit: 交付前 subagent Codex read-only 审计已作为硬步骤，commit 只能发生在 audit PASS 或 findings 修复后。
