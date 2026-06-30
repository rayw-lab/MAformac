# UIUE 8.C2 L0-L3 视觉验收包实施计划

> **给 agentic workers:** 必须使用 `superpowers:subagent-driven-development`（推荐）或 `superpowers:executing-plans` 按任务执行本计划。步骤使用 checkbox（`- [ ]`）追踪。

**目标:** 产出 `8.C2 visual-acceptance L0-L3` 视觉验收证据包：L0 on-screen simulator runtime-truth、L1 PASS/WARN/FAIL collapse sentinel、L2 OCR+contrast hard gate + SSIM evidence、L3 磊哥人工 5-gate verdict。

**架构:** 8.C2 是证据包和验收门，不是新产品功能。执行用现有 `MAformacIOS`、`MAformacIOSUITests`、`-mockSnapshot`、`-mockTheme`、`-contextCapsuleRoute` 和 `simctl io booted screenshot` 生成多场景截图；机器层只负责挡塌陷和可读性，最后由磊哥签 L3，任何 agent 不得把 simulator/local/unit 证明升级成 `V-PASS`。

**技术栈:** Swift 6.0、Xcode project `MAformac.xcodeproj`、scheme `MAformacIOS`、XCTest/XCUITest、iOS Simulator `iPhone 17 Pro Max` with `iPhone 17 Pro` fallback、`xcrun simctl`、Python 3 stdlib + existing Pillow-backed `Tools/checks/phase2_zone_compare.py`、Swift one-file Vision OCR checker、OpenSpec。

## 全局约束

- 默认中文文档、派单、计划、审计报告、verdict、receipt；代码标识符、路径、命令、API 字段和外部英文原文引用可保留英文。
- 工作目录固定为 `/Users/wanglei/workspace/MAformac-uiue`，分支应为 `uiue/phase4-default-scope-presentation`。
- 不使用 `git add .`；只 stage 本计划列出的 owned files。
- 严格排除旧 untracked visual evidence dirs，不移动、不重命名、不删除、不批量 stage：
  - `docs/research/2026-06-25-a2-execution/visual-diff-v45/`
  - `docs/research/2026-06-25-a2-execution/zone-compare-main-stage-v1/`
  - `docs/research/2026-06-25-a2-execution/zone-compare-phase6-capsule/`
  - `docs/research/2026-06-25-a2-execution/zone-compare-phase6-route-spike/`
  - `docs/research/2026-06-26-ios2026-frontend-trends-migration/`
- 不接真 NLU / ASR / TTS / LoRA / backend；8.C2 只验 UIUE mock-frontstage 视觉证据。
- 不碰投屏、AirPlay、1080p 外屏验收；本包按手持/本机模拟器视觉证据处理。
- 不声明 `mobile`、`true_device`、App Store/TestFlight/release readiness、A-2 complete，除非对应 proof class 后续真实存在。
- `8.C2` 只有在 L0/L1/L2/L3 四层都齐且磊哥明确给出可关闭 verdict 后才能勾选；L0-L2 绿但缺 L3 时最终状态必须是 `PARTIAL_PENDING_L3`。
- L0 截图必须来自 on-screen `xcrun simctl io booted screenshot`；SwiftUI Preview、`ImageRenderer`、XCUITest attachment、静态 snapshot、非合成渲染输出均不得计入 L0。
- L1 的 `PASS/WARN/FAIL` 只挡视觉塌陷和明显回归，不是审美打分，不追 RMSE 小数优化。
- L2 的 OCR 和 contrast 是可读性硬门，SSIM 只作为 regression evidence；LPIPS 不作为本 change gate。
- L3 人工 5-gate verdict enum 只能是 `V-PASS`、`V-PASS_WITH_NOTES`、`PARTIAL`、`FAIL`；只有磊哥能签 `V-PASS`。
- 执行完毕回写前必须安排独立 subagent Codex 做 read-only 审计，controller 修复审计 findings 后才能 commit 或回写最终 verdict。

---

## 对 `019f0313-0be0-7950-9e48-23c75aea9028` 的累计派单要求

这一段是硬约束，不是建议。

- 时常回顾经验教训：每完成一个里程碑，更新 `docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/LESSONS.md`，至少记录 `new proof class`、`new risk`、`fix-forward decision`、`not claimed`。
- 时常回顾 `Tools/` 与 `Tools/skills/` 的肩膀：Stage 0、Stage 2、final audit 前各回看一次 `Tools/skills/INDEX.md`、`Tools/skills/ios-simulator-skill/SKILL.md`、`Tools/agent-platform-plugin-refs/README.md`，并在 receipt 写明采用或不采用原因。
- 参考官方 iOS 生态工具和联网资料：至少核 Apple `xcodebuild test`、XCUITest launch arguments、`accessibilityIdentifier`、Simulator `simctl io screenshot`；可参考 Codex 官方 `build-ios-apps` skills，但以 live repo truth 和 Apple 官方文档为准。
- Apple 官方资料核验必须落成可审计产物：创建 `docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/tool-official-source-notes.md`，记录 URL、captured_at、采用/不采用结论和映射到的计划步骤。
- 有坑先用 pre-mortem：若 UI test、screenshot、OCR、contrast、anchor compare、pbxproj/scheme 任一处异常，先写 mini pre-mortem，再修；不能盲调。
- 做好截图对比和 harness：所有截图必须有命令、manifest、UI tree、case id、theme、launch args；禁止只靠口头“看起来可以”。
- 不降级，不把需求砍成只跑 U17；8.C2 必须覆盖 `continuous stage no black line`、`thermal cooling/heating`、`safety refusal`、`capsule diorama` 和 `deepSpace/ivory` 两主题。
- 不过度工程化：优先复用现有 `MAformacIOSUITests`、`DebugLaunchArguments`、`phase2_zone_compare.py`；只新增 8.C2 所需的最小 harness/checker/docs。
- 长跑 stop-rule：连续两轮只调同一个 L1/L2 数字、没有新增 proof class 或 artifact 时必须停，按 `PARTIAL/FAIL` 收口，不能再烧长跑。
- 最终回写必须中文，格式包含 `verdict`、`commit sha`、`changed files with line refs`、`validation`、`proof class`、`residual risks`、`exact remaining tasks`。

