# PHASE2-G4-KNIFE3-APP-TASK-HANDLE-CLOSEOUT

- **Worker**: gw-deepseek-v4-flash（DeepSeek V4 Flash · G4 刀3 收口）
- **Date**: 2026-07-23
- **Subject**: App ingress `Task` handle ownership + lease cascade（Composition 持柄 / preempt / lease→runner）
- **Product SHAs**:
  - `b11184fd` — knife3 主落地：`ingressRouteTask` + `scheduleIngressRoute` + ContentView 去匿名 Task + lease 经 `DemoSliceRoute`→runner
  - `a4924a81` — Gemini 残留补丁：Task **完成后** `defer` 清空 handle；`Task.isCancelled` 时不抹后继
- **Tip at closeout (may include non-product reanchor)**: live `git rev-parse HEAD`；本 closeout **不**把 reanchor/closure 记为产品完成证明
- **No push**

## Done

1. **Composition 持 Task handle**
   - `FrontstageRuntimeComposition.ingressRouteTask`
   - `scheduleIngressRoute(...)` 为客户路径唯一调度入口

2. **Preempt 顺序（Gemini cancel/isCurrent 原子）**
   1. `ingressRouteTask?.cancel()` → nil
   2. `markCurrent(turn)`（先切 identity / lease capability）
   3. `speech.cancelPendingSpeech()`（只杀旧 turn 语音）
   4. 新 Task：签发 `RuntimeTurnLease` → `routeDemoSlice` → runner doors

3. **完成后清空 handle**
   - Task body `defer { if !Task.isCancelled { self.ingressRouteTask = nil } }`
   - 避免 preempt 后继被完成路径误清

4. **ContentView**
   - `submitCustomerIngress` 只调 `frontstageRuntimeComposition.scheduleIngressRoute`
   - 无匿名 `Task { @MainActor ... routeDemoSlice }`

5. **Lease 下传**
   - Composition 签发 lease（`isCurrent` → `currentTurnID == trimmedTurnID`）
   - `DemoSliceRoute.route(..., lease:)` → `DemoRuntimeSessionRunner.run(..., lease:)`
   - **未改 C3**

## Verification（亲跑）

```text
swift test --filter 'TurnLeaseCancellationTests|FrontstageContainmentSourceContractTests|ProductOperatorCompositionRootTests|SessionLifecycleCompositionGateTests'
```

- **exit_code**: `0`
- **Executed**: 30 tests, 0 failures
  - `TurnLeaseCancellationTests` 13
  - `FrontstageContainmentSourceContractTests` 7
  - `ProductOperatorCompositionRootTests` 4
  - `SessionLifecycleCompositionGateTests` 6
- **evidence log sha256**: `4f2e16e68dbbe73e516d82622b68a38868e85b2082b62c9c16b71884df9476d1`（`/tmp/g4-knife3-evidence/swift-test.log`）

## Non-claims

- 不声称 G4 COMPLETE / 刀4 完成 / full suite 绿 / UI-E2E 绿
- 不抬 `actionDemoProven`；不演示/合并后三族 candidate
- 不改 protected；不改 C3；不把 reanchor/closure 卷进本 closeout 产品声明
- GitNexus impact：索引未收录 `scheduleIngressRoute`（stale → UNKNOWN）；未宣称 blast-radius PASS

## 刀4 建议（handoff）

1. 补齐 `TurnLeaseCancellationTests` 场景收口：双 ingress 竞态（后发 wins）、cancel 后零 mutation/零 TTS、lease stale 跨 await 门
2. G4 smoke 聚合（source contract + Door-1/Door-2 + App preempt 顺序）单一 filter/recipe
3. 仍禁抬 proven / 禁演示；G5 作战包待 G4 COMPLETE 后开工
