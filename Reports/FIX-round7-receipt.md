# FIX round 7 receipt — matrix canonical gate

- `status`: `DONE_LOCAL_GATES_PASSED_AWAITING_FRESH_AUDIT`
- `base_sha`: `6e2bf2a47463a4c1f5082eb3bed65ba48f0970f7`
- `code_head_sha`: `fb1df44d30ce649b0ba8900f6391118a44ed1fd2`
- `branch`: `c1/int-v4-governance-repair`
- `worktree`: `/Users/wanglei/workspace/MAformac-ma13-wt/fix-p01`
- `proof_class`: `local + unit + integration + macOS build`

## Conclusion

P0 root cause was a missed regeneration after the T0 authority changed, not nondeterministic materialization: two fresh materializations compared equal, while the tracked matrix differed only in `source.t0_design_sha256`. The tracked matrix and its Swift projection were regenerated from the current authority without changing cell semantics.

The checker now executes the committed Draft 2020-12 schema, locks the exact `1...120` ID set, and rejects any full fresh-canonical mismatch with `E_MATRIX_CANONICAL_DRIFT`. The top-level `diff` target now materializes a fresh matrix and Swift projection to temporary artifacts and byte-compares both before checking the normal generated-file diff.

## Canonical and negative evidence

| Check | Result |
|---|---|
| fresh materialize twice | byte-identical |
| fresh matrix vs tracked matrix | `cmp rc=0` after regeneration |
| tracked matrix truth | 120 cells; `canDemo=0`; classes `0/36/82/1/1` |
| named negative CLI cases | all red: stale provenance, missing `source`, wrong `schema_version`, tampered `family`, `value_shape`, `register`, `injected_path_status`, `source_hash`, `anchors`, and `matrix_id=999` |
| source mutation without regeneration | isolated `make diff rc=2` at matrix canonical cmp |
| removed `diff` canonical prerequisite | isolated `make verify-c1-matrix rc=2` at `test_diff_target_requires_matrix_and_swift_canonical_regeneration` |

## Fresh validation

| Command | Result |
|---|---|
| `make verify-c1-matrix` | rc=0; 12 probe-checker tests, 28 matrix tests, 40 fallback cases, action/readback receipt PASS |
| `make verify-all` | rc=0; 783 tests, 7 skipped, 0 failures |
| `make verify-ci` | rc=0; 783 tests, 7 skipped, 0 failures |
| `make verify-c1-finite-reason-authority` | rc=0; G1-G4 acceptance surface PASS |
| root-bound G5 `jq -e` membership check | rc=0 / `true` |
| `make verify-c1-probes` | covered by `verify-all` and `verify-ci`, rc=0 |
| `xcodebuild -scheme MAformacMac build` | rc=0; `BUILD SUCCEEDED` |
| `git diff --check` before code commit | rc=0 |

The original acceptance-SPEC G5 jq expression was also run and returned `rc=5` (`Cannot index array with string "finiteReason_enum"`), matching the pre-existing w1 finding that it has an array-scope bug. It is not represented as PASS; the root-bound equivalent above is the code-level acceptance check.

## Scope and residuals

- No change to the 120 cell semantics, `canDemo=0/120`, class conservation, mounted catalog, T0 membership, `ContentView`, or `Core/Training`.
- This producer receipt is not an independent re-audit and does not declare PR-ready, operator-pass, V-PASS, device, or live-api proof.
- Local GitNexus index refresh updated `AGENTS.md` and `CLAUDE.md`; those unrelated working-tree changes were deliberately not staged.
- Required next action: fresh non-producer audit on the pushed head, including canonical cmp and the named negative cases.