## 当前真态

- HEAD at plan time: `aef42d8` on `uiue/phase4-default-scope-presentation`，repo ahead 51。
- `openspec/changes/ui-presentation/tasks.md` 中 `8.G1` 到 `8.G9b` 已勾，`8.C2` 仍 open。
- `openspec/changes/ui-presentation/specs/ui-presentation/spec.md` 已锁 L0-L3 视觉门契约。
- `Tools/checks/phase2_zone_compare.py` 已是 L1 sentinel，主输出为 `l1_verdict` 的 `PASS/WARN/FAIL`。
- `MAformacIOSUITests/U17GoldenPathUITests.swift`、`Tools/checks/capture-u17-l0-evidence.sh`、`Tools/checks/check-u17-l0-evidence.py` 已提供 U17 L0 smoke 模式，可复用结构但不能以 U17 单点关闭 8.C2。
- `App/MAformacApp.swift` DEBUG 启动参数已支持：
  - `-goldenPathID uiue_g9b_ac_success_deep_space`
  - `-mockSnapshot coldStart|cooling|heating|safetyRefusal`
  - `-mockTheme deepSpace|ivory`
  - `-contextCapsuleRoute cLite|videoLoop`
  - `-contextSpeed <int>`、`-contextGear <string>`、`-contextWeather <string>`、`-contextTimePeriod <string>`
- 现有稳定 UI identifiers 包括 `context-band`、`mic-dock-safe-area`、`demo-orb`、`dialogue-stream`、`vehicle-cards`、`vehicle-cards-mac-panorama`、`vehicle-card-family.*`。

## 证据包目录

创建一个新的证据目录：

```text
/Users/wanglei/workspace/MAformac-uiue/docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/
  README.md
  LESSONS.md
  package-manifest.json
  tool-official-source-notes.md
  l0/
    case-id.json
    case-id-simctl.png
    case-id-ui-tree.txt
  l1/
    case-id.tsv
    l1-summary.tsv
  l2/
    case-id.json
    l2-summary.json
  l3/
    human-5gate-verdict.md
  audit/
    subagent-codex-audit.md
```

不得写入旧的 untracked `docs/research/2026-06-25-a2-execution/**` 目录。若确实要用旧图片作为 anchor，只能把明确选中的文件复制到新的 8.C2 证据包，并在 `package-manifest.json` 记录 source path。

## 验收用例矩阵

证据包至少包含这些用例：

| case_id | launch args | theme | purpose |
| --- | --- | --- | --- |
| `main_cooling_deep_space` | `-mockSnapshot cooling -mockTheme deepSpace -contextCapsuleRoute cLite` | `deepSpace` | continuous stage + cooling thermal visual |
| `main_heating_ivory` | `-mockSnapshot heating -mockTheme ivory -contextCapsuleRoute cLite` | `ivory` | continuous stage + heating thermal visual |
| `safety_refusal_ivory` | `-mockSnapshot safetyRefusal -mockTheme ivory -contextCapsuleRoute cLite` | `ivory` | safety refusal copy and state differentiation |
| `capsule_video_loop_deep_space` | `-mockSnapshot cooling -mockTheme deepSpace -contextCapsuleRoute videoLoop -contextSpeed 48 -contextGear D -contextWeather 雨 -contextTimePeriod 夜间` | `deepSpace` | capsule diorama / motion-heavy scene |
| `u17_golden_path_deep_space` | `-goldenPathID uiue_g9b_ac_success_deep_space` | `deepSpace` | reuse G9b golden path as reference smoke, not as sole 8.C2 coverage |

如果 simulator accessibility controls 可用且不会造成不稳定全局副作用，可追加这个诊断用例：

| case_id | launch args | theme | purpose |
| --- | --- | --- | --- |
| `reduced_motion_think_static` | `-mockSnapshot cooling -mockTheme deepSpace -contextCapsuleRoute cLite` with Reduce Motion enabled before launch | `deepSpace` | G8 static feedback sanity; diagnostic unless L3 flags it |

## 任务 0：真态门、工具肩膀与 Pre-Mortem

**文件:**
- Read: `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/tasks.md`
- Read: `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/specs/ui-presentation/spec.md`
- Read: `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/design.md`
- Read: `/Users/wanglei/workspace/MAformac-uiue/Tools/skills/INDEX.md`
- Read: `/Users/wanglei/workspace/MAformac-uiue/Tools/skills/ios-simulator-skill/SKILL.md`
- Read: `/Users/wanglei/workspace/MAformac-uiue/Tools/agent-platform-plugin-refs/README.md`
- Read: `/Users/wanglei/workspace/MAformac-uiue/Tools/agent-platform-plugin-refs/build-ios-apps-skills/ios-simulator-browser/SKILL.md`
- Create: `/Users/wanglei/workspace/MAformac-uiue/docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/LESSONS.md`
- Create: `/Users/wanglei/workspace/MAformac-uiue/docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/tool-official-source-notes.md`

**接口:**
- 消费：OpenSpec L0-L3 contract、existing U17 L0 harness、Tools/skills guidance。
- 产出：execution notes、pre-mortem risks、first lessons ledger、official source notes。

- [ ] **步骤 1：确认 repo 真态**

```bash
cd /Users/wanglei/workspace/MAformac-uiue
pwd
git branch --show-current
git rev-parse --short HEAD
git status --short
openspec validate ui-presentation --strict
```

预期：
- branch is `uiue/phase4-default-scope-presentation`
- `openspec validate ui-presentation --strict` prints `Change 'ui-presentation' is valid`
- old untracked visual evidence dirs remain untracked and untouched

- [ ] **步骤 2：确认 8.C2 仍 open 且 G 任务已关**

```bash
cd /Users/wanglei/workspace/MAformac-uiue
sed -n '108,160p' openspec/changes/ui-presentation/tasks.md
sed -n '252,285p' openspec/changes/ui-presentation/specs/ui-presentation/spec.md
```

预期：
- `8.C2` unchecked
- `8.G1` through `8.G9b` checked
- spec states L0/L1/L2/L3 and L3 human verdict rules

- [ ] **步骤 3：阅读工具肩膀**

