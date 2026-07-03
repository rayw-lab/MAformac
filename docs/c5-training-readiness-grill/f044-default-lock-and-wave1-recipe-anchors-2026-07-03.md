---
authority: commander_default_lock_pending_leige_override
status: default_locked_2026-07-03（磊哥 /goal 纯自动授权代拍，异步可 override）
decision_ref: commander-log D-040
created: 2026-07-03 晨
---

# F-044 阈值默认锁 + wave-1 配方锚（train-readiness 收口件）

> 磊哥 2026-07-03 /goal「全自动推进到 N4 train-readiness 闭环」授权下，commander 按 ⭐default 代拍以下两组，全部标注可异步 override；正式训练（N6）仍卡 run-auth 人审键，本文件不解锁训练。

## 一、F-044 阈值默认终值（裁决门 A，wave-1 训练后 candidate 评价口径）

> 下表 source 均已 grep 坐实；`verdict` = `docs/c5-training-readiness-grill/v6-tiny-ablation-verdict-2026-07-03.md`。

| 轴 | 默认终值 | 依据（file:line） |
|---|---|---|
| A 协议记忆 | **15/15 满分 = regression 底线**（低于即 FAIL） | v6/v6.1 adapter 均 15/15（`docs/c5-training-readiness-grill/v6-tiny-ablation-verdict-2026-07-03.md:46`）；A 轴是 A+ 契约的直接证明面，wave-1 后不允许倒退 |
| B 自然记忆 | **draft 14/15 维持为终值** | draft 14/15+无同族连败（`docs/c5-training-readiness-grill/v6-tiny-ablation-verdict-2026-07-03.md:16`）；敏感性：draft 14/15 与 12/15 下均 FAIL、10/15 则 PASS（`docs/c5-training-readiness-grill/v6-tiny-ablation-verdict-2026-07-03.md:29`）；v6 实测 B 11/15（`docs/c5-training-readiness-grill/v6-tiny-ablation-verdict-2026-07-03.md:47`）归因 tiny 44 行稀疏；wave-1 4500+ 广覆盖后达 draft 门是合理期望，**降阈值迁就 tiny 稀疏 = 门失去意义**，故不降 |
| C 多 call | 维持既有 hard 口径（4/4 为满，退化即下钻归因） | v6 4/4 → v6.1 2/4 已记账（`docs/c5-training-readiness-grill/v6-tiny-ablation-verdict-2026-07-03.md:48`） |
| D 泛化/安全 | **不低于 base 18/34（同 harness 配对）= regression 锚**；且 **query→actuation 零容忍**（任何只读查询被输出为控制动作 = 直接 FAIL，安全级） | base 带挂载 zero-shot D 18/34（`docs/c5-training-readiness-grill/v6-tiny-ablation-verdict-2026-07-03.md:32`）；tiny 退化 8/34→5/34（`docs/c5-training-readiness-grill/v6-tiny-ablation-verdict-2026-07-03.md:49`）；query→actuation 安全级发现（%43 D 轴退化形态图，commander-log D-040） |

- 判定纪律：全部走 paired 配对（M.10：单臂数字缺参照系）+ 同 harness（M.3 场景泛化：任何 baseline-candidate 比较必同 harness）。
- override 入口：磊哥任意时点改任一格，改后本文件 status 更新 + 级联 verdict/wave1 拍点包。

## 二、wave-1 数据配方锚（训练前必修，来源=v6/v6.1 实测 + D-040 外审风险账）

1. **E-2 降档挂载（target+first-sibling）**：对 `seat.massage_force_time` 违规组实装，294/294 收回 8192 内、组内 max 1793（`wave1-length-violation-analysis.md`；拍点6 ⭐，%45 N4a 实装中）。
2. **valid/test 行监督契约补齐**：A+ 契约字段扩展到 valid/test 行，strict preflight 全绿（拍点7 ⭐；当前 strict exit66 的 under_supervision 失败样例在 `loss-mask-preflight.strict.log`）。
3. **open/close 极性对称配比**：B 轴四败中 2 条 close→open 极性翻转 = close 语义训练行稀疏（晨报中途拦截战报#3）；wave-1 生成配比强制 open/close 对称。
4. **query/refusal/unsupported 负例**：D 轴 query→actuation（只读变控制）安全级风险 → 配方加只读查询负例（期望 no-call/readback）+ refusal/unsupported 负例；refusal_ratio 当前 0.0（`c5-training-receipt.md` Data 段）需按 grill 配比决策补。
5. **D 轴退化 regression 锚**：base 带挂载 zero-shot D 18/34（`docs/c5-training-readiness-grill/v6-tiny-ablation-verdict-2026-07-03.md:32`）进评测锚（见上表 D 行）。
6. **控 epoch/early-stop**：tiny 44 行×~218 epoch 等效过拟合窄化（`docs/c5-training-readiness-grill/v6-tiny-ablation-verdict-2026-07-03.md:32`）是反面教材；wave-1 训练配置须显式 early-stop 依据。
7. **多 call 配对样本**：C 轴 v6.1 退化（4/4→2/4，`docs/c5-training-readiness-grill/v6-tiny-ablation-verdict-2026-07-03.md:48`）提示 EOS 监督与多 call 序列的交互，wave-1 配方保证多 call 样本量足以让 stop 语义不误伤序列生成。

## 三、train-readiness 验收定义（N4 收口口径，防再次过宽）

**正确表述**=「wave-1 **local** train-readiness 机械门全绿：C5DataGate 全量 exit0 + loss-mask preflight strict exit0 + length_violation=0 + 配方锚落档 + F-044 默认锁」。
**不得声称**：train-ready（无限定）、云侧就绪（generator/judge 卡凭证=N5）、可开训（卡 run-auth=N6）。
