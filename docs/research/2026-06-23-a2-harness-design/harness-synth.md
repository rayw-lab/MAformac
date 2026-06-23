## A2 执行 harness

> 执行方 = **另一 CC 窗口 ultracode + `/goal` 自驱**（不派 codex 长跑）。终点 = **代码说 D-domain + 编译过 + `swift test` 0 fail + `make verify` 绿**，**止于老 C5 LoRA 训练前**——A2 不训练、不评模型性能、不生成语料（§0 全部 DEFERRED）。本 harness 把 §C 6 步做成确定性状态机，每步「执行线 + 一轮审计 + 主线程亲核 + step gate」，整体收口才 loopaudit。
>
> 🔴 本机已亲核坐实（A2 执行方起手可直接信）：`scope_tier` 全仓 0 命中（step[0] 硬前置真实）；`generated/` **不在** Makefile diff gate 路径（`Makefile:51` 只含 `GENERATED_CONTRACTS`+`HANDWRITTEN_CONTRACTS`+scripts+Makefile）→ step[1] D-domain 产物必须显式纳入 diff gate 否则逃逸；`C5LoRATraining.swift:2344` `removedToolID:"tool_call_frame"` metadata 声称 vs `:2362` 仍 emit frame（claim-vs-reality 铁律1 活样本，frame 删用行为门不用 metadata）；`rank16Mainline()`=`:1175`（守不动）；`MAformacCoreTests`（`Package.swift:48` SPM target）+ `MAformac.xcodeproj` 并存；cross-section `:4` 注释「不查 correctness」（frame 真删/口径对错验不了 → 必主线程亲核 + 异源）。

---

### 1. 执行管控：6 步 → 7 work-state 单向 DAG + /goal 自驱

6 步映射成 7 个 work-state（`S_INIT` 起手 freeze baseline + `S0`-`S5` + `S_CLOSE` 整体收口），单向 DAG，依赖序违反 = 返工。**state 转移 = 合取 gate（任一 fail 不转移）**。

```
S_INIT → S0(口径+manifest) → S1(Python codegen) → S2(Compiler) ─┐
                                                                  ▼  (S2 ∥ S3 文件域不重叠可逻辑并行)
S_DONE ← S_CLOSE(整体loopaudit) ← S5(C6 surface+base) ← S4(C5 surface) ← S3(state-cells)
   ▲                                                              ▲ (S4 ∥ S5 文件域不重叠可逻辑并行)
   └─ 任一 Sn 失败且不可前修 → ROLLBACK 到 Sn-1 已签 commit（strangler 旧路径保活，链路不断）
```

| state | step | 一句话目标 | 主产物（commit 域，生成物/手写分离） |
|---|---|---|---|
| **S_INIT** | — | 起手对齐：grep `Package.swift`/xcodeproj 确认 `swift test` 入口；读起手必读 5 件；跑 base freeze **A2-before C6 baseline receipt** | 无 commit，记 baseline receipt（命令+case subset+输出目录+sha256+每轴 base 数，action hard_pass 锚 **base 10/23** 按 case schema 字段拆非 case_id naming） |
| **S0** | [0] | 锚 **191 device/562 intent/2159 行**；工具数 G2 实算（不拍 30-60）；col O 从 raw xlsx 第15列提；**落盘 scope_tier/allowlist manifest**（source/sha256/验证命令）；重生成 `generated/10-family-device-map.json` 对齐 191（现 223 过期）；废口径全仓标 SUPERSEDED | `contracts/`(manifest) + `generated/`(重生成) |
| **S1** | [1] | `gen_tool_contract.py` 加 D-domain 具名目录生成函数（value 形态编码进名 + arg enum + domain→子组→tool 三级），**两层 scope**（full 1538/demo 562），消费 S0 manifest；产物纳入 diff gate | `scripts/gen_tool_contract.py` + `generated/`(D-domain 目录) |
| **S2** | [2] | 删 `frameToolSchema`(:23)/`renderedToolsText` 双 surface 并挂(:48)/`dDomainSurfaceNames()` 硬编码(:71)；Normalizer+StateApplier（329 行）data-driven（switch 补 default+日志）；写 compiler unit test | `Core/Contracts/ToolContractCompiler.swift` + 新 test |
| **S3** | [3] | state-cells 补 6 族（座椅/车门/音量/雨刮/天窗/香氛）→ 191 device；C3 `executionCellID` switch→`execution_range_cell` 派生；命名清债 `hvac.ac`→`ac.power`（StateStore:136/150、FastPath:21） | `contracts/state-cells.yaml` + `C3ExecutionPipeline.swift` + `DemoVehicleStateStore.swift` + `FastPathIntentEngine.swift` |
| **S4** | [4-code] | C5 正样本(:2362)/tools schema(:2408)/用户文本风格(:1767) surface 改 D-domain；CLI 加 `--scope`/`--surface`；**仅预留接口/shape，不生成语料/不调云 generator/不跑 judge/不训**；守 `rank16Mainline()`(:1175) | `Core/Training/C5LoRATraining.swift` + `Tools/C5TrainingCLI/main.swift` |
| **S5** | [5-code] | C6 30 MP case expected(:356-387)/`c6-bench-cases.jsonl`/coverage(:419 扩 191 device) 迁 D-domain；readback(:1038-1039) 走方案P（删 eval 计 hard_pass，gold :865 不改）；**跑 base 验格式/链路**（不评 LoRA 性能、不建四层门） | `Core/Bench/C6VehicleToolBench.swift` + `contracts/c6-bench-cases.jsonl` |
| **S_CLOSE** | — | 整体 loopaudit 至一轮零 P0/P1 + §F 验收门逐条核 + 生成物/手写 commit 分离核 | lessons-learned 追加 + loopaudit 留痕 |

