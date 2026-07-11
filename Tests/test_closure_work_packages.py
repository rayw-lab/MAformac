"""Executable O1/O2 positive and mandatory-negative contracts."""

from __future__ import annotations

import json
import hashlib
import importlib.util
import re
import shutil
import subprocess
import sys
from pathlib import Path

import pytest
import yaml


REPO = Path(__file__).resolve().parents[1]
CHECKER = REPO / "scripts" / "check_closure_work_packages.py"
REGISTRY = REPO / "contracts" / "closure-work-packages.v1.yaml"
ROADMAP = REPO / "docs" / "roadmap-2026-07-11-v6-closure-baseline.md"
RESOURCE_POLICY = REPO / "contracts" / "closure-execution-window.v1.yaml"
SCHEMA = REPO / "contracts" / "schemas" / "closure-work-packages.v1.schema.json"
NEGATIVE_DIR = REPO / "Tests" / "Fixtures" / "closure-registry" / "negative"


def load_checker_module():
    spec = importlib.util.spec_from_file_location("closure_checker", CHECKER)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


CHECKER_MODULE = load_checker_module()


def current_head() -> str:
    return subprocess.run(
        ["git", "rev-parse", "HEAD"], cwd=REPO, text=True, capture_output=True, check=True
    ).stdout.strip()


def canonical_digest(value: object) -> str:
    encoded = json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(encoded.encode("utf-8")).hexdigest()


def write_registry(tmp_path: Path, mutate) -> Path:
    registry = yaml.safe_load(REGISTRY.read_text(encoding="utf-8"))
    mutate(registry)
    path = tmp_path / "registry.yaml"
    path.write_text(yaml.safe_dump(registry, allow_unicode=True, sort_keys=False), encoding="utf-8")
    return path


def write_fixture(tmp_path: Path, patches: list[dict[str, object]]) -> Path:
    path = tmp_path / "mutation.fixture.yaml"
    path.write_text(
        yaml.safe_dump(
            {"fixture_contract": "closure_registry_negative_fixture_v1", "id": "test-mutation", "patches": patches},
            allow_unicode=True,
            sort_keys=False,
        ),
        encoding="utf-8",
    )
    return path


def run_checker(
    tmp_path: Path,
    *extra: str,
    registry: Path = REGISTRY,
    roadmap: Path = ROADMAP,
    subject_head: str | None = None,
) -> subprocess.CompletedProcess[str]:
    receipt = tmp_path / "closure-registry-check.v1.json"
    if subject_head is None:
        subject_head = current_head()
    return subprocess.run(
        [
            sys.executable,
            str(CHECKER),
            "check",
            "--registry",
            str(registry),
            "--schema",
            str(SCHEMA),
            "--roadmap",
            str(roadmap),
            "--o6-policy",
            str(RESOURCE_POLICY),
            "--subject-head",
            subject_head,
            "--receipt",
            str(receipt),
            *extra,
        ],
        cwd=REPO,
        text=True,
        capture_output=True,
        check=False,
    )


def read_receipt(tmp_path: Path) -> dict[str, object]:
    return json.loads((tmp_path / "closure-registry-check.v1.json").read_text(encoding="utf-8"))


