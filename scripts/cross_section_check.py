#!/usr/bin/env python3
"""cross-section-check：基线文档组【段间一致性】（§35 级联 drift / claim-vs-reality 第10变体）。

只查 internal 一致性（同一锚的数字跨段/跨文档是否分叉），**不查 correctness**（值一致但错抓不到）。

🔴 EN3 只检【存档态】：跳过显式标 SUPERSEDED/旧算/留史/deprecated/grill 演进痕迹 的行
   （grill 期数字主动变 ζ 11/30→10/23 是过程非 bug；这些行是有意保留的历史，不算分叉）。
🔴 pG4 路径白名单：只 enforce 基线文档组（非全 docs/**）。

锚（drift-prone，实测过的）：mp_positive_action 分数（曾 11/30 vs 10/23 分叉）。
扩展：在 ANCHOR_KEYWORDS 加关键词即可纳入更多锚。

用法: cross_section_check.py [repo_root]
退出: 0=无分叉 / 1=发现分叉
"""
import glob
import json
import os
import re
import subprocess
import sys

# pG4 基线文档组（路径白名单，相对 repo root）
# finding round-03：加 docs/grill-tournament/*（第一个长跑新 grill SSOT：cascade-inventory /
#   grill-decisions-master / final-grill-list 等），否则口径级联（534→562 全仓回写）无机械门兜底。
BASELINE_GLOBS = [
    "docs/c5-recovery-2026-06-22/*.md",
    "docs/roadmap-2026-06-20-from-c6-done.md",
    "docs/grill-tournament/*.md",
    # v6 active baseline + commander decisions authority (exact paths; NO bare commander-log/*.md)
    # roster-sync rule v2 修法2: registry/authority-derived expected set, not heterogeneous glob.
    "docs/roadmap-2026-07-11-v6-closure-baseline.md",
    "docs/commander-log/decisions.md",
]

# 存档态过滤：含这些标记的【行】跳过（有意保留的历史/被取代值）
# 注：口径锚里 534/2086 等废口径行几乎必带「废/作废/已废/旧/SUPERSEDED」标记 → 被本过滤跳过，
#     只剩权威 562/2159 行参与一致性比对（避免「权威 vs 废口径」误报为 drift）。
SUPERSEDED_MARKERS = re.compile(
    r"SUPERSEDED|SUPERSEDES|旧算|留史|deprecated|演进痕迹|第6同坑前|过程非 bug|历史|曾误|纠正前|废口径|作废|已废|禁引|禁再引|旧口径|534-era|边注"
)

# 锚关键词 → 紧跟的分数模式（分数型锚：跨段同一分数不应分叉）
ANCHOR_KEYWORDS = ["mp_positive_action"]
FRACTION = re.compile(r"\b(\d{1,4})\s*/\s*(\d{1,4})\b")

# 口径单值锚（finding round-03）：跨文件断言同一个量的【权威单值】，分叉=drift。
# key = 锚关键词（出现在【权威断言】行），value = 该量的【唯一允许值集合】（写多个=多个等价表述）。
# 机制：锚关键词后必须【紧跟】赋值符号（= ＝ : ：）或「数/＝」+ 整数，才算「权威断言」；
#   prose（如「10 族 device 边界（CC 422 vs ...」）中关键词后是文字不是赋值 → 不命中（避免误报）。
#   废口径行（带「废/作废/旧/边注」标记）已被 SUPERSEDED_MARKERS 跳过，不参与。
CALIBER_ANCHORS = {
    "10 族 intent": {"562"},          # 磊哥 2026-06-23 终拍权威
    "10 族 device": {"191"},
    "族外 intent": {"976"},
}
# 锚后紧跟赋值（允许中间至多一个「数」字 + 空白 + = ＝ : ：），再抓整数
INT_AFTER = re.compile(r"^\s*数?\s*[=＝:：]\s*\**\s*(\d{2,4})")

RECEIPT_BASIS = re.compile(r"\b(basis_id|basis)\s*:")


