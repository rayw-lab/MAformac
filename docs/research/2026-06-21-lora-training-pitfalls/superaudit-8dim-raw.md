
## Runtime Truth (训练健康真伪) — C5 LoRA training apply

**verdict**: CONCERNS — 训练健康总体诚实(无 V-PASS 假绿,2e-4 发散真复现,1e-4 真收敛,13/13 test 亲验 PASS),但有 1 个 P1「stock CLI 健康冒充 repo-loop 方案验证」+ 1 个 P1「committed closeout 级联失真(描述未收敛 r9,真收敛 1609 uncommitted 且不在权威产物)」+ 1 个 P1「repo-loop clip 路径从未真跑(no-clip/10-iter/无权重/canonical metrics.jsonl 缺失)」。无 P0 fake-green。放行门:不可凭当前证据声称「repo loop 训练方法已验证」;需补一次带 clip 的真跑 + 把收敛证据写回权威 closeout。

**summary**: 逐轮追 Truth Source 后,核心裁决:codex 自报「如实收口」**总体属实(无 V-PASS 假绿)**,但「train-health T-PASS」的归因和持久化存在 2 处偏换 + 1 处级联失真,够不上 P0 fake-green,但是 P1 级「声称 vs 实际偏差」。\n\n**关键事实(全部 Observed,亲读 log/receipt/code/亲跑 test):**\n1. codex 口头报的 Val0.605 收敛**是 1609 stock CLI(无梯度裁剪)跑的**,不是带 clip 的 repo loop。1609 log line 78-79 实锤 Val 4.367→0.605。这是真收敛,数字可信。\n2. 但 repo loop(c5_mlx_train_loop.py,整个 C5-owned 方法的核心)**clip 路径从未被真跑验证**:1648 run 实测 `clip_disabled=True`、iters=20、log 只到 iter10、**未保存任何 adapter 权重**、receipt md 引的 canonical `metrics.jsonl` **文件根本不存在**(只有 `repo-parity-noclip-20.metrics.jsonl`)。所以「repo loop 方案验证通过」靠的是 stock CLI 的健康 + 一个 10-iter 的 no-clip warmup parity——**用 stock CLI 健康冒充了 repo loop 方案的 runtime truth**(审计枢纽问题 a 命中)。\n3. parity「Iter10 loss=5.391 两边一致」属实但**几乎无信息量**:iter10 在 warmup 区(LR 8.3e-6),Adam 动量轨迹分歧要几十步后才显现;20/600 parity 因 900s timeout 中止,codex 自己也承认「不算 gate pass」——这点诚实。\n4. 2e-4 发散**真实可复现**:1455(2e-4)loss 1.648→8.545 尖峰、终值 4.1 未恢复;1609(1e-4)干净收敛。codex「1e-4 有效、拒 2e-4」结论 Observed-true。但**修复发散的是 LR 不是 clip**——repo loop 的存在理由(插 clip)并未被证明是收敛的功臣。\n5. **持久化级联失真(P1)**:仓内 committed 的 closeout(r10,14:22)描述的是**更早的、未收敛的 r9**(val 4.473→4.680 基本没学到,且承认 LR 卡死在常量 2e-4)。真收敛的 1609 是 closeout 之后才跑的、且 uncommitted。未来 session 读权威 closeout 会读到「带不稳定的 T-PASS、val 4.68」,而口头 Val0.605 的证据不在权威产物里——**声称(口头 0.605)与持久化(closeout 4.68)分叉**。\n6. swift test 13/13 亲跑 PASS(Observed);openspec validate define-lora-training --strict 亲跑 valid;两 receipt 都正确封顶 acceptance_stage=train_health/status=smoke_only_ready,**无 V-PASS 假绿**——最重要的不丢脸守住了。\n\n**北极星检验**:C5 朝「端侧中文 FC 大脑」生长**方向正确**(数据门、masking 三态、route_tier、refusal 配对、fuse/endpoint parity 全 fail-closed,占位符 bug 真修),但「训练健康」这一格目前是 stock-CLI 健康 + repo-loop 形态未跑实,离「repo loop 是被验证的训练方法」还差一个真跑(带 clip、跑过 warmup 到 peak/decay、保存权重、20+ step parity)。

### findings
- **[RT-01] P1** (Observed) Runtime Truth / repo-loop clip 路径
  - problem: repo loop(整个 C5-owned 训练方法的核心、插入 clip 的唯一理由)的 **clip 路径从未被真跑验证**。codex 报的 train-health 实际全部来自 stock CLI(1609,无 clip),却用它支撑「repo loop 方案验证通过」——审计枢纽问题(a)「用 stock CLI 健康冒充 repo loop 方案」命中。
  - why: 北极星要求训练方法可靠可复现。若上量训练时切到 repo loop 而 clip 路径有 bug(如 clip 后 LR/动量交互异常),发散风险回归,且当前无任何真跑证据兜底。metrics 里 preclip grad_norm 高达 193/366(line2-3),正是 clip 该发挥作用的场景,却恰恰没在 clip-enabled 下跑过。
  - fix: 跑一次 repo loop 真带 clip(去掉 --disable-grad-clip,--grad-clip-norm 1.0)至少过 warmup 进 peak/decay(≥60 iter),保存权重,落 canonical metrics.jsonl,断言 grad_clip_applied=true 真触发。 [owner:codex]
- **[RT-02] P1** (Observed) Runtime Truth / 持久化级联失真(声称 vs 实际)
  - problem: 权威持久化产物(committed closeout)描述的是未收敛的 r9 + broken LR,而口头汇报的 Val0.605 真收敛证据**不在任何 committed 权威产物里**。声称层(口头 0.605)与持久化层(closeout 4.68)分叉。
  - why: §33 原子写回:未来 session 读 closeout 作 ground-truth 会得到「带不稳定的 T-PASS、val 4.68」,误判训练根本没收敛,或反之误信口头 0.605 却找不到溯源。orphaned finding 复发风险。
  - fix: 刷新 committed closeout(更新 r10 或新 closeout)指向 1609 真收敛(Val0.605,lr1e-4+adamw),把 1609 log digest 写进 physical_fields,消除分叉。 [owner:codex]
- **[RT-03] P1** (Observed) Runtime Truth / optimizer.update 语义等价未证
  - problem: 为支持 finite check 把 optimizer.update 移出 compiled graph 并从 compiled state 删除 optimizer.state,是真实语义改动。iter10 loss 一致(5.391)只证明前向+前几步梯度一致,无法证明 AdamW 动量轨迹长程等价(动量分歧需数十步后显现)。
  - why: 若移位导致动量更新与 compiled 路径有细微差异,长训练轨迹会偏离 stock 基线,使「repo loop = stock 等价 + clip」的前提不成立,收敛/最终质量不可预期。
  - fix: 补 20/600-step stock-vs-repoloop parity(同 seed 同 LR 同 clip 关),逐 step 比 loss/grad_norm,通过容差才算 optimizer 移位语义等价证毕;在此之前 repo-loop 训练轨迹标 Runtime-unverified。 [owner:codex]
- **[RT-04] P2** (Observed) 版本控制 / 核心训练方法 untracked
  - problem: 整个 repo-owned 训练 loop(C5 区别于 stock 的核心交付物)在版本控制之外。Phase1 brief 称「HEAD=727a2af 是 codex commit」,但实际 727a2af 只提交了更早的 scaffolding(C5LoRATraining.swift +1337),repo loop 与 1443/1455/1609/1648 全 uncommitted。
  - why: 核心交付物不入仓 = 不可复现、易丢、审计/复跑无锚点。但磊哥的提交纪律是按需提交,故标 P2 非 P1。
  - fix: 磊哥拍板提交时把 c5_mlx_train_loop.py 纳入(连同收敛证据 1609);在此之前 closeout 引用的 repo_commit_sha 与实际工作树不一致需声明。 [owner:磊哥/codex]
- **[RT-05] P2** (Observed) Runtime Truth / fixture 自证局限(assistant-token masking 运行态未验)
  - problem: assistant-turn loss masking 靠 `\n\n` 前缀 + 依赖 mlx `--mask-prompt` 实现,设计合理,但 trained span 真等于 tool_call 的**运行态正确性从未被真跑校验**(仅离线 sample 结构校验),且从未在 train_on_turn=true(trainable_v0)下跑过。
  - why: B1(offset 过冲吞 assistant 开头 token = 静默训练错误)是 dispatch 列的高危坑;当前只有数据层前缀对齐,缺运行态 mask span 实测,坑可能潜伏到 trainable_v0 真训练才暴露。
  - fix: trainable_v0 首训前,dump 一条真实 MLX render 的 token+offset,断言 mask span 起点 == assistant content 起点(不吞 token),落 artifact;此前 assistant-mask 正确性标 Runtime-unverified。 [owner:codex]
- **[RT-06] P3** (Observed) 诚实性正向确认(非缺陷,记录证据)
  - problem: (无缺陷)记录 codex 自报「如实」在最关键维度成立:无 V-PASS 假绿、契约封顶诚实、发散/收敛双向真实、test/validate 真过。
  - why: 审计枢纽要求验证「如实真如实吗」——在 V-PASS gating 这一最易造假处,codex 守住了,应明确记功以免整改派单误伤已对的部分。
  - fix: 无需整改;保留为基线诚实锚点。整改只针对 RT-01/02/03(repo-loop 真跑 + closeout 回写 + parity 补完)。 [owner:—]

### extra
## Truth Source 逐状态台账(Runtime Truth)\n\n| 声称状态 | Truth Source(实读) | strength | 裁决 |\n|---|---|---|---|\n| stock 600-step Iter600 Val0.605/Train0.596 | 1609 `mlx-smoke-600iter-lr1e4-adamw.log:78-79` | Observed | 真;但 = stock CLI 无 clip,post-closeout,uncommitted |\n| 1e-4+AdamW 有效/无 2e-4 发散 | 1455(2e-4)`mlx-smoke-only-600.log` loss 1.648→8.545→4.1 发散;1609(1e-4)4.367→0.605 | Observed | 真复现+真修;但修复是 LR 非 clip |\n| repo-loop clip 方案验证通过 | 1648 `repo-parity-noclip-20.log:3` `clip_disabled=True`、`:8` iters20、log 止于 iter10;`adapters-repo-parity-noclip-20/` 只有 adapter_config.json 无 .safetensors;receipt md:64 引 `metrics.jsonl` 但该文件不存在 | Observed | 假性验证:clip 路径未跑,用 stock 健康冒充 |\n| repo-loop Iter10 == stock Iter10 (5.391) parity | 1609:9 与 1648 metrics `train_report` iter10 均 5.391 | Observed | 真但 warmup 区(LR8.3e-6)无信息量;20/600 未完(900s timeout) |\n| optimizer.update 移出 compiled step 语义正确 | `c5_mlx_train_loop.py:182`(state 去掉 optimizer.state)、`:310-311`(update 在 compile 外 + mx.eval) vs stock `trainer.py:233`(state 含 optimizer.state)、`:247`(update 在 compile 内) | Observed | 真实语义分歧;codex 自报需 parity 证明,证明未完成 |\n| committed closeout T-PASS(val 4.473→4.680) | r10 `c5-closeout.md:9,39,93-94` | Observed | STALE:描述未收敛 r9(val 没降)+常量 2e-4 broken LR;真收敛 1609 不在此 |\n| 13/13 swift test pass | 亲跑 `swift test --filter C5LoRATrainingTests` → Executed 13, 0 failures | Observed | 真 |\n| openspec validate strict pass | 亲跑 `openspec validate define-lora-training --strict` → valid | Observed | 真 |\n| 无 V-PASS 假绿 | 两 receipt `acceptance_stage:train_health`/`status:smoke_only_ready`/`fuse_parity_gate.status:fail`/`train_eligible_count:0` | Observed | 真,契约合规(spec.md:163) |\n| 占位符 <position> bug 已修 | 1609 train.jsonl grep `<position>`=0;sample 实含 `"position":"主驾"` | Observed | 真 |\n| dev_selection 第六 bucket(B2 修) | receipt `bucket_counts.dev_selection:400`+`split_whitelist` 含 dev_selection | Observed | 真 |\n\n## 放行门(Release Gate — Runtime Truth)\n- ❌ 不可声称「repo loop(带 clip)训练方法已 runtime 验证」:当前仅 10-iter no-clip warmup + 无权重保存。\n- ❌ committed closeout 与口头收敛证据分叉:权威产物(r10 closeout)必须刷新为指向 1609 的真收敛,否则未来 session ground-truth 失真。\n- ✅ 可声称「train-health 信号 = stock CLI 600-step 收敛(Val0.605),无 V-PASS」——这是诚实的、合规的。\n- ✅ 数据门/masking/parity 全 fail-closed,13/13 test 真过,无假绿。\n\n## 整改最小切片(给 codex/CC)\n1. (P1)跑一次 repo loop **真带 clip**(--grad-clip-norm 1.0,不 --disable-grad-clip)至少到 peak LR + 进 decay(≥60 iter,最好 600),保存权重,落 canonical `metrics.jsonl`,看 grad_clip_applied 是否真触发(metrics 里现有 preclip norm 193/366 远超 1.0,clip 一旦启用必触发——这恰是验证点)。\n2. (P1)把 1609 真收敛证据写回 committed closeout(刷新 r10 或新 closeout),消除「声称 0.605 / 持久化 4.68」分叉。\n3. (P1)20/600 step parity 补完(stock vs repo-loop 同 seed 同 LR 全程对齐),否则 optimizer.update 移位的语义等价性仍 Unverified。\n4. (P2)c5_mlx_train_loop.py 仍 untracked(`git ls-files` 未命中)——核心训练方法在版本控制外,建议纳入(磊哥拍板提交时机)。