```bash
cd /Users/wanglei/workspace/MAformac-uiue
sed -n '1,220p' Tools/skills/INDEX.md
sed -n '1,260p' Tools/skills/ios-simulator-skill/SKILL.md
sed -n '1,220p' Tools/agent-platform-plugin-refs/README.md
sed -n '1,220p' Tools/agent-platform-plugin-refs/build-ios-apps-skills/ios-simulator-browser/SKILL.md
```

预期：
- receipt notes mention which simulator/screenshot/UI test commands were adopted
- if a tool is not used, receipt states the reason

- [ ] **步骤 4：写 Apple 官方资料核验记录**

按这个最小结构创建 `tool-official-source-notes.md`：

```markdown
# UIUE 8.C2 官方资料与工具吸收记录

captured_at: write the exact output of `date -u +"%Y-%m-%dT%H:%M:%SZ"`
repo_head: write the exact output of `git rev-parse --short HEAD`

## Apple 官方资料

| source | url | used_for | adopted_decision |
| --- | --- | --- | --- |
| Apple xcodebuild tests | write the official Apple URL | UI test CLI gate | write adopted or not adopted and why |
| Apple XCUIApplication launchArguments | write the official Apple URL | `UIUE_8C2_CASE_ID` launch args | write adopted or not adopted and why |
| Apple accessibilityIdentifier | write the official Apple URL | UI tree evidence markers | write adopted or not adopted and why |
| Apple Simulator simctl screenshot | write the official Apple URL | L0 on-screen screenshot | write adopted or not adopted and why |
| Apple Vision text recognition | write the official Apple URL | L2 OCR hard gate | write adopted or not adopted and why |

## 本仓工具吸收

| source | path | used_for | adopted_decision |
| --- | --- | --- | --- |
| ios-simulator-skill | Tools/skills/ios-simulator-skill/SKILL.md | simulator lifecycle / screenshot | write adopted or not adopted and why |
| Codex build-ios-apps ios-simulator-browser | Tools/agent-platform-plugin-refs/build-ios-apps-skills/ios-simulator-browser/SKILL.md | simulator/browser proof | write adopted or not adopted and why |
| U17 L0 harness | Tools/checks/capture-u17-l0-evidence.sh | L0 harness pattern | write adopted or not adopted and why |
```

这个文件是必需证据 artifact。不要只把 Apple 官方资料核验留在 terminal scrollback 或最终 verdict 口头描述里。

- [ ] **步骤 5：写第一版 lessons ledger**

按这个初始内容创建 `LESSONS.md`：

```markdown
# UIUE 8.C2 Visual Acceptance Lessons

## 阶段 0

- captured_at: write the exact output of `date -u +"%Y-%m-%dT%H:%M:%SZ"`
- repo_head: write the exact output of `git rev-parse --short HEAD`
- proof_class_added: none yet
- tools_reviewed: Tools/skills/INDEX.md, Tools/skills/ios-simulator-skill/SKILL.md, Tools/agent-platform-plugin-refs/README.md, build-ios-apps ios-simulator-browser skill
- official_sources_reviewed: see tool-official-source-notes.md
- pre_mortem:
  - risk: L0 screenshot accidentally comes from XCUITest attachment or static render
    guard: require manifest capture_command containing `simctl io booted screenshot`
  - risk: L1 RMSE loop becomes fake aesthetic work
    guard: stop after two loops without new proof class or artifact
  - risk: L2 OCR/contrast unavailable on local machine
    guard: stop as PARTIAL with exact missing tool/framework; do not close 8.C2
  - risk: L3 not signed by 磊哥
    guard: final verdict becomes PARTIAL_PENDING_L3 and tasks.md remains open
- not_claimed: mobile, true_device, V-PASS, A-2 complete, real NLU/ASR/TTS/LoRA/backend
```

- [ ] **步骤 6：真态门失败时停下**

Stop and report exactly:

```text
blocked at Stage 0 after attempts git-status/openspec-validate/tools-read; only missing the specific missing repo, scheme, spec, or tool named here
```

## 任务 1：8.C2 L0 多用例 UI Test 与截图 Harness

**文件:**
- Create: `/Users/wanglei/workspace/MAformac-uiue/MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift`
- Create: `/Users/wanglei/workspace/MAformac-uiue/Tools/checks/capture-8c2-l0-evidence.sh`
- Create: `/Users/wanglei/workspace/MAformac-uiue/Tools/checks/check-8c2-l0-evidence.py`
- Modify: `/Users/wanglei/workspace/MAformac-uiue/docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/LESSONS.md`

**接口:**
- 消费：
  - Existing `MAformacIOSUITests` target
  - `MAformacIOSUITests/U17GoldenPathUITests.swift` pattern
  - `App/MAformacApp.swift` DEBUG launch arguments
- 产出：
  - one UI tree text file per case
  - one on-screen `simctl` PNG per case
  - one L0 JSON manifest per case
  - package manifest root JSON

- [ ] **步骤 1：新增 UI test 用例注册表**

创建 `MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift`：test 从环境变量读取 `UIUE_8C2_CASE_ID`，映射到验收用例矩阵里的精确 launch arguments，启动 `XCUIApplication`，等待 `context-band`、`demo-orb`、`dialogue-stream` 和 `mic-dock` 或 `mic-dock-safe-area`，然后把 `8c2-{case_id}-ui-tree.txt` 写入 `UIUE_8C2_EVIDENCE_DIR`。

必需 Swift 形态：

