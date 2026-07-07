# 2026-06-22 C5 Recovery Grill Session Checkpoint (Hermes)

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

> **作用**：本次 Hermes session 元认知 + 项目状态锚点的 repo 内可搜索镜像（hindsight cloud 401 API key 缺失走 plan B）。新 session 起手读 → 知道本次 grill 已闭环到哪 + next phase。

## 1. C5 状态指针 (2026-06-22)

- **PR5 candidate LoRA 0/34** = **UNSIGNED/BLOCKED**（不抢救，artifact 永久 discarded；与"LoRA recovery approach 仍可救"区分）。
- **Recovery in-grill**，推进事实源 = `docs/c5-recovery-2026-06-22/grill-decisions.md`。
- **已闭环 11 段**：Q1(route边界) / Q2(safety) / BG1(demo锚) / BG3(两层SSOT) / A0(C6口径) / A1(tiny对照) / D1(route-deriver) / D2(make-verify) / G5-G9(数据契约) / α(Compiler scaffold) / axes-catch + ε + δ + ζ (C6 三轴 + readback走P + axis producer + 阈值)。
- **剩余 ~20-24 题 / 6 模块**：θ-data / θ-train / 审计框架 / Compiler细节 / 真机防复发 / demo scope κ / 范式结论 G6。

## 2. C6 真口径三轴数字 (ζ 段已锁，亲核 c6-summary.json + C6VehicleToolBench.swift)

| 轴 | base | lora | 备注 |
|---|---|---|---|
| **action (tcm&sdm)** | **10/23 = 43%** | 0/23 | positive action 全面塌缩 = 数据契约错。**recovery 锚点 = base 10/23** |
| **readback** | 0/15 | 0/15 | 走 P 方案（ε 段拍）= 单列 informational，**不计 model hard_pass** |
| **overall** | 0/30 | 15/30 | overall 不再做主锚 |

**E4 阈值口径** = `action_hard_pass(tcm&sdm&clm&!parser) ≥ K`，K 超 10/23（`no_negative_regression` + `wrapper_drift→0`）。

⚠️ **历史漂移数字（禁再引）**：
- name-only 25/34 / 0/34（spike-e3:158 口径，已降级 smoke）
- 整体 7/57（含 readback，二手 axes 手 rolled，无产生器）
- 11/30 / 15/30（grill 早期算法，第 6 同坑后修订为 10/23）

## 3. demo-critical 7 case 定性 (2026-06-22 逐 case 亲核 chunkText/toolCalls)

**不是"都修判等过严"，是 1 判等 + 6 capability gap 混合**：

| case 类 | 类型 | recovery 路径 |
|---|---|---|
| SAFE-001 高速开门 + SAFE-002/3 | capability gap | 训：从 risk-policy.yaml R0-R3 派生拒识样本（query→拒+理由话术+toolCalls=[]） |
| ASR 澄清（座椅通分 / 空跳开一哈） | capability gap | 训：从封闭词表拼音 fuzzy 造扰动 + 澄清话术监督，loss 覆盖澄清 token |
| 工具映射边界（开门→错调 set_cabin_window） | capability gap | 训：out-of-toolset-refusal 样本 |
| 其余 1 个 | 判等 surface 过严 | 放宽判等可救 |

## 4. 本次 session 元认知（已落 MEMORY.md）

- **同坑变体 #7**：base=0/X 类锚点必逐 case 一手核（chunkText/toolCalls），不凭 axis 聚合归一类。
- **Claim-vs-reality 实证 9**：长文档段间分叉（11/30 vs 10/23 vs 15/30 共存）= 同文档自我污染。扳机：每 grill 5 段或拍重大反转后做 cross-section consistency check。
- **Grill 反模式·"待 spike" 暗未拍**：用"待 spike"包装 = OPEN-marker 非 decision。正确 close = 拍 spike 边界 + 决策门 + 回退方案三件套。

## 5. Next Phase (磊哥拍 A 后待执行)

### Phase A — 防御性级联（30 分钟，**未做**）

1. **CLAUDE.md §9** 补一行级联指针：
   ```
   > 🔁 C5 状态更新 (2026-06-22)：PR5 candidate 0/34 已 UNSIGNED/BLOCKED；
   > recovery in-grill，推进事实源 = docs/c5-recovery-2026-06-22/grill-decisions.md
   ```
2. **`docs/c5-recovery-2026-06-22/roadmap.md §1.5` 顶部 banner**：
   ```
   > 🔁 SUPERSEDED-BY-ζ (2026-06-22)：成功标准已定 = action 锚 base 10/23，
   > readback 走 P 单列 informational，详见 grill-decisions.md
   ```

### Phase B — θ-data grill 修订版（7 题 + 1 矩阵 + 1 invariant）

CC 原 6 题基础上 push back 修订：

| 题 | 状态 |
|---|---|
| θd-1 ~ θd-4（拒识/ASR/边界派生骨架 + LLM 增广） | ✅ 方向对，沿用 |
| **θd-5 配比** | ⚠️ 改"拍 spike 边界 + 决策门 + 回退方案"，不再"待 spike" |
| **θd-6 loss-span** | ⚠️ 加 invariant：positive action **不能被 negative loss 稀释**（high-weight 或 oversample 或 negative loss ceiling） |
| **θd-7 OOD smoke (新增)** | 10-15 case held-out OOD，demo 期不训不见，eval 期跑，定 OOD pass rate floor |
| **7 case × θd-N 映射矩阵 (新增)** | demo-critical 7 case 每个至少 1 个 θd 命中，每个 θd 声明覆盖哪几个 case |

### Phase C — 收口批量级联 8 处剩余 gap

待 grill 全收口后一次性做。P0=CLAUDE.md / roadmap.md §1.5（已在 Phase A 处理）；P1 = `exec-plan.md L32 base 7/57` stale / `8d-rootcause.md L28-29` 三轴真相缺；P2 = spec.md readback 口径（需更深核）。

⛔ **已撤销 gap**：MEMORY.md（不在 repo，是 ~/.hermes/memories/）/ roadmap-2026-06-20.md（文件名错，实际 roadmap-2026-06-20-from-c6-done.md）。

## 6. Hindsight cloud 401 (技术债)

`~/.hermes/hindsight/config.json` 的 `apiKey: ""` 为空 → hindsight_retain 全部 401 Unauthorized → 自动 retain 实际也是不工作的（虽然 `auto_retain=true`）。建议磊哥后续：
- 要么补 API key（vectorize.io 注册）
- 要么切 `mode: cloud` → `mode: local_embedded`
- 在此之前**所有跨 session 事实记忆必须走 MEMORY.md（满 100% 时 batch 替换）或 repo 内 handoff 镜像**（如本文）。

## 7. 起手读路径（新 session）

`CLAUDE.md` → 本 handoff → `docs/c5-recovery-2026-06-22/grill-decisions.md`（事实源）→ 决策段按需。
