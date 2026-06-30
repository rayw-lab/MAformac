---
status: active_architecture_absorption_record
artifact_kind: architecture_absorption
language: zh
created_at: 2026-06-24
change_id: define-demo-default-scope
source_reports:
  - /Users/wanglei/Downloads/pr_audit_4(GPTPRO窗口1).md
  - /Users/wanglei/Downloads/pr_audit_4(gptpro窗口2).md
proof_class: local_review
authority: research_absorption_not_contract
retire_trigger: "The accepted architecture debt is either converted into OpenSpec changes or explicitly superseded by a later architecture decision."
---

# PR #4 GPT Pro 架构建议吸收记录

## 0. 这份文档补什么

前一份吸收记录 `docs/research/2026-06-24-pr4-gptpro-audit-absorption.md` 主要处理两份 GPT Pro 报告的 P0/P1/P2 merge gate 和 fake-green 修复。它没有完整吸收报告下半段的架构建议。

本文件专门吸收两份报告的架构段：

- 窗口1 `后续架构建议`：`TargetResolution`、`PlannedEffect`、`ContractReplayEngine`、`VehiclePresentationAdapter`、`ScopeCandidateCatalog`、`ContractBundle/Fingerprint`、head-bound receipt、PR lane 拆分。见 `/Users/wanglei/Downloads/pr_audit_4(GPTPRO窗口1).md:213-674`。
- 窗口2 `10 条架构方向`：`ScopedStateKey`、`C2ScopeResolver` 单源、`StateApplyEngine`、`ReadbackRenderer`、device/cell-aware C5、C6 replay proof、Presentation ViewModel、receipt artifact、分层路线和落地顺序。见 `/Users/wanglei/Downloads/pr_audit_4(gptpro窗口2).md:232-262`。

本文件不是新的实现授权，不关闭 C6 acceptance、LoRA training、demo-golden-run、voice、UIUE merge 或 R-L17。它的作用是把架构建议转成后续 OpenSpec / dispatch 的 routing ledger。

## 1. 总体判断

**结论：方向基本正确，但不能把它理解为“PR #4 必须一次性重构到位”。**

两份报告抓到的根因不是单点 bug，而是 `default_scope` 被多个层各自理解：C3 runtime、state applier、C5 target rendering、C6 verifier、readback、UI presentation 都在不同程度上解析 scope、推断 origin 或拼 scoped key。这个判断成立。

但报告的建议有两类不同性质：

| 类别 | 应对 |
|---|---|
| 合并门缺口 | PR #4 已经止血：throwing state applier、C6 消费 `applyWithEvidence`、C5 device/cell scope candidates、head-bound CI/receipt。 |
| 架构主干重构 | 不应塞回 PR #4；应拆成后续 `runtime contract spine` / `rebuild-c6` / UIUE presentation / `retrain-c5` 相关 changes。 |

反方观点也成立：如果现在立刻引入 `TargetResolution + PlannedEffect + ContractReplayEngine + ContractBundle` 全套，会变成大爆炸重构，和 A2 之后刚稳定的 default_scope apply 主线冲突。正确路线是保留 PR #4 的止血成果，把架构建议拆成薄主干、逐段替换。

## 2. 已经落地的部分

这几项不再只是建议，已经进入 PR #4 合并态：

| 报告建议 | 当前落地 | 剩余边界 |
|---|---|---|
| `C2ScopeResolver` 成为 scope 单源 | `Core/Execution/ScopeResolution.swift` 已有 `ScopeResolution(keys/resolvedScopes/origin)`，C3 与 state applier 共用。 | 结构仍偏薄，缺 `baseCellID/requestedScope/sourceSlot/presentationPolicy/diagnostics`。 |
| State applier fail-closed | `ToolContractStateApplier.apply/applyWithEvidence` 已 throwing，unknown/unmapped/missing/scope failure 不再 log+return。 | 仍是 normalize+resolve+write 同函数，没有拆成 plan/validate/apply 三段。 |
| C6 不再重算 `ScopeOrigin` | C6 通过 `C6MockStateApplier.applyWithEvidence` 消费执行 evidence。 | 还不是完整 `ContractReplayEngine`，C6 仍保留较多自身 matcher/gate 逻辑。 |
| C5 scope candidate device/cell-aware | `C5ScopeCandidateCatalog.scopeCandidatesByDeviceSlot` 从 C2 state cells 和 `deviceCellMap` 派生。 | `slotKeys(for:)` 仍是手写桥接，191 device 全量 codegen 仍 deferred。 |
| head-bound receipt + CI | GitHub Verify 和 `verify-ci-receipt` 已出现，main head 也有 CI receipt。 | receipt schema 还未纳入 `ContractBundleFingerprint`，branch protection 是 GitHub 设置，不是 repo 文件。 |
| UI presentation 不直接在 PR #4 改 | P1 UI 建议移交 UIUE，保留 `presentationCells`、`base[scope]`、`DemoVehicleStateCell.init(...visualState:)`。 | UIUE 后续仍要接管 structured presentation，而不是长期 parse key。 |