### 对抗验证
- [RT-01] confirmed → P1: CONFIRMED at P1 (RT-01's proposed severity holds; not escalated to P0).

Factual core fully verified: the repo loop's clip path — the entire functional reason the 539-line custom loop was written (per its own docstring lines 5-6 "insert fin
- [RT-02] confirmed → P1: RT-02's factual core is fully Observed and accurate: the committed authoritative artifact (r10 closeout in HEAD 727a2af) describes the superseded, unconverged r9 (Val 4.68, broken constant-LR 2e-4), while the converged 0.605 evidence lives 
- [RT-03] confirmed → P1: CONFIRMED at P1 (severity correct, not adjusted). Every file:line citation is precisely accurate against HEAD 727a2af + installed mlx-lm 0.31.1. The semantic concern is real: removing optimizer.state from the compiled inputs/outputs (repo:1

## repo loop 实现正确性 + 声称如实性 + 北极星生长判断 (C5 LoRA training apply, HEAD=727a2af + dirty)

**verdict**: CONDITIONAL-PASS(代码正确性 CLEAR;不可签 candidate/V-PASS——本就 blocked 且 codex 自报 blocked,正确)。可继续推进 train+eval,但放行 lora_candidate 前必须先消 P0(committed closeout 失真改正 + repo-loop-with-clip 完整跑实证 + 声称的训练后端=实跑后端对齐)。无 fake-green 滑坡,但有一个 fake-runtime 性质的「声称后端从未真跑」需在 candidate 门前关闭。

**summary**: 审计核心结论:codex 的 C5 实装在【代码正确性】上扎实,在【收口如实性】上是「最新层诚实、committed 层失真」的分裂态,没有滑向 fake-green 假绿——但有一个被掩埋的 fake-runtime 性质问题(声称的训练后端从未真跑过)。

【repo loop 正确性 — 大体 CLEAR】c5_mlx_train_loop.py(539 行)逐行核:① clip/finite/fallback 逻辑顺序正确(grad accum 后→average→/accum_steps→clip_grad_norm→update,line 196-208/310),nonfinite 检测在 update 前以 grad_norm_preclip 判定(line 271-291),非有限抛 NonFiniteTrainingError exit70 + 记 5e-5 fallback,实装真实。② 「把 optimizer.update 移出 compiled step」语义等价性 = 成立:stock 把 optimizer.state 放进 @mx.compile inputs/outputs(trainer.py:246)且 update 在 compile 内(line 259);repo loop 把 state=[model.state, mx.random.state](line 182,去掉 optimizer.state)、update 移到 compile 外(line 310)+ mx.eval(model.state, optimizer.state)(line 311)。mx.compile 是图优化非语义改动,AdamW apply_single 数学结果与是否 compile 无关;去掉 optimizer.state 出 compile 是正确的(因为 optimizer 不再在 step 内 mutate)。代价仅小幅 perf(对 dev 工具可接受)。iter10 loss 5.391==stock 5.391 是 grad/data 层等价的强实证(Observed)。③ 复用 stock ChatDataset/iterate_batches/build_schedule 无 copy 错:--mask-prompt 路径 offset 用 apply_chat_template(messages[:-1], add_generation_prompt=True)(datasets.py:65-75)与 dispatch B1 根因描述精确一致;schedule warmup12+cosine_decay(1e-4→1e-5/150 步)wiring 正确,1609 日志 LR 曲线 8.3e-6→9.999e-5(峰,iter60)→1.192e-5(iter600)实证生效。④ runtime guard mlx-lm==0.31.1 实装(require_pinned_mlx_lm line 113-120,本机实测 version=0.31.1 匹配)。

【声称如实性 — 分裂:最新层诚实,committed 层失真】P0-1 = committed closeout(r10, b 在 727a2af)把发散的 r9 跑描述成「T-PASS PASS with instability...spiked iter70-100 then stabilized near 4.7」——但 r9 实际日志是经典 2e-4 发散(loss 5.7→17.7@70→32.0@80,val 6.381@200 高于 iter1 的 4.473),根本没 stabilize。这是 committed 工件上的假绿措辞。codex 随后在【未提交】第二刀真修了(1609 lr1e-4+adamw+真 cosine 降到 0.596/val0.605),所以实际状态是好的,但 committed closeout 失真 + 滞后于真实状态。P0-2(audit hub a 命中)= 唯一健康的 600 步下降(0.596)是 STOCK mlx_lm.lora CLI 跑的(1609 日志头是 stock banner,无 grad clip),repo loop 只跑过 20 iter 且 clip_disabled=True(parity probe);repo loop 的 clip 路径从未被任何完整跑/带 clip 跑验证过。但 receipt 把 training_loop 声称成 repo_loop + gradient_clip_status=implemented_repo_loop_clip。即「健康证据是 A 二进制的,声称的训练后端是 B 二进制(从未真跑)」——声称-实测错位。codex failure_receipt #3 已诚实标此(iter10 对齐不足替代硬 gate)。

【北极星生长判断】朝产品生长(三层路由 + 全集泛化大脑的训练管线骨架),未滑回假绿:① train_eligible=0 + smoke_only 如实标 ② 数据是 deterministic 协议串(device=X;primitive=Y;slots=Z;请按语义执行)非真实模糊 L2-L5 中文,如实标 cloud_multi_source_generator_not_run ③ 三 V-PASS(模型质量/端侧)正确 BLOCKED ④ data gate 0 泄漏 0 overlap(但本 run 无 heldout/must_pass/c6_base bucket 混入,「0 overlap」是 trivially true,保护代码真实但本 run 未被实际行使)⑤ fuse parity/lineage/judge 正确 blocked。这是诚实的「骨架就绪 + 真活未做」,非「smoke 跑通=完成」。

27/33 tasks 勾选核验:6 个未勾(3.1/6.1/6.2/6.4/6.5/7.4)全是真 blocked 项,无 blocked 混入已勾。已勾任务大体属实(schema/fixture 层),但 3.2(assistant-mask)勾在 schema 层、实际训练 run 是 smoke_only(train_on_turn=false),masking_complete_v1 仅在 dry-run prepare 行使过、从无真训练。13/13 swift test pass(实跑 Observed)、openspec validate --all --strict 8 passed(实跑 Observed)。「我没 commit」= 半真:727a2af 确是 codex commit(scaffolding 第一刀),第二刀(+595 行/repo loop/4 report dir)才是未提交的,措辞误导但非谎。

### findings
- **[P0-1] P0** (Observed) 声称如实性 / committed closeout 假绿措辞
  - problem: committed 工件把经典 2e-4 发散描述成「T-PASS / stabilized near 4.7」。这是 committed 层的 fake-green 措辞——下游/新 session 读 committed closeout 会误以为 r9 训练健康通过,而真实是发散。codex 第二刀(未提交)真修了(1609 降到 0.596),但 committed closeout 滞后且失真。
  - why: 审计枢纽核心:验证『如实收口』是否真如实。最易导致后续误判『训练已健康』而越门。committed 是唯一可溯源的固化事实源,失真比 dirty 失真危害大。
  - fix: 用 1609(stock lr1e-4 健康 0.596)/1648 真实状态重写或作废 r10 closeout 的 r9 措辞:发散归发散(2e-4 rejected)、健康归 stock 1609。closeout 不得把 stock 跑的健康记成 repo loop 的。 [owner:codex]
- **[P0-2] P0** (Observed) fake-runtime / 声称的训练后端从未真跑(audit hub a 命中)
  - problem: 声称的训练后端(repo-loop-with-clip)从未被任何完整跑/带 clip 跑验证过;健康/T-PASS 证据全来自另一个二进制(stock CLI,无 clip)。clip/finite-check 安全逻辑(本 change 核心新增价值)零 runtime 证据。属 fake-runtime:声称='已实装 repo loop clip 训练',实测='clip 路径从未真跑'。
  - why: C5 安全护栏(梯度裁剪/非有限停训/5e-5 fallback)是这次实装的 raison d'être。若它从未真跑,等于 demo 北极星的『不崩』护栏未经验证。candidate 门前若不补,会拿『health 是 stock 跑的』冒充『repo loop 已验证』。
  - fix: repo-loop clip enabled 真跑一次完整 600 步 + 同 seed clip-disabled parity 跑满(非 iter10)对齐 stock;parity pass 后 receipt 才可声称 training_loop=repo_loop 为已验证后端。codex failure#3 已诚实预告,需落地。 [owner:codex]
- **[P1-1] P1** (Observed) spec-vs-code drift / fuse parity quantized 臂漏 delta
  - problem: spec 说 quantized 也做 symmetric delta,code 只做 fused delta + quantized 绝对 floor。fuse 让 0.95→0.91 被 spec 的 symmetric 句捕获(fused 臂有 delta),但量化让 0.95→0.91 仍>0.9 floor 不报(quantized 臂无 delta)= CC 插话3a 的漏检在量化臂仍存活。= codex failure_receipt#1 自报。
  - why: 端侧实际部署是 4bit 量化态(dtype=bf16_lora_on_4bit_base);量化降级正是端侧最可能的『看着达标实则退化』隐患。spec 承诺了 code 没兑现 = 契约漂移,审计枢纽『声称 vs 实际偏差』。
  - fix: C5FuseParityInput 补 quantizedToolCallExact/quantizedIrrelAcc-vs-dynamic delta 字段 + 失败分支 + fail-closed 测试;或改 spec 措辞为 quantized 只做绝对 floor(降承诺,不推荐——端侧量化退化正需 delta)。 [owner:codex]
- **[P1-2] P1** (Observed) B1 offset fixture 绕过 / 真 mlx 字节 parity 未机器强制
  - problem: B1 修复在数据层真实(train.jsonl 带 \n\n + 0 占位符),且 1609 带 --mask-prompt 健康下降是『offset 没吃掉 tool_call 开头』的间接实证;但 dispatch 明确要求的『offset==实际 assistant 起点』+『train_render_bytes==spike actual』字节级机器验证未实装,生产路径用自断言 bool 绕过了诚实的 external_mlx_fixture_required 拦截。
  - why: offset 过冲是静默训练错误(render_diff 不报),demo 北极星『听懂中文』直接受损。1609 健康是好信号但非精确证明;自断言 bool 把诚实的『我没验真 mlx』红旗压成了 pass。
  - fix: 加一个真过 mlx_lm ChatDataset(mask_prompt=True)算 offset、断言 offset 落在 assistant content 起点的 fixture(可在 c5_mlx_train_loop.py --inspect-batches 路径扩展 offset 校验);先把 dev/spike-e3 enable_thinking=false 实际渲染字节固化成可引用 artifact 再断言相等。 [owner:codex]
- **[P1-3] P1** (Observed) 声称如实性 / '我没 commit' 措辞误导
  - problem: 『我没 commit』只对第二刀成立,对整体不成立——codex 确实 commit 了第一刀(727a2af)。措辞让人误以为全程零 commit。叠加 P0-1:727a2af 里固化的 r10 closeout 正是那份失真的『T-PASS stabilized』。
  - why: 审计枢纽明列『commit scaffolding(727a2af)却回写没 commit』偏差。准确归因 introduced(第一刀已 commit 含失真 closeout)vs第二刀未提交(真修),对放行决策很关键:失真已进 git 历史,不只是 dirty。
  - fix: closeout 措辞改为『第一刀 727a2af 已 commit(含 scaffolding + 当时的 r10 closeout);第二刀(repo loop/lr 修复/4 report)未 commit』,并按 P0-1 修正 727a2af 里固化的失真措辞(可新 commit 覆盖,不改史)。 [owner:codex]
- **[P1-4] P1** (Observed) 数据 gate 保护未被实际行使 / trivially-true 0 overlap
  - problem: leakage/overlap 保护代码本身正确(已读 C5DataGate:243-258),但本 run 数据里根本没有 protected bucket 混入,『0 overlap / 0 must_not_train』是 trivially true,不构成『保护已行使』的证据。真考验在 Q13 多源生成 + 真 C6 cases 混入时,尚未做。
  - why: 审计枢纽『数据污染』维度 + 北极星『不丢脸需 held-out 防作弊』。现在的『data_gate_ready』容易被读成『泄漏防护已验证』,实则只验证了空集。
  - fix: candidate 门前用一份故意混入 heldout/must_pass/c6_base parent 的 fixture 跑 data gate,断言 train-side overlap 被真拦截(C5DataGateTests 可加一条对抗 fixture);非空集才算保护行使。 [owner:codex]
- **[P2-1] P2** (Observed) 训练后端版本无 lock pin
  - problem: 运行时 guard 能拦版本漂移,但复现/新环境无声明式 pin,依赖『恰好装对版本』。
  - why: 复现性 + SA 资产价值(本项目是 codex+CC+磊哥学习场)。无 pin = 别人复跑可能撞 guard 报错却不知装哪版。
  - fix: 加 Tools/C5TrainingCLI/requirements.txt 或 lock 固定 mlx==0.31.x / mlx-lm==0.31.1 / transformers,与 guard 双保险。 [owner:codex]
- **[P2-2] P2** (Observed) task 勾选轻微不一致(3.1 未勾 smoke 已跑)
  - problem: 3.1 实跑了却没勾(偏保守,非夸大);3.2 勾选属 schema/dry-run 层真实但训练 run 未行使 masking_complete_v1。两处方向都不夸大(诚实偏保守),记为 P2。
  - why: 审计枢纽『27 tasks 勾选真完成 vs blocked 混入』:核实结论是无夸大式假勾,反而 3.1 偏保守漏勾。属如实性的正面证据,但一致性可补。
  - fix: 3.1 可勾(smoke_only 已实装实跑);3.2 receipt 注明『masking 完整态仅 dry-run prepare 行使,真训练待 trainable_v0 跑』,与 task 措辞对齐。 [owner:codex]
- **[P2-3] P2** (Observed) 训练数据为协议串非真实模糊中文(北极星语义广听懂)
  - problem: smoke chain 数据是确定性协议串,只验链路/格式/masking,不练 LoRA 真正该学的『模糊说→ToolCall』泛化。已如实标 blocked,非假绿,但要防后续误把 smoke 健康当成『LoRA 已学会泛化』。
  - why: 北极星=客户随意说全集→语义广听懂(LoRA)。协议串训练对此零贡献。属正确的『真活未做且标了』,记 P2 防误读。
  - fix: Q13 多源生成阶段必须产真实模糊中文 utterance(label 仍 deterministic_contract_toolcall);candidate 门前 C6 三轴诊断(in_dist/heldout/ood)用真 utterance 而非协议串。 [owner:codex]

### extra
## tasks 真实性核对(27/33 勾选)
| task | 状态 | 核验 | strength |
|---|---|---|---|
| 6 未勾(3.1/6.1/6.2/6.4/6.5/7.4) | [ ] | 全真 blocked(smoke 实现/C6 diff/fingerprint/OOD/parity/V-PASS 前置),无 blocked 混入已勾 | Observed |
| 13/13 swift test | pass | 实跑 Observed | Observed |
| openspec validate --all --strict | 8 passed | 实跑 Observed | Observed |
| 3.2 assistant-mask [x] | schema 真/run 假 | masking_complete_v1 仅 dry-run prepare 行使;训练 run=smoke_only train_on_turn=false | Observed |
| 3.1 smoke_only [ ] 但 smoke 已跑 | 轻微不一致 | smoke 实跑了却没勾(诚实偏保守,非夸大) | Observed |

## Truth Source 表(声称 vs 实测)
| 声称 | 实测 | 裁 |
|---|---|---|
| closeout: r9 T-PASS「stabilized near 4.7」 | r9 日志 loss→32@80, val6.381@200 发散 | 失真(P0-1) |
| training_loop=repo_loop + clip implemented | 健康 600 步=stock CLI(无 clip);repo loop 仅 20iter clip_disabled | 错位(P0-2) |
| 600 步无发散 health pass | 真(但属 1609 stock 跑,非 repo loop) | 真但归属错 |
| 我没 commit | 727a2af 是 codex commit(第一刀);第二刀未提交 | 半真/误导 |
| data gate 0 泄漏 0 overlap | 真但本 run 无 protected bucket,trivially true | 真但未行使 |
| B1 \n\n 前缀修复 | train.jsonl assistant content 真带 \n\n + 0 占位符 | 真(Observed) |
| B2 dev_selection 第六 bucket | spec.md:4 改 6 bucket + C5DataGate:243/255 + scenario:18 | 真(Observed) |

## codex failure_receipt 落地对照(5 条自报)
| # | 自报 | 核验 | 准确度 |
|---|---|---|---|
| 1 | quantized IrrelAcc delta 未完整(只 dynamic-vs-fused) | code line 1016-1041:仅 fused delta + quantized 绝对 floor,无 dynamic-vs-quantized delta | 准确 Observed |
| 2 | endpoint parity 只 fail-closed 非完整 evidence;think_block_parity 两边缺时显 true 不严谨 | line 1101-1119 确认 | 准确 Observed |
| 3 | repo-loop 需 parity 证明,iter10 不足替代硬 gate | 命中 P0-2 核心 | 准确(诚实自暴) |
| 4 | status=smoke_only_ready 可能被误读,须结合 acceptance_stage+child gates | receipt 确有 acceptance_stage=train_health + 各 child gate blocked/fail | 准确 |
| 5 | mlx-lm==0.31.1 有 runtime guard 但无 repo requirements/lock pin;未跑 make verify/C6 diff/真机 | guard 真(line 113);lock 缺真;make verify 未跑(本审计也未跑,Runtime-unverified) | 准确 |

## CC 三次插话元审(有效信号 vs 噪声)
| 插话 | 采纳 | 对否 | 元审 |
|---|---|---|---|
| 1 LR 2e-4→1e-4/adam→adamw/4坑 | 采纳 | 对(1609 实证甜区) | 有效信号 |
| 2 Q2 架构B 最小自有 loop 复用 stock internal + pin 0.31.1 | 采纳 | 对(repo loop 正是此形态,guard 已加) | 有效信号 |
| 3a fuse_parity IrrelAcc 缺 dynamic-vs-fused delta(0.95→0.91 漏检) | 部分采纳 | 对但未尽:code 加了 fused delta(line 1016-1028)+ spec 写「symmetric」,但 quantized 臂仍只绝对 floor 漏 delta(= codex failure#1)| 有效但落地不全 |
| 3b 端侧 enable_thinking 对齐 | 采纳 | 对(tokenizer patch main.swift:303-308 + endpoint parity gate) | 有效信号 |
| (磊哥纠 CC「缺 environment 段」基于旧 receipt) | — | CC 旧结论错(1609 已有 environment 段) | 噪声/已纠 |

## 放行门(candidate/V-PASS 前必关)
1. [P0] 改正/作废 committed r10 closeout 的「r9 T-PASS stabilized」失真措辞,以 1609/1648 真实状态重写(发散归发散,健康归 stock 1609)。
2. [P0] repo-loop-with-clip 必须真跑一次完整 600 步(clip enabled)+ 同 seed clip-disabled parity 跑满(非 iter10),证明「声称后端=实跑后端」;否则 receipt 不得声称 training_loop=repo_loop 为已验证训练后端。
3. [P1] fuse_parity quantized 臂补 dynamic-vs-quantized IrrelAcc delta 字段+测试(消 codex failure#1 + CC 插话3a 残口)。
4. [P1] offset fixture 用 usesTrainingTokenizerPatch:true 硬编码(main.swift:53)绕过 external_mlx_fixture_required,须补真 mlx apply_chat_template 字节 offset parity(dispatch B1 fixture②:train_render_bytes==c3_spike actual,当前未机器强制)。
5. [P1] mlx-lm 0.31.1 加 repo 级 requirements/lock pin(codex failure#5)。
6. [P2] data gate 在含真 heldout/must_pass/c6_base bucket 的数据上行使 overlap 检查(当前 0 overlap 是 trivially true)。
7. [未跑] make verify / 完整 swift test / C6 base-vs-LoRA diff / 真机端侧 smoke — Runtime-unverified,候选门前补。

### 对抗验证
- [P0-1] refuted → P2: The finding alleges the committed r10 closeout is P0 fake-green: it claims the closeout describes "经典 2e-4 发散" as "T-PASS / stabilized near 4.7" when "真实是发散" (reality is divergence). Independent re-read of the committed artifacts refutes th
- [P0-2] severity-adjusted → P1: FACTUAL CORE = CONFIRMED. The repo-loop-WITH-clip backend (this change's raison d'être: grad clipping + non-finite stop + 5e-5 fallback) has ZERO execution evidence. Independently verified all three states (committed HEAD 727a2af / dirty tr
- [P1-1] confirmed → P1: 原 finding confirmed,severity P1 准确(不升 P0)。

【drift 真实存在 — confirmed】git diff 铁证 codex 在同一脏改里新增 spec.md:151,该 scenario 明文要求量化臂也做对称 IrrelAcc delta("even when fused/quantized IrrelAcc remains above the absolute C6 threshold"),但 C5LoRATraining.
- [P1-2] confirmed → P1: CONFIRMED,severity 维持 P1(claim 原判正确)。审计枢纽(声称 vs 实际偏差)在此命中:生产路径用一个硬编码 bool 把诚实的 `external_mlx_fixture_required` 红旗压成 "pass",这正是 fake-green 模式——闸报"通过"它从未机器验证过的东西(真 mlx offset 正确性)。dispatch 明确把 B1 标为「必须显式非自主」「否则静默训练错误」,而 as-shipped 的闸只做字符串自断言,
- [P1-3] confirmed → P1: 独立重核 git 三态(committed HEAD / 未提交工作树 / 各轮 receipt),P1-3 的核心断言成立,severity 维持 P1。

【确认项 — Observed,亲读 git 历史】
1. 727a2af 确为 committed(`git show 727a2af`),subject="Implement C5 LoRA training apply scaffolding"(匹配 codex apply 命名;author/committer
- [P1-4] confirmed → P1: CONCLUSION CONFIRMED, MECHANISM CORRECTED (worse than stated). The finding's verdict — the receipt's `train_parent_semantic_overlap: 0` / `must_not_train_violations: 0` are trivially-true and do NOT prove the C6-gold leakage guard was exerc

## openspec/tasks 真实性核对

**verdict**: CHANGES-REQUESTED(无 P0 fake-completion;codex 勾选诚实度成立。但 4 项 P1 需修:closeout 与最新收据 drift(masking_complete_v1 vs smoke_only)、T-PASS 由 stock-CLI 而非声明的 repo loop 背书、task 3.2 offset fixture 过度声称、task 3.1 完成了却未勾。发布门:NOT-READY-FOR-CANDIDATE(本就 blocked,符合诚实预期);可作为 train_health 阶段闭包,但 closeout 必须重生成对齐最新 smoke-only 收据后才能签 T-PASS)

**summary**: 审 define-lora-training 的 tasks.md / spec.md / design.md 真实性。结论:codex 的"如实收口"在【勾选/未勾选的诚实度】上基本成立——6 个真正 blocked 的 C6/parity/V-PASS 类 task(6.1/6.2/6.4/6.5/7.4 + spec 内 6.5)全部诚实留 [ ],没有把 blocked 当 done 混进 [x],无典型 P0 fake-completion。但有三处真实性偏差:(1)【声称 vs 实际】canonical closeout(r10,14:33)写 train_on_turn=true / masking_complete_v1 / 4556 train-eligible,而 codex 自己实际作 T-PASS 依据的 4 个 latest 收据(1443/1455/1609/1648)全是 smoke_only / train_on_turn=false / train_eligible=0——closeout 未在最新 smoke-only 跑后重生成,描述了一个被后续配置回退掉的状态(P1 doc-drift)。(2)【T-PASS 偷换的 task 投影】task 5.3[x]+design.md 把 repo-owned loop(带 clip)声明为 canonical 训练 loop,但唯一的 600-step 健康曲线(Iter600 Val0.605)是 STOCK CLI(无 clip,1609,gradient_clip_status=blocked_stock...)跑的;repo loop(1648,有 clip)只跑到 iter10(loss5.391)。没有任何 task 覆盖"repo-loop 600-step 健康/parity 已证",codex failure_receipt #3 已诚实标 parity 不足——但 task 层把"repo loop 是训练 loop"勾成既成事实,与"它从未跑满一次健康曲线"有张力(P1)。(3)task 3.1(smoke_only 600-iter,标 [ ])实际已完成 4 次 smoke-only 跑(逆向错:做完了却没勾,保守非假绿,但 tasks 状态不准,P2)。task 3.2[x]"fixture 证明 user/system token 被排除"过度声称:offset fixture 实为 external_mlx_fixture_required(延迟,未对真 tokenizer 验证)(P1)。task accounting 漂移:openspec list=27/33(committed),工作树=28/34(新增 6.7[x] 未提交),codex 回写 27/33 对齐 commit 不对齐工作树(P2)。spec/design 改动(endpoint_tokenizer_parity 新 Requirement + 5.3 LR 1e-4 + IrrelAcc 对称 parity)delta 合规、openspec validate --all --strict 8 passed、swift test C5 13/13 实跑通过——没有把 not-done 写成已实现行为的 spec(spec 写的都是 SHALL 契约,gate 在收据里诚实 fail)。北极星检验:C5 朝"端侧中文 FC 大脑"生长(契约/masking/gate 骨架真实落地+诚实 blocked),未滑回假绿;但"train-health T-PASS"被 stock-CLI 健康曲线背书而非声明的 repo loop,是最该 surface 给磊哥的偏差。

### findings
- **[TASK-01] P1** (Observed) closeout vs 最新收据 doc-drift
  - problem: canonical closeout 描述的是被后续配置回退掉的 r9/r10 状态(masking_complete_v1),未在最新 smoke-only 跑后重生成,与 codex 实际作 T-PASS 依据的收据矛盾
  - why: closeout 是发布门读的权威产物;它声称 train_on_turn=true(已实现 masking)而运行态是 false(smoke-only),会让读者误判 masking 已在跑——这正是 grill 3HIGH 之一(防死记)的核心字段
  - fix: 用最新 1609/1648 收据重生成 c5-closeout.md/json,把 masking 段改为 smoke_only/train_on_turn=false/train_eligible=0,并显式标注 masking_complete_v1 仅代码实现未运行 [owner:codex]
- **[TASK-02] P1** (Observed) T-PASS 背书源偷换(task 5.3 / design.md vs 实跑)
  - problem: codex 报 'train-health T-PASS,600-step 完成' 的健康曲线由无 clip 的 stock CLI 背书,而 task/design 声明的 canonical 训练 loop(repo loop with clip)从未跑满一次健康曲线
  - why: 审计枢纽核心张力:T-PASS 的 runtime truth 是 stock CLI 的不是带 clip 的 repo loop 的。repo loop 把 optimizer.update 移出 compiled step(c5_mlx_train_loop.py:310)语义已偏离 stock,只有 iter10 parity,健康性未在目标 loop 验证
  - fix: T-PASS 措辞补注 '健康曲线来自 stock mlx-lm CLI(无 clip),repo-loop(canonical,带 clip)仅 iter10 parity,600-step 健康待补';或对 repo loop 补一次 600-step 健康跑再签 T-PASS [owner:codex]
- **[TASK-03] P1** (Observed) task 3.2 over-claim(offset fixture 延迟)
  - problem: offset fixture 并未对真 MLX tokenizer 验证 assistant-token 级排除,而是断言一个延迟态;task 3.2 的 Verification 声称超出 fixture 实际证明范围
  - why: assistant-turn loss masking 的 token 级正确性(防死记/防训到 user span)是 LoRA 质量根基;fixture 是 external_required 意味着这条最关键的 masking 正确性尚未真验,task 却记为已证
  - fix: task 3.2 Verification 降级为 'offset fixture 记录 assistant \n\n prefix(2 bytes)+ 标 external_mlx_fixture_required,token 级排除待真 MLX apply_chat_template fixture 嵌入';不改 [x] 但措辞对齐实证 [owner:codex]
- **[TASK-04] P2** (Observed) task 3.1 完成却未勾(逆向不准)
  - problem: smoke_only 600-iter chain test 实际已完成多次,task 却留 [ ];与 codex 'T-PASS 600-step 完成' 自报自相矛盾
  - why: task 状态不准会让发布门误判 smoke 链路未跑;这是保守漏勾(非假绿),但 tasks.md 作为执行计划事实源应准确
  - fix: task 3.1 勾 [x],Verification 引 1609 smoke receipt(loss trend/peak12.939GB/tokens-sec,train_eligible=false 不标 formal readiness) [owner:codex]
- **[TASK-05] P2** (Observed) task accounting / commit 措辞漂移
  - problem: 三处计数不一致:committed 27/33 vs 工作树 28/34 vs 回写 27/33;'没 commit' 仅对 13 个 dirty 文件成立,scaffolding 已 commit(727a2af)
  - why: task 计数 + commit 状态是 Phase1 侦察的对账锚点;codex 回写的 27/33 对齐 commit 但不对齐工作树最新状态,易让审计/磊哥误判进度边界
  - fix: closeout/handoff 标 '27/33 committed(727a2af),工作树 +6.7=28/34 未提交;scaffolding 已 commit,后续 13 dirty 文件未 stage' [owner:codex]
- **[TASK-06] P3** (Observed) spec/design delta 合规(正向确认)
  - problem: 无问题——spec delta 全为 SHALL 契约(ADDED/MODIFIED 合规),未把 not-done 写成已实现行为;gate 在收据里诚实 fail(fuse_parity=fail / diagnostic=blocked_missing),validate 通过
  - why: 确认 codex 没有用 spec 洗白 blocked 工作:spec 描述目标契约,运行态收据诚实标 blocked,二者分离正确,符合 OpenSpec '只写可观察行为' + grill 'low val loss 不产 V-PASS'
  - fix: 无需修;作为 train_health 阶段 spec 基线保留。后续 candidate 阶段补 6.1/6.2/6.4/6.5/7.4 时回核这些 Requirement 是否被实跑满足 [owner:none]

### extra
## tasks 真实性核对表(task / 勾选 / 实际状态 / 证据)

| task | 勾选 | 实际状态 | 证据 | 判定 |
|---|---|---|---|---|
| 1.1 上游 gate 起点 | [x] | 真完成 | tasks.md:3;closeout source_refs 引 define-lora-training 为 active C5 源 | ✓ |
| 1.2 读 data-gate requirements | [x] | 真完成 | closeout.md:22 引 data-gate spec.md:4/:72-88 | ✓ |
| 1.3 receipt 证 0 protected leakage | [x] | 真完成 | receipt Gates: data_gate_status=data_gate_ready;closeout.md:81 must_not_train_violations=0/overlap=0/quarantine=0 | ✓ |
| 1.4 offline only | [x] | 真完成 | receipt 无网络依赖;CLAUDE.md 红线 | ✓ |
| 2.1 sample metadata 字段 | [x] | 真完成 | testBuilderProducesRequiredMetadata 通过;receipt route_tier_counts | ✓ |
| 2.2 route_tier 派生(free 优先) | [x] | 真完成 | testRouteTierDerivesFromNormalizedFCFlagsWithFreeTakingPrecedence 通过 | ✓ |
| 2.3 exec_tier 分离 | [x] | 真完成 | testBuilderKeepsExecutionTierSeparate 通过 | ✓ |
| 2.4 rule-l1 rehearsal 5-10% | [x] | 真完成 | receipt rehearsal_ratio=0.0749(在 5-10%);代码 hardFailure 校验 0.05-0.10 | ✓ |
| **3.1 smoke_only 600-iter** | **[ ]** | **实际已完成(逆向错)** | 1443/1455/1609/1648 四次 smoke-only 跑;1609 Iter600 Val0.605 完成。标 [ ] 与实跑矛盾 | ⚠️ 漏勾(保守非假绿) |
| 3.2 assistant-turn loss masking | [x] | **过度声称** | testAssistantDoubleNewlineOffsetFixture 断言 status==external_mlx_fixture_required + failure_receipt 含 mlx_apply_chat_template_offset_fixture_not_embedded(=未对真 tokenizer 验证);task 称"fixture 证明 token 被排除"超出实证 | ⚠️ over-claim |
| 3.3 name 增广 distractor_only | [x] | 真完成 | receipt masking_coverage function_name=true/argument_name=true;代码 distractor 路径 | ✓ |
| 3.4 argument_value 三策略 | [x] | 真完成 | testSlotPlaceholdersAreRendered 通过;value_strategy 枚举 | ✓ |
| 3.5 promote masking_complete_v1 | [x] | 代码完成但**最新收据未达此态** | 代码 maskingCompleteV1 枚举+testReceiptSummarizesMaskingCompleteStage 通过;但 4 个 latest 收据 = smoke_only/train_on_turn=false。[x] 指代码实现成立,但与 closeout 声称的"运行态 masking_complete_v1"drift | ✓(代码)/ ⚠️(closeout drift) |
| 4.1 refusal 配对 train-split | [x] | 真完成 | testNoCallCounterfactualsArePairedAndCapped 通过 | ✓ |
| 4.2 no-call 字段 | [x] | 真完成 | 同上测试覆盖字段 | ✓ |
| 4.3 refusal_ratio 0.10/cap0.20 | [x] | 真完成 | receipt refusal_ratio_observed=0.1001/target=0.1/cap=0.2;代码 hardFailure cap 校验 | ✓ |
| 4.4 prompt distractor 分离 | [x] | 真完成 | receipt prompt_distractor_count=9912 与 no-call 分开计 | ✓ |
| 5.1 MLX scale 非 alpha | [x] | 真完成 | testMLXConfigUsesScaleAndExcludesEmbeddings 断言 renderYAML 无 alpha | ✓ |
| 5.2 显式 projection keys | [x] | 真完成 | receipt keys 列 7 projection;test 断言 excludesEmbeddingTargets | ✓ |
| 5.3 Qwen3-1.7B/lr1e-4/AdamW/repo loop | [x] | 真完成(配置)但 repo loop 无 600-step 实跑 | receipt config 全部记录;但 training_loop=repo_loop 而 600-step 健康曲线来自 STOCK CLI(1609 gradient_clip_status=blocked_stock_mlx_lm) | ✓(配置)/ ⚠️(loop 实跑) |
| 5.4 rank32/DoRA 次选 | [x] | 真完成 | design.md:133-135 区分 mainline/optional | ✓ |
| 6.1 C6 base baseline | [ ] | 真 blocked(诚实) | closeout.md:106 c6_base_vs_lora_diff_not_run | ✓ 诚实留空 |
| 6.2 replay fingerprints | [ ] | 真 blocked(诚实) | closeout.md:107 replay_fingerprints_not_complete | ✓ 诚实留空 |
| 6.3 generalization_diagnostic | [x] | 真完成(代码 fail-closed) | testGeneralizationDiagnosticAndFuseParityFailClosed 通过;receipt diagnostic_verdict=blocked_missing(=正确 fail-closed) | ✓ |
| 6.4 OOD probes | [ ] | 真 blocked(诚实) | 无 OOD 构造证据;留空 | ✓ 诚实留空 |
| 6.5 dynamic/fused/quantized 对比 | [ ] | 真 blocked(诚实) | receipt fuse_parity_gate=fail(IrrelAcc_delta_missing);closeout.md:108 three_way_parity_not_run | ✓ 诚实留空 |
| 6.6 acceptance_stage 门控 | [x] | 真完成 | receipt acceptance_stage=train_health;testSmokeOnlyStage 通过;low val loss 不产 V-PASS | ✓ |
| 6.7 endpoint tokenizer parity 字段(工作树新增) | [x] | 代码完成 | testEndpointTokenizerParityRequiresByteExact 通过;spec.md 新 Scenario;但仅 fail-closed 字段非完整 evidence gate(codex failure_receipt #2 诚实标) | ✓(字段)/ ⚠️(非完整 gate,已自报) |
| 7.1 focused tests fail-closed | [x] | 真完成(实跑) | swift test --filter C5LoRATrainingTests = 13/13 passed(Observed,本审实跑) | ✓ |
| 7.2 openspec validate | [x] | 真完成(实跑) | openspec validate --all --strict = 8 passed 0 failed(Observed,本审实跑) | ✓ |
| 7.3 data-gate validator | [x] | 真完成 | receipt validator_layer1=pass(layer2 诚实 blocked_missing) | ✓ |
| 7.4 C6 diff/fuse/endpoint parity | [ ] | 真 blocked(诚实) | closeout.md:118 残留;留空 | ✓ 诚实留空 |
| 7.5 closeout report | [x] | 完成但**已 stale** | closeout.md 存在且区分 T/V-PASS;但 generated_at 14:22 早于 1609(16:08)/1648(16:48),内容与最新收据 drift | ⚠️ stale |

## Truth Source 表(声称 vs 实际偏差)

| 声称(codex closeout/回写) | 实际(本审实读) | 偏差等级 |
|---|---|---|
| "27/33 tasks" | committed=27/33;工作树=28/34(6.7[x] 未提交) | P2 accounting drift |
| "train-health T-PASS,600-step 完成 Iter600 Val0.605/Peak12.939GB" | 真完成,但来自 STOCK CLI(1609,无 clip),非声明的 repo loop | P1 背书源偷换 |
| closeout "masking_complete_v1 / train_on_turn=true / 4556 train-eligible" | 4 个 latest 收据全 smoke_only/false/0;closeout 未重生成 | P1 doc-drift |
| "没 commit 未提交改动" | HEAD=727a2af 是 codex 的 commit('C5 scaffolding');另有 13 dirty 文件未提交。"没 commit" 仅对 dirty 部分成立,scaffolding 已 commit | P2 措辞偏差(codex 已自标需核) |
| repo loop "把 optimizer.update 移出 compiled step" | 确认:c5_mlx_train_loop.py:185-208 compiled step 内算 grad+clip,:310 optimizer.update 在 compiled step 外。语义偏离 stock,parity 仅 iter10 证据 | (runtime 维,本维 noted)codex failure_receipt #3 诚实标 |

## 放行门(本维度)
- ✅ 无 P0 fake-completion:6 个 blocked task 全诚实留 [ ],blocked gate(fuse_parity=fail/diagnostic=blocked_missing)如实写进收据,未把 not-done 写成已实现 spec。
- ⚠️ P1 必修(发布门前):① 重生成 closeout 对齐最新 smoke-only 收据(消除 masking_complete_v1 vs smoke_only drift);② T-PASS 措辞标注健康曲线来自 stock CLI 非 repo loop,或补一次 repo-loop 600-step 健康跑;③ task 3.2 措辞降级为"fixture 标记 external_mlx_fixture_required(token 排除待真 tokenizer 验证)";④ task 3.1 勾上(已完成)。
- 裁决:train_health 阶段闭包成立;lora_candidate / V-PASS 本就诚实 blocked,符合预期,不可签 candidate。

### 对抗验证
- [TASK-01] confirmed → P1: CONFIRMED at P1. Independently re-read all cited artifacts; the doc-drift is real and the chronology checks out.

CORE CLAIM VERIFIED (Observed):
- The ONLY closeout is Reports/c5-lora-training-20260621T1245-r10/c5-closeout.{md,json} (find 
- [TASK-02] confirmed → P1: CONFIRMED at P1 (not severity-adjusted up to P0). Every load-bearing claim verified against primary artifacts: (a) the only 600-step health曲线 (Val0.605/Train0.596/Peak12.939GB) came from STOCK mlx_lm.lora CLI which has NO grad clip (receipt
- [TASK-03] severity-adjusted → P0: CONFIRMED on facts + core problem, SEVERITY ADJUSTED UP P1→P0 (finding under-weighted a fake-green mechanism it never inspected).

CONFIRMED (all Observed, re-read line-by-line, did not trust finding's wording):
1. tasks.md:18 task 3.2 is [

## masking / B1 (enable_thinking) / 数据 pipeline 真实性

**verdict**: 数据/masking/B1 块：诚实标 smoke_only/dry-run，无 fake-green、无数据污染、无泄漏，占位符与 B1 真修——朝北极星方向正确但仍在「地基诚实空跑」阶段，未滑回假绿。但有 1 个 P1 北极星缺口（训练集 0 条自然中文，LoRA 该学的 L2-L5 模糊意图没数据）+ 1 个 P1 tasks 勾选漂移（真做的没勾、没做的 assistant-token mask 与未达成的 masking_complete 勾了）+ 2 个 P2 receipt 诚实度暗坑（proxy 旗使 masking-incomplete 信号永不触发；fixture 字符串级冒充 token 级）。建议门：发布门 BLOCKED（与 codex 自报一致），但 tasks.md 必须先纠勾选 + masking_coverage 守门逻辑要把 train_on_turn 纳入 incomplete 判据，否则 trainable_v0 阶段会把 proxy-true 误读成 masking ready。

**summary**: 审 C5 数据生成 + masking + B1 tokenizer patch 三块。结论分两面。【诚实面，codex 没造假绿】① 占位符 bug 真修了：1443/1455 轮 train.jsonl 有 1305 处 assistant JSON 字面 `<position>` 等尖括号占位符（直接教模型吐占位符），1609/1648 两轮已 0 处，且有回归测试 `testSlotPlaceholdersAreRenderedAsConcreteValuesInUserAndAssistant` 锁死（Observed，swift test 13/13 pass）。② B1 enable_thinking patch 实装正确（main.swift:297-314 把 chat_template 的 `enable_thinking is defined and ... false` 改成 `is not defined or ... false`，默认抑制 think 块）。③ 数据门干净：must_not_train_violations=0 / parent_overlap=0 / quarantine=0 / leakage=0，无 C6/heldout 污染。④ 数据本质=dry-run，failure_receipt 如实记 `cloud_multi_source_generator_not_run`/`multi_source_generator_diversity_missing`/`cross_vendor_semantic_judge_not_run`，closeout:41 明文「确定性协议数据不满足 Q13/Q14/Q15」，状态诚实标 `smoke_only_ready`/`PARTIAL_T_PASS_NOT_CANDIDATE`。【真问题】① 训练数据 100% 是确定性协议串 `device=X; primitive=Y; slots=Z; <固定后缀>`，4556 行里自然中文 0 行——LoRA 北极星要练的 L2-L5 模糊口语意图，训练集里一条都没有，所谓「自然中文」只是 8 个固定后缀模板字符串（如「用自然中文表达也要落到同一动作」），后缀是 ceremony 不是 paraphrase。② masking 机制偷换：grill Q4 决策 `train_on_turn=return_assistant_tokens_mask`（assistant-token mask），实装零处 `return_assistant_tokens_mask`，实际走 stock mlx-lm `--mask-prompt`（单 offset prompt mask，单轮等价但非 grill 决策的机制）；`C5MaskOffsetFixture` 是字符串级比对（trained span==渲染 tool_call），非 token 级证明，但 task 3.2 文案声称「fixture proves user/system/prompt tokens excluded」=token 级。③ masking_coverage proxy 旗虚真：`function_name`/`argument_name` 由 `!distractors.ids.isEmpty` 派生（每样本必带 2 distractor → 永真），smoke_only 也显 3/4 true。④ 因 proxy 全真，masking-not-implemented 守门条件（line 1526 只查 3 旗、漏 train_on_turn）永不触发 → smoke_only receipt 的 failure_receipt 不含 `masking_complete_augmentation_not_implemented`，掩盖 train_on_turn=false 的实情，下游读到「masking 3/4 ready」=高估。⑤ tasks.md 勾选漂移：真做了的 3.1（smoke_only 链测）反而 unchecked；3.2（assistant-token mask，没实装该机制）checked；3.5（promote masking_complete_v1，从未达到，receipt 仍 smoke_only）checked。⑥ `testReceiptSummarizesMaskingCompleteStage` 是空转测试：stage 由 caller 传参，builder 机械打标，测「你说 complete 就 complete」非「earned」。

### findings
- **[MD-P1-01] P1** (Observed) 数据 pipeline / 北极星对齐
  - problem: 训练集没有任何自然/口语模糊中文。LoRA 的北极星职责正是练 L2-L5 模糊意图（CLAUDE.md 架构铁律：L1 走规则，只有模糊/跨域走 Qwen+LoRA）。当前数据全是机器协议串，模型即便训完也只学会『把 device= 协议串映射成 tool_call』，学不到『客户随口一句模糊中文→落同一动作』。
  - why: 这是 C5 是否朝『端侧可演示中文 FC 大脑』生长的核心。数据决定能力上限——确定性协议串训出的 LoRA 在客户现场听到真人模糊说法会失效，正是北极星最怕的『听不懂中文』。codex 已诚实标 dry-run/smoke_only 并 fail-closed，故非 fake-green（降为 P1 而非 P0），但缺口的严重性需对磊哥显式 surface。
  - fix: trainable_v0 阶段必须执行 Q13 多源云 generator（claude 主力 + hermes gpt-5.5 异源）产口语变体 + Q14 跨厂商 semantic judge，确定性协议串只作 label/格式 fixture，不作 user utterance 训练源。在跑真训练前不得把 smoke_only 数据当 trainable。 [owner:codex]
- **[MD-P1-02] P1** (Observed) tasks.md 勾选真实性
  - problem: 勾选与实情反向漂移：真做的（3.1 smoke 链测）没勾；没按决策机制实装的（3.2 assistant-token mask）勾了；从未达成的晋升（3.5 masking_complete_v1）勾了。
  - why: §30/§22 元认知：勾选 task 实际 blocked 是 P0-级 fake-completion 信号。本例非恶意但会误导新 session『3.2/3.5 已完成』，跳过真正的 token-mask 实装与 masking 晋升，复发同类盲点。
  - fix: 3.1 补勾；3.2 改为未完成或降级文案『prompt-offset 单轮等价已实装，assistant-token mask（多轮）与 token 级 fixture deferred』；3.5 取消勾（masking_complete_v1 未达成）。每条 task 勾选前对账 receipt 实际状态。 [owner:codex]
- **[MD-P2-01] P2** (Observed) receipt 诚实度 / masking 守门逻辑
  - problem: masking_coverage 的 function_name/argument_name 是 proxy 旗（distractor 是否存在），smoke_only 也永真；导致 line 1526 的 masking-incomplete 守门永不触发，receipt 不报 masking 未实装，下游读到『masking 3/4 ready』高估真实就绪度。
  - why: receipt 是机器可审事实源（lessons B19）。proxy 旗使 train_on_turn=false（唯一真正重要的 loss-mask 旗）被三个虚真旗掩盖，恰是『假绿在 receipt 字段层』的微缩版，trainable_v0 阶段会据此误判。
  - fix: (1) line 1526 incomplete 判据纳入 `!coverage.trainOnTurn`；(2) function_name/argument_name 旗语义改为『真执行了 distractor name 增广』而非『distractor 存在』；(3) smoke_only 阶段 masking_coverage 三旗应反映 train_eligible=false 的实情。 [owner:codex]
- **[MD-P2-02] P2** (Observed) masking fixture 证明层级
  - problem: fixture 是字符串 span 比对，非 token 级 loss-mask 证明。它能证『assistant payload 前缀 \n\n + 后续等于渲染 tool_call』，但不能证 stock mlx-lm 的 token offset 真把 system/user token 的 loss 排除、只训 assistant token。task 3.2 的 token 级声称被这层字符串 fixture over-claim。
  - why: lessons:31/B22 自己定下『不能只看最终字符串像不像，要真实 offset fixture：trained span 必须等于 ToolCall』——但当前 fixture 恰好停在字符串层，且自己标 `not_embedded`。声称与实现的证明层级有 gap，trainable_v0 前需补真 token-offset fixture（用 apply_chat_template 实算 offset）。
  - fix: 在 trainable_v0 阶段补一个真跑 mlx tokenizer 的 offset fixture：dump `apply_chat_template(messages[:-1], add_generation_prompt, enable_thinking=false)` 的 token 长度，断言 == mask offset，且该 offset 之后才是 loss 区；把它固化成 CI fixture（Q7 dump）。 [owner:codex]
- **[MD-P2-03] P2** (Observed) 测试有效性
  - problem: 该测试是空转（tautology）：stage 由 caller 传参、builder 机械贴标，测的是『你说 complete 就 complete』，不验证 masking_complete_v1 是否真由 assistant-mask+distractor 增广+value 增广全到位 earned。
  - why: 测试给 task 3.5 背书但实际没守住晋升条件，属安慰剂测试（pre-mortem Elevate-or-Kill）。配合 MD-P2-01 的守门漏洞，masking_complete_v1 可被无条件声称。
  - fix: 改测试为：构造真满足三类增广的样本 → 断言 receipt 状态自然升到能标 masking_complete_v1；并加反例测试：缺任一增广时 receipt 必含 masking_complete_augmentation_not_implemented。 [owner:codex]
- **[MD-INFO-01] P3** (Observed) runtime truth 旁证（非本维度主裁，供综合官交叉）
  - problem: codex 报的 train-health 来自 stock CLI（无 clip），带 clip 的 repo loop（实际 C5 交付代码）从未端到端跑完，仅 iter10 对齐。
  - why: 这是审计枢纽问题(a)『health 是 stock CLI 还是 repo loop』的答案：确为 stock CLI。codex failure_receipt#3 已诚实披露『repo-loop parity 不足以替代硬 gate』，故非偷换隐瞒，但综合官应记入 runtime-truth 矩阵——带 clip 的产品代码路径仍 Runtime-unverified（>iter20）。
  - fix: trainable_v0 前用 repo loop（clip enabled）跑完整 600-step 并与 stock 做 20/600-step parity，再据此声称 train health；不得用 stock CLI 健康替代 repo loop 健康。 [owner:codex]

### extra
## tasks 真实性核对（define-lora-training，本维度相关）
| task | 勾选态 | 实际 | 判定 |
|---|---|---|---|
| 3.1 smoke_only + train_eligible=false（600-iter 链测） | [ ] 未勾 | 真做了（1609 跑完 Iter600；receipt smoke_only/train_eligible=0/masking_stage_counts smoke_only=4956） | ❌ 漂移：真完成却未勾 |
| 3.2 assistant-token masks，fixture 证 token 级排除 | [x] 已勾 | 零处 `return_assistant_tokens_mask`；走 stock `--mask-prompt`（prompt-offset，单轮等价）；fixture 是字符串级比对非 token 级 | ⚠️ 机制偷换 + 文案 over-claim（单轮功能可接受，但非声称的机制/证明层级） |
| 3.3 function_name/argument_name distractor_only | [x] 已勾 | 实装（distractorToolSchemas 每样本 2 个，正例 name 稳定） | ✅ 属实 |
| 3.4 argument_value 三 value_strategy 增广 | [x] 已勾 | 实装（augmentValue: slot_extract/exp_inverse_normalize/percent_extract）；但仅 value.type 非空才触发，且 smoke 数据未作 trainable 消费 | ✅ 代码属实（消费态待 trainable_v0） |
| 3.5 promote masking_complete_v1 only after 全到位 | [x] 已勾 | 从未达到 masking_complete_v1；receipt=smoke_only；`masking_complete_augmentation_not_implemented` 属 formalStep2Failures | ❌ gate 存在但晋升从未发生，勾选暗示完成 |

## Truth Source 表（声称 vs 实际，本维度）
| 声称（closeout/receipt/tasks） | 实际（亲读证据） | strength |
|---|---|---|
| 占位符 bug 已修，新 train.jsonl 无 assistant JSON `<...>` | 1648 train.jsonl grep `<position>` 等 = 0；1443/1455 = 1305 | Observed |
| B1 enable_thinking patch 实装 | main.swift:297-314 字符串替换条件正确 | Observed |
| 数据是 dry-run，cloud generator 未跑 | 4556/4556 行为 `device=...` 协议串，自然中文 0 行；failure_receipt 列 4 条 | Observed |
| masking_coverage train_on_turn=false（如实） | receipt.json 确为 false | Observed |
| masking_coverage function/argument_name=true | 派生自 `!distractors.ids.isEmpty`（永真），非真 name-masking 证据 | Observed（proxy 旗） |
| Q4 train_on_turn=return_assistant_tokens_mask | 代码零处该 API，走 `--mask-prompt` | Observed（机制偏离 grill 决策） |
| swift test 13/13 pass | 实跑 13 passed 0 failed | Observed |

## 放行门（本维度）
- 数据/masking/B1 块对 P0「fake-green/数据污染/泄漏/占位符未修」全部 CLEAR（与 codex 自报「smoke_only/dry-run」一致，未洗白）。
- 但发布门维持 BLOCKED：训练集 0 自然中文 = LoRA 北极星能力（听懂模糊中文）无训练信号，trainable_v0 必须先跑 Q13 多源云 generator + Q14 跨厂商 judge。
- 整改前置（trainable_v0 之前必做）：(1) tasks.md 纠勾选漂移（3.1 补勾 / 3.2 降级为「prompt-offset 单轮等价，token 级证明 deferred」/ 3.5 取消勾）;(2) line 1526 masking-incomplete 判据纳入 `train_on_turn`，否则 proxy-true 会让 trainable_v0 误判 masking ready;(3) masking_coverage 的 function_name/argument_name 改为「真做了 distractor 增广」而非「distractor 存在」语义，避免 smoke 阶段虚显 3/4。

### 对抗验证
- [MD-P1-01] confirmed → P1: verdict=confirmed，severity 维持 P1。三态(committed HEAD 727a2af / 8 文件脏工作树 / 4 个 untracked smoke-only Reports)已核清——被审数据在 untracked Reports 目录，源码改动在脏工作树（C5LoRATraining.swift M），未被错标。

finding 全部事实声称独立复核为真且可复现：(a) 4 轮 train.jsonl 100% 协议串/0 自然中文（亲
- [MD-P1-02] confirmed → P1: CONFIRMED at P1. All three checkbox/receipt discrepancies are real and independently reproduced from file:line evidence: 3.1 is done-but-unchecked; 3.2 and 3.5 are checked-but-contradicted by the latest 4 authoritative smoke receipts (train

## fuse/端侧 parity 实装真伪 + train-health runtime truth + fake-completion 核验（C5 LoRA training apply）

**verdict**: CONDITIONAL-PASS（train-health T-PASS 诚实成立；candidate V-PASS 正确 BLOCKED）。无 P0 假绿/假 runtime/数据污染/权重泄露。发布门：不可签 lora_candidate（符合 codex 自报）。放行进下一步（trainable_v0 实训）前须关 2 个 P1：spec.md:151 要求的 quantized-IrrelAcc-delta 落 code+test；clip 路径以 clip enabled 实跑 ≥1 次坐实熔断。北极星硬约束：trainable_v0 数据必须替换为真自然中文多源生成，结构化链路串绝不可进正式训练。

**summary**: 总裁决：codex 的 C5 收口本质诚实，不是假绿——所有 V-PASS 显式 BLOCKED、receipt status=smoke_only_ready/PARTIAL_T_PASS_NOT_CANDIDATE、fuse/endpoint gate 全 fail-closed、无权重入仓、无 make-verify 虚报。审计枢纽四问逐一证伪了"偷换/假绿"指控：(a) train-health 无偷换——600-step health 明确归 stock CLI（gradient_clip_status=blocked_stock_mlx_lm，1609 Val0.605）、repo-loop 只跑 20 iter no-clip 且 receipt 标 implemented_repo_loop，两者各自归属诚实；(b) 27/33 task 勾选基本属实，仅 task 3.1（smoke_only stage）该勾未勾=漏勾（反向，不是假完成）；(c) repo-loop 把 optimizer.update 移出 compiled step 语义正确，且 Iter10 loss 5.391 与 stock 逐位对齐=parity 真；(d) 声称 vs 实际偏差极小且都有 failure_receipt 兜底。

但有两类真问题：① 【P1 spec↔code drift】spec.md:151 明文要求 candidate 失败若 dynamic-vs-**quantized** IrrelAcc delta 超容差（即使绝对值>0.9），但代码 1016-1018 只算 dynamic-vs-fused delta，quantized 只比绝对阈值（1039）——CC插话3 的 fused 侧 gap 已修（test 验过 4pp），quantized 侧 delta 仍是缺口（codex failure_receipt #1 已诚实自报）。② 【P1 runtime-unverified】clip+nonfinite-fallback 代码路径从未以 clip enabled 跑过任何 iter（所有 run 都 clip_disabled=True 或 stock 无 clip），熔断/裁剪逻辑零运行时证据。

北极星视角最大隐忧（P1，非假绿但方向需盯）：smoke 训练数据 4556 条 user utterance 100% 是 `device=atmosphere_lamp; primitive=power_on; slots=...` 结构化机器串 + 轮换后缀，零自然模糊中文。这是 grill Q16 显式定义的 dev_time_chain_test（不是质量声明），真正的多源云 LLM 自然口语生成（Q13/14/15）codex 诚实标 not_run。链路测合法，但下游必须确保 trainable_v0 换成真自然中文语料，否则模型学不会"听懂中文"。

CC 三次插话元审：插话1（LR/clip/optimizer 三件套+占位符 bug）全部落地有效；插话2（最小自有 loop 复用 stock API + pin 0.31.1）落地为 c5_mlx_train_loop.py，REQUIRED_MLX_LM_VERSION 硬校验已实装；插话3 gap#1（IrrelAcc dynamic-vs-fused）已修+test 覆盖，gap#2（端侧 enable_thinking）落地为 patched tokenizer + endpoint_tokenizer_parity fail-closed gate。CC 旧"缺 environment 段"错判已被 1609 receipt 的 Environment 段证伪（磊哥纠对）。CC 反馈链有效信号占压倒多数。

### findings
- **[F1] P1** (Observed) fuse parity gate / spec↔code drift
  - problem: spec 明文要求 quantized IrrelAcc 对称 delta 检测（量化掉 4pp 但仍>0.9 应失败），代码只对 fused 侧实现，quantized 侧会漏检 4pp 行为回退。CC插话3 提的 fused 侧 gap 已修，quantized 侧仍缺。
  - why: 端侧实际跑的是 fused_quantized_4bit（北极星=端侧），quantized 行为回退正是端侧最易踩的坑；spec 已识别此风险却未落 code = candidate gate 对端侧最关键的一类回退失明。codex failure_receipt #1 已诚实自报，非隐瞒。
  - fix: C5FuseParityInput 加 quantizedIrrelAcc 的 dynamic-vs-quantized delta 计算（对称 abs delta>tolerancePP）；evaluate() 加 quantized_IrrelAcc_delta_exceeds 失败项；补 test 覆盖 quantized 掉 4pp 但绝对>0.9 仍 fail。 [owner:codex]
- **[F2] P1** (Observed) 梯度裁剪 runtime truth
  - problem: c5_mlx_train_loop.py 的 clip_grad_norm(1.0)+nonfinite_stop+5e-5 fallback 代码路径从未以 clip enabled 跑过任何 iteration。所有 repo-loop run 都 clip_disabled=True（为做 stock parity），600iter/clip 配置只在 command.txt 描述、未执行（hermes 跑该配置 900s timeout 被 kill）。
  - why: 插话1/2 的核心价值就是熔断+裁剪防 2e-4 发散；该逻辑零运行时证据。design.md:141 声称 'clip_grad_norm before optimizer update' 是能力描述非运行验证。这是 §30 '机械操作会成功 ≠ 实际跑过' 的活例——代码看着对，但裁剪分支、nonfinite raise、fallback 都没被触发过。
  - fix: 以 clip enabled 实跑 ≥1 次（至少到 LR 爬过 warmup 的 iter，让 grad_norm_preclip>1.0 触发 clip_grad_norm 真分支）；并构造 nonfinite 注入用例验 NonFiniteTrainingError 路径（return 70 + metrics nonfinite_stop）。在 trainable_v0 实训前坐实，否则首次正式训练即首跑未验证熔断。 [owner:codex]
- **[F3] P1** (Observed) 训练数据 north-star 对齐（smoke 阶段）
  - problem: smoke 训练数据 100% 是机器结构化串，零自然模糊中文。这恰是架构里 L1 规则快路该处理的形态，而 LoRA 存在的全部理由是学 L2-L5 自然模糊说法。在此数据上训出的模型学不会'听懂中文'。
  - why: 北极星=客户现场听懂中文。此为 grill Q16 显式定义的 dev_time_chain_test（不是质量声明）、codex frame_surfaced 诚实标 deterministic_protocol 不满足 Q13/14/15，故 smoke 阶段合法。但风险在下游：若 trainable_v0 沿用此生成器，模型方向滑回 L1 模板回声。codex failure_receipt 已标 multi_source_generator_not_run。
  - fix: trainable_v0 阶段强制切换到 Q13/14/15 多源云 LLM 自然口语生成（label_authority=deterministic_contract_toolcall 不变，只 utterance 换真自然变体）；放行门加'结构化 device= 串禁进正式训练'硬断言；新增 test 断言 trainable_v0 样本 user content 不以 'device=' 开头。 [owner:magnet 拍板 + codex 实装]
- **[F4] P2** (Observed) tasks 勾选准确性
  - problem: task 3.1 实际已完成（smoke_only stage 是整个收口的主体）却未勾选——是漏勾（反向误差），不是假完成。
  - why: 审计枢纽要求查'勾选 task 实际 blocked'（假完成）。此处相反：实际 done 却未勾，说明 codex 勾选偏保守而非虚高，进一步佐证'诚实非假绿'。但 tasks 是执行计划事实源，漏勾会让新 session 误以为 smoke 未做。
  - fix: 勾选 3.1 [x] 并标 Verification 已满足（smoke receipt 报 loss/mem/tok-s 且 train_eligible=false 未声明 formal readiness）。 [owner:codex]
- **[F5] P2** (Observed) endpoint think_block_parity 显示语义
  - problem: 两侧 render 均缺失时 think_block_parity 字段显 true（实为 missing==missing 巧合），易被人读成'think 块已对齐'。但 status 正确返回 blocked（1125-1126），不泄漏成 pass。
  - why: codex failure_receipt #2 已诚实自报此瑕疵。fail-closed 在 status 层完整（gate 不会因此误放行），故属误导性子字段=P2 cosmetic，非 P1 fake gate。
  - fix: thinkSignature 两侧 missing 时返回独立哨兵或让 thinkBlockParity 在任一侧 missing 时强制 false/nil（与 byteParity 一致：missing→false）；避免 missing==missing→true 的误读。 [owner:codex]
- **[F6] P2** (Observed) closeout 状态命名易误读 + 提交归属
  - problem: (a) status=smoke_only_ready 的 'ready' 措辞 codex failure_receipt #4 自承可能被误读为 candidate-ready；须结合 acceptance_stage=train_health+child gates blocked 读。(b) '没 commit' 表述与 HEAD 是 codex commit 存在时序错位——第一波 scaffolding 已 commit，第二波 dirty。
  - why: 非假绿（实际语义全 blocked），但 'ready' 命名 + 提交归属表述会让磊哥/新 session 误判进度。§28 派生物当事实源风险。
  - fix: status 改 smoke_only_chain_test_passed_not_candidate；closeout 明确区分'第一波已 commit(727a2af) / 第二波 repo-loop+parity 仍 dirty 待 commit'。 [owner:codex]
- **[F7] P3** (Observed) grad_norm 显示默认值
  - problem: train_report 行在非 update iteration 把 grad norm 显示为 0.000000（实为 None），可能被误读成梯度消失。
  - why: 纯显示层，实际数据在 metrics.jsonl optimizer_update 事件正确捕获；不影响任何 gate 或 receipt 字段。
  - fix: 显示 'n/a' 或仅在 do_update 行打印 grad norm。 [owner:codex]
- **[F8] P3** (Observed) CC 反馈链元审（信号质量）
  - problem: CC 三次 boundary-guard 插话有效信号占压倒多数（LR/clip/optimizer/占位符/IrrelAcc/enable_thinking 全部落地），唯一噪声是基于 1455 旧 receipt 的'缺 environment 段'错判（已被磊哥纠正、1609 证伪）。
  - why: 元审要求区分 CC 反馈有效信号 vs 噪声。结论：CC 反馈链高有效性，错判源于读了旧 receipt 未核最新（§28 一手源时效性），单点非系统性。
  - fix: CC 引 receipt 字段前核对最新轮次（1609/1648 而非 1455）；其余插话维持。 [owner:CC]

### extra
## tasks 真实性核对（27/33）
| task | 勾选 | 实际 | 判定 |
|---|---|---|---|
| 3.1 smoke_only stage | [ ] 未勾 | 实际已实现+已跑（这就是被审的 smoke 主体） | 漏勾（反向误差，非假完成）P2 |
| 3.2 assistant-mask | [x] | fixture 验过(testEndpoint... + offset)；smoke 阶段 train_on_turn=false 是设计（smoke 不应用 mask）正确 | 属实 |
| 3.5 masking_complete_v1 | [x] | code 1494-1527 coverage 逻辑+formal_step2 failure 兜底；smoke receipt train_on_turn=false 如实 | 属实 |
| 6.6/6.7 candidate gate | [x] | acceptanceStage 永不到 loraCandidate（1539 只 smoke→trainHealth/else→trainableV0）；spec 要求的 lora_candidate 升级路径=未实装但 fail-closed | 属实（gate 存在但 candidate 升级路径未接，符合"无 V-PASS"） |
| 6.1/6.2/6.4/6.5/7.4 | [ ] 未勾 | C6 diff/fingerprint/OOD/三方 parity 全 not_run | 诚实未勾 |
| 7.2 openspec strict | [x] | 实跑 8 passed,0 failed（亲验） | Observed 属实 |

## Truth Source 表（冲突按权威序裁）
- 600-step "health" 真源 = stock CLI（1609 mlx-train-command.txt=mlx_lm.lora；gradient_clip_status=blocked_stock_mlx_lm）。Val0.605 属 1609（uncommitted）；committed r9 是 constant-2e-4 不稳定 run（val 4.473→4.68 反升，loss_trend=early_spike_then_stabilized，failure_receipt 标 lr_schedule_not_effective）。codex closeout 引 r9 不稳定=诚实，未把 1609 好曲线冒充 r9。无偷换。
- clip 真源 = 仅 repo-loop（c5_mlx_train_loop.py，untracked）；但所有 repo-loop run clip_disabled=True → clip 实际执行=ZERO。
- parity 真源 = repo-loop noclip Iter10 loss 5.391 == stock Iter10 5.391（trained_tokens 2924 逐位对齐）= Observed 真。

## fuse/endpoint parity 实装真伪（指派维度结论）
- endpoint_tokenizer_parity：fail-closed 正确（status=blocked 当任一 render missing，1125-1126）。think_block_parity 两边 missing 显 true=codex 自报属实的瑕疵，但 status 仍 blocked 不泄漏成 pass → P2 cosmetic 非 P1 fake gate。
- fuse_parity_gate：硬编码全零输入（1552 dynamic=0/fused=0/quantizedIrrelAcc=0）→ 恒 fail；无真 C6 eval 喂入路径 = placeholder（合理，因 C6 diff not_run）。IrrelAcc dynamic-vs-fused delta=已实装+test（4pp fail 验过）；dynamic-vs-quantized delta=未实装（spec:151 要求）= P1 drift。

## Cascade Drift
- spec.md:151（quantized delta 要求）↔ code（只 fused delta）：DRIFT P1（codex failure_receipt #1 自报）。
- design.md:141（clip before update）↔ code（已实装但未运行）：声称=能力描述，无运行证据 → runtime-unverified 非 drift。
- lessons-learned #25 已正确记录 quantized delta 应做 → 文档比 code 更前，提示 codex 知道但未补完。

## 放行门
1. 不可签 lora_candidate（符合 codex）。
2. trainable_v0 前置：① quantized-IrrelAcc-delta 落 code+test（关 spec:151 drift）② clip enabled 实跑 ≥1 次（坐实 1648 mlx-train-command 描述的 600iter/clip1.0 配置，当前只跑了 20iter/noclip）。
3. 北极星门：trainable_v0 数据 = 真多源自然中文（Q13/14/15），结构化 device= 串禁进正式训练。
4. 真机门：endpoint V-PASS 必真机（devicectl No devices found，simulator 不替代）—已锁。

### 对抗验证
- [F1] confirmed → P1: Every factual claim in F1 is independently confirmed by亲读到行 (Observed): spec.md:151 mandates the symmetric dynamic-vs-quantized delta; code only implements dynamic-vs-fused delta (lines 1016-1018) + a quantized absolute-threshold check (lin
- [F2] confirmed → P1: F2 confirmed at P1 — every cited fact re-verified by亲读 file:line, none refuted, none Inferred-as-Observed. The clip_grad_norm(1.0), NonFiniteTrainingError raise (return 70), and 5e-5 fallback code paths in c5_mlx_train_loop.py have NEVER ex
- [F3] confirmed → P1: CONFIRMED at P1 (severity correct, not P0, not downgrade). Every Observed claim in F3 reproduced exactly against HEAD=727a2af working tree (1648 round). The smoke data being 100% machine-structured device= strings is real and is the L1-rule

## Red Team (fake-green / 洗白 / 声称vs实际) — C5 LoRA Training Apply

**verdict**: PARTIAL T-PASS / NOT CANDIDATE / 收尾如实性 CLEAR(无 P0 fake)。发布门:HOLD —— 训练管道工程质量高且诚实,可作 train-health 基线接受;但 C5 实质交付物(自然中文语料生成 Q11-Q15 + C6 评估 + 三方 parity + 真机端侧)未做,不得标 candidate/V-PASS,不得 archive。建议:接受当前为「C5 训练管道 T-PASS 里程碑」,真正的 C5 corpus generation 作为下一刀(需先解 hermes 审计闸超时 + 接入多源 generator 实跑)。

**summary**: 对抗审 codex C5 apply 收尾如实性。结论:codex 的「如实收口」基本属实,无 P0 fake-green / fake-runtime / 数据污染 / candidate 当 approved。验证命令实跑全部为真(swift test --filter C5LoRATrainingTests 13/13 pass、openspec validate --all --strict 8 passed),失败 receipt 自报准确无洗白,blocked 任务正确留 [ ]。但有一个 P1 级的「完成度错觉」:codex 完成的是【训练管道 plumbing + train-health】,而非 C5 真正交付物【Q11-Q15 多源自然中文 utterance 语料生成】——后者 generator_orchestration=dry_run_only / cloud_multi_source_generator_not_run,从未产出一条样本。所有 5 轮 smoke 训练数据是结构化模板 `device=atmosphere_lamp; primitive=power_on; 请按这个语义执行`,不是北极星要的「听懂中文」自然模糊说法。27/33 tasks 勾选诚实但掩盖了:已完成的是脚手架/格式/config,BLOCKED 的恰是实质性语料生成 + C6 评估。北极星生长=部分:工程地基扎实(B1/B2 显式修复到位、repo loop 梯度裁剪正确实现且 iter10 与 stock bit-parity、masking offset fixture、fuse parity dynamic-vs-fused IrrelAcc delta、endpoint tokenizer fail-closed gate 全实装),但模型从未在自然中文上训过,「听懂中文」完全 unverified。

中心张力(train-health 是 stock CLI 无 clip 还是 repo loop 带 clip)已坐实无偷换:健康 600 步曲线(Val0.605)是 STOCK CLI 1609 跑的(lr 1e-4,无 clip,stock 无 hook);带 clip 的 repo loop 1648 只跑了 noclip-20 iter 做 parity,真正 600 步 clip 训练从未完成(receipt 明写 training_log_ref=planned_...、closeout 写「20/600-step parity 未完成不算 gate pass」)。codex 给编排器的 verdict 正确归因 stock。clip 路径的 600 步实际行为 UNVERIFIED,但 codex 诚实标注。

「我没 stage/commit」与 HEAD=727a2af 是 codex commit 无矛盾:727a2af(14:38)是早期 scaffolding(仅 r9 lr2e-4 + r10 dry-run);其后的 4 个 smoke 轮(含验证 verdict 的 1609/1648)+ 核心交付物 c5_mlx_train_loop.py + 927 行未提交 Swift 改动全部 untracked。「没 commit」指 727a2af 之后的工作,属实。fresh checkout 会丢核心 repo loop = P2 流程风险。

派单强制的每步 hermes 异源审计闸 FAILED(hermes-q6-repoloop-audit.md: ok=false, timeout 900s, stdout 空);codex 已披露此 gate 无有效输出,Codex subagent 审计 verdict=FAIL 被作输入未修。= 跨厂商审计闸事实上未生效 = P1。

### findings
- **[RT-01] P1** (Observed) 完成度错觉 / 声称vs实际(C5 实质交付物未做)
  - problem: codex 完成的是训练 plumbing + 在结构化占位语料上的 train-health,不是 C5 真正交付物(多源生成自然中文模糊 utterance 教模型「听懂中文→映射 ToolCall」)。27/33 勾选诚实但已完成的全是脚手架/格式/config/safety-gate 代码,实质性语料生成(Q11-Q15)+ 评估(Q17)+ 签发(Q18)全 BLOCKED。模型从未在自然中文上训练,北极星核心能力(听懂中文)完全未验证。这不是 codex 撒谎(它如实标 blocked),而是『C5 apply 完成』这个 frame 会被误读为『LoRA 大脑已就绪』。
  - why: 北极星 = 客户现场听懂中文。当前训练数据让模型学的是把 `device=X; primitive=Y` 语法 parrot 成 ToolCall——这恰是 3HIGH『防死记』警告的死记模式,对自然中文理解零贡献。若误判此里程碑为『C5 done 可进 C4/C7』,会在缺真实 FC 大脑的地基上继续盖楼。
  - fix: 明确定性当前为『C5 训练管道 T-PASS 里程碑(plumbing verified on placeholder data)』,非『C5 LoRA 大脑就绪』。下一刀必做:① 接入多源 generator(hermes glm 主)实跑产自然 utterance 语料 ② dual-layer 异源 judge ③ Q15 lineage 重判 ④ 再训 + C6 base-vs-LoRA diff 证 vs 0.789 hard_fail 的提升。不得在 dry_run 语料上声明任何模型质量结论。 [owner:codex(下一刀 C5 corpus generation)+ 磊哥拍板里程碑定性]
- **[RT-02] P1** (Observed) 跨厂商审计闸失效(派单强制 gate 未生效)
  - problem: 派单磊哥强制的每步 hermes 异源(cross-vendor)审计闸事实上从未产出有效输出(900s 超时空 stdout)。唯一跑出的 Codex subagent 审计给了 FAIL,但 codex 把它『作输入不再修复』。= repo loop 这一关键步骤(改了 stock 训练语义把 optimizer.update 移出 compiled step)缺乏独立跨厂商验证。
  - why: 派单核心防线之一是异源审计破共享 frame(codex 自审同 family bias)。审计闸失效 = repo loop 的训练语义正确性只有 codex 自己 + 一个 FAIL 的 subagent 背书 + iter10 parity(仅 10 步)。长程(600 步)clip 路径行为无任何独立验证。
  - fix: 下一刀前先修 hermes 审计闸超时(probe generator 三权分立档已记本机 hermes 不稳→可改 timeout 更长/换源/拆更小 prompt)。repo loop 的 optimizer.update-out-of-compile 语义应跑一次完整 600 步 clip-enabled vs clip-disabled 双跑,确认长程无 compile-state 漂移(当前仅 iter10 bit-parity)。Codex subagent 的 FAIL verdict 应逐条核实而非『作输入』。 [owner:codex + 磊哥(审计闸基础设施)]
- **[RT-03] P2** (Observed) 核心交付物未提交(fresh checkout 丢失风险)
  - problem: codex『我没 stage/commit』属实且无误导(727a2af 是早期 scaffold,其后工作刻意未提交)。但 C5 核心交付物 c5_mlx_train_loop.py + 595 行 C5LoRATraining.swift 增量 + spec/tasks 修订 + 4 个验证轮全在工作树未落 git。
  - why: fresh checkout / git clean 会丢掉 repo loop(梯度裁剪实现)+ 全部验证证据。审计员实读到的 1902 行 C5LoRATraining.swift 与 HEAD 的 1337 行版本不同(差 595 行未提交)——任何基于 HEAD 的复核会看到不完整实现。
  - fix: 磊哥决定是否 commit(派单未要求 codex 自动 commit,符合『commit 只在用户要求时』纪律)。若接受里程碑,应 commit c5_mlx_train_loop.py + 未提交 Swift/spec/tasks,并把 .safetensors adapter 产物按红线处理(权重产物入仓 OK,但 600 个 checkpoint .safetensors 体积需评估)。Reports 下 smoke 轮的 placeholder train.jsonl 是脱敏结构化模板(非原文语料)可入仓。 [owner:磊哥(commit 决策)]
- **[RT-04] P2** (Observed) receipt 字段语义易误读(train_on_turn vs 实际 chat-mask)
  - problem: `train_on_turn=false` 不代表『无 masking』——MLX `--mask-prompt` chat 格式天然 mask prompt(offset 425 证实)。该字段指的是 C5 自己的 masking-stage 晋级(masking_complete_v1),smoke 轮故意停在 smoke_only 用 stock chat-mask。但 committed closeout(描述 masking_complete_v1 数据)与最终 verdict 支撑轮(1609/1648 smoke_only)是不同 run,字段取值相反易让审计误判为回退或矛盾。
  - why: 审计/未来 session 读 receipt 可能误判『masking 没做』或『closeout 与实跑矛盾』。实际是:committed closeout 描述 r10 dry-run(masking_complete_v1),但 verdict 支撑的健康曲线来自 1609(smoke_only / 不同 masking 阶段)——两者非同一 run,需显式说明。
  - fix: receipt 加注:train_on_turn 指 C5 masking-stage 晋级标志,非『是否有任何 prompt mask』;smoke 轮始终用 stock --mask-prompt chat masking(offset 已验)。closeout 应显式标明『verdict 健康曲线来自 1609 smoke_only run,与本 closeout 描述的 r10 masking_complete_v1 dry-run 不是同一 run』。 [owner:codex(receipt 字段注释)]
- **[RT-05] P2** (Observed) endpoint tokenizer parity think_block 字段诚实但显示误导(codex 已自报)
  - problem: 两边 render 缺失时 thinkBlockParity 字段显 true(看着像通过),但 gate 整体 fail-closed(status=blocked + 缺失 failure)。字段显示有误导,但不产生 false pass。codex 已诚实自报此局限。
  - why: 纯 cosmetic——gate 行为正确(fail-closed),无 fake-green 风险。但字段值与直觉相反,人审 receipt 可能瞬间误读。codex 主动披露 = 无洗白。
  - fix: thinkBlockParity 在任一 render 为 nil 时返回 false 或单独的 "blocked/unknown" 三态,而非 true。低优先,gate 行为已正确。 [owner:codex(字段 polish,非阻断)]
- **[RT-06] P3** (Observed) 正面确认 — codex 声称的验证全部实跑为真(无 fake-runtime)
  - problem: 无问题——记录为对照基线。codex 的核心验证声称(swift test 13/13、openspec 8 passed、parity、placeholder fix、B1/B2)经审计员独立实跑/实读全部为真。无 fake-runtime,无声称做了实际没做。
  - why: Red Team 默认怀疑下,逐条复核未发现 codex 虚报『做了』。失败 receipt 5 条(quantized IrrelAcc delta 缺、endpoint parity 仅 fail-closed 非完整 evidence、repo-loop 需 parity 证明、status=smoke_only_ready 易误读、mlx-lm 无 lock pin)经核实全部如实,无洗白。这是高质量诚实工程。
  - fix: 无需修复。作为『收尾如实性 CLEAR』的正面证据。 [owner:—]

### extra
## tasks 真实性核对(27 勾选 vs 6 blocked,无 fake completion)

| task | 状态 | 审计核实 |
|---|---|---|
| 1.1-1.4, 2.1-2.4 | [x] | 真:source refs/route_tier 派生/offline 在代码+receipt 坐实 |
| 3.2 assistant-mask | [x] | 真但 nuance:代码实现 + offset fixture testSlotPlaceholders 过;smoke 轮用 stock --mask-prompt(offset 425 验),非 C5 masking_complete_v1 晋级 |
| 3.3/3.4/3.5 augmentation | [x] | 真:distractor_only/value_strategy/masking_complete_v1 promotion 代码+test 过 |
| 4.1-4.4 refusal | [x] | 真:counterfactual paired/0.10 target/0.20 cap/prompt distractor 在 receipt(refusal_ratio_observed 0.1001) |
| 5.1-5.4 config | [x] | 真:scale 非 alpha/7 keys 非 embed/1e-4 cosine adamw wd0.01/rank16 mainline,config yaml 实读坐实 |
| 6.3 diagnostic | [x] | 真:generalization_diagnostic 字段 + blocked_leakage 逻辑;但实际 in_dist/heldout/ood=null(未跑) |
| 6.6/6.7 acceptance gate | [x] | 真:acceptance_stage 三态 + endpoint parity gate 代码+test 过 |
| 7.1/7.2/7.3/7.5 verify | [x] | 真:13/13 test、8 passed validate、data-gate validator、closeout 三层报告,审计员实跑确认 |
| **3.1 smoke formal readiness** | **[ ]** | 诚实留空:smoke 不标 formal readiness |
| **6.1 C6 base-vs-LoRA diff** | **[ ]** | 诚实留空:c6_base_vs_lora_diff_not_run |
| **6.2 replay fingerprints** | **[ ]** | 诚实留空 |
| **6.4 OOD probes** | **[ ]** | 诚实留空 |
| **6.5 三方 parity 实跑** | **[ ]** | 诚实留空:dynamic/fused/quantized 行为对比未跑(gate 代码已实装但无数据) |
| **7.4 V-PASS 前置全跑** | **[ ]** | 诚实留空 |

核实结论:27 勾选无 fake completion(均代码/test/receipt 坐实);6 留空恰是实质性语料生成+评估+真机,与 candidate blocked 一致,无矛盾。

## 中心张力 Truth Source 表(train-health 来源溯源)

| run | 工具 | lr | grad clip | 600步? | 健康曲线 | 委托 verdict 引用? |
|---|---|---|---|---|---|---|
| r9(committed) | stock mlx_lm.lora | **2e-4** | 无 | 是 | spike→stabilize 5.711→4.713 | committed closeout 引;非最终 verdict 主据 |
| 1609(untracked) | stock mlx_lm.lora | 1e-4 | 无(stock 无 hook) | 是 | **健康 Val4.367→0.605 Train→0.596** | ⭐最终 verdict『Iter600 Val0.605』主据 |
| 1648(untracked) | **repo loop c5_mlx_train_loop.py** | 1e-4 | **1.0(实装)** | **否,仅 noclip-20** | iter10=5.391 与 stock bit-parity | parity 证据;明写『20/600 未完成不算 gate pass』|

裁决:无偷换。健康 600 步是 STOCK 1609(无 clip,lr 1e-4),codex verdict 正确归因 stock。带 clip 的 repo loop 600 步从未跑(receipt training_log_ref=planned_...)。clip 路径长程行为 UNVERIFIED 但 codex 诚实标注,iter10 parity 证明语义正确(短程)。

## Cascade Drift(doc/code/receipt 漂移核查)

| 维度 | 一致性 |
|---|---|
| spec.md ↔ code | 一致:endpoint parity/IrrelAcc delta/schedule unit 三 scenario 新增,代码均实装 |
| tasks.md ↔ 实际 | 一致:勾选=已实装,留空=blocked |
| design.md ↔ code | 一致:1e-4/adamw/repo loop/对称 IrrelAcc delta 描述与代码吻合 |
| committed closeout(r10)↔ 最终 verdict(1609/1648)| **轻漂移**:closeout 描述 masking_complete_v1 dry-run,最终 verdict 健康曲线来自 smoke_only run;同字段 train_on_turn 取值相反(RT-04)。非 fake,需显式说明非同 run |
| lessons B20-B26 ↔ receipts | 一致:B21 grad clip blocked / B22 placeholder / B26 endpoint parity 均与 receipt+code 吻合 |

## 放行门(Release Gate)

- ✅ 收尾如实性:CLEAR(无 P0 fake-green/fake-runtime;失败 receipt 无洗白;验证实跑为真)
- ✅ train-health T-PASS:可接受(plumbing 在 placeholder 数据上验证 + 健康曲线 stock 实跑)
- ❌ C5 实质交付物(Q11-Q15 自然中文语料生成):未做,不得标 done
- ❌ 模型质量 V-PASS(C6 Mac):BLOCKED(C6 diff 未跑)
- ❌ 端侧 candidate V-PASS(真机):BLOCKED(无真机 dump + 三方 parity 未跑)
- ⚠️ 跨厂商审计闸:失效(hermes 900s timeout 空输出)→ 下一刀前必修
- ⚠️ 核心交付物(c5_mlx_train_loop.py)untracked → 接受里程碑则需 commit

裁决 = **HOLD**:接受为『C5 训练管道 T-PASS 里程碑』,不得 archive define-lora-training,不得进 C4/C7。下一刀 = 真正 C5 corpus generation(先修 hermes 审计闸 + 接多源 generator 实跑 + C6 评估)。

### 对抗验证
- [RT-01] severity-adjusted → P2: RT-01's factual core is fully confirmed by my own direct reads, but its P1 severity (filed under "完成度错觉 / 声称vs实际") is overstated because no 声称-vs-实际 gap actually exists — every authoritative source already frames C5 honestly, and the misrea
- [RT-02] confirmed → P1: CONFIRMED at P1. RT-02's two load-bearing claims both hold against first-hand re-read: (1) the magnet-mandated, explicitly-"不降级" hermes cross-vendor gate produced zero valid output on the repo-loop step (900s timeout, empty stdout/stderr) —

## grill 决策落地 + boundary-guard 元审

**verdict**: PASS_WITH_FINDINGS — 训练健康 T-PASS(stock CLI 实跑 600 step 收敛 0.596、无 NaN/OOM)诚实成立；candidate V-PASS(模型质量+端侧)如实 blocked，无假绿。无 P0。codex closeout「如实收口」核验=如实。放行进 P1-C 下阶段(跑 Q13/Q14/Q15 正式数据 + C6 diff + 三方 parity)，前提是补齐下方 4 条 P1(均为 codex 已自报的部分实装，需落进执行计划而非停在报告/failure_receipt)。grill 决策落地率高(~90%)，CC boundary-guard 反馈有效信号占优。

**summary**: 审计枢纽三问全部坐实，结论与 codex 自报「如实收口」基本一致——这是一次少见的【诚实长跑】，不是假绿。(a) train-health 来源无偷换：codex 报的 600-step Iter600 Val0.605/Train0.596/Peak12.939GB 来自 1609 **stock CLI** 跑（receipt 明写 `gradient_clip_status: blocked_stock_mlx_lm_lora_has_no_grad_clip_hook`，无 clip），repo-loop(1648) 只跑到 iter10 且 LR≈0(warmup)，codex 自己白纸黑字「20/600-step parity 未完成不算 gate pass」——两份 receipt 干净区分，无张冠李戴。(b) 27/33 checkbox 无 fake completion：6 个 open([ ])恰好是 6.1/6.2/6.4/6.5/7.4(C6 diff/fingerprint/OOD/三方 parity)+3.1，全是真 blocked 项；无任何 blocked 项被标 [x]；6.3[x] 诚实(verification 只要 diagnostic 结构+fail-closed，`blocked_missing` 正满足「missing 只阻泛化声明」)；3.1[ ] 是保守欠报(smoke_only stage 代码+测试都过却没勾)。(c) repo-loop 语义正确：把 optimizer.update 移出 `mx.compile` step、同时从 compiled state 删 optimizer.state(c5_mlx_train_loop.py:182 vs stock trainer.py:232)= 一致正确的变换，非引入 bug。验证实跑：swift test C5LoRATraining 13/13 pass、C5DataGate 6/6 pass、openspec validate --all --strict 8 passed、data-gate receipt must_not_train=0/overlap=0/redaction pass——全 Observed。grill 落地高保真：Q11 bug_corpus 第一刀不进(代码只读 3990+c6 cases，零 12000bug 引用)、rank16/scale(非alpha)/lr1e-4/AdamW wd0.01/num_layers-1/clip1.0/keys 排 embedding 全对、CC 插话1/2/3(含 gap1 dynamic-vs-fused IrrelAcc delta、gap2 端侧 patched tokenizer)全被采纳且实装正确。真问题都是 codex **主动自报**的部分实装(dynamic-vs-quantized IrrelAcc delta 缺、B1 offset fixture 是 Swift 字符串前缀代理非真 MLX offset、c3 spike render bytes 未固化、端侧 render 未 dump)，方向=向北极星生长(端侧可演示中文 FC 大脑的数据/masking/验收骨架立住)，非滑回假绿。CC 元审：3 插话有效信号占优，已知「缺 environment 段」错判(基于 1455 旧 receipt，1609 已有该段)被磊哥纠正属实=噪声已 catch。

### findings
- **[GD-01] P1** (Observed) B1 offset fixture / masking 正确性
  - problem: receipt 报的 offset_fixture:pass 是 Swift 侧字符串前缀代理，不是 dispatch B1 要求的真 MLX tokenizer offset 字节校验。这正是 B1 风险本身——render_diff 不报 offset 正确性。若 stock ChatDataset 实际 offset 与假设不符(过冲 think 块字节)，fixture 仍会显 pass，静默训练错误不被 catch。
  - why: B1 是两审共识的技术正确性 BLOCKER；用字符串代理冒充 offset 校验=把 B1 的硬约束软化成表层检查，违 dispatch:5「B1 必须显式非自主」。
  - fix: 加一个真跑 MLX 的 fixture(Python/pytest 调 apply_chat_template(messages[:-1],tools,add_generation_prompt=true,enable_thinking=false) 算 offset，断言 == assistant content 起点、trained span 精确覆盖 tool_call)；先固化 c3 spike enable_thinking=false 实际 render bytes 落盘为可引用 artifact，再做 train_render_bytes==spike_bytes 比对。Swift 侧 fixture 降级为辅助、不得单独产 pass。 [owner:codex]
- **[GD-02] P1** (Observed) fuse parity / IrrelAcc delta
  - problem: CC 插话3 gap1『fuse 让 0.95→0.91 仍>0.9 不报』对 fused 已修，但对 quantized(4bit endpoint)同样的对称 delta 漏检——量化掉 4pp 但仍>0.90 绝对阈值会漏报，恰是 dispatch:93 fail_if 的 quantized 行为回退场景。
  - why: 端侧实际跑的是 quantized 4bit(dispatch Q18 three-way parity 第三态)，dynamic-vs-quantized 才是端侧 demo 行为真相；缺它则三方 parity 名不副实。codex 已自报但停在 failure_receipt，未落执行计划=会被遗忘(§33)。
  - fix: C5FuseParityInput 加 dynamicIrrelAcc-vs-quantizedIrrelAcc 对称 delta 字段 + fail_if delta>tol + 单测覆盖 0.95→0.91 quantized 回退 fail-closed。与 fused delta 并列。 [owner:codex]
- **[GD-03] P1** (Observed) mlx-lm 版本 pin / 复现
  - problem: repo-loop copy 了 stock trainer.train() 主体(c5_mlx_train_loop.py:1-7 注释明示 intentionally copies stock body)，强依赖 0.31.1 internal API(CONFIG_DEFAULTS/build_parser/yaml_loader/iterate_batches/build_schedule)。无 repo 级 pin，新环境 pip 装到 0.31.2+ 时 internal API 漂移会静默炸 or 行为变。runtime guard 只在跑时拦，不锁安装。
  - why: 插话2 gap『复用 stock internal API 需 pin 0.31.1+CI』codex 采纳了 runtime guard 但没补 lock；OpenSpec 首次实践+SA 资产的复现性靠 lock 不靠跑时提醒。
  - fix: 加 requirements-c5-training.txt(mlx-lm==0.31.1, mlx, transformers, numpy 等精确 pin)+ README/closeout 引用；CI(如有)装这个 lock。runtime guard 保留作双保险。 [owner:codex]
- **[GD-04] P1** (Observed) Q15 lineage / Q13-14 正式数据管道
  - problem: step2 数据是确定性模板 dry-run，不是 dispatch Q13 多源云 generator+Q14 跨厂商 judge+Q15 candidate 语义重判的正式管道。当前 4956 行不可作 trainable_v0 正式训练数据(只是 smoke_only 链路验证)。Q15 candidate_parent_semantic_id 增广后重判(修 C5DataGate:255 exact-ID 假安全)的核心逻辑未实跑。
  - why: 这是 P1-C 进入正式训练的硬前置——没有 Q13/14/15 正式数据，后续 C6 diff 跑的是合成 dry-run 数据，模型质量 V-PASS 不成立。codex 诚实标 blocked(非假绿)，但是阻塞下阶段的关键路径。
  - fix: 按 dispatch step2a/2b/2c 跑正式管道：多源云 generator(hermes glm 主+异源)产候选 utterance → dual-layer validator(逐样本 judge≠gen)→ Q15 candidate 语义重判 against heldout/c6_base/must_pass → data-gate rerun。先 scout 本机 embedding 模型(bge-zh/m3e)+人标小批校准 dedupe 阈值(Q15 依赖链①②③)。 [owner:codex]
- **[GD-05] P2** (Observed) grill mix 配比偏差
  - problem: fc_l2(69%)、fc_l3(23%)双双超 grill 软目标；fc_l3 从~95-163 种子重增广到 948 行(≈6-10x/种子)逼近甚至可能局部超 per_seed_max_variants≤8，过度复制少数稀缺种子会放大死记/分布失真风险。
  - why: Q11 elephant+pre-mortem 明确 fc_l3 是隐藏瓶颈、grill 定 best_effort+per_seed 上限正为防此；偏差虽在『~』近似latitude 内，但 fc_l3 23% 远超 15% 且来自少量种子，对小数据 LoRA 死记敏感。
  - fix: receipt 加 per_seed_variant_count 直方图(尤其 fc_l3 种子)+ 显式核 per_seed_max_variants≤8 未破；若 fc_l3 配比要保 23% 则需第二刀补真实 fc_l3 种子(Q11 fc_l3_undersampled:true 已标)而非靠重复增广。closeout 记偏差理由。 [owner:codex]
- **[GD-06] P2** (Observed) smoke_only masking_coverage 语义
  - problem: smoke_only receipt 报 function/argument/value masking=true 与 grill『smoke_only 不置 masking_coverage 真』矛盾。虽然底层增广确实跑了(非凭空)，但 train_eligible=false/acceptance_stage_max=train_health 已堵死误升，影响有限；不过审计读 receipt 时 function/arg/value=true 易被误读成『masking_complete 已达成』。
  - why: grill 三态设计意图是 smoke_only 阶段 masking_coverage 全 false(纯链路测)，trainable_v0/masking_complete_v1 才逐步置真；当前实现把『增广是否应用』与『stage 准入』耦合错位。
  - fix: smoke_only stage 时强制 masking_coverage 四项全 false(或加 coverage_stage_consistent 字段说明 smoke_only 下 true 仅表增广已生成、不表准入)；对齐 grill Q4 三态表语义。 [owner:codex]
- **[GD-07] P2** (Observed) config scale 值
  - problem: scale 口径(非 PEFT alpha)正确✓，但 magnitude 选 32 偏离 grill『首版~20』且 closeout/design.md 未记为何选 32(=rank16 时 alpha 等效 2r=32 的 PEFT 思路?若如此则正是 grill 警告的 alpha=2r 口径回潮)。
  - why: Q7 codex 自己纠过『MLX scale≠PEFT alpha，不写 alpha=2r』；scale=32 恰好=2×rank16，疑似 PEFT alpha=2r 思路换皮回来，与 grill 纠偏意图相悖(或纯属冒烟 A/B 选值，需澄清)。
  - fix: design.md/closeout 记 scale=32 选择理由(冒烟 A/B 实测优 or 其他)；若是 alpha=2r 推导则改回 grill 建议~20 或显式说明 MLX scale 语义下 32 的依据，避免口径回潮。 [owner:codex]
- **[GD-08] P3** (Observed) closeout 文档措辞
  - problem: closeout 用『B20-B26』标号与实际 lessons 编号 20-26 不符(B 是 lessons-learned 里另一组前缀)。纯命名笔误，内容真实存在且优质。
  - why: 审计若按『B20-B26』grep 会误判 lessons 未写(本审计起初 grep B20 即空)；属可溯源性小噪声。
  - fix: closeout 改引『lessons-learned.md 第 20-26 条』或给 lessons 加稳定锚点 ID。低优先。 [owner:codex]

### extra
## tasks 真实性核对（27/33 [x]，逐 open 项核 blocked 性）
| task | 状态 | 核验结论 | strength |
|---|---|---|---|
| 3.1 smoke_only stage | [ ] open | **欠报**：代码 smokeOnly+测试 testSmokeOnlyStage 都过，6 轮 smoke 实跑，却没勾。安全方向错(under-claim) | Observed |
| 6.1 C6 base baseline | [ ] open | 真 blocked：无 C6 base-vs-LoRA diff(closeout failure_receipt 实录) | Observed |
| 6.2 replay fingerprints | [ ] open | 真 blocked：adapter digest 部分有(P0-2 C6EvalRun)但 C5 run 未跑 | Observed |
| 6.4 OOD probes | [ ] open | 真 blocked：ood_probe=null(receipt diagnostic_verdict=blocked_missing) | Observed |
| 6.5 三方 parity | [ ] open | 真 blocked：fuse_parity_gate input(0,0,0)→fail 占位，未实跑 | Observed |
| 7.4 C6 diff+parity+byte parity | [ ] open | 真 blocked：endpoint render 未 dump | Observed |
| 6.3 generalization_diagnostic | [x] | **诚实**：verification 只要结构+fail-closed，`blocked_missing` 正满足；OOD 实跑归 6.4(open) | Observed |
| 6.6/6.7 acceptance_stage/endpoint fields | [x] | 诚实：gate 逻辑+字段实装，缺 render 时 blocked 不漏成 pass | Observed |
**结论**：无 blocked 混入 [x]；codex checkbox 标记诚实且保守(3.1 反而欠勾)。

## Truth Source 表（审计枢纽三问）
| 问 | codex 自报 | 实际(Observed) | 是否如实 |
|---|---|---|---|
| (a)train-health 跑哪个 loop | stock CLI 600-step(无clip)；repo-loop iter10 不算 gate | 1609 stock CLI gradient_clip_status=blocked；1648 repo-loop log 止于 iter10、LR≈0 | ✅ 如实，无偷换 |
| (b)27 task 真完成 | 27 done/6 blocked open | 6 open=真 blocked C6/parity/OOD 项；无 blocked 标 done | ✅ 如实 |
| (c)repo-loop 正确性 | 移 optimizer.update 出 compiled step | py:185-208 compile 内算 grad+clip 返回，:310 外部 update；:182 删 optimizer.state(对应) | ✅ 正确变换 |
| (d)声称 vs 实际 | failure_receipt 自报 4-5 条部分实装 | dynamic-vs-quantized IrrelAcc delta 缺/B1 offset 字符串代理/c3 render bytes 未固化/端侧 render 未 dump 全属实 | ✅ 未洗白 |

## grill 落地对照（Q1-Q18）
✅ 落对：Q11(bug 不进第一刀实证零引用)/Q12(B1 `\n\n`前缀+patched tokenizer，超 grill 推荐)/Q4 rank16/Q7 scale非alpha=32/Q8 refusal 0.10观测0.1001 cap0.20/Q5 route_tier≠exec_tier+rehearsal7.5%/Q9 三轴诊断 blocked_missing fail-closed/Q10 acceptance_stage 三级/Q14 stop_on_rule_fail+layer2 异源 judge_model_id≠generator/Q15 candidate 语义重判字段(blocked_missing 未跑)/Q17 dev_selection 第六 bucket(B2)+C6 final-only/Q18 三方 parity gate+真机 reject substitutes。
⚠️ 偏差(P2)：mix fc_l2=69%/fc_l3=23% 超 grill 软目标 55%/15%(fc_l3 仅~95-163 种子重增广到 948，per_seed≤8 仍偏高)；scale=32 vs grill「首版~20」无文档理由。

## CC boundary-guard 元审
- 插话1(loss三件套)：✅ 采纳(1e-4/repo-loop clip/AdamW wd0.01)且正确。
- 插话2(Q2 最小自有 loop)：✅ 采纳——repo-loop 复用 stock ChatDataset/iterate_batches/build_schedule/CONFIG_DEFAULTS，只重写最外层 step，pin 0.31.1 有 require_pinned_mlx_lm。正确。
- 插话3 gap1(dynamic-vs-fused IrrelAcc delta)：✅ 实装(C5LoRATraining.swift:1016-1029，fail-closed missing)。gap2(端侧 enable_thinking)：✅ patched tokenizer+endpoint parity gate。
- 已知错判「缺 environment 段」：基于 1455 旧 receipt，1609/1648 实有 Environment 段(seed/版本/硬件/commit)——磊哥纠正属实，CC 旧结论错=噪声，已 catch。有效信号占优。

## 放行门
- [门1·已过] 训练健康真跑(stock CLI 600 step 收敛+无NaN/OOM) Observed。
- [门2·已过] candidate V-PASS 如实 blocked、无假绿；closeout 三层(train-health/C6 model-quality/真机 endpoint)分清。
- [门3·待补 4×P1，进下阶段前落执行计划] ①dynamic-vs-quantized IrrelAcc delta 字段+测试(现只 dynamic-vs-fused) ②B1 offset fixture 升级为真 MLX apply_chat_template offset 校验(现 Swift 字符串前缀代理，dispatch:72 clause①②未真实装) ③固化 c3 spike enable_thinking=false 实际 render bytes 为可引用 artifact(dispatch:72 要求) ④mlx-lm 0.31.1 加 repo 级 requirements/lock pin(现只 runtime guard)。
- [门4·阻端侧不阻 C5] iPhone 8GB 真机端侧 V-PASS(北极星硬前置，与 P1-B 一致 blocked)。

### 对抗验证
- [GD-01] confirmed → P1: The finding's core technical claim is CONFIRMED on every load-bearing point I could read: the offset_fixture is a Swift string-prefix proxy, usesTrainingTokenizerPatch is hardcoded true and forces pass, apply_chat_template is never actually
- [GD-02] confirmed → P1: CONFIRMED at P1 (severity held, not adjusted). The technical core is accurate and Observed: C5FuseParityGate (C5LoRATraining.swift:1014-1041) implements only the dynamic-vs-fused IrrelAcc symmetric delta and checks quantizedIrrelAcc only ag
- [GD-03] severity-adjusted → P2: Factual core CONFIRMED (all Observed by direct Read/Bash), but severity downgraded P1->P2. WHAT'S TRUE: (1) Tools/C5TrainingCLI/c5_mlx_train_loop.py:46 REQUIRED_MLX_LM_VERSION='0.31.1' + :113-120 require_pinned_mlx_lm runtime guard - read d
- [GD-04] confirmed → P1: GD-04 is fully confirmed at the stated P1 severity. Every cited file:line and receipt value reproduces exactly under independent Read/Grep/python inspection. The substance is precisely correct: the 4956-row training data is 100% determinist

## Doc Cascade Drift + Release Gate

**verdict**: No-Ship 非 Stop-the-line。可放行 train_health T-PASS 绝不可签 candidate/V-PASS。必清:Q2 clip-ENABLED 真跑、修两处文档 drift、云 generator/Layer2/lineage 三 not_run、C6 diff、真机 parity。北极星朝端侧 FC 大脑生长无假绿,差真训 candidate 加 C6 提升 加 真机整条腿。</verdict>
<extra>放行门:门1 Q2 真红、门2 云 generator 真红(dry_run_only)、门3 三轴真红(diagnostic blocked_missing)、门4 部分(render bytes 未落盘 endpoint_byte_count=0)、门5 真绿。Closeout 全 Observed:train-health Val0.605 无发散、candidate blocked、27/33 无 fake completion 6 未勾全真 not_run。D4 诚实收紧(tasks.md 提交后反加 6.7 endpoint parity/5.3 改 1e-4),D5 design/spec/code/lessons 无 drift。CC 插话1/2 高信号 1:1 兑现,插话3 漏 quantized delta 半对,1 处 §28 滞后(缺 environment 段结论基于 1455 旧 receipt)。第六 finding(CC boundary-guard P2)因篇幅并入此处。make verify=Unverified 真机 Runtime-unverified。全程只读未碰工作树。

**summary**: codex C5 实现底子诚实非 fake-green。openspec validate 8 passed、swift test 13/13、占位符 bug 已修、B2 dev_selection 六桶落 spec.md:4。五放行门 4 真绿。两类 drift 加 Q2 clip 实跑门未达。

### findings
- **[DCG-P1-01] P1** (Observed) Closeout-Fact Drift 已提交 closeout 比实况乐观
  - problem: 仓内唯一被提交的 closeout 报 trainable_v0 加 masking 完整,实际回到 train_eligible=0;权威记录偏乐观,读者误以为可进 C6 diff
  - why: 违反 lessons B18 与 §28:committed artifact 应是最保守实况非中途乐观快照
  - fix: codex 收尾提交最终 train_health receipt 加对齐 closeout,r10 顶加 superseded 指针 [owner:codex]
- **[DCG-P1-02] P1** (Observed) Roadmap-Implementation Drift 级联根文档过时
  - problem: CLAUDE.md §9 与 roadmap 是起手必读级联根,读它们以为 C5 没派没跑,实际已到 train_health 加 5 训练轮;状态滞后一整阶段
  - why: memory v10 并发纪律下 CC 暂不改 repo 文档,预期滞后仍是 drift,§33 失忆复发风险
  - fix: codex 收尾后 CC 立即级联:CLAUDE.md §9 改 C5 实装到 train_health 下一步 Q2 clip 实跑;roadmap 同步;memory v10 到 v11 [owner:CC]
- **[DCG-P1-03] P1** (Observed) Release Gate Q2 repo-loop grad-clip 路径零 runtime 覆盖
  - problem: Q2 放行门未达:clip 代码写了 parity clip-disabled 对齐了但 clip 生效路径从未真跑 fallback 零覆盖;该 run grad_norm 193-366 正该 clip 却禁用
  - why: 审计枢纽核心怀疑属实但 codex 如实标注是诚实未完成非隐瞞;北极星不崩依赖 clip 未实跑等于防线未验证;§34 代码 active 不等于行为生效
  - fix: 正式训练前跑 repo-loop clip-ENABLED 真跑验 grad_clip_applied true,构造 nonfinite fixture 验 5e-5 fallback 真停训 exit 70 [owner:codex]
- **[DCG-P2-05] P2** (Observed) Release Gate fuse_parity 与 endpoint_tokenizer stub 占位加 codex 没 commit 偏差
  - problem: 两个 candidate 门是 fail-closed 占位非真实计算门关着对但没真数据;think_block_parity 字段误导;codex 自报没 commit 只对 dirty tree 成立易让审计以为 C5 没进 git
  - why: 发行门保守符 B25/B26 但误当已跑过 parity 会漏没比对;codex 本地身份提交致状态来源不清
  - fix: candidate 阶段喂真实 C6 harness 输出加真实 render bytes 修 thinkSignature nil 判 false;closeout 分两段已提交与未提交 [owner:codex]

### extra
—

### 对抗验证
- [DCG-P1-01] severity-adjusted → P2: 独立重核三态(committed HEAD 727a2af / 未提交工作树 / 各轮 receipt),finding 的事实观察成立但 severity 与 framing 被部分证伪,降 P1→P2。

【事实层 — Observed,成立】committed r10/c5-closeout.md 确实报 trainable_v0 + 完整 masking,而更新的 1648 receipt 报 train_health/smoke_only/train_eligibl
- [DCG-P1-02] confirmed → P1: Independently re-verified the three-state (committed HEAD / uncommitted worktree / report rounds) and the doc-drift claim — finding holds at P1.

CORE CLAIMS VERIFIED (all Observed):
1. `git show --numstat 727a2af -- Core/Training/C5LoRATra
- [DCG-P1-03] confirmed → P1: Finding confirmed at P1; every cited fact (file:line, grad norms, clip_disabled flag, train-health source) re-verified as Observed, and strength="Observed" is accurate. The substance is real and matches §34 (code active ≠ behavior verified)
