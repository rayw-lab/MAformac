---
kind: governance-freeze-notice
as_of: 2026-07-21
authority: WP0-3 (Phase 0 WBS v2.1)
freeze_period: 6 months (until 2027-01-21)
---

# 治理 Checker 冻结通知

## 冻结规则

从 2026-07-21 起，**禁止新增 governance checker**（包括但不限于：scripts/check_*.py、scripts/verify_*.py、Tests/ 中新增的 *GovernanceTests.swift、Makefile 新增 verify-* target）。

## 例外条件（同时满足才可新增）

1. 书面说明该 checker 验证的是**产品行为**（非治理自洽）
2. 磊哥亲批
3. grok 异源二审通过

## 砍削期纪律

- 冻结期内新增 checker 净增 > 0 = 政策锚定失效信号
- 现有 checker 不删不改（砍削在 Phase 2 WP2-5 统一做）
- 健康度 KP：每月核查 checker 数量变化

## 事实锚

产品当前正向目录=12 个评审入口（空调调温是 18–32 整数边界模板，其余为精确话术）/ App 仍未接模型 / 多意图未准入 / actionDemoProven=0/120。
治理 checker 数量 ≠ 产品进展。