def committed_registry_probe(
    tmp_path: Path,
    *,
    post_basis_change: str | None = None,
) -> tuple[subprocess.CompletedProcess[str], dict[str, object]]:
    clone = tmp_path / "postcommit"
    subprocess.run(
        ["git", "clone", "--quiet", "--no-hardlinks", str(REPO), str(clone)],
        check=True,
    )
    subprocess.run(["git", "config", "user.name", "O1O2 pytest"], cwd=clone, check=True)
    subprocess.run(["git", "config", "user.email", "o1o2-pytest@example.invalid"], cwd=clone, check=True)
    basis_head = subprocess.run(
        ["git", "rev-parse", "HEAD"], cwd=clone, text=True, capture_output=True, check=True
    ).stdout.strip()
    registry_path = clone / "contracts" / "closure-work-packages.v1.yaml"
    shutil.copy2(REGISTRY, registry_path)
    shutil.copy2(ROADMAP, clone / ROADMAP.relative_to(REPO))
    shutil.copy2(REPO / "closure" / "receipts" / "W1.v1.json", clone / "closure" / "receipts" / "W1.v1.json")
    registry_text = registry_path.read_text(encoding="utf-8")
    registry_text, replacement_count = re.subn(
        r"(?m)^(  repo_head:) [0-9a-f]{40}$",
        rf"\1 {basis_head}",
        registry_text,
        count=2,
    )
    assert replacement_count == 2
    registry_path.write_text(registry_text, encoding="utf-8")
    shutil.copy2(CHECKER, clone / "scripts" / "check_closure_work_packages.py")
    subprocess.run(
        [
            "git",
            "add",
            "contracts/closure-work-packages.v1.yaml",
            "closure/receipts/W1.v1.json",
            "docs/roadmap-2026-07-11-v6-closure-baseline.md",
            "scripts/check_closure_work_packages.py",
        ],
        cwd=clone,
        check=True,
    )
    subprocess.run(["git", "commit", "--quiet", "-m", "test: registry-only refresh"], cwd=clone, check=True)
    if post_basis_change == "docs":
        docs_path = clone / "docs" / "r19-whitelist-probe.md"
        docs_path.write_text("# R19 governance-only probe\n", encoding="utf-8")
        subprocess.run(["git", "add", str(docs_path.relative_to(clone))], cwd=clone, check=True)
        subprocess.run(["git", "commit", "--quiet", "-m", "test: docs-only drift"], cwd=clone, check=True)
    elif post_basis_change == "roadmap_generated_table":
        roadmap_path = clone / "docs" / "roadmap-2026-07-11-v6-closure-baseline.md"
        roadmap_text = roadmap_path.read_text(encoding="utf-8")
        roadmap_text, replacement_count = re.subn(
            r"(?m)^\| packages \| 29 \|$",
            "| packages | 30 |",
            roadmap_text,
            count=1,
        )
        assert replacement_count == 1
        roadmap_path.write_text(roadmap_text, encoding="utf-8")
        subprocess.run(["git", "add", str(roadmap_path.relative_to(clone))], cwd=clone, check=True)
        subprocess.run(
            ["git", "commit", "--quiet", "-m", "test: unsynchronized generated table"],
            cwd=clone,
            check=True,
        )
    elif post_basis_change == "core":
        product_path = clone / "Core" / "State" / "DialogueState.swift"
        product_path.write_text(product_path.read_text(encoding="utf-8") + "\n", encoding="utf-8")
        subprocess.run(["git", "add", "Core/State/DialogueState.swift"], cwd=clone, check=True)
        subprocess.run(["git", "commit", "--quiet", "-m", "test: product drift"], cwd=clone, check=True)
    elif post_basis_change is not None:
        raise AssertionError(f"unsupported post-basis change: {post_basis_change}")
    subject_head = subprocess.run(
        ["git", "rev-parse", "HEAD"], cwd=clone, text=True, capture_output=True, check=True
    ).stdout.strip()
    receipt_path = clone / ".build" / "closure-registry-check.v1.json"
    result = subprocess.run(
        [
            sys.executable,
            str(clone / "scripts" / "check_closure_work_packages.py"),
            "check",
            "--registry", str(registry_path),
            "--schema", str(clone / "contracts" / "schemas" / "closure-work-packages.v1.schema.json"),
            "--roadmap", str(clone / "docs" / "roadmap-2026-07-11-v6-closure-baseline.md"),
            "--o6-policy", str(clone / "contracts" / "closure-execution-window.v1.yaml"),
            "--subject-head", subject_head,
            "--receipt", str(receipt_path),
        ],
        cwd=clone,
        text=True,
        capture_output=True,
        check=False,
    )
    receipt = json.loads(receipt_path.read_text(encoding="utf-8"))
    return result, receipt


def test_current_29_package_registry_passes(tmp_path: Path) -> None:
    result = run_checker(tmp_path)

    assert result.returncode == 0, result.stderr
    receipt = read_receipt(tmp_path)
    assert receipt["status"] == "PASS"
    assert receipt["package_count"] == 29
    assert receipt["hard_leaf_denominator"] == 28
    assert receipt["root_reach"] == "29/29"
    assert receipt["resource_pair_encoding"] == "unordered_canonical_single_row"
    assert receipt["lease_states"] == ["running"]
    assert receipt["repo_head"] == current_head()
    assert receipt["schema_sha256"] == hashlib.sha256(SCHEMA.read_bytes()).hexdigest()


