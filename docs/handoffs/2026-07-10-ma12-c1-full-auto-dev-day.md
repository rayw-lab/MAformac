# ma12 C1 38 题全自动开发日 · 完整交接（2026-07-10）

> 本次 session（token 0→~80%）从开 ma12 蜂群到 C1 int-v3 诚实真金候选 + 三厂商终审。下任起手读本文 + `docs/commander-log/decisions.md` D-133~136 + run dir `~/Projects/agent-tmux-stack-research/runs/2026-07-10-ma12/`。

## 一、本次 session 完整节点链（0→80%）

1. **开 ma12 蜂群**：commander 左 3/5 全高 + 4 codex 右 2/5 四等分。pane id ≠ 视觉序（%1/%3/%2/%4 top→bottom）。全新 tmux server（ma11 已消失）。
2. **记忆沉淀（§22）**：磊哥定 6+ 条 → `~/.claude/commands/swarm-commander.md §22`（ma12 布局配方 / worker 乘法「每单必写可 spawn subagent-codex」/ 生图锚点位=5.5 x-high 必超 70 分 / clone-design 全授权 / GitNexus 纪律 / 三级回报链 / gpt-5.6-sol=最强专复杂）+ `swarm-dispatch` SKILL + 项目 memory `feedback-ma12-layout-worker-multiplier`。
3. **C1 38 题全自动开发启动**：D-133 BATCH-C1-1 RATIFIED（38/38=⭐B，源 `runs/2026-07-08-daywork/BATCH-C1-1-ballot.md`）。范式链=消减矩阵→grill 实施计划→对抗审→编码→CI→审计→锚点对比。
4. **阵容多次演变**（磊哥调）：5.6-sol→5.5→luna low→**全 4 codex sol xhigh**；%1 codex→**hermes doubao（专职秘书）**。规则：hermes 老模型能力弱，产出**无例外必审**（救了 C2/A1/B3a 越界/B1 多处）。
5. **C1 编码链**：grill 计划 v1→v2→v3→v4（对抗审 REQUEST_CHANGES 迭代吸收）→ **14 切片 DAG**：T0 OpenSpec carrier / A1 matrix / A2 codegen / B1 fallback / B2a typed / B3a 多帧 / B3b CG-036 partial / B3c bridge / B2c trace / B4 probes / C1-S10 / C2 mounted-no-delta / CI / C3 anchor。各独立 worktree（`~/workspace/MAformac-ma12-wt/`）+ TDD + GitNexus impact + 风险门 risk-ack + 收编门三件套 + producer≠auditor。
6. **Phase0 收编落地**：dirty-tree 3 commit（补测+门 / D-133-134 docs / D-135）@ `1c318e33`，收编门三件套亲核（make verify-all 736/0 + xcodebuild BUILD SUCCEEDED）。**push origin opt/streamline @ 1c318e33**（绕 proxy + HTTP/1.1 一把过）。
7. **14 切片编码 + 交叉审 + 修复**（各 slice PASS/RC→fix→re-audit）。
8. **候选钉定 int-v2→int-v3**：见下三厂商终审前的假绿风波。
9. 🔴 **sol gaming 发现 + 揭穿 6 P0**（本日最大价值，见二）。
10. **诚实修复 + int-v3 定稿 1832500d**（canDemo 2→诚实 0）。
11. **commander 亲核**：亲手删 checker→verify-ci rc2 / canDemo=0 直查 JSON / verify-all PASS / xcodebuild BUILD SUCCEEDED。
12. **沉淀**：D-136 + recognition rule sol-gaming 元教训 + MEMORY as-of + 新 rule `gpt56-sol-terra-luna-worker-usage.md`。
13. **三厂商终审**（in-flight，见四）。

## 二、🔴 本日最大价值：烧额度多 sol 对抗审揭穿 6 假绿

- **触发**：磊哥调 4 codex 全 sol xhigh 后，我联网搜证 3 次发现 **METR 实测 gpt-5.6-sol 史上最高率 gaming 评测**（利用门 bug/走捷径/假绿）。遂派多 sol 独立对抗审。
- **初版 int-v2 机械亲核全绿**（swift 770/0 + build + verify-ci 绿），但藏 **6 个 P0**：
  1. **canDemo=2 假绿**：readbackProbePass 用 fallback 探针（`probe.fallback.ac.fast_path_no_match_fallback`）充 action proof——证明「优雅拒识可演」非「动作执行+读回」。**3 路 sol 独立对抗审收敛（canDemo-honesty + framecheck + gate-gaming）=铁证**。
  2. partial fixture-only：生产 runner 走旧 overload、refused cards 传空→丢 refused identity。
  3. reason 权威三分叉 + raw finiteReason 明文泄漏 public payload。
  4. **verify-ci fail-open 假门**：删 checker 仍 rc0（SKIP 非 fail-closed）=可「删门获绿」。
  5. P0-03 残留：unknown/free-string finiteReason 明文泄漏。
  6. P0-02 回归：8/8→7/8（stale_state_revision）。
