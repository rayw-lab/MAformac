---
authority: p3h_harness_v3_grill_overnight
artifact_kind: grill_decision_matrix
status: proposed_running_on_default_per_overnight_auth
created: 2026-07-03 凌晨
seed: v6 probe 全轴全臂 empty → commander 四步排除法（prompt面一致→loss shift 正确→labels 对齐 17/17→teacher-forcing 17/17 完美）→ 真根因=probe 无 tools 挂载
---

# P3H v3 grill — probe tools 挂载契约（GF-149~156）

## 证据链（commander 亲核一手，排除法四连）
1. 全轴全臂 empty（68 case×2 臂），但训练 loss 0.072、preflight ratio 1.0。
2. 排除：probe/训练 prompt 面渲染一致（think 块两面都有）；loss shift 标准；labels 对齐 17/17 精确；**精确 teacher-forcing 17/17 满分**（早前 14/18 是 commander 自己 span 测量误差，教训：span 起点必须用 assistant_tokenization 的 start，勿用 gen 长度推）。
3. 真根因：训练渲染 `apply_chat_template(messages, tools=tools)` 带 **tools 目录**（E-2 两级挂载，start=737 即前文 737 token 含 subset 工具 schema），probe harness render_prompt **无 tools 参数** → OOD → 丢 `ac_`+重复循环。
4. 🎉 闭环行为证据：带 tools 挂载生成——A 轴协议串完美 `open_ac_cooling_mode`；**B 轴自然句「打开空调制冷模式」同样完美** = D-domain tiny 训练下自然中文迁移的首个正面样例。
5. 次级：`</tool_call>` 后模型不停（loss span 未含 `<|im_end|>`，EOS 无监督）→ 重复到 max_tokens；parser 取首 call 可容忍，但需决策。

## 决策矩阵
| id | 议题 | 选项+⭐default | 量化理由 | 防惨败检查 | status |
|---|---|---|---|---|---|
| GF-149 | probe prompt tools 挂载 | A. 不挂（现状）；B. ⭐必挂，per-case 与训练同 surface：A/B/C 轴用该 case 对应训练行的 `tools` 字段原样（A/B 同 parent 行、C 用其工具所属 subset 组的挂载）；挂载缺失=exit 2 invalid_probe | 训练面带 tools（E-2 契约），无 tools=OOD 崩坏（实证） | 防 v5/v6 输入面错配第三次复发；tools 挂载是 same-surface 契约的一等维度 | proposed |
| GF-150 | D 轴挂载策略 | A. 不挂；B. ⭐按 E-2 subset policy 给 D 轴 case 的 expected tool 所属功能组挂载（与未来 C6 eval 挂载规则同源）；策略写进 probe receipt | D 轴 report-only 也要 same-surface 才有报告价值 | 防 D 轴证据在错误 surface 上采集 | proposed |
| GF-151 | decode 契约补 tools_mount 字段 | A. 契约不管；B. ⭐`decode-contract` 增 `tools_mount_policy` + per-case receipt 记 `mounted_tool_count`/`mount_source`（GF-144 八字段之后第九字段） | GF-144 契约漏了此维度=契约自身盲区实证 | 防「同 decode 契约」声称在挂载不同下仍成立 | proposed |
| GF-152 | 渲染断言升级 | A. 只断言 think 块；B. ⭐增断言：prompt token 长度 ≥ mounted tools 下限（如 A 轴 ~700+）+ 含 `<tools>` 段标记，fail-closed | GF-142 断言只覆盖 think 块，挂载缺失照样过 | 防断言假绿 | proposed |
| GF-153 | EOS/停止监督 | A. 维持 target 到 `</tool_call>`；B. ⭐v6.1 数据 trainable span 延至 `<|im_end|>`（模型学会停）；本轮 probe 先由 parser 取首 call 容忍 | 重复到 max_tokens 浪费 4×延迟且污染 raw 证据可读性 | 防生成不停被误读为病理 | proposed（数据面改动，下轮 build 生效） |
| GF-154 | 本次 v6 probe run 定性 | A. FAIL；B. ⭐INVALID_PROBE（harness 缺陷，非模型失败）——与 v5 重标同构；但注记「正面样例证据」：A/B 轴样例级完美（commander 行为探测 2 case） | 排除法+闭环生成实证 | 防把 harness 缺陷记成模型/范式失败（v5 教训直接复用成功） | proposed |
| GF-155 | 修复后重跑 | A. 只跑 A/B；B. ⭐四轴全重跑（paired），阈值仍用 F-044 default（A 15/15、B 14/15），run 目录 v6-probe2 | 数据/训练无需重做（teacher-forcing 已证），只重 probe | 防部分重跑留盲区 | proposed |
| GF-156 | span 测量纪律 | ⭐teacher-forcing/对齐类复算必须用 `assistant_tokenization` 返回的 start/atoks，禁用「另一渲染的长度」推 span | commander 自己 14/18 假信号实证（几乎误导向 adapter 加载嫌疑） | 防复算工具自身引入假信号 | proposed |

## 融合义务
lock 后：GF-149~152 并入 F-044 v6 spec decode/tools 契约段；GF-153 进 v6.1 数据契约；GF-154 级联 verdict 文件；GF-156 进 lessons 元认知段。
