# MAformac 后续整改 Roadmap 总纲（2026-06-22)

> 本文件 = **总纲**,统辖两条线:① **C5 recovery**(LoRA 0/34 灾难修复,Contract-v2;**范式 D-双层/B-frame 未决,据实验拍**) ② **UIUE 41 维调研落地**(三轮 ultracode)。
> 配套:[8d-rootcause.md](8d-rootcause.md)(根因)/ [exec-plan.md](exec-plan.md)(C5 详细执行)/ [grill-checklist-30.md](grill-checklist-30.md)(lora 整改 30+ grill,待 grill-with-docs)。
> 北极星不变:客户现场 5min — 听懂中文 / 反应快 / 不崩 / 看着惊艳 / 断网能跑。
>
> **🔁 grill 级联(2026-06-22 grill-with-docs,权威源 `grill-decisions.md`,下方旧内容冲突以其为准)**:① **两层 SSOT**——能力层 `semantic-function-contract.jsonl`(3990,LoRA训练/C6诊断锚它,客户随意说全集兜底)⊃ 演示层 `demo-golden-run.v1.yaml`(挑选炸场序列,**demo 全部延后,recovery 聚焦能力层大而全 LoRA**)② **C6 真口径 = `model_action_hard_pass`**(三维,name-only 降 smoke)③ route_tier 等 Compiler 从契约派生不手标 ④ **「CI 门」→「`make verify` 本地门」**(D2:仓库无 CI,有 `Makefile:19`)⑤ route_tier 派生统一改 `C5RouteTier.derive` 加 value.type(D1 待拍)⑥ A1 D/B tiny 对照 + `phase-1-c5-recovery-foundation` bundle。⚠️ grill 未走完(D1 + G2-G32),持续级联。

---

## 1. 此刻状态快照

| 线 | 状态 | 关键事实 |
|---|---|---|
| C5 LoRA | 🔴 candidate `0/34` UNSIGNED/BLOCKED | **已坐实首要缺陷=数据契约执行错 + surface/scorer 分叉 + empty=hit + name-last(代码层 8D D4);范式/scale 未证明为主因、亦未排除 → G4 ablation + tiny 对照裁决**(外审 P1-4 降调,不写「非范式/scale 已坐实」) |
| PR2/PR4 | ✅ 完成 | clip parity 证 + define-lora-training archived(与事故解耦) |
| C6 bench | ⚠️ harness 有缺陷 | 工具硬编码非 contract 派生 + empty=hit 掩盖 collapse(需修,P5/P6) |
| UIUE 调研 | ✅ 三轮 41 维 + 8 clone done | 鸟瞰图 v1/v2/v3 + 语音规范 + roadmap,**暂存 raw 待归位** `~/workspace/raw/.../research/2026-06-22-uiue-ultracode/` |
| 模型选型 | ✅ 守 Qwen3-1.7B | 不动(0/34 未证明是模型错;数据/surface 为已坐实缺陷,模型 confounder 未排除但无翻案证据) |
| 真机 | 🔴 无 target iOS device | endpoint V-PASS 阻塞链,需提前采购/借测 |

---

## 1.5 🔴 「0/34」定性修正 + recovery 成功标准（✅ 已定,见下方 banner）

> 🔁 **SUPERSEDED-BY-ζ/axes-catch(2026-06-22 grill,权威=`grill-decisions.md`)**:本段「成功标准**未定**/超25还是超7」**已被推翻**——亲核一手 `c6-summary.json:eval_runs[].gate_result` 坐实:C6 真口径 = **action `hard_pass`(tcm&sdm,按 case schema 拆 `mp_positive_action` n=23)**,**base 锚 10/23**(非整体 7/57、非 name-only 25);**readback 走方案 P**(端 renderer 状态播报,删 eval `:1039`,不计 model hard_pass);recovery 相对门 = `lora.mp_positive_action > base 10/23` + no_regression + wrapper_drift=0。下方原文保留作 grill 演进痕迹,**数字/口径一律以 grill-decisions 为准**。

- **「0/34」≠「LoRA 全废」**:C6 有**两套 scorer 口径相反**——name-only(`spike-e3:158`,只匹配工具名不验 args)base 25/34 vs lora **0/34**(positive 具名命中灾难,真,因 tool surface 分叉 intersection=∅);hard_pass(`C6VehicleToolBench.swift`,state_delta 严格,`all_c6_release` axis)base 7/57 vs lora **15/57 — LoRA 反而翻倍优于 base**。准确定性 = positive action 塌缩(数据契约错)+ negative 提升的混合 → **数据修好 + surface/scorer 对齐后 LoRA 有救**。
- 🔴 **recovery 成功标准未定(grill 头号议题)**:超 25(name-only)还是超 7(hard_pass)?C6 真口径 = spike-e3 还是 C6VehicleToolBench?两套从未对齐 → 必须先定,否则 recovery 又会拿「超 25 name-only」自我安慰。
- CC 教训(已写 8D D4.4):凭 receipt 顶层聚合数(25)当锚点、没下钻 axis = 同坑第三变体。

---

## 2. 两条线的关系（为什么放一个总纲)