**/goal 状态持久（双锚防分叉）**：每 gate 通过后原子写 `.a2-goal-state.json`（gitignored，仓内不入）记 `current_state`/`states_done`/`baseline_receipt`/`last_signed_commit`/`next_action`。**中断恢复**：读 state 文件 → `git log` 对账 HEAD==`last_signed_commit`（不一致以 git 为事实层）→ **实跑 `swift test`+`make verify` 确认当前态真绿**（不信状态文件「说绿了」，claim-vs-reality 第10变体文档层镜像）。TodoWrite 镜像 7 state 给磊哥实时可见。

---

### 2. 每 step 内部：三线并进 + workflow fan-out（cap 3-5，不狂派）

```
step[N] ─┬─ 执行线（ultracode workflow，fan-out 按文件/子任务，cap 3-5）
         ├─ 审计线（1 个 subagent CC，与执行线同时启，范围=本 step 边界，不指定问题）
         ↓
   主线程亲核（不并行派，亲手核 load-bearing 数字/file:line/口径/frame 残留）
         ↓
   step gate（§3）全绿 → 进 step[N+1]
```

- **fan-out 切分**：按文件切不按行切（同文件多 agent 改 = 文件系统竞争）；有依赖子任务串行（如 S2「删 frame」先于「Normalizer data-driven」）；Edit+Bash 分两轮（parallel-safety 保守）。
- 🔴 **逻辑并行 / 落盘串行**：S2∥S3、S4∥S5 文件域不重叠可逻辑并行，但**共享一个 git 工作树 + 一个 `make verify` 出口**（regen 重写 generated/、diff gate 全量对账）→ 并行 agent 各产 **patch/diff 草案**回主线程，主线程**串行 apply + 单次 make verify**（两个并行刀不能同时 `make regen`，generated/ 竞争）。
- **派不派 workflow 判据**（agents.md 门槛 + lessons G「狂派=混乱源」）：read-heavy + 真独立并行 + 跨 5+ 文件不确定在哪 → 派；**文档精确修正 / 单文件改 / 口径数字回写 = 主线程亲手做**。每次派前扣「这是 read-heavy 独立任务还是机械单文件」。
- **step 复杂度分级**：S0 口径=主线程亲手（仅废口径全仓 grep 可派 1 fan-out）；S1 codegen=1-2 workflow；**S2 核心重写=细切 3 刀**（删 frame / data-driven / unit test，有依赖序串行）；S3=2-3 workflow（yaml 扩/C3 派生/命名清债）；S4=1-2；S5=2（expected codegen / coverage 扩 + 主线程跑 base 验）。
- 并发 cap **3-5**（rate-limit 是基础设施限流，加额度无效；同源 GLM/codex 审计不并发 5）。

---

### 3. 分段审计：每 step【一轮】subagent 审 + 主线程亲核（过程不 loopaudit）

🔴 **磊哥铁律**：过程中每 step 只**一轮**单发 subagent 审（审完即出 verdict，**不循环**），范围=本 step 任务边界，**提示词不指定具体问题**（避免引导漏盲点）；loopaudit 仅 S_CLOSE。

