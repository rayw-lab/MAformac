#!/usr/bin/env python3
import json
import pathlib
import re
import sys

FORBIDDEN_PATTERNS = [
    re.compile(r"\bV-PASS\s+achieved\b", re.IGNORECASE),
    re.compile(r"\bcandidate\s+signed\b", re.IGNORECASE),
    re.compile(r"\badapter_learned_qa\s*=\s*true\b", re.IGNORECASE),
]


def fail(message: str) -> int:
    print(f"BLOCK {message}", file=sys.stderr)
    return 1


def read_text_files(root: pathlib.Path) -> str:
    chunks: list[str] = []
    for path in root.rglob("*"):
        if path.is_file() and path.suffix.lower() in {".json", ".log", ".md", ".txt"}:
            chunks.append(path.read_text(encoding="utf-8", errors="replace"))
    return "\n".join(chunks)


def load_receipt(root: pathlib.Path) -> dict:
    receipt_path = root / "runtime-adapter-mount-receipt.v2.json"
    if not receipt_path.exists():
        raise ValueError("missing runtime-adapter-mount-receipt.v2.json")
    return json.loads(receipt_path.read_text(encoding="utf-8"))


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        return fail("usage: check_w20a_claim_envelope.py <closeout_artifact_dir>")
    root = pathlib.Path(argv[1])
    if not root.is_dir():
        return fail(f"artifact dir not found: {root}")

    text = read_text_files(root)
    for pattern in FORBIDDEN_PATTERNS:
        if pattern.search(text):
            return fail(f"forbidden claim matched: {pattern.pattern}")

    try:
        receipt = load_receipt(root)
    except Exception as exc:
        return fail(str(exc))

    if receipt.get("schema_version") != "runtime_adapter_mount_receipt.v2":
        return fail("receipt schema is not runtime_adapter_mount_receipt.v2")
    if receipt.get("runtime_target") != "ios_sim":
        return fail("receipt runtime_target is not ios_sim")
    if not receipt.get("ir_map_fingerprint"):
        return fail("missing ir_map_fingerprint")
    if not receipt.get("mounted_demo_catalog_sha"):
        return fail("missing mounted_demo_catalog_sha")
    non_claims = receipt.get("non_claims") or {}
    if non_claims.get("adapter_learned_qa") is not False:
        return fail("adapter_learned_qa must be false")
    if non_claims.get("candidate_status") != "unsigned":
        return fail("candidate_status must be unsigned")

    stdout_path = root / "ios-destination-stdout.log"
    if stdout_path.exists() and "runtime_target=ios_sim" not in stdout_path.read_text(encoding="utf-8", errors="replace"):
        return fail("iOS destination stdout does not match runtime_target=ios_sim")

    print("PASS W20A claim envelope")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