- **C5 recovery 是「大脑」线**:让 LoRA 真能听懂中文→吐对 ToolCall。是 demo「听懂/不崩」的根。**最高优先,阻塞 demo 可信度。**
- **UIUE 是「脸面」线**:让 demo「看着惊艳/反应快」。**可与 C5 大量并行**(设计层不碰训练)。
- **交汇点**:① 语音体验规范(UIUE round3)依赖 C5 真模型才能定真实 TTFA/think-tag(UIUE completeness 已标);② C6 bench 修复(C5 P5/P6)产出的「分层打分 + 状态读回」正是 UIUE 状态 UI(D8)的数据源;③ 二者共享 contract SSOT(C5 的 ToolContractCompiler 派生的 tool surface = UIUE 车控卡片的契约源)。

---

## 3. 核心决策树（待 grill-with-docs 拍）

```
C5 0/34 → 根因=数据契约执行错(已坐实)
            │
   ┌────────┴─── 先做(无争议,先修数据证明根因) ───┐
   │  D-fix:真删工具 + 清446矛盾对 + name-first + label门 + tiny-overfit ablation
   │  (hermes H-A/H-C:先证数据是主因,empty 28/34→<5/34)
   └────────┬──────────────────────────────────────┘
            │ 然后才谈范式(0/34 不能当范式证据,confounder 已坐实)
   ┌────────┴────────┐
 ⭐D-双层(gptpro)      B-frame判等(hermes)
 模型出 set_cabin_*    守 tool_call_frame
 +内部ToolCallFrame IR  +device enum 二元判等
 +compiler 派生        C6 改判等口径
 顺Qwen具名FC先验       顺C1 SSOT(frame是codegen产物)
 102→domain分层不爆炸   8工具压成1工具+device
   └────────┬────────┘
       ⚠️ 两者都要先过 D-fix + ToolContractCompiler(SSOT派生);
       范式由 tiny-overfit 对照实验 + grill 拍,不凭 0/34
```
**CC 倾向**:架构层采 gptpro 的 **ToolContractCompiler 单源派生**(消除 SSOT 失守,无争议);范式层 D-双层 与 B-frame判等 留 grill + tiny 实验定(我不再凭 0/34 拍范式,confounder 教训)。

---

## 4. 阶段总览（C5 recovery,详见 exec-plan.md)

```
M0 决策冻结(ADR-tool-surface-v2 variant待定/硬门/scope) 0.5-1天
M1 ToolContractCompiler(SSOT单源派生)      2-4天  ← 解 SSOT 失守
M2 Surface/Runtime 闭环(consistency make-verify 门)    2-3天  ← 解 intersection=∅
M3 Gold/Verifier(verify_gold=100%)         3-5天
M3.5 ⭐D-fix tiny-overfit ablation          1天   ← 先证数据根因(hermes,CC加在重训前)
M4 Base C6 v2 baseline                      1-2天
M5 Data v2(真删工具/清矛盾/name-first/label门) 2-4天
M6 Tiny+Full action-focused LoRA            2-5天
M7 Parity + Physical Endpoint               3-7天(看真机)
M8 Final 异构审计 + sign/blocked            1-2天
```

## 5. UIUE 落地阶段（详见 raw/.../round2/roadmap.md，可与 C5 并行）

```
P1 低保真验证(HTML反例/概念稿)  🟢可与C5并行(不碰代码)
P2 设计系统token              🟡半并行
P3 组件库 / P4 高保真三屏 / P5 测试+演示编排  🔴等codex收工归位(SwiftUI代码层)
```
**现在就能并行做(raw 暂存,零 C5 冲突)**:UIUE 调研档归位 docs/research(codex 已收工可做)+ HTML 反例脚本 + 演示编排 openspec change 草拟。

## 6. 与 codex / 真机 协调

| 现在可做(并行) | 串行依赖 |
|---|---|
| UIUE 调研归位 docs/research + INDEX | C5 重训等 ToolContractCompiler + verify_gold |
| UIUE HTML 低保真 + token 设计(raw) | **硬门:UIUE SwiftUI 代码层等 C5 contract version freeze(G6 范式拍板 + Compiler 派生 tool surface)后才进**;在此前只设计层(raw),不碰 contract 派生物 |
| 真机采购/借测(解 endpoint 阻塞) | endpoint V-PASS 等 C6 model-quality pass |
| C5 数据契约修复 + label 门 | full LoRA 等 tiny-overfit ablation 证根因 |

## 7. 不做清单（防 over-engineering / 重蹈覆辙)

- ❌ 不抢救 0/34 candidate(报废)。
- ❌ 不凭 0/34 拍范式(confounder 坐实,范式靠 tiny 实验+grill)。
- ❌ 不再手写第二套 tool schema(必须 compiler 派生)。
- ❌ 不用 metadata 声称代替 code enforce(真删工具/真验矛盾)。
- ❌ 审计不只审合规,必加语义正确性维度。
- ❌ simulator 不代替真机 V-PASS;same-source 审计不代替异构终审。

## 8. 起手第一步

1. 读 [8d-rootcause.md](8d-rootcause.md) 吃透根因(代码 file:line 级)。
2. grill-with-docs 过 [grill-checklist-30.md](grill-checklist-30.md) 的 30+ 议题(尤其范式 D-双层 vs B-frame / label 门口径 / 审计框架补维度)。
3. 拍板后按 [exec-plan.md](exec-plan.md) M0 起步:ADR-tool-surface-v2(variant 待 G6 拍)+ ToolContractCompiler(支持 D/B 双 surface)。
4. 并行:UIUE 调研归位 docs/research + INDEX(codex 已收工)。
