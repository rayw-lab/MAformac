---
name: closeout-receipt-writer
description: Use when 一个 apply/重型任务/审计 wave 收口需要写 receipt 证据。症状:想用 hardcoded pass、读 metadata flag 自证 verdict、凭印象写状态、或 receipt 与实跑 log 脱节;0-34 灾难根因正是 receipt 读自己的 metadata flag 翻 pass、零 token 证据。
---

# Closeout Receipt Writer

## Overview

receipt 的 verdict **必来自实跑 evidence**（命令 + exit_code + 输出 sha256），**不来自 metadata flag 或声称**。

**Core principle:** receipt 是「实跑发生过」的不可篡改证据,不是「我认为完成了」的自陈。**verdict 读 evidence_path,不读状态字段**。

**Violating the letter of this rule is violating the spirit of this rule.**

## When to Use

- apply / 重型重构 / 审计 wave / 长跑 step 收口要落 receipt
- 症状:想写 `"status": "pass"` 而没附实跑 log / verdict 来自某 bool 字段 / 验证器读同一 metadata 做判断

**NOT for:** 临时探查 / 不作交付证据的中间产物。

## REQUIRED 字段（structural — 缺一不算 receipt）

锚 schema `docs/project/receipts/local-receipt.schema.json`（`additionalProperties:false`）:

| 字段 | 必含 |
|---|---|
| `receipt_id / created_at / change_id` | 标识 |
| `base_commit / head_commit / dirty_worktree` | git 锚 |
| `proof_class` | enum:`openspec_apply_local` / `local_tests_only` / `manual_review_evidence` |
| **`commands[]`** | 每条 `{cmd, exit_code, verdict∈[pass,fail,blocked], evidence_path, sha256(64hex)}` |
| `mechanical_gates` | 每门 pass/fail/blocked |
| `claim_boundaries` | 必含「本 receipt **不**声称什么」（如 `no_training_no_golden_no_voice`） |

## Prohibition（禁 — discipline 失守点）

- ❌ **hardcoded pass** —— verdict 必来自 `commands[].evidence_path` 里的实跑输出,不手写 `pass`。
- ❌ **读 metadata flag 自证** —— 如 `usesTrainingTokenizerPatch=true → pass`(0/34 灾难);verdict 用实际产物文本/token 证据,不用 bool 字段。
- ❌ **验证器读同一 metadata 判断** —— 循环失守(被同一个谎蒙蔽);recompute 用白名单命令重跑 + hash 比对。
- ❌ **状态冒充** —— `train_health ≠ model_quality ≠ V-PASS`,scoped 不互冒充。

## Recipe

1. 每条 verify command **实跑** → 存输出到 `evidence_path` → 算 `sha256` → verdict 从输出读（非手写）。
2. 填 `mechanical_gates`（各门实跑结果）+ `claim_boundaries`（划清不声称什么）。
3. 渲染 **JSON + Markdown twin**（机器核 + 人读）。
4. 落 `Reports/<task>-<YYYYMMDD[THHMM]>-<variant>/receipt.json`。

## Red Flags — STOP

- 写 `"verdict":"pass"` 但没对应 `evidence_path` + `sha256`
- verdict 来自某 bool/flag 字段
- "诚实报告了失败"就判 receipt 合规 PASS（合规 ≠ 成功;审计抓"假装成功"抓不到"为何必然失败"）
- 同一 metadata 既被 receipt 写、又被验证器读

## Real-World Impact

MAformac `0/34` 通宵灾难:receipt 读自己 metadata `usesTrainingTokenizerPatch` 直翻 pass、零 token 证据,4556 样本未验真 tokenizer;`fuse_parity_gate.status:fail` 与父 `status:smoke_only_ready` 顶层绿/轴内 fail 并存。配 schema `docs/project/receipts/local-receipt.schema.json` + rule `claim-vs-reality-gap` 铁律 1/2（enforce 非 declare、审计实跑非读 receipt）+ `completion-claim-triage`。
