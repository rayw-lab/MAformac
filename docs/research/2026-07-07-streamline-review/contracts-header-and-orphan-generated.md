# B1c/B1d 预研：contracts header 矛盾澄清 + orphan generated 定性

status: `RESEARCH_ONLY`（零 commit 权，只写本档；禁动 contracts/ generated/ 原件）
by: hermes glm-5.2 (pane %31, B1c/B1d 预研)
spec: 执行单 B1c/B1d 预研（commander 派单，零 commit）
cwd: `/Users/wanglei/workspace/MAformac`
head: `03526e76986310846f5f6b255a2dcfc8b87c2b8c`
basis: live repo probe 2026-07-07 + W3 盘点稿 `out/inv-core-contracts.md` + hermes-ammo-audit

---

## ① B1c 预研：contracts/capabilities.yaml header 矛盾澄清

### 当前 header 现状全文引用（contracts/capabilities.yaml:1-20）

```yaml
# ⚠️ HISTORICAL / v1-B-frame-archived（2026-06-23 文档级联，范式翻案）
# 现行权威 = contracts/semantic-function-contract.jsonl（C1 SSOT，3990 源行级全集）
#   + docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md（surface 范式权威）。
# 本文件的 8 个能力（cabin.ac 等）+ tool_schema 名（set_cabin_ac / set_cabin_window 等）= 旧 B-frame 式手写示范，
#   不是 model-visible surface 的最终形态。范式翻案后：
#   - model-visible surface = D-domain 具名工具（value 形态编码进工具名，如 adjust_ac_temperature_to_max / _to_number / _by_exp / query_ac_temperature）；
#     generic frame（tool_call_frame）作 surface 已否决（paradigm §1-§2）。
#   - canonical IR 仍 device × action_primitive × value（B-frame 式），即「对模型像 D-domain 具名工具，对系统像 device×action IR」。
#   - D-domain 具名工具目录由 A2 从 semantic-function-contract.jsonl codegen 派生（替 scripts/gen_tool_contract.py 现硬编码 6 工具名）；
#     工具数未拍待 value-form 实算（10 族 = 191 device / 562 intent / 2159 行 / 54.1%，但 562=intent 非工具数；
#       source: docs/research/2026-06-22-mvp-10family-device-boundary.md:39（2159/3990=54.1%）+ paradigm §14:228-231；562 = 磊哥 2026-06-23 终拍权威，534 系列已废）。
# 保留本文件作旧 surface 示范 / eval refs / voice aliases 溯源，勿当权威 surface 派生源。升级目标见 paradigm §15-§17。
version: 1
state: active
source_of_truth: contracts/capabilities.yaml
notes:
  - "MAformac Phase1 MVP vehicle capability contract."
  - "This file is the single manually maintained source for tool schemas, UI cards, eval refs, trace schema, voice aliases, and LoRA labels."
  - "Generated Swift types and tool_schemas.json are owned by later changes."
  - "⚠️ HISTORICAL v1-B-frame: tool_schema 名为旧 B-frame 示范；model-visible surface 已翻案为 D-domain 具名工具（见文件头 banner + paradigm §1-§2）。"
```

### W3 指认的矛盾点（双 SSOT 气味 + 自指 supersedes）

W3 盘点稿（`out/inv-core-contracts.md:63`）已明确指认：

> 文件自称现行权威是 C1（`contracts/capabilities.yaml:2`），但仍写 `source_of_truth: contracts/capabilities.yaml` 和 single manually maintained source（`:15-18`），属于双份 SSOT 气味。

live 亲核补充三个矛盾点（W3 没展开的）：

**矛盾 1（header:2 vs header:15 自相矛盾）**：`:2` 说"现行权威 = contracts/semantic-function-contract.jsonl"，`:15` 说"source_of_truth: contracts/capabilities.yaml"——同一文件 header 内部两个 source_of_truth 指向不同文件。读者不知道该信哪个。

