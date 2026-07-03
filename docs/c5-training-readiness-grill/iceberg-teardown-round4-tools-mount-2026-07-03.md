---
authority: iceberg_teardown_round4_overnight
artifact_kind: reflection_report
created: 2026-07-03 凌晨
seed: v6 probe 全轴 empty → 四步排除法 → 真根因 tools 挂载缺失
lineage: gate2 dead-field → v5 under-supervision → v6-probe1 tools-mount（FINAL 档冰山序列第三例）
---

# Iceberg Teardown 第四轮 — tools 挂载缺失（先抽象两次，再扩散）

## 1. 可见故障
v6 tiny 训练（loss 4.16→0.072，600 iters 健康）后 paired 四轴 probe **全轴全臂 empty（68×2）**。若照单全收 = 「训练无效/范式失败」——与 v5 的 34/34 同款表象。

## 2. 排除法四连（每步一手复算，全程 ~20 分钟）
| 步 | 假设 | 复算 | 结果 |
|---|---|---|---|
| 1 | probe/训练 prompt 面 think 块错配 | 两面渲染对比 | 证伪（两面一致） |
| 2 | loss label shift（复读机病理） | 读 loss 实现 | 证伪（标准 shift） |
| 3 | labels 错位（BPE 对齐断裂） | 逐 token 复算 | 证伪（17/17 精确） |
| 4 | adapter 保存/加载错位 | 精确 teacher-forcing | **证伪 + 反转**：17/17 满分 → 模型学会了，问题在 probe 输入 |
| 5 | → tools 挂载缺失 | 带 tools 生成 | **实锤**：A 协议串+B 自然句全完美 |

⚠️ 步 4 曾因 commander 自己 span 测量误差（用 gen 长度推 target 起点）得出 14/18 假信号，几乎误导向「加载错位」——**测量工具自身可引入假信号**（GF-156 已立规：复算必用 assistant_tokenization 的 start）。

## 3. 抽象第一次：未枚举维度的契约断裂
三例同构：gate2（labels 字段无消费者）→ v5（监督范围残缺）→ v6-probe1（挂载维度缺失）。每次修复**被咬的那个维度**，下一个**未枚举的维度**以同样方式断裂。修复模式是「响应式补丁」，缺「维度全集」。

## 4. 抽象第二次：「same surface」是复合对象，单数名词掩盖复合性
契约语言一直说「同输入面/same surface/同 harness」——单数名词。实际 surface 是**复合自由度向量**：system prompt / user 形态 / think 块 / **tools 挂载** / assistant 前缀 / 停止 token / decode 参数 / tokenizer patch / chat template 版本…… 每轮验证只覆盖「已知维度」，语言上却声称「same surface」全称成立。**治理修法：把 same-X 声称强制展开为 X 的维度分解表**（训练列 vs 评测列逐维对齐打勾，新维度发现即追加）——GF-151/152 的推广，落 F-044 v6 spec。

## 5. 扩散检查（同病还在哪）
| 场景 | 风险 | 处置 |
|---|---|---|
| C6 正式 eval 挂载 | 同 D 轴，无策略即重演 | GF-150 已定（expected tool 功能组挂载） |
| **wave-1 generator 产出行的 surface** | 🔴 生成数据的 tools/挂载字段若与训练 surface 契约脱节，wave-1 数据整体 surface 漂移 | 已列 wave-1 拍点包附加项；P5W dry-run 行需补验 tools 字段 |
| voice/ASR 输入面（未来） | 文本 probe 面 ≠ 语音转写面 | 未来 lane 立项时进 surface 维度表 |
| readback/renderer 状态面 | UIUE 桥接契约同族 | bridge contract 已有 field-drift 防线 |

## 6. 正面收获
1. 🎉 **D-domain 范式首个正面行为证据**：44 行 tiny 训练即让 1.7B 在挂载 surface 下对协议串（A）与自然中文（B）都输出正确具名工具——「B 轴自然迁移」样例级成立，v5 时代「范式失败」疑云进一步消解。
2. 排除法四连每步一手复算的节奏（假设→复算→证伪→下一层）用 ~20 分钟走完五层，堆猜测做不到。
3. 冒烟→v2→v3 的三段拦截全部发生在正式结论之前——per-phase 冒烟纪律的复利。

## 7. 次级发现
- EOS 未监督（target 止于 `</tool_call>`，模型不会停）→ GF-153（v6.1 数据 span 延至 `<|im_end|>`）；本轮 parser 取首 call 容忍。
