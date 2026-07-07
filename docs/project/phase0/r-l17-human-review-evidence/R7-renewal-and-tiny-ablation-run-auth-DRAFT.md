---
status: part_a_renewed_and_part_b_v5_consumed（v5 授权已消耗于已完成 run；v6 需按 FINAL 档 §5 新签）
artifact_kind: r7_renewal_template_and_tiny_ablation_run_auth_checklist
authority: template_only_no_authorization（本文件存在≠任何授权；签字动作只能磊哥本人在【签字区】显式落笔）
prepared_by: claude-commander（磊哥 D-019 指令：备模板不等 7-15，保持 draft/unsigned）
prepared_on: 2026-07-02
supersedes: 无（与 R7-final-route-deframing-signoff.md 并存；签署后本文件转正式 signoff 文件）
predecessor: R7-final-route-deframing-signoff.md（route-only signed 2026-06-25，expires 2026-07-15）
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# R7 续签 + 裁决-A tiny-ablation run-auth（模板，draft/unsigned）

> 🔴 本文件是**空白签字模板**。所有 verdict 字段 = `unsigned`；填写与签署 = 磊哥本人动作。commander/worker 不得代填任何签字区字段。

## Part A — route-only signoff 续签（原件 2026-07-15 到期）

### A.1 续签范围（与原件一致，无扩权）
- 续签仅延续 `route_only_to_rebuild_c6_construction` 已解锁项；**blocks 清单原样保留**：retrain-c5 / C6 acceptance / D-domain base recalibration / candidate comparison / demo-golden / voice / endpoint / UIUE merge / V-S-U-PASS。
- 新到期日建议：签署日 + 21 天（可改）。

### A.2 续签前置核对（commander 备料，磊哥核签）
| # | 核对项 | 状态（备料） | 磊哥核 |
|---|---|---|---|
| 1 | 原件 blocks 是否全程守住 | 备料：2026-06-25 至今无真训练/真生成/真评测/云生成调用；三 gate 落地均 construction 态（D-011/D-018） | ☐ |
| 2 | 期间新增解锁类动作是否都有独立授权 | 备料：M1 merge（D-017⑤ 磊哥授权）/ gate7+E2 construction（D-019 磊哥授权，条件二收窄） | ☐ |
| 3 | 是否有需要**收窄**的项 | 备料：无建议收窄；E2-D 条件二已额外收窄 Phase-1 | ☐ |

### A.3 签字区（磊哥本人）
```
route_only_renewal_verdict: signed_route_only_renewed
renewed_on: 2026-07-02
new_expires: 2026-07-23
human_owner_signature: 磊哥（王磊）2026-07-02 对决策包第 6 项「同意」——commander 代录口头授权，非代签；范围与原件一致无扩权，blocks 清单原样保留。
```

## Part B — 裁决-A tiny-ablation RUN 授权 checklist（run-auth，unsigned）

> 依据：F-044（tiny ablation：20-50 样本，empty 28/34→<5/34 才许声称范式修复）+ F-092/F-094（4 模型一致 PASS 不自动放行；run auth 是独立最后一拍）+ F-089/F-091（R1-R6 证据格式 {file:line/row-id, verdict, 异源判官}）+ 磊哥 D-019 顺序令：**gate7 pipeline construction + E-2 Phase-1 construction 两者 merged 之后才可授权本 run**。