**3.1 一轮 subagent 审提示词模板（只给边界，不给问题）**
```
你是 A2 step[N] 的独立审计员（异于执行线）。本 step 任务边界（只给边界，不给具体要找的问题）：
  - 目标：<本 step 一句话目标>
  - 涉及文件域：<git diff --name-only 拿到的清单>
  - 不应触及：<本 step 之外的文件/行为，如「C5/C6 本 step 不动」>
独立审计（自己判断从哪查查什么，我不指定问题）：
  1. 实跑 swift test + make verify，贴原始 stdout/exit code（不信「应该绿」）。
  2. 实跑 C6 跑 base + verify-gold，贴 receipt 路径 + sha256。
  3. 通读本 step diff，自主判断范式是否真落地 / 口径是否对 / 有无回归 / 有无越界 / 有无半写入。
输出按下方 JSON schema。每 finding 必带 file:line + 一手证据（命令输出/grep），禁凭印象/二手定性；
数字必当场 cite-verify 数据源。你全 rate-limited 或无法实跑 ≠ clean，如实标 blocked。
```

**3.2 审计输出 schema（4 维 + 越界 + 半写入）**
```jsonc
{ "step_id":"0-5", "audit_round":"single", "agent_ran_real_commands":true,  // false/blocked ≠ clean
  "verdicts":{
    "paradigm_aligned":{"verdict":"PASS|FAIL|N/A","generic_frame_removed":true,
      "removal_evidence":"grep tool_call_frame 主链路 → 0 命中 + file:line",
      "evidence_is_code_not_metadata":true},   // 真删代码≠改 removedToolID metadata（铁律1）
    "caliber_correct":{"verdict":"PASS|FAIL|N/A","intent_562":"实算+来源","device_191":"实算+来源",
      "is_intent_not_toolcount":true,           // 562 是 intent 不是工具数
      "scope_tier_landed":true},                // S0 专属:manifest 落盘 source/sha256/验证命令
    "no_regression":{"verdict":"PASS|FAIL","make_verify_exit":0,"swift_test_fail_count":0,
      "c6_base_verify_gold":"pass|fail","raw_stdout_refs":["命令+exit+receipt 路径，实跑非推理"]},
    "boundary_held":{"verdict":"PASS|FAIL","no_training":true,"no_perf_eval":true,
      "no_scope_creep":true,"recipe_ssot_untouched":true}},  // rank16Mainline/codegen 地基未动
  "findings":[{"id":"S{N}-P0-1","severity":"P0|P1|P2","file_line":"path:line",
      "claim_vs_reality":"声称 vs 事实","evidence":"一手命令/grep","fix":"…"}],
  "half_write_check":{"git_status_short":"实跑输出","untracked_generated":[],"stage_committed_consistent":true},
  "overall":"CLEAR|NEEDS-REVISION|BLOCKED" }
```
每 step 审计维度裁剪：S0 无 surface 维度（填 N/A），重审口径+scope_tier+manifest；S2/S4/S5（改 surface 的 step）必审 `paradigm_aligned`+`boundary_held`；S5 额外审「C6 base 链路通且格式对、未评 LoRA 性能」。

**3.3 主线程亲核 checklist（独立核一手，不信「subagent 说核了」）**

| # | 亲核项 | 主线程亲手动作 | 防的坑 | 频次 |
|---|---|---|---|---|
| H1 | 口径 562/191 | `python3` 实算 demo 目录 intent/device 去重计数，核 562 是 **intent** 非工具数 | finder 编数字 / 562 当工具数 | 每 step |
| H2 | scope_tier 真落盘 | `grep -rl scope_tier contracts/ generated/` 实际命中（当前=0）；核 manifest 有 source/sha256/验证命令 | 对不存在字段派生 | S0 |
| H3 | frame 真删非声称 | `grep -rn 'tool_call_frame\|frameToolSchema' Core/` 主链路 0 残留；核 `:2344` 是真删代码不是改字段值 | 铁律1；drift gate 不报 compiler-derived 债 | S2/S4/S5 |
| H4 | test/verify 真绿 | **主线程亲跑** `swift test`+`make verify` 看 exit code，不信「应该绿」 | 铁律2 receipt≠实跑 | 每 step |
| H5 | C6 base 真跑 | 亲核 base receipt sha256+命令+每轴数；action hard_pass base **10/23** 按 case schema 字段拆非 case_id prefix | 铁律3 顶层聚合掩盖子轴 | S_INIT/S5 |
| H6 | file:line 现行有效 | `sed -n` 抽样核 subagent 引的 file:line 内容真在该行 | 凭印象/失效引用 | 抽样 |
| H7 | 半写入对账 | 亲跑 `git status --short`，核生成物已 stage、无未跟踪漂移 | OpenSpec archive 半写入坑 | 每 step |
| H8 | diff gate 真纳新产物 | 核 D-domain 目录 + `generated/10-family-device-map.json` 已进 diff gate 路径（**当前 generated/ 裸奔，本机已核**） | 新硬编码逃 drift gate | S0/S1 |

