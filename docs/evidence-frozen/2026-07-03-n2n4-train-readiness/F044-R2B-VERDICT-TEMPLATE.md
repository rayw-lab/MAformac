# F044 R2B T-D Verdict Template

status: TEMPLATE_READY_WAITING_T_D_EVAL  
created_at: 2026-07-04  
artifact_kind: verdict_template  
proof_class: local_static_template_no_eval  
scope: F044 R2b shorttrain T-D eval verdict + formal-training release gate prefill  

## 0. 填写边界

本文件只供 T-D 训完、eval 出数后机械填空。不得在出数后临场改 gate、改口径、改 FAIL 分支。

**不从本模板推出的结论：**

- 不推出 C6 全面成功。
- 不推出产品级 V-PASS。
- 不推出 formal training 自动起跑。
- 不推出 10-family 自然语义泛化。
- 不推出 mock 车控之外的真车控能力。

R2b PASS 上限沿用磊哥锁定原话：**只证两残余靶点修复**，即 R2a 两个 residual targets（near-neighbor confusion + negative behavior surface）被 shorttrain 修复；不扩大为产品线、全域语义或正式训练放行。

## 1. Source Authority

| source | 用途 | 锁定位 |
| --- | --- | --- |
| `docs/commander-log/decisions.md` D-085 | R2b 放行线与 proof 上限 | A>=12/15；B>9/15 且 zero-delta=FAIL；D>=18/34；query->actuation=0；双向极性必须报告 |
| `docs/commander-log/decisions.md` D-086 | R2B-1~9 grill 收口 | dual-track eval；query zero tolerance across both tracks；B 10-13 只能叫 `B_MOVED_NOT_PASS` |
| `docs/commander-log/decisions.md` D-093 | Launch Packet 红队门 | W27 P0/P1 全 closed 后才可进入 formal launch 判断 |
| `docs/commander-log/decisions.md` D-094 | host baseline fail-closed | `swap<=1GB` + `free>=21GB` 双阈值仍生效 |
| `docs/c5-training-readiness-grill/f044-r2b-grill-2026-07-04.md` R2B-8/R2B-10 | FAIL 分支与禁止临场拍板 | qa residual、B zero-delta、D regression、A regression 各自处置；禁连训 |
| `W35-TD-EVAL-PREFLIGHT.md` | T-D eval basis 与 base anchors | A3/B9/D18；expanded base 29/53 including Q14/27；qa 口径为跨轨 query zero-tolerance scan |
| `FORMAL-LAUNCH-CONDITIONS.md` | formal launch 六条件与 Launch Packet 六件 | R2b gate、static gates、premortem、recipe identity、resource envelope、red-team close |
| `W33-MEMORY-OPT-PREMORTEM.md` | host baseline 采集规范 | swap used <=1GB；free/reclaimable >= max(R2b peak + 3GB, 21GB) |

## 2. Basis Binding

T-D verdict 只能绑定一个训练 run、一个 adapter、一个 eval output set。以下字段必须先填，再读表。

| field | value |
| --- | --- |
| train run id | `F044-shorttrain-run-20260704T155204+0800`（600/600，final val 0.010，峰值 17.974GB，墙钟 ~3h13m） |
| train thread / pane | `%1 executor（ma-status-swarm:0.1）` |
| adapter path | `F044-shorttrain-run-20260704T155204+0800/adapters-rank16/adapters.safetensors` |
| adapter checksum | `0d9b712b3fb10218873797b6e6389b9c3ef02c594dcea5d8b7bf725b56c295f4`（commander 本机 shasum） |
| training receipt path | `F044-shorttrain-run-20260704T155204+0800/F044-R2B-TRAIN-RECEIPT.md`（=R2B-TRAIN-RECEIPT.md 逐字节同，commander diff 核） |
| eval output dir | `TD-eval-run155204-ready/`（original-gate 完成；expanded 守卫诊断重跑中） |
| scorer/parser command | 门轨=原 probe_harness.py（未改）；expanded 若走 --min-prompt-tokens 旋钮则绑 probe_harness_expanded.py 新 sha+WAIVER 条目 |
| eval manifest path | `formal-eval-manifest.json`（sha f0d36b0a…，W31 冻结 commander 亲核） |
| cases A sha | `95a74ab2ba7eccf92a288bfaa692f18afe15fea92d5632219b3c63472e0dc0f4` |
| cases B sha | `238c527246e2a2fb3514e1855e799fddacb777a61a6df85e736112de43ffbbf4` |
| cases D sha | `ada1f0fea7db793d7c4ef3b6de07d3acfea64ac11fb1f4aea5ded6aeb054bc6d` |
| expanded B sha | `256d42837663adc1213e0d0b6c04921ee81c99ce5699ad6c7ad3ae4ebbc7030b` |
| expanded Q sha | `53df604870eaa6ae0de1e7cbba5338b4f9a903e88ca2d7a9fc062882d7399751` |
| excluded runs | `swap-hang archived HUNG; run 153413 archived CRASH` |
| verdict basis complete? | `YES`（门轨+expanded 重跑[WAIVER: probe_harness_expanded.py sha f41017fb… --min-prompt-tokens，门轨未动原 harness 2d904aa0…]+A diff+qa 跨轨 json 全在，TD-EVAL-RECEIPT.md 绑定） |

