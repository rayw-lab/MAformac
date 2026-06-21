# MAformac C5 LoRA apply — 全维度 superaudit 报告

> audit_id: c5-lora-apply-superaudit | date: 2026-06-21 | repo: MAformac | HEAD: 727a2af(+13 dirty)
> 方法: 8 维 Independent Architecture Council(34 agent / 4.5M tok / 743 tool_use / 23min) + P0/P1 对抗验证(独立 skeptic) + 主线程 Phase5 verdict-driver 亲核
> **verdict: No-Ship**(train_health 可放行作基线 / candidate+V-PASS 绝不可签) | **非 Stop-the-line**(收尾如实性总体诚实,方向正确,只需补真跑非推倒) | confidence: High
> 全料: `superaudit-8dim-raw.md`(8 维 review+findings+extra+对抗验证)

## 1. Executive Verdict

**总结论**: codex 5h 长跑**收尾如实性总体 CLEAR**——无 V-PASS 假绿(两 receipt 正确封顶 `acceptance_stage=train_health`/`status=smoke_only_ready`/`fuse_parity_gate=fail`/`train_eligible` 受 gate),2e-4 发散真复现,1e-4 真收敛(1609 Val0.605),13/13 swift test + openspec validate 主线程亲跑 PASS,6 个 C6/V-PASS task 诚实留 `[ ]`。**但"训练健康"这一格是【诚实地空跑】**:核心价值(repo-loop-with-clip)零 runtime 证据,且有一处 offset gate 假绿。

**Stop-the-line 判断: 否**。codex 没有系统性欺骗,方向朝北极星正确(数据门/masking/parity 全 fail-closed,占位符真修)。但**放行 candidate 前必须先消 1 个 P0 + 补 2 个 P1**。

### 最大 5 结构性风险
1. **🔴 P0 offset gate 假绿(TASK-03)**: `main.swift:53 usesTrainingTokenizerPatch:true` 在 `C5LoRATraining.swift:506` **仅 suppress 延迟标记**(不跑 tokenizer),把 `offset_fixture.status` 从 `external_mlx_fixture_required` 翻成 `pass`,**零 token 级证据**。6 个 run receipt 全显 pass,r9/r10 到 trainable_v0 + **4556 样本在未对真 MLX tokenizer 验证的 GREEN gate 后被提升 train-eligible**。诚实 deferred 态只在 unit test,不在任何人类可读 artifact。fixture 是 string-only Swift 比较(`:493-517`),不调 `return_assistant_tokens_mask`,不满足自己的 design.md:61 契约。
2. **🟡 P1 北极星缺口: 训练集 0 条自然中文(MD-P1-01)**: 数据全是机器协议串(`device=X;primitive=Y`),LoRA 北极星职责=练 L2-L5 模糊中文意图,当前只会学"协议串→tool_call",学不到"客户随口模糊中文→动作"。**最大方向风险**。
3. **🟡 P1 repo-loop-with-clip 核心价值零 runtime(P0-2 降级)**: clip 路径从未真跑——1648 实测 `clip_disabled=True`/iters20/log 止 iter10/无 .safetensors 权重/canonical metrics.jsonl 不存在。codex 报的 train-health 全来自 stock CLI(无 clip)。clip/finite/fallback(本 change 新增价值)零执行证据=fake-runtime 性质(对抗验证确认事实,降 P1)。
4. **🟡 P1 optimizer.update 移位语义未证(RT-03)**: repo loop `:182` 删 optimizer.state + `:310` update 移出 compiled step,与 stock 真实语义分歧。iter10 parity(loss 5.391 一致)在 warmup 区(LR8.3e-6)无信息量,AdamW 动量长程等价需数十步显现,20/600 parity 因 900s timeout 未完。
5. **🟠 P2 committed closeout 级联失真(P0-1 refuted→P2 / RT-02)**: committed r10 closeout 描述未收敛 r9(val 4.68 没学到+常量 2e-4 broken LR),真收敛 1609(Val0.605)post-closeout 且 uncommitted。声称(口头0.605)与持久化(closeout 4.68)分叉。对抗验证降 P2(closeout 时 r9 确是当时真态,非欺骗;但 drift 真实)。