---

### 4. 监控：进度可见 + 偏离检测信号表

进度用 /goal 状态机（当前 step + 已 gated 数 + commit 分离计数 + 累积 diff 手写/生成物行数）。**偏离信号见红/橙即停回修**：

| 信号 | 检测命令/动作 | 含义 | 动作 |
|---|---|---|---|
| 🔴 越界训练 | grep diff 是否含跑权重/调云 generator/生成语料(.jsonl/metrics.jsonl/checkpoint)/跑 judge | 越 A2 边界（最易越界点） | 停，DEFERRED 不在 A2 |
| 🔴 越界评性能 | C6 是否跑 LoRA/建四层门 | 越 A2 边界 | 停，只跑 base 验格式 |
| 🔴 frame 未删干净 | `grep -rn 'tool_call_frame' Core/` 主链路 >0 | generic frame 残留（**drift gate 不报，本机已核**） | 显式移除 + 异源 + 主线程核 |
| 🔴 口径 drift | `make verify` cross-section 报 caliber_violation；或主线程 python 复算 ≠ 报值 | 562/191/976 写错或分叉 | 停改；B1 扩 BASELINE_GLOBS 兜底 |
| 🔴 562 当工具数 | grep codegen 是否生成「562 个工具」 | 口径错全链路 | 停，562 是 intent；工具数 G2 实算 |
| 🟠 半写入 | `git status --short` 有未跟踪生成物 / make 报 No files changed 实已写 | OpenSpec archive 半写入坑 | git 对账重跑 |
| 🟠 scope_tier 缺位 | S0 后 `grep scope_tier` 仍 0 | codegen 无合法口径源（硬前置） | S0 未完不进 S1 |
| 🟠 配方被改 | `git diff Core/Training/C5LoRATraining.swift` 命中 :1175/LR/adamw | 重开配方混淆变量 | 守现状，撤回 |
| 🟠 scope creep | diff 含本 step 边界外文件/重命名（非命名清债） | behavior-changing 混入 | 只迁 surface 不夹带 |
| 🟡 大爆炸刀 | 单刀 diff 同改 surface+训练+bench / 触 GENERATED+2+ Core 文件+跨 step | Netscape 红 flag | 拆刀 |
| 🟡 类型检查器爆炸 | swift build 出 expression-too-complex/timeout | 生成大字面量无类型标注 | 生成器 emit 显式类型+拆字面量 |
| 🟡 Reports 膨胀 | `du -sh Reports`（现 2.8G） | 产物污染仓 | 中间产物落 raw/.gitignore |

**enforce 覆盖补强（B 段，边重构边落，补本机已核 3 漏点）**：B1 扩 `BASELINE_GLOBS` 纳 `CLAUDE.md`/`docs/srd-*.md`/`baseline-semantic-protocol-2026-06-19.md`/`CONTEXT.md`/`docs/research/INDEX.md`（扩前废口径行标 SUPERSEDED 避误报）；B2 S0 新口径（工具数实算/族外 device）加 `CALIBER_ANCHORS` 单值锚；B3 scope_tier 单源从 S0 manifest 派生纳 diff gate；可选 `make verify-swift` 把 `swift test` 机械化进 Makefile。🔴 **enforce 边界**：cross-section 只查 drift 不查 correctness、**验不了 frame 真删** → 必主线程亲核（H3）+ 异源补，别让 make verify 绿成「假绿放行」。

可选机械门（补 drift gate 盲区，A2 期临时挂 make verify）：`a2_boundary_guard.py`（扫新增训练语料/checkpoint/云 endpoint → exit1，防越界）+ `frame_residue_check.py`（grep 主链路 `tool_call_frame`/`frameToolSchema` 残留 → exit1，补 drift gate 对 compiler-derived 债不报的盲区）+ **generated/ 纳入 diff gate**（本机已核当前裸奔，S1 必补否则新硬编码逃逸）。

---

### 5. 整体推进：依赖序编排 + incremental 分刀 + step close protocol

