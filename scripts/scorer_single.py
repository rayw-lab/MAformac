#!/usr/bin/env python3
"""scorer-single：核 hard_pass scorer 只有【一套产生器】（防 0/34 的 scorer 双口径）。

扫 Core/（排除 Test/.build）含 hard_pass 计算赋值的 swift 文件，断言 canonical 单源。
出现第二套 scorer 逻辑 = 双口径风险 = fail。

用法: scorer_single.py [repo_root]
"""
import json
import os
import re
import sys

CANONICAL = "Core/Bench/C6VehicleToolBench.swift"
# 计算赋值标志（非纯 enum decl / Codable decode）
MARKERS = [
    re.compile(r"hardFailed\s*="),
    re.compile(r"stateDeltaMatch\s*="),
    re.compile(r"toolCallSetMatch\s*="),
    re.compile(r"func\s+\w*[Hh]ardPass"),
]


def main():
    root = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()
    core = os.path.join(root, "Core")
    producers = []
    for dirpath, dirnames, filenames in os.walk(core):
        dirnames[:] = [d for d in dirnames if d not in (".build", "DerivedData") and not d.startswith(".")]
        if os.sep + "Test" in dirpath or dirpath.endswith("Tests"):
            continue
        for fn in filenames:
            if not fn.endswith(".swift") or "Test" in fn:
                continue
            p = os.path.join(dirpath, fn)
            try:
                with open(p, encoding="utf-8") as f:
                    txt = f.read()
            except OSError:
                continue
            if any(m.search(txt) for m in MARKERS):
                rel = os.path.relpath(p, root)
                producers.append(rel)

    producers = sorted(set(producers))
    out = {
        "canonical": CANONICAL,
        "scorer_producers": producers,
        "single_source": producers == [CANONICAL],
    }
    print(json.dumps(out, sort_keys=True, ensure_ascii=False))
    return 0 if producers == [CANONICAL] else 1


if __name__ == "__main__":
    sys.exit(main())