```swift
import Foundation
import XCTest

final class UIC2VisualAcceptanceUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testVisualAcceptanceCaseLaunchesAndCapturesUITree() throws {
        let caseID = ProcessInfo.processInfo.environment["UIUE_8C2_CASE_ID"] ?? ""
        let spec = try UIC2CaseSpec.caseSpec(for: caseID)
        let evidenceDirectory = try makeEvidenceDirectory()
        let app = XCUIApplication()
        app.launchArguments = spec.launchArguments
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 12))
        XCTAssertTrue(waitForElement("context-band", in: app))
        XCTAssertTrue(waitForElement("demo-orb", in: app))
        XCTAssertTrue(waitForElement("dialogue-stream", in: app))
        XCTAssertTrue(waitForAnyElement(["mic-dock", "mic-dock-safe-area"], in: app))
        XCTAssertTrue(waitForAnyElement(["vehicle-cards", "vehicle-cards-mac-panorama"], in: app))

        let tree = try writeUITree(for: app, caseID: caseID, to: evidenceDirectory)
        for marker in spec.requiredMarkers {
            XCTAssertTrue(tree.contains(marker), "missing marker: \(marker)")
        }
    }

    private func makeEvidenceDirectory() throws -> URL {
        let rawPath = ProcessInfo.processInfo.environment["UIUE_8C2_EVIDENCE_DIR"] ?? NSTemporaryDirectory()
        let directory = URL(fileURLWithPath: rawPath, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    @MainActor
    private func waitForElement(_ identifier: String, in app: XCUIApplication) -> Bool {
        app.descendants(matching: .any)[identifier].waitForExistence(timeout: 12)
    }

    @MainActor
    private func waitForAnyElement(_ identifiers: [String], in app: XCUIApplication) -> Bool {
        let deadline = Date().addingTimeInterval(12)
        repeat {
            if identifiers.contains(where: { app.descendants(matching: .any)[$0].exists }) {
                return true
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        } while Date() < deadline
        return false
    }

    @discardableResult
    @MainActor
    private func writeUITree(for app: XCUIApplication, caseID: String, to evidenceDirectory: URL) throws -> String {
        let tree = app.debugDescription
        let treeURL = evidenceDirectory.appendingPathComponent("8c2-\(caseID)-ui-tree.txt")
        try tree.write(to: treeURL, atomically: true, encoding: .utf8)
        print("UIUE_8C2_UI_TREE_BEGIN \(caseID)")
        print(tree)
        print("UIUE_8C2_UI_TREE_END \(caseID)")
        return tree
    }
}

private struct UIC2CaseSpec {
    let id: String
    let theme: String
    let launchArguments: [String]
    let requiredMarkers: [String]

    static func caseSpec(for id: String) throws -> UIC2CaseSpec {
        guard let spec = all.first(where: { $0.id == id }) else {
            throw NSError(
                domain: "UIC2CaseSpec",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "unknown UIUE_8C2_CASE_ID: \(id)"]
            )
        }
        return spec
    }

    static let all: [UIC2CaseSpec] = [
        UIC2CaseSpec(
            id: "main_cooling_deep_space",
            theme: "deepSpace",
            launchArguments: ["-mockSnapshot", "cooling", "-mockTheme", "deepSpace", "-contextCapsuleRoute", "cLite"],
            requiredMarkers: ["context-band", "demo-orb", "dialogue-stream", "vehicle-card-family."]
        ),
        UIC2CaseSpec(
            id: "main_heating_ivory",
            theme: "ivory",
            launchArguments: ["-mockSnapshot", "heating", "-mockTheme", "ivory", "-contextCapsuleRoute", "cLite"],
            requiredMarkers: ["context-band", "demo-orb", "dialogue-stream", "vehicle-card-family."]
        ),
        UIC2CaseSpec(
            id: "safety_refusal_ivory",
            theme: "ivory",
            launchArguments: ["-mockSnapshot", "safetyRefusal", "-mockTheme", "ivory", "-contextCapsuleRoute", "cLite"],
            requiredMarkers: ["context-band", "demo-orb", "dialogue-stream", "vehicle-card-family."]
        ),
        UIC2CaseSpec(
            id: "capsule_video_loop_deep_space",
            theme: "deepSpace",
            launchArguments: [
                "-mockSnapshot", "cooling",
                "-mockTheme", "deepSpace",
                "-contextCapsuleRoute", "videoLoop",
                "-contextSpeed", "48",
                "-contextGear", "D",
                "-contextWeather", "雨",
                "-contextTimePeriod", "夜间"
            ],
            requiredMarkers: ["context-band", "demo-orb", "dialogue-stream", "vehicle-card-family."]
        ),
        UIC2CaseSpec(
            id: "u17_golden_path_deep_space",
            theme: "deepSpace",
            launchArguments: ["-goldenPathID", "uiue_g9b_ac_success_deep_space"],
            requiredMarkers: ["context-band", "demo-orb", "dialogue-stream", "vehicle-card-family."]
        )
    ]
}
```

- [ ] **步骤 2：先跑一个用例的新 UI test**

```bash
cd /Users/wanglei/workspace/MAformac-uiue
UIUE_8C2_CASE_ID=main_cooling_deep_space \
UIUE_8C2_EVIDENCE_DIR=docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/l0 \
xcodebuild test \
  -project MAformac.xcodeproj \
  -scheme MAformacIOS \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -only-testing:MAformacIOSUITests/UIC2VisualAcceptanceUITests/testVisualAcceptanceCaseLaunchesAndCapturesUITree
```

预期：
- test passes
- `l0/8c2-main_cooling_deep_space-ui-tree.txt` exists

- [ ] **步骤 3：新增截图脚本**

参考已验证的 `Tools/checks/capture-u17-l0-evidence.sh` 模式创建 `Tools/checks/capture-8c2-l0-evidence.sh`。必需行为：

```text
usage: Tools/checks/capture-8c2-l0-evidence.sh [out_dir]
default out_dir: docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance
device default: iPhone 17 Pro Max
fallback: iPhone 17 Pro
for each required case:
  1. boot the selected simulator
  2. run only UIC2VisualAcceptanceUITests/testVisualAcceptanceCaseLaunchesAndCapturesUITree with UIUE_8C2_CASE_ID and UIUE_8C2_EVIDENCE_DIR
  3. install built MAformacIOS.app
  4. terminate bundle lab.rayw.MAformac.ios
  5. launch app with the exact same case launch args
  6. assert exactly one booted simulator and it is the target UDID
  7. run xcrun simctl io booted screenshot l0/{case_id}-simctl.png
  8. write l0/{case_id}.json with required L0 fields
  9. append the case to package-manifest.json
after all cases:
  run Tools/checks/check-8c2-l0-evidence.py with the actual output directory
  clean DerivedData/result bundles/logs unless a failure occurs
```

每个 L0 case JSON 必须包含：

