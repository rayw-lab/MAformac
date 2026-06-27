# 8.C2 独立 Codex read-only 审计报告

日期：2026-06-27
scope：仅 `8.C2` L0-L3 visual acceptance 证据包
审计模式：read-only
verdict：`PASS_WITH_NOTES`

## Findings

| priority | finding | fix |
|---|---|---|
| P0 | 无 | 不适用 |
| P1 | 无 | 不适用 |
| P2 | `openspec/changes/ui-presentation/design.md` 旧实装 order 残留 `visual-acceptance（投屏 V10）`，与 AD-15 `投屏 DELETE` 冲突。 | 已改为 `visual-acceptance（L0-L3，手持环境；投屏 DELETE C0）`。 |
| P2 | `Tools/checks/check-8c2-l2-package.py` 默认重写 `l2-summary.json`，不适合作为 read-only checker。 | 已改为默认只读校验；仅 `--write-summary` 会重写 summary。 |

## Scope / No-Touch

- 未发现 `contracts/`、`generated/`、`App/`、`Core/` 改动。
- `openspec/changes/ui-presentation/tasks.md` 的 `8.C2` 保持 open。
- 旧 untracked visual evidence dirs 不纳入本轮 commit。

## Proof-Class Check

- 未发现把 simulator/local 写成 `mobile`、`true_device`、L3、`V-PASS` 或 `A-2 complete`。
- 本包继续保持 `PARTIAL_PENDING_L3`。

## Evidence Check

- L0：`device`、`launchArg`、`theme`、`ui_tree_evidence`、`screenshot_path`、`proof_class` 字段存在；截图来源为 on-screen `xcrun simctl io booted screenshot`。
- L1：5 case 为 2 `PASS` / 3 `WARN` / 0 `FAIL`；`WARN` 不签审美。
- L2：真实 `VNRecognizeTextRequest` OCR + contrast hard gate PASS，SSIM recorded。
- L3：`PENDING`，只有磊哥可签 `V-PASS`。

## Post-Fix Requirement

修复 P2 后需重跑受影响验证：`openspec validate ui-presentation --strict`、`python3 Tools/checks/check-8c2-l2-package.py ...`、`git diff --check`。
