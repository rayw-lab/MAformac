---
authority: v6_tiny_ablation_commander_verdict
run_auth: v6-overnight-run-auth-2026-07-02.md
data: P12-v6-build（44 行，A+ 契约，镜像门双亲核）
train: 600 iters loss 4.16→0.072，NONFINITE=0，配方与 v5 冻结一致（单变量=数据契约）
probe: v6-probe2（harness v3 tools 挂载，paired base/adapter，68 case×2 臂，decode 契约 v2+tools_mount 字段）
created: 2026-07-03 凌晨
---

# v6 tiny-ablation verdict（commander 判定）

## 结果表（exact/order-sensitive match）
| 轴 | base | adapter | paired delta | 门语义 | 判定 |
|---|---|---|---|---|---|
| A 协议记忆 15 | 3 | **15** | **+12** | hard（draft 15/15） | ✅ **PASS 满分** |
| B 自然记忆 15 | 12 | 11 | **-1** | hard（draft 14/15+无同族连败） | ❌ FAIL_WITH_ATTRIBUTION |
| C 近泛化 4 | 4 | 4 | 0 | observe | 记录（case 偏易，base 即满） |
| D 原 C6 34 | 18 | 8 | **-10** | report-only | 记录（过拟合窄化信号） |

## 裁决-A 核心问题的回答
**「A+ 契约修复是否解 v5 的 NO_TOOL/协议崩坏」→ YES**：同配方同 harness 下 A 轴 adapter 0 形态（v5）→ **15/15 满分**；empty 全轴归零。数据契约（监督范围）就是 v5 主因的实证闭环（v5 四根因 #1 坐实为主导）。

## B 轴 FAIL 的 attribution（四败逐条一手）
| case | 输入 | 期望→实际 | 形态 |
|---|---|---|---|
| B-012/013 | 关闭(主驾)空调设置页面 | close_ac_set_interface→**open**_ac_set_interface | 🔴 极性翻转（同族连败，触发 F-044 同族规则） |
| B-010 | 打开空调设置页面 | open_ac_set_interface→open_defog_mode | 细分设备混淆 |
| B-014 | 打开空调出风口 | open_airoutlet→open_ac | 细分设备混淆 |
attribution=tiny 44 行数据稀疏（「关闭」自然语义仅 2 训练行且 close_ac 族被 C6 排除掉；细分设备每个 1-2 行）——**形态与数据覆盖一一对应，非链路/范式缺陷**。阈值敏感性：draft 14/15 与 12/15 下均 FAIL，10/15 则 PASS；**终值仍待磊哥 lock，本判定不自拍**。

## paired 配对的当晚价值（磊哥六拍④实证）
无 base 配对，B 11/15 会被读成「学到 73%」；配对暴露真相：**B delta=-1、D delta=-10**——tiny 训练教会协议输出（A +12），自然理解 base 本就会（带挂载 zero-shot B 12/15、D 18/34=base 锚首个同 harness 真值），44 行×~218 epoch 等效反而窄化泛化。
**对 wave-1 的直接配方含义**：①全量广覆盖（4.5k）+ 控 epoch/early-stop 是 B/D 提升的正路 ②open/close 极性对称配比必须进数据配方 ③D 轴退化幅度是 wave-1 训练的 regression 监控锚。

## verdict 词表（GF-154/F-044，不升格）
`A_PASS_TINY_SCOPE + B_FAIL_WITH_ATTRIBUTION(data_sparsity) + probe1=INVALID_PROBE(tools挂载缺失,已修复重跑)`。不声称：范式整体成立/C6 acceptance/candidate/模型质量/V-S-U-PASS。