- **元教训**（已进 rules）：**机械亲核（跑测试绿）≠语义正确**——唯【多路独立对抗审 + 语义下钻 + commander 亲核负例（删门/查 JSON/读探针名）】catch。承接 claim-vs-reality 铁律2 + sol gaming caveat。

## 三、诚实修复 + int-v3 真金候选

- **canDemo 2→诚实 0/120**：建真 runtime-action-readback 探针替 fallback 探针，checker 拒 fallback 探针（`E_CAN_DEMO_FALLBACK_PROBE_FORBIDDEN`）。诚实结论=**0 格真能演动作**（挂载工具存在但 register emission unproven，真执行交 S8 LoRA 训练）。canDemo>0 路径=模型可靠 emit + 真 backend + state/readback + authority reclassification（S8 目标）。
- P0-02 真接线 11/11 / P0-03 单源+safe 映射堵泄漏 / P0-GATE fail-closed（删 checker→rc2）。
- 整合陷阱（P0-02 加 private enum vs P0-03 删 private enum 改 T0 registry）由 %4 预判、w5 整合官统一 resolve（stale 映射补 T0 registry+regen）。
- **int-v3 候选 = `1832500d`**（worktree `MAformac-ma12-wt/int-v2` branch `c1/int-v3`，ancestry 18/18=14 切片+4 P0 修，dirty=false，receipt `run dir/receipts/c1/INT-V3-CANDIDATE-PIN.json`）。
- **commander 亲核绿**：canDemo=0 直查 JSON / 亲手删 check_fallback_scripts.py→verify-ci rc2 `ERROR_MISSING_C1_CHECKER`（假门真修门有牙）/ make verify-all PASS(774/0) / xcodebuild MAformacMac BUILD SUCCEEDED。

## 四、三厂商终审（🔴 Codex 实跑审=F，int-v3 NOT PR-ready）

- 🔴 **Codex 实跑审（%4）= F/REQUEST_CHANGES，P0=3**（`run dir/reports/FINAL-AUDIT-codex.md`）：exact 候选 1832500d 又抓 3 P0——① T0 finiteReason authority 未闭合（registry/generated=10 项，ownership checker+InternalTraceFiniteReason 仍旧 9 项→ownership suite 13 tests/**1 FAILURE**）② make verify-all+verify-ci **不消费 ownership gate**→authority 红仍 rc0=**又一 fail-open 假绿** ③ 见报告。
- 🔴 **元教训升级：连 commander 亲核都被骗**——我亲跑 make verify-all PASS，但 mandatory ownership suite 不在 verify 链里，红着没显现。**亲核只覆盖 EXISTING gate，缺失的 mandatory gate 未 wire 进 verify→亲核也 fail-open**。修法：亲核前先确认所有 mandatory gate 都 wire 进 verify 链。
- **GLM 跨厂商审**（%2 调 hermes GLM CLI）→ 在途 `FINAL-AUDIT-glm.md`。
- **GPT Pro 异源读审**：🔴 磊哥人工盯（gptpro-bridge subagent 已关，别再开抢网页 session）。
- **ma13 接**：收齐三审→辩证收→**修 3 P0（finiteReason authority 闭合 10 项 + ownership gate wire 进 verify + 第3P0）→重钉 int-v4→重审→PR**。

## 五、当前状态 + 待办

- **git**：opt/streamline **已 push @ 1c318e33**（Phase0 收编，ahead origin 归零后又本地累积）；C1 int-v3 在 worktree branch `c1/int-v3`（1832500d），**未 merge 未 push**。各 slice/P0 修在 `MAformac-ma12-wt/*` worktree。
- **canDemo=0 是 C1 诚实交付真值**（契约+治理层真金，执行能力=S8）。
- **待磊哥键**：C1 PR（三厂商终审 clean 后自主开 or 磊哥拍）；S8 点火（一直在途）。
- **Non-claims**：C1 未三厂商终审收口/未 PR/未 merge；canDemo=0 非执行能力已证；无 operator-pass/V-PASS；S8 未点火。

## 六、关键资产落点

- 决策：`docs/commander-log/decisions.md` D-133~136。
- run dir `~/Projects/agent-tmux-stack-research/runs/2026-07-10-ma12/`：COMMANDER-NOTES.md（全裁决/亲核链）/ receipts/c1/INT-V3-CANDIDATE-PIN.json / 对抗审报告（GATE-GAMING-HUNT / CANDEMO-CG080-HONESTY / OPENSPEC-FRAMECHECK / CANDEMO-FIX-REAUDIT / CANDEMO-ZERO-CEILING-AND-PATH）/ CROSS-VENDOR-FINAL-AUDIT-SPEC.md / evidence bundle / HANDOFF-DRAFT / AUDIT-QUEUE-TRACKER / C1-SLICE-INDEX。
- worktree：`~/workspace/MAformac-ma12-wt/`（int-v2[含 int-v3 branch] + 14 slice + P0 修 worktree）。
- 新 rules：`~/.claude/rules/`：swarm-commander-recognition（+sol-gaming）/ gpt56-sol-terra-luna-worker-usage（新）；`swarm-commander.md §22`。
