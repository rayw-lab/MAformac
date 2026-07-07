---
authority: design_note_not_ssot
retire_trigger: MCP 二期立项或 C5 收口后重估
status: draft_design_note
proof_class: local_repo_truth
---

# Architecture Roadmap

> 设计文档，正式编码另立单。

本文件只记录 B6 架构拆分路线，不授权改代码、不替代 OpenSpec、不卡当前 register/C5 窗。正式编码前必须另起执行单，重新跑 impact/测试门，并按当时 live repo 重核 file:line。

## 0. 输入与纠偏口径

- W3 `inv-core-contracts.md` TOP10 指向三类主债：大文件拆分、Training/Bench 从 app 编译面剥离、双 SSOT 清理；其中 TOP10 明确列出拆 `C5LoRATraining.swift`、拆 `C6VehicleToolBench.swift`、剥离 Training/Bench、处理 `10-family-device-boundary.md`、把 C6 cases 纳入更明确 gate（`out/inv-core-contracts.md:112-121`）。
- hermes 草稿给出的目标方向是 dev-time/runtime primitives split：`C6ToolCall`、`C6Hash`、`C6CanonicalJSON`、`DDomainToolEntry` 等 primitives 应有独立归属，且第一轮不要直接移动 Training/Bench/Generation（`out/ARCHITECTURE-ROADMAP-2026-07-07.md:100-109`）。
- W2 交叉审修正 MCP 表述：新增 `Core/` 文件不是“零行为”，只能称 `no runtime entrypoint`；ToolProvider 路线必须显式 amend 旧 Capability/MCP 决策，proof-class 词表也要先选定（`out/xaudit-w4-by-w2.md:16`, `:23-26`）。

## 1. 巨型文件拆分草案

> 设计文档，正式编码另立单。

| 对象 | live evidence | 拆分草案 | 风险 | 验收命令 |
|---|---|---|---|---|
| `Core/Training/C5LoRATraining.swift` | 当前 3837 行；文件内同时有训练 scope/surface 枚举（`Core/Training/C5LoRATraining.swift:72-82`）、样本/MLX record/loss mask（`:346-540`）、训练环境/receipt（`:577-727`）、build options（`:878-963`）、loss mask builder（`:2284-2305`）、D-domain scope filter（`:3296-3308`）。 | 分 6 组：`C5TrainingTypes`（route/scope/surface/sample/message）、`C5LossMasking`、`C5DataBuildOptions`、`C5HashRecipe`、`C5TrainingReceipts`、`C5TrainingBuilder`。第一单只抽 private/internal helpers，保持 public API/typealias 兼容。 | 高。训练链、receipt、hash recipe 是 C5 证据链，不得在 register/C5 run-auth 窗口中顺手改；任何 public type 移动都会影响 `Tools/C5TrainingCLI`。 | `swift test --filter C5`；`make verify-c5-phase1-gates`；`make verify-all`。若只做文件搬迁，还需 `git diff --stat Core/Training` + public symbol grep。 |
| `Core/Bench/C6VehicleToolBench.swift` | 当前 2400 行；文件头定义 C6 gold 基础类型和 `C6ToolCall`（`Core/Bench/C6VehicleToolBench.swift:4-42`），中段包含 dataset codec/generator（`:423-466`）、Swift 内建 must-pass default cases（`:506-552`），尾部包含 `C6Hash`/`C6CanonicalJSON`（`:2329-2363`）。 | 分 5 组：`C6BenchTypes`（case/tag/source refs）、`C6DatasetCodec`、`C6DatasetGenerator`、`C6RunnerScorer`、`C6BenchReceiptSummary`。先抽 primitives 与 codec，再处理 generator/default cases 双源。 | 高。C6 gold 是评测口径；拆错会制造 JSONL/Swift default case 漂移，或让 C5 Training/Gate7 找不到 `C6ToolCall`/hash。 | `swift test --filter C6VehicleToolBenchTests`；`make verify-surface`；`python3 scripts/verify_gold.py contracts/c6-bench-cases.jsonl generated/D_domain.tools.demo.json`；`make verify-all`。 |
| `Core/Generation/Gate7GeneratorPipeline.swift` | 当前 1049 行；同文件包含 provider/request/receipt、subset manifest、generated sample、pipeline request、data gate receipt bridge（`Core/Generation/Gate7GeneratorPipeline.swift:3-291`），并直接引用 `C6ToolCall`/`C6Hash` 与 `C5DataGateCandidate`（`:215-246`, `:406`, `:451-452`, `:614-652`）。 | 分 4 组：`Gate7Provider`、`Gate7Manifest`、`Gate7PipelineCore`、`Gate7DeterministicGates`。抽分前先落 primitives，避免继续从 Bench 借 `C6ToolCall`。 | 中高。Gate7 是 dev-time 生成/judge/data gate 链，不应进入 demo runtime，但会受 target split 影响；拆分可能改变 mock provider 行为和 receipt 字段。 | `swift test --filter Gate7`；`swift build --product Gate7DryRunCLI`；`make verify-all`。 |

