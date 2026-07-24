# ma13 第一波收稿 + 暂停点交接（2026-07-10 16:40）

> 🔴 HISTORICAL：本 handoff 的『暂停待拍』态已被 D-138 补记 supersede（BALLOT RATIFIED + 修复轮开工），现行态见 docs/CURRENT.md + STATUS-BOARD。

> 起手读链：本文 → decisions.md **D-138**（本波全账）→ run dir `~/Projects/agent-tmux-stack-research/runs/2026-07-10-ma13/`（9 份交付）→ ma12 交接 `2026-07-10-ma12-c1-full-auto-dev-day.md`。

## 完成了什么
1. **ma13 蜂群起（4 codex sol high + hermes 秘书）**，布局同 ma12（%0 commander 左/%5 秘书左下/右列 %1 %3 %2 %4）。
2. **w1 fresh 对抗审 PR #42 int-v4（790b6c7b）= REQUEST_CHANGES**：P0-1 finiteReason 生产分叉（commander comm 亲核坐实）+ P1-1 ownership gate 不扫生产面 + P2-1 D-137 归因。其余 body 声称全 MATCH（canDemo=0 真/负例门全有牙/无越界）。
3. **int-v5 六开放项四路预研全收**（cite 抽核全坐实）+ **w2↔w3 双向互审**（方向全接受，实施细节 REQUEST_CHANGES 待吸收）。
4. **w1 修复验收门 SPEC 已锁**（`specs/SPEC-p01-fix-acceptance.md`：parse/ir/bridge→`unsupported_tool_plan`+`decodeFailureKind`，不扩 T0 闭集）。
5. 收尾落库：D-138 + CURRENT.md 刷新 + 本 handoff + MEMORY as-of。housekeeping：D-137 补记 commit `4779b8eb`；check-codex-hooks-health.sh 移出仓。

## 未完成 / 下一步（磊哥拍后恢复）
1. 🔴 **磊哥拍 `reports/BALLOT-ma13-final.md`**（主 3 题：Q-1 路线 ⭐B / Q-12 branch protection ⭐上 / Q-13 结构缺口 ⭐residual + 细节 10 题全 ⭐）。
2. 拍后执行序：**修复轮**（P0-1/P1-1，修复方≠w1，按验收门 SPEC）→ w1 复审 → PR #42 转 Ready → merge（磊哥键）→ int-v5a（⑥正名+③bundle codegen）→ v5b（admission deny-first）→ v5c（witness+可靠性 negative lane）。
3. backlog：make verify-all fresh 环境 rc2（source-snapshot xlsx 路径迁移，pre-existing）；GitNexus 索引 stale 5+ commits；本地 ahead 1 未 push。

## 关键发现（本波新知）
- **gate 覆盖面也是 basis**：ownership gate wire 进 verify 但只核 registry 自洽 → 生产违反时仍 PASS（骗过 ma12 亲核的再深一层）。
- **P0-5 比 GPT Pro 报的重**：inline bundle 自造契约不存在 row ID + risk policy 削空（行驶中开门禁令丢失）。
- **repo 实况零 branch protection**（w4 live API 核，且仓已 PUBLIC 非 private——commander 派单 stale 声称被 worker 纠正）。
- **witness 必须 int-v5 先行**：等 S8 = 第一批正证落在可拼接旧 receipt 上。
- hermes 秘书一稿 3 处编造被审出（必审纪律再实证）；秘书 REPORT 两次误发 %3 需 C-u 清。

## 当前状态
- git：opt/streamline @ 4779b8eb（ahead origin 1，含 D-137 补记；本收尾 commit 后 ahead 2）；PR #42 Draft/CI 绿/MERGEABLE。
- 蜂群：ma13 全员 idle 挂机（暂停令 16:35 起一小时，计时器 bfxou5hx2 在跑）；**恢复派单前先向磊哥确认**。
- Non-claims：PR #42 未 Ready/未 merge；修复未开工；canDemo=0/120；无 operator-pass/V-PASS；S8 未点火。
