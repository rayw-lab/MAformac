# θ-α 执行派单提示词（直接扔给 codex）

> ⚠️ **HISTORICAL 快照（2026-06-22）—— 文档级联 banner（2026-06-23）**
> 本文是 θ-α 执行的派单提示词中间态历史快照（已执行，generated-positive 全 checkpoint 实测 FAIL，见 `docs/lessons-learned.md #49`）。范式翻案后 θ-α 根因深挖 = generic frame 判定面爆炸 → D-domain 具名工具（见 `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `grill-decisions-amend-theta-alpha-rootcause-grill.md`）。**活基线** = `CLAUDE.md §9` + grill-decisions + paradigm-amend。正文保留供溯源，勿据此重新派单。

## 0. 起手必读秩序

**读路径**（绝对路径，按顺序，权威优先）：

1. ⭐⭐ `/Users/wanglei/workspace/MAformac/docs/c5-recovery-2026-06-22/grill-decisions.md` — 推理唯一 SSOT，含 η-scope-split[L345] + θtrain-recipe-baseline[L359] + α[L220] + G5-G9[L191] + ε[L253] + ζ[L298] + δ[L275]
2. ⭐ `/Users/wanglei/workspace/raw/05-Projects/MAformac/dispatches/2026-06-22-c5-theta-alpha-execution-dispatch.md` — 三件套任务单（100 行，自包含）
3. 配方 SSOT：`/Users/wanglei/workspace/MAformac/Core/Training/C5LoRATraining.swift:1164 rank16Mainline()`（**别再调参**：rank16/scale20/lr1e-4/warmupFraction0.08/gradClipNorm1.0/adamw/wd0.01/epochs3）
4. 契约 SSOT：`/Users/wanglei/workspace/MAformac/contracts/semantic-function-contract.jsonl`（3990 全集，能力层兜底）
5. 训练后端：`/Users/wanglei/workspace/MAformac/Tools/C5TrainingCLI/{main.swift, c5_mlx_train_loop.py, c5_mlx_train_loop.verification.json}`（clip/metrics/marker 已 verified，2026-06-22T00:34 sign）
6. home-llm 参考线：`/Users/wanglei/workspace/raw/05-Projects/MAformac/ref-repos/home-llm/docs/experiment-notes-phi.md`（3 epochs，4th overfit）

**❌ 不读**：`exec-plan.md` / `roadmap.md §1.5` / `8d-rootcause.md D4-D6` / `grill-checklist-30.md G1-G32`——这些顶部有 grill 级联 banner，但旧段是 grill 演进痕迹非执行依据，读它们会引回 D-fix E0-E5 老路径。

## 1. θ-α 三件套（纯语义 positive 闭环第一刀）

`dispatch.md` 已全在。三件套 = **PR1 name-first ∥ PR2 compiler-scaffold → PR3 θ-α-data**（PR1/PR2 并行，PR3 依赖 PR2）。

**PR1 name-first**：`C5LoRATraining.swift:2407-2414 C5CanonicalJSONObject.render` 拆用途——assistant tool_call payload 显式 ordered `[name, arguments]`（喂模型学，name-first 顺 Qwen3 chat_template）；canonical hash 用独立规范化层保留 sorted（不依赖 Dictionary/JSONEncoder 偶然序）。验收：① 渲染出的 payload 首 key=`name`（grep 实际渲染文本断言，非字段声称）② canonical hash 同输入同 hash ③ 单测覆盖 ④ `make verify` 过。

**PR2 α compiler-scaffold**：`C6VehicleToolBench.swift:1163-1176` 硬编码 `switch call.name { case "set_cabin_ac"... default: continue }` 替成 applier 派生（任何 surface → 内部 IR `device×primitive×value` → state mutation）；`C5LoRATraining.swift:1942 toolCallFrameToolSchema` 改从 `semantic-function-contract.jsonl` 派生；Makefile `regen` target 接入 ToolContractCompiler；routeTier 走 RouteDeriverV2（D1 段 inputs 去 exec_tier 加 value.type）。验收：① D/B 两 surface 都从 contract 派生（grep 无第二套硬编码）② applier 对 D-domain + B-frame 都算 state_delta（单测）③ surface-consistency check 过 ④ verify_gold=100%（gold apply 不退化）。

**PR3 θ-α-data**：跳过 `buildNoCallSamples`（`C5LoRATraining.swift:1977/2327`），build options 设 `refusal_ratio_target=0` 或跳过 :1977 调用（自主选干净落点）。纯 positive 数据（θd-1 派生骨架 + 云多源 LLM 增广，规模 4-5k 参考 P1-C Q11），保留 **When2Call distractor-in-prompt**（θ-α tiger：prompt 塞工具集没有的干扰工具教「没有就别调」，非 refusal 样本不引入 negative loss）。配方 `rank16Mainline()` 直接用，iters 按数据量 spike（home-llm 3 epochs，4th overfit；rank16Mainline epochs=3 已对齐）。验收：① 数据零 NO_TOOL/refusal（grep 断言）② lineage parent_semantic overlap=0 ③ tiny run 跑通（marker 已 verified repo loop）④ C6 `action_hard_pass(剔readback) > base 10/23`（ζ 相对门）⑤ metrics.jsonl 监控 `empty_rate>0.15 / wrapper_drift>0 / IrrelAcc≥base 0.789` 三件套早停 ⑥ receipt 记 iters/epochs 实测 + home-llm 参考线对照。

## 2. 🔴 红线（别越界做成 θ-β）

- 不训 safety 拒识 / ASR 澄清 / out-of-toolset 拒识 / ambiguous 澄清 / NO_TOOL（这些 θ-β 第二刀，θ-α 做了就污染单变量、重蹈 0/34 negative 压倒 positive）
- 安全靠 `contracts/risk-policy.yaml` 规则门 codegen + DemoGuard 白名单（不入 LoRA，"安全检查是代码不是 prompt" 铁律）
- readback 走 renderer 方案 P（不入 LoRA；`C6VehicleToolBench.swift:1039 failures.append(.readback)` 删除是 ε 决策另派单，**本三件套不碰 readback eval**；gold path `:865` 不改）
- candidate 维持 UNSIGNED/BLOCKED（θ-α 是地基不签 candidate，签发走完整 C6/parity/真机/异源终审）

## 3. claim-vs-reality 四铁律（避开 CC 这几轮的坑）

参 `~/.claude/rules/claim-vs-reality-gap.md` 十变体：

1. **配方数字 → grep 代码工厂方法**：`config.yaml/receipt/log/snapshot` 都是代码渲染的产物非 SSOT。引用任何配方数字回 `rank16Mainline:1164` 核
2. **核实际文件/实跑 ≠ 核代码静态分支**：`verification.json` 已 sign 状态 ≠ `main.swift:324 missing_verification_marker` 那条静态分支
3. **不凭转述**（含「对方亲核了」）：引用自己回读一手 file:line
4. **双层 check**：(a) 验证型（对吗）(b) 发现型（漏什么 gap/边界/成本），审任何结论（含自己的）别只验证就走

## 4. 留痕 + 收口

每 PR 独立 receipt：① 回读了什么（file:line）② 发现 gap ③ 遇坑怎么判 ④ surface 什么 ⑤ 失败如实（risk_state）。每 PR + `make verify` 门。三件套都 done 后磊哥审（异源 + 实跑复算，不只读 receipt）→ 更新 grill-decisions「α 已实装」。重大不可逆 surface 磊哥。
