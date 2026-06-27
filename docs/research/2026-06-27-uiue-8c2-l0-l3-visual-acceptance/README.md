# UIUE 8.C2 L0-L3 视觉验收证据包

日期：2026-06-27
repo head at capture：`aef42d8`
scope：仅 `8.C2 visual-acceptance L0-L3`
verdict：`PARTIAL_PENDING_L3`
proof class：`simulator_l0_runtime_truth` + `local_l1_l2_checker`；L3 待磊哥人工签核

> 2026-06-27 L3 人审更新：磊哥在可见 simulator UI 上发现 `cooling + ivory` 视觉与交互阻断问题（空调渐变语义不足、玻璃质感不足、氛围灯 8 色选择崩溃、空调模式点击制热后外层仍蓝色、多个 badge/toggle 控件存在假交互/contract 外值风险）。后续又发现验证设备/树漂移（工具 profile 曾指向 main tree + `iPhone 17 Pro`）、氛围灯亮度圆圈触摸假 affordance、环形控件点按/拖拽方向不符合用户预期、stepper 分段条点按语义不区分左右。该发现证明本包 L0-L2 不能升级为 L3；8.C2 继续 open，修复后仍需重新人审。当前磊哥仍在体验，未签 L3。

## 结论

本证据包已完成 L0/L1/L2 机器与本地证据：

- L0：5 个场景均为 on-screen `xcrun simctl io booted screenshot`，并含 `device`、`launchArg`、`theme`、`ui_tree_evidence`、`screenshot_path`、`proof_class`。
- L1：5 个场景均完成 `PASS/WARN/FAIL` sentinel，结果为 2 `PASS` + 3 `WARN` + 0 `FAIL`；`WARN` 不签审美。
- L2：5 个场景均完成真实 `VNRecognizeTextRequest` OCR + contrast hard gate，SSIM 仅记录为 regression evidence；5 个场景均 `PASS`。
- L3：仍为 `PENDING`。只有磊哥可签 `V-PASS`。

因此 `8.C2` 不能勾选完成，不能声明 `V-PASS`、`mobile`、`true_device` 或 `A-2 complete`。

## Evidence Index

| layer | artifact | status | boundary |
|---|---|---|---|
| L0 | `l0/*.json` + `l0/*-simctl.png` + `l0/*-ui-tree.txt` | `PASS` | simulator on-screen screenshot only；UI tree 佐证字段，不替代 OCR/L3。 |
| L1 | `l1/l1-summary.tsv` + `l1/reports/*.tsv` | 2 `PASS` / 3 `WARN` / 0 `FAIL` | 只挡塌陷；不追 RMSE 分数，不签审美。 |
| L2 | `l2/*.json` + `l2/l2-summary.json` | `PASS` | OCR + contrast 是 hard gate；SSIM 是 evidence；UI tree 不能冒充 OCR。 |
| L3 | `l3/human-5gate-verdict.md` | `PENDING` | 只有磊哥可以签 `V-PASS`。 |

## Case Summary

| case | launchArg | theme | L1 | L2 | L3 |
|---|---|---|---|---|---|
| `main_cooling_deep_space` | `-mockSnapshot cooling -mockTheme deepSpace` | `deepSpace` | `WARN` | `PASS` | `PENDING` |
| `main_heating_ivory` | `-mockSnapshot heating -mockTheme ivory` | `ivory` | `WARN` | `PASS` | `PENDING` |
| `safety_refusal_ivory` | `-mockSnapshot safetyRefusal -mockTheme ivory` | `ivory` | `PASS` | `PASS` | `PENDING` |
| `capsule_video_loop_deep_space` | `-mockSnapshot cooling -mockTheme deepSpace -contextCapsuleRoute videoLoop` | `deepSpace` | `WARN` | `PASS` | `PENDING` |
| `u17_golden_path_deep_space` | `-goldenPathID uiue_g9b_ac_success_deep_space` | `deepSpace` | `PASS` | `PASS` | `PENDING` |