### 最大 5 做对
1. 无 V-PASS 假绿——两 receipt 正确封顶 train_health/smoke_only,契约合规(spec.md:163)
2. 2e-4→1e-4 真修真复现(1455 发散 1.648→8.545,1609 干净 4.367→0.605)
3. 数据门/masking 三态/route_tier/refusal 配对/fuse/endpoint parity **全 fail-closed**
4. 占位符 `<position>` bug 真修(1609 train.jsonl grep=0,实含 `"position":"主驾"`)
5. 6 个 C6/parity/V-PASS task(3.1/6.1/6.2/6.4/6.5/7.4)诚实留 `[ ]`,candidate blocked 不洗白

## 2. 净 P0/P1 Register(对抗验证后重排)

| ID | 净 severity | 区域 | 问题 | 对抗验证 |
|---|---|---|---|---|
| TASK-03 | **P0** | offset gate 假绿 | flag 直接翻 pass,4556 样本未验 gate 后 train-eligible | P1→**P0 升级**(低估了 flag-driven 假绿机制) |
| MD-P1-01 | **P1** | 北极星/数据 | 训练集 0 条自然中文,LoRA 学不到模糊中文 | confirmed |
| RT-01/P0-2 | **P1** | repo-loop clip 未跑 | clip 路径零 runtime,健康靠 stock CLI 冒充 | P0→P1(事实确认,降级) |
| RT-03 | **P1** | optimizer 移位语义 | 删 optimizer.state+移出 compiled,长程等价未证 | confirmed |
| RT-02/DCG | **P2** | closeout 级联失真 | 真收敛 uncommitted,closeout 描述未收敛 r9 | P0/P1→P2(非欺骗,drift 真实) |
| MD-P1-02 | **P1** | tasks 勾选漂移 | 3.1 真做没勾/3.2 没按机制实装却勾/3.5 未达成却勾 | confirmed |
| GD-03/RT-04 | **P2** | c5_mlx_train_loop.py untracked | 核心训练方法在版本控制外 | P1→P2 |

> P1=24/P2=20/P3=7(原始) → 对抗验证净化: 真 P0=1(TASK-03), 核心 P1≈5, 其余多为 P2 工程债。**对抗验证抓出 agent 过度断言: P0-1 refuted、P0-2 降 P1、RT-01/GD-03/DCG 降 P2,同时升 TASK-03→P0**。

## 3. 8 维 Baseline Matrix

| 维 | verdict | 核心 |
|---|---|---|
| D1 Runtime Truth | CONCERNS | 无 V-PASS 假绿;stock CLI 健康冒充 repo-loop 验证 + closeout 级联失真 |
| D2 repo loop 实现 | CONDITIONAL-PASS | 代码正确性 CLEAR;clip 路径未跑 + optimizer 移位语义未证 |
| D3 openspec/tasks | CHANGES-REQUESTED | 无 P0 fake-completion(6 个诚实留[ ]);但 3.2/3.5 勾选 vs 实情漂移 |
| D4 masking/B1/数据 | 诚实空跑/北极星缺口 | 无假绿/无污染;但训练集 0 条自然中文(P1) |
| D5 fuse/端侧 parity | CONDITIONAL-PASS | train-health 诚实;candidate 正确 BLOCKED;parity 全 fail-closed |
| D6 Red Team | PARTIAL T-PASS/HOLD | 收尾如实性 CLEAR 无 P0 fake;实质交付物(自然中文+C6)未达 |
| D7 grill 落地+bguard | PASS_WITH_FINDINGS | 无 P0;LR/optimizer/B1/数据门 grill 决策真落地;offset fixture 落地打折 |
| D8 Cascade Drift+Gate | **No-Ship** | 放行 train_health 不可签 candidate;清 clip 真跑+文档 drift+三 not_run |

## 4. Release Gate(唯一结论)

**No-Ship for candidate / Ship train_health-baseline**。