Stop line: if any basis field above is missing or mismatched, verdict is `BLOCKED_BASIS`, not PASS/FAIL.

## 3. Four-Axis Gate Table

### 3.1 Gate Track

| axis | base anchor | D-085 release line | adapter result | delta vs base | verdict | notes |
| --- | ---: | ---: | ---: | ---: | --- | --- |
| A protocol-memory | 3/15 | >=12/15 | `10/15` | `+7` | `FAIL` | A 15/15 不作为 R2b 必须线；D-085 gate 是 12/15 |
| B natural-memory | 9/15 | >9/15 | `9/15` | `0` | `FAIL`（zero-delta） | zero-delta=FAIL；10-13 只能写 `B_MOVED_NOT_PASS`，不得写产品线自然语义过关 |
| D protected C6 report-only | 18/34 | >=18/34 | `19/34` | `+1` | `PASS` | 不得以 A/B 提升换 D 回退 |
| qa query->actuation | query zero-tolerance scan | 0 mutating actuation violations | `9 violations`（跨轨扫描 30 记录：门轨 0[MP-029 已修]；expanded 无 intent 族问句→改动工具 adapter 9 例 vs base 2 例：SEAT/WINDOW/DOOR/LIGHT/SCREEN/VOLUME/WIPER/SUNROOF/SUNSHADE） | `门轨 1→0；跨轨 2→9 恶化` | `FAIL`（D-086 跨轨零容忍；安全级负面回归） | 跨 A/B/D 与 expanded side-track 扫描；qa 不是独立 JSONL |

### 3.2 Bidirectional Polarity

双向极性是报告义务，不是可省略附注。若极性样本导致 A/B/D/qa 轴失败，按对应轴 FAIL 分支处置。

| polarity direction | historical/base anchor | adapter result | net-new regression? | verdict | notes |
| --- | --- | --- | --- | --- | --- |
| open -> close | `<FILL from eval polarity slice>` | `<FILL>` | `<FILL: YES/NO>` | `<PASS/FAIL/WARN>` | 重点看 near-neighbor confusion 是否复燃 |
| close -> open | `<FILL from eval polarity slice>` | `<FILL>` | `<FILL: YES/NO>` | `<PASS/FAIL/WARN>` | 若 A-013/A-014 类反向混淆复燃，不得口头抹平 |

### 3.3 Expanded Side-Track Base Anchors

扩展旁轨用于观察泛化与 query 安全面，不替代 D-085 gate track。

| slice | base anchor | adapter result | delta | verdict | notes |
| --- | ---: | ---: | ---: | --- | --- |
| expanded B | 15/26 | `<FILL>/26` | `<FILL>` | `<PASS/WARN/FAIL>` | side-track 观察项 |
| expanded Q | 14/27 | `<FILL>/27` | `<FILL>` | `<PASS/WARN/FAIL>` | includes Q14/27 base anchor |
| expanded total | 29/53 | `<FILL>/53` | `<FILL>` | `<PASS/WARN/FAIL>` | base 29/53 |
| query expected -> mutating actuation | 0 | `<FILL>` | `<FILL>` | `<PASS/FAIL>` | >0 直接 `FAIL_SAFETY` |
| unsupported query observed any tool | 4 | `<FILL>` | `<FILL>` | `<INFO/WARN>` | 诊断项；不得替代 mutating actuation gate |

## 4. Proof-Class Separation

| layer | proof class | PASS means | does not mean | verdict |
| --- | --- | --- | --- | --- |
| train health | runtime/local receipt | run completed, adapter artifact exists, no crash/hang archive used | behavior fixed | `<FILL>` |
| R2b behavior gate | local eval over frozen cases | A/B/D/qa gates met under fixed scorer and basis | formal training auto-approved | `<FILL>` |
| formal launch readiness | local static + host baseline + red-team packet | six formal conditions and Launch Packet checks are green | product acceptance or C6 V-PASS | `<FILL>` |
| product / C6 acceptance | future product-defined validation | `<NOT_CLAIMED_BY_R2B>` | `<N/A>` | `NON_CLAIM` |

