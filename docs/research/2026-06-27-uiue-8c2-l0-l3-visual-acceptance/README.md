# UIUE 8.C2 L0-L3 视觉验收证据包

日期：2026-06-27
repo head at capture：`aef42d8`
scope：仅 `8.C2 visual-acceptance L0-L3`
verdict：`PARTIAL_PENDING_L3`
proof class：`simulator_l0_runtime_truth` + `local_l1_l2_checker`；L3 待磊哥人工签核

> 2026-06-27 L3 人审更新：磊哥在可见 simulator UI 上发现 `cooling + ivory` 视觉与交互阻断问题（空调渐变语义不足、玻璃质感不足、氛围灯 8 色选择崩溃、空调模式点击制热后外层仍蓝色、多个 badge/toggle 控件存在假交互/contract 外值风险）。该发现证明本包 L0-L2 不能升级为 L3；8.C2 继续 open，修复后仍需重新人审。

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
- `python3 Tools/checks/phase2_zone_compare.py --self-check`：待最终验证。
- `python3 Tools/checks/check-8c2-l2-package.py docs/research/2026-06-27-uiue-8c2-l0-l3-visual-acceptance`：PASS（默认只读校验；只有 `--write-summary` 会重写 summary）。
- `xcodebuild test -project /Users/wanglei/workspace/MAformac-uiue/MAformac.xcodeproj -scheme MAformacIOS -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:MAformacIOSUITests/UIC2VisualAcceptanceUITests`：PASS，8 tests / 0 failures，覆盖空调制热外层联动、氛围灯 8 色选择不崩、座椅按摩 contract 选项和 5 个 L0 UI tree case。

## R0 返修边界补记

- 已修/已验证：`cooling + ivory` 颜色语义增强、内容卡自研玻璃层次增强、空调制热/制冷联动、氛围灯 8 色选择不崩、badge/toggle/options/readback 写回路径回归。
- 未声明完成：直接触摸挡位仍未在本轮实现；当前 `vehicle.gear` 仍按只读仪表处理，后续应进入 Interaction Integrity `SHOULD_GRILL` 决策和实现范围。
- 8.C2 状态：仍 open；本轮只提供 local/unit/simulator UI 回归，不替代 L3 人审。

最终提交前仍需跑完整计划验证门和独立 read-only 审计。

## Non-Claims

- 不声明 `mobile`。
- 不声明 `true_device`。
- 不声明 L3 已签。
- 不声明 `V-PASS`。
- 不声明 `A-2 complete`。
- 不关闭 `8.C2`。
