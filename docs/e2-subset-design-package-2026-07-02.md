---
status: design_package_for_magnet_ratification
artifact_kind: e2_subset_design_decision_package
authority: proposal_not_ssot（磊哥细拍后落 grill SSOT + landing-matrix）
created: 2026-07-02
author: claude-commander（纵切综合）
evidence: L4-e2-subset-materials.md（%43，真 tokenizer 实算 + 先例 file:line）+ commander 亲算（126,275/159,899 tokens）
upstream_locked: D-017 ②「E-2 subset 方向 locked」；本包只拍【实装形态】
---

# E-2 subset 实装形态 design 包（供磊哥细拍）

## §0 问题的真形状（真 tokenizer 口径，全部实测非估算）

- 562 工具目录（=10 族 MVP **全集**）compact JSON = **126,275 tokens**；default 序列化 = **159,899**（超 Qwen3 131,072 绝对上限）。
- **族级装载也不够**：seat 单族 **35,698**（超 32K！）、light 22,757 / screen 22,239 / ac 14,366 / volume 11,551 全超 8K；只有 door/sunroof/window/wiper/fragrance 五小族能进 8K。
- token 成本由 **schema 长度/参数形态**主导而非工具数（volume 32 工具 > door 48 工具的 token）。
- 训练代码早已内证：`C5LoRATraining.swift:2189-2205` `sameFamilyDistractors` 注释明写「不渲全 562(token 爆)」——**训练侧样本 surface 本来就是小工具面**，E-2 实质 = 让 runtime/评测面与训练面同构。
- 北极星约束：3s 端到端闭环 → prefill 越小越快，demo 实用预算应对齐 **≤8K**（32K 是上限不是目标）。

## §1 五个候选形态（L4 §4 全料，此处判决式浓缩）

| 形态 | 一句话 | 8K 可行 | 致命弱点 |
|---|---|---|---|
| A 族级动态装载 | NLU 预路由→挂单族 | ❌ 5 大族超 8K | 单独不充分；错族=目标工具不在面 |
| B 场景宏静态 subset | demo scene→预挂小包 | ✅ | 泛化弱=「剧本工具包」，偏离「随便说」叙事 |
| C device 级装载 | 目标 device+distractor（191 device 粒度） | ✅ | 需 entity linker；模糊说跨 device |
| D 受限解码 grammar | 只约束输出不减 prompt | —（不解决 prompt） | 单独无用；grammar 与 prompt 面不同源=新 drift |
| E 组合 | A/C 解 prompt + D 解输出 | ✅ | 复杂度最高，五方同源 receipt 要求最重 |

## §2 ⭐ 推荐：E-lite 两层组合（C′ 装载 + D 输出门），分两阶段落地

**装载层 C′ = 「意图收缩驱动的 device-group 装载」**：
- L1 明确指令走规则快路**不碰模型**（架构铁律，不变）。
- 慢路（模糊说）：NLU/clarifyTag 产 **domain/device 候选（top-2 族或 device-group）** → 从 D-domain catalog 派生该候选集工具面 + home-llm 式同族 distractor（与训练 `sameFamilyDistractors` 同构）→ 目标 ≤8K（大族按 device-group 切：seat 按 位置×功能 分组后单组 ≤8K，L4 表推算可行）。
- 候选置信不足 → **降级链**：top-2 双族装载（若 ≤8K）→ 场景宏兜底（B 作降级态非主态）→ 规则澄清/拒识（R2）。
- **场景宏（B）保留为 demo 兜底态**：现场脚本化段落用 scene manifest 预挂，泛化段落走 C′——两态同一 manifest 机制，不是两套系统。

**输出层 D = grammar 白名单同源**：
- `mlx-swift-structured`（XGrammar，raw 区已有，README 给了 Qwen3 tool-calling 语法先例，简单 grammar 性能损耗 <3%）约束输出工具名 ∈ 装载面 + arguments ∈ schema enum。
- 🔴 grammar allowed set 与 prompt mounted set **同一 manifest 同一 digest**（否则制造新 surface drift）。

