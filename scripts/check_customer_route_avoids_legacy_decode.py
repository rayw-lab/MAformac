#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]


def check(root: Path = ROOT) -> list[str]:
    failures: list[str] = []
    backend = (root / "Core/LLM/DDomainToolPlanBackend.swift").read_text()
    parser = (root / "Core/LLM/DDomainToolCallParser.swift").read_text()
    router = (root / "Core/LLM/DemoNLURouter.swift").read_text()

    if "DDomainToolCallParser.parse(envelope" not in backend:
        failures.append("customer backend must pass a typed envelope to DDomainToolCallParser")
    if "public static func parse(_ completion: String)" in parser:
        failures.append("production parser must not expose the legacy bare-string parse entrypoint")
    if "DDomainToolCallParser" in router:
        failures.append("DemoNLURouter must delegate decoding to LLMBackend")
    for scope in (root / "Core", root / "App"):
        if not scope.exists():
            continue
        for path in scope.rglob("*.swift"):
            text = path.read_text()
            if path.name != "DDomainToolPlanBackend.swift" and "DDomainToolPlanBackend" in text and "completionProvider:" in text:
                failures.append(f"customer/runtime call site uses legacy completionProvider: {path.relative_to(root)}")
    return failures


if __name__ == "__main__":
    errors = check()
    for error in errors:
        print(error, file=sys.stderr)
    raise SystemExit(1 if errors else 0)
