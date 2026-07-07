#!/usr/bin/env python3
import base64
import pathlib
import re
import sys

RECEIPT_MARKER = "W20A_RUNTIME_RECEIPT_JSON_BASE64="


def main(argv: list[str]) -> int:
    if len(argv) != 3:
        print(
            "usage: extract_w20a_receipt_from_xcode_stdout.py <ios-destination-stdout.log> <artifact_dir>",
            file=sys.stderr,
        )
        return 1
    stdout_path = pathlib.Path(argv[1])
    artifact_dir = pathlib.Path(argv[2])
    stdout = stdout_path.read_text(encoding="utf-8", errors="replace")
    matches = re.findall(rf"{RECEIPT_MARKER}([A-Za-z0-9+/=]+)", stdout)
    if not matches:
        print("BLOCK missing runtime receipt marker in xcode stdout", file=sys.stderr)
        return 1
    receipt_json = base64.b64decode(matches[-1]).decode("utf-8")
    artifact_dir.mkdir(parents=True, exist_ok=True)
    (artifact_dir / "runtime-adapter-mount-receipt.v2.json").write_text(receipt_json, encoding="utf-8")
    print("PASS extracted runtime-adapter-mount-receipt.v2.json")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
