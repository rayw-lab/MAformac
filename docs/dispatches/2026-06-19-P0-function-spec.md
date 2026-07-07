# P0 dispatch — MAformac 功能清单全集生成(内化方案 roadmap P0)

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

## 0. 路由
- **TO**:codex(隔离 worktree `/Users/wanglei/workspace/MAformac-p0`,branch `feat/p0-function-spec`)
- **FROM**:CC
- **PRIORITY**:P0(内化方案落地第一步)
- **DELIVERABLE**:从基座全景**机械全量生成** MAformac 自有功能清单全集 + 端态 cell 清单 + device-action 矩阵,脱敏入仓(worktree)。

## 1. 冷启动背景
MAformac = 纯端侧离线车控 demo。**内化方案全文**:`/Users/wanglei/workspace/MAformac/docs/baseline-internalization-plan-2026-06-19.md`(业内做法 + roadmap,本任务 = **P0 全集事实源定稿**)。基座 = 某车厂语义四级协议(~3900 intent),已解析成 digest。P0 = 把基座全集**机械转**成 MAformac 自有功能清单(`device × action-primitive × value 四件套`),作 LoRA 语料 + E2E 基线 + 契约升级的根。

## 2. 任务(严格沿用 v0 模板 schema,机械转换,非创作)
**模板(必读,schema + 12 action_primitives + 空调/座椅样板)**:`/Users/wanglei/workspace/MAformac-p0/contracts/function-spec-full-v0.yaml`

### 2.1 `contracts/function-spec-full.yaml`(全集功能清单)
数据源(只读):
- `~/workspace/raw/00-Inbox/maformac-baseline-digest/digest/_设备全景_{carControl,airControl,cmd}.txt`(每 device + 动作集 + 优先级)
- `~/workspace/raw/00-Inbox/maformac-baseline-digest/digest/{carControl,airControl,cmd}.txt`(DS协议 / 取值范围 / 示例说法)

对**每个 device**(carControl 398 + airControl 16 + cmd 257 ≈ 670)生成一条,字段同 v0 模板:
- `id`(`cabin.<域>.<device>`)/ `service` / `display_zh` / `state_cell` / `value_type` / `range`(对齐端态打点真值)/ `positions`(收敛 `主驾/副驾/左后/右后/全车`)/ `primitives`(**动作集→12 原语映射,见下**)/ `clarify_examples`(脱敏代表说法 2-3 条,**不堆原始语料**)/ `exec_tier` / `risk` / `priority`(取全景优先级列)
- **动作集→primitive 映射**:`open/activate→power_on` · `close/deactivate→power_off` · `raise/increase + little→increase_by_exp` · `lower/decrease + little→decrease_by_exp` · `raise+by_number→increase_by_number` · `lower+by_number→decrease_by_number` · `adjust+to_number→adjust_to_number` · `+to_max/to_min/to_gear→adjust_to_max/min/gear` · `+by_percent→by_percent` · `switch/set+mode→set_mode` · `switch+color→set_color` · `query/check→query`
- **exec_tier 判定**:优先级"高" 且属炸点域(空调/座椅/氛围灯/车窗/天窗/屏幕/音量/香氛)→ `L1`;其余车控 → `L2`;导航/音乐 → `L3`;敏感词 → `L4`

### 2.2 `contracts/state-cells.yaml`(端态 cell 清单)
源(只读):`~/workspace/raw/02-Raw/座舱/多阶车控车型支持端状态能力打点V1.0.md`(102 原子能力)。
每 cell:`key` / `range`(取值范围真值)/ `default`(默认值列)/ `uploadable`(是否上传)/ `priority`(P0/P0-1/P0-2)。至少全 P0 子集。

### 2.3 `contracts/device-action-matrix.md`(可读矩阵)
device × 12 primitive 覆盖矩阵 + 统计(每原语被多少 device 用 / 每 device 用几个原语)。

## 3. Prerequisite Check(起手必跑)
```bash
cd /Users/wanglei/workspace/MAformac-p0
git branch --show-current                                   # 必须 feat/p0-function-spec
git -C /Users/wanglei/workspace/MAformac branch --show-current   # 主树必须 main
ls contracts/function-spec-full-v0.yaml                     # 模板在
wc -l ~/workspace/raw/00-Inbox/maformac-baseline-digest/digest/_设备全景_*.txt   # 全景在
python3 -c "import yaml; yaml.safe_load(open('contracts/function-spec-full-v0.yaml'))" && echo "模板yaml合法"
```

## 4. 边界
- **红线**:脱敏 —— intent 协议骨架入仓,**原始中文语料/客户名/车型代号不入仓**;`clarify_examples` 用通用口语代表说法(如"有点冷"),不堆基座原文。`raw/`、`~/Downloads/` 只读不入仓。
- **禁区**:禁碰 main / 禁 archive / 禁动其他 change / 禁动 change3-fix、lora-build worktree。
- **OUT_OF_SCOPE**:LoRA 语料合成(P4)/ 运行时三层路由(P2)/ codegen 实装(P1)。**本任务只产事实源 YAML/MD,不写 Swift、不改 capabilities.yaml**。
- **🔴 三纪律**:只在 `feat/p0-function-spec` commit;禁 merge;任何"完成"断言**必附** `git -C /Users/wanglei/workspace/MAformac-p0 status --short` + `git log --oneline -5` + `git branch --show-current` 实际 stdout(防幻觉,CC 收稿自跑核对)。

## 5. 验收
- `function-spec-full.yaml`:device 覆盖 ≈670(carControl+airControl+cmd 全),`python3 -c "import yaml;yaml.safe_load(...)"` 通过,range 对齐端态打点(空调温度 18-32 / 风量 1-10 / 座椅 0-3 / 车窗 0-100%)。
- `state-cells.yaml`:≥102 P0 端态,yaml 合法。
- **脱敏自查**:`grep -iE "奇瑞|某真实车厂名|T19|E0Y|AH8" contracts/*.yaml` 应为空(车型代号不入仓);clarify_examples 无大段原始语料。
- 报告附 ground-truth git stdout + 各产物行数/device 数 + 3 条样例 device 条目。

## 6. 相关文件(优先读 ≤5)
1. `function-spec-full-v0.yaml`(模板,worktree 内)
2. `docs/baseline-internalization-plan-2026-06-19.md`(方案上下文,主树绝对路径)
3. 设备全景 + digest + 端态打点(路径见 §2)

## 7. 回报(带 status field)
- **status**:done/blocked/partial
- 产物清单(文件 + 行数 + device 数 + 3 样例条目)
- 三纪律 ground-truth git stdout
- `introduced`(本次生成)vs `exposed`(基座里发现的矛盾/缺口)
- 下一步建议(如:L1 子集是否需人工精修 clarify_examples)