### B.1 授权前置条件（全 ☑ 才可进签字区）
| # | 前置 | 验证方式 | 状态 |
|---|---|---|---|
| 1 | 🔴 gate7 pipeline construction PR merged（G7A/G7B/G7C/G7D） | gh pr state=MERGED + main CI 绿 | ☑ **全 MERGED**：A `c93efaee`/B `2b006b8a`/C `0ff56e06`/D `1d822961`，每支交叉审绿 |
| 2 | 🔴 E-2 Phase-1 construction merged（manifest codegen + 预算门 + grammar artifact + C6 schema + receipt + C5 builder 按 manifest） | 同上 + `verify-subset-budget` 本地绿 | ☑ 全 merged + hermes findings 修复闭环（#21/#22/#23 closed，含 P1 policy authority + S-210 三层可达），`verify-subset-budget` PASS |
| 3 | route-only signoff 有效（未过期或已续签 Part A） | 本目录 signoff 文件 status | ☑ 有效期内（expires 2026-07-15；Part A 续签模板备好） |
| 4 | ablation 样本集就绪且过数据门（20-50 样本，含 subset manifest digest；must_not_train/C6 保护零命中） | C5DataGate receipt | ☐ |
| 5 | 训练循环 verified（gate1 机制 + `--require-maformac-loss-mask` + 反向 guard 三 split 在 main） | main 代码态 ☑（D-018）；run 前 self-test 复跑（run plan Step 2 前置） | ☑/run 前复跑 |
| 6 | run 配置 = rank16Mainline 工厂（scale20/LR1e-4/gradClip1.0），零手改 | 渲染命令 diff 工厂 | ☐ |
| 7 | receipt 契约就绪（run manifest / metrics.jsonl / 行为中门 / C6 样本探针 / non_claims） | blueprint §3 + run plan §落盘清单 | ☑ |
| 8 | 判定标准预注册（防移门）：**empty 28/34→<5/34 通过；未过不得声称范式修复；不得事后放宽** | 本 checklist 即预注册 | ☑ 预注册于此 |
| 9 | ≥1 异源审计员指定（非 Claude-family，审 run 产物） | 磊哥指定 | ☐ |

### B.1.1 真态快照 + scoped waiver（2026-07-02 深夜，磊哥认可态）
- main = `aac84de9`（13 支 PR #12-#23 全合流；G7A/B/C/D + E-2 Phase-1 merged；hermes findings #21/#22/#23 closed）。
- 终验收 receipt = **PARTIAL_SIBLING_NOISE**：main 全机械门 PASS + 修复轮目标套件全绿（C5 53/0 / C6Subset 18/0 / G7 8/0）；唯一失败 = pre-existing sibling UIUE fixture 对比测试（M1 前已存在，输入与本轮全部变更无关）。
- 🔴 **scoped waiver（磊哥 2026-07-02）**：sibling UIUE fixture 噪声**仅豁免为本轮 tiny-ablation 的前置验收残留**——不豁免 wave-1/formal train/candidate/C6 acceptance 的验收要求；M4 UIUE 收口时根治。
- 🔴 **non-claims（写死）**：tiny-ablation 通过 **不代表** wave-1 数据授权、不代表 formal train、不代表 candidate、不代表 C6 acceptance、不代表 UIUE merge、不代表 V/S/U-PASS——仅回答一个问题：「D-domain 范式在 20-50 样本过拟合下能否把 empty 从 28/34 打到 <5/34」。

### B.2 run 范围（授权即仅此，超出即违）
- **仅** 裁决-A tiny ablation：20-50 样本小训练 + 行为探针评测。**不是** formal 训练、不是数据 wave、不是 C6 acceptance、不是 candidate comparison。
- 产物：adapter 权重（tiny，run 目录内不入仓）+ receipt + 行为对比表。run 结束后权重处置听磊哥（默认保留 run 目录待审）。

### B.3 签字区（磊哥本人）
```
tiny_ablation_run_auth_verdict: signed_run_authorized
authorized_on: 2026-07-02
authorized_scope: adjudication_A_tiny_ablation_only
sample_count_approved: 40
human_owner_signature: 磊哥（王磊）本人于 2026-07-02 对话原话「全部授权 推进tiny ablation 真跑」——在 commander 贴出签字包终版+run plan 全文并自证零 scope 扩张后授权；commander 代录口头授权，非代签。B.1 第 9 条（run 产物异源审计员）按「全部授权」默认=run 产物出稿后磊哥指定（hermes 下个审计点仍等磊哥通知）。
```

## Part C — 维护
- G7A/B/C + RAT PR 状态变化 → commander 刷 B.1 前置表状态列（不碰签字区）。
- 磊哥签署任一 Part → 本文件 status 更新 + 级联 CURRENT/landing/blueprint §4 + commander-log 决策记录。
