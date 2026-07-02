---
authority: e2_subset_grill_synthesis
artifact_kind: grill_round_synthesis_reduction
round: e2-subset-grill（2026-07-02，磊哥 6 维度→9 维度树→4 路 43 决策）
inputs: e2-subset-w1-decisions.md（S-001~011=11）/ e2-subset-w2-decisions.md（S-101~108=8）/ e2-subset-w3-decisions.md（S-201~210=10）/ e2-subset-commander-d9-premortem.md（SF-01~14）
status: synthesized_pending_magnet_ratification
author: claude-commander（总监综合）
---

# E-2 subset grill round — 综合 + 消减 + 上抛

## §1 四路会聚（全票/多路互证项 = net 载力 ⭐，13 条）

| 会聚组 | 参与 | net ⭐ |
|---|---|---|
| **manifest 单一 SSOT（本轮宪法落点）** | S-004(W1)+S-105(W2)+S-201(W3)+SF-03 四路全票 | subset-policy manifest 从 `generated/D_domain.tools.demo.json` 的 `_domain/_sg/_ir` **codegen 派生**，禁手写；digest = canonical manifest entry（S-201 ⭐C 字段组：policy_id/group_id/mount_mode/tool_ids_ordered/schema_digest/no_tool_outlet_digest/qwen_format_version/tokenizer_id/grammar_builder_version） |
| **静态 build 门，runtime 零裁剪** | S-102(W2 ⭐B)+S-008(W1)+SF-01 | 超限在 manifest build 时 fail-closed；runtime 动态 trim = 亲手造 drift，禁 |
| **两级装载粒度** | S-001/002/003(W1) | 单候选 = 7 个 seat 功能组（全 ≤7,206）；top-2 = 精确 `_sg` micro-group pair；粗功能组 pair 爆 10K+ **reject** |
| **降级链** | S-101(W2 ⭐C) | device-group → top-2 `_sg` pair → scene macro → clarify/NO_TOOL，全链 manifest 静态定义 |
| **NO_TOOL 虚拟出口 + 三层不支持** | S-204+S-210(W3 ⭐C)+SF-02+D8-8c | grammar 内置非执行出口 `{reason: group_out_of_mount/mvp_unsupported/global_unsupported/safety_or_policy/need_clarify}` → parser 映射 `toolCalls=[]`；**group 外≠族外≠全集外三层分账** |
| **grammar 静态预编译 per group/macro** | S-202(W3 ⭐C)+SF-09 | build 产 grammar artifact，runtime 按 digest 取缓存，缺失即 fail |
| **digest 失配 = 硬拒** | S-203(W3 ⭐C)+SF-05 | `subset_digest_mismatch` infra receipt，禁降级无 grammar 继续跑 |
| **KV 预热 per group/macro + 稳定前缀** | S-104(W2 ⭐C)+SF-06 | 静态 tools/system 前置、动态 DialogueState 后置（home-llm `_cache_prompt` 先例+vLLM/SGLang prefix cache 实践）；换组=显式重预热 |
| **scene macro = C2 codegen 派生** | S-105(W2 ⭐C)+D4-4a | 只引用 C2 state-cells + codegen tool group，Phase-1 只做 schema/digest；Phase-2 `presenter_forced_scene` 优先于低置信自动切（S-106） |
| **训练同源 distractor 固化** | S-009(W1)+S-207(W3 ⭐C)+SF-13 | `same_sg_then_same_domain_then_other, k=3` 进 manifest；top-2/宏样本记 `distractor_pool_group_ids`；train/C6 复用同一 policy digest |
| **分布同构监控** | S-206(W3 ⭐C)+D7-7a | train/C6/runtime 三方记 `mounted_tool_count/token_count/group_id/policy_digest`，分布差异超阈 BLOCKED |
| **C6 schema add-only 扩展** | S-208+S-209(W3 ⭐C)+SF-11 | `C6SubsetContext` 新增字段 + `subset_failure_class`（missing_expected_in_mounted / actual_not_in_allowed / …）——漏挂失败与模型失败分账（S-010 `routing_miss` 同源） |
| **multi-intent 守 E-024** | S-011(W1)+D6 | 连续两句=分句独立装载；单句跨族=D2 top-2/clarify；不训单句多意图 |

## §2 唯一跨路张力（消减仲裁，⭐ commander 裁 + 上抛确认）

**W1 S-008 最坏精确 `_sg` pair = 7,901 tokens（含 system）vs W2 S-103 build cap = 7,200 tool tokens**（cap 推导：8192 − system 29 − DialogueState 3 轮 101 tokens（W2 实算，`docs/c5-training-readiness-grill/e2-subset-w2-decisions.md` S-103 行）− user reserve − generation headroom − digest reserve = exact 7,541 → 保守 7,200）。最坏 pair 工具面 ≈7,872 > cap ~672 tokens。
- ⭐ **裁定建议：守 7,200 cap 不抬**（8K 纪律是北极星 3s 闭环的物理基础）；build 时全枚举 pair 预算，**超 cap 的 pair 静态标 `pair_mode=degraded_clarify`**（该组合不双挂，走 top-1 + clarify 澄清一次定组）——超限 pair 是可枚举的少数（W1 实算仅最坏尾部），比抬 cap/砍 schema 都干净，且完全在静态门内。
- 备选 B：为 pair 模式单设 8,192 满预算口径（挤掉 headroom）——reject：generation headroom 被挤 = 输出截断风险。

## §3 消减账

- 43 条 → 会聚 13 组 net ⭐（§1）+ 1 仲裁（§2）+ 7 条独立保留（S-005 粒度判据 / S-006 bug 库只做 tie-breaker / S-007 top-2 来源 B 主 C spike A 禁 / S-205 think×grammar 默认 no_think 显式记 mode / S-103 预算公式细目 / SF-11 C6 锚重测进 run-auth 清单 / SF-12 三方 tokenizer 对账进 real-model dump）+ 消减掉的重复 ~22 条（四路重叠互证，不丢内容全并入 §1 组）。
- 🐘 elephant 单列上抛：SF-11（subset 语境下 base 10/23 锚要重测——锚源 F-093 `docs/c5-training-readiness-grill/worker-commander-dim10-gate-r-l17-deepen.md:48`）/ SF-12（HF vs mlx-swift tokenizer 预算对账）/ SF-13（manifest 版本混训拒）/ SF-14（同源消费层行为测试，防 gate2 dead-field 同构复发）。

## §4 上抛磊哥细拍清单（E2 形态包 v2 = design 包 + 本轮）

1. **E2-A 装载形态总拍**：⭐ 两级装载（7 功能组单候选 + 精确 `_sg` top-2）+ S-101 四级降级链 —— 对应 design 包 E2-2 的 E-lite 落到可实装粒度。
2. **E2-B 预算口径**：⭐ build cap 7,200 tool tokens + 超限 pair `degraded_clarify`（§2 仲裁）。
3. **E2-C NO_TOOL 出口 + 三层不支持分账**：⭐ S-204+S-210（安全灵魂项）。
4. **E2-D Phase-1 范围**：⭐ manifest codegen + grammar artifact 预编译 + C6 add-only schema + 六轴 digest receipt（construction only，硬括号照 design 包）。
5. **E2-E 4 条 elephant 处置**：⭐ 全部纳入对应 R7-gated 清单（不新增 R7-safe 工作）。

拍后级联：本轮 43 条 status proposed→locked（按拍）；design 包 §4 四子决策同步收口；landing-matrix E-2 行更新；gate7 SPEC（G7IMPL）§E-2 联动段定稿；retrain-c5 carrier 补 subset 字段。