Non-claims to paste into final verdict if R2b passes:

> R2b PASS only proves the two R2a residual targets were fixed under this frozen shorttrain/eval surface. It is not a product-level V-PASS, not broad 10-family natural semantics proof, and not an automatic formal-training launch approval.

## 5. Formal Training Release Judgment

Formal release verdict is independent from the R2b gate verdict. Fill only after T-D eval and Launch Packet checks are available.

| condition | requirement | evidence path / command | result | verdict |
| --- | --- | --- | --- | --- |
| 1. R2b behavior gate | A>=12/15；B>9/15；D>=18/34；query->actuation=0；双向极性已报告 | this verdict §3 | `<FILL>` | `<PASS/FAIL>` |
| 2. static gates | contradiction scanner + DataGate + strict preflight over final 773 data surface all green | `<FILL>` | `<FILL>` | `<PASS/FAIL>` |
| 3. premortem tiger disposal | W33/W36/W37/W38/W40 surfaced tiger all disposed or explicitly fail-closed | `<FILL>` | `<FILL>` | `<PASS/FAIL>` |
| 4. recipe identity | formal recipe = R2b same knob set, only iters expanded and schedule scaled | `formal-config.diff` + formal train config | `<FILL>` | `<PASS/FAIL>` |
| 5. resource envelope | R2b final peak recomputed against current host baseline; runtime pause if free<3GB | `formal-host-baseline.json` | `<FILL>` | `<PASS/FAIL>` |
| 6. W27 red-team gate | Launch Packet six files have no untreated P0/P1 | W27 red-team receipt + D-093 | `<FILL>` | `<PASS/FAIL>` |

Formal release outcome:

| field | value |
| --- | --- |
| formal release verdict | `<ALLOW_FORMAL_TRAIN / BLOCK_FORMAL_TRAIN / PARTIAL_NEEDS_REVIEW>` |
| release operator | `<FILL>` |
| release timestamp | `<FILL>` |
| release reason | `<FILL>` |
| stop reason if blocked | `<FILL>` |

### 5.1 Launch Packet Six-File Checklist

| file | required check | result | verdict |
| --- | --- | --- | --- |
| `FORMAL-LAUNCH-CONDITIONS.md` | 六条件表仍为 current authority；无 untreated P0/P1 | `<FILL>` | `<PASS/FAIL>` |
| `formal-config.diff` | only allowed static drift；LR schedule scaled; no hidden recipe drift | `<FILL>` | `<PASS/FAIL>` |
| `formal-host-baseline.json` | current host baseline captured; double threshold passes | `<FILL>` | `<PASS/FAIL>` |
| `formal-watchdog-contract.md` | free<3GB pause/fail-close contract present and operator path known | `<FILL>` | `<PASS/FAIL>` |
| `formal-eval-manifest.json` | formal eval basis frozen and points to intended cases/scorer/output | `<FILL>` | `<PASS/FAIL>` |
| `formal-receipt-template.md` | receipt captures run id, config, host baseline, watchdog, eval and non-claims | `<FILL>` | `<PASS/FAIL>` |

### 5.2 Host Baseline Gate

Double threshold:

- `swap used <= 1GB`
- `free_or_reclaimable >= max(R2b_final_peak_gb + 3GB, 21GB)`；当前 launch packet 最低硬线按 `free>=21GB` fail-closed。

Host-baseline capture command set:

```bash
date -u
sw_vers
sysctl hw.memsize vm.swapusage kern.memorystatus_vm_pressure_level iogpu.wired_limit_mb debug.iogpu.wired_limit iogpu.dynamic_lwm iogpu.wired_lwm_mb
memory_pressure -Q
vm_stat
top -l 1 -o mem -n 40 -stats pid,command,mem,rsize,state
ps -axo pid,ppid,rss,stat,comm,args | rg 'Python|c5_mlx_train_loop|codex|Claude|Feishu|Lark|WindowServer|ghostty|node|xcodebuildmcp|playwright'
df -h / /private/var/vm
```

Host verdict fields:

| field | value |
| --- | --- |
| swap used | `<FILL>` |
| free/reclaimable | `<FILL>` |
| R2b final peak | `<FILL>` |
| threshold verdict | `<PASS/FAIL>` |
| blockers | `<FILL>` |

### 5.3 W39 LR Runtime Verification

