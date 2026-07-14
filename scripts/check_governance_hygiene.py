#!/usr/bin/env python3
"""Small fail-closed checks for MAformac governance surfaces."""

from __future__ import annotations

import argparse
import datetime as dt
import json
import re
import sys
import tomllib
from pathlib import Path


NEVER_EXEMPT = {
    "secrets_credentials_tokens",
    "personal_data",
    "pricing_and_cost",
    "real_customer_identity",
    "restricted_internal_source_text",
    "training_data_from_restricted_sources",
}
ALLOWED_CARRIERS = {"docs/research/**", "referencerepo/reports/**"}
PATCH_RESIDUE_FILES = (
    "MEMORY.md",
    "docs/lessons-learned.md",
    "docs/commander-log/decisions.md",
)
FRONTMATTER_FILES = (
    "CLAUDE.md",
    "docs/CURRENT.md",
    "docs/project/collaboration-and-roles.md",
)


def read_text(root: Path, relative: str, errors: list[str]) -> str:
    path = root / relative
    if not path.is_file():
        errors.append(f"E_MISSING:{relative}")
        return ""
    return path.read_text(encoding="utf-8")


def frontmatter(text: str, relative: str, errors: list[str]) -> dict[str, str]:
    lines = text.splitlines()
    if not lines or lines[0] != "---":
        errors.append(f"E_FRONTMATTER_MISSING:{relative}")
        return {}
    try:
        end = lines.index("---", 1)
    except ValueError:
        errors.append(f"E_FRONTMATTER_UNCLOSED:{relative}")
        return {}
    result: dict[str, str] = {}
    for line in lines[1:end]:
        match = re.match(r"^([A-Za-z_][A-Za-z0-9_-]*):\s*(.*)$", line)
        if not match:
            continue
        key, value = match.groups()
        if key in result:
            errors.append(f"E_FRONTMATTER_DUPLICATE:{relative}:{key}")
        result[key] = value.strip().strip('"')
    return result


def check_codex_config(root: Path, errors: list[str]) -> None:
    relative = ".codex/config.toml"
    path = root / relative
    try:
        data = tomllib.loads(path.read_text(encoding="utf-8"))
    except (OSError, tomllib.TOMLDecodeError) as exc:
        errors.append(f"E_CODEX_CONFIG_PARSE:{exc}")
        return
    if data.get("approval_policy") != "on-request":
        errors.append("E_CODEX_APPROVAL_POLICY")
    if data.get("sandbox_mode") != "workspace-write":
        errors.append("E_CODEX_SANDBOX_MODE")


def check_openspec_config(root: Path, errors: list[str]) -> None:
    text = read_text(root, "openspec/config.yaml", errors)
    if not re.search(r"(?m)^schema:\s*spec-driven\s*$", text):
        errors.append("E_OPENSPEC_SCHEMA")
    if not re.search(r"(?m)^context:\s*\|\s*$", text) or not re.search(r"(?m)^rules:\s*$", text):
        errors.append("E_OPENSPEC_STRUCTURE")
    banned = {
        "define-c1c2-contract": r"define-c1c2-contract",
        "vendor_dispatch": r"\b(Codex|Claude|Grok|Hermes)\b",
        "provider": r"\bprovider\b",
        "operator_state": r"\b(pane|PID|simulator)\b",
        "repo_visibility": r"repo.{0,20}\b(public|private)\b",
    }
    for name, pattern in banned.items():
        if re.search(pattern, text, flags=re.IGNORECASE):
            errors.append(f"E_OPENSPEC_DYNAMIC:{name}")


