# C5 Recovery Grill — Amend：G6-C surface ablation 实验设计（三方 CC/GLM/codex 综合定稿）

> 🔴🔴 **SUPERSEDED-BY `grill-decisions-amend-paradigm-tool-surface.md`（2026-06-22 范式翻案，pending SSOT reconciliation）**：本文档的 **D-vs-B 对照框架已作废**——第4源（真实座舱 TOP技能表）坐实 model-visible surface = **D-domain 具名工具**（generic frame 否决），不再跑 D-vs-B。G6-C 重定义为「canonical IR(device×action) + 具名工具是否同源/可训/可执行」三层验证，cell 待 SSOT 对账（paradigm amend grill A1）后重设。**勿按本文档旧 D-vs-B 框架执行。**

> **as-of**: 2026-06-22 晚（θ-α confounded 后，G6-C tiny 对照实验设计 grill；助理 A=GLM-5.2 / 助理 B=codex）
> **本文档 = G6-C 实验设计定稿**（grill-with-docs engineering-contract mode）。是 `grill-decisions.md` **A1（D-vs-B tiny ablation，`:139`）的 amend 执行细化**——drop B 为既有 anchor + 补 distractor 维度 + multi-checkpoint + 诊断门。
> **权威边界**：G6-C 设计以本文档为准；根因定向见 `grill-decisions-amend-theta-alpha-rootcause-grill.md`；A1 原决策被本文档 amend（§6）。
> **verify 纪律**：codex 关键 cite 已 verify 坐实（§1）；GLM entropy 数字已脚本复核纠错（§1.3）。

---

## §1 verify（grill-with-docs：验 artifact 不信 chat）

1. ✅ **codex tiger 坐实**：`Core/Training/C5LoRATraining.swift:2362` = `C5TrainingToolCall(name: "tool_call_frame", ...)` 硬编码；grep 全文件**无 d_domain / surfaceVariant 切换点**（仅 `toolCallFrameToolSchema`）→ **G6-C 硬前置 = C5 training renderer 支持 `target_surface_variant=d_domain`（从 ToolContractCompiler 派生），非 PR2 闭合**。🔴 **GLM 整份 yaml 漏此**（假设能训 D 但代码硬走 B-frame = cite-verify 失守）。
2. ✅ **A1 坐实**：`grill-decisions.md:139` A1 原 = D-vs-B ablation（唯一变量 target_surface_variant，D/B 都 Compiler 派生，blocked_by=[G4_DATA_FIX_ABLATION_PASS, VERIFY_GOLD_100]）→ **drop B = 修订 A1（§6 amend）**。
3. ❌ **catch GLM entropy**：GLM 称 base entropy 1.93 bits；脚本复核（`c6-base-full/spike-e3-results.json` `.results[].toolCalls` 分布 `window12/ambient6/ac6/fan4/screen2/seat2/query1`）= **2.437 bits**。alarm 门基线用 **2.44**（跌>50% = <1.22）。base trigger **33/57** GLM 对。

## §2 硬前置（先于 cell 设计，三方未全顶到）

- **P0（codex tiger）**：C5 training renderer 支持 D-domain 输出（当前 `:2362` 硬走 tool_call_frame）。🔴 **CC elephant：此前置 ≈ G6-A（训练改 D-domain）核心实现** → G6-C 不是 G6-A 的替代选项，是它的「先 tiny 验证」版；C1 验证 work 则 full train 直接 = G6-A。
- **P1（A1 继承 blocked_by）**：`VERIFY_GOLD_100`（已满足：completion-audit gold_replay 57/57）；`G4_DATA_FIX_ABLATION_PASS`（PR2 partial，θ-α 数据已 prepare）。

## §3 cell 表定稿（2 anchor 不重训 + 3 D cell + 1 条件）

| 类 | id | train surface | eval | distractor | checkpoints | 测什么 |
|---|---|---|---|---|---|---|
| anchor（不训，引既有）| `A0_base` | — base only — | D-domain | — | base | LoRA 是否破坏 base（基线 trigger 33/57 · entropy 2.44 · action 10/23）|
| anchor（不训，引既有）| `A1_BD_cross` | B-frame | D-domain | 错域(nav/music) | 既有 iter100/400/600 | 复现本次失败（全 0/23）|
| **cell（命门）** | `C1_DD_cross` | D-domain | D-domain | 错域 | 50/100/150 | **surface 对齐能否恢复 trigger（证伪 surface 主因关键）** |
| cell | `C0_DD_none` | D-domain | D-domain | 无 | 50/100/150 | distractor 整体毒性基线 |
| cell | `C2_DD_same` | D-domain | D-domain | 同域(跨工具同 D-prefix) | 50/100/150 | distractor 域反噬权重 |
| 条件 | `C4_BB` | B-frame | B-normalized | — | — | **仅 C0/C1/C2 全塌才追加**（需 PR2 normalizer 闭合）|

- A0/A1 anchor 引用既有数据（`c6-base-full/` + `generated-positive-data/`），**不重训**（codex catch GLM C3 重训浪费）。
- 3 D cell × 3 ckpt = 9 次 C6 eval；distractor 三档 none/cross/same（codex no_distractor 基线 + GLM cross/same）。

## §4 配方 / subset / monitors