这说明报告的架构方向不是空泛建议，PR #4 已经完成了最小止血版。

## 3. 应采纳为后续主干的建议

### 3.1 `ScopedStateKey` 与 `TargetResolution`

**采纳，但要薄实现。**

窗口1建议 `TargetResolution` 作为唯一 scope 计算产物，窗口2建议先抽 `ScopedStateKey`。这两者应合并看：先稳定 key parser，再扩展 resolver 输出。

建议后续最小形态：

```swift
public struct ScopedStateKey: Codable, Equatable, Hashable, Sendable {
    public var baseCellID: String
    public var scope: String?
}

public struct TargetResolution: Codable, Equatable, Sendable {
    public var baseCellID: String
    public var requestedScope: String?
    public var sourceSlot: String?
    public var resolvedKeys: [ScopedStateKey]
    public var resolvedScopes: [String]
    public var scopeOrigin: ScopeOrigin
}
```

暂不建议把 `presentationPolicy` 强塞进 resolver 的核心结构。`presentationPolicy` 属 channel policy，尤其 UIUE 已拍“默认 scope 淡显、非完全省略”。resolver 应输出事实，presentation adapter 再决定视觉与文案。

**反方校验：**如果只为少数 scoped key 抽类型，可能过度工程。但当前已有 C3/C6/UI/readback 多处 bracket parser 与 origin 推断漂移，抽 `ScopedStateKey` 已有足够事实基础。

### 3.2 `StateApplyEngine` 与 `PlannedEffect`

**采纳为 rebuild-c6 前置，不回填 PR #4。**

报告建议把 state-applier 拆成 plan -> validate -> apply。PR #4 已经把 fail-open 关掉，但还没有产生可复放的 effect plan。

建议后续形态：

```swift
public struct PlannedEffect: Codable, Equatable, Sendable {
    public var sourceToolName: String
    public var ir: ToolContractIR
    public var target: TargetResolution
    public var writes: [ScopedStateKey: String]
    public var dependencies: [String: String]
}

public struct StateApplyDiagnostics: Codable, Equatable, Sendable {
    public var errors: [String]
    public var scopeEvidence: [String: ScopeOrigin]
    public var unexpectedMutations: [String]
}
```

收益是 C6 可以验证 planner 输出，而不是事后对 final state 做字符串对账。风险是过早扩大实现面，所以它应跟 `rebuild-c6-four-layer-bench` 绑定，不作为 `default_scope apply` 返工项。

### 3.3 `ContractReplayEngine`

**采纳，且优先级高于继续补 C6 case。**

窗口1指出 C6 正在变成第二个 runtime，这个判断很关键。当前 C6 已经消费 state applier evidence，但 matcher、readback、delta 比较仍有 C6 自身逻辑。

后续目标：

```mermaid
flowchart LR
    "C6 Case" --> "ContractReplayEngine"
    "Tool Calls" --> "ContractReplayEngine"
    "ContractReplayEngine" --> "PlannedEffect"
    "PlannedEffect" --> "State Delta"
    "PlannedEffect" --> "Scope Evidence"
    "PlannedEffect" --> "Readback Expectation"
    "Model Output" --> "Gate Compare"
    "State Delta" --> "Gate Compare"
    "Scope Evidence" --> "Gate Compare"
    "Readback Expectation" --> "Gate Compare"
```

这应进入 `rebuild-c6-four-layer-bench` 的 proposal，不应在 `retrain-c5` 里临时做。

### 3.4 `ReadbackRenderer` 独立化

**采纳，但要区分 domain text 与 UI presentation。**

报告建议 C3、C6、UI、TTS 共用 renderer，避免 defaulted scope 是否省略漂移。方向正确，但报告示例里 `elideDefault` 与 UIUE 的“默认淡显、非完全省略”冲突。

