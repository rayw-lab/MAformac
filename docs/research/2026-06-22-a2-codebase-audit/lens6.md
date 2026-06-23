# Lens 6: Lens 5: Swift codegen 框架 + 端侧受限解码选型（外部+clone）

# Lens 5 一手档：Swift codegen 框架 + 端侧受限解码选型（MAformac contract→534 D-domain 具名工具）

> finder: Swift codegen 框架选型（github-first, ≥10 搜证, 2 clone）
> 检索日: 2026-06-22 | 搜证 12+ web + 7 gh api 核 + 2 repo clone

## 核心结论（summary）

把任务拆成**两个独立决策面**，结论相反：

1. **contract jsonl → Swift 代码/枚举/schema 的 codegen**：**不引入任何 Swift codegen 框架**。MAformac **已有现成 Python codegen SSOT**（`scripts/gen_c1.py` + `scripts/gen_tool_contract.py` → `generated/D_domain.tools.json` / `B_frame.frame_schema.json` / `rendered_tools_text`，Makefile `regen-tool-contract` 调它，`git diff --exit-code` 守门）。Sourcery / SwiftSyntax / SPM build-plugin / gyb 引入任何一个都是**造第二套 SSOT**，违项目宪法 §4「契约单源」+ claim-vs-reality 铁律1。
2. **端侧受限解码（真缺口、最高价值）**：**adopt `petrukha-ivan/mlx-swift-structured` 的 `TriggeredTagsFormat` 模式**，但**以 vendor C++ 进仓自维护的形态**（非直接依赖单人 repo）。这是 mlx-swift 端**唯一**直接可用的 constrained-decoding 库，其 triggered-tags 正是「534 D-domain 具名工具」范式的精确解。

---

## 对比矩阵（候选 × 维度，每格带源）

| 候选 | star/活跃(2026-06检索) | 输入形态 | 与 MAformac 匹配 | 裁决 |
|---|---|---|---|---|
| **现状: Python `gen_*.py`** | 本机 SSOT | jsonl/yaml→JSON | ✅ 已是单源, Makefile+git diff 守门 | **守现状(codegen)** |
| Sourcery | 8010★ / 2026-06-11 | **Swift AST + 标注** | ❌ 吃 Swift 不吃 jsonl | drop(输入不符) |
| SwiftSyntax/Builder | 3671★(官方) / 2026-06-17 | 任意→Swift 源码 | ⚠️ 能做但多此一举(已有JSON,Codable解码即可) | drop(过度) |
| swift-openapi-generator | 1934★(官方) / 2026-06-22 | OpenAPI yaml→Swift | ⚠️ 范式标杆但语义不符(HTTP API≠tool-call) | 参考范式不adopt |
| gyb | Apple内部/非公开工具 | Python 模板 | ❌ 又一Python模板层, Macros取代 | drop |
| **mlx-swift-structured** | **74★ / 2026-04-06(临界)** | JSONSchema→受限解码 | ✅✅ **TriggeredTags=534具名工具精确解** | **adopt(受限解码), vendor自维护** |
| otriscon/llm-structured-output | 93★ / 2025-01(死) | Python | ❌ Python, >1年没动 | drop(灵感来源,已被Swift库吸收) |
| mlc-ai/xgrammar(底层) | 1752★ / 2026-06-11 | C++/Py/JS/Swift API | ✅ 上游引擎活跃 | 间接(经Swift壳/自vendor) |

## 端侧受限解码方案（关键缺口的解法）

**问题真值**：mlx-swift 核心栈**无** constrained decoding（llama.cpp 有 GBNF + JSON-schema→GBNF 编译，MLX 没等价，只能 bolt-on）。home-llm 蓝本的 `output.gbnf` 路线是 **llama.cpp 专属，不可移植 mlx-swift**。

**唯一直接解 = `petrukha-ivan/mlx-swift-structured`**：
- 形态：vendored XGrammar C++（`Sources/CMLXStructured` 仅 **44K / 4 cpp**，iOS 可编译）+ 直接挂 `mlx-swift-lm`（MAformac 已用此栈）+ Apache-2.0。
- API：`Grammar.schema(JSONSchema)` / `Grammar.generable(@Generable)`（需 macOS26/iOS26）/ `GrammarMaskedLogitProcessor.from(...)` 挂进 `TokenIterator`。
- 实测开销：合成 <3%，真实模型 ≤10%（README）。
- **TriggeredTags 正是 534 具名工具的精确解**（`ToolCallingExample.swift:64-86`）：
```swift
Grammar {
  TriggeredTagsFormat(triggers: ["<tool_call>"], options: [.atLeastOne, .stopAfterFirst]) {
    for tool in tools {  // 534 D-domain 具名工具
      TagFormat(begin: "<tool_call>\n{\"name\": \"\(tool.name)\", \"arguments\": ",
                end: "}\n</tool_call>") {
        JSONSchemaFormat(schema: tool.parameters)
      }
    }
  }
}
```
- 底层 XGrammar-2 用 **Aho-Corasick DFA 同时匹配多 tag**（534 工具不退化），Structural Tag 把 schema accuracy 提到 **100%**，论文明示「对小模型增益尤其大」——正中 1.7B + 范式翻案（generic frame 判定面爆炸→具名工具）痛点。