**矛盾 2（supersedes 自指）**：`:22-30` 的 `supersedes:` 段列了 3 个被替代项，每项的 `replacement: contracts/capabilities.yaml`——**capabilities.yaml 声称自己替代自己**。语义应是"这些旧文件被 contracts/semantic-function-contract.jsonl 替代"，但 replacement 字段全写成自己。这是历史遗留（v1 时 capabilities.yaml 是 SSOT，范式翻案后 header 改了但 supersedes 段没同步）。

**矛盾 3（notes:18 声称"single manually maintained source"与 header 矛盾）**：`:18` notes 说"This file is the single manually maintained source for tool schemas, UI cards, eval refs, trace schema, voice aliases, and LoRA labels"——但 header `:2` 已说权威移交给 C1 SSOT。notes 段是 v1 遗留，没随 header 更新。

**下游 reader 风险评估**（live probe）：
- `grep -rln "capabilities.yaml" scripts/ Core/` = **0 命中**（gen 脚本和 Swift 代码都不读它）。header 无下游 parser 风险——改 header 不破 regen/verify/编译。
- `grep -rln "capabilities.yaml" docs/` 有引用（范式权威 paradigm-tool-surface.md 等），但都是 docs 层引用路径，不解析 header 字段。

### 最小 diff 提案（只加澄清注释，不删内容，不改 8 能力定义）

目标：消除 header 内部自相矛盾 + supersedes 自指，不动 `version/state/source_of_truth/notes` 的 YAML 字段值（保留历史溯源），只加澄清注释行。

提案 diff（`contracts/capabilities.yaml`，在 `:15` 前插入 3 行注释，在 `:22` supersedes 段前插入 1 行注释）：

```diff
 # 保留本文件作旧 surface 示范 / eval refs / voice aliases 溯源，勿当权威 surface 派生源。升级目标见 paradigm §15-§17。
+# ⚠️ 澄清（2026-07-07 streamline B1c）：下方 version/state/source_of_truth/notes 字段为 v1 历史值，
+#   保留作溯源；现行权威以本文件头 banner（:2-3）的 C1 SSOT + paradigm 为准，不以 source_of_truth 字段为准。
 version: 1
 state: active
 source_of_truth: contracts/capabilities.yaml
 notes:
   - "MAformac Phase1 MVP vehicle capability contract."
   - "This file is the single manually maintained source for tool schemas, UI cards, eval refs, trace schema, voice aliases, and LoRA labels."
   - "Generated Swift types and tool_schemas.json are owned by later changes."
   - "⚠️ HISTORICAL v1-B-frame: tool_schema 名为旧 B-frame 示范；model-visible surface 已翻案为 D-domain 具名工具（见文件头 banner + paradigm §1-§2）。"
+# ⚠️ 澄清（2026-07-07 streamline B1c）：下方 supersedes 段的 replacement 字段为 v1 遗留自指，
+#   实际替代者 = contracts/semantic-function-contract.jsonl（C1 SSOT），不是 capabilities.yaml 自身。
 supersedes:
   - id: 03-openspec-input
```

**不动什么**：
- 不删 `version/state/source_of_truth/notes` 字段值（保留 v1 历史溯源，删了破 611 行正文里可能引用这些字段的地方）
- 不改 8 能力定义（cabin.ac 等，:31+ 正文）
- 不改 supersedes 段的 replacement 字段值（只加注释说明）
- 只加 4 行 `# ⚠️ 澄清` 注释

**验收命令**（改后跑）：
- `git diff -- contracts/capabilities.yaml | grep -c "^+# ⚠️ 澄清"` = 2（两处澄清块）
- `git diff -- contracts/capabilities.yaml | grep -c "^-[^-]"` = 0（无删除行）
- `make verify`（diff gate 含 capabilities.yaml via HANDWRITTEN_CONTRACTS，`Makefile:114,117`）——commit 后 working tree clean，diff gate 绿
- `grep -c "cabin.ac\|set_cabin_ac\|set_cabin_window" contracts/capabilities.yaml` 不变（8 能力定义未动）

### 权限标注

**动 contracts/ 需 commander 豁免**：`STREAMLINE_NOTOUCH_ALLOW=contracts/capabilities.yaml` 单独 commit。

