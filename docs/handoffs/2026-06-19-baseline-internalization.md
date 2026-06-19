# Handoff 2026-06-19 — 座舱语义协议基座深度内化(重大转向)

## 一句话状态
change3 整改已完成(PR #1 head `46340f1`,Layer1 自核 44/44 绿);但**对话重心转向更根本的事**:深度内化座舱语义协议**基座**(磊哥反复强调"别马虎/这是基座/不想丢脸"),重新认知 MAformac 的语义层架构。

## 🔑 重大认知(本 session 核心,务必继承)
1. **4 张金钥匙表 = MAformac 语义协议基座**(`~/Downloads/`:公版语义四级协议-编辑版 / 车控功能打点表 / 上下文二次交互功能清单 / 多语种展开V1)。**只读,不进仓,不入训练集(红线)**。消化工件已保命到 `~/workspace/raw/00-Inbox/maformac-baseline-digest/`(digest + xlsx_dump + 解析脚本,重启不丢)。
2. **语义协议范式(我之前 capabilities.yaml 全错失)**:① `value` 四件套 `{ref:CUR/ZERO/MAX, direct:+/-, offset:数值/LITTLE/MORE/MAX/MIN, type:SPOT/PERCENT/EXP}` → 区分 相对/绝对/经验/极值;② **归一化动作编码**(3900 intent = ~114 编码 × 设备 × value × position,不是每设备一个平铺 tool);③ FC模糊说/自由说标记 = 路由分流依据;④ 二次交互矩阵(首轮→次轮 可继承+省略说法)= 多轮/指代源。「有点冷」=升温 by_exp 经验值,步长执行层定,**不是 LLM 拍**。
3. **🔴 不丢脸架构(磊哥点睛)**:客户现场**随意说** carControl 2655+ 甚至超出 → **语义理解必须广覆盖(LoRA 核心价值)+ mock 执行分层**:L1 精做炸点(~10 高优先级设备)/ L2 通用 mock 兜底(2600+ 听懂→通用卡片,不崩)/ L3 越界优雅延后 / L4 安全门拒识。功能清单 = **全集语义协议(LoRA 语料 + E2E"随便说不崩"基线)**。
4. **我反复犯的错(教训)**:凭二手 `capabilities.yaml` 拍脑袋推进 change2/3/must-pass,**4 次被要求"仔细看"都没读一手基座**;must-pass 的"+2度"是编的,"有点冷→设26度"语义错反。基座必须逐 sheet 核。

## 已落盘(重启不丢)
- `docs/baseline-semantic-protocol-2026-06-19.md` — 基座消化 + 范式 7 要素 + capabilities.yaml 逐项错对照 + 内化方案
- `docs/maformac-function-spec-2026-06-19.md` — MAformac 功能清单 v0 + **§5 不丢脸架构(L1-L4 + LoRA)**
- `~/workspace/raw/00-Inbox/maformac-baseline-digest/` — digest 工件 + 脚本(`parse_devices.py` 等)
- 全集已解析:carControl 398设备/975intent + airControl 16/51 + cmd 257/512

## 下一步(磊哥未拍板,待续)
1. **把全集语义协议系统沉淀进仓**(脱敏:只 intent 协议骨架,原始语料不入仓)= LoRA 语料 + E2E 基线 + L1-L4 分层。
2. L1 精做选型(基于真实优先级:空调温度/风速·座椅加热/通风/按摩·氛围灯·车窗·天窗·屏幕·音量·香氛)。
3. 回写 CLAUDE.md 决策(广听懂+优雅兜底+LoRA 是核心架构)+ 落马虎教训 memory。
4. capabilities.yaml 回炉 vs 新起契约升级 change(待磊哥定)。

## 工件重生成(若 /tmp 丢)
`cd ~/workspace/raw/00-Inbox/maformac-baseline-digest && python3 parse_devices.py`(原表在 `~/Downloads/` 不丢)。

## 旁支(本 session 早段,已完成)
change3 整改(F2真bug多cell/content-fallback fail-closed/F3-F6)+ Layer1自核44绿 + 三纪律守住;欠账:change6二分对齐✅ / must-pass candidate(已废,要基于基座重做)/ lora分支红线clear待merge / G5排期。GPT Pro复审报告已下载(`~/workspace/data/gptpro-downloads/`)但审的是旧扁平契约,契约升级后再审才有意义。