def check_exception_registry(root: Path, as_of: dt.date, errors: list[str]) -> None:
    relative = "contracts/governance/public-repo-exceptions.v1.json"
    try:
        data = json.loads((root / relative).read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        errors.append(f"E_EXCEPTION_REGISTRY_PARSE:{exc}")
        return
    if data.get("schema_version") != 1 or data.get("default_policy") != "deny":
        errors.append("E_EXCEPTION_REGISTRY_HEADER")
    never = set(data.get("never_exempt", []))
    if never != NEVER_EXEMPT:
        errors.append("E_EXCEPTION_NEVER_EXEMPT")
    exceptions = data.get("exceptions")
    if not isinstance(exceptions, list) or not exceptions:
        errors.append("E_EXCEPTION_EMPTY")
        return
    ids: set[str] = set()
    for item in exceptions:
        required = {
            "id", "status", "basis", "valid_from", "expires_on",
            "allowed_subjects", "allowed_carriers", "conditions", "never_overrides",
        }
        if not isinstance(item, dict) or not required.issubset(item):
            errors.append("E_EXCEPTION_FIELDS")
            continue
        item_id = item["id"]
        if item_id in ids:
            errors.append(f"E_EXCEPTION_DUPLICATE:{item_id}")
        ids.add(item_id)
        try:
            valid_from = dt.date.fromisoformat(item["valid_from"])
            expires_on = dt.date.fromisoformat(item["expires_on"])
        except (TypeError, ValueError):
            errors.append(f"E_EXCEPTION_DATE:{item_id}")
            continue
        if valid_from > expires_on:
            errors.append(f"E_EXCEPTION_DATE_ORDER:{item_id}")
        if item["status"] == "active" and expires_on < as_of:
            errors.append(f"E_EXCEPTION_EXPIRED_ACTIVE:{item_id}")
        if set(item["allowed_carriers"]) != ALLOWED_CARRIERS:
            errors.append(f"E_EXCEPTION_CARRIERS:{item_id}")
        if set(item["never_overrides"]) != never:
            errors.append(f"E_EXCEPTION_OVERRIDE_GAP:{item_id}")
        if not item["allowed_subjects"] or not item["conditions"]:
            errors.append(f"E_EXCEPTION_UNBOUNDED:{item_id}")
        basis_parts = str(item["basis"]).split("#", 1)
        basis_path = basis_parts[0]
        if not (root / basis_path).is_file():
            errors.append(f"E_EXCEPTION_BASIS_MISSING:{item_id}")
        elif len(basis_parts) != 2 or basis_parts[1] not in (root / basis_path).read_text(encoding="utf-8"):
            errors.append(f"E_EXCEPTION_BASIS_ANCHOR:{item_id}")


def check_authority_surfaces(root: Path, errors: list[str]) -> None:
    claude = read_text(root, "CLAUDE.md", errors)
    agents = read_text(root, "AGENTS.md", errors)
    if "## 3. Authority matrix" not in claude:
        errors.append("E_AUTHORITY_MATRIX")
    if "不作为工作约束" in claude or "单一权威源 =" in agents:
        errors.append("E_BLANKET_OR_SINGLE_AUTHORITY")
    marker_count = sum(text.count("<!-- gitnexus:start -->") for text in (agents, claude))
    end_count = sum(text.count("<!-- gitnexus:end -->") for text in (agents, claude))
    if marker_count != 1 or end_count != 1:
        errors.append("E_GITNEXUS_MANAGED_BLOCK_COUNT")
    if "起手三步" in agents or "/Users/wanglei/.codex/AGENTS.md §13" in agents:
        errors.append("E_AGENT_ROUTE_DRIFT")
    if "起手必读" in claude and "lessons-learned.md" in claude:
        errors.append("E_LESSONS_FULL_READ")
    readme = read_text(root, "docs/README.md", errors)
    if "CLAUDE.md §9" in readme or "当前 baseline 指针" in readme:
        errors.append("E_DOC_MAP_DYNAMIC_ROUTE")


def check_current_chain(root: Path, errors: list[str]) -> None:
    current_text = read_text(root, "docs/CURRENT.md", errors)
    for name, pattern in {
        "process_state": r"\b(?:pane|PID)\b",
        "provider_state": r"\bprovider\b",
        "machine_path": r"/Users/",
        "tonight_route": r"今晚|今夜",
    }.items():
        if re.search(pattern, current_text, flags=re.IGNORECASE):
            errors.append(f"E_CURRENT_DYNAMIC:{name}")
    current = frontmatter(current_text, "docs/CURRENT.md", errors)
    latest = current.get("latest_handoff")
    if not latest:
        errors.append("E_CURRENT_LATEST_HANDOFF")
        return
    handoff_text = read_text(root, latest, errors)
    handoff = frontmatter(handoff_text, latest, errors)
    for key in ("predecessor", "supersedes"):
        if not handoff.get(key):
            errors.append(f"E_HANDOFF_CHAIN:{key}")
    predecessor = handoff.get("predecessor")
    if predecessor and not (root / predecessor).is_file():
        errors.append("E_HANDOFF_PREDECESSOR_MISSING")


def check_structure(root: Path, errors: list[str]) -> None:
    for relative in FRONTMATTER_FILES:
        frontmatter(read_text(root, relative, errors), relative, errors)
    residue = re.compile(r"(?m)^(?:\+\+ b/.+|\+)\s*$")
    for relative in PATCH_RESIDUE_FILES:
        if residue.search(read_text(root, relative, errors)):
            errors.append(f"E_PATCH_RESIDUE:{relative}")
    for base in (root / ".claude", root / ".codex"):
        if not base.exists():
            continue
        for path in base.rglob("*"):
            if path.is_file() and (".bak" in path.name or path.name.endswith(("~", ".orig"))):
                errors.append(f"E_LIVE_CONFIG_BACKUP:{path.relative_to(root)}")
    for prefix in (root / ".claude/skills", root / ".codex/skills"):
        if prefix.exists() and any(prefix.glob("openspec-*/SKILL.md")):
            errors.append(f"E_PROJECT_OPENSPEC_SKILL_DUPLICATE:{prefix.relative_to(root)}")
    roadmap = read_text(root, "docs/roadmap-2026-07-11-v6-closure-baseline.md", errors)
    try:
        manual = roadmap.split("### 进度 verdict", 1)[1].split("<!-- O1:GENERATED:START", 1)[0]
    except IndexError:
        errors.append("E_ROADMAP_GENERATED_MARKERS")
    else:
        if re.search(r"\b(?:done|blocked|planned|gap|ready|running|paused)=\d+", manual):
            errors.append("E_ROADMAP_MANUAL_CANONICAL_COUNT")


def check_make_wiring(root: Path, errors: list[str]) -> None:
    makefile = read_text(root, "Makefile", errors)
    for target in ("verify", "verify-ci"):
        match = re.search(rf"(?m)^{re.escape(target)}:\s*([^\n]*)$", makefile)
        if not match or "verify-governance-hygiene" not in match.group(1).split():
            errors.append(f"E_MAKE_WIRING:{target}")
    body = re.search(r"(?ms)^verify-governance-hygiene:\s*\n((?:\t.*\n)+)", makefile)
    if not body or "test_check_governance_hygiene.py" not in body.group(1) or "check_governance_hygiene.py" not in body.group(1):
        errors.append("E_MAKE_TARGET_BODY")


def run(root: Path, as_of: dt.date) -> list[str]:
    errors: list[str] = []
    check_codex_config(root, errors)
    check_openspec_config(root, errors)
    check_exception_registry(root, as_of, errors)
    check_authority_surfaces(root, errors)
    check_current_chain(root, errors)
    check_structure(root, errors)
    check_make_wiring(root, errors)
    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--as-of", type=dt.date.fromisoformat, default=dt.date.today())
    args = parser.parse_args()
    errors = run(args.repo.resolve(), args.as_of)
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1
    print("governance_hygiene=ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
