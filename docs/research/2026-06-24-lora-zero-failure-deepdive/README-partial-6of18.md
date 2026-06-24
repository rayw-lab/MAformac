> ⚠️ **PARTIAL — 基于 6/18 路成功**（L01/L02/L03/L05/L06/L15；其余 12 路 rate-limited 待补跑后重综合）。本报告结论不完整，仅供过渡参考。

---

# MAformac LoRA 零容错调研 — 综合官报告（probe 式收敛）

> as-of 2026-06-24 ｜ 综合官 = Opus 4.8 (1M) ｜ 边界 = pre-propose 弹药，不执行训练/评测/voice ｜ 锚 = Phase 0 已接受 24 grill 决策 + rank16Mainline SSOT + 0/34 8D 复盘

## 0. 数据完整性披露（最优先，诚实标注）

派单声称 **18 路 finder**，workflow return 实际只回传 **6 路**（L01/L02/L03/L05/L06/L15）。**其余 12 路未在 return 中**。我不编造未收到的 finder 内容。下方所有矩阵/排序只对 6 路负责，缺失路标 `[未回传]`。

🔴 **主线程必做**：① 回查 `/private/tmp/.../tasks/<taskId>.output` 是否被系统清理；② 确认 workflow 是否实际只跑了 6 路还是回传截断；③ 按 7-lens 推测缺失路可能含的 **P0 盲区**——尤其【BFCL/tau2 评测 harness】（C6 four-layer 同源）和【safety/clarify 拒识训练】（demo 灵魂），这两类若缺失是真盲区，必须补。

## 1. 每路一句话精华

- **L01 训练栈**：本机 M5/32GB 训 1.7B-4bit peak 仅 11.4-12.2GB/no_oom，**训练栈跑不跑得动从来不是 0/34 root cause**——堵死「该不该上云/换硬件」伪讨论 + 坐实 rank16Mainline SSOT=scale20（旧 receipt scale32 是过期 A/B 值）。
- **L02 loss-mask**：mlx-lm 单 offset 前缀掩码对 C5 当前 80/80 单轮样本正确，**mask 不是主 0/34 根因但能造一种新变体**（多轮漏训中间工具调用轮）；offset 验证器已在场。
- **L03 byte-parity**：训练 assistant 段带 `<think>` 块 4 token、端侧默认不带 = 端侧少 4 prompt token offset 漂，是**比 loss-mask 更隐蔽的 0/34 路径**；gate 骨架已在 `C5LoRATraining.swift:1612` 但 endpointRendered=nil 从未真接。
- **L05 中途门**：0/34 是 loss 健康/行为全塌 → 中途门**必须是行为生成门非 val-loss 门**，iter50 就能 catch 省 ~550 iter；callback 停不了 stock loop 必须 raise。
- **L06 端侧解码**：**翻案 grill SSOT「端侧无 GBNF」**（XGrammar 已 ship Swift Package）；但**约束解码阻止不了 0/34**（语义塌缩非语法错），甚至可能把 0/34 变成更隐蔽的合法但错。
- **L15 home-llm**：home-llm 用 19 generic intent 工具能 work 因【封闭词表小+工具子集化+重 distractor】**反向印证 A2 D-domain 正解**；数据链路是教科书最佳实践可 adopt；LR2e-4 照搬必发散。

## 2. 总体认可度

| 路 | 自评 priority | 综合官认可 | 调整说明 |
|---|---|---|---|
| L01 | P2 | ✅ 认可 P2 | escape_hatch，排除硬件伪 root cause |
| L02 | P1 | ✅ 认可 P1 | 验证门非阻断器 |
| L03 | P0 | ✅ 认可 P0 | 隐蔽 0/34 路径，gate 未闭环 |
| L05 | P0 | ✅ 认可 P0 | **最高优先**，直接命中 GOV6 |
| L06 | P1 | ✅ 认可 P1 | 翻案有价值但非病因解药 |
| L15 | P1 | ✅ 认可 P1 | 反向印证 + 警戒 |

**6 路自评 priority 全部经独立核对认可，无需调整。** 所有路严守 Phase 0 deferred 边界（纯搜证 + 假想验证 + 产 task 弹药）。

## 3. 核心收敛：0/34 的真根因层与本轮调研的对应

| 0/34 根因层 | 是否本轮新增防护 | 对应路 |
|---|---|---|
| generic frame 单工具判定面爆炸（surface） | A2 已修，L15 反向印证 | L15 |
| masking 446 假删 | offset 验证器已在场，L02/L04 防多轮变体 | L02 |
| train/eval/runtime surface 异源 | A2 已修，L05 门强依赖同源 | L03/L05 |
| 模板数据退化 | L15 警戒（确定性+真实种子锚） | L15 |
| **codex 自主跑无中途门（GOV6）** | **L05 行为中途门（本轮最大 P0 增量）** | L05 |
| **chat-template byte-parity（隐蔽新面）** | **L03 byte-parity 门（本轮第二 P0）** | L03 |

