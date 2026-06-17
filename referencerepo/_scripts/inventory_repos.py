#!/usr/bin/env python3
from __future__ import annotations

import json
import subprocess
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPOS = ROOT / "repos"
SNAPSHOTS = ROOT / "snapshots"
SNAPSHOTS.mkdir(exist_ok=True)

EXT_LANGUAGE = {
    ".swift": "Swift",
    ".py": "Python",
    ".rs": "Rust",
    ".go": "Go",
    ".kt": "Kotlin",
    ".kts": "Kotlin",
    ".java": "Java",
    ".ts": "TypeScript",
    ".tsx": "TypeScript",
    ".js": "JavaScript",
    ".jsx": "JavaScript",
    ".c": "C",
    ".cc": "C++",
    ".cpp": "C++",
    ".cxx": "C++",
    ".h": "C/C++",
    ".hpp": "C++",
    ".proto": "Protocol Buffers",
    ".yaml": "YAML",
    ".yml": "YAML",
    ".json": "JSON",
    ".md": "Markdown",
}


def run_git(repo: Path, *args: str) -> str:
    try:
        return subprocess.check_output(
            ["git", "-C", str(repo), *args],
            text=True,
            stderr=subprocess.DEVNULL,
        ).strip()
    except subprocess.CalledProcessError:
        return ""


def read_text(path: Path, limit: int = 6000) -> str:
    try:
        return path.read_text(encoding="utf-8", errors="replace")[:limit]
    except OSError:
        return ""


def repo_inventory(repo_dir: Path) -> dict:
    owner, name = repo_dir.name.split("__", 1)
    files = [p for p in repo_dir.rglob("*") if p.is_file() and ".git" not in p.parts]
    ext_counts = Counter(p.suffix.lower() for p in files if p.suffix)
    language_counts = Counter()
    for ext, count in ext_counts.items():
        language_counts[EXT_LANGUAGE.get(ext, ext or "unknown")] += count

    readmes = sorted(
        [p for p in repo_dir.iterdir() if p.is_file() and p.name.lower().startswith("readme")]
    )
    manifests = [
        rel
        for rel in [
            "Package.swift",
            "pyproject.toml",
            "Cargo.toml",
            "package.json",
            "Makefile",
            "go.mod",
            "build.gradle",
            "settings.gradle",
        ]
        if (repo_dir / rel).exists()
    ]

    return {
        "repo": f"{owner}/{name}",
        "local_path": str(repo_dir),
        "head": run_git(repo_dir, "rev-parse", "--short", "HEAD"),
        "branch": run_git(repo_dir, "branch", "--show-current"),
        "remote": run_git(repo_dir, "remote", "get-url", "origin"),
        "file_count": len(files),
        "top_languages_by_file_count": language_counts.most_common(8),
        "manifests": manifests,
        "readme_files": [str(p.relative_to(repo_dir)) for p in readmes],
        "readme_excerpt": read_text(readmes[0]) if readmes else "",
    }


def main() -> None:
    repos = sorted(p for p in REPOS.iterdir() if p.is_dir() and (p / ".git").exists())
    data = [repo_inventory(repo) for repo in repos]

    json_path = SNAPSHOTS / "repo_inventory.json"
    json_path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")

    lines = [
        "# Repo Inventory",
        "",
        f"Repo count: {len(data)}",
        "",
        "| Repo | HEAD | Files | Top languages | Manifests |",
        "|---|---:|---:|---|---|",
    ]
    for item in data:
        langs = ", ".join(f"{name}:{count}" for name, count in item["top_languages_by_file_count"][:4])
        manifests = ", ".join(item["manifests"])
        lines.append(
            f"| `{item['repo']}` | `{item['head']}` | {item['file_count']} | {langs} | {manifests} |"
        )
    (SNAPSHOTS / "repo_inventory.md").write_text("\n".join(lines) + "\n", encoding="utf-8")

    urls = [
        line.strip()
        for line in (ROOT / "repo_urls.txt").read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    cloned = {item["repo"] for item in data}
    coverage_lines = [
        "# Clone Coverage",
        "",
        f"Requested repos: {len(urls)}",
        f"Cloned repos: {len(cloned)}",
        f"Missing repos: {len(urls) - len(cloned)}",
        "",
        "## Cloned",
        "",
    ]
    for url in urls:
        repo = url.removeprefix("https://github.com/")
        if repo in cloned:
            coverage_lines.append(f"- [x] `{repo}`")
    coverage_lines.extend(["", "## Missing", ""])
    for url in urls:
        repo = url.removeprefix("https://github.com/")
        if repo not in cloned:
            coverage_lines.append(f"- [ ] `{repo}`")
    (SNAPSHOTS / "clone_coverage.md").write_text("\n".join(coverage_lines) + "\n", encoding="utf-8")

    status_lines = [
        "# Clone Status",
        "",
        f"Generated: {datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')}",
        "",
        "| Repo | Local Path | Status |",
        "|---|---|---|",
    ]
    for url in urls:
        repo = url.removeprefix("https://github.com/")
        owner, name = repo.split("/", 1)
        local_path = REPOS / f"{owner}__{name}"
        status = "cloned" if repo in cloned else "missing"
        status_lines.append(f"| `{repo}` | `{local_path}` | {status} |")
    (ROOT / "clone_status.md").write_text("\n".join(status_lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
