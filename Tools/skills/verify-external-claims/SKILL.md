---
name: verify-external-claims
description: Use when 一个多路 workflow/finder 调研、deep-research、或综合官报告引用了 arxiv ID、精确数字（调用数/百分比/star/benchmark）、或 repo 活跃度断言,且这些要驱动决策。症状:finder 在搜证压力下高发编造精确数字 + 引用 ID,且常安到真实存在的 source 上(issue/论文真、数字假),综合官即使做了本机 grep 也漏外部声称。
---

# Verify External Claims

## Overview

派出去的 finder 在搜证压力下**高发编造**精确数字与引用 ID,而且**常把假数字安到真实存在的 source 上**（issue/论文是真的,数字是编的）——这是最难 catch 的一类。

**Core principle:** 综合官即使做了本机 grep cite-verify,也**漏外部声称**（本机可核、arxiv/issue 不会主动核）。**驱动决策的外部数字/引用 ID,主线程必亲核,不信"综合官说核了"。**

## When to Use

- 多路 workflow / finder 调研收口,结论引了 arxiv ID / 精确数字 / repo star / benchmark
- deep-research / oracle 产出要拿外部声称驱动选型、配方、决策
- 症状:报告里出现精确到位的数字（"234760 调用 / 6.2%→33.7%"）或 arxiv 编号——越精确越要警惕

**NOT for:** 纯本机可 grep 核的内部数字（那走 cite-verify / cross_section_check）。

## Recipe（核什么 + 怎么核）

1. **抽 load-bearing 外部声称**（只核驱动决策的,不核全部）：arxiv ID / 精确数字 / repo star+pushedAt / benchmark 排名。
2. **亲核（workflow 跑期间可并行）**：
   - arxiv ID → WebSearch「arxiv <ID>」:搜得到吗?venue/作者/标题对吗?（编造 ID 搜不到或对不上）
   - 精确数字 → 回该 source 读原文:数字真在里面吗?（finder 常把假数字安到真 issue/论文上）
   - repo 活跃 → `gh repo view <owner/repo> --json stargazerCount,pushedAt`:star + 近 60 天活跃双指标
3. **建核实表**:`声称 | 权威值 | 状态(✓/✗编造) | source URL`。
4. **finder 回稿逐条对照,引错即 catch + 就地标注"勿引"**,不让假数字进决策/归档。

## Red Flags — STOP 核

- 报告给出**异常精确**的数字（六位调用数、精确百分比变化）→ 高编造嫌疑
- arxiv ID 没附标题/作者 → 先 WebSearch 验存在
- "综合官说核过了" → 综合官核本机,漏外部;主线程仍亲核
- `grep | uniq -c` 当"N 路引用" → 那是**出现次数**非路数（口径自纠）

## Real-World Impact

MAformac 实证:18 路 lora-deepdive 抽样即 catch **1 个编造 arxiv `2603.03203`**（单路 5 次引用一个搜不到的 ID）;另案 finder 编 issue#42796「234760 调用 / 6.2%→33.7%」+ arxiv `2603.05344`（真 `2507.14417`）——**综合官本机 grep 漏掉,主线程 gh/WebSearch 才 catch**。元层自证:调研"AI 凭印象"的 workflow 自己 finder 凭印象编数字 = enforce>自觉。配 rule `ultracode-deep-research-7lens` 横切纪律 7 + `claim-vs-reality-gap` 第 8 坑。