理由：
- contracts/ 是 SSOT 承重区（CLAUDE.md:71 "唯一契约源"），默认 no-touch。
- capabilities.yaml 虽 HISTORICAL，但仍进 `HANDWRITTEN_CONTRACTS` diff gate（`Makefile:114`），且 611 行正文可能被 docs 引用。
- 本提案只加 4 行注释（零删除、零字段值变更、零正文变更），风险极低，但按 synthesis §1 结论 8 的风险分级"动 contracts/ = 高风险"。
- 因此需 commander 显式豁免 `STREAMLINE_NOTOUCH_ALLOW=contracts/capabilities.yaml`，并单独 commit（proof domain = contracts-header-clarify，不与其他 B1 项混）。

---

## ② B1d：generated/10-family-device-boundary.md orphan 定性档

### 为什么它是 orphan

`generated/10-family-device-boundary.md` 是 orphan，因为：

**证据 1（不在 GENERATED_DOMAIN）**：`Makefile:14-25` 定义 `GENERATED_DOMAIN` 11 个文件，`generated/10-family-device-boundary.md` **不在列表中**（`grep "10-family-device-boundary" Makefile` exit 1）。

**证据 2（不在 GENERATED_CONTRACTS / GENERATED_SWIFT / HANDWRITTEN_CONTRACTS）**：它不在任何 Makefile 守护变量里。`Makefile:5-10`（GENERATED_CONTRACTS）/ `:27-28`（GENERATED_SWIFT）/ `:114`（HANDWRITTEN_CONTRACTS）都不含它。

**证据 3（不是 gen 脚本产物）**：`scripts/gen_tool_contract.py` / `gen_family_allowlist.py` / `gen_subset_manifest.py` 都不生成 `.md` 文件（它们生成 .json/.yaml）。`10-family-device-boundary.md` 是 2026-06-22 手写的研究档（文件头 `:1` "# G4: 10 族 device 边界精确梳理"，`:3` as-of 2026-06-22）。

**证据 4（躺 generated/ 但无门守护）**：它 tracked（`git ls-files generated/ | grep boundary.md` 命中），但 diff gate（`Makefile:117`）只列 `$(GENERATED_DOMAIN)` + `$(GENERATED_CONTRACTS)` + `$(GENERATED_SWIFT)` + `$(HANDWRITTEN_CONTRACTS)` + `scripts` + `Makefile`——**不含它**。它被改/删/移无任何机械门捕获。

**证据 5（内容是研究档不是生成物）**：`:1-7` 文件头说"数据源: contracts/semantic-function-contract.jsonl"+"目的: 解 CC 422 vs GLM 397 不一致"——是调研/盘点文档，不是 codegen 产物。放 generated/ 是历史误放（2026-06-22 写时图方便放 generated/，因为配套 `10-family-device-map.json` 确实是生成的）。

### 被引用情况（live probe）

`grep -rln "10-family-device-boundary.md\|10-family-device-boundary" docs/` = **9 个 docs 引用**：
- `docs/research/2026-06-22-a2-codebase-audit/{README,lens1,lens4,codex-checks}.md`（A2 盘点引用）
- `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`（范式权威引用，`:39` 引 2159/3990=54.1%）
- `docs/dispatches/2026-06-23-a2-code-refactor-cc-ultracode-dispatch.md`（派单引用）
- `docs/grill-tournament/round-01/brain-3.md`（grill 引用）
- `docs/research/2026-06-23-precommit-audit/round2-audit-E.md`（precommit 审计引用）
- `docs/evidence-frozen/.../grill-decisions-amend-paradigm-tool-surface.md`（frozen 副本引用）

**关键**：范式权威 `grill-decisions-amend-paradigm-tool-surface.md` 引用它的数据（562/2159/54.1%），是 load-bearing 引用。**移动文件路径会破 9 个 docs 引用**。

### 三个处置选项