**同源铁律（gate3 扩展为六轴，修 XAUDIT-e2pkg P1-1）**：`train target tool names ⊆ train prompt tools ≡ C6 expected ≡ runtime prompt tools ≡ grammar allowed ≡ model actual 审计集`——gate3 原始四方（train target × train prompt × C6 expected × model actual，<80% exit 65）一轴不丢，加 runtime prompt 与 grammar allowed 两轴。全部由**单一 subset-policy manifest（codegen 从 D-domain catalog 派生，禁手写）**生成；mounted/prompt/grammar 三者 digest 关系 = `runtime prompt tools` 与 `grammar allowed` 引用同一 manifest 条目故 digest 恒等。**Phase-1 receipt 必含字段**：`target_in_prompt / expected_in_mounted / actual_in_allowed / prompt_tools_digest / grammar_tools_digest / subset_policy_digest`，任一失配 → BLOCKED。

**分阶段**：
- **Phase-1**：subset-policy manifest codegen + 训练样本装载逻辑按 manifest（distractor 已同构，改动小）+ C6 expected 按 manifest 过滤 + receipt 六轴 digest。🔴 **硬括号（修 XAUDIT-e2pkg P2-2）：construction only——schema/fixture/codegen/receipt 形态；no true data generation / no training run / no C6 acceptance / no candidate claim**；伴随 gate7 也只是 design/code/fixture 联动，真实生成仍等 explicit run auth。**不含 runtime NLU 预路由实装**（runtime backend 的活，R7 后置）。
- **Phase-2（runtime backend 立项时）**：NLU 预路由 + 降级链 + mlx-swift-structured 端侧集成（受限解码 vendor 当前 DEFERRED 状态不变，Phase-2 才解）。

**E-lite 残留 cons / failure modes（修 XAUDIT-e2pkg P2-1，上抛必读不隐藏）**：
- C′ 装载层：模糊说可能同时涉及 ac/seat/方向盘加热等跨 device；entity linker 置信不足时漏挂/错挂（降级链是缓解非消除）；191 device 粒度过细加剧漏挂——device-group 分组粒度本身要 grill。
- D grammar 层：不降 prompt token；复杂 grammar 有推理延迟（README 实测简单 <3%，复杂可到 ~10%）；端侧 vendor integration 仍 DEFERRED；allowed set 若与 manifest 脱钩 = 新 surface drift。
- E 组合整体：错因面最宽（预路由/缺工具/grammar/模型语义/DemoGuard 五处都可能），receipt/debug 要求最重，receipt 不全即 fake-green 温床。

## §3 为什么不选纯 B / 纯 A / 纯 C（steelman 后砍）

- 纯 B：demo 最稳但把「语义广听懂」的产品灵魂降级成剧本——磊哥北极星「客户随意说 10 族」要泛化装载。
- 纯 A：seat/light/screen/ac/volume 五大族 8K 装不下，物理不成立。
- 纯 C（device 级无 grammar）：小模型输出错形/幻觉工具名无门；D 层是 0/34「降误吸内核」的直系继承（具名工具拆判定面+受限解码本就是范式翻案的两条腿）。

## §4 磊哥要拍的 4 个子决策

| # | 问题 | ⭐ 推荐 |
|---|---|---|
| E2-1 | runtime prompt 预算目标 | ⭐ **8K**（3s 闭环 prefill 友好；32K 仅上限） |
| E2-2 | 装载形态 | ⭐ **E-lite（C′ device-group + B 兜底 + D grammar）** |
| E2-3 | Phase-1 范围 | ⭐ **manifest codegen + 训练/C6 侧同源 + 五方 digest receipt**（runtime 预路由 Phase-2） |
| E2-4 | E-2 manifest 是否 Phase-1 就建 top-2 双族/跨族 fallback 的 **schema+digest**（仅建模，不做 runtime 预路由实装） | ⭐ **建**（只建 schema 防做死，成本低）。🔴 约束来源（已决，非本问待决，修 XAUDIT-e2pkg P1-2）：demo「连续两句」splitter 是已决特性（grill SSOT H 组）+ **E-024（⭐C proposed 在案未 supersede）：C5 前只保留 C6 multi-call fixture，不把一句话多意图当 LoRA 主训练目标**——所以本问只拍 manifest 建模范围，不重开训练目标、不把「已决连续两句」当本问理由 |

拍后级联：grill SSOT 新增 E2 系列决策 + landing-matrix gate8/E-2 行更新 + gate7 SPEC（G7IMPL）§E-2 联动段定稿 + retrain-c5 change carrier 补 subset 字段。
