# Lens 06 — Presentation Truth

- 日期：2026-07-21
- 席位：frontend-worker / Kimi K3
- transcript：`history://PresentationTruth`
- 结构化输出：`agent://PresentationTruth`

## Finding

1. ROB-1 生产链真修：speech enqueue 结果驱动 runner orb，payload 传递，ContentView 消费。
2. WP1a-2 验收仍主要依赖源码字符串扫描；把 orb 判定改回旧 bug，现有关键扫描门仍可能绿。
3. `ContentView.swift:621` 在 demo-slice 路径固定 `voiceState: .speaking`，TTS 失败时与诚实 orb 冲突。
4. `ContentView.swift:628` 固定 `mutation=1`，already-state no-op 仍显示执行和 mutation。
5. payload v1 新增 orbState，但 strict consumer/schema/fixtures 未同步；删除 fixture tests 后失去形状/manifest 门。
6. UI E2E tests 主要断 status/proof，不覆盖 orb/voice/TTS；且 Make 判分器能吞测试失败。

## 边界

生产 redaction 和 partial projection 代码仍存在；问题是回归可见性和协议一致性下降，不是当前所有行为立即失守。
