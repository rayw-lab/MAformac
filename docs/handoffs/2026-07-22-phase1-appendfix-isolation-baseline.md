---
kind: handoff
as_of: 2026-07-22
predecessor: docs/handoffs/2026-07-21-phase0-1a-1b-remediation-complete.md
supersedes: none
authority: Phase1-AppendFix isolation baseline
phase2_authorization: wp2-1-dataflow-only
---

# Phase1-AppendFix 隔离后基线

## 当前产品边界

- 客户正向目录仅含精确话术「打开空调」与 18–32 整数调温模板。
- mounted D-domain 工具严格为 `adjust_ac_temperature_to_number`、`close_ac`。
- App 客户文本入口只走 `DemoSliceRoute` 的有限 literal 路径；App、runner、Makefile 无 live model backend 注入。
- 车窗、氛围灯、座椅、尾门、十族扩张、自然改写模型门、ASR 与多意图均未准入。
- `actionDemoProven=0/120`。治理绿灯、测试数量与隔离归档不构成产品验收。

## 越界实验隔离

完整归档与可逆恢复依据位于 run root：

- `isolation/phase2-phase3-quarantine-20260722/full-snapshot-receipt.json`
- `isolation/phase2-phase3-quarantine-20260722/post-isolation-negative-assertions.json`
- `isolation/phase2-phase3-quarantine-20260722/deepseek-boundary-inventory.md`
- `isolation/phase2-phase3-quarantine-20260722/full-untracked-files.manifest.json`
- `isolation/phase2-phase3-quarantine-20260722/full-untracked-files.tar.gz`
- `isolation/phase2-phase3-quarantine-20260722/full-tracked-working-tree.patch`

上述归档只用于取证与恢复；不得整包恢复到 live 产品路径。

## AF-G0 首轮结论与返修

首轮独立门审结论为 `NO-GO`：

1. fresh store 的 `ac.power=off`、主驾温度默认 24；首次输入「把空调调到24度」被 route 预检误判 `alreadyStateNoop`，绕过 C3 的隐式开机 transition。
2. `docs/CURRENT.md` 与权威演示脚本仍描述已隔离的十族、尾门与 model backend 路径。

返修动作：

- `Core/Execution/DemoSliceRoute.swift`：no-op 短路同时检查调温动作的隐式 `ac.power=on` 目标。
- `Tests/MAformacCoreTests/DemoSliceProductBehaviorGateTests.swift`：新增 fresh default 24 度回归，要求 runner=1、`ac.power=on`、mutation=1 与真实 readback。
- `docs/CURRENT.md`：改为隔离后两类空调行为基线。
- `docs/governance/demo-script-v1.md`：回退为 7 步空调脚本，删除十族、尾门、模型与香氛断网演示。

回归测试先复现 5 个断言失败，再在修复后通过；异源返修复审 verdict 为 `AF-G0 GO`，Phase2 WP2-1 数据流批次获准启动。TTS/ASR/真实音频不属于产品门。

## 发布门与 stopline

- E3「磊哥亲灌句 + 真实录像」仍为发布门；本 handoff 不声称已完成。
- 远端 required UI-E2E context 仍需独立证据；本 handoff 不声称已完成。
- AF-G0 已给 `GO`；Phase2 仅按 WP2-1 数据流批次启动，不获得发布授权。
- Phase2 只能按 Program WBS V10 的批次顺序推进；不得恢复十族/model/tailgate 归档。

## 权威外部产物

run root：`/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-17-s8-s9-successor-c-longrun/`

- `REMEDIATION-WBS-IMPLEMENTATION-PLAN.md`
- `PHASE1-APPENDFIX-IMPLEMENTATION-PLAN.md`
- `PHASE1-APPENDFIX-MAIN-THREAD-AUDIT-20260722.md`
- `isolation/phase2-phase3-quarantine-20260722/`
