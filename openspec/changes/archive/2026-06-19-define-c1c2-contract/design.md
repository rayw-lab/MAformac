## Context

旧路线(扁平 8 能力 `capabilities.yaml` + 二分路由)被 2026-06-19 基座内化推翻。本 change 把 C1(语义功能契约 SSOT)+ C2(场景端态协议)立为新路线的根,后续 C3–C7(执行/路由/LoRA/bench/voice,已 park)在其上 rebase。设计经 Q1–Q15 脑暴(CC↔codex)+ 2 轮 oracle 联网验证定稿。

现状约束:旧 5 change 已物理 park(`_parked/`);P0 `function-spec-full.yaml`(671 device 聚合稿,0 provenance)降级为参考、不作主源;冻结源快照在外部 raw 只读(源料不进仓,红线)。

主链路(本 change 只立契约,不实现):`文本 → 意图解析 → ToolCall → DemoGuard(代码门) → mock state → trace`。安全门是代码不是 prompt;模型输出是不可信候选。

## Goals / Non-Goals

**Goals:** C1 全集语义契约(源行级 JSONL + value 四件套 + 三元 + clarifyTag + followup + risk-policy + l1-allowlist)+ C2 场景端态(state cells + execution_range 权威 + scenarios)+ C1↔C2 接口互锁 + `make verify` 本地门 + 全程脱敏。为 C3–C7 立可校验地基。

**Non-Goals:** runtime 实现(C3–C7)/ 全集 runtime 精做(只 L1)/ 真车控 / 量产端态复刻 / LoRA 训练 / 路由实现 / bench。

## Decisions(承接 Q1–Q15,决策 + 为什么 + 备选)

| Q | 决策 | 为什么(备选已否) |
|---|---|---|
| Q1 | 甲档:全集精确,**codegen 从冻结快照机械派生(非手写)** | 手写 2655 carControl intent 不可能且必复发拍错。备选乙(范式+L1+索引)磊哥否,选甲 |
| Q2 | 甲-混节奏:C1/C2 先做对 → 纵切 `空调温度`+`车窗` 验全栈 → 横铺 | 纯横切 demo 太晚 / 纯纵切违全集先行。纵切两设备覆盖 value 四件套+经验步长+position fan-out+读回 |
| Q3 | 新建 `semantic-function-contract` spec,旧 `vehicle-capabilities` 标 **superseded**(非物理删) | OpenSpec archive 的 spec 不回炉;沿用 archive capability change 的 superseded 标注先例 |
| Q4 | 主源 `*.jsonl`(源行级 + provenance),`function-spec-full.yaml` 派生视图 | JSONL 行级保溯源 + diff 可读;YAML 聚合给人读不作权威(Oracle:go-generate+diff 范式)。**P0 的 671-device YAML 无 provenance,不能当起点** |
| Q5 | 源行级建模 + canonical 去重(SCD Type 7 双 key);**`dropped_rows=0` → 分流账本** | Oracle:dropped=0 逼脏行洗白成契约(coincidental correctness)。改 `unclassified=0` + `quarantined`(带 reason)≠ drop,守恒可审计 |
| Q6 | 源料中文不进仓,只存 `*_hash` + `evidence_ref`;LoRA 训练独立读冻结快照 | 红线;仓内 hash 仅作覆盖/diff 锚 |
| Q7 | 二次交互 = `semantic-followup-transitions.jsonl` sidecar,C4 消费;`unresolved_ref ≤2%` 收敛门 | 关系边独立、不并入主覆盖;Oracle:unresolved 不设门会静默堆积假完整 |
| Q8 | C1 `semantic_range` 引用 + `execution_range_ref`;C2 `execution_range` 权威;**range_ref 按 exec_tier 分级** | L1 必须 concrete 落 C2;L2/L3 用 `generic`/`none`(否则全集 L2 行 range_ref 大规模悬空)。range_conflicts 区分 placeholder_open vs material_conflict 防噪声爆炸 |
| Q9 | `exec_tier`/`risk` **挂源行**(非 device);`risk-policy.yaml` 单源收 R0–R3/ASIL/forbidden 双轨;`l1-allowlist` 的 L1 必须 reviewed | device 标量稀释高危 action(座椅加热 R0 vs 位置移动夹手 R1)。risk 双轨(integration-blueprint R0-R3 + baseline ASIL)必收口。demo 豁免 ISO26262,二次确认=炸场效果 |
| Q10 | 生成权威 = **冻结快照(snapshot + content_digest)**,非活 xlsx,非 digest | Oracle:codegen 输入必须不可变(reproducible build);活 `~/Downloads` 会被改/无版本控制/副本满天飞 |
| Q11 | manifest 双 hash(`file_sha256` 防换文件 + `content_digest` 防语义漂、xlsx 重存不变);覆盖 **4 张** C1 表 + C2 源;`snapshot_id` content-addressed;`source_reachable` 降级语义 | xlsx=zip 重存字节 hash 变;codex 漏第 4 张金钥匙;源不可达时仓内 JSONL 镜像=fallback 权威 |
| Q12 | C2 cell = `L1_device_cells ∪ scenario_required_cells ∪ safety_cells`;量产表只作**脱敏参考池** | 纯场景驱动漏 L1 readback 多 cell;`工作簿1.xlsx`(量产端态上传清单)含供应商名/车型代号/责任方=红线敏感(已脱敏,不写真名),参考映射禁存来源方/车型/责任方 |
| Q13 | `l1-allowlist` reviewed,粒度 `device+primitive+cell_group+followup`;allowlist=L1 唯一真源,C1 的 L1 标记从它派生 | 漏多轮维度则炸点缩水;`required_state_cell_groups` 方向 = allowlist→C2(需求声明);防 C1 手写 L1 漂移 |
| Q14 | **一个 change 两个 capability spec delta**(非两 sibling change) | 两 change 双向依赖 → OpenSpec archive 循环死锁(依赖仅文字);一 change 两 spec:spec 分开防糊账 + change 合一同波 archive |
| Q15 | 旧 change 物理 park 到 `_parked/`(非删非 archive)+ config v2 移除 + README 复用度 | OpenSpec 无 status 字段,文字标注防不住误 apply;物理移出 changes/ 根 → 工具扫不到 |

## C1↔C2 接口共享段(两 spec 互锁,写在本 change 内自洽)

- `execution_range_ref`(C1→C2):C1 每行引用 C2 的 cell；`range_ref_kind ∈ {concrete, generic, none}`,L1 必 concrete,L2/L3 可 generic/none。
- `state_cell_group`(C2 拥有):cell 的分组身份,C1 的 `required_state_cell_groups` 与之对应。
- `l1-allowlist.required_state_cell_groups`(C1→C2 需求方向):allowlist 声明需求,C2 据此建 cell;`make verify` 校验闭合(每个需求 C2 都建了)。
- `risk-policy`(C1 拥有):`Rn → {asil_origin, demo_action, confirm_timeout_s, source}`;C3 DemoGuard/SafetyGate 共 import。
- **archive 同波**:C1+C2 在同一 change,接口在 design 内闭环,不跨 change 双向依赖。

## Risks / Trade-offs(pre-mortem 三分类,已搜坑 + 来源,非空泛风险)

**🐯 tiger(HIGH,带 mitigation):**
- 假泛化(SGD-X:靠 intent 名记忆) → function masking + schema 名增广 + bench 换说法(落 C5/C6,C1 schema 留 masking 钩子)
- 假 SSOT(生成物手改不校验) → `make verify` 本地 regen+`git diff --exit-code`(不等 CI,gate≠CI)
- `dropped_rows=0` 洗白脏行 → 分流账本(unclassified=0,quarantine≠drop 带 reason);来源 Kimball error-event
- 活 xlsx 作权威漂移 → 冻结快照+content_digest;来源 reproducible-builds.org
- JSONL 无原生 FK 跨行引用悬空 → `verify_refs.py` 实跑(canonical/dedupe/followup/range_ref 四类),unresolved≤2%
- WPS dimension/合并格静默丢字段 → codegen 三道硬 gate(reset_dimensions / merged-cell forward-fill / schema validation);来源 openpyxl 官方
- 多版本真相(Downloads 20+ 竞争座舱表+【禁外传】发音人列表) → 4 个 `file_sha256` 锁死防近似表混入

**🐯📄 paper-tiger(有据可控):** 源行/canonical 双建模 = Kimball SCD Type 7 正统(非过度设计);JSONL 几千行远在舒适区(真坑是引用校验非规模)。

**🐘 elephant:** 全集 3990 契约主要服务 LoRA 语料 + bench 覆盖,**runtime 只跑 L1 ~10 + L2 通用兜底**;甲档价值在地基正确与可演进,不在 runtime 全用。

## Migration Plan

1. supersede:新 `semantic-function-contract`+`scenario-state-protocol` spec ADDED;`vehicle-capabilities` 旧 5 Requirement REMOVED + 加 1 墓碑 Requirement(降为指向 C1/C2 的指针,非清空——OpenSpec 不许空 spec)。
2. 冻结快照:`freeze` 脚本(校验 dimension/合并/schema → 写快照 + content_digest + manifest)→ codegen 从快照派生。
3. rollback:git revert;`_parked/` 旧 change 不动(随时可 rebase)。
4. C3–C7 rebase 触发:本 change apply+archive 后,按 `_parked/README` 复用度逐个移回。

## Open Questions —— ✅ apply 阶段已全部 resolved(2026-06-20 回填)

- **C2 端态一手源**:✅ 已定。C2 是原创 mock(不复刻量产);`state-cells.yaml` 三源并集(L1_device ∪ scenario_required ∪ safety),demo 场景 cell 已建(含横铺 screen/ambient)。3 个 demo-decided 取值(brightness/exp_step/ambient 色)已 flag 待 magnet 拍(非协议一手源)。
- **L1 allowlist ~10 炸点最终名单**:✅ magnet reviewed(`l1-demo-allowlist.yaml` `reviewed_by: magnet`),C1 的 L1 行集从它派生(76 行,三向闭合)。
- **冻结快照落点**:✅ freeze 脚本已跑,4 张 C1 金钥匙表 content_digest 入 `source-snapshot-manifest.yaml`(source_rows=3990)。C2 端态源仍按 open question 留空(原创 mock,无需冻结量产表)。