```json
{
  "case_id": "main_cooling_deep_space",
  "device": {
    "name": "iPhone 17 Pro Max",
    "udid": "write the runtime UDID returned by simctl",
    "runtime": "iOS Simulator"
  },
  "launchArg": "-mockSnapshot cooling -mockTheme deepSpace -contextCapsuleRoute cLite",
  "theme": "deepSpace",
  "ui_tree_evidence": "l0/8c2-main_cooling_deep_space-ui-tree.txt",
  "screenshot_path": "l0/main_cooling_deep_space-simctl.png",
  "proof_class": "simulator_l0_runtime_truth",
  "screenshot_source": "on_screen_simctl_io_booted_screenshot",
  "capture_command": "xcrun simctl io booted screenshot l0/main_cooling_deep_space-simctl.png",
  "claims_not_made": [
    "mobile",
    "true_device",
    "L3",
    "V-PASS",
    "A-2 complete"
  ]
}
```

- [ ] **步骤 4：新增 L0 checker**

泛化 `check-u17-l0-evidence.py`，创建 `Tools/checks/check-8c2-l0-evidence.py`。必需检查：

```text
input: evidence dir
required cases: main_cooling_deep_space, main_heating_ivory, safety_refusal_ivory, capsule_video_loop_deep_space, u17_golden_path_deep_space
for every case:
  manifest file exists at l0/{case_id}.json
  JSON has device, launchArg, theme, ui_tree_evidence, screenshot_path, proof_class
  proof_class == simulator_l0_runtime_truth
  screenshot_source == on_screen_simctl_io_booted_screenshot
  capture_command contains simctl io booted screenshot
  forbidden screenshot sources are absent: ImageRenderer, SwiftUI preview, Preview, static snapshot, XCTAttachment, xcuitest_attachment
  UI tree file exists and contains context-band, demo-orb, dialogue-stream, vehicle-card-family.
  screenshot exists and has PNG magic bytes
package-manifest.json lists every required case exactly once
print: PASS: 8.C2 L0 evidence package is complete
```

- [ ] **步骤 5：跑完整 L0 capture**

```bash
cd /Users/wanglei/workspace/MAformac-uiue
Tools/checks/capture-8c2-l0-evidence.sh
python3 Tools/checks/check-8c2-l0-evidence.py docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance
```

预期：
- capture script passes
- checker prints `PASS: 8.C2 L0 evidence package is complete`
- no old visual evidence dirs are touched

- [ ] **步骤 6：更新 lessons**

Append to `LESSONS.md`:

```markdown
## 阶段 1

- proof_class_added: simulator_l0_runtime_truth
- cases_captured: main_cooling_deep_space, main_heating_ivory, safety_refusal_ivory, capsule_video_loop_deep_space, u17_golden_path_deep_space
- screenshot_source: on_screen_simctl_io_booted_screenshot
- tools_rechecked: Tools/checks/capture-u17-l0-evidence.sh, Tools/checks/check-u17-l0-evidence.py, ios-simulator-skill
- not_claimed: mobile, true_device, L3, V-PASS, A-2 complete
```

## 任务 2：L1 塌陷 Sentinel 与 Anchor 账

**文件:**
- Modify: `/Users/wanglei/workspace/MAformac-uiue/docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/package-manifest.json`
- Create: `/Users/wanglei/workspace/MAformac-uiue/docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/l1/l1-summary.tsv`
- Create: selected anchor copies under `/Users/wanglei/workspace/MAformac-uiue/docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/anchors/`

**接口:**
- 消费：
  - L0 screenshots from Task 1
  - `Tools/checks/phase2_zone_compare.py`
- 产出：
  - L1 `PASS/WARN/FAIL` per case
  - source-accounted anchor selection

- [ ] **步骤 1：自检 L1 sentinel**

```bash
cd /Users/wanglei/workspace/MAformac-uiue
python3 Tools/checks/phase2_zone_compare.py --self-check
python3 Tools/checks/phase2_zone_compare.py --print-stop-rule
```

预期：
- self-check prints `self-check	PASS`
- stop-rule text states L1 does not replace L3

- [ ] **步骤 2：选择带 provenance 的 anchors**

允许的 anchor 来源：

```text
1. committed evidence package if a matching anchor already exists in repo
2. explicit copy from old untracked visual evidence dirs into the new 8.C2 package, with source path recorded
3. if no honest anchor exists, stop as PARTIAL at L1 with exact missing anchor list
```

不得把截图和它自己比较后称为 L1 pass。这是 fake-green。

在 `package-manifest.json` 记录选中的 anchors：

```json
{
  "anchors": [
    {
      "case_id": "main_cooling_deep_space",
      "anchor_path": "anchors/main_cooling_deep_space-anchor.png",
      "source_path": "docs/research/2026-06-25-a2-execution/shots/phase2-iphone-v68-acfixed-downfill-cooling.png",
      "source_status": "copied_from_existing_untracked_visual_evidence",
      "reason": "closest pre-8.G visual anchor for cooling main stage"
    }
  ]
}
```

- [ ] **步骤 3：逐用例运行 L1**

对每个有 anchor 的用例运行：

```bash
cd /Users/wanglei/workspace/MAformac-uiue
python3 Tools/checks/phase2_zone_compare.py \
  --case main_cooling_deep_space \
  --anchor docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/anchors/main_cooling_deep_space-anchor.png \
  --current docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/l0/main_cooling_deep_space-simctl.png \
  --output docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/l1/main_cooling_deep_space.tsv
```

如果用例是 dynamic capsule video：

```bash
python3 Tools/checks/phase2_zone_compare.py \
  --case capsule_video_loop_deep_space \
  --anchor docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/anchors/capsule_video_loop_deep_space-anchor.png \
  --current docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/l0/capsule_video_loop_deep_space-simctl.png \
  --mask-preset phase2-capsule-diorama \
  --output docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/l1/capsule_video_loop_deep_space.tsv
```

预期：
- each TSV has `l1_verdict`
- no `FAIL`
- `WARN` is allowed only with a written reason and L3 attention note

- [ ] **步骤 4：汇总 L1**

创建 `l1/l1-summary.tsv`，header 为：

```text
case_id	l1_verdict	tsv_path	anchor_path	current_path	reason
```

如果任一用例是 `FAIL`，停下并回报：