建议拆成两层：

| 层 | 职责 |
|---|---|
| Domain Readback Renderer | 产生可读且不丢 scope 事实的文本。PR #4 已选择保留“主驾”。 |
| Presentation Adapter | 根据 `scopeOrigin` 决定默认 scope 低强调、显式 scope 强展示、fanout aggregate。UIUE owns。 |

这可以防止 “TTS/plain text 没法淡显，所以只能省略” 这种错误推理。plain text 不具备淡显能力时，应宁可保留 scope，不丢事实。

### 3.5 C5 scope candidate 全量从 C2 派生

**采纳，且已有局部落地，但仍有结构债。**

PR #4 已修掉 window-only parity。后续仍需要把 `slotKeys(for:)` 从手写 switch 变成显式 binding 或 codegen：

```swift
public struct SlotToCellScopeBinding: Codable, Equatable, Sendable {
    public var device: String
    public var slotKey: String
    public var cellID: String
}
```

这个应进入 `retrain-c5` 前置 gate，而不是训练时再靠样本检查发现。

### 3.6 `ContractBundle` 与 fingerprint

**采纳为 evidence 层优先，不必立刻改所有 runtime API。**

报告建议把 semantic/state/risk/allowlist/IR/catalog 打包为 `ContractBundle` 并记录 digest。这个方向对 C6/receipt 价值很高，因为当前 fake-green 的一部分来自“哪个模块读了哪个版本的 contract”不够透明。

落地顺序应是：

1. 先为 C6 eval/receipt 记录 `ContractBundleFingerprint`。
2. 再让 C6 replay 与 C5 render 接受同一个 bundle。
3. 最后再考虑 C3 runtime 是否也改成 bundle 注入。

不建议一开始就把所有 lookup 构造全部重写，避免制造大面积 API churn。

### 3.7 Head-bound receipt / CI artifact

**已经采纳，但需继续制度化。**

PR #4 之后已有 GitHub Verify、source-free CI receipt、本地 raw-bound receipt。后续应补：

- receipt schema 加 `receipt_version`。
- receipt 加 `contract_bundle_fingerprint`。
- CI artifact 明确区分 `push head`、`PR synthetic merge ref`、`main head`。本轮已经实际遇到 PR-event artifact 绑定 synthetic merge SHA，而 push-event artifact 才绑定 branch head。
- branch protection/required checks 作为 repo setting 单独确认，不伪装成代码已强制。

### 3.8 PR lane 拆分

**采纳为治理原则，不 retroactively 拆 PR #4。**

窗口1批评 PR #4 混入 runtime、tests、reports、research tools、skills、docs，审计成本高。这个批评成立。PR #4 已合并，不再倒拆；但后续应按 lane 写 dispatch：

| Lane | 后续动作 |
|---|---|
| Contract / OpenSpec | 新行为先走 change，不直接改 runtime。 |
| Runtime spine | `ScopedStateKey`、`TargetResolution`、`StateApplyEngine`。 |
| C6 replay | `ContractReplayEngine`、manifest、exact replay proof。 |
| C5 data/render | `SlotToCellScopeBinding`、C2-derived candidates、sample observability。 |
| UIUE presentation | `VehiclePresentationCell`、default scope 淡显、fanout aggregate。 |
| Verification | head-bound receipt、bundle fingerprint、CI artifact。 |
| Research artifacts | 单独 PR 或明确 non-runtime。 |

## 4. 不应照单全收的地方

### 4.1 不把 `presentationPolicy` 变成 C2 状态事实

报告把 `presentationPolicy` 放进 `TargetResolution` 示例里。这个可以作为输出附带信息，但不应混进 C2 状态权威。C2 应描述 state cell 的事实：scope、default_scope、range、readback template、depends_on。UI 如何淡显或聚合，属于 channel policy。

### 4.2 不把 defaulted scope 完全省略当统一策略

报告中出现 `elideDefault` 倾向，但 UIUE 决策已经指出默认 scope 应淡显而非完全省略。对 plain text/TTS 而言，没有淡显能力时应保留“主驾”，否则会损失“主驾 vs 全车”的关键信息。

### 4.3 不为 default_scope 一次性引入巨型框架

`TargetResolution -> PlannedEffect -> ContractReplayEngine -> ContractBundle` 是正确方向，但一次性落地会形成新的大爆炸。A2 刚结束，PR #4 的价值是关闭 merge gate，不是重构全部架构。