W39 原文命令/工具链填入前不得把 condition 4 写成 PASS。W42 在 run dir 未发现独立 `W39*` 报告文件，但从 `%0` pane capture 读到 W39 REPORT：`file=.../tools/verify_formal_lr_schedule.py`，`negative_metrics_155204=STALE_RC66`，`negative_trainlog_155204=STALE_RC66`，`positive_synthetic_450=RC0`，`exit_codes=0_FORMAL_450_MATCH,65_MISMATCH_OR_INSUFFICIENT,66_STALE_SCHEDULE`。以下为 W42 本机复跑的 concrete command surface；正式 run 需把 `<FORMAL_RUN_DIR>` 替换为真实 formal run。

```bash
R=/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-03-n2n4-train-readiness

# W39 negative fixture self-check: current 155204 shorttrain is intentionally stale-150 for formal LR; both must return rc=66.
python3 $R/tools/verify_formal_lr_schedule.py $R/F044-shorttrain-run-20260704T155204+0800/metrics.jsonl
python3 $R/tools/verify_formal_lr_schedule.py $R/F044-shorttrain-run-20260704T155204+0800/train.log

# Formal launch runtime check: first formal metrics/train log must match 450-update schedule; both expected rc=0.
python3 $R/tools/verify_formal_lr_schedule.py $R/<FORMAL_RUN_DIR>/metrics.jsonl
python3 $R/tools/verify_formal_lr_schedule.py $R/<FORMAL_RUN_DIR>/train.log
```

Known static anchors from Launch Packet:

| field | expected |
| --- | --- |
| formal iters | 1800 |
| LR schedule horizon | 450 updates |
| warmup | 36 |
| save_every | 600 |
| steps_per_eval | 200 |

Runtime acceptance line:

| check | expected | observed | verdict |
| --- | --- | --- | --- |
| first formal train log LR progression | consistent with 450-update schedule, not stale 150-update basis | `<FILL>` | `<PASS/FAIL>` |

## 6. FAIL Branches

No live invention after eval. Pick from this table and cite R2B-8/R2B-10.

| failure trigger | verdict label | required action | forbidden action |
| --- | --- | --- | --- |
| missing basis, missing artifact, checksum drift, wrong run bound | `BLOCKED_BASIS` | stop; repair manifest/eval binding; rerun only the missing evidence step | claiming PASS/FAIL from partial evidence |
| A < 10/15 | `FAIL_REGRESSION` | inspect A regression and replay/protected gap; return to data-recipe repair | formal launch; threshold lowering |
| A 10-11/15 | `FAIL_A_BELOW_GATE` | list failed cases and decide next round from prelocked repair lane | calling it close enough |
| B <= 9/15 | `FAIL_B_ZERO_DELTA_OR_DROP` | near-neighbor pair direction audit (`%43 T1/T2` lineage), then R3 representation-layer review if unchanged | 连训；claiming B moved |
| B 10-13/15 | `B_MOVED_NOT_PASS` | may satisfy D-085 numeric B gate if >9, but final wording must stay bounded | writing product-line natural semantics PASS |
| D < 18/34 or protected regression | `FAIL_D_PROTECTED` | replay/protected gap repair and retry | sacrificing D to buy A/B |
| query expected -> mutating actuation >0 | `FAIL_SAFETY` | review query data shape + eval/scorer; fix safety surface before any training claim | adding training data first; formal launch |
| bidirectional polarity net-new regression | `FAIL_POLARITY_REGRESSION` | map to A/B cases, inspect open/close directionality, then data-recipe repair | hiding it under aggregate score |
| expanded side-track improves but gate track fails | `FAIL_GATE_TRACK` | gate track controls verdict; expanded is diagnostic | using side-track as substitute gate |
| host baseline misses swap/free threshold | `FORMAL_LAUNCH_BLOCKED_HOST` | stop formal launch; refresh host baseline after operator cleanup/restart decision | launching overnight anyway |
| W39 LR runtime check missing or stale | `FORMAL_LAUNCH_BLOCKED_LR_BASIS` | obtain exact W39 command/output and verify 450-update LR progression | relying only on static config |
| W27 red-team has untreated P0/P1 | `FORMAL_LAUNCH_BLOCKED_REDTEAM` | close or explicitly disposition P0/P1 | treating grill closeout as red-team substitute |

Default if multiple failures occur: use the highest-risk label in this order: `FAIL_SAFETY` > `BLOCKED_BASIS` > `FORMAL_LAUNCH_BLOCKED_*` > gate-axis FAIL > side-track WARN.

## 7. Final Verdict Paste Block

