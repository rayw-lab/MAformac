#!/usr/bin/env python3
import subprocess
import sys
import tempfile
from pathlib import Path


REPO = Path(__file__).resolve().parents[1]
CHECK = REPO / "scripts" / "cross_section_check.py"


def run(*args, cwd=None):
    return subprocess.run(args, cwd=cwd, text=True, capture_output=True)


def make_repo(receipt_text, receipt_path="LOCAL-RECEIPT.md"):
    tmp = tempfile.TemporaryDirectory()
    root = Path(tmp.name)
    run("git", "init", "-q", cwd=root).check_returncode()
    receipt = root / receipt_path
    receipt.parent.mkdir(parents=True, exist_ok=True)
    receipt.write_text(receipt_text, encoding="utf-8")
    return tmp, root


def main():
    good_tmp, good_root = make_repo("status: PASS\nbasis_id: CODE-2026-07-03-PR38\n")
    with good_tmp:
        good = run(sys.executable, str(CHECK), str(good_root))
        if good.returncode != 0 or '"receipt_basis_missing": []' not in good.stdout:
            print(good.stdout)
            print(good.stderr, file=sys.stderr)
            raise SystemExit("positive receipt fixture should pass")

    bad_tmp, bad_root = make_repo("status: PASS\n")
    with bad_tmp:
        bad = run(sys.executable, str(CHECK), str(bad_root))
        if bad.returncode == 0 or "LOCAL-RECEIPT.md" not in bad.stdout:
            print(bad.stdout)
            print(bad.stderr, file=sys.stderr)
            raise SystemExit("negative receipt fixture should fail")

    docs_bad_tmp, docs_bad_root = make_repo("status: PASS\n", "docs/TEST-RECEIPT-mt2-negative.md")
    with docs_bad_tmp:
        docs_bad = run(sys.executable, str(CHECK), str(docs_bad_root))
        if docs_bad.returncode == 0 or "docs/TEST-RECEIPT-mt2-negative.md" not in docs_bad.stdout:
            print(docs_bad.stdout)
            print(docs_bad.stderr, file=sys.stderr)
            raise SystemExit("docs root negative receipt fixture should fail")

    docs_good_tmp, docs_good_root = make_repo("status: PASS\nbasis: CODE-2026-07-03-PR38\n", "docs/TEST-RECEIPT-mt2-positive.md")
    with docs_good_tmp:
        docs_good = run(sys.executable, str(CHECK), str(docs_good_root))
        if docs_good.returncode != 0 or "docs/TEST-RECEIPT-mt2-positive.md" not in docs_good.stdout:
            print(docs_good.stdout)
            print(docs_good.stderr, file=sys.stderr)
            raise SystemExit("docs root positive receipt fixture should pass")

    frozen_tmp, frozen_root = make_repo("status: PASS\n", "docs/evidence-frozen/HISTORICAL-RECEIPT.md")
    with frozen_tmp:
        frozen = run(sys.executable, str(CHECK), str(frozen_root))
        if frozen.returncode != 0 or "docs/evidence-frozen/HISTORICAL-RECEIPT.md" in frozen.stdout:
            print(frozen.stdout)
            print(frozen.stderr, file=sys.stderr)
            raise SystemExit("docs/evidence-frozen historical receipt fixture should be exempt")

    print("receipt_basis_gate_fixtures=ok")


if __name__ == "__main__":
    main()
