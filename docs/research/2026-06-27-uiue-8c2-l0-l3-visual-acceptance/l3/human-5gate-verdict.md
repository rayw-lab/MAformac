# 8.C2 L3 人工 5-gate 待签模板

日期：2026-06-27
scope：仅 `8.C2` visual-acceptance L3
当前状态：`PENDING`

## 可选 verdict enum

- `V-PASS`
- `V-PASS_WITH_NOTES`
- `PARTIAL`
- `FAIL`

## 签核边界

- 只有磊哥可以签 `V-PASS`。
- L0/L1/L2 自动化证据不能升级为 `V-PASS`、`mobile`、`true_device` 或 `A-2 complete`。
- 未完成本文件人工签核前，最终 closeout 最高只能是 `PARTIAL_PENDING_L3`，`openspec/changes/ui-presentation/tasks.md` 的 `8.C2` 保持 open。

## 5-gate 人审项

| gate | 场景 | L0 截图 | L1 | L2 | 人工 verdict | notes |
|---|---|---|---|---|---|---|
| 1 | `main_cooling_deep_space` 深空制冷主舞台 | `../l0/main_cooling_deep_space-simctl.png` | `WARN` | `PASS` | `PENDING` | L1 `WARN` 只表示 sentinel 差异，非审美失败。 |
| 2 | `main_heating_ivory` 米白制热主舞台 | `../l0/main_heating_ivory-simctl.png` | `WARN` | `PASS` | `PENDING` | 需人工看米白主题高级感和可读性。 |
| 3 | `safety_refusal_ivory` 米白安全拒绝 | `../l0/safety_refusal_ivory-simctl.png` | `PASS` | `PASS` | `PENDING` | 需人工看安全话术权重、视觉警示不过度。 |
| 4 | `capsule_video_loop_deep_space` 深空 capsule videoLoop | `../l0/capsule_video_loop_deep_space-simctl.png` | `WARN` | `PASS` | `PENDING` | L1 anchor 只证全屏未塌陷，不证 videoLoop 细节。 |
| 5 | `u17_golden_path_deep_space` U17 黄金路径 | `../l0/u17_golden_path_deep_space-simctl.png` | `PASS` | `PASS` | `PENDING` | 只代表 simulator L0 golden path，不是真机。 |

## 签核记录

- 签核人：待磊哥填写
- 签核时间：待填写
- 最终 verdict：`PENDING`
- 是否允许勾选 `8.C2`：否
- 备注：待填写