**结论：本轮调研的真正增量 = L05 行为中途门 + L03 byte-parity 门两个 P0 防护**，其余 4 路是排除假设（L01）/验证门（L02）/事后防线（L06）/反向印证（L15）。

## 4. 守现状 steelman（详见 steelman_hold_current 字段）

核心：**0/34 不在配方/容量/范式，这三者已被本轮反向坐实健康；换它们只引入新混淆变量、丢健康基线**。唯一该动的是补 4 颗螺丝：surface 同源验证 + byte-parity 门 + 行为中途门 + masking off-by-one 防护。守 rank16Mainline（C16 reopen criteria 未触发）/ 守 1.7B（8GB≤2B，容量适配 562）/ 守 home-llm 范式（数据链路最佳实践 + 反向印证 A2）。

## 5. 与 Phase 0 冲突检查（详见 conflicts_with_phase0 字段）

**零硬冲突**。6 路全落 Phase 0 边界内，为 C14/C16/C17/C18/C19/C20/C13/C12/C03/C09/C10 提供实证弹药。3 处需对齐（非冲突）：① C20「GBNF fallback only」可更新为「llama.cpp GBNF fallback，XGrammar 端侧可行作 prevention」；② C14 补「human_pause 超时降级 blocked」；③ C09/C10 L15 提供具体工程模板。

## 6. Stop-the-Train 矩阵（核心交付物，详见 stop_the_train_matrix_md 字段）

12 行风险，按能否提前阻止 0/34 排序。**R1-R5 是 P0/P1 主战场**（中途门/surface 同源/byte-parity/off-by-one/enable_thinking），R6-R11 是配方/约束解码/数据/checkpoint/门假绿，R12 是 paper-tiger（硬件）。每行「提前发现手段」= OpenSpec gate task 弹药。

## 7. 给磊哥的下一步建议（pre-propose 收敛）

1. **回查缺失 12 路**（最高优先）：6/18 回传，确认是 return 截断还是只跑 6 路。**评测 harness / 拒识训练路若缺是 P0 盲区**。
2. **把 R1-R5 写进 retrain-c5 OpenSpec gate task**（Phase 0 acceptance 的 next action 正是「转 OpenSpec-ready tasks」）：
   - C14 中途行为门：⭐行为生成门 + 相对 base 10/23 阈值 + 四态 + human_pause 超时降级 blocked + infrastructure-enforced（**需磊哥拍 grill_ammo 第1/2条**）。
   - C19/C20 byte-parity 门契约：端侧 render dump 协议 + 比 mask offset 起点 token（端侧实装随 golden-run DEFERRED）。
   - masking 多轮拆单轮样本规则 + enable_thinking=False 渲染 + fixture expected_start 随 D-domain 更新。
3. **3 个需磊哥拍板的口径型/选择型议题**（不无限核，上抛拍板）：
   - 约束解码 vs 安全拒识张力（⭐grammar 留拒识合法出口，grill_ammo 第3条）。
   - C5 数据 template-heavy vs cloud-NL 配比（⭐template-heavy hypothesis 待 spike，grill_ammo 第4条）。
   - stop-the-train「谁有权停 + 无人值守降级」（grill_ammo 第2条）。
4. **抽样亲核 external_claims**（详见 external_claims_verified 字段，~30 条待核）：尤其驱动决策的 arxiv ID（2511.22138/2604.05426/2408.14774/2510.05133）和精确数字（BFCL 55.49%/Qwen3.5-2B 43.6%/iPhone 984MB），按 ultracode-7lens「finder 高发编造精确数字+引用 ID」纪律抽样 gh/WebSearch 亲核，不信「综合官说核了」。
5. **不要做**（守 Phase 0 边界）：不 retrain、不 base 重校准、不端侧 ready 声称、不冻结 C11/C12 配比为生产值——本轮全是 pre-propose 弹药，落 docs/research 不碰 runtime contracts/。

## 8. 元层提醒（claim-vs-reality 第11坑预防）

L05 elephant 点破的 **「门本身成新第11坑」** 值得最高警惕：行为门 receipt 写 PASS 是 metadata 声称，门 generate/parse 有 bug 或读 flag → 假绿。**门 generate 必须实跑模型 + value-in-source 核（解析出的 toolCall 真在生成文本里）+ 异源 grader（hermes 非同 Claude 家族）+ sign-or-block**。别让防 0/34 的门自己成下一个 0/34。