```text
blocked at Stage 2 after attempts phase2_zone_compare/self-check/anchor-provenance; only missing a non-FAIL L1 sentinel for the named case_id
```

- [ ] **步骤 5：更新 lessons**

Append to `LESSONS.md`:

```markdown
## 阶段 2

- proof_class_added: l1_sentinel
- l1_cases: write every case id with its PASS/WARN/FAIL verdict
- anchor_rule: no screenshot compared to itself; every anchor has source_path
- stop_rule_checked: yes
- not_claimed: L3, V-PASS, aesthetic acceptance
```

## 任务 3：L2 OCR、Contrast 与 SSIM 证据

**文件:**
- Create: `/Users/wanglei/workspace/MAformac-uiue/Tools/checks/check-8c2-l2-readability.swift`
- Create: `/Users/wanglei/workspace/MAformac-uiue/Tools/checks/check-8c2-l2-package.py`
- Create: `/Users/wanglei/workspace/MAformac-uiue/docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/l2/l2-summary.json`
- Modify: `/Users/wanglei/workspace/MAformac-uiue/docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/LESSONS.md`

**接口:**
- 消费：
  - L0 screenshots
  - L1 anchors where available
  - Apple Vision text recognition on macOS for OCR
- 产出：
  - one L2 JSON per case
  - OCR and contrast hard gate result
  - SSIM or documented fallback evidence

- [ ] **步骤 1：新增 Swift Vision OCR/contrast checker**

创建 one-file Swift script `Tools/checks/check-8c2-l2-readability.swift`。必需命令接口：

```bash
swift Tools/checks/check-8c2-l2-readability.swift \
  --case main_cooling_deep_space \
  --image docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/l0/main_cooling_deep_space-simctl.png \
  --expect-text 制冷 \
  --expect-text 26 \
  --expect-text 按住说话 \
  --output docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/l2/main_cooling_deep_space.json
```

必需实现：

```text
imports: Foundation, AppKit, Vision, CoreGraphics
load PNG via NSImage -> CGImage
run VNRecognizeTextRequest with zh-Hans and en-US
collect recognized strings and confidence
pass OCR only if every --expect-text appears in Vision-recognized joined text
use UI tree text only as corroborating evidence in the JSON; never use UI tree text to satisfy the OCR hard gate
measure approximate contrast using sampled luminance over text-heavy crops:
  context top band
  dialogue band
  card/title band
  mic dock band
contrast hard gate:
  body text estimated contrast >= 4.5
  large display text estimated contrast >= 3.0
SSIM evidence:
  if anchor provided, compute simple luminance SSIM or call a helper function inside this script
  if no anchor exists, record "ssim_status": "not_run_missing_anchor", exit non-zero in strict mode, and keep the package PARTIAL
output JSON fields:
  case_id
  ocr_verdict: PASS|FAIL
  expected_texts
  recognized_texts
  contrast_verdict: PASS|FAIL
  contrast_samples
  ssim_status
  ssim_value
  proof_class: "l2_readability_regression_evidence"
  claims_not_made
exit 1 if OCR or contrast fails
```

如果本机跑不了 Vision OCR，不得只用 UI tree 伪造 OCR。按下面格式停下：

```text
blocked at Stage 3 after attempts swift-vision-ocr/xcode-framework-probe/ui-tree-fallback; only missing runnable OCR engine for L2 hard gate
```

- [ ] **步骤 2：定义每个用例的 expected texts**

最低 OCR 预期文本：

```text
main_cooling_deep_space: 制冷, 26, 按住说话
main_heating_ivory: 制热, 28, 按住说话
safety_refusal_ivory: 安全, 行驶中, 按住说话
capsule_video_loop_deep_space: 雨, 夜间, 制冷
u17_golden_path_deep_space: 制冷, 26, 按住说话
```

- [ ] **步骤 3：逐用例运行 L2**

```bash
cd /Users/wanglei/workspace/MAformac-uiue
swift Tools/checks/check-8c2-l2-readability.swift \
  --case main_cooling_deep_space \
  --image docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/l0/main_cooling_deep_space-simctl.png \
  --ui-tree docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/l0/8c2-main_cooling_deep_space-ui-tree.txt \
  --anchor docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/anchors/main_cooling_deep_space-anchor.png \
  --expect-text 制冷 \
  --expect-text 26 \
  --expect-text 按住说话 \
  --output docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/l2/main_cooling_deep_space.json
```

对每个必需用例按对应 expected texts 重复运行。

- [ ] **步骤 4：新增 package checker**

创建 `Tools/checks/check-8c2-l2-package.py`，必需检查：

```text
input: evidence dir
for every required case:
  l2/{case_id}.json exists
  ocr_verdict == PASS
  contrast_verdict == PASS
  proof_class == l2_readability_regression_evidence
  recognized_texts is non-empty
  contrast_samples is non-empty
  ssim_status is one of PASS, WARN
if any required case fails OCR or contrast, exit 1
if any required case has ssim_status == not_run_missing_anchor, exit 1 unless the caller explicitly passes --allow-partial
write l2/l2-summary.json with aggregate status
print PASS: 8.C2 L2 package is complete
```

- [ ] **步骤 5：运行 L2 package checker**

```bash
cd /Users/wanglei/workspace/MAformac-uiue
python3 Tools/checks/check-8c2-l2-package.py docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance
```

预期：
- prints `PASS: 8.C2 L2 package is complete`
- if OCR/contrast fails, do not proceed to mark 8.C2 complete

- [ ] **步骤 6：更新 lessons**

Append to `LESSONS.md`:

```markdown
## 阶段 3

- proof_class_added: l2_readability_regression_evidence
- ocr_cases: write PASS/FAIL by case
- contrast_cases: write PASS/FAIL by case
- ssim_status: write PASS/WARN/PARTIAL by case
- tools_rechecked: Apple Vision OCR path, Tools/skills accessibility/contrast references if used
- not_claimed: L3, V-PASS, true_device, mobile
```

## 任务 4：L3 人工 5-Gate 模板与收口规则