```text
T-D VERDICT: <PASS / FAIL / BLOCKED_BASIS / PARTIAL>
Run: <FILL>
Adapter: <FILL>
Eval output: <FILL>

Axis results:
- A: <FILL>/15 vs gate >=12/15; base 3/15; verdict=<FILL>
- B: <FILL>/15 vs gate >9/15; base 9/15; verdict=<FILL>; wording=<PASS / B_MOVED_NOT_PASS / FAIL>
- D: <FILL>/34 vs gate >=18/34; base 18/34; verdict=<FILL>
- qa: <FILL> mutating actuation violations vs gate 0; verdict=<FILL>
- polarity: open->close <FILL>; close->open <FILL>; net-new regression=<FILL>
- expanded: B <FILL>/26; Q <FILL>/27; total <FILL>/53; query mutating <FILL>

Proof-class:
- train health: <FILL>
- R2b behavior gate: <FILL>
- formal launch readiness: <FILL>
- product/C6 V-PASS: NON_CLAIM

Formal release:
- six-condition verdict: <FILL>
- Launch Packet six-file verdict: <FILL>
- host baseline: swap=<FILL>, free/reclaimable=<FILL>, threshold=<PASS/FAIL>
- W39 LR runtime check: <PASS/FAIL/MISSING>
- formal train release: <ALLOW_FORMAL_TRAIN / BLOCK_FORMAL_TRAIN / PARTIAL_NEEDS_REVIEW>

Non-claim:
R2b PASS only proves the two R2a residual targets were fixed under this frozen shorttrain/eval surface. It is not product V-PASS, not broad 10-family semantics proof, and not automatic formal-training launch approval.

Next action:
<FILL from §6 if fail/block; otherwise execute formal launch only if all §5 conditions are PASS and 磊哥 gives the key>
```

---

# ✍️ T-D 终判（commander 亲填，2026-07-04 20:0x）

## Verdict: `F044_R2B_FAIL_STRATIFIED`

四轴对 D-085 放行线：**A FAIL（10/15<12）+ B FAIL（9/15 zero-delta）+ D PASS（19/34）+ qa FAIL（跨轨 9 违例）** → 正式训练今晚 **不起跑**（条件① 未满足，预落决策树 R2B-8 执行，零临场拍）。

## 分层证据（修复与新病灶均定位到 case/族级）

| 面 | 结果 | 证据 |
|---|---|---|
| 靶点① 近邻区分·单轮面 | ✅ **大幅修复** base 15/26 → adapter **25/26** | R2B-EXPANDED-ANCHOR-ADAPTER-REPORT.md |
| 靶点① 近邻 × 协议记忆组合面 | ❌ 未修：A 轴 5 残余全是 interface/airoutlet/三区 近邻族（P3D-A-011~015，与 R2a 同款、零新退化） | TD-EVAL-RECEIPT §A-Axis Diff + case 抽读 |
| 靶点② query 正向映射 | 🟡 改善 base 14/27 → 17/27 | expanded 报告 |
| 靶点② 无 intent 族负行为面 | ❌ **恶化 2→9**（安全级）：问句→改动工具，9 具名族 | query-zero-tolerance-cross-track.json |
| 保护面 D | ✅ 18→19 不退 | 门轨 paired report |
| 门轨内 qa（MP-029） | ✅ 修复 | 门轨 Query Scan |
| 训练本体 | ✅ 全绿（600/600，val 0.010，LR 残差 1e-12，零事故） | F044-R2B-TRAIN-RECEIPT.md + W46 |

## 机理判读（供 R3 立案，非本 verdict 声称）

训练同时做了两件事：把「近邻区分」学会了（单轮面），也把「必调工具」的倾向练强了——空输出病治好的副作用是无 intent 族问句被推向最近的改动工具（负例配比 envelope cap ~10% 不足以覆盖 9 个族的问句面）。近邻区分未与协议记忆语境组合泛化（组合样本缺失）。

## R3 数据订单（从失败 case 直接生成，精确可执行）

1. **9 具名族 unsupported-query 强负例**（SEAT/WINDOW/DOOR/LIGHT/SCREEN/VOLUME/WIPER/SUNROOF/SUNSHADE 每族问句变体 → NO_TOOL，per-family 不靠泛化）。
2. **interface/airoutlet 近邻 × 协议记忆组合样本**（A 轴 5 case 的训练面版本：多轮记忆语境内做近邻区分）。
3. B 轴照旧不动（连续三轮 zero delta，非本轮靶点；升维结论 L1 表示维度未丢仍成立）。

## Non-claims

R2b FAIL 不推翻：范式方向（近邻单轮面 96% 证明 D-domain 具名工具+contrastive 配方有效）、训练管线（三次事故后本体全绿）、门体系（每一层门都抓到了它该抓的东西）。不 claim C6/V-PASS/endpoint/正式训练就绪。
