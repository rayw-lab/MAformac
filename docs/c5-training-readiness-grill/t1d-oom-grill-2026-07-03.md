---
authority: grill_locked_default_pending_leige_override
series: T1D
status: locked_2026-07-03（窄口径，D-046 范式；弹药=codex runbook 矩阵 + commander dim34 辩证，无需另开 fan-out）
decision_ref: D-053/D-054/D-055/D-056
basis: CODE-2026-07-03（main pin b33d8eba）+ DATA-WAVE1-SUBSTRATE-v2（见 docs/BASELINE-REGISTRY.md）
---

# T1D-OOM 诊断 grill（窄口径 lock）

> 决策矩阵主体 = `t1-oom-diagnostic-runbook-2026-07-03.md` §3（D0-D7）**全盘采纳**，本档只记增量决策与 lock 状态，不复制。

| ID | 决策 | verdict |
|---|---|---|
| T1D-001 | 执行序 = **D0 →（按 D0 判据分流）D1 / D1b / D2 → D4 组合**；D3 仅作旁证；D5/D6 高风险域不进本轮（进入需磊哥单签） | locked |
| T1D-002 | 🔬 **D0 双假设判据**：H-act（长序列×batch4 activation 驻留；预测=首个 train step 峰值 ≫ val 峰值且与 batch 内 token 数强相关）vs H-sup（监督面 2.56x；预测=峰值随 supervised token 占比变化）。D0 memory profile 必须分阶段采样（load 后/val 中/val 后/train step1 forward/backward/optimizer），能判则判，不能判如实写 indeterminate | locked |
| T1D-003 | ➕ **D1b token 预算 batching** 进矩阵（低语义风险大杠杆）：利用自有 `maformac_iterate_batches` 按 token 总量组批（预算参数显式，如 total_tokens_per_batch≈8192-16384），数据零丢失；实现在 **snapshot 副本**（run 目录，先例=T1-smoke 的 `c5_mlx_train_loop.snapshot.py`），不动 repo 代码；若 D1b 胜出，repo 化走正式 PR+审 | locked |
| T1D-004 | 一切 run 遵 runbook §2 停线条件 + §4 硬产物 + `diagnostic_not_candidate` 词表；每 run receipt 必 cite basis_id（BASELINE-REGISTRY 规则）+ 资源包络两列（peak memory/wall clock，维度三推论） | locked |
| T1D-005 | 通过词=`T1D_DIAGNOSTIC_PASS_<knob-set>`；候选化五步照 runbook §5（含磊哥 run-auth 单签），本轮不做 | locked |
| T1D-006 | 执行分派：D-run 执行=%44（harness 主刀，xhigh）；receipt 审=%43；commander 亲核每个 D-run 的 exit/profile 一手 | locked |