依赖序建议：

1. 先抽 runtime/dev-time 共享 primitives。
2. 再拆 C6 bench types/codec，保持 generator 与 JSONL 对齐。
3. 再拆 Gate7，因为它依赖 C6 primitives 与 C5 DataGate 类型。
4. 最后拆 C5 Training；它依赖 C6 hash/tool call、D-domain catalog、loss-mask和 receipt，风险最高。

## 2. Runtime primitives 抽离方案

> 设计文档，正式编码另立单。

### 2.1 当前耦合

- `C6ToolCall` 现在定义在 bench 文件头（`Core/Bench/C6VehicleToolBench.swift:34-42`），但 Gate7 request/sample 也使用它（`Core/Generation/Gate7GeneratorPipeline.swift:215-246`）。
- `C6Hash` 和 `C6CanonicalJSON` 定义在 bench 文件尾（`Core/Bench/C6VehicleToolBench.swift:2329-2363`），但 C5 Training 多处用它算训练/receipt digest（如 `Core/Training/C5LoRATraining.swift:1222`, `:2540-2567`, `:2908-2925`）。
- `DDomainToolEntry` 已在 `Core/Contracts/ToolContractCompiler.swift`，用于解码 `generated/D_domain.tools.demo.json`（`Core/Contracts/ToolContractCompiler.swift:100-121`），Training/Gate7 都引用它。

### 2.2 目标形态

新建低层 primitives 归属，建议命名为 `Core/RuntimePrimitives/` 或未来 SwiftPM target `MAformacRuntimePrimitives`：

| primitive | 从哪里来 | 放哪里 | 不放什么 | 风险 | 验收命令 |
|---|---|---|---|---|---|
| `C6ToolCall` | `Core/Bench/C6VehicleToolBench.swift:34-42` | `Core/RuntimePrimitives/ToolCall.swift` | 不带 C6 case/gold/scorer。 | 中：名称带 C6 历史味，未来可 alias 为 `ToolCall`，但第一单别 rename。 | `swift test --filter C6VehicleToolBenchTests`; `swift test --filter Gate7`; `swift build --product C5TrainingCLI`. |
| `C6Hash` | `Core/Bench/C6VehicleToolBench.swift:2329-2355` | `Core/RuntimePrimitives/StableHash.swift` | 不带 C6 contract bundle policy；`contractDigest` 可先留 Bench 或拆成 `C6ContractDigest`. | 中：hash 是 receipt 承重墙，不能改 encoder/输入顺序。 | `swift test --filter C6ContractBundleFingerprint`; `make verify-all`. |
| `C6CanonicalJSON` | `Core/Bench/C6VehicleToolBench.swift:2357-2363` | `Core/RuntimePrimitives/CanonicalJSON.swift` | 不带 C5-only `C5CanonicalJSONObject`（`Core/Training/C5LoRATraining.swift:3772`）。 | 中：JSON sorted key 语义是 receipt hash 输入，格式变化会破 digest。 | `swift test --filter C6`; `swift test --filter C5`; compare known receipt digests if available. |
| `DDomainToolEntry`/`DDomainFunction` | `Core/Contracts/ToolContractCompiler.swift:100-119` | 可暂留 `Core/Contracts`；若 target split 需要，再下沉到 primitives。 | 不读取 `generated/*.json`；只保 Codable data type。 | 低中：类型共享合理，但 loader/resource policy 不能跟着下沉。 | `swift test --filter ToolContract`; `swift build --product Gate7DryRunCLI`. |

非目标：第一轮不要改 tool semantics、不要 rename public concepts、不要把 `C6DatasetGenerator` 或 `C5TrainingBuilder` 下沉到 runtime。

## 3. Dev-time SwiftPM target split + Xcode whole-Core membership 拆分路径

> 设计文档，正式编码另立单。

### 3.1 当前编译面