**文件:**
- Create: `/Users/wanglei/workspace/MAformac-uiue/docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/l3/human-5gate-verdict.md`
- Create: `/Users/wanglei/workspace/MAformac-uiue/docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/README.md`
- Modify only if closure is authorized by磊哥: `/Users/wanglei/workspace/MAformac-uiue/openspec/changes/ui-presentation/tasks.md`
- Modify: `/Users/wanglei/workspace/MAformac-uiue/docs/grill-checklist/uiue-a2-grill-coverage-index.md`

**接口:**
- 消费：
  - L0 package checker result
  - L1 summary
  - L2 summary
  - 磊哥 L3 verdict
- 产出：
  - L3 signed or pending verdict file
  - README receipt
  - optional `8.C2` task closure only when allowed

- [ ] **步骤 1：写 L3 模板**

创建 `l3/human-5gate-verdict.md`：

```markdown
# UIUE 8.C2 L3 Human 5-Gate Verdict

captured_at: write the exact UTC timestamp used for the L3 review
reviewer: 磊哥
verdict: PENDING
allowed_values: V-PASS | V-PASS_WITH_NOTES | PARTIAL | FAIL

## 已审阅证据

- L0 manifest: ../package-manifest.json
- L1 summary: ../l1/l1-summary.tsv
- L2 summary: ../l2/l2-summary.json
- screenshots:
  - ../l0/main_cooling_deep_space-simctl.png
  - ../l0/main_heating_ivory-simctl.png
  - ../l0/safety_refusal_ivory-simctl.png
  - ../l0/capsule_video_loop_deep_space-simctl.png
  - ../l0/u17_golden_path_deep_space-simctl.png

## 5-Gate 检查表

1. 米白主题可读性和质感：PENDING
2. 深空主题可读性和质感：PENDING
3. 连续舞台无黑线、断层、明显错位：PENDING
4. 制冷、制热、安全拒识三类语义能一眼区分：PENDING
5. capsule diorama / Liquid Glass / Reduce Motion 不抢主信息、不造成演示风险：PENDING

## 人工备注

- PENDING

## 收口规则

- Only 磊哥 may change `verdict`.
- `V-PASS` may close `8.C2`.
- `V-PASS_WITH_NOTES` may close `8.C2` only if 磊哥 explicitly says notes are non-blocking and authorizes closure.
- `PARTIAL`, `FAIL`, or `PENDING` must leave `8.C2` open.
- This file does not claim `mobile`, `true_device`, or real runtime readiness.
```

- [ ] **步骤 2：缺 L3 时按 pending 停下**

If磊哥 has not supplied a verdict in this execution thread, do not edit `tasks.md`. Final verdict must be:

```text
verdict: PARTIAL_PENDING_L3
reason: L0/L1/L2 evidence package is present, but only 磊哥 can sign L3 and V-PASS.
tasks.md: 8.C2 remains open
```

- [ ] **步骤 3：如果已有 L3 verdict，应用收口规则**

Allowed updates:

```text
if verdict == V-PASS:
  mark 8.C2 checked in openspec/changes/ui-presentation/tasks.md
if verdict == V-PASS_WITH_NOTES and 磊哥 explicitly authorizes closure:
  mark 8.C2 checked and preserve notes in README
if verdict == PARTIAL or FAIL:
  keep 8.C2 open
```

- [ ] **步骤 4：写 README receipt**

创建 `README.md`，内容包括：

```markdown
# UIUE 8.C2 L0-L3 Visual Acceptance Evidence Package

## 结论

- status: write one of DONE, PARTIAL_PENDING_L3, PARTIAL, FAIL
- 8.C2 tasks.md state: write open or checked
- L3 verdict: write one of V-PASS, V-PASS_WITH_NOTES, PARTIAL, FAIL, PENDING

## 证据

- L0: package-manifest.json + l0/*.json + on-screen simctl screenshots
- L1: l1/l1-summary.tsv
- L2: l2/l2-summary.json
- L3: l3/human-5gate-verdict.md

## 复跑

```bash
cd /Users/wanglei/workspace/MAformac-uiue
Tools/checks/capture-8c2-l0-evidence.sh
python3 Tools/checks/check-8c2-l0-evidence.py docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance
python3 Tools/checks/phase2_zone_compare.py --self-check
python3 Tools/checks/check-8c2-l2-package.py docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance
openspec validate ui-presentation --strict
```

## 未声明事项

- No true-device proof
- No mobile proof unless separately added later
- No real NLU / ASR / TTS / LoRA / backend readiness
- No App Store / TestFlight / external customer release readiness
- No projection / AirPlay / 1080p external display validation
```

- [ ] **步骤 5：更新 grill checklist**

Append one receipt row to `docs/grill-checklist/uiue-a2-grill-coverage-index.md` with:

```text
8.C2 L0-L3 visual acceptance package | evidence dir docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance | L0/L1/L2/write actual L3 state | residual write exact residual
```

Do not edit `docs/grill-tournament/**` unless the execution discovers a new grill decision, not merely evidence.

## 任务 5：验证、Subagent Codex 审计、修复、提交

**文件:**
- Create: `/Users/wanglei/workspace/MAformac-uiue/docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/audit/subagent-codex-audit.md`
- Modify as needed only to fix audit findings within this plan scope.

**接口:**
- 消费：all package artifacts and validation output。
- 产出：audited commit or audited PARTIAL report。

- [ ] **步骤 1：先跑必需验证**

```bash
cd /Users/wanglei/workspace/MAformac-uiue
swift test --filter U17GoldenPathManifestTests
UIUE_8C2_CASE_ID=main_cooling_deep_space \
UIUE_8C2_EVIDENCE_DIR=docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/l0 \
xcodebuild test \
  -project MAformac.xcodeproj \
  -scheme MAformacIOS \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -only-testing:MAformacIOSUITests/UIC2VisualAcceptanceUITests/testVisualAcceptanceCaseLaunchesAndCapturesUITree
Tools/checks/capture-8c2-l0-evidence.sh
python3 Tools/checks/check-8c2-l0-evidence.py docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance
python3 Tools/checks/phase2_zone_compare.py --self-check
python3 Tools/checks/check-8c2-l2-package.py docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance
swift test
make verify-all
openspec validate ui-presentation --strict
git diff --check
git diff --cached --check
```

如果 `iPhone 17 Pro Max` 缺失但 `iPhone 17 Pro` 存在，用 fallback 重跑 XCUITest 和 capture harness，并在每个 L0 JSON 记录真实设备。不得静默改写 device name。

