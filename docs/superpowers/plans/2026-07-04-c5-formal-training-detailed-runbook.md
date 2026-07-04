# C5 正式训练当日细化执行书（2026-07-04）

> authority: implementation_plan_not_ssot
> parent_plan: `docs/superpowers/plans/2026-07-04-c5-formal-training-today.md`
> decision_ssot: `docs/commander-log/decisions.md` D-080 / D-085~090+今日后续；`docs/c5-training-readiness-grill/f044-r2b-grill-2026-07-04.md` R2B-1~10
> proof_class: planning + local repo evidence；本档只细化执行，不替代 decisions / grill / run-dir receipt
> status: active_runbook_for_2026-07-04_c5_formal_training_push

## 1. 目标口径

磊哥今日目标是“C5 正式训练完成”。按现有计划和 D-080/D-085 边界，本档把目标拆成两层：

| 层级 | 今日目标 | 完成判据 |
|---|---|---|
| P0 hard target | 今天完成 R2b 全链路，并在五条件全绿后启动 C5 正式训练 | R2b verdict 达 D-085；五条件消减表全部 locked；正式训练 run_dir、config、watchdog、receipt owner 全落盘并起跑 |
| P1 stretch target | 若正式训练墙钟允许，今天内 adapter + train receipt 落盘 | 正式训练 adapter 存在、metrics/log/config/receipt 四件齐；否则明早按无人值守 receipt 收口 |

状态词约束：

- `FORMAL_TRAIN_LAUNCHED`: 五条件全绿后正式训练已起跑；这是今晚最低成功态。
- `FORMAL_TRAIN_DONE`: 正式训练 adapter + receipt 完整落盘；若跨夜，明早收口。
- `R2B_FAIL_STOP`: R2b 未过门，按 R2B-8 分诊，不起正式训练。
- `PARTIAL_WITH_RECEIPT`: 有阶段完成但 hard gate 未满足，必须写清停在哪个阶段。

## 2. 固定边界

本档遵守以下已锁边界，不在执行中重拍：

- R2b 门：A≥12/15、B>9/15、D≥18/34 不退化、qa=0、极性双向单列。
- R2b PASS 只证明两残余靶点被短训修复，不升格为产品验收、全 10 族自然语义鲁棒、V-PASS 或候选签字。
- R2b PASS 后仍需 D-080 五条件独立重评，才允许正式训练。
- 本轮不改 OpenSpec change；R3 后再开 `define-f044-shorttrain-behavior-gate`。
- 本轮不换 LR、不换 PEFT、不改 mount/prompt 判定面、不改训练脚本主路径；训练变量聚焦数据面。
- R2b FAIL 不连训；按四轴分诊回数据配方层。

## 3. 入口真态

截至本档细化时，当前入口真态按 parent plan 与 R2B grill 消减记录读取：

- 750 四批已 accept；还剩 +23 AC supplement 进入 judge / 注入 / 773 终账。
- R2B-10 已把 S2 拆成 4 批×2 lane×75 行滚动闭环，当前进入 train-pack 之前的尾部收口。
- 正式训练仍是条件化授权，不是 R2b 完成后自动执行。

## 4. 总流程

```text
T-A supplement 收口
  -> T-B train-pack 组装与三静态门
  -> T-C R2b full-pack 短训
  -> T-D 双轨 eval + 四轴 verdict
  -> T-E 五条件消减 + 正式训练起跑
  -> T-F 正式训练无人值守收口
```

## 5. T-A：supplement 收口与 773 终账

目标：把 750 accept 数据面补齐到 773 终版候选池，并证明 R2B-1 必含项不再缺口。

| 项 | 内容 |
|---|---|
| 输入 | 750 accepted lanes；+23 AC supplement；D-090 supplement 范围 |
| owner | `%43` judge；`%45` 注入；`%44` 773 merger / cumulative gates；commander 复核 |
| 产物 | supplement judge 报告、注入后数据包、773 终账 ledger、累计门首跑输出 |
| hard gates | 23/23 行 judge 结论明确；airoutlet/wind 6 组补齐；set_interface_vs_defog 第 8 组补齐；query 保护行严格口径到 10；全局 row id 唯一 |
| stop line | 任一 supplement 行语义 FAIL；必含项仍缺口；注入后累计账不自洽；query 行被误写成 mutating actuation |

T-A closeout 必须写：

- supplement sha / row count / inject sha。
- 必含项矩阵：`interface/defog`、`airoutlet/wind`、`query_ac_temperature_vs_adjust`。
- 若有 deviation，必须命名为 `DEVIATION-*` 并说明是否阻断 T-B。

## 6. T-B：train-pack 组装与三静态门

目标：从 773 终版候选池组装 R2b 短训包，完成渲染、scanner、DataGate、strict preflight。

