---
retire_trigger: "Retire when superseded by archived OpenSpec specs or explicit user decision."
expires: "2026-08-15"
---

# R5 D16 Gate 4 - Core Config / Force-State Upstream Verifier

Date: 2026-06-29
Gate: `D16_GATE_4_UPSTREAM_VERIFIER`
Repo: `/Users/wanglei/workspace/MAformac`
UIUE: `/Users/wanglei/workspace/MAformac-uiue` read-only

## Verdict

`BLOCKED_D17_RELEASE_CLOSED`

`d17_release_gate: closed`

Gate 4 does not release D17. Hermes returned an anchored FAIL with P0 empty and P1 on a remaining construction bypass: `DemoForceStateContext` is still externally constructible through synthesized `Decodable`/`Codable`, even after the explicit initializer was made internal. Per commander intake guardrail, any remaining bypass closes the release gate and stops the supertrain.

## Live Truth

### Main

- HEAD: `47c5e9c4c71fb37eda64f1d61795b9c4b51c7012`
- Branch: `codex/rebuild-c6-doc-absorption-20260624`
- D16 commits since start `1d9b67412b7fa11fbce5f7b5f52be6f2586c475d`:
  - `16860c8 docs(main): define d16 core config force-state authority`
  - `d00023a feat(main): add d16 core config authority`
  - `47c5e9c feat(main): add d16 force-state boundary`
- Preserve-unowned dirty remains unstaged and out of Gate4 scope: `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`, `.xcodebuildmcp/`, `Tools/agent-platform-plugin-refs/`

### UIUE

- HEAD: `531a189d36d5462dadeea47393d5d6b5b3c5c2bf`
- Branch: `uiue/phase4-default-scope-presentation`
- Read-only status matches expected untracked source artifacts: D12-D16/D17 dispatch docs plus `docs/research/2026-06-29-visual-acceptance-standard/`
- No UIUE file was written or staged in Gate4.

## Clean Worktree Verifier

Created clean detached worktree:

```text
/tmp/maformac-d16-gate4-clean.WwiS4e
```

Clean worktree status:

```text
## HEAD (no branch)
```

Committed D16 diff from `1d9b67412b7fa11fbce5f7b5f52be6f2586c475d..HEAD`:

```text
A Core/Config/DemoForceStateBoundary.swift
A Core/Config/SceneMacroRegistry.swift
A Tests/MAformacCoreTests/DemoForceStateBoundaryTests.swift
A Tests/MAformacCoreTests/SceneMacroRegistryTests.swift
A docs/project/phase0/r5-d16-gate1-core-config-force-state-authority-2026-06-29.md
A docs/project/phase0/r5-d16-gate2-core-config-code-2026-06-29.md
A docs/project/phase0/r5-d16-gate3-force-state-boundary-code-2026-06-29.md
A openspec/changes/define-core-config-force-state-authority/.openspec.yaml
A openspec/changes/define-core-config-force-state-authority/design.md
A openspec/changes/define-core-config-force-state-authority/proposal.md
A openspec/changes/define-core-config-force-state-authority/specs/core-config-force-state/spec.md
A openspec/changes/define-core-config-force-state-authority/tasks.md
```

## Gate3 Intake Guardrail

Gate3 is recorded as:

- Hermes transcript: `Reports/r5-d16-gate3-20260629T1757/hermes-output.txt`
- Anchor: `HERMES_R5_D16_GATE_3_FORCE_STATE_BOUNDARY_CODE_VERDICT: FAIL`
- P0: empty
- P1: `DemoForceStateContext` public initializer bypassed `DemoForceStateBoundary.accept(...)`
- Fix: `DemoForceStateContext.init(...)` is internal after audit
- Rerun: no Hermes rerun, per operator one-pass override for Gate1-Gate7
- Valid proof after fix: local/unit + local/static + OpenSpec only

Gate4 release must not state or imply Gate3 Hermes PASS. Gate8 Claude Code adversarial final audit must include this Gate3 P1 absorption and verify no remaining public construction bypass.

## Verification Evidence

| Check | Result | Proof class |
| --- | --- | --- |
| `git diff --check 1d9b67412b7fa11fbce5f7b5f52be6f2586c475d..HEAD` from clean worktree | PASS | local/static |
| `swift test --filter 'SceneMacroRegistryTests\|DemoForceStateBoundaryTests\|RuntimePresentationBridgeTests'` from clean worktree | PASS, 27 tests / 0 failures | local/unit |
| `openspec validate define-core-config-force-state-authority --strict && openspec validate --all --strict` from clean worktree | PASS; full OpenSpec 18 items / 0 failed | local/OpenSpec |
| `node .gitnexus/run.cjs analyze` if present, else `npx gitnexus analyze` from main | PASS; 28,064 nodes, 49,853 edges, 998 clusters, 300 flows | local/GitNexus |
| `mcp__gitnexus.detect_changes(scope=compare, base_ref=1d9b674...)` from live worktree | Low risk but polluted by preserve-unowned dirty; not used as clean authority | local/GitNexus limitation |
| `mcp__gitnexus.detect_changes(scope=staged)` for Gate4 receipt/tasks | Low risk, 2 staged files, 0 affected processes | local/GitNexus |
| UIUE read-only grep for D16 stable names under `Core App Features Tests openspec Package.swift` | No premature D16 stable name consumption | local/static |
| UIUE read-only grep for forbidden private names under `Core App Features Tests openspec Package.swift` | No `DemoRuntimeAdapter`, `RuntimeAdapterBox`, fingerprints, ledgers, raw store/model/training receipt consumption | local/static |
| Clean worktree grep for `DemoForceStateContext(` / `public init(` / force-state names | Expected constructor call only inside boundary return; `DemoForceStateContext` has no public initializer | local/static |
| Claim grep for forbidden proof promotion | Only non-claim / negative assertions and fail-closed tests; no D16 runtime/mobile/true-device/live/V-PASS claim | local/static |