- **配方守住不破**（三方一致）：`rank16 / scale20 / lr1e-4 / warmup0.08 / grad_clip1.0`（`rank16Mainline` SSOT）；只缩 iter。scale 是独立题（列 G6-D，G6-C 不测，防污染 surface 变量）。
- **subset**：600–768，**stratified by route_tier**（保持 fc_l2:fc_l3:rule_l1 ≈ 2781:939:298，防 subset 偏移）。
- **monitors（每 ckpt）**：`action_axis_without_readback` / `positive_trigger_rate` / `negative_false_calls` / `tool_name_entropy`（Shannon，base 2.44）/ `d_tool_coverage`。

## §5 success_gate 分层 + anti-confirmation

**分层（codex，禁 train-health/diagnosis/candidate 混层）**：
- **diagnostic（G6-C 用）**：`trigger≥50%(≥25/57)` AND `action≥5/23` AND `d_tool_coverage≥4` AND `neg_false_calls≤base+2` AND `no_collapse_in_any_checkpoint`。
- **candidate（仅 full train）**：`action_hard_pass > base 10/23`。

**判据数字（综合 GLM Q4，门设计值非实测）**：
- C1 **surface 主因坐实**：trigger≥25/57 + action≥5/23 + entropy≥1.5。
- C1 **surface 非主因（证伪）**：trigger<15/57 或任一 ckpt 闭嘴 + action<2/23 → 转查 LoRA 强度（G6-D scale）。
- C2 vs C1：`Δtrigger≥5/57` → 错域反噬坐实（§5#4 distractor 硬规矩升级）；`|Δ|<3/57` → 反噬 weak（GLM 根因 B 权重下调）；C2<C1 → 同域反拖累，翻案 θ-α 用错域。

**anti-confirmation hardgate（GLM，写进 yaml）**：
- 每 cell 3 ckpt 任一闭嘴（trigger=0）→ 标 `collapse_observed`，禁只看最好 ckpt 报通过。
- 任一 cell entropy 比 base 2.44 跌>50%（<1.22）→ 标 `flattening_observed`，verdict 显式。

## §6 A1 决策 amend（codex elephant）

🔴 `grill-decisions.md` **A1（`:139` D-vs-B tiny ablation）被本文档 amend**：
- 原 A1：D-双层 vs B-frame 对照（唯一变量 target_surface_variant，两个都新训）。
- **amend**：drop B 新训 → B 降为 **既有 anchor `A1_BD_cross`**（本轮 generated-positive 已是 B→D×错域全 0/23，不重训）+ B 可学性测降为**条件 cell `C4_BB`**（仅 C0/C1/C2 全塌才追加，需 PR2 闭合）。理由 = §1 steelman 留 B 5 因全驳（demo 不要范式论文）+ B 失败已有数据。

## §7 辩证账（不迎合 · 双层）

- **采纳 GLM**：multi-ckpt 测曲线（漏洞2）/ base no-train 锚（漏洞1）/ entropy 量化（基线用复核 2.44 非 1.93）/ 同域=跨工具同 D-prefix（漏洞3）/ steelman B 全驳。
- **采纳 codex**：真前置 D-domain renderer（verify 坐实）/ B 用既有 anchor / no_distractor 基线 / 诊断门 vs candidate 门分层 / A1 amend / oracle（Qwen FC、Together fine-tuning 支持 surface 对齐先行）。
- **catch GLM**：① 漏真前置 renderer（最严重，yaml 跑不起来）② C3 重训浪费 ③ 漏 no_distractor 基线 ④ entropy 算错 1.93→2.44。
- **catch codex**：① 2 ckpt(80/150) 不够描"调对→塌→闭嘴"曲线（采 GLM 3 点）② 漏 base no-train 锚。
- **CC elephant**：① G6-C 真前置 ≈ G6-A 核心（非替代选项，是 tiny 验证版）② A1 已存在 + blocked_by 继承（三方没 check）。
- **CC steelman 自己**：surface 主因是假设，C1 multi-ckpt 是证伪关键（iter100 调对 iter150 闭嘴 → LoRA 强度非 surface）；C1+C0_none+base锚+multi-ckpt 四件一起才干净归因。

## §8 post-G6C + 级联

- **post-G6C（GLM）**：PR2 `ToolContractNormalizer` 硬编码 D-domain（lessons #14/#33 0/34 同坑）→ **闭合作 G6-D 入口**（不阻塞 G6-C，closeout 即触发）。
- **若 C1 诊断门过**：full train D-domain = G6-A 落地（§2 elephant）→ 走 candidate 门（>base 10/23）+ parity + 真机。
- **级联**：本设计定稿后 → `grill-decisions.md` A1 段标 `AMENDED-BY-g6c-design`；`execution-gap §D0` 指向本文档；待 G6-C 跑出再级联实验结果 + experiment_validity。

## §9 给三方的开放 grill 点（喂回 GLM/codex 终审）

1. **subset 600（GLM）vs 768（codex）**：取哪个？或折中（按 route_tier 分层后取整）。
2. **C4_BB 触发条件**：codex「C0/C1/C2 全塌才追加」—— 若只 C1 塌但 C0/C2 部分活，要不要追加 B？（边界）
3. **diagnostic 门 trigger≥50% vs action≥5/23 哪个优先**：tiny 短 iter 下 action 可能滞后 trigger 恢复——是否 trigger 先达标即算 surface 假设初步成立？
4. **真前置（D-domain renderer）工程量**：codex 估 `training_surface_switch_d_domain` + `surface_triplet_probe`，需 codex 给具体改动点 + 是否复用 ToolContractCompiler 已派生的 D_domain.tools.json。