**选项 1：迁 docs/ 移出 generated/（⭐建议）**
- 动作：`git mv generated/10-family-device-boundary.md docs/research/2026-06-22-mvp-10family-device-boundary.md`（与 `docs/research/2026-06-22-mvp-10family-device-boundary.md` 同名——但该文件已存在？需核。若已存在，迁 `docs/research/2026-06-22-10family-device-boundary.md`）
- 优点：放对目录（研究档归 docs/research/），不再躺 generated/ 误导
- 缺点：破 9 个 docs 引用路径，需批量 sed 改引用
- 风险：中（改 9 个 docs 引用 = 改 docs 正文，但都是路径替换不改语义）
- 本轮：**只记录不动**（需 commander 批 + 9 文件引用批量改 plan）

**选项 2：留在 generated/ 但加 redirect 注释 + 纳入 diff gate**
- 动作：① 文件头加 `# ⚠️ 本文件是手写研究档，非 codegen 产物，放 generated/ 因配套 10-family-device-map.json；权威归属 docs/research/` ② Makefile `GENERATED_DOMAIN` 加入它（纳 diff gate 守护）
- 优点：不改路径（不破 9 引用），加门守护（防误删/误改），澄清归属
- 缺点：generated/ 目录仍混着手写+生成物，不干净
- 风险：低（只加注释 + Makefile 加一行）
- 本轮：**只记录不动**（需 commander 批 Makefile 改动）

**选项 3：纳管为 generated/ 的"文档伴侣"**
- 动作：承认 generated/ 允许有手写文档伴侣（如 boundary.md 是 map.json 的人类可读摘要），文件头加 metadata 标 `kind: human_readable_companion` / `generator: manual` / `canonical_source: contracts/semantic-function-contract.jsonl`
- 优点：不移动不破引用，显式标 metadata 让未来 reader 知道它是手写伴侣
- 缺点：generated/ 语义变模糊（"生成物目录"允许手写？）
- 风险：低（只加 metadata）
- 本轮：**只记录不动**

### ⭐建议

**本轮只记录不动文件**（零 commit 权，且三个选项都需 commander 批）。

推荐顺序（呈 commander）：
1. **选项 2（留 + 加注释 + 纳 diff gate）** 作为最小风险首选——不破 9 引用、加门守护、澄清归属。可在 B1 零风险清单批做（加注释）+ B2 接线批做（Makefile 纳 diff gate）。
2. 选项 1（迁 docs/）作为后续清理——等 9 引用的批量 sed 改 plan 落地后再做，不本轮。
3. 选项 3 不推荐——generated/ 语义应保持"生成物"纯净，混手写会让未来 codegen 审计困难。

**不动原件声明**：本档是预研记录，未动 `generated/10-family-device-boundary.md` 原件，未动 `Makefile`，未动任何 docs 引用。所有选项标注"本轮只记录不动"。

---

## 附：权限与约束

- 零 commit 权（执行单明确）
- 禁动 contracts/ generated/ 原件（执行单明确）
- 本档是预研记录，落 `docs/research/2026-07-07-streamline-review/contracts-header-and-orphan-generated.md`（指定新文件）
- 所有 diff 提案/处置选项标注"需 commander 豁免/批后执行"
- B1c 验收命令已给（4 项 grep/make verify）
- B1d 处置选项已给 3 个 + ⭐建议

## live truth 对账（2026-07-07 亲核）

- `contracts/capabilities.yaml` = 611 行，已有 14 行 HISTORICAL banner（`:1-12`），`supersedes:` 段 `:22-30` 含 3 项自指 replacement
- `grep -rln "capabilities.yaml" scripts/ Core/` = 0（gen 脚本和 Swift 都不读它）
- `generated/10-family-device-boundary.md` = 247 行，2026-06-22 手写，不在 GENERATED_DOMAIN/GENERATED_CONTRACTS/HANDWRITTEN_CONTRACTS 任何变量
- `grep -rln "10-family-device-boundary" docs/` = 9 引用（含范式权威 paradigm-tool-surface.md）
- `Makefile:114` HANDWRITTEN_CONTRACTS 含 capabilities.yaml（进 diff gate）
- `Makefile:117` diff gate 不含 10-family-device-boundary.md