## Validation Snapshot

- `Tools/checks/capture-8c2-l0-evidence.sh`：PASS，生成 5 个 L0 on-screen simulator screenshot case。
- `python3 Tools/checks/check-8c2-l0-evidence.py docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance`：PASS。
- `python3 Tools/checks/phase2_zone_compare.py --self-check`：PASS（覆盖 PASS/WARN/FAIL 三类 sentinel 自检；不替代 L3 审美判断）。
- `python3 Tools/checks/check-8c2-l2-package.py docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance`：PASS（默认只读校验；只有 `--write-summary` 会重写 summary）。
- `xcodebuild test -project /Users/wanglei/workspace/MAformac-uiue/MAformac.xcodeproj -scheme MAformacIOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:MAformacIOSUITests/UIC2VisualAcceptanceUITests`：历史辅助 PASS，8 tests / 0 failures；该 proof 设备不是 UIUE 默认设备，不能作为最终 Pro Max proof。
- `mcp__xcodebuildmcp.session_set_defaults` 已把当前 profile 修正回 `/Users/wanglei/workspace/MAformac-uiue/MAformac.xcodeproj` + `MAformacIOS` + `iPhone 17 Pro Max`；`.xcodebuildmcp/config.yaml` 与 `README.md` 无 diff。
- `mcp__xcodebuildmcp.test_sim -- -only-testing:MAformacIOSUITests/UIC2VisualAcceptanceUITests`：PASS，14 tests / 0 failures，device=`iPhone 17 Pro Max`，覆盖 5 个 L0 UI tree case、空调制热外层联动、氛围灯 8 色选择不崩、氛围灯亮度圆圈 `62% -> 63%` 写回、环形控件空间点按（下方减小、左上增大）、环形控件顺/逆时针拖拽连续写回、stepper 分段条左/右点按减小/增大、10 族摘要卡可展开/收起、10 族代表控件 primary touch 写回并刷新摘要。xcresult：`/Users/wanglei/Library/Developer/XcodeBuildMCP/workspaces/MAformac-71f6fc684d4b/result-bundles/test_sim_2026-06-27T07-17-09-985Z_pid49604_1df591a6.xcresult`。
- `xcodebuild test -project /Users/wanglei/workspace/MAformac-uiue/MAformac.xcodeproj -scheme MAformacIOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -only-testing:MAformacIOSUITests/UIC2VisualAcceptanceUITests`：PASS，14 tests / 0 failures；xcresult：`/Users/wanglei/Library/Developer/Xcode/DerivedData/MAformac-bbjvhflnlnnawnfsgfgdicvjoora/Logs/Test/Test-MAformacIOS-2026.06.27_15-25-53-+0800.xcresult`。

## R0 返修边界补记

- 已修/已验证：`cooling + ivory` 颜色语义增强、内容卡自研玻璃层次增强、空调制热/制冷联动、氛围灯 8 色选择不崩、badge/toggle/options/readback 写回路径回归、环形控件空间点按/顺逆时针拖拽、stepper 分段条左右点按、10 族摘要卡展开/收起、10 族代表控件 primary touch 写回矩阵。
- 未声明完成：演绎控制台的 `vehicle.gear` 仍按 mock context/只读仪表处理，不把它悄悄升级为全局直接触摸档位控制；是否把 gear 纳入 Interaction Integrity 仍应进入 `SHOULD_GRILL` 决策。
- 8.C2 状态：仍 open；本轮只提供 local/unit/simulator UI 回归，不替代 L3 人审。

最终提交前仍需跑完整计划验证门和独立 read-only 审计。

## Non-Claims

- 不声明 `mobile`。
- 不声明 `true_device`。
- 不声明 L3 已签。
- 不声明 `V-PASS`。
- 不声明 `A-2 complete`。
- 不关闭 `8.C2`。
