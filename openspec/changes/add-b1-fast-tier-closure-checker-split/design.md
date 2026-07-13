## Context

W8 runtime-spine authorizes a static/local-fast closure lane for solo iteration. Remote `verify-ci` must remain on the existing full `verify-closure-work-packages` target. Four pytest cases (`committed_registry_probe` git-clone family) are the heavy slice; all other closure contract tests stay on the static slice while still running `check_closure_work_packages.py check`.

## Goals / Non-Goals

**Goals:**

- Deterministic path classification with explicit reasons and a thin read-only git adapter.
- Pytest partition keyed on a shared constant list of four stable function names (no marker registration and no line numbers).
- Make targets: `verify-closure-work-packages-static`, `verify-closure-work-packages-local-fast`, unchanged `verify-closure-work-packages`.

**Non-Goals:**

- No CI default switch to local-fast.
- No edits outside the FT1 allowlist.

## Decisions

### AD-001 — Three-tier fail-closed classifier

The closed tier enum is `ordinary_docs < closure_authority < full`; aggregation always selects the strongest changed path. Empty input, unrecognized paths, malformed git output, missing base/subject ancestry, shallow history, or registry-reference parse failure yields `full`.

### AD-002 — Exact path authority

Ordinary documentation is `docs/**` excluding authority patterns. Closure authority is exactly decisions, roadmap, handoffs, CURRENT, OpenSpec changes, closure receipts, and commander documents. Everything else—including `Makefile`, `.github/**`, scripts, contracts, tests, generated files, unknown roots, and product code—is `full`. A deleted authority or registry-referenced path escalates to `full`; an unreferenced ordinary-doc deletion remains `ordinary_docs`.

### AD-003 — Pytest deselect via stable names

The ratified source roster remains exactly 20 functions: 16 static + four clone/history-heavy. The static Make target passes stable-name `--deselect` pairs emitted by the classifier CLI. The split is semantic; it is not a wall-clock guarantee. A prior local static run measured about 152 seconds, so this change makes no speedup claim.

### AD-004 — local-fast orchestration

The adapter requires explicit base and subject commits, rejects shallow/missing ancestry, parses `git diff --name-status -z` with both rename/copy sides, unions committed range changes with staged+unstaged `git diff HEAD` and untracked `git ls-files -z`, and only permits an environment manifest to add paths. `ordinary_docs` retains `git diff --check` and `verify-cross-section`; `closure_authority` runs full closure verification; `full` runs `verify-ci`. The full target never depends on local-fast, so dispatch cannot recurse.

## Risks

- Drift if new git-sensitive tests are added without updating the stable roster → mitigated by an exact source-function conservation test.
- Git status grammar or repository history is incomplete → fail closed to `full`.

## Proof ceiling

Local pytest + Make wiring checks only. Not proof of GitHub runner timing or W8 spine completion.

## Non-claims

- `verify-ci` is not shortened.
- The explicit static closure-test target does not remove the real checker invocation.