### 4.4 不让 C6 architecture debt 阻断 UIUE rebase

UIUE 需要的是已稳定的 domain interface：`presentationCells`、`base[scope]`、`DemoVehicleStateCell.init(...visualState:)`、structured readback/scope metadata。`ContractReplayEngine` 和 C6 manifest 是后续 bench 质量，不应变成 UIUE 合并前置。

### 4.5 不把 receipt/CI 当产品验收

CI receipt 只能证明 source-free local gates。它不证明 LoRA quality、C6 acceptance、voice readiness、demo-golden-run 或 R-L17。报告建议 evidence artifact 化是对的，但 proof class 仍要分层。

## 5. 后续路线建议

### Phase A：runtime spine 最小化

目标：把 scope key 和 target resolution 从字符串习惯升级成结构化事实。

Scope in：

- `ScopedStateKey`
- 扩展 `ScopeResolution` 或引入 `TargetResolution`
- C3/state-applier/C6/readback 共用 parser
- 不动 UIUE `ContentView`

Validation：

- C3 defaulted/explicit/fanout tests
- state applier invalid scope hard-fail
- C6 scoped delta evidence hard-fail
- mechanical gate 禁重复 bracket parser 扩散

### Phase B：C6 replay proof

目标：C6 不再是第二 runtime，而是 contract runtime replay。

Scope in：

- `PlannedEffect`
- `StateApplyDiagnostics`
- `ContractReplayEngine`
- C6 exact delta + unexpected mutation + scope evidence + readback compare
- C6 JSONL manifest / generator hash / trap migration hash

Validation：

- `swift run C6BenchCLI verify-gold`
- manifest hash gate
- no-call/refusal/unsupported 与 action positive 分层 receipt

### Phase C：C5 render/data gate

目标：训练前 target rendering 不再靠 slot-name 启发式。

Scope in：

- `SlotToCellScopeBinding`
- C2-derived `ScopeCandidateCatalog`
- sample observability：target 是否实际存在于工具/cell binding
- byte parity / tokenizer fixture 仍按 proof class 分层

Non-goal：

- 不启动 LoRA training
- 不把 C5 data gate pass 写成 model quality pass

### Phase D：UIUE presentation adapter

目标：UI 不再 parse scoped key 生成展示事实。

Scope in：

- `VehiclePresentationCell`
- `scopeOrigin`
- `resolvedScope`
- `presentationScopePolicy`
- defaulted scope 淡显、explicit scope 强展示、fanout aggregate-first

Ownership：

- UIUE owns SwiftUI consumption。
- domain owns structured facts and readback metadata。

### Phase E：evidence / governance

目标：receipt 变成可复核 artifact，而不是日志摘要。

Scope in：

- `receipt_version`
- `head_sha`
- `dirty_worktree`
- `contract_bundle_fingerprint`
- `commands[]` with sha256
- CI source-free / local raw-bound proof class split

## 6. 推荐的 OpenSpec / dispatch 落点

| 建议落点 | 承载内容 | 不承载 |
|---|---|---|
| `harden-contract-runtime-spine` | `ScopedStateKey`、`TargetResolution`、state apply diagnostics、readback fact split。 | UIUE layout、C6 acceptance、training。 |
| `rebuild-c6-four-layer-bench` | `ContractReplayEngine`、C6 manifest、exact replay proof、bundle fingerprint。 | LoRA training。 |
| `retrain-c5-lora-d-domain` 前置 gate | `SlotToCellScopeBinding`、C2-derived scope candidates、sample observability。 | default_scope 语义重拍。 |
| UIUE change | `VehiclePresentationCell`、default scope 淡显、fanout aggregate。 | Domain resolver 重写。 |
| CI / receipt hardening | CI artifact schema、main/PR/push head SHA 对账、branch protection checklist。 | 产品 V-PASS。 |

## 7. 一句话吸收结论

两份 GPT Pro 报告下半段的核心价值不是“多补几个测试”，而是指出 `default_scope` 必须从散落规则升级为一条薄而可复放的 contract spine：`ScopedStateKey / TargetResolution -> PlannedEffect / StateApplyDiagnostics -> ContractReplayEngine / ReadbackRenderer -> PresentationAdapter / C5-C6 gates -> head-bound receipt`。PR #4 已经完成止血版；后续应按 OpenSpec 拆分推进，防止一次性重构，也防止 C3/C5/C6/UI 继续各自理解 scope。

