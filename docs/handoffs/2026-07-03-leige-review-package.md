# 磊哥人审包（2026-07-03，一页看全）

> 只列需要您动手/拍板的；其余全部已 default 锁定可异步翻。证据都在 run 目录 `2026-07-03-n2n4-train-readiness/` 与 commander-log D-040~048。

## 一、要您动手的（按顺序，4 件）

| # | 动作 | 说明 |
|---|---|---|
| 1 | **修 GitHub billing/spending limit** | 六支 PR 的 CI verify 全 FAILURE 均此因。修完**不用理我**，我自动 rerun checks |
| 2 | **CI 绿后按序 merge**：#26 → #27 → #28 → #29 → #31 → #32 | 全部 local 审绿且绑当前 head（见下表）；#32 是 docs 整编支（MERGEABLE），合完我关 #30 |
| 3 | **N5E-005 人工精度门（一选）**：A ⭐您本人按代码 sample size 抽检（family<0.8 停线）／ B 首波跳过人工门，数据门+judge 双机械门先行 | 扩量 4.5k 唯一没 default 敢替您拍的题。回「A」或「B」即可 |
| 4 | **run-auth / R7 candidate signoff**（训练线，不急） | 签后第一动作=T1 hang 验证 2-iter smoke（mlx-lm#1348 触发面与我们配置命中） |

## 二、PR 状态速览（merge 前扫一眼）

| PR | head | local 终态 |
|---|---|---|
| #26 P3H 探针 harness | `edfc2198` | P1 修复后复核全 PASS（parser 脏尾巴污染已堵） |
| #27 A+ 损失契约 | `a400b01a` | APPROVE；mirror gate 复跑 old v5 exit66 / new v6 exit0 |
| #28 v6.1 EOS | `49fa0b9b` | APPROVE；注意 v6.1 同帐有 C/D 退化（tiny 稀疏，非实装 bug） |
| #29 G7 surface 硬门 | `871307d9` | 双 P1 修复后 APPROVE（`tools:[{}]` 绕门+digest 未闭合已堵） |
| #31 E-2 降档+valid/test 监督 | `f163eedf` | APPROVE；preflight strict exit0 我独立复跑过 |
| #32 docs 整编 | `e01aa7c3` | 按 66 文件裁决表构建，%43 复核 APPROVE，**MERGEABLE** |

## 三、今天替您默认锁的（可异步翻，不用回复）

1. **F-044 阈值**：A 15/15 底线 / B draft 14/15 / D base 18/34 锚 / query→actuation 零容忍。
2. **GF 消减 rev3**：136/136 映射，default lock。
3. **N5E 扩量 12 题中 10 题**：C 混合形态（warmup 50→75）/ 批契约六条款（ledger 与 hash 重算 fail-closed）/ judge 机械-语义分工抽样 / salvage 全量重判两 stop gate / 声称分层（抽样禁升格全量）等——三份执行契约已 rev2.1。
4. **canary 裁决**：60 行两轮收敛 PASS（v1 FAIL=跨厂商 judge 抓溯源缺陷，一轮修复）；diversity 长度带宽 WARN 不翻改、折进批契约。

## 四、可选（不催）

- **M2 树清理授权**：逐分支 rev-list 盘点已 ready（`M2-TREE-CLEANUP-INVENTORY.md`），您授权时一次性清。
- 训练风险提醒（run-auth 时再看）：B 11/15 未达门、D 轴 18→8→5 窄化、query→actuation 安全级——配方锚与 runbook 门已备好。