| 项 | 内容 |
|---|---|
| 输入 | R2a base pack、773 终版候选池、replay 表、protected set、envelope 规则 |
| owner | `%45` assembler；`%44` scanner/DataGate/preflight；commander 独立复跑关键门 |
| 产物 | train-pack manifest、class-ratio report、density report、pair-ledger、protected-replay table、query-shape audit、strict-preflight metrics |
| hard gates | scanner contradiction=0；mount-order pass；DataGate exit0；strict preflight exit0；loss mask 有效；query→actuation 静态扫 0；no-call 行不得含 mutating expected |
| stop line | 矛盾监督 >0；DataGate/strict preflight 非 0；query shape 仍可诱发 actuation；protected leakage；class ratio 超 cap 无 waiver |

Replay shortfall 处理：

- R2B-3 目标 replay=112；parent plan 记录 assembler 当前可能为 `replay 102=SHORTFALL-01`。
- 若确为 102，必须在 train-pack manifest 写明：
  - 缺口来源；
  - 是否仍在 replay band 10-20% 内；
  - protected set 覆盖是否完整；
  - 是否阻断 R2b 短训。
- commander 必须在 T-C 起跑前给 `SHORTFALL-01_ACCEPTED` 或 `SHORTFALL-01_BLOCKED`，不能隐式带过。

T-B closeout 必须写：

- 数据包 sha / manifest sha / preflight metrics sha。
- 资源包络预估：records、trainable_tokens、ignored_tokens、ignored:trainable、max_token_length。
- receipt 效率两列预填：`supervised_tok_per_sec` 待 T-C 实测；`ignored_trainable_ratio` T-B 即可算。

## 7. T-C：R2b full-pack 短训

目标：用同 knob set 跑一次 R2b full-pack 短训，验证数据面修复是否带来目标行为移动。

| 项 | 内容 |
|---|---|
| 输入 | T-B 绿的 train-pack；R2a 血缘 fork 脚本；watchdog 参数 |
| owner | train runner；quiet observer；commander 记录 milestone |
| 产物 | run_dir、run script、config、train.log、metrics.jsonl、watchdog log、checkpoint 50/100 快探结果、adapter/checkpoint |
| hard gates | optimizer update 出现；无 OOM/NaN/Inf；watchdog 未触发 hard stop；ckpt50/100 行为快探按 R2B-7 执行 |
| stop line | ckpt50/100 目标族无移动；A 快探明显回跌；query spot 出 actuation；资源峰值越停线；adapter 未保存 |

Checkpoint 行为快探：

| checkpoint | 最小探针 | 判据 |
|---|---|---|
| ckpt50 | A 轴 15 case + interface/airoutlet/query_vs_adjust spot | 目标族有移动；无 query actuation |
| ckpt100 | 同上，复看移动是否持续 | 无移动则早停，省后续训练与 eval |

T-C closeout 必须写：

- `optimizer_update_count`、`trained_tokens`、`tokens/sec`、`supervised_tok_per_sec`、`peak_memory`、wall clock。
- `ignored_trainable_ratio` 与 T-B 是否一致。
- checkpoint 快探 verdict：`MOVE_CONFIRMED` / `NO_MOVE_EARLY_STOP` / `SAFETY_STOP`。

## 8. T-D：双轨 eval 与四轴 verdict

目标：在原 bundle 和扩充旁路上分层评估，产出 R2b 四轴 verdict。

| 项 | 内容 |
|---|---|
| 输入 | R2b adapter/checkpoint；原 A15/B15/D34 bundle；W11 扩充旁路；base anchor |
| owner | eval runner；verdict writer；commander 复核 |
| 产物 | eval raw outputs、scored report、base anchor report、four-axis verdict、polarity report、query zero-tolerance report |
| hard gates | 原 bundle 判 D-085；扩充旁路只作信息面；query zero-tolerance 跨两轨全扫；四轴分列，不 aggregate 掩盖 |
| stop line | A<12；B≤9；D<18 或 protected 退化；qa>0；极性反转复发；base anchor 失真 |

四轴判定：

| 轴 | 放行线 | verdict wording |
|---|---|---|
| A 协议 v2 | ≥12/15 | `A_PASS` / `A_FAIL` |
| B 自然 | >9/15 | 10-13 写 `B_MOVED_NOT_PASS`，不升格产品线 |
| D 泛化安全 | ≥18/34 且不退化 | `D_PASS` / `D_REGRESSION` |
| query→actuation | =0 | 任一例为 `FAIL_SAFETY` |

T-D closeout 必须写：

- R2b verdict：`R2B_PASS_FOR_FORMAL_TRAIN_REVIEW` 或 `R2B_FAIL_*`。
- 若 PASS，只表示进入 T-E 五条件消减，不直接等于正式训练放行。
- 若 FAIL，按 R2B-8 给下一步，不起正式训练。

## 9. T-E：五条件消减与正式训练起跑

目标：把 R2b PASS 转成正式训练启动许可，且启动前证据齐全。

