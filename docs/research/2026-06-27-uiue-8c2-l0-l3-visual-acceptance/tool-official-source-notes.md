# 8.C2 工具与官方来源核验笔记

日期：2026-06-27
repo_head：`aef42d8`

## 本地工具真态

- `Tools/agent-platform-plugin-refs/README.md`：本 worktree iOS 默认配置为 `MAformac.xcodeproj` / `MAformacIOS` / `iPhone 17 Pro Max`，并要求优先使用本 worktree dedicated simulator。
- `.xcodebuildmcp/README.md`：同样确认 profile=`ios`、project=`/Users/wanglei/workspace/MAformac-uiue/MAformac.xcodeproj`、scheme=`MAformacIOS`、simulator=`iPhone 17 Pro Max`。
- `Tools/skills/ios-simulator-skill/SKILL.md`：推荐优先用 accessibility tree 做导航，截图只用于 visual verification / bug reports / visual diff；与本轮“UI tree 佐证、simctl 截图作 L0”一致。
- `Tools/agent-platform-plugin-refs/build-ios-apps-skills/ios-debugger-agent/SKILL.md`：确认 simulator build/install/launch/UI tree/screenshot 的操作边界。
- `xcodebuild -version`：`Xcode 26.5 (17F42)`。
- `xcrun simctl io help`：当前本机 `simctl io booted screenshot screenshot.png` 示例存在；`screenshot` 支持 PNG，作为本轮 L0 on-screen 截图命令。

## Apple 官方资料核验

- XCTest `XCUIApplication.launchArguments`：Apple Developer Documentation 说明 UI test 可设置 app launch arguments；本轮使用 `-mockSnapshot`、`-mockTheme`、`-contextCapsuleRoute`、`-goldenPathID` 冻结入口。
  来源：https://developer.apple.com/documentation/xctest/xcuiapplication/launcharguments
- XCTest/Xcode 测试运行：Apple Xcode 文档覆盖通过 Xcode/xcodebuild 运行与解释测试结果；本轮保留真实 `MAformacIOSUITests` target，不用 SwiftPM/unit 冒充 UI test。
  来源：https://developer.apple.com/documentation/xcode/running-tests-and-interpreting-results
- Accessibility identifier：Apple `UIAccessibilityIdentification.accessibilityIdentifier` 用于 UI 自动化稳定定位；本轮 L0 UI tree 佐证依赖既有 `context-band`、`demo-orb`、`vehicle-card-family.*` 等 identifiers。
  来源：https://developer.apple.com/documentation/uikit/uiaccessibilityidentification/accessibilityidentifier
- Vision OCR：Apple `VNRecognizeTextRequest` 是 Vision 文本识别 API；本轮 L2 OCR 使用该 API，UI tree 只能佐证，不能替代 OCR。
  来源：https://developer.apple.com/documentation/vision/vnrecognizetextrequest
- Simulator command-line interaction：Apple Simulator Guide 记录可用 `xcrun simctl io booted screenshot screenshot.png` 进行命令行截图；本轮 L0 采用 on-screen `simctl io booted screenshot`。
  来源：https://developer.apple.com/library/archive/documentation/IDEs/Conceptual/iOS_Simulator_Guide/InteractingwiththeiOSSimulator/InteractingwiththeiOSSimulator.html

## Adopted Decision

- 采用真实 `xcodebuild test` + `MAformacIOSUITests` 捕获 UI tree，然后用 `xcrun simctl launch` 启动同一 launchArg 态并执行 on-screen `xcrun simctl io booted screenshot`。
- `XCTAttachment`、Preview、ImageRenderer、静态 mock snapshot 不进入 L0 字段。
- `VNRecognizeTextRequest` 失败时不降级为 UI tree OCR；必须显式 FAIL/PARTIAL。
- 本轮不使用 `serve-sim` 浏览器镜像作为 proof class；它可做观察，但不能替代计划要求的 `simctl io` L0 包。