**pre-mortem 三分类**：
- 🐅 **tiger**：`mlx-swift-structured` 仅 **74★ + 最后 push 2026-04-06（>60天，磊哥『近2月活跃』硬约束临界淘汰区）**，依赖 `swift-json-schema` **0★**。这是单人维护的薄绑定壳。**修法 = vendor 进仓自维护**（C++ 仅 44K 可控；上游 `mlc-ai/xgrammar` 1752★/2026-06-11 + `mlx-swift-lm` 679★/2026-06-21 活跃，自维护风险低）。验证清单：① 实跑 `MLXStructuredCLI tool-calling` 验 Qwen3-1.7B 输出 ② 测 534 工具下 DFA 编译时间 ③ 确认 iOS arm64 编译通过。
- 🐅 **tiger**：`ToolContractCompiler.swift:1-118` 是与 `gen_tool_contract.py:14-45` **重复的手写编译器**（同算 device/action/value/slots + `dDomainSurfaceNames` 手映射 if-else），双源漂移。修法=Swift 侧改读 `generated/*.json` 产物不重算。
- 🐅 **tiger**：build-plugin 三坑实证（Build input file not found / 间接依赖不触发 / dirty-tracking stale, SPM#6936）。MAformac 现状（Python 生成入仓 + git diff 守门）已规避，**不要为 codegen 改 build plugin**。
- 🐘 **elephant（没人提但该提）**：选型问的是「引入哪个 Swift codegen 框架」，但**正确答案是不引入**——MAformac 已有 Python codegen SSOT，引入 Swift codegen 框架=与之竞争的第二套 SSOT。真正该做的是「Swift 侧消费 Python 产物 + adopt 受限解码」。
- 🦌 **paper-tiger**：Sourcery/gyb 看似 codegen 候选，实际输入形态不符（Sourcery 吃 Swift AST 不吃 jsonl；gyb 是又一 Python 模板层），非威胁=不适用直接 drop。

## clone 结构（本机 `~/workspace/raw/05-Projects/MAformac/ref-repos/`，只读不入仓）

`mlx-swift-structured`（已 clone）目录：
- `Sources/MLXStructured/Grammar/` — `Grammar.swift`/`Grammar+Schema.swift`(JSONSchema→grammar)/`Grammar+Generable.swift`/`Grammar+Structural.swift`
- `Sources/MLXStructured/Structural/StructuralTag.swift` — `SequenceFormat`/`OrFormat`/`TagFormat`/`TriggeredTagsFormat` result-builder DSL
- `Sources/MLXStructured/GrammarMaskedLogitProcessor.swift` — 挂进 TokenIterator 的 logit 屏蔽器
- `Sources/CMLXStructured/xgrammar/` — vendored XGrammar C++（44K，可直接 vendor 进 MAformac）
- `Sources/MLXStructuredCLI/Commands/ToolCallingExample.swift` — **534 具名工具范式参考实现**

## 决策 + ⭐ 默认

- **codegen 维度**：⭐ **守现状**（Python `gen_*.py` SSOT + git diff 守门），不引入 Swift codegen 框架。Swift 侧把 `ToolContractCompiler.swift` 改为消费 `generated/D_domain.tools.json`（消除双源债）。
- **受限解码维度**：⭐ **adopt `mlx-swift-structured` 的 TriggeredTags 模式，vendor C++ 进仓自维护**（因绑定层 74★/临界新鲜度，不直接依赖单人 repo）。这是 0→100% schema 保证、534 具名工具范式落地的关键基础设施。

## grill 议题弹药（喂回主线程）

1. **受限解码 adopt 形态**：A=直接 SPM 依赖 mlx-swift-structured(快但 74★/临界新鲜度风险) / B=⭐vendor C+++Swift 壳进仓自维护(C++仅44K,上游 xgrammar 1752★活跃,自控) / C=暂不上受限解码靠 fuzzy-parse 兜底。量化:B 多 ~1 天 vendor 成本换掉单人 repo 弃坑风险。
2. **Swift 侧双源债**：ToolContractCompiler.swift(手写)vs gen_tool_contract.py(Python SSOT)是否本刀消除(Swift 改读 JSON 产物)? A=⭐本刀改(债早还) / B=记 TODO 后续。
3. **534 工具 DFA 编译时间**：adopt 前是否需先 spike 实测 534 个 TagFormat 的 Aho-Corasick 编译延迟(冷启动炸场风险)? ⭐是,纳入 P1 spike。
4. **Generable macro 门**：`Grammar.generable(@Generable)` 需 macOS26/iOS26;若目标设备低于此版本,只能走 `Grammar.schema(JSONSchema)` 路径(从 generated JSON 喂)。确认目标 iOS 版本。