def test_real_schema_rejects_registry_id_array(tmp_path: Path) -> None:
    registry = write_registry(tmp_path, lambda value: value.__setitem__("registry_id", ["invalid", "array"]))

    result = run_checker(tmp_path, registry=registry)

    assert result.returncode == 64, result.stderr
    assert read_receipt(tmp_path)["errors"] == ["E_SCHEMA"]


def test_parent_basis_behind_checked_subject_is_stale(tmp_path: Path) -> None:
    stale_head = "f1bca6e18cdd1bb70ffe6ca1d0ecd34e585efa5b"
    fixture = write_fixture(
        tmp_path,
        [
            {"target": "registry", "op": "replace", "path": "/basis/repo_head", "value": stale_head},
            {"target": "registry", "op": "replace", "path": "/source_snapshot/repo_head", "value": stale_head},
        ],
    )

    result = run_checker(tmp_path, "--fixture", str(fixture), subject_head=current_head())

    assert result.returncode == 70, result.stderr
    assert "E_STALE_BASIS" in read_receipt(tmp_path)["errors"]


def test_registry_only_commit_after_basis_remains_fresh(tmp_path: Path) -> None:
    result, receipt = committed_registry_probe(tmp_path)

    assert result.returncode == 0, receipt
    assert receipt["status"] == "PASS"
    assert "E_STALE_BASIS" not in receipt["errors"]


def test_docs_only_commit_after_basis_remains_fresh(tmp_path: Path) -> None:
    result, receipt = committed_registry_probe(tmp_path, post_basis_change="docs")

    assert result.returncode == 0, receipt
    assert receipt["status"] == "PASS"
    assert "E_STALE_BASIS" not in receipt["errors"]


def test_core_change_after_basis_is_stale(tmp_path: Path) -> None:
    result, receipt = committed_registry_probe(tmp_path, post_basis_change="core")

    assert result.returncode != 0
    assert "E_STALE_BASIS" in receipt["errors"]


def test_unsynchronized_roadmap_generated_table_is_not_guarded_by_staleness(tmp_path: Path) -> None:
    result, receipt = committed_registry_probe(
        tmp_path,
        post_basis_change="roadmap_generated_table",
    )

    assert result.returncode == 68, receipt
    assert "E_GENERATED_BLOCK_DRIFT" in receipt["errors"]
    assert "E_STALE_BASIS" not in receipt["errors"]


def test_arbitrary_existing_file_cannot_satisfy_w1_transition_chain(tmp_path: Path) -> None:
    fixture = write_fixture(
        tmp_path,
        [{
            "target": "registry", "op": "replace",
            "path": "/packages/by-id/W1/execution_state/transition_receipts",
            "value": [{"root": "repo", "path": "docs/commander-log/decisions.md", "availability": "existing", "sha256": None}],
        }],
    )

    result = run_checker(tmp_path, "--fixture", str(fixture))

    assert result.returncode == 65, result.stderr
    assert "E_TRANSITION" in read_receipt(tmp_path)["errors"]


@pytest.mark.parametrize("mutation", ["wrong_package", "illegal_edge", "missing_intermediate"])
def test_w1_transition_chain_rejects_invalid_hops(tmp_path: Path, mutation: str) -> None:
    registry = yaml.safe_load(REGISTRY.read_text(encoding="utf-8"))
    registry["allowed_roots"]["build"] = str(tmp_path)
    package = next(item for item in registry["packages"] if item["id"] == "W1")
    source_paths = [
        REPO / reference["path"] for reference in package["execution_state"]["transition_receipts"]
    ]
    payloads = [json.loads(path.read_text(encoding="utf-8")) for path in source_paths]
    if mutation == "wrong_package":
        payloads[1]["package_id"] = "W2"
    elif mutation == "illegal_edge":
        payloads[1]["to_state"] = "done"
    else:
        payloads.pop(1)
    refs = []
    for index, payload in enumerate(payloads, 1):
        path = tmp_path / f"transition-{index}.json"
        path.write_text(json.dumps(payload), encoding="utf-8")
        refs.append({"root": "build", "path": path.name, "availability": "existing", "sha256": None})
    package["execution_state"]["transition_receipts"] = refs

    assert CHECKER_MODULE.validate_transition_chain(registry, package) == ["E_TRANSITION"]