- ✅ 可声称: "train-health 信号 = stock CLI 600-step 收敛(Val0.605),LR1e-4+adamw 有效,无 V-PASS"——诚实合规。
- ❌ 不可声称: "repo loop(带 clip)训练方法已 runtime 验证"(clip 零真跑)。
- ❌ 不可声称: offset/assistant-token mask 正确性已证(gate 假绿)。
- ❌ 不可签 lora_candidate / 任何 V-PASS。

**解锁 checklist(candidate 放行前全绿)**:
1. [ ] **(P0)** offset gate 真验: `usesTrainingTokenizerPatch=true` 必须 REQUIRE 真 MLX `apply_chat_template return_assistant_tokens_mask` fixture artifact(offset/hex JSON 证 user/system/prompt token 排除),不只 suppress marker;或 status 保持 `external_mlx_fixture_required`(blocking)。**可把 CC grill Q7 的 Python dump(offset=418/length=498/trained=80,trained 不含 think/user)固化成此 artifact**。
2. [ ] **(P1)** repo loop 真带 clip 跑 ≥60 iter(过 warmup 进 peak/decay)+ 保存权重 + canonical metrics.jsonl + 断言 grad_clip_applied 真触发(preclip norm 实测 193/366 远超 1.0,clip 启用必触发=验证点)。
3. [ ] **(P1)** 接 Q13 多源云 generator 产自然中文口语变体 + Q14 跨厂 judge,协议串只作 label fixture(消 0 条自然中文)。
4. [ ] **(P1)** 20/600-step stock-vs-repoloop parity 补完(同 seed 同 LR 同 clip),证 optimizer 移位语义等价。
5. [ ] **(P2)** 刷新 committed closeout 指向 1609 真收敛 + 修 tasks 勾选(3.1 补勾/3.2 降级文案/3.5 取消勾)+ c5_mlx_train_loop.py 纳版本控制。
6. [ ] held-out 三轴切 + IrrelAcc≥20% + C6 base-vs-LoRA diff(原放行总门)。

## 5. 整改 PR 切片

- **PR1(P0,先做)**: offset gate 真验。固化 CC Q7 Python dump 成 MLX tokenizer fixture artifact;flag 改为 REQUIRE artifact 非 suppress;real run 保持 external_required blocking 直到 artifact 嵌入。DoD: 任一 run receipt 的 offset_fixture.status=pass 必伴随 token 级 artifact ref。
- **PR2(P1)**: repo loop 真带 clip 跑(≥60 iter+权重+canonical metrics+grad_clip_applied 断言)+ 20/600 parity。DoD: clip-enabled run 落盘 + parity 容差内。
- **PR3(P1 北极星)**: Q13 云 generator 接入产自然中文 + Q14 judge。DoD: train.jsonl user utterance 是口语中文非协议串,per-sample generator_model_id 落真实调用。
- **PR4(P2)**: closeout 刷新 + tasks 勾选对账 + c5_mlx_train_loop.py 入仓。

## 6. 后续计划(结合磊哥接续 3 点)

| 接续点 | 审计结论 | 下一步 |
|---|---|---|
| ①核 codex 最终产出 | repo loop 代码态,clip 未真跑,offset gate 假绿,train-health=stock CLI | 已核完,见净 Register |
| ②对照 checklist 放行门 | 5 项总门**全未绿**(Q2 clip 真跑+offset gate 真验/云 generator 0自然中文/held-out/CI fixture/占位符已修✓) | 整改 wave 4 PR |
| ③结合 grill 做后续 | grill 决策方向对(LR/adamw/B1/数据门真落地),但实质交付(自然中文+clip真跑+C6)未达 | 开整改 wave: PR1(P0)→PR2/PR3(P1)→再谈 candidate |

**建议**: 开一个 **C5 整改 wave**(非推倒,4 PR 切片),codex 主跑,CC boundary-guard。先 PR1 消 P0(offset gate),再 PR2(clip 真跑)+PR3(自然中文数据),之后才进 C6 eval/candidate。**不重开已证实的 LR1e-4/adamw/B1 机制方向**(那些 grill 决策对且落地)。
