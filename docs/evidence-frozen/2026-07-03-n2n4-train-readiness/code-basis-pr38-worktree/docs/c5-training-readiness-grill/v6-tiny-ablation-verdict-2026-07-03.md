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

## 附录：D 轴退化形态图（%43 深挖，2026-07-03，一手 `runs/tiny-ablation-adjudication-A/v6-d-axis-degradation-map.md`）
集合关系：base 18 ∩ adapter 8 = 6 both；**base-only 退化 12**；adapter-only 提升 2（window 百分比行）；neither 14。
六形态：①`open_*` 过度泛化侵占 raise/lower/adjust（6 条，亮度/风速重灾）②close/否定极性反转（3）③window 数值化入侵简单开（2）④🔴 **query→actuation（`query_ac_temperature`→`open_ac_temperature_to_max`，只读变控制=安全语义级风险类）**（1）⑤adapter 仅胜在显式百分比行（2，但同配方制造了③）⑥多 call 首调丢失+次调极性漂移共存（MP-028）。
**wave-1 配方锚 6 条**：D 轴聚合数≠纯模型质量（退化集中于 LoRA surface 语义族碰撞）/ window 百分比行需负例配平 / open-adjust-raise/lower 数据分离 / query 反执行负例 / 否定纠正对监督 / 保留 ordered-call 证据+双 call 配对样本。

## 附录2：v6.1 EOS 增量对照（同配方单变量=trainable span 延至 `<|im_end|>`）
| 轴 | v6-probe2 adapter | v6.1 adapter | delta |
|---|---|---|---|
| A | 15/15 | **15/15** | 0 ✅ 协议记忆无损 |
| B | 11/15 | 11/15 | 0 |
| C | 4/4 | 2/4 | -2（empty +1） |
| D | 8/34 | 5/34 | -3（empty +3） |
**重复病理：repeated_end 68/68 → 1/68**（EOS 监督生效，GF-153 主目标达成）；残余 4 parse_error 下钻定性（%44）：全是 malformed/截断 JSON，且这 4 case 在 v6 里本就 repeated-tail 不稳（v6 碰巧首 call 可解析）——EOS 把「无限重复」压成「早停截断」，是同一数据稀疏在不同 stop 语义下的两种表象，非净退化。C/D 微降+empty 增=EOS 让模型对边缘 case 更早停（「沉默化」），tiny 规模下的次级效应，wave-1 广覆盖下再评。

## 附录3：wave-1 proto build 全量数据门首跑（2026-07-03 凌晨，%45）
- **build：4500 样本（train 4100/valid 400/test 128）38.8s**；工具覆盖 expected 314/562、mounted 395/562、55 subset 组、tools/row avg14.5 max48。
- **C5DataGate 全量 exit0 `data_gate_ready`：4500 行 must_not_train=0/parent_overlap=0/heldout_axis_overlap=0/row_overlap=0/tool_format_fail=0/quarantine=0/C6 交集=0**——磊哥「数据门跑完」全量版兑现（协议串模式，自然句待云语料）。
- 🔴 **暴露 wave-1 训练前必修 gap**（tiny 44 行未暴露）：MLX preflight strict exit66——`max_token_length=8982 > max_seq 8192`、length_violations=294、valid/test 行 under-supervised（当前契约只监督 train 行）。→ 量化解已出（%45 分析，`wave1-proto-build/wave1-length-violation-analysis.md`）：294 条违规**全部**来自 `seat.massage_force_time` 单一 subset 组（17 工具挂载，8935-8982 token=E-2 已知 degraded 重灾族）；三解——max_seq 9000 即收全 / ⭐**E-2 降档挂载（target+first-sibling）294/294 回 8192 内且全量 max 仅 1793**（训练成本同降）/ target-only max 995。+ valid/test 行监督契约议题。与 wave-1 5 拍点同会话拍。
