#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sys
from pathlib import Path

from c1_common import (
    CONTRACTS_DIR,
    CORE_SHEETS,
    SOURCE_FILES,
    atomic_write_text,
    content_digest_for_workbook,
    copy_sources_to_snapshot,
    downloads_path,
    dump_yaml,
    file_sha256,
    load_manifest,
    manifest_path,
    sha256_json,
    utc_now_iso,
)


def build_source_entry(source: dict, snapshot_dir: Path) -> dict:
    live_path = downloads_path(source["filename"])
    snapshot_path = snapshot_dir / source["filename"]
    digest, stats = content_digest_for_workbook(snapshot_path, source["expected_sheets"])
    sheet_stats = stats["sheet_stats"]
    contract_rows = 0
    if source.get("contract_source"):
        for sheet in CORE_SHEETS:
            contract_rows += sheet_stats[sheet]["rows_after_header"]
    return {
        "source_key": source["key"],
        "authority_kind": source["authority_kind"],
        "source_filename": source["filename"],
        "source_reachable": live_path.exists(),
        "snapshot_file": str(snapshot_path),
        "file_sha256": file_sha256(snapshot_path),
        "content_digest": digest,
        "sheets_expected": source["expected_sheets"],
        "missing_expected_sheets": stats["missing_expected_sheets"],
        "contract_source_rows": contract_rows,
        "sheet_stats": sheet_stats,
    }


def freeze() -> dict:
    source_digests = []
    live_entries = []
    for source in SOURCE_FILES:
        live_path = downloads_path(source["filename"])
        if not live_path.exists():
            raise FileNotFoundError(f"missing source file: {live_path}")
        digest, _ = content_digest_for_workbook(live_path, source["expected_sheets"])
        source_digests.append({"source_key": source["key"], "content_digest": digest})
        live_entries.append(source)

    aggregate_digest = sha256_json(source_digests)
    snapshot_id = f"c1-2026-06-19-{aggregate_digest[:8]}"
    snapshot_dir = copy_sources_to_snapshot(snapshot_id, live_entries)

    c1_semantic_sources = []
    c1_reference_sources = []
    for source in SOURCE_FILES:
        entry = build_source_entry(source, snapshot_dir)
        if source["key"] == "semantic_protocol_edit":
            c1_semantic_sources.append(entry)
        else:
            c1_reference_sources.append(entry)

    source_rows = sum(source["contract_source_rows"] for source in c1_semantic_sources)
    manifest = {
        "version": 1,
        "snapshot_id": snapshot_id,
        "frozen_at": utc_now_iso(),
        "snapshot_dir": str(snapshot_dir),
        "aggregate_content_digest": aggregate_digest,
        "contract_scope": {
            "domains": list(CORE_SHEETS),
            "source_rows": source_rows,
            "source_rows_basis": "semantic_protocol_edit physical rows after header in airControl/carControl/cmd",
        },
        "c1_semantic_sources": c1_semantic_sources,
        "c1_reference_sources": c1_reference_sources,
        "c2_state_reference_sources": [],
        "authority_notes": [
            "Source xlsx files stay outside the git repository under raw source-snapshots.",
            "file_sha256 protects frozen file identity; content_digest protects normalized semantic row content.",
            "C2 state authority is not defined in stage A; reference sources are recorded but not promoted.",
        ],
    }
    CONTRACTS_DIR.mkdir(parents=True, exist_ok=True)
    atomic_write_text(manifest_path(), dump_yaml(manifest))
    return manifest


def check() -> dict:
    manifest = load_manifest()
    errors = []
    all_sources = manifest.get("c1_semantic_sources", []) + manifest.get("c1_reference_sources", [])
    for source in all_sources:
        path = Path(source["snapshot_file"])
        if not path.exists():
            errors.append(f"missing snapshot file: {path}")
            continue
        actual_file_sha = file_sha256(path)
        actual_digest, _ = content_digest_for_workbook(path, source["sheets_expected"])
        if actual_file_sha != source["file_sha256"]:
            errors.append(f"file_sha256 mismatch: {source['source_key']}")
        if actual_digest != source["content_digest"]:
            errors.append(f"content_digest mismatch: {source['source_key']}")
    if errors:
        raise RuntimeError("\n".join(errors))
    return manifest


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="verify the committed manifest and frozen files")
    args = parser.parse_args()
    manifest = check() if args.check else freeze()
    print(f"snapshot_id={manifest['snapshot_id']}")
    print(f"source_rows={manifest['contract_scope']['source_rows']}")
    print(f"manifest={manifest_path()}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"freeze_snapshot failed: {exc}", file=sys.stderr)
        raise