def git_paths(root, *args):
    try:
        out = subprocess.check_output(
            ["git", "-C", root, *args],
            text=True,
            stderr=subprocess.DEVNULL,
        )
    except (OSError, subprocess.CalledProcessError):
        return []
    return [line.strip() for line in out.splitlines() if line.strip()]


def changed_receipt_paths(root):
    paths = set()
    paths.update(git_paths(root, "diff", "--name-only", "--diff-filter=AM", "HEAD", "--"))
    paths.update(git_paths(root, "diff", "--cached", "--name-only", "--diff-filter=AM", "--"))
    paths.update(git_paths(root, "ls-files", "--others", "--exclude-standard"))
    result = []
    for rel in sorted(paths):
        name = os.path.basename(rel)
        if not rel.endswith(".md"):
            continue
        if "RECEIPT" not in name and "receipt" not in name:
            continue
        if rel.startswith("docs/evidence-frozen/"):
            continue
        if rel == "runs/README.md":
            continue
        result.append(rel)
    return result


def receipt_basis_violations(root):
    violations = []
    checked = []
    for rel in changed_receipt_paths(root):
        path = os.path.join(root, rel)
        try:
            with open(path, encoding="utf-8") as f:
                text = f.read()
        except OSError:
            continue
        checked.append(rel)
        if not RECEIPT_BASIS.search(text):
            violations.append(rel)
    return checked, violations


def main():
    root = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()
    files = []
    for g in BASELINE_GLOBS:
        files.extend(sorted(glob.glob(os.path.join(root, g))))

    # anchor -> { value -> [ "file:line" ] }（仅存档态行）
    anchors = {kw: {} for kw in ANCHOR_KEYWORDS}
    # 口径锚命中非允许值的行（finding round-03）
    caliber_violations = []

    for path in files:
        rel = os.path.relpath(path, root)
        try:
            with open(path, encoding="utf-8") as f:
                lines = f.readlines()
        except OSError:
            continue
        for i, line in enumerate(lines, 1):
            if SUPERSEDED_MARKERS.search(line):
                continue  # EN3：跳过被取代/历史行
            for kw in ANCHOR_KEYWORDS:
                if kw not in line:
                    continue
                # 取该行 kw 之后最近的一个分数（锚的当前值）
                seg = line.split(kw, 1)[1]
                m = FRACTION.search(seg)
                if not m:
                    continue
                val = f"{int(m.group(1))}/{int(m.group(2))}"
                anchors[kw].setdefault(val, []).append(f"{rel}:{i}")
            # 口径单值锚：抓关键词后紧跟的整数，必须 ∈ 允许集合
            for kw, allowed in CALIBER_ANCHORS.items():
                if kw not in line:
                    continue
                seg = line.split(kw, 1)[1]
                m = INT_AFTER.search(seg)
                if not m:
                    continue
                got = m.group(1)
                if got not in allowed:
                    caliber_violations.append(
                        {"anchor": kw, "found": got, "allowed": sorted(allowed), "loc": f"{rel}:{i}"}
                    )

    drifts = []
    for kw, valmap in anchors.items():
        if len(valmap) > 1:
            drifts.append({"anchor": kw, "distinct_values": {v: locs for v, locs in sorted(valmap.items())}})

    receipt_basis_checked, receipt_basis_missing = receipt_basis_violations(root)

    out = {
        "baseline_files": [os.path.relpath(p, root) for p in files],
        "anchors_checked": ANCHOR_KEYWORDS,
        "caliber_anchors_checked": sorted(CALIBER_ANCHORS),
        "receipt_basis_checked": receipt_basis_checked,
        "receipt_basis_missing": receipt_basis_missing,
        "drifts": drifts,
        "caliber_violations": caliber_violations,
        "consistent": len(drifts) == 0 and len(caliber_violations) == 0 and len(receipt_basis_missing) == 0,
    }
    print(json.dumps(out, sort_keys=True, ensure_ascii=False, indent=2))
    return 0 if out["consistent"] else 1


if __name__ == "__main__":
    sys.exit(main())