**5.1 依赖序硬约束（违反=返工）**：`[0]→[1]→[2]→[3]→[4]→[5]`，其中 `[0]→[1]→[2/3]` 严格串行（[1] 消费 [0] manifest；[2] 消费 [1] JSON）；`[2]∥[3]`、`[4]∥[5]` 文件域不重叠可逻辑并行但落盘串行（§2）；合流门 = [4][5] 起手前 [2]∧[3] 都 `swift test`+`make verify` 绿。

**5.2 incremental 分刀（防 Netscape 大爆炸）**：一刀=一个 step 内独立可验收单元，绝不一刀同改 surface+训练+bench；每刀后三必绿（`swift test` 0 fail + `make verify` 绿 + S5 起加 C6 base verify-gold）；每刀=「手写 commit + 生成物 commit」两原子 commit 作回滚锚。S2 核心重写最危必细切 3 刀（删 frame / data-driven / unit test）。**strangler 不变量**：删旧 surface 那刻新 surface 已由前 step codegen 产出且 compiler 能消费 → 链路零中断窗口；删旧前并存可跑（双 surface 共存期=合规中间态）。中途每 step 跑 C6 base 当活体检验（防塌缩不等终局）。

**5.3 step close protocol（每 step/每刀末固定 7 动作，缺一不算收口）**：
```
1. review diff（逐块看，确认只迁 surface 不夹带）
2. git stage 分两组：a) 生成物组(generated/ + regen 的 contracts/) b) 手写组(Core/*.swift + scripts + Makefile + 手写 yaml)
3. make verify（含 git diff --exit-code 漂移门；绿才继续，红→回 step 修）
4. swift test 0 fail（S5 起加 C6 跑 base verify-gold pass）
5. git status --short 对账（防半写入；必须干净）
6. commit 分两次：a) "chore(codegen): regen D-domain surface (step[N])" b) "<type>: step[N] 手写逻辑"
7. 完整性 gate：对账「本 step 计划 modify 的文件 vs git diff 实际改的」——标了没改=执行 gap（补执行，不进审计循环）
```
（stage 分两组**先于** commit：make verify 的 diff gate 是 `git diff --exit-code`，先 stage 才验「暂存态=重生成态」一致。）

**5.4 失败回滚**：可前修（编译错/test fail/口径错）→ 留本 state，write-test-fix 内循环修不回滚；子任务 X 坏 Y/Z 好 → 仅 `git checkout -- <X>`；整 step 方向错 → `git reset --hard <Sn-1 已签 commit>`（旧路径 strangler 残留仍可跑）。每 step 末打 tag（`a2-step0-done`…）作粗粒度回滚点。

**5.5 step gate（进下一 step 的硬门，合取全绿）**：① 审计线 verdict=CLEAR（NEEDS-REVISION 回修；BLOCKED/全 rate-limited≠clean，重派）② 主线程亲核（§3.3 该 step 必核项）全过 ③ 三门绿（swift test 0 fail + make verify 绿 + C6 base verify-gold）④ 半写入对账干净 + 生成物/手写 commit 分离 ⑤ 本 step P0/P1 全修 ⑥ §4 红/橙偏离信号 0 命中。修复守**收敛定律：修复范围 ⊇ 审计范围 ⊇ 执行范围**。

**5.6 agree-before-build**：archived spec（C1/C2/C3/C6）MODIFY 走 OpenSpec change `migrate-d-domain-tool-surface`（DRAFT→propose 对齐→apply），**不直接改 archived**；其余 3 change（retrain-c5/rebuild-c6/golden-run）保持 DEFERRED banner 在位。

---

### 6. 收口：loopaudit 仅整体最终用（6 step 全 gated 后）

🔴 **过程每 step 只一轮审；loopaudit 开放式循环审计至无 P0/P1 仅用于 A2 全 6 步完成后的整体最终收口**（每 step 跑 loopaudit = over-engineering + 6 倍阻塞）。