- SwiftPM `MAformacCore` 以 repo root 为 path，exclude 掉 docs/contracts/generated 等，但 sources 直接包含 `Core` 和 `Features`（`Package.swift:19-47`）。
- CLI products 依赖 `MAformacCore`：`C6BenchCLI`、`C5DataGateCLI`、`C5TrainingCLI`、`Gate7DryRunCLI` 都依赖同一个 core target（`Package.swift:54-77`）。
- Xcode Mac/iOS target 使用 filesystem synchronized groups，把 `App`、`Core`、`Features` 整体纳入 target（`MAformac.xcodeproj/project.pbxproj:21-35`, `:138-166`）。这意味着 `Core/Training`、`Core/Bench`、`Core/Generation` 当前会进入 app 编译面。

### 3.2 目标 target 拆分

| target | 内容 | 消费方 | 风险 | 验收命令 |
|---|---|---|---|---|
| `MAformacRuntimePrimitives` | `C6ToolCall`、stable hash、canonical JSON、必要 D-domain Codable types。 | `MAformacCore`、dev tools。 | 中：新增 target 会改变 import surface。 | `swift build`; `swift test`; `swift package describe`. |
| `MAformacCore` | demo runtime 必需的 State/Execution/Presentation/Voice/Routing/Capability/Contracts runtime facade。 | App Mac/iOS、core tests。 | 高：错误剥离会破 app build。 | `swift test`; `xcodebuild -scheme MAformacMac -configuration Debug build`; `xcodebuild -scheme MAformacIOS -configuration Debug build`. |
| `MAformacDevToolsCore` | C5 Training、C6 Bench runner/scorer/generator、Gate7 generator/data gate。 | `C5TrainingCLI`、`C6BenchCLI`、`Gate7DryRunCLI`。 | 高：CLI 和 tests 需要重挂依赖。 | `swift build --product C5TrainingCLI`; `swift build --product C6BenchCLI`; `swift build --product Gate7DryRunCLI`; targeted C5/C6/Gate7 tests. |

### 3.3 Xcode membership 拆分路径

1. 先在 SwiftPM 中完成 primitives + dev tools target，让 CLI/test 证明可编译。
2. 再改 Xcode：把 filesystem synchronized `Core` 整体纳入改成更细的 groups，或对 `Core/Training`、`Core/Bench`、`Core/Generation` 加 target exclusion。当前同步组证据见 `MAformac.xcodeproj/project.pbxproj:138-166`。
3. 再跑 Mac/iOS app build，确认 demo runtime 不依赖 dev-time files。
4. 最后清理 imports，禁止 App/ContentView 直接 import dev tools target。

风险：Xcode filesystem sync 的 membership 改动是高风险项目文件改动，必须单独执行、单独验收；不应混进大文件拆分 commit。

## 4. MCP 接入成本地图

> 设计文档，正式编码另立单。

| 层 | 当前/目标 | 成本 | 风险 | 验收命令 |
|---|---|---|---|---|
| 决策层 | 旧口径“Capability 本地/MCP 同构”需要显式 amend 为 vehicle `Capability` + domain-neutral `ToolProvider`，否则形成双权威；W2 已指出该冲突（`out/xaudit-w4-by-w2.md:25`）。 | 低，docs/decision note。 | 高：不先 amend 会让后续代码绕开旧 guard/executor 边界。 | `rg -n "Capability|ToolProvider|MCP" docs openspec`; decision note 过审后再编码。 |
| Domain registry snapshot | 若新增 `Core/Domain`，它会进入 `MAformacCore` 编译/API 面，不是零行为（`out/xaudit-w4-by-w2.md:23`）。 | 中，新增 types + tests。 | 中：API surface 变化、bundle/resource 假设。 | `swift test --filter Domain`; `git diff --name-only -- App Core/Execution Core/Routing`; no App/C3 callsite diff。 |
| ToolProvider stub | 目标是 planned-unavailable，不接 MCP client，不路由外域。 | 中。 | 高：状态词若有 `.success` 或 runtime-ready，会制造假支持。 | 强词 grep：`rg -n "已支持 MCP|runtime-ready|V-PASS|mobile|true_device|live_api|success" Core docs openspec`. |
| ExternalToolInvocation vocabulary | 不复用 vehicle IR；不能让音乐/导航伪装为 `ToolCallFrame.device/actionPrimitive`。 | 中。 | 中：status/proof vocab 混层。 | targeted tests + no `ToolCallFrame` callsite diff。 |
| Presentation proof | public payload 用 `PresentationProofClass`，stage preview 用 `StagePresentationProofClass`，不能混 raw values；W2 已指出 proof-class mismatch（`out/xaudit-w4-by-w2.md:24`）。 | 中。 | 中高：不可编码/不可消费或 fake proof。 | `swift test --filter RuntimePresentationBridge`; `swift test --filter PresentationSnapshot`; proof-class raw value grep。 |
| 真 MCP client | 本 roadmap 不做；等 MCP 二期立项。 | 高。 | 高：网络/权限/外部服务/live claim。 | 另立 OpenSpec + live/mock proof-class 分层；本单无验收。 |

