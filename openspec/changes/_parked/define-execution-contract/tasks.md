> 范围:6-change 第 3 个。升级 change1 walking skeleton(DemoGuard 协议位→完整门;arguments `[String:String]`→`[String:JSONValue]`)为完整执行链 + 错误枚举。**adopt `mlx-swift-lm` 上游 parser(E1),不自建**。依赖 change2 `capabilities.yaml`(demo_guard 规则 / 范围枚举源)。pre-mortem 全料见 `docs/execution-pre-mortem-2026-06-18.md`。

## 0. 前置 spike(go/no-go,E1+E3 合并,起手必做)

- [ ] 0.1 用 `mlx-swift-lm`(pin exact tag)喂 Qwen3-1.7B-4bit,**量化 `.toolCall` 事件触发率**(N 条车控 prompt)。验收:**收到 `.toolCall` 事件而非 `.chunk` 含 `<tool_call>` 原文**(T2 失配指纹);确认 adopt 上游 parser 可行。**go/no-go 门**:触发率过低 → 记 risk + 通知 LoRA Day1 优先采「漏触发」样本。**叠加 Superpowers: verification**。

## 1. ToolCallFrame 薄层(adopt 上游,E1/E2/T2/T5)

- [ ] 1.1 load 后**显式锁 `toolCallFormat = .json`**(不靠 `infer()`,防 model_type 静默失配)。验收:smoketest 断言收 `.toolCall` 事件。
- [ ] 1.2 消费 `mlx-swift-lm` `.toolCall` 事件 → `ToolCallFrame`(薄层 + 二次校验);`arguments` 从 change1 占位 `[String:String]` 升级 `[String:JSONValue]`,**全类型归一**(对象/字符串化 JSON/数组/标量)。验收:数组/标量 arguments fixture 不被丢弃。
- [ ] 1.3 两层 decode 边界:严格 enum/required/类型校验门挂**第②层(`execute()` 前 `decode(Input.self)`)**。验收:enum 校验在第②层触发(非宽松第①层)。

## 2. 错误枚举 + decode_failed(T3/T4)

- [ ] 2.1 自写 `throws` decoder,产出三态错误枚举:`no_tool_call` / `malformed` / `schema_invalid`(细分 `unknown_tool` / `missing_field` / `type_mismatch` / `out_of_range`)。验收:三态各有测试,`decode_failed` 可达。
- [ ] 2.2 面向模型输出的 enum **手写 `init(from:)`**(未知值落 `unknown` / 转 decode_failed);**全链路禁 `try!` / `try?`**(用 do/catch)。验收:未知 enum 值不抛 `dataCorrupted`、不崩。**叠加 code review checklist**。
- [ ] 2.3 retry≤1(仅 `malformed`)+ `decode_failed` → 澄清。验收:malformed 重试 1 次后转澄清,无无限重试。

## 3. DemoGuard 完整门(升级 change1 协议位)

- [ ] 3.1 实现 R0–R3 代码门:unknown tool / schema / 范围枚举 / writable / 风险等级 / 确认策略 / 互斥 bus / 前置条件(规则源 = `capabilities.yaml.demo_guard`)。验收:`Unsafe false pass=0`;unknown/越界/缺字段/非法 enum 均拒。
- [ ] 3.2 `think_leak`:输出含 `<think>` → trace 记 + 该轮失败 / 降级澄清。验收:think 泄漏被捕获不进执行。

## 4. trace + 升级 change1 接入

- [ ] 4.1 TraceLogger 五段 + **显式记 `toolCalls.count` / `stopReason`**(T2 指纹)。验收:trace 含五段 + 两指标。
- [ ] 4.2 升级 change1 `DemoWalkingSkeleton`:单条放行占位 → 接完整执行链(decoder + 完整 DemoGuard)。验收:change1 闭环测试仍绿 + 新错误枚举路径覆盖。

## 5. 验收门

- [ ] 5.1 错误枚举三态 + arguments 全类型 fixture 测试(用模型实采样本,非 mock)。**叠加 Superpowers: TDD**。
- [ ] 5.2 填实 change1 占位测试(`Unsafe false pass=0` / `readback mismatch=0` / pending 不冒充);全绿。
- [ ] 5.3 `openspec validate define-execution-contract` 通过;`enable_thinking=false` 实测;全链路 grep 无 `try!`/`try?`。
