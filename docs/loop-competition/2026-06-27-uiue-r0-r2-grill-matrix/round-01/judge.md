# Round 01 Judge

日期：2026-06-27
status：DONE
reviewers：RED failure auditor / GREEN implementation coordinator / BLUE UX-HMI designer
candidate_set：C01-C70
coverage：3 reviewers * 70 score rows；`## Scores` 区块均无缺失、无重复
proof_boundary：local / unit / simulator；不声明 L3 / V-PASS / mobile / true_device / A-2 complete

## Mechanical Coverage

| Reviewer | Output | Scores Coverage | Min | Max |
| --- | --- | ---: | ---: | ---: |
| R1-RED | `brain-1.md` | 70/70 | 19 | 25 |
| R1-GREEN | `brain-2.md` | 70/70 | 17 | 25 |
| R1-BLUE | `brain-3.md` | 70/70 | 18 | 25 |

## Strongest Round 01 Consensus

| Candidate | R1-RED | R1-GREEN | R1-BLUE | Avg | Judge signal |
| --- | ---: | ---: | ---: | ---: | --- |
| C26 | 25 | 25 | 25 | 25.0 | P0：ring / percent / dial 手势真值必须成为 hard grill。 |
| C27 | 25 | 25 | 25 | 25.0 | P0：stepper 左右/drag/边界语义必须独立验。 |
| C37 | 25 | 25 | 25 | 25.0 | P0：tap / long press / drag / a11y proof 必须拆开。 |
| C03 | 25 | 25 | 23 | 24.3 | P0：8.C2 继续 open，UI test 不得替代 L3。 |
| C30 | 24 | 25 | 24 | 24.3 | P0：color swatch 要同步外层卡、summary、expanded row。 |
| C35 | 24 | 25 | 24 | 24.3 | P0：写回后至少两个可见层级必须同步。 |
| C39 | 23 | 25 | 25 | 24.3 | P0：44pt touch target 应成为手持 HMI 底线。 |
| C56 | 24 | 24 | 25 | 24.3 | P0：Layout Integrity Gate 必须进入 R2 前置 grill。 |
| C57 | 24 | 24 | 25 | 24.3 | P0：Layout pair 覆盖 capsule / orb / dialogue / cards / mic dock。 |
| C48 | 25 | 25 | 22 | 24.0 | P0：每条 proof 都要标 proof class，禁止 simulator 升格。 |
| C51 | 23 | 25 | 24 | 24.0 | P0：`cooling + ivory` 必须纳入 R2 L0 第一阻断 case。 |
| C59 | 25 | 25 | 22 | 24.0 | P0：L0 继续必须是 on-screen `simctl io` screenshot。 |
| C64 | 23 | 24 | 25 | 24.0 | P0：VPA/orb 四态至少要有 L0/UI tree proof。 |

## Controller Takeaways

1. R0 不只是“修今天截图”。必须同时守住 dirty scope、proof class、`8.C2` open、设备/xcresult attribution，以及 capsule/VPA 的 placeholder 边界。
2. R1 的核心不是“10 族都点过”，而是 `value type x gesture x writeback x readback x proof class`。今天 ring/stepper 的失败就是该矩阵缺口。
3. R2 必须把视觉结构门前置：Layout Integrity、Visual Spacing Sentinel、on-screen L0、只读 evidence checker、L3 punchlist。机器门只能挡塌陷/结构/可读性，不能签审美。
4. Capsule / GPT Image 2 / anchor 的治理要升级为规则：锚点只定义方向和审美 bar；资产不带预烘焙外壳；SwiftUI 负责 mask/glass/chrome；placeholder 与 final art 必须分层。
5. VPA/orb 必须回到 SD16/SD18：`idle/listen/think/speak` 四态、米白/深空双主题、halo budget、注意力优先级，不允许用 frame 未遮挡掩盖光晕抢层级。

## Merge / Canonical Groups

| Group | Candidates | Canonical direction |
| --- | --- | --- |
| Layout Integrity | C15, C16, C56, C57, C58 | frame pair、min gap、safe area、crop、PASS/WARN/FAIL；覆盖按钮、capsule、orb、dialogue、cards、dock、端状态列。 |
| Interaction Matrix | C23, C24, C26, C27, C37, C39, C40 | family / value type / gesture / touch target / a11y / writeback / readback / proof class 分列。 |
| Visual Asset Governance | C11, C12, C19, C63, C68 | GPT Image 2 和 anchor 只作方向；asset 不带 chrome；placeholder/final art 书面分层。 |
| VPA/Orb | C13, C14, C64, C65 | 四态、文案绑定、主题分开、halo budget、注意力链。 |
| Evidence Discipline | C03, C04, C17, C18, C48, C54, C55, C59, C61, C69, C70 | `8.C2` open、设备/路径/xcresult、只读 checker、失败只回写发现、R3 前独立审计。 |

## Missing Risks Promoted To Final Consideration

- `capture-8c2-l0-evidence` 不应 silent fallback 到非目标设备；若 Pro Max 不可用，应显式 `PARTIAL` 或写降级 proof。
- 审计不能简单 grep `V-PASS` 字符串；`claims_not_made` 里的 non-claim 不是违规声明。
- `accessibilityIdentifier` 和中文 display title / contract id 的改名同步要有全局撞名和查错元素防护。
- `mic dock` 遮最后一行卡片需要单独 bottom inset / crop 证明；不能只在 pairwise gate 中一笔带过。
- 动态字体、最长中文文案、米白主题 hairline/细字对比仍需要进入后续 R1/R2 punchlist。

## Round 01 Verdict

保留全部 70 项进入 Round 02。Round 01 没有建议删除项；低分项主要是“需要并入 canonical group 或改写成更可执行的门”，不是无价值。
