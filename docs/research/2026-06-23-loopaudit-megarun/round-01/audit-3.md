# Loopaudit Megarun — Round 01 · 审计员 #3

> **审计员**: #3（第1轮）
> **负责维度**: 范式一致（D-domain / 无 generic frame drift） + 可执行性（OpenSpec change skeleton 合规 / 物理落点可派单）
> **as-of**: 2026-06-23
> **verdict**: **has_p0p1 = true**（0 P0 / 3 P1 / 1 P2）。范式一致维度近乎干净（活基线 CLAUDE/SRD/MASTER/state-cells/4 change 全 D-domain 无 generic-frame-as-authority drift，口径全仓 562 已级联）；可执行性维度 4 个 change skeleton 结构合规、`openspec validate --all --strict` 13/13 pass。问题集中在**派生数字引用**（418 废口径混入 + 误 cite §13 G4）+ **历史档段间矛盾**（boundary §3/§4 拍板状态未随 A4 终裁更新）。

---

## 实核痕迹（本机 Read/grep/python 实跑，非凭印象）

1. **per-family 表合计复算**（python）：boundary §1 device 25+36+11+21+29+33+11+8+10+7 = **191** ✓ / intent 68+126+27+48+113+75+32+27+30+16 = **562** ✓ / 行 212+696+82+129+468+205+153+80+102+32 = **2159** ✓。三轴与权威口径完全一致，无内部分叉。
2. **openspec validate --all --strict** = 13 passed / 0 failed；4 个新 change（migrate / retrain / rebuild-c6 / demo-golden-run）逐个 `--strict` 各自 valid。
3. **change skeleton 结构**：4 个均含 `proposal.md`（DRAFT banner + agree-before-build 守门 + Why/What/Capabilities/Non-Goals/Success Criteria/Impact）+ `tasks.md`（DRAFT + incremental 序）+ `specs/<cap>/spec.md`（MODIFIED/ADDED Requirements + Scenario 占位）+ `.openspec.yaml`（status: DRAFT）。spec delta 格式合规（`## MODIFIED Requirements` / `### Requirement:` / `#### Scenario:` GIVEN/WHEN/THEN）。
4. **D-domain drift 扫描**（grep `tool_call_frame / set_cabin / B_frame / B-frame surface` 于 CLAUDE.md / SRD / MASTER / state-cells.yaml / 4 change）：零「B-frame-as-authority」残留。命中的 `set_cabin`（MASTER §3:84/94）全为「错在哪」负面示例，`tool_call_frame` 全为「否决/显式移除」语境，合规。
5. **口径 562 级联**：CLAUDE.md §9 banner(:113)、SRD §1.4(:78)/§5.2、MASTER 头 banner(:8)、boundary 头(:3)、cascade-inventory(:5/:108)、4 change proposal 全持 562 权威 + 旧 534/2086/52.3% 标废。state-cells.yaml 含 2026-06-23 surface 边界级联注释（:9-15）。
6. **418 / §13 G4 cite 核对**：grep 418 跨 master/paradigm/cascade — master §0 废口径表列「418（codex compact positive，口径不同**待重算**）」；paradigm §14:232「⚠️ 待 A1 按 scope_tier 拆后重算」；paradigm §13 G4(:189) 正文**不含 418**（只有 562/2159）。
7. **boundary §3/§4 vs A4 终裁**：boundary §3 header(:67) 仍「边界歧义点（待磊哥拍）」；§4(:116)「steering_wheel_heating 若并入座椅 +1 device/+10 intent」；但 paradigm §13(:203) A4 已拍「展示层归座椅、技术 device 独立不变」+ boundary 头(:3)「device 191 不变」。cascade-inventory(:108) 仅核 562 口径、判「无须再改正文」，未覆盖 §3/§4 拍板状态 staleness。

---

## Findings