MCP 最小可执行序：decision note → vocabulary/proof-class decision → docs-only or hardcoded snapshot → no-runtime-entrypoint tests → later client work。任何直接接 C3 vehicle pipeline 的方案都应拒绝。

## 5. 双 SSOT 消除清单

> 设计文档，正式编码另立单。

| SSOT 气味 | live evidence | 处理建议 | 风险 | 验收命令 |
|---|---|---|---|---|
| `contracts/capabilities.yaml` header vs historical machine fields | 文件头标明现行权威是 `contracts/semantic-function-contract.jsonl`，但下方仍有 historical `source_of_truth: contracts/capabilities.yaml`（`contracts/capabilities.yaml:1-18`）；测试仍读取该文件（`Tests/MAformacCoreTests/CapabilityContractFileTests.swift:18`, `:35`, `:44`）。 | 第一阶段只强化 header 和测试命名：测试应验证“historical file remains marked superseded”，不要再把它当 active SSOT。第二阶段迁出 active contracts 或改成 fixture。 | 中：直接删会破历史 refs/tests；保留不解释会误导 agent。 | `swift test --filter CapabilityContractFileTests`; `rg -n "source_of_truth: contracts/capabilities.yaml" contracts Tests docs`. |
| C6 gold JSONL vs Swift default cases | `contracts/c6-bench-cases.jsonl` 是测试/脚本/CLI 消费源；Makefile `verify-surface`/`verify-gold`/shape check 都读它（`Makefile:62-67`）。但 Swift 内建 `mustPassCases()` 仍有 default cases（`Core/Bench/C6VehicleToolBench.swift:506-552`）。 | 明确单源：JSONL 是 committed gold；Swift default cases 只能作为 generator fixture，必须有 round-trip test 证明生成输出等于 JSONL 或移到 tests fixture。 | 高：C6 acceptance 口径漂移会污染 C5 behavior gate。 | `python3 scripts/verify_gold.py contracts/c6-bench-cases.jsonl generated/D_domain.tools.demo.json`; `swift test --filter C6VehicleToolBenchTests`; future `make verify-c6-gold-single-source`. |
| `generated/10-family-device-boundary.md` orphan | 文件在 `generated/` 下，自述来源 semantic contract（`generated/10-family-device-boundary.md:1-6`），但 Makefile `GENERATED_DOMAIN` 列表没有它（`Makefile:14-25`）。 | 二选一：纳入生成器+diff gate，或迁到 `docs/research/` 并标 historical/design evidence。不要留在 generated 目录假装可 regen。 | 中：读者会误以为它是机械生成产物；regen 不会保护它。 | `make verify-generated`; `git diff --exit-code -- generated/10-family-device-boundary.md`; after move, `rg -n "10-family-device-boundary" docs generated Makefile`. |
| runtime compiled IR map vs file IR map | W3 TOP10 已指出 compiled IR map/file IR map 权威边界需命名清楚（`out/inv-core-contracts.md:121`）。`C6Hash.contractDigest` 把 `generated/d_domain_ir_map.json` 纳入 bench 指纹（`Core/Bench/C6VehicleToolBench.swift:2338-2353`）。 | 文档命名：Mac demo runtime 使用 compiled constant，CLI/test 可读 generated file；fingerprint 只证明 bench 输入一致，不等于 runtime 依赖 CWD。 | 中。 | `swift test --filter RuntimeAdapterMount`; `swift test --filter C6ContractBundleFingerprint`; `rg -n "d_domain_ir_map|compiled" Core docs Tests`. |

## 6. 执行边界与停止条件

> 设计文档，正式编码另立单。

- 不在本文件授权删除、移动、rename、target membership 改动或 MCP client。
- 不在 register S7c/run-auth 或 C5 training/evidence 窗口混入高风险架构改动。
- 每个正式实施单必须单 proof domain：primitives、C6 split、Gate7 split、C5 split、SwiftPM target、Xcode membership、MCP decision、SSOT cleanup 分开。
- 任一单触碰 `Core/Training`、`Core/Bench`、`Core/Generation`、`Package.swift`、`MAformac.xcodeproj/project.pbxproj`，都需要 fresh `git status`、impact/调用面扫描、targeted tests、`make verify-all` 或明确降级说明。

建议第一刀：只抽 `C6ToolCall` + `C6Hash` + `C6CanonicalJSON` 到 primitives，保持 type names 和 behavior 不变；通过 C5/C6/Gate7 targeted tests 后，再讨论 target split。
