#!/usr/bin/env python3
"""Fail-closed checker for the O1 closure work-package registry.

The registry is intentionally the only source for O1 package state.  This
checker derives counts and readiness; it never accepts a prose summary as an
oracle.  It also executes the persistent JSON-patch-style YAML fixtures used
by the O1/O2 regression suite.
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import re
import shutil
import subprocess
import sys
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import yaml
from jsonschema import Draft202012Validator, FormatChecker


SCHEMA_VERSION = "closure_work_packages_v1"
ENVELOPE_VERSION = "closure_package_exit_envelope_v1"
CHECK_RECEIPT_VERSION = "closure_registry_check_v1"
ROOT = Path(__file__).resolve().parents[1]
TOKEN_RE = re.compile(r"O1COUNTv1\{[^\r\n]*\}")
TOKEN_GRAMMAR = re.compile(
    r"^O1COUNTv1\{registry=[0-9a-f]{64};packages=(?:0|[1-9][0-9]*);"
    r"hard=(?:0|[1-9][0-9]*);done=(?:0|[1-9][0-9]*);"
    r"ready=(?:0|[1-9][0-9]*);blocked=(?:0|[1-9][0-9]*);"
    r"planned=(?:0|[1-9][0-9]*);gap=(?:0|[1-9][0-9]*);"
    r"running=(?:0|[1-9][0-9]*);paused=(?:0|[1-9][0-9]*)\}$"
)
MARKER_RE = re.compile(
    r"\n<!-- O1:GENERATED:START registry_sha256=[0-9a-f]{64} checker_sha256=[0-9a-f]{64} -->"
    r"\n.*?\n<!-- O1:GENERATED:END -->\n?",
    re.DOTALL,
)
SHA256_RE = re.compile(r"^[0-9a-f]{64}$")
GIT_SHA_RE = re.compile(r"^[0-9a-f]{40}$")
TRANSITION_SCHEMA_PATH = ROOT / "contracts" / "schemas" / "closure-status-transition-receipt.v1.schema.json"
EXIT_ENVELOPE_SCHEMA_PATH = ROOT / "contracts" / "schemas" / "closure-package-exit-envelope.v1.schema.json"
GATE_RECEIPT_SCHEMA_PATH = ROOT / "contracts" / "schemas" / "closure-gate-receipt.v1.schema.json"
ALLOWED_TRANSITIONS = {
    ("gap", "planned"), ("gap", "blocked"),
    ("planned", "ready"), ("blocked", "ready"),
    ("ready", "running"),
    ("running", "paused"), ("running", "done"), ("running", "failed"),
    ("paused", "ready"), ("paused", "running"), ("paused", "failed"),
}


class DuplicateKeyError(ValueError):
    pass


class StrictLoader(yaml.SafeLoader):
    pass


def _construct_mapping(loader: StrictLoader, node: yaml.MappingNode, deep: bool = False) -> dict[Any, Any]:
    mapping: dict[Any, Any] = {}
    for key_node, value_node in node.value:
        key = loader.construct_object(key_node, deep=deep)
        if key in mapping:
            raise DuplicateKeyError(f"duplicate YAML key: {key!r}")
        mapping[key] = loader.construct_object(value_node, deep=deep)
    return mapping


StrictLoader.add_constructor(yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, _construct_mapping)


@dataclass
class CheckFailure(Exception):
    code: str
    message: str


def sha256_text(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def canonical_json(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def registry_digest(registry: dict[str, Any]) -> str:
    return sha256_text(canonical_json(registry))


def checker_digest() -> str:
    return hashlib.sha256(Path(__file__).read_bytes()).hexdigest()


def file_digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def git_blob_digest(repo_head: str, relative_path: str) -> str:
    if not GIT_SHA_RE.fullmatch(repo_head) or relative_path.startswith("/") or ".." in Path(relative_path).parts:
        raise CheckFailure("E_TRANSITION", "invalid git evidence subject")
    result = subprocess.run(
        ["git", "show", f"{repo_head}:{relative_path}"],
        cwd=ROOT,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        raise CheckFailure("E_TRANSITION", "transition evidence is absent at declared repo head")
    return hashlib.sha256(result.stdout).hexdigest()


def is_ancestor(ancestor: str, descendant: str) -> bool:
    return subprocess.run(
        ["git", "merge-base", "--is-ancestor", ancestor, descendant],
        cwd=ROOT,
        capture_output=True,
        check=False,
    ).returncode == 0


def typed_value_is_valid(value_type: Any, value: Any) -> bool:
    if value_type == "git_sha":
        return isinstance(value, str) and bool(GIT_SHA_RE.fullmatch(value))
    if value_type == "sha256":
        return isinstance(value, str) and bool(SHA256_RE.fullmatch(value))
    if value_type == "string":
        return isinstance(value, str)
    if value_type == "integer":
        return isinstance(value, int) and not isinstance(value, bool)
    if value_type == "boolean":
        return isinstance(value, bool)
    return False


def load_json(path: Path, code: str) -> dict[str, Any]:
    try:
        value = json.loads(read_utf8(path))
    except (OSError, json.JSONDecodeError, CheckFailure) as exc:
        raise CheckFailure(code, f"invalid JSON artifact: {path}") from exc
    if not isinstance(value, dict):
        raise CheckFailure(code, f"JSON artifact must be an object: {path}")
    return value


def schema_errors(instance: Any, schema: dict[str, Any]) -> list[str]:
    validator = Draft202012Validator(schema, format_checker=FormatChecker())
    return [error.message for error in validator.iter_errors(instance)]


def read_utf8(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except UnicodeDecodeError as exc:
        raise CheckFailure("E_PARSE_AMBIGUOUS", f"non-UTF-8 input: {path}") from exc


def reject_ambiguous_yaml(raw: str) -> None:
    if re.search(r"(^|\n)\s*<<\s*:", raw):
        raise CheckFailure("E_PARSE_AMBIGUOUS", "YAML merge keys are forbidden")
    if re.search(r"(^|[\s\[{,])&[A-Za-z0-9_-]+", raw):
        raise CheckFailure("E_PARSE_AMBIGUOUS", "YAML anchors are forbidden")
    if re.search(r"(^|[\s\[{,])\*[A-Za-z0-9_-]+", raw):
        raise CheckFailure("E_PARSE_AMBIGUOUS", "YAML aliases are forbidden")
    if re.search(r"(^|[\s\[{,])![A-Za-z0-9_-]+", raw):
        raise CheckFailure("E_PARSE_AMBIGUOUS", "YAML custom tags are forbidden")


def load_yaml(path: Path) -> Any:
    raw = read_utf8(path)
    reject_ambiguous_yaml(raw)
    try:
        return yaml.load(raw, Loader=StrictLoader)
    except (yaml.YAMLError, DuplicateKeyError) as exc:
        raise CheckFailure("E_PARSE_AMBIGUOUS", f"invalid YAML {path}: {exc}") from exc


def root_path(registry: dict[str, Any], root: str) -> Path:
    allowed = registry["allowed_roots"][root]
    value = Path(allowed)
    return value if value.is_absolute() else ROOT / value


def artifact_path(registry: dict[str, Any], artifact: dict[str, Any]) -> Path:
    path = Path(artifact["path"])
    if path.is_absolute() or ".." in path.parts:
        raise CheckFailure("E_PATH_ESCAPE", f"unsafe artifact path: {artifact['path']}")
    base = root_path(registry, artifact["root"])
    resolved_base = base.resolve()
    resolved = (base / path).resolve()
    try:
        resolved.relative_to(resolved_base)
    except ValueError as exc:
        raise CheckFailure("E_PATH_ESCAPE", f"path escapes allowed root: {artifact['path']}") from exc
    return resolved


def command_is_safe(command: dict[str, Any]) -> bool:
    argv = command.get("argv")
    if command.get("shell") is not False or not isinstance(argv, list) or not argv:
        return False
    if any(not isinstance(item, str) or not item for item in argv):
        return False
    forbidden = {"sh", "bash", "zsh", "python", "python3"}
    if argv[0] in forbidden and len(argv) > 1 and argv[1] == "-c":
        return False
    return all("=" not in name for name in command.get("env_names", []))


def command_available(command: dict[str, Any]) -> bool:
    if command.get("availability") != "existing":
        return False
    executable = command["argv"][0]
    return bool(Path(executable).exists() or shutil.which(executable))


def run_command(command: dict[str, Any]) -> bool:
    cwd_map = {"repo": ROOT, "run_dir": ROOT, "build": ROOT / ".build"}
    try:
        result = subprocess.run(
            command["argv"],
            cwd=cwd_map.get(command["cwd"], ROOT),
            timeout=command["timeout_seconds"],
            capture_output=True,
            text=True,
            check=False,
        )
    except (OSError, subprocess.TimeoutExpired):
        return False
    return result.returncode in command["success_exit_codes"]


def source_basis_text(roadmap_text: str) -> str:
    # The generated block is inserted after the source paragraph's blank line.
    # Removing the whole match (rather than replacing it with another newline)
    # restores the pre-generated source byte stream for R19.
    without_generated = MARKER_RE.sub("", roadmap_text)
    # R18 exclusively owns count-token placement.  Excluding standalone tokens
    # from the R19 source digest keeps one mutation mapped to one exact error.
    return re.sub(r"(?:^|\n)O1COUNTv1\{[^\r\n]*\}\n?", "\n", without_generated)


def derive_counts(packages: list[dict[str, Any]]) -> dict[str, int]:
    execution = Counter(package["execution_state"]["declared"] for package in packages)
    hard_leaf = sum(
        1
        for package in packages
        if package["closure_required"]
        and package["scope_class"] == "hard"
        and package["counting"]["role"] == "leaf"
        and package["counting"]["count_in_hard_denominator"]
    )
    return {
        "package_count": len(packages),
        "hard_leaf_denominator": hard_leaf,
        "done": execution["done"],
        "ready": execution["ready"],
        "blocked": execution["blocked"],
        "planned": execution["planned"],
        "gap": execution["gap"],
        "running": execution["running"],
        "paused": execution["paused"],
    }


def count_token(digest: str, counts: dict[str, int]) -> str:
    return (
        f"O1COUNTv1{{registry={digest};packages={counts['package_count']};"
        f"hard={counts['hard_leaf_denominator']};done={counts['done']};"
        f"ready={counts['ready']};blocked={counts['blocked']};"
        f"planned={counts['planned']};gap={counts['gap']};"
        f"running={counts['running']};paused={counts['paused']}}}"
    )


def render_generated_block(registry: dict[str, Any]) -> str:
    digest = registry_digest(registry)
    counts = derive_counts(registry["packages"])
    token = count_token(digest, counts)
    rows = [
        f"| {package['id']} | {package['decision_state']['declared']} | "
        f"{package['execution_state']['declared']} | {package['proof_state']['declared']} |"
        for package in registry["packages"]
    ]
    return "\n".join(
        [
            f"<!-- O1:GENERATED:START registry_sha256={digest} checker_sha256={checker_digest()} -->",
            "| O1 checker field | derived value |",
            "|---|---:|",
            f"| packages | {counts['package_count']} |",
            f"| hard leaf denominator | {counts['hard_leaf_denominator']} |",
            f"| execution | done={counts['done']}; ready={counts['ready']}; blocked={counts['blocked']}; planned={counts['planned']}; gap={counts['gap']}; running={counts['running']}; paused={counts['paused']} |",
            f"| count token | `{token}` |",
            "",
            "| package | decision_state | execution_state | proof_state |",
            "|---|---|---|---|",
            *rows,
            "<!-- O1:GENERATED:END -->",
        ]
    )


REQUIRED_TOP_LEVEL = {
    "schema_version", "registry_id", "artifact_kind", "authority", "basis", "source_snapshot",
    "edge_basis", "requires_checker", "allowed_roots", "closure_roots", "proof_profiles",
    "o6_resource_policy_ref", "receipt_envelope_contract", "external_facts", "packages",
}
REQUIRED_PACKAGE = {
    "id", "source_id", "revision", "kind", "scope_class", "closure_required", "counting",
    "decision_state", "execution_state", "proof_state", "prerequisites", "external_gates",
    "exit_receipt", "check_command", "proof_profile_id", "resource_claim_refs",
}
ALLOWED_EXECUTION = {"gap", "planned", "blocked", "ready", "running", "paused", "done", "failed"}
ALLOWED_EDGE_BASIS = {"source_inherited", "audit_repair_v2", "ratified_override"}
V8_SUBJECT_KEYS = {
    "repo_head", "build_identity", "base_model_sha256", "adapter_sha256", "tokenizer_sha256",
    "contract_bundle_sha256", "matrix_sha256", "corpus_sha256", "scorer_sha256",
    "checker_bundle_sha256", "model_gate_receipt_sha256", "capability_gate_receipt_sha256",
    "architecture_gate_receipt_sha256", "demo_gate_receipt_sha256", "honesty_gate_receipt_sha256",
    "operator_ceremony_receipt_sha256",
}
V8_SHARED_SUBJECT_KEYS = {
    "repo_head", "build_identity", "base_model_sha256", "adapter_sha256", "tokenizer_sha256",
    "contract_bundle_sha256", "matrix_sha256", "corpus_sha256", "scorer_sha256", "checker_bundle_sha256",
}


def validate_shape(registry: dict[str, Any], schema: dict[str, Any]) -> list[str]:
    if schema_errors(registry, schema):
        return ["E_SCHEMA"]
    errors: list[str] = []
    for package in registry["packages"]:
        for command in package["check_command"].values():
            if not command_is_safe(command):
                errors.append("E_COMMAND_UNSAFE")
    return sorted(set(errors))


def apply_fixture(
    registry: dict[str, Any], roadmap_text: str, fixture_path: Path
) -> tuple[dict[str, Any], str, list[dict[str, Any]]]:
    fixture = load_yaml(fixture_path)
    if fixture.get("fixture_contract") != "closure_registry_negative_fixture_v1":
        raise CheckFailure("E_SCHEMA", "unsupported fixture contract")
    result = copy.deepcopy(registry)
    leases: list[dict[str, Any]] = []
    by_id = {package["id"]: package for package in result["packages"]}
    for patch in fixture["patches"]:
        target = patch["target"]
        if target == "registry":
            match = re.fullmatch(r"/packages/by-id/([^/]+)/(.*)", patch["path"])
            if match and match.group(1) in by_id:
                node: Any = by_id[match.group(1)]
                parts = match.group(2).split("/")
            elif re.fullmatch(r"/(basis|source_snapshot)/[A-Za-z0-9_]+", patch["path"]):
                parts = patch["path"].removeprefix("/").split("/")
                node = result
            else:
                raise CheckFailure("E_SCHEMA", f"unsupported registry patch: {patch}")
            for part in parts[:-1]:
                node = node[part]
            node[parts[-1]] = patch["value"]
        elif target == "leases" and patch["op"] == "add_valid_lease":
            leases.append({"package_id": patch["package_id"], "claim_id": patch["claim_id"], "valid": True})
        elif target == "roadmap" and patch["op"] == "insert_after":
            if patch.get("value_from") != "canonical_count_token_of_base_registry":
                raise CheckFailure("E_SCHEMA", f"unsupported roadmap patch: {patch}")
            roadmap_text = roadmap_text.rstrip("\n") + "\n" + count_token(registry_digest(result), derive_counts(result["packages"])) + "\n"
        else:
            raise CheckFailure("E_SCHEMA", f"unsupported fixture patch: {patch}")
    return result, roadmap_text, leases


def validate_resource_policy(policy: dict[str, Any]) -> tuple[dict[str, set[str]], set[tuple[str, str]]]:
    if policy.get("schema_version") != "closure_execution_window_v1" or policy.get("authority") != "O6":
        raise CheckFailure("E_RESOURCE_POLICY", "unsupported O6 policy")
    if policy.get("lease_required_for_states") != ["running"]:
        raise CheckFailure("E_RESOURCE_POLICY", "only running may require a lease")
    pairs: set[tuple[str, str]] = set()
    for pair in policy.get("conflict_pairs", []):
        left, right = pair.get("left"), pair.get("right")
        if not isinstance(left, str) or not isinstance(right, str) or left >= right or (left, right) in pairs:
            raise CheckFailure("E_RESOURCE_POLICY", "resource pairs must be unique canonical unordered pairs")
        pairs.add((left, right))
    claims: dict[str, set[str]] = {}
    for claim in policy.get("claims", []):
        claim_id = claim.get("id")
        resources = claim.get("resources")
        if not isinstance(claim_id, str) or claim_id in claims or not isinstance(resources, list) or not resources:
            raise CheckFailure("E_RESOURCE_POLICY", "invalid O6 claim")
        claims[claim_id] = set(resources)
    return claims, pairs


def native_receipt_value(path: Path, pointer: str) -> Any:
    if path.suffix == ".json":
        value: Any = load_json(path, "E_DONE_RECEIPT")
    else:
        raw = read_utf8(path)
        match = re.search(r"~~~yaml\s*\n(.*?)\n~~~", raw, re.DOTALL)
        if not match:
            raise CheckFailure("E_DONE_RECEIPT", f"native receipt has no YAML metadata: {path}")
        value = yaml.safe_load(match.group(1))
    for part in pointer.removeprefix("/").split("/"):
        if not isinstance(value, dict) or part not in value:
            raise CheckFailure("E_DONE_RECEIPT", f"native success pointer not found: {pointer}")
        value = value[part]
    return value


def load_done_receipts(
    registry: dict[str, Any], packages: dict[str, dict[str, Any]], fixture_mode: bool
) -> tuple[dict[str, dict[str, Any]], list[str]]:
    receipts: dict[str, dict[str, Any]] = {}
    errors: list[str] = []
    digest = registry_digest(registry)
    envelope_schema = load_json(EXIT_ENVELOPE_SCHEMA_PATH, "E_SCHEMA")
    for package in packages.values():
        if package["execution_state"]["declared"] != "done":
            continue
        try:
            path = artifact_path(registry, package["exit_receipt"]["artifact"])
            payload = load_json(path, "E_DONE_RECEIPT")
        except (CheckFailure, OSError):
            errors.append("E_DONE_RECEIPT")
            continue
        if fixture_mode:
            payload["registry_digest"] = digest
        if schema_errors(payload, envelope_schema):
            errors.append("E_DONE_RECEIPT")
            continue
        revision_mismatch = (
            payload.get("registry_schema_major") != SCHEMA_VERSION
            or payload.get("registry_digest") != digest
            or payload.get("package_id") != package["id"]
            or payload.get("package_revision") != package["revision"]
        )
        if revision_mismatch:
            errors.append("E_RECEIPT_REVISION")
            continue
        if (
            payload.get("schema_version") != ENVELOPE_VERSION
            or payload.get("native_receipt_schema_id") != package["exit_receipt"]["native_schema_id"]
            or payload.get("status") != "DONE"
            or payload.get("subject_schema_id") != package["exit_receipt"]["subject_schema_id"]
            or not SHA256_RE.fullmatch(str(payload.get("native_receipt_digest", "")))
        ):
            errors.append("E_DONE_RECEIPT")
            continue
        native_ref = package["exit_receipt"].get("native_artifact")
        if not isinstance(native_ref, dict) or payload.get("native_receipt") != {
            "root": native_ref.get("root"), "path": native_ref.get("path"), "sha256": native_ref.get("sha256")
        }:
            errors.append("E_DONE_RECEIPT")
            continue
        try:
            native_path = artifact_path(registry, native_ref)
            native_digest = file_digest(native_path)
            success_value = native_receipt_value(native_path, package["exit_receipt"]["success_pointer"])
        except (CheckFailure, OSError):
            errors.append("E_DONE_RECEIPT")
            continue
        if (
            native_ref.get("availability") != "existing"
            or native_ref.get("sha256") != native_digest
            or payload.get("native_receipt_digest") != native_digest
            or success_value not in package["exit_receipt"]["success_values"]
        ):
            errors.append("E_DONE_RECEIPT")
            continue
        subject_keys: set[str] = set()
        valid_subject = isinstance(payload.get("subject"), list) and bool(payload["subject"])
        for item in payload.get("subject", []):
            key, value_type, value = item.get("key"), item.get("value_type"), item.get("value")
            if key in subject_keys or not isinstance(key, str):
                valid_subject = False
            subject_keys.add(key)
            valid_subject = valid_subject and typed_value_is_valid(value_type, value)
        if not valid_subject:
            errors.append("E_DONE_RECEIPT")
            continue
        receipts[package["id"]] = payload
    return receipts, errors


def validate_transition_chain(registry: dict[str, Any], package: dict[str, Any]) -> list[str]:
    state = package["execution_state"]["declared"]
    refs = package["execution_state"]["transition_receipts"]
    if state not in {"ready", "running", "paused", "done", "failed"}:
        return [] if not refs else ["E_TRANSITION"]
    if not refs:
        return ["E_TRANSITION"]
    schema = load_json(TRANSITION_SCHEMA_PATH, "E_SCHEMA")
    receipts: list[dict[str, Any]] = []
    for ref in refs:
        try:
            path = artifact_path(registry, ref)
            payload = load_json(path, "E_TRANSITION")
        except CheckFailure:
            return ["E_TRANSITION"]
        if schema_errors(payload, schema):
            return ["E_TRANSITION"]
        evidence = payload["evidence"]
        evidence_ref = {"root": evidence["root"], "path": evidence["path"], "availability": "existing", "sha256": evidence["sha256"]}
        try:
            evidence_path = artifact_path(registry, evidence_ref)
            head_ok = is_ancestor(payload["repo_head"], registry["basis"]["repo_head"])
            if evidence["root"] == "repo":
                evidence_ok = evidence_path.is_file() and git_blob_digest(
                    payload["repo_head"], evidence["path"]
                ) == evidence["sha256"]
            else:
                evidence_ok = evidence_path.is_file() and file_digest(evidence_path) == evidence["sha256"]
        except (CheckFailure, OSError):
            evidence_ok = head_ok = False
        if (
            payload["package_id"] != package["id"]
            or payload["package_revision"] != package["revision"]
            or not evidence_ok
            or not head_ok
            or payload["command_rc"] != 0
        ):
            return ["E_TRANSITION"]
        receipts.append(payload)
    receipts.sort(key=lambda item: item["sequence"])
    if [item["sequence"] for item in receipts] != list(range(1, len(receipts) + 1)):
        return ["E_TRANSITION"]
    if receipts[0]["from_state"] != "gap" or receipts[-1]["to_state"] != state:
        return ["E_TRANSITION"]
    final_head = receipts[-1]["repo_head"]
    if any(not is_ancestor(receipt["repo_head"], final_head) for receipt in receipts[:-1]):
        return ["E_TRANSITION"]
    for index, receipt in enumerate(receipts):
        if (receipt["from_state"], receipt["to_state"]) not in ALLOWED_TRANSITIONS:
            return ["E_TRANSITION"]
        if index:
            previous = receipts[index - 1]
            if previous["to_state"] != receipt["from_state"]:
                return ["E_TRANSITION"]
    return []


def typed_subject_map(payload: dict[str, Any]) -> dict[str, tuple[str, Any]]:
    result: dict[str, tuple[str, Any]] = {}
    for item in payload.get("subject", []):
        key = item.get("key")
        if not isinstance(key, str) or key in result:
            raise CheckFailure("E_SUBJECT_JOIN", "duplicate or invalid typed subject key")
        value_type, value = item.get("value_type"), item.get("value")
        if not typed_value_is_valid(value_type, value):
            raise CheckFailure("E_SUBJECT_JOIN", "typed subject value does not match value_type")
        result[key] = (value_type, value)
    return result


def validate_v8_same_subject(inputs: list[tuple[str, Path]]) -> list[str]:
    expected_gate_ids = {"model", "capability", "architecture", "demo", "honesty", "operator"}
    if len(inputs) != 6 or {gate_id for gate_id, _ in inputs} != expected_gate_ids:
        return ["E_SUBJECT_JOIN"]
    schema = load_json(GATE_RECEIPT_SCHEMA_PATH, "E_SCHEMA")
    reference: dict[str, tuple[str, Any]] | None = None
    for gate_id, path in inputs:
        try:
            payload = load_json(path, "E_SUBJECT_JOIN")
            if schema_errors(payload, schema) or payload.get("gate_id") != gate_id or payload.get("status") != "PASS":
                return ["E_SUBJECT_JOIN"]
            subject = typed_subject_map(payload)
        except (CheckFailure, OSError):
            return ["E_SUBJECT_JOIN"]
        if set(subject) != V8_SHARED_SUBJECT_KEYS:
            return ["E_SUBJECT_JOIN"]
        if reference is None:
            reference = subject
        elif subject != reference:
            return ["E_SUBJECT_JOIN"]
    return []


def validate_v8_join(
    registry: dict[str, Any], package: dict[str, Any], v8_receipt: dict[str, Any]
) -> list[str]:
    join_inputs = package["exit_receipt"].get("join_inputs", [])
    inputs: list[tuple[str, Path]] = []
    digest_keys: dict[str, str] = {}
    for item in join_inputs:
        artifact = item.get("artifact", {})
        if artifact.get("availability") != "existing":
            return ["E_SUBJECT_JOIN"]
        try:
            path = artifact_path(registry, artifact)
        except CheckFailure:
            return ["E_SUBJECT_JOIN"]
        inputs.append((item.get("gate_id"), path))
        digest_keys[item.get("digest_subject_key")] = file_digest(path) if path.is_file() else ""
    errors = validate_v8_same_subject(inputs)
    if errors:
        return errors
    try:
        v8_subject = typed_subject_map(v8_receipt)
        first_gate = load_json(inputs[0][1], "E_SUBJECT_JOIN")
        shared_subject = typed_subject_map(first_gate)
    except (CheckFailure, OSError):
        return ["E_SUBJECT_JOIN"]
    if set(v8_subject) != V8_SUBJECT_KEYS:
        return ["E_SUBJECT_JOIN"]
    for key, value in shared_subject.items():
        if v8_subject.get(key) != value:
            return ["E_SUBJECT_JOIN"]
    for key, digest in digest_keys.items():
        if v8_subject.get(key) != ("sha256", digest):
            return ["E_SUBJECT_JOIN"]
    return []


def validate_registry(
    registry: dict[str, Any], schema: dict[str, Any], schema_path: Path, roadmap_text: str,
    policy: dict[str, Any], policy_path: Path, subject_head: str,
    fixture_mode: bool, leases: list[dict[str, Any]]
) -> tuple[list[str], dict[str, Any]]:
    errors = validate_shape(registry, schema)
    packages_list = registry.get("packages", [])
    if errors:
        return sorted(set(errors)), {}
    package_ids = [package["id"] for package in packages_list]
    packages = {package["id"]: package for package in packages_list}
    facts = {fact["id"]: fact for fact in registry["external_facts"]}
    if len(packages) != len(packages_list) or len(facts) != len(registry["external_facts"]):
        errors.append("E_ID_DUPLICATE")
    snapshot = registry["source_snapshot"]
    snapshot_ids = snapshot["package_ids"]
    if len(snapshot_ids) != len(set(snapshot_ids)) or set(package_ids) != set(snapshot_ids):
        errors.append("E_SOURCE_SET_DRIFT")
    if len(packages_list) != 29:
        errors.append("E_SOURCE_SET_DRIFT")
    for package in packages_list:
        if package["source_id"] != package["id"]:
            errors.append("E_SOURCE_SET_DRIFT")
        for artifact in [package["exit_receipt"]["artifact"], *package["execution_state"]["transition_receipts"]]:
            try:
                artifact_path(registry, artifact)
            except CheckFailure as exc:
                errors.append(exc.code)
        for command in package["check_command"].values():
            if not command_is_safe(command):
                errors.append("E_COMMAND_UNSAFE")
    basis = registry["basis"]
    authority = registry["authority"]
    authority_path = ROOT / authority["source_path"]
    if (
        not authority_path.is_file()
        or not SHA256_RE.fullmatch(str(authority.get("source_sha256", "")))
        or hashlib.sha256(authority_path.read_bytes()).hexdigest() != authority["source_sha256"]
    ):
        errors.append("E_DECISION_STATE")
    source_sha = sha256_text(source_basis_text(roadmap_text))
    if (
        basis["repo_head"] != snapshot["repo_head"]
        or basis["repo_head"] != subject_head
        or basis["roadmap_sha256"] != snapshot["source_sha256"]
        or basis["roadmap_sha256"] != source_sha
        or basis["roadmap_path"] != snapshot["source_path"]
    ):
        errors.append("E_STALE_BASIS")
    consumers: dict[str, set[str]] = defaultdict(set)
    prerequisites_by_package: dict[str, set[str]] = defaultdict(set)
    for package in packages_list:
        for prereq in package["prerequisites"]:
            predecessor = prereq["package_id"]
            if predecessor not in packages or predecessor == package["id"]:
                errors.append("E_DAG")
            else:
                consumers[predecessor].add(package["id"])
                prerequisites_by_package[package["id"]].add(predecessor)
    edge_basis = registry["edge_basis"]
    if (
        edge_basis.get("default_basis") != "conservative_v2"
        or not edge_basis.get("default_authority_refs")
    ):
        errors.append("E_EDGE_BASIS")
    overridden_edges: set[tuple[str, str]] = set()
    for override in edge_basis.get("overrides", []):
        edge = (override.get("from"), override.get("to"))
        if (
            edge in overridden_edges
            or edge[0] not in packages
            or edge[1] not in packages
            or edge[0] not in prerequisites_by_package[edge[1]]
            or override.get("basis") not in ALLOWED_EDGE_BASIS
            or not override.get("authority_refs")
        ):
            errors.append("E_EDGE_BASIS")
        overridden_edges.add(edge)
    for edge in snapshot.get("hard_edges", []):
        source_edge = (edge.get("from"), edge.get("to"))
        if source_edge not in overridden_edges:
            errors.append("E_EDGE_BASIS")
    roots = set(registry["closure_roots"])
    if not roots.issubset(packages):
        errors.append("E_DAG")

    def reaches_root(package_id: str, seen: set[str]) -> bool:
        if package_id in roots:
            return True
        if package_id in seen:
            return False
        return any(reaches_root(next_id, seen | {package_id}) for next_id in consumers[package_id])

    if any(package["closure_required"] and not reaches_root(package["id"], set()) for package in packages_list):
        errors.append("E_DAG")

    visit_state: dict[str, int] = {}

    def has_cycle(package_id: str) -> bool:
        state = visit_state.get(package_id, 0)
        if state == 1:
            return True
        if state == 2:
            return False
        visit_state[package_id] = 1
        result = any(has_cycle(predecessor) for predecessor in prerequisites_by_package[package_id])
        visit_state[package_id] = 2
        return result

    if any(has_cycle(package_id) for package_id in packages):
        errors.append("E_DAG")
    bootstrap = registry["authority"].get("bootstrap_ratification_receipt")
    if bootstrap is not None:
        try:
            bootstrap_path = artifact_path(registry, bootstrap)
            if registry["authority"]["state"] != "ratified" or not bootstrap_path.is_file():
                errors.append("E_BOOTSTRAP_REUSE")
        except CheckFailure:
            errors.append("E_BOOTSTRAP_REUSE")
    try:
        expected_policy = artifact_path(registry, registry["o6_resource_policy_ref"]["artifact"])
        if expected_policy != policy_path.resolve():
            errors.append("E_RESOURCE_POLICY")
        claims, pairs = validate_resource_policy(policy)
    except CheckFailure as exc:
        errors.append(exc.code)
        claims, pairs = {}, set()
    resource_errors: list[str] = []
    running_resources: list[tuple[str, set[str]]] = []
    for package in packages_list:
        state = package["execution_state"]["declared"]
        if state == "running":
            package_leases = [lease for lease in leases if lease["package_id"] == package["id"] and lease.get("valid")]
            lease_claims = {lease["claim_id"] for lease in package_leases}
            if not package_leases or not set(package["resource_claim_refs"]).issubset(lease_claims):
                resource_errors.append("E_RESOURCE_CONFLICT")
            resources: set[str] = set()
            for claim_id in package["resource_claim_refs"]:
                if claim_id not in claims:
                    resource_errors.append("E_RESOURCE_POLICY")
                resources.update(claims.get(claim_id, set()))
            running_resources.append((package["id"], resources))
    for index, (_, left_resources) in enumerate(running_resources):
        for _, right_resources in running_resources[index + 1 :]:
            if any(tuple(sorted((left, right))) in pairs for left in left_resources for right in right_resources):
                resource_errors.append("E_RESOURCE_CONFLICT")
    if resource_errors:
        errors.extend(resource_errors)
    receipts, receipt_errors = load_done_receipts(registry, packages, fixture_mode)
    errors.extend(receipt_errors)
    count_keys: set[str] = set()
    deliverables: set[str] = set()
    exit_paths: set[str] = set()
    profiles = {profile["id"]: profile for profile in registry["proof_profiles"]}
    for package in packages_list:
        count_key = package["counting"]["count_key"]
        if count_key in count_keys:
            errors.append("E_COUNTING")
        count_keys.add(count_key)
        for deliverable in package["counting"]["deliverable_keys"]:
            if deliverable in deliverables:
                errors.append("E_COUNTING")
            deliverables.add(deliverable)
        exit = package["exit_receipt"]
        # Receipt ownership is keyed by its logical receipt path, not by the
        # convenience root label.  Otherwise a package could evade R14 by
        # relabeling the same path from ``build`` to ``repo``.
        exit_path = exit["artifact"]["path"]
        if exit_path in exit_paths or exit["owner_package_id"] != package["id"]:
            errors.append("E_RECEIPT_ALIAS")
        exit_paths.add(exit_path)
        state = package["execution_state"]["declared"]
        decision = package["decision_state"]["declared"]
        authority_refs = package["decision_state"].get("authority_refs", [])
        if not authority_refs or (decision == "ratified" and any(ref.get("required_state") != "ratified" for ref in authority_refs)):
            errors.append("E_DECISION_STATE")
        if decision != "ratified" and state in {"ready", "running", "done"}:
            errors.append("E_DECISION_STATE")
        if state in {"ready", "running"}:
            prereq_ok = all(
                prereq["package_id"] in packages
                and packages[prereq["package_id"]]["execution_state"]["declared"] == "done"
                and (not prereq["require_receipt"] or prereq["package_id"] in receipts)
                for prereq in package["prerequisites"]
            )
            external_ok = all(facts.get(gate["fact_id"], {}).get("status") == "satisfied" for gate in package["external_gates"])
            if not prereq_ok or not external_ok or not command_available(package["check_command"]["entry"]):
                errors.append("E_READY_PREREQUISITE")
        errors.extend(validate_transition_chain(registry, package))
        profile = profiles.get(package["proof_profile_id"])
        if profile is None:
            errors.append("E_PROOF_PROMOTION")
            continue
        evidence_classes = set()
        for evidence in package["proof_state"]["evidence"]:
            evidence_classes.add(evidence["class"])
            if evidence["claim"] not in profile["allowed_claims"] or evidence["claim"] in profile["forbidden_claims"]:
                errors.append("E_PROOF_PROMOTION")
        if state == "done":
            if not set(profile["done_requires"]["all_of"]).issubset(evidence_classes):
                errors.append("E_PROOF_PROMOTION")
            if not run_command(package["check_command"]["exit"]):
                errors.append("E_DONE_RECEIPT")
    if packages["V8"]["execution_state"]["declared"] == "done":
        errors.extend(validate_v8_join(registry, packages["V8"], receipts.get("V8", {})))
    counts = derive_counts(packages_list)
    if counts["hard_leaf_denominator"] != 28:
        errors.append("E_COUNTING")
    generated = render_generated_block(registry)
    marker_matches = list(MARKER_RE.finditer(roadmap_text))
    if len(marker_matches) != 1 or marker_matches[0].group(0).strip() != generated.strip():
        errors.append("E_GENERATED_BLOCK_DRIFT")
    for token_match in TOKEN_RE.finditer(roadmap_text):
        token = token_match.group(0)
        inside = len(marker_matches) == 1 and marker_matches[0].start() <= token_match.start() <= marker_matches[0].end()
        if not TOKEN_GRAMMAR.fullmatch(token) or not inside or token != count_token(registry_digest(registry), counts):
            errors.append("E_HANDWRITTEN_COUNT")
    metadata = {
        "counts": counts,
        "registry_digest": registry_digest(registry),
        "source_snapshot_sha256": snapshot["source_sha256"],
        "o6_resource_policy_sha256": sha256_text(canonical_json(policy)),
        "schema_sha256": file_digest(schema_path),
        "checker_sha256": checker_digest(),
        "repo_head": subject_head,
        "resource_holds": [package_id for package_id, _ in running_resources],
    }
    if resource_errors:
        return sorted(set(resource_errors)), metadata
    return sorted(set(errors)), metadata


def exit_code(errors: list[str]) -> int:
    codes = set(errors)
    if not errors:
        return 0
    if codes & {"E_PARSE_AMBIGUOUS", "E_SCHEMA"}:
        return 64
    if codes & {"E_RESOURCE_POLICY", "E_RESOURCE_CONFLICT"}:
        return 67
    if codes & {"E_GENERATED_BLOCK_DRIFT", "E_HANDWRITTEN_COUNT"}:
        return 68
    if codes & {"E_DONE_RECEIPT", "E_RECEIPT_REVISION", "E_PROOF_PROMOTION", "E_SUBJECT_JOIN"}:
        return 69
    if codes & {"E_PATH_ESCAPE", "E_COMMAND_UNSAFE", "E_STALE_BASIS"}:
        return 70
    if codes & {"E_ID_DUPLICATE", "E_SOURCE_SET_DRIFT", "E_DAG", "E_EDGE_BASIS", "E_COUNTING", "E_RECEIPT_ALIAS"}:
        return 66
    return 65


def write_receipt(path: Path, errors: list[str], metadata: dict[str, Any]) -> None:
    counts = metadata.get("counts", {})
    payload = {
        "schema_version": CHECK_RECEIPT_VERSION,
        "status": "PASS" if not errors else "BLOCKED",
        "repo_head": metadata.get("repo_head", "not_checked"),
        "registry_sha256": metadata.get("registry_digest", ""),
        "source_snapshot_sha256": metadata.get("source_snapshot_sha256", ""),
        "o6_resource_policy_sha256": metadata.get("o6_resource_policy_sha256", ""),
        "schema_sha256": metadata.get("schema_sha256", ""),
        "checker_sha256": metadata.get("checker_sha256", checker_digest()),
        "package_count": counts.get("package_count", 0),
        "hard_leaf_denominator": counts.get("hard_leaf_denominator", 0),
        "counts_by_execution": {key: counts.get(key, 0) for key in ALLOWED_EXECUTION},
        "root_reach": "29/29" if not any(error in {"E_DAG", "E_SOURCE_SET_DRIFT"} for error in errors) else "blocked",
        "resource_pair_encoding": "unordered_canonical_single_row",
        "lease_states": ["running"],
        "resource_holds": metadata.get("resource_holds", []),
        "errors": errors,
    }
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def command_check(args: argparse.Namespace) -> int:
    registry_path = Path(args.registry)
    roadmap_path = Path(args.roadmap)
    receipt_path = Path(args.receipt)
    try:
        registry = load_yaml(registry_path)
        schema_path = Path(args.schema)
        schema = load_json(schema_path, "E_SCHEMA")
        if not GIT_SHA_RE.fullmatch(args.subject_head):
            raise CheckFailure("E_STALE_BASIS", "checked subject head must be a 40-character lowercase git SHA")
        roadmap_text = read_utf8(roadmap_path)
        policy_path = Path(args.o6_policy)
        policy = load_yaml(policy_path)
        fixture_mode = args.fixture is not None
        leases: list[dict[str, Any]] = []
        if fixture_mode:
            registry, roadmap_text, leases = apply_fixture(registry, roadmap_text, Path(args.fixture))
            generated = render_generated_block(registry)
            if MARKER_RE.search(roadmap_text):
                roadmap_text = MARKER_RE.sub("\n" + generated + "\n", roadmap_text)
            else:
                roadmap_text = roadmap_text.rstrip("\n") + "\n\n" + generated + "\n"
        errors, metadata = validate_registry(
            registry, schema, schema_path, roadmap_text, policy, policy_path,
            args.subject_head, fixture_mode, leases
        )
    except CheckFailure as exc:
        errors, metadata = [exc.code], {}
    write_receipt(receipt_path, errors, metadata)
    return exit_code(errors)


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description=__doc__)
    subcommands = result.add_subparsers(dest="command", required=True)
    check = subcommands.add_parser("check")
    check.add_argument("--registry", required=True)
    check.add_argument("--schema", required=True)
    check.add_argument("--roadmap", required=True)
    check.add_argument("--o6-policy", required=True)
    check.add_argument("--receipt", required=True)
    check.add_argument("--subject-head", required=True)
    check.add_argument("--fixture")
    render = subcommands.add_parser("render")
    render.add_argument("--registry", required=True)
    digest = subcommands.add_parser("digest")
    digest.add_argument("--registry", required=True)
    return result


def main(argv: list[str]) -> int:
    args = parser().parse_args(argv)
    if args.command == "check":
        return command_check(args)
    registry = load_yaml(Path(args.registry))
    if args.command == "render":
        print(render_generated_block(registry))
    else:
        print(registry_digest(registry))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
