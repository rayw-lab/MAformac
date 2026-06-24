> ⚠️ **PARTIAL — 基于 6/18 路成功**（L01/L02/L03/L05/L06/L15；其余 12 路 rate-limited 待补跑后重综合）。本报告结论不完整，仅供过渡参考。

---

## 18 路 × 维度对比矩阵

> ⚠️ **数据完整性披露（综合官诚实标注）**：本次派单声称 18 路 finder，但 workflow return 实际只回传了 **6 路**（L01/L02/L03/L05/L06/L15）。其余 12 路（含 L04/L07-L14/L16-L18，按 7-lens × 多候选拆解推测含「横向候选小模型选型」「云 generator 自然中文数据」「BFCL/tau2 评测 harness」「safety/clarify 拒识训练」「DialogueState 多轮」「distractor 注入」等）**未在 return 中**。下方矩阵只对实际收到的 6 路负责，缺失 12 路标 `[未回传]`，主线程应回查 `/private/tmp/.../tasks/<taskId>.output` 是否被系统清理，或确认 workflow 是否实际只跑了 6 路。**不编造未收到的 finder 内容。**

| 路 | 维度焦点 | prevents_0_34 | priority | vs rank16Mainline | requires A2 surface change | 关键发现（source） |
|---|---|---|---|---|---|---|
| **L01** 训练栈本机/云逃生口 | 显存/吞吐/优化器/收敛 | **no** | P2 | support | no | 本机 M5/32GB peak 仅 11.4-12.2GB（/32GB，留 20GB headroom）、no_oom、loss 5.5→0.6-1.3 健康；rank16Mainline SSOT=`C5LoRATraining.swift:1210` scale20/LR1e-4（旧 smoke receipt 渲染 scale32 是过期 A/B 值，产物非 SSOT）；云 Axolotl 是真不必要逃生口（home-llm 上云只因训 270m 走 CUDA）。**训练栈跑不跑得动从来不是 0/34 root cause** |
| **L02** loss-mask 机制 | mlx-lm 单 offset 前缀掩码 | **no（部分）** | P1 | support | no（但 fixture expected_start 需随 D-domain 更新） | mlx-lm 0.31.1 = 单 offset 连续前缀掩码（`datasets.py:57-77` + `trainer.py:75-85`），对 C5 当前样本（实测 80/80 单 assistant 轮）正确；`c5_mask_offset_fixture.py:85-123` 是真 token 级验证器非 flag；Qwen3 模板无 `{% generation %}`，return_assistant_tokens_mask 全 0 → per-turn 不可用。**mask 能造的 0/34 = 引入多轮样本而 mlx 单 offset 漏训中间工具调用轮** |
| **L03** chat-template byte-parity | 训练 vs 端侧渲染字节同源 | **yes** | **P0** | escape_hatch | no（但 A2 引入新 byte-parity 面） | 本机实测训练 assistant 段含 `<think>\n\n</think>\n\n`（4 token 151667/271/151668/271），端侧默认推理 prompt 不含 → 端侧少 4 prompt token，offset 漂移；`C5EndpointTokenizerParityGate`（`C5LoRATraining.swift:1612`）骨架在但 endpointRendered=nil 从未真接 mlx-swift（lessons #26/TRN2 未闭环）；D-domain 工具名多 token whitespace 敏感（38719 vs 7500） |
| **L05** 训练中途 gate + stop-the-train | 行为生成门 vs val-loss 门 | **yes** | **P0** | escape_hatch | no（强依赖 A2 同源 surface） | 0/34 = loss 健康/行为全塌 → 中途门必须是【行为生成门】（iter50/100/150 抽样 generate→解析 toolCall→C6 抽样），mlx-lm 原生 val-loss 门测不到；callback 不能停 stock loop（`trainer.py:273-301` 不 check 返回值，必须 raise）；home-llm val_set_size=0.0/saves_per_epoch=1=零门（任务简单不亏，MAformac 23x 复杂必须加） |
| **L06** 端侧部署+受限解码+parser三层 | XGrammar Swift/jetsam/防御解析 | **no** | P1 | support | no（A2 D-domain 利好约束解码） | **翻案 grill SSOT「端侧无 GBNF」**：XGrammar 官方 ship Swift Package（iOS/macOS 支持 1756★ 2天前 push）+ mlx-swift-structured（74★ 接 LogitProcessor）；overhead <10%；1.7B-4bit iPhone17Pro(12GB) 984MB/TTFT360ms/39.5tok/s（**但目标 8GB 必真机 spike**）；约束解码保证语法不保证语义（whitelist 强制 valid 非 correct，可能把 0/34 变成更隐蔽的合法但错） |
| **L15** home-llm 蓝本再 teardown | 训练后端/数据链路/surface 教训 | **yes（反向印证+警戒）** | P1 | support | no（反而印证 A2） | home-llm 已迁 Axolotl+Gemma-270m（旧 teardown 过时）；数据链路=seed CSV→synthesize.py(LLM填种子)→generate_data.py(确定性templating)→distractor=教科书合成数据最佳实践；**home-llm 用 19 generic intent 工具能 work 因封闭词表小+每例工具子集化+重 distractor 训练**；home-llm LR=2e-4（MAformac 守 1e-4，照搬必发散）；100% 合成能 work 因确定性+真实种子锚 |
| **L04/L07-L14/L16-L18** | `[未回传]` | — | — | — | — | **workflow return 缺失，主线程需回查 .output / transcript** |