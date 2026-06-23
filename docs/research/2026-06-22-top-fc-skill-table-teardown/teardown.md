# 某车厂 TOP 技能表 FC / 复杂车控 FC 手册 teardown（结论版）
- 范围：只拆两份一手源；座舱控制以 `airControl` + `carControl` 为主，`cmdControl` 69 个更像通用命令词，不计入设备控制主口径。
- 方法：直接解析 xlsx/xml 与 docx 文本；只抽结构/范式/计数，不复制原始客户语料。

1. **真实座舱用了多少工具？**
- 纯座舱控制共 **991 个 FC 工具**：`airControl` **51** + `carControl` **940**；若把 `cmdControl` 也算上是 **1060**。
- 工具名结构明显是 **per-family / per-operation 具名 intent**，典型形态：`open_window`、`open_ac`、`adjust_ac_temperature_to_number`、`raise_seat_heat_temperature_little`。
- 结论：**不是** `tool_call_frame{device,action,value}` 这种 1 个通用工具；也不是我们当前 C6 那种 6 个 `set_cabin_*` 子集。

2. **FC 工具参数 schema 是什么？**
- NLU 侧主键是 `intent`；动作语义大多固化在工具名里，不靠统一 `action_primitive` 参数。
- 常见可选槽位：`position` / `direction` / `mode` / `name` / `device`；数值类统一落到四元组：`value.{ref,direct,offset,type}`，空调则是 `temperature.{...}`、`fanSpeed.{...}`。
- DS 侧统一落为：`{"service":"airControl|carControl","intent":"...","semantic":{"slots":{...}}}`。
- 因此它是 **“具名工具 + 槽位参数”**，不是 **“device+action 全分离 frame”**；`device` 只在少数族内作为二级槽位出现（如座椅局部件、空调设备）。

3. **交付手册定义的最终 surface/schema 是什么？**
- 手册写明：云端**不改写** FC 结果，正常下发到端侧；端侧再按 `label`（如“自由/指令”）决定交互策略。
- 结合技能表 DS 协议，模型最终给端侧的稳定结构是 **单条 `service + intent + semantic.slots` JSON**，而非通用 frame。
- 手册还写明：**一句话多意图仍是 Demo 态/未正式支持**，所以当前 ground-truth 仍以 **单 intent 输出** 为准。

4. **B-frame 还是 D-domain？**
- 结论是 **D-domain 主导，带少量槽位层混合**：设备族/动作/value-form 已提前编码进 intent 名；槽位只补位置、模式、方向、数值。
- 所以真实座舱 ground-truth **反证 B-frame**；我们当前 6 个 `set_cabin_*` 不是“真实 D-domain”，只是一个很窄的手工子集。

5. **测试集覆盖范围 & 与 C6 的量级差**
- `airControl` + `carControl` 单轮测试 **3577 行**，覆盖 **991/991 工具（100%）**；多轮测试 **282 行**，覆盖 **183/991 工具（18.5%）**。
- 仅空调域也有：单轮 **380 行 / 51 工具全覆盖**，多轮 **64 行 / 50 工具覆盖**。
- 与 C6 当前 **6 工具**相比：只看空调，C6 只覆盖真实 HVAC 工具面的 **11.8%（6/51）**；看全座舱控制，只覆盖 **0.6%（6/991）**，真实基线量级约是 **8.5× HVAC** / **165× 全座舱**。