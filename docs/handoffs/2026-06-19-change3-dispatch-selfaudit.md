# Handoff 2026-06-19 — change3 apply:pre-mortem + dispatch v2 + self-audit 闭环

> 注:本文件记录派工前的 pre-mortem/dispatch/self-audit 上下文。change3 实装完成后的证据与 closeout 见 `docs/handoffs/2026-06-19-change3-execution-contract-apply-closeout.md`。

## 一句话状态
change3 进 **apply**:磊哥拍 **E1b 解耦**(契约层纯 Swift + spike fixture,MLX runtime 接入拆出);dispatch v2(self-audit 回填 6 catch)**ready 派 Codex**;design/tasks 已对齐,`openspec validate` 通过。500 字 Codex 启动 prompt 已交付磊哥。

## 本 session 完成
1. **读齐 change3 契约 + spike 实测坑**(adopt 上游 parser / E1a content-fallback / 两层 decode / 错误枚举三态)。
2. **/pre-mortem(deep)** scout 直读 pin 3.31.3 源码 + oracle iOS 实证 → 3 层 catch:**源码锚点失效**(`JSONToolCallParser.swift` 不存在,并入 `ToolCallFormat.swift`)/ **命名漂移**(change1 `vehicle.ac.toggle` vs change2 `cabin.ac`)/ **iOS+MLX 全未验**(Simulator 必崩 [mlx#2605]+metallib+entitlement)。
3. **磊哥拍 E1b 解耦** ⭐:change3 = 纯逻辑契约层(spike 55 条 fixture 驱动,`swift test` 可跑,arguments **自定义 JSONValue 不 import 上游**);MLX runtime 接入(锁 format+消费实时事件)拆出独立 change,接入前先最小 iOS 真机冒烟。
4. **回写 change3 design/tasks**(E1b 解耦 + 锚点修正 + Risks T6/T7/T8/T9 + 范围拆分)。
5. **写 dispatch** → **派 subagent CC self-audit**(对抗)→ **6 catch 全成立**,辩证吸收回填成 **dispatch v2**:
   - C1 T7 命名漂移**三处**(+DemoActionExecutor+FastPathIntentEngine,只修一处执行链断)
   - C2 codegen 撞 Package exclude/红线 → **手动脚本+生成物 commit**(不用 plugin)
   - **C3/F4 挖更深**:核实 demo_guard **无 restraint 字段** → **DemoGuard 是 schema 门 ≠ 语义拒识门**,挡不住 N016/N017 restraint + N002 意图越界;真防线 = intent-routing/LoRA;修正 E1a「fallback 不恶化 G3」论证
   - C4 T5 fixture 实采 0 数组 → 合成豁免  · C5 frame 三字段映射链  · C6 N002 单列
6. **沉淀**:lessons §B15(DemoGuard schema 门边界)+ §G(apply self-audit 对抗 + 辩证吸收双层)。

## change3 状态
- dispatch v2 = `docs/dispatches/2026-06-19-define-execution-contract-apply.md`(自包含,冷启动可执行,6 catch 前置)
- design/tasks 对齐 E1b/T9;`openspec validate define-execution-contract` ✅ valid
- **待派 Codex 实装**(契约层,TDD,`swift test` 全绿)

## 待拍板 / 待办
- **派 Codex 实装 change3**(500 字启动 prompt 已给磊哥,贴 Codex 新窗口)
- 3 Open Question(不阻塞实装,后续拍):content-fallback 默认开/关 / R2-R3 无实际数据怎么办 / MLX runtime 接入 change 拆分粒度(独立 vs 并 voice)
- **CLAUDE §9 待同步**:line 104 还写「spike E3 是起手生死线 + arguments→JSONValue 留本 change(import MLXLMCommon 拖 Metal 栈)」—— 已被 E1b 反转(spike GO,自定义 JSONValue 不 import);建议下次小更新

## 关键机制
- **self-audit 双层**(本 session 高价值):① CC subagent 对抗审主线程 dispatch 找盲点 ② 主线程辩证核 subagent(不盲从,核引用,挖更深 catch)。
- pre-mortem reflex(scout 直读 pin 源码 + oracle 仅 CC subagent+WebSearch)。
- dispatch 模板 `docs/dispatches/_TEMPLATE.md`;codex §23 三硬约束(failure receipt / 实采 smoketest / table-driven error)。

## 🟡 demo 边界
不接真车;量产标准(ISO26262/端云/QPS)豁免;安全门思想/参数规划/读 mock 态/LoRA 保留。

## 起手读
CLAUDE.md → 本 handoff → `docs/dispatches/2026-06-19-define-execution-contract-apply.md` → `openspec/changes/define-execution-contract/design.md`(Risks T1-T9 + E1a/E1b)→ `docs/lessons-learned.md` §B15/§G。

## 环境
M5 + Swift 6.3.2;iOS 26.5 Simulator ready;Xcode 解 metallib(但 change3 契约层 `swift test` 不需);spike 隔离包 `dev/spike-e3/`(fixture 源 `Reports/spike-e3-results.json`);Apple Developer 未配(MLX runtime 接入 change 前需配,真机才能跑 MLX)。git 工作树:本 session 改 `define-execution-contract/{design,tasks}` + 新建 dispatch/handoff + lessons §B15/§G。