- **触发**：A2 全 6 step gate 全绿 + 各 step P0/P1 已清。
- **形式**：`loopaudit` skill，targets = A2 全量代码产出（generated/D-domain 目录、state-cells.yaml、ToolContractCompiler/C5LoRATraining/C5TrainingCLI/C6VehicleToolBench/DemoVehicleStateStore/FastPathIntentEngine/C3ExecutionPipeline、gen_tool_contract.py、S0 manifest、migrate change）；scope = 一句话范围**不列问题**（开放式核心）；维度 ≥3 subagent（默认 10 维 + A2 专补：范式对齐/frame 真删/口径全仓/不退化/边界守/data-driven/健壮性/commit 分离/archived 走 change/历史档 vs 活基线）；perAgent=3（PANEL≈4）；maxRounds=5；outDir=`docs/research/2026-06-23-a2-loopaudit-closeout/`。
- **收敛定律强制**：修复 targets 动态 = 初始 ∪ findings location 涉及文件；执行后完整性 gate 先于审计（标 modify≠已 modify → 补执行不进循环）；finding 分两类（产出 bug→Edit 修 / 执行 gap→补执行）；反复报同口径问题不收敛 → `dispute-triage` 分诊，口径型（562 vs 旧 534/2086）**上抛磊哥拍板非无限核**（562 已终拍，遇旧值是历史档判定，标 historical 不改正文）。
- **防假 clean**：`panelOk`（≥半数 agent 成功非空才认 clean，全 rate-limited/空 ≠ clean）；clean = panel 足 AND 零 P0/P1；**主线程亲核覆盖审计漏点**（loopaudit 报 clean 后仍独立 grep 主链路 `tool_call_frame` 残留 + 抽样核 D-domain 工具名是否真从 codegen 派生 + python 复算口径）；异源加分（panel 内掺 1 个 hermes/GLM-5.2 破同 family bias，尤其核 frame 真删 vs drift gate 不报的 compiler-derived 债）；留痕 `round-NN/audit-i.md`+`fixes.md`+`ledger.md`。
- **判据**：`clean=true`（一轮零 P0/P1，panel 足）→ 进 §7；`STOPPED@5` → 如实报磊哥剩余 P0/P1 别假 clean，不收敛根因若口径型 → 上抛拍板。

---

### 7. A2 完成判据（code 层验收门，非模型性能；每条主线程亲核一手）

| # | 验收门 | 核验方式 |
|---|---|---|
| 1 | surface 全 D-domain，`tool_call_frame` generic frame **显式移除** | grep 主链路无残留（异源+主线程核，非靠 drift gate） |
| 2 | ToolContractCompiler data-driven 消费 generated JSON，无硬编码 if-else surface，有 unit test | Read 确认无 `dDomainSurfaceNames` 硬编码 + `swift test` 含 compiler unit test 绿 |
| 3 | scope_tier/allowlist manifest 落盘（source/sha256/验证命令）+ 纳入 diff gate | 文件存在 + make verify diff gate 覆盖 |
| 4 | C5 生成器**代码能产** D-domain shape（CLI `--scope`/`--surface` 可用）；**未生成语料、未重训** | CLI 跑通产 shape + grep 无云 generator/训练触发（边界守） |
| 5 | C6 expected 全 D-domain + 10 族 191 device coverage；**跑 base** verify-gold pass + A2-before baseline receipt freeze；**未跑 LoRA 评性能、未建四层门** | C6 base 跑通 + receipt freeze（每轴 base 数 action hard_pass base 10/23）+ grep 无 LoRA 评测/四层门 |
| 6 | state-cells 10 族 191 device + C3 映射派生 + 命名清债（无 hvac.ac 双轨） | grep `hvac.ac` 主链路 0 + state-cells device count=191 |
| 7 | 口径全仓 562/191/976 统一 | cross-section 扩 BASELINE_GLOBS 后 make verify 绿（B1/B2 落地） |
| 8 | `swift test` 0 fail + `make verify` 绿（**每 step 都绿非只终局**） | 每 step close protocol 留痕 + 终局全跑一次 |
| 9 | 生成物 commit 与手写 commit 分离；archived spec 走 migrate change | git log 确认分离 + archived 无直接改 |
| 10 | 起手归档全引一手（口径用终拍 562 非 README 正文 534/2086） | 主线程亲核所有 load-bearing 数字源 |
| 11 | lessons-learned 持续追加；loopaudit 整体收口至无 P0/P1 留痕 | `docs/lessons-learned.md` + loopaudit ledger.md clean |

> **元洞察（pre-mortem 收敛）**：A2 的失败 7 类（越界/frame 没删/假 clean/标 modify≠已 modify/scope_tier 对不存在字段派生/半写入/口径漂）同根 = **「声称层 vs 事实层脱节」的不同变体**——本项目代码自己就是活样本（`:2344` metadata 声称删 vs `:2362` 仍 emit）。harness 核心防范 = **机械门补 drift gate 盲区（frame_residue/boundary_guard/generated 进 diff/口径锚扩）+ 行为门取代状态字段 + 主线程亲核一手**，enforce 降低对自觉依赖但不替代「写每个数字时」的扳机。