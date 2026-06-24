# L09 — 样本可观测性 + dataset receipt + 训练前 dry-run 样本审计

> pre-propose decision-pack，纯搜证 + 假想验证。落 docs/research 供 retrain-c5 propose 用，不执行训练/评测/数据生成。
> 注：findings/premortem/must_answer/paper_findings/clone_findings/external_claims 等 JSON 字段以英文 ASCII 表达（规避 harness 对 JSON-string 内 CJK 多字节字符的解析 bug），本 full_markdown 为完整中文一手档，落盘成 lens9.md。

## Summary
样本可观测性是 0/34 的直接 P0 解药。0/34 根因不是模型/配方（A2 已证 rank16Mainline 正确），而是样本不可观测——buildNoCallSamples（C5LoRATraining.swift:2333-2348）写 metadata removedToolID 声称删 tool_call_frame 却没物理执行 tools.removeAll，446 个 no-call 样本每条 tools 仍含 tool_call_frame（user 有效车控意图+答案 NO_TOOL=矛盾监督），dataset receipt 只看聚合数 no_call_counterfactual_count:456 从不下钻样本级。这是 claim-vs-reality 铁律1 数据版（enforce 非 declare）。

## 方法论结论
① 每条 D-domain 样本带 P0 三字段：no_call_target_present（从样本实际 tools 计算 target 物理不在，不读 metadata）/ tool_surface_digest（train-eval surface 同源样本级锚）/ label_conflict_flag（必 0）。P1：mask_span_digest / expected_state_delta（与 C6 同源）/ lineage 四件套（已有 lineageGroupID/seedParentSemanticID/generatorModelID/generatorCallID）。P2：source_type / judge_model_id / split（已有）。
② receipt 报逐字段分布+硬断言非顶层聚合（no_call_target_present 必 N/N true、label_conflict 必 0）。
③ 训练前 dry-run sample audit fail-closed exit 65：逐 token 打印 mask span + no-call 物理验 target 不在 + receipt 硬断言 + surface digest 取交集非空。

## Findings（每条带 source，详见 findings 字段）
- F1 0/34 直接根因=样本不可观测（8d D4.1 一手坐实 446/446）high
- F2 现有 receipt 是顶层聚合受理单非样本级审计（本机实测 19 字段无 label_conflict）high
- F3 训练前 dry-run mask 打印是业界标准（HF/TRL/Axolotl，Open-Assistant#1974）high
- F4 FC 数据集 no-call 业界是物理丢 tool 再 relabel，与 MAformac metadata 声称丢相反（APIGen/ToolACE/Hammer/When2Call）high
- F5 Datasheets/Croissant 取内核砍全量 medium
- F6 DVC/lakeFS/OpenLineage 量产越界 demo 不引（home-llm 1364★ 无之即可靠）high

## Clone/一手锚
C5DataGate.swift:3-137（已有 sampleID/masking 4flag，缺 no_call_target_present/label_conflict/tool_surface_digest）；C5TrainingSample(C5LoRATraining.swift:251-307 已有 lineage 四件套)；c5-training-receipt.json（35 顶层字段全聚合无样本级矛盾断言）；home-llm data/generate_data.py:23/32/181（规则模板物理构造 answer）；p1c-training-grill-decisions.md Q12（已有 assistant_mask_fixture，补逐 token 打印+no-call 物理验两探针）。

## 假想验证（详见 hypothesis_verification 字段）
预测能直接阻止 0/34 复发，成本极低。字段集 P0/P1/P2 + dry-run 门四步（mask span 打印 / no-call 物理验 / receipt 硬断言 / surface 交集）。失败模式：验证器读 metadata 循环失守 / 字段加了 receipt 仍报聚合数 / 字段膨胀 13 字段 matrix。

## Pre-Mortem 三分类（详见 premortem 字段）
Tiger：验证器读 metadata flag 而非样本实际内容 / receipt 仍报顶层聚合数 / dry-run 只验 mask span 不验 no-call 物理。Paper-Tiger：需完整 Croissant+DVC 套装（假，home-llm 证不需要）/ 拍死 13 字段 matrix（假，Phase 0 不拍死生产值）。Elephant：masking_coverage 4 bool flag 本身同类陷阱需一并升级物理验 / dry-run 4956 行需抽样肉眼+全量机械断言双轨 / A2 D-domain 后 no-call 物理删对象变 retrain-c5 propose 必带。

## Must-Answer 5 条（详见 must_answer 字段）
1. prevents_0_34: yes（P0 直接解药，缺 no_call_target_present 一字段即复发）
2. vs_rank16mainline: support（不碰配方）
3. requires_a2_surface_change: no（数据治理层与 A2 code surface 正交，唯一耦合在 retrain-c5 propose）
4. introduces_deferred: no（纯方法论落 docs/research，dry-run 门写 OpenSpec task 正是下一步主线）
5. priority_self: P0