| # | 条件 | 证据 | owner | 状态写法 |
|---|---|---|---|---|
| 1 | R2b verdict 达 D-085 放行线 | T-D four-axis verdict | commander | `LOCKED_PASS` / `BLOCKED` |
| 2 | 三静态门全绿 | T-B scanner/DataGate/strict preflight | `%44` + commander | `LOCKED_PASS` / `BLOCKED` |
| 3 | premortem 无未处置 tiger | 对照 WD-AMMO-43-R2B-PREMORTEM-DELTA 8T | `%43` + commander | `ALL_TIGERS_CLOSED` / `OPEN_TIGER_BLOCKS` |
| 4 | 配方同 R2b，仅扩 iters | formal config diff vs R2b | commander | `CONFIG_DIFF_ALLOWED` / `CONFIG_DIFF_BLOCKED` |
| 5 | 资源包络按 R2b 实测重推 | peak/wall/supervised tok/s/ignored ratio | commander | `ENVELOPE_OK` / `ENVELOPE_BLOCKED` |

正式训练起跑包必须包含：

- formal run_dir。
- exact command / script path / config path。
- R2b run_dir 和 adapter/data lineage。
- iters 数与依据：R2b 实测吞吐、目标监督覆盖、资源包络。
- watchdog env：process peak、system memory hard-disabled/辅助口径、interval。
- receipt owner、observer owner、morning closeout owner。

T-E stop line：

- 五条件任一不是 pass，不起正式训练。
- formal config diff 出现 LR/PEFT/mount/prompt/training script 主路径变化，停。
- 资源包络超过机器或 watchdog 停线，停。

## 10. T-F：正式训练无人值守收口

目标：正式训练若跨夜，保证会话可抛弃、receipt 可恢复、明早可复核。

| 项 | 内容 |
|---|---|
| 产物 | formal train.log、metrics.jsonl、watchdog log、adapter、config、receipt、manifest postscript |
| hard gates | optimizer updates 达配置目标；adapter 存在；无 NaN/Inf/OOM；watchdog 未 hard stop；receipt 逐数可复算 |
| proof class | train-health 只证明训练健康；正式候选晋级仍走 R-L17 / 后续 C6 产品门 |

明早 closeout 必须分层：

- `formal_train_health`: pass/fail。
- `adapter_artifact`: path + sha。
- `behavior_verdict`: 是否已有，不得用 train-health 替代。
- `candidate_status`: unsigned / pending R-L17 / blocked。
- `next_gate`: C6 / R-L17 / OpenSpec R3 change / data repair。

## 11. 回写矩阵

| 里程碑 | 必写位置 | 内容 |
|---|---|---|
| 773 终账 | `docs/commander-log/decisions.md` D-091+；R2B grill 消减记录 | row count、必含项、deviation |
| T-B 全绿 | plan 本档或 parent plan；run-dir receipt | scanner/DataGate/preflight 逐数 |
| R2b 起跑 | decisions D-091+；run-dir receipt | run_dir、script、watchdog、预计收口 |
| ckpt50/100 | run-dir midtest receipt | 行为快探结果与是否早停 |
| R2b verdict | verdict doc；decisions；MEMORY as-of | 四轴结果、声称上限 |
| formal 起跑 | decisions；formal run receipt | 五条件消减表、formal command |
| formal 收口 | formal train receipt；handoff/morning brief | train-health、adapter、residual risk |

## 12. 最小 checklist

T-A 前：

- [ ] 23 行 supplement judge 已完成。
- [ ] 注入后 row count = 773。
- [ ] mandatory first 三项补齐并有 ledger。

T-B 前：

- [ ] 773 终账无 unowned deviation。
- [ ] assembler 输入包 sha 固定。
- [ ] replay shortfall 已判定是否阻断。

T-C 前：

- [ ] scanner contradiction=0。
- [ ] scanner mount-order pass。
- [ ] DataGate exit0。
- [ ] strict preflight exit0。
- [ ] query shape audit pass。
- [ ] watchdog 参数写入 run receipt。

T-D 前：

- [ ] R2b train-health pass。
- [ ] checkpoint 快探完成或早停理由已写。
- [ ] adapter/checkpoint 可加载。

T-E 前：

- [ ] R2b verdict 达 D-085。
- [ ] 五条件表全部 `LOCKED_PASS`。
- [ ] formal config diff 只扩 iters。
- [ ] 资源包络按 R2b 实测重推。

T-F / 明早：

- [ ] formal adapter 存在。
- [ ] formal receipt 逐数可复算。
- [ ] train-health 与 behavior / candidate status 分层。
- [ ] MEMORY as-of 和 morning brief 更新。

## 13. 执行原则

- REPORT-first：落盘但未回报，不算阶段完成。
- 机械门先行，judge 后行；judge 抓系统性问题立即停流水。
- 所有 worker 附带断言必须亲核，不能直接进 spec 硬门。
- 每个 deviation 必须命名、归属、决定阻断或放行；不能散在 prose。
- 任何“完成 C5”的对外表述必须带 proof class：train-health、behavior pass、candidate signoff、V-PASS 不互相替代。