@pytest.mark.parametrize("mutation", ["unknown_head", "digest_not_at_head", "regressing_head"])
def test_w1_transition_receipts_bind_evidence_to_declared_git_head(
    tmp_path: Path, mutation: str
) -> None:
    registry = yaml.safe_load(REGISTRY.read_text(encoding="utf-8"))
    registry["allowed_roots"]["build"] = str(tmp_path)
    package = next(item for item in registry["packages"] if item["id"] == "W1")
    payloads = [
        json.loads((REPO / reference["path"]).read_text(encoding="utf-8"))
        for reference in package["execution_state"]["transition_receipts"]
    ]
    if mutation == "unknown_head":
        payloads[0]["repo_head"] = "0" * 40
    elif mutation == "digest_not_at_head":
        payloads[0]["evidence"]["sha256"] = hashlib.sha256(
            (REPO / payloads[0]["evidence"]["path"]).read_bytes()
        ).hexdigest()
    else:
        payloads[2]["repo_head"] = "ba2c36360584bcca8260d57c2be4c9294f82f8a5"
        payloads[2]["evidence"]["sha256"] = "5d95778d56f20eb198fd302cfc2660261c73b719e51b369b07a74ec7529ea4d9"
        payloads[3]["repo_head"] = "ed4aabc42a831d1838820eb89fdbeef3535797b2"
        payloads[3]["evidence"]["sha256"] = "222635a870f302cbbf828073d2066f8f5d2862a61816582890fdd3dd79892000"
    refs = []
    for index, payload in enumerate(payloads, 1):
        path = tmp_path / f"historical-transition-{index}.json"
        path.write_text(json.dumps(payload), encoding="utf-8")
        refs.append({"root": "build", "path": path.name, "availability": "existing", "sha256": None})
    package["execution_state"]["transition_receipts"] = refs

    assert CHECKER_MODULE.validate_transition_chain(registry, package) == ["E_TRANSITION"]


def test_wrong_native_receipt_digest_is_rejected(tmp_path: Path) -> None:
    fixture = write_fixture(
        tmp_path,
        [{
            "target": "registry", "op": "replace",
            "path": "/packages/by-id/W1/exit_receipt/native_artifact/sha256",
            "value": "0" * 64,
        }],
    )

    result = run_checker(tmp_path, "--fixture", str(fixture))

    assert result.returncode == 69, result.stderr
    assert "E_DONE_RECEIPT" in read_receipt(tmp_path)["errors"]


def test_v8_join_requires_six_real_receipts_with_equal_subject_values(tmp_path: Path) -> None:
    validator = getattr(CHECKER_MODULE, "validate_v8_same_subject", None)
    assert callable(validator), "R16 must be implemented as a real receipt join"
    shared = {
        "repo_head": ("git_sha", "a" * 40),
        "build_identity": ("string", "build-1"),
        "base_model_sha256": ("sha256", "1" * 64),
        "adapter_sha256": ("sha256", "2" * 64),
        "tokenizer_sha256": ("sha256", "3" * 64),
        "contract_bundle_sha256": ("sha256", "4" * 64),
        "matrix_sha256": ("sha256", "5" * 64),
        "corpus_sha256": ("sha256", "6" * 64),
        "scorer_sha256": ("sha256", "7" * 64),
        "checker_bundle_sha256": ("sha256", "8" * 64),
    }
    inputs = []
    for gate_id in ["model", "capability", "architecture", "demo", "honesty", "operator"]:
        path = tmp_path / f"{gate_id}.json"
        subject = shared.copy()
        if gate_id == "honesty":
            subject["build_identity"] = ("string", "wrong-build")
        path.write_text(
            json.dumps(
                {
                    "schema_version": "closure_gate_receipt_v1",
                    "gate_id": gate_id,
                    "status": "PASS",
                    "subject": [
                        {"key": key, "value_type": value_type, "value": value}
                        for key, (value_type, value) in subject.items()
                    ],
                }
            ),
            encoding="utf-8",
        )
        inputs.append((gate_id, path))

    errors = validator(inputs)

    assert errors == ["E_SUBJECT_JOIN"]


