#!/usr/bin/env python3
"""共享：C6 axis schema-field 拆分 + action hard_pass 复算。

🔴 锁定算法（harness-enforce-impl-lessons §1，实测 base 10/23 坐实）：
- scope: eval_runs 过滤 case_id 前缀（默认 C6-MP = MP 场景族）
- JOIN: case_id × c6-bench-cases.jsonl（含 expect_no_call/pre_state/expected_state_delta）
- schema 三分类（顺序敏感，refusal 先排，防 noop 双计）：
    refusal  = expect_no_call==True
    noop     = (非 refusal) AND expected_state_delta 非空 AND delta 各 key 在 pre 已是该值（应用无变化）
    positive = 非 refusal AND 非 noop
- action hard_pass（不含 readback）= gate_result.tool_call_set_match AND state_delta_match
"""
import json
import sys


def load_cases(path):
    out = {}
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            c = json.loads(line)
            out[c["case_id"]] = c
    return out


def load_summary(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def is_refusal(case):
    return case.get("expect_no_call") is True


def is_noop(case):
    if is_refusal(case):
        return False
    delta = case.get("expected_state_delta") or {}
    pre = case.get("pre_state") or {}
    if not delta:
        return False
    return all(str(pre.get(k)) == str(v) for k, v in delta.items())


def is_positive(case):
    return (not is_refusal(case)) and (not is_noop(case))


def classify(summary, cases, scope_prefix="C6-MP"):
    """返回 {positive:[run], noop:[run], refusal:[run], unknown:[run]}。"""
    buckets = {"positive": [], "noop": [], "refusal": [], "unknown": []}
    for r in summary.get("eval_runs", []):
        cid = r.get("case_id", "")
        if scope_prefix and not cid.startswith(scope_prefix):
            continue
        case = cases.get(cid)
        if case is None:
            buckets["unknown"].append(r)
        elif is_refusal(case):
            buckets["refusal"].append(r)
        elif is_noop(case):
            buckets["noop"].append(r)
        else:
            buckets["positive"].append(r)
    return buckets


def action_hard_pass(runs):
    """positive runs 中 tcm && sdm（不含 readback）的计数。"""
    hp = 0
    for r in runs:
        g = r.get("gate_result", {})
        if g.get("tool_call_set_match") and g.get("state_delta_match"):
            hp += 1
    return hp