| # | severity | issue | location | fix |
|---|---|---|---|---|
| 1 | **P1** | retrain change 把废/待重算口径 **418** 当作已定 scope_tier 数引用（「scope_tier 拆：候选 562 / compact positive 418」），且 cite 来源标 **paradigm §13 G4**——但 §13 G4 正文不含 418（只有 562/2159）；418 实际出处 = §13 A3 / §14:232，均明标「待 A1 按 scope_tier 拆后重算」+ master §0 废口径表。违背 claim-vs-reality 第10变体（派生/待重算数当一手）+ §0「禁引废口径」。 | `openspec/changes/retrain-c5-lora-d-domain/proposal.md:23` + `openspec/changes/retrain-c5-lora-d-domain/specs/lora-training/spec.md:7` | 把「compact positive 418」改为「compact positive [待 A1 按 scope_tier 拆后重算]」或删去具体数字（DRAFT 占位足矣）；cite 改 `paradigm §13 A3 / §14:232（418 待重算）`，不挂 §13 G4。 |
| 2 | **P1** | boundary 历史档段间矛盾：§3 header 仍「边界歧义点（**待磊哥拍**）」且 Q-A4(:84-86) 仍列 steering_wheel_heating「当前归属族外 / ⭐建议族外」——与 paradigm §13 A4 终裁「磊哥拍展示层归座椅、技术 device 独立」矛盾；§4(:116)「若并入座椅 +1 device」把已裁的 A4 描述成仍开放，与本文头(:3)「device 191 不变」自相矛盾。cascade-inventory(:108) 只核 562 口径判「无须再改正文」，漏此拍板状态 drift。 | `docs/research/2026-06-22-mvp-10family-device-boundary.md:67`(§3 header) + `:84-86`(Q-A4) + `:116`(§4 微调) | §3 header 加边注「A1-A9 已磊哥拍（见 paradigm §13），下列为推导溯源历史态，勿据此推进」（与头 :3 口吻一致）；Q-A4 ⭐建议改标「已拍：展示层归座椅、技术 device 独立、191 不变」；删/改 §4:116「+1 device」微调句（与 191 不变冲突）。 |
| 3 | **P1** | cascade-inventory boundary verdict 不完整：line 108 verdict 只处理「562 口径回写」一维并判「无须再改正文」，未把 boundary §3「待磊哥拍」+ §4「+1 device」拍板状态 staleness 纳入 what_to_change。该账本是「第一个长跑级联机械账本」（§35），漏标 = 下游执行者照账本会认为 boundary 文件干净、不修 §3/§4，drift 留存。 | `docs/grill-tournament/cascade-inventory.md:108` | boundary verdict 的 what_to_change 补一条「§3/§4 拍板状态级联：A1-A9 已拍，§3 header『待磊哥拍』+§4『+1 device』需加已拍边注/改写（见 finding 2）」，保留 modify(P0) 但明确正文需改 §3/§4 段（非仅口径锚）。 |
| 4 | **P2** | 4 个 change 的 `## MODIFIED Requirements` 用**新 Requirement header**（如「model-visible surface SHALL be D-domain named tools」「tool-call frame SHALL be a D-domain named tool」），与 archived spec 既有 Requirement header（如 tool-execution「运行时只接受单发工具调用或非动作帧」/「工具调用帧必须表达 action primitive 与 value 四件套两维」）**不一致**。OpenSpec MODIFIED 语义按 header 匹配既有 requirement；新 header = sync/apply 时易成 orphan-MODIFIED（改了不存在的 requirement）。validate 不交叉核（已 13/13 pass），故仅在 propose→apply 阶段暴露。DRAFT banner 已守 agree-before-build（不进 apply）+ delta 显式标「Requirement/Scenario 待 propose 填实」，故降 P2 advisory。 | `openspec/changes/migrate-d-domain-tool-surface/specs/{semantic-function-contract,tool-execution}/spec.md` + retrain `lora-training` + rebuild `vehicle-tool-bench` 的 MODIFIED Requirement header | propose 填实时：MODIFIED block 的 `### Requirement:` header 必须与 archived spec 既有 header **逐字一致**（否则用 ADDED 新增），新行为若是改既有则复用旧 header 加 SHALL 增量；或在 DRAFT 注释里显式提示「propose 时 header 对齐 archived spec，防 orphan-MODIFIED」。当前 DRAFT 阶段可不动。 |

---

## Summary

范式一致维度：**干净**。活基线（CLAUDE.md §9 / SRD §1.4+§5.2 / MASTER 头 banner / state-cells.yaml 注释 / 4 change proposal）全部 D-domain 具名工具为权威 + generic frame `tool_call_frame` 标否决/显式移除，无 B-frame-as-authority drift；口径 562 已全仓级联（旧 534/2086/52.3%/1004/1904 标废），boundary per-family 表 191/562/2159 三轴 python 复算精确一致。

可执行性维度：**结构合规可派单**。4 个 OpenSpec change skeleton 均 DRAFT-banner 守 agree-before-build、含完整 proposal/tasks/spec-delta、`openspec validate --all --strict` 13/13 pass、依赖序（migrate→retrain→rebuild-c6→demo-golden-run，对齐 A2 6 步 [0-3]/[4]/[5]/末端）清晰、物理落点（cascade-inventory 各 path verdict）可追。

3 个 P1 集中在两类：① **派生/待重算数字混入**（418 当已定 scope_tier + 误 cite §13 G4，retrain change 2 处）；② **历史档段间矛盾未级联**（boundary §3「待磊哥拍」+§4「+1 device」与已拍 A4「191 不变」冲突，且 cascade-inventory 账本漏标）。1 个 P2 是 DRAFT-mitigated 的 OpenSpec MODIFIED-header 对齐 advisory（propose 时需注意，当前 DRAFT 不阻塞）。无 P0：无阻塞、无事实错、无 D-domain drift、无决策违背。
