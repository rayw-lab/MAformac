## Why

MAformac 当前缺少一个由 Core 单一 owner 维护的 session lifecycle 合同；cancel、terminal、child fence、checkpoint 与 recovery 语义分散，无法稳定表达 generation 单调、last reconciled stable recovery 以及 pending-plan resume 禁止。W8 carrier 现在只做 propose 写回，用已拍 M16-007/008/009 与 010a/010b 的边界把行为合同落入 OpenSpec；SEQ-001=A 明确 W8 不依赖 W5c DONE。

## What Changes

- 新增 session-lifecycle capability，定义单 owner lifecycle state machine、精确 transition、compound request serialization 与 immutable snapshot。
- 定义 child disposition closed set，包含 cancelled、terminal、unsupported、timedOutFenced，并规定 cancel fan-out、ack 或 timeout+fence 后才能进入新 session/generation。
- 定义 last reconciled stable checkpoint recovery、terminal/checkpoint/child-fence join、新 generation 与禁止 pending-plan resume。
- 记录 010a deterministic interleaving 仅为 profile_only / stress_profile_only，不满足 proof_runtime。
- 记录 010b 真实 process recipe provenance，recipe_only 直至真实 process receipt；unit/mock/fake 不得满足 proof_runtime。
- 物化两项 planned gate 合同及其 claim ceiling；verify-session-lifecycle-source 与 verify-session-lifecycle 在真实 checker、wiring、negative 与 materialization receipt 齐全前保持 PLANNED_GATE_NOT_YET_EXECUTABLE。
- 保留 W7 的 DialogueState window/retention/clear policy 边界、W9 的 force/reset write store 边界、W10 TTS 边界、W5c composition 边界与 V2 operator-pass 边界。

## Capabilities

### New Capabilities

- session-lifecycle：session identity、generation、terminal/child disposition、cancel fan-out、fence、checkpoint、recoveryReady 与 proof-cap 的可观察行为合同。

### Modified Capabilities

- None.

## Impact

- 新增 OpenSpec carrier：openspec/changes/define-t09-session-lifecycle-recovery/。
- 仅新增 proposal、design、session-lifecycle spec、tasks 与 .openspec.yaml carrier 文件；本单不改 Swift、Core、App、Makefile、registry、active tool-execution 或实现代码。
- S0 必须把 canonical seed 展开为全量 ADDED Requirements 与 GIVEN/WHEN/THEN scenarios，并在 strict validate rc0 前保持 structure incomplete。
- 010a dependency pins 只允许在 test-only seam 中使用；默认路径为 protocol + FakeClock 或 TestClock，不引入 swift-dependencies。
- 010b recipe 引用 RECIPE-REAL-PROCESS-HARNESS sha256 93c7623846cc7d407ec120ad926620d24f2bc1f5893b7dae2baca41c8ced20ed，但不把 recipe_only 写成 proof satisfied。

## Non-goals

- 不实现 session lifecycle coordinator、App seam、runtime runner、checker、Makefile target、gate materialization 或任何 Swift/Python 业务代码。
- 不修改 W7 DialogueState policy、W9 force/reset write store、W10 TTS、W5c default backend/composition root、V2 operator-pass 或 registry 边。
- 不把 010a profile_only、010b recipe_only、unit/mock/fake、planned gate 或 OpenSpec strict 绿写成 proof_runtime、gate green、W8 DONE、operator-pass、V-PASS、mobile、true-device 或 live proof。
- 不引入第二 lifecycle owner，不允许 pending-plan resume，不允许 old-generation stale mutation 被应用。
- 不做 /opsx:apply、coding、merge、push、package state flip、V7/A5/S8 授权或状态翻转。

## Success Criteria

- openspec validate --all --strict rc0，且 openspec validate --strict 对本 change rc0。
- specs/session-lifecycle/spec.md 含全量 ADDED Requirements 与可观察 GIVEN/WHEN/THEN scenarios，覆盖 M16-007/008/009、010a/010b 及 owner-boundary SHALL NOT。
- design.md 保留主链路、single-owner/fence/recovery 的 Architecture Decisions、010a profile 与 010b recipe 的 proof-class 分离、两门 planned 条件与 risk/stopline。
- tasks.md 将 S0–S9 拆为独立产出与验收项，并把 coding、两门物化、GitNexus、真实 process 与另键事项保持为 future/blocked，不提前勾选。
- W8 change 不引入 W5c DONE 前置；W7、W9、W10、V2 边界未被吞并。
- 完成 carrier 写回后的 pair receipt、plan SUPERSEDED_BY_CARRIER flip 与本地 commit；不执行 push。