UIUE bounded evidence:

```text
rg ... Core App Features Tests openspec Package.swift
exit=1 for D16 stable names and forbidden private names
```

The only earlier broad UIUE grep hit was historical/generated corpus noise and is not used as verifier proof.

## GitNexus Notes

- Main index was refreshed after Gate3 commit.
- Live-worktree compare is polluted by preserve-unowned dirty files because the MCP server sees local dirty documents. Clean detached worktree diff and source/test/static checks are load-bearing for committed D16 verification.
- No HIGH or CRITICAL unexplained GitNexus risk is used for release.

## Hermes Gate4 Audit

- Prompt: `Reports/r5-d16-gate4-20260629T1808/hermes-prompt.txt`
- Transcript: `Reports/r5-d16-gate4-20260629T1808/hermes-output.txt`
- Anchor: `HERMES_R5_D16_GATE_4_UPSTREAM_VERIFIER_VERDICT: FAIL`
- P0: Empty.
- P1: `DemoForceStateContext` remains externally constructible through synthesized `Decodable`/`Codable`; an external package can decode JSON with `"isolation":"customer_facing"` and receive a `DemoForceStateContext` with `proofClass = .localUnit` without passing through `DemoForceStateBoundary.accept(...)`.
- P2: UIUE read-only conclusion is directionally correct, but the receipt should preserve exact grep boundaries and distinguish existing UIUE bridge/context vocabulary from D16 stable-name consumption.
- Release gate recommendation from Hermes: closed.
- Controller decision: closed, no D17 start.

## Harness

| Item | Result |
| --- | --- |
| Lesson learned / metacognitive reflection | A release gate can fail by wording even when code is fixed. Gate3 remains an absorbed Hermes FAIL, not a PASS. |
| Pre-mortem | D17 could start on a false green if Gate4 hides Gate3 P1 absorption, relies on dirty live-worktree compare, or treats UIUE historical transcripts as active consumption. |
| Local repo cross-search | Main clean worktree and UIUE bounded code/OpenSpec grep were both used; broad UIUE corpus grep was discarded as noisy. |
| Necessary web cross-search | Not used. Gate4 verifier is repo-local and tool-output based. |
| Iceberg visible symptom | Gate3 P1 fixed after audit, but no Hermes rerun. |
| Iceberg underlying class | Audit result laundering: absorbed findings can be incorrectly rewritten as audited PASS. |
| Iceberg same-class risk map | Gate4 release wording, D17 authority receipt, Gate8 final audit, route map reconcile. |
| Immediate fix | Write `d17_release_gate` basis as operator override + post-fix local proof, not Hermes PASS. |
| Class-level fix | Gate8 Claude Code adversarial audit must explicitly re-check Gate3 P1 absorption. |
| Governance fix | D17 may start only after this Gate4 receipt is committed with `d17_release_gate: open` and Gate4 Hermes is acceptable. |
| Goal drift | No UIUE writes, no source dispatch staging, no push/PR/merge, no runtime/mobile/true-device/live proof. |
| Authority | Gate4 section of D16+D17 source dispatch; D16 OpenSpec `core-config-force-state`; committed Gate1-Gate3 receipts. |
| Claim-vs-proof | D16 proof remains local/unit/static/OpenSpec plus audit transcripts. Release-to-D17 is governance permission, not product readiness. |
| Boundary | UIUE may consume only D15 presentation-safe payload fields and D16 stable main-owned names after release; it may not consume debug force-state internals or private runtime adapter fields. |
| If wrong, what proves it | `Reports/r5-d16-gate3-20260629T1757/hermes-output.txt`, `Core/Config/DemoForceStateBoundary.swift`, `Tests/MAformacCoreTests/DemoForceStateBoundaryTests.swift`, UIUE bounded grep commands, and clean worktree diff commands above. |
| Post-audit correction | Gate4 Hermes found a remaining construction bypass via `Decodable`; per commander guardrail, Gate4 closes D17 release and stops. |

## Release Decision

Closed:

```yaml
d17_release_gate: closed
blocker:
  class: remaining_public_construction_bypass
  evidence: Reports/r5-d16-gate4-20260629T1808/hermes-output.txt
  detail: DemoForceStateContext remains externally decodable as customer_facing without DemoForceStateBoundary.accept
completed_basis:
  - Gate1 authority committed
  - Gate2 core config local/unit proof committed
  - Gate3 force-state boundary committed with Hermes FAIL/P1 fixed after audit
  - clean worktree validation passed
  - UIUE read-only grep found no premature D16 consumption
  - operator one-pass Hermes override applies to Gate1-Gate7
not_release_basis:
  - not Gate3 Hermes PASS
  - not Gate4 Hermes PASS
  - not Release binary proof
  - not runtime/mobile/true-device/live/V-PASS proof
next_minimal_fix:
  - harden or remove DemoForceStateContext external Decodable/Codable construction surface
  - add regression proof that an external client cannot construct/decode customer_facing DemoForceStateContext
  - rerun local validation and request explicit commander/operator direction before reopening D17
```

## Non-Claims

- No production-ready claim.
- No runtime-ready claim.
- No mobile, true-device, live API, V-PASS, S-PASS, U-PASS, A-2, UIUE merge, voice-ready, model-ready, golden-ready, or endpoint-ready claim.
- No UIUE implementation has started in Gate4.