- [ ] **步骤 2：最终回写前安排 subagent Codex read-only 审计**

使用独立 subagent Codex，发送以下 prompt：

```text
请在 /Users/wanglei/workspace/MAformac-uiue 做 read-only 审计，不要改文件。

范围：UIUE 8.C2 L0-L3 visual acceptance evidence package。

审计对象：
- docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/
- Tools/checks/capture-8c2-l0-evidence.sh
- Tools/checks/check-8c2-l0-evidence.py
- Tools/checks/check-8c2-l2-readability.swift
- Tools/checks/check-8c2-l2-package.py
- MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift
- openspec/changes/ui-presentation/tasks.md
- docs/grill-checklist/uiue-a2-grill-coverage-index.md

硬审计问题：
1. L0 screenshots 是否全部来自 on-screen `xcrun simctl io booted screenshot`，不是 Preview/ImageRenderer/XCTAttachment/static snapshot？
2. 每个 L0 manifest 是否含 device、launchArg、theme、ui_tree_evidence、screenshot_path、proof_class？
3. L1 是否只输出 PASS/WARN/FAIL，且没有把 RMSE 当审美裁判？
4. L2 是否真的有 OCR+contrast hard gate，SSIM 只作为 evidence，LPIPS 没被引入？
5. L3 是否只有磊哥能签，缺 L3 时 `8.C2` 是否保持 open？
6. 是否误声明 mobile/true_device/V-PASS/A-2 complete/runtime/backend/voice/model ready？
7. 是否误触旧 untracked visual evidence dirs 或用了 `git add .`？
8. 是否按本次派单要求回顾 Tools/、Tools/skills、经验教训、pre-mortem，并更新 LESSONS.md？

中文返回格式：
- verdict: PASS | FINDINGS | BLOCKED
- findings ordered by severity with file:line
- evidence table
- confidence
- touched paths: none
- residual risk
```

- [ ] **步骤 3：修复审计 findings**

Controller 必须修复 scope 内所有 `P0/P1/P2` finding。如果 finding 需要磊哥 L3 输入，不得伪造；保持 `8.C2` open，并回报 `PARTIAL_PENDING_L3`。

- [ ] **步骤 4：审计修复后重跑验证**

修复任何 audit finding 后，必须重跑所有可能受改动影响的验证。如果不确定，重跑下面 full gate。不得用审计前验证结果覆盖审计后代码、脚本或证据。

```bash
cd /Users/wanglei/workspace/MAformac-uiue
swift test --filter U17GoldenPathManifestTests
UIUE_8C2_CASE_ID=main_cooling_deep_space \
UIUE_8C2_EVIDENCE_DIR=docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance/l0 \
xcodebuild test \
  -project MAformac.xcodeproj \
  -scheme MAformacIOS \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
  -only-testing:MAformacIOSUITests/UIC2VisualAcceptanceUITests/testVisualAcceptanceCaseLaunchesAndCapturesUITree
Tools/checks/capture-8c2-l0-evidence.sh
python3 Tools/checks/check-8c2-l0-evidence.py docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance
python3 Tools/checks/phase2_zone_compare.py --self-check
python3 Tools/checks/check-8c2-l2-package.py docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance
swift test
make verify-all
openspec validate ui-presentation --strict
git diff --check
git diff --cached --check
```

如果 audit 后没有任何文件改动，在最终 receipt 记录 `post-audit validation reused: yes, reason: no file changes after read-only audit`。

- [ ] **步骤 5：只 stage owned files**

只使用显式路径：

```bash
cd /Users/wanglei/workspace/MAformac-uiue
git add \
  MAformacIOSUITests/UIC2VisualAcceptanceUITests.swift \
  Tools/checks/capture-8c2-l0-evidence.sh \
  Tools/checks/check-8c2-l0-evidence.py \
  Tools/checks/check-8c2-l2-readability.swift \
  Tools/checks/check-8c2-l2-package.py \
  docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance \
  docs/grill-checklist/uiue-a2-grill-coverage-index.md
```

只有 L3 收口规则授权勾选 `8.C2` 时，才 add `openspec/changes/ui-presentation/tasks.md`。

- [ ] **步骤 6：提交**

如果 L3 已签且 `8.C2` 可以关闭：

```bash
git commit -m "test(uiue): close 8c2 visual acceptance package"
```

如果 L0-L2 通过但 L3 仍 pending：

```bash
git commit -m "test(uiue): add 8c2 visual acceptance evidence package"
```

- [ ] **步骤 7：最终中文 verdict**

返回：

```text
verdict: DONE | PARTIAL_PENDING_L3 | PARTIAL | FAIL | BLOCKED
commit sha: write the actual commit sha if committed; write none if no commit was made

changed files:
- write each changed path with line reference and what changed

validation:
- write each validation command with PASS/FAIL and key result

proof class:
- local
- unit
- XCUITest
- simulator_l0_runtime_truth
- l1_sentinel
- l2_readability_regression_evidence
- l3_human_5gate only if 磊哥 signed

residual risks:
- no true_device unless separately captured
- no mobile unless separately captured
- no real NLU/ASR/TTS/LoRA/backend readiness
- 8.C2 remains open if L3 is PENDING/PARTIAL/FAIL

exact remaining tasks:
- write exact remaining tasks, or write none if no task remains in scope
```

## 自检

- Spec 覆盖：L0 fields、L1 PASS/WARN/FAIL、L2 OCR/contrast/SSIM、L3 human enum、no simulator auto-upgrade to V-PASS 均已映射到任务。
- Scope 覆盖：覆盖 continuous stage、cooling/heating thermal state、safety refusal、capsule diorama、deepSpace/ivory、U17 golden path reference。
- 派单要求：包含 repeated lessons updates、Tools/skills review cadence、pre-mortem use、screenshot compare/harness、no downgrade/no overengineering、final writeback 前 subagent Codex audit。
- No fake-green 规则：缺 L3 强制 `PARTIAL_PENDING_L3`；L1/L2 failure 阻止 8.C2 closure。
- No-touch 规则：旧 untracked visual evidence dirs 已明确排除。