@pytest.mark.parametrize("invalid_git_sha", ["NOT_A_SHA", ["a" * 40]])
def test_v8_join_rejects_equal_but_ill_typed_subject_values(
    tmp_path: Path, invalid_git_sha: object
) -> None:
    shared = {
        "repo_head": ("git_sha", invalid_git_sha),
        "build_identity": ("string", "build-1"),
        "base_model_sha256": ("sha256", "1" * 64),
        "adapter_sha256": ("sha256", "2" * 64),
        "tokenizer_sha256": ("sha256", "3" * 64),
        "contract_bundle_sha256": ("sha256", "4" * 64),
        "matrix_sha256": ("sha256", "5" * 64),
        "corpus_sha256": ("sha256", "6" * 64),
        "scorer_sha256": ("sha256", "7" * 64),
        "checker_bundle_sha256": ("sha256", "8" * 64),
    }
    inputs = []
    for gate_id in ["model", "capability", "architecture", "demo", "honesty", "operator"]:
        path = tmp_path / f"typed-{gate_id}.json"
        path.write_text(
            json.dumps(
                {
                    "schema_version": "closure_gate_receipt_v1",
                    "gate_id": gate_id,
                    "status": "PASS",
                    "subject": [
                        {"key": key, "value_type": value_type, "value": value}
                        for key, (value_type, value) in shared.items()
                    ],
                }
            ),
            encoding="utf-8",
        )
        inputs.append((gate_id, path))

    assert CHECKER_MODULE.validate_v8_same_subject(inputs) == ["E_SUBJECT_JOIN"]


@pytest.mark.parametrize(
    "fixture_name",
    [
        "fake-ready-w2.fixture.yaml",
        "duplicate-counting-b6.fixture.yaml",
        "resource-conflict-s8-build.fixture.yaml",
        "handwritten-count-token.fixture.yaml",
        "fake-done-w2.fixture.yaml",
    ],
)
def test_required_negative_fixture_reds_in_real_checker(
    tmp_path: Path,
    fixture_name: str,
) -> None:
    fixture = NEGATIVE_DIR / fixture_name
    contract = yaml.safe_load(fixture.read_text(encoding="utf-8"))["expect"]
    result = run_checker(tmp_path, "--fixture", str(fixture))

    assert result.returncode == contract["rc"], result.stderr
    receipt = read_receipt(tmp_path)
    assert receipt["status"] == contract["status"]
    actual_errors = set(receipt["errors"])
    if "errors_exact" in contract:
        assert actual_errors == set(contract["errors_exact"])
    else:
        assert set(contract["errors_include"]).issubset(actual_errors)


def test_verify_ci_consumes_o1o2_checker_and_presence_gate() -> None:
    makefile = (REPO / "Makefile").read_text(encoding="utf-8")
    verify_ci = re.search(r"^verify-ci:\s*(.*)$", makefile, re.MULTILINE)
    assert verify_ci is not None
    assert "verify-closure-work-packages" in verify_ci.group(1)
    presence = re.search(r"^verify-c1-checker-files:\n(?P<body>(?:\t.*\n)+)", makefile, re.MULTILINE)
    assert presence is not None
    for required in [
        "scripts/check_closure_work_packages.py",
        "contracts/closure-work-packages.v1.yaml",
        "contracts/schemas/closure-work-packages.v1.schema.json",
        "contracts/closure-execution-window.v1.yaml",
        "Tests/test_closure_work_packages.py",
    ]:
        assert required in presence.group("body")


def test_generated_block_contains_all_29_canonical_package_rows() -> None:
    registry = yaml.safe_load(REGISTRY.read_text(encoding="utf-8"))
    generated = CHECKER_MODULE.render_generated_block(registry)

    rows = re.findall(r"^\| (B1a|B1b|B[2-7]|W(?:10|[1-9]|5[a-d])|V(?:6p|[1-8])) \|", generated, re.MULTILINE)
    assert len(rows) == 29
    assert len(set(rows)) == 29
    assert "historical source view; superseded by O1 generated table" in ROADMAP.read_text(encoding="utf-8")
