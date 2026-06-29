# R5 D16 Gate 4R - Force-State Codable Bypass Repair And Reopen

Date: 2026-06-29
Gate: `D16_GATE_4R_FORCE_STATE_CODABLE_BYPASS_REPAIR_REOPEN`
Repo: `/Users/wanglei/workspace/MAformac`
UIUE: `/Users/wanglei/workspace/MAformac-uiue` read-only

## Verdict

`LOCAL_VALIDATION_PASS_PENDING_AUDIT`

`d17_release_gate: pending_audit`

Gate4R repairs the Gate4 Hermes P1 construction bypass by removing `DemoForceStateContext` synthesized `Codable` / `Decodable` conformance. External clients can still read contexts returned by `DemoForceStateBoundary.accept(...)`, but cannot decode or construct a `DemoForceStateContext` with `isolation = customer_facing` through `JSONDecoder`.

## Live Truth

### Main

- Start HEAD: `e4f25598e148ab33bc621d6f34faeabe31e5d331`
- Branch: `codex/rebuild-c6-doc-absorption-20260624`
- Preserve-unowned dirty remains unstaged and out of Gate4R scope: `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`, `.xcodebuildmcp/`, `Tools/agent-platform-plugin-refs/`
- Cached at start: empty

### UIUE

- HEAD: `531a189d36d5462dadeea47393d5d6b5b3c5c2bf`
- Branch: `uiue/phase4-default-scope-presentation`
- Read-only dirty: source dispatch docs and `docs/research/2026-06-29-visual-acceptance-standard/`
- Cached at start: empty
- Gate4R writes: none

## Owned Changes

- `Core/Config/DemoForceStateBoundary.swift`
  - `DemoForceStateContext` changed from `Codable, Equatable, Sendable` to `Equatable, Sendable`.
  - `DemoForceStateContext.init(...)` remains internal.
  - `proofClass` remains computed and fixed to `.localUnit`.
  - No `DemoVehicleStateStore`, runtime adapter, C3 execution path, UIUE code, or production force-state runtime was touched.
- `Tests/MAformacCoreTests/DemoForceStateBoundaryTests.swift`
  - Added `testForceStateContextIsNotExternallyDecodable`.
  - Preserved fail-closed tests for `.customerFacing`, missing `.demoHarness` provenance, empty context, and duplicate dimensions.
- `openspec/changes/define-core-config-force-state-authority/tasks.md`
  - Added Gate4R task truth.

## Why `public init(` Grep Was Insufficient

Gate3 fixed the explicit public initializer bypass by making `DemoForceStateContext.init(...)` internal. Gate4 Hermes correctly found the same construction class through a different Swift surface: public `Codable` implies synthesized `Decodable`, and an external package can call `JSONDecoder().decode(DemoForceStateContext.self, ...)` without `DemoForceStateBoundary.accept(...)`. Therefore a syntactic grep for `public init(` is not enough; protocol conformance can be an external construction surface.

## GitNexus

- `context(DemoForceStateContext)`: found in `Core/Config/DemoForceStateBoundary.swift`, incoming caller only `DemoForceStateBoundary.accept`, no processes.
- `context(DemoForceStateBoundary)`: incoming callers are Gate4R/Gate3 tests, no processes.
- `context(DemoForceStateValue)`: incoming callers are tests, no processes.
- `impact(...)` was not exposed in the available GitNexus MCP tool surface for this turn. This limitation is compensated by direct source diff, unit tests, external package compile probe, and staged `detect_changes`.
- Pre-edit live `detect_changes(unstaged)` was polluted by preserve-unowned dirty and is not used as proof.

## Validation Evidence

| Check | Result | Proof class |
| --- | --- | --- |
| `swift test --filter DemoForceStateBoundaryTests` | PASS, 6 tests / 0 failures | local/unit |
| `swift test --filter 'DemoForceStateBoundaryTests\|SceneMacroRegistryTests\|RuntimePresentationBridgeTests'` | PASS, 28 tests / 0 failures | local/unit |
| `git diff --check` | PASS | local/static |
| `openspec validate define-core-config-force-state-authority --strict && openspec validate --all --strict` | PASS; full OpenSpec 18 items / 0 failed | local/OpenSpec |
| `rg -n "DemoForceStateContext.*Codable\|DemoForceStateContext.*Decodable\|JSONDecoder\\(\\)\\.decode\\(DemoForceStateContext\|public init\\(" Core/Config/DemoForceStateBoundary.swift Tests/MAformacCoreTests/DemoForceStateBoundaryTests.swift` | PASS for the repaired surface: no `DemoForceStateContext` Codable/Decodable conformance or decode call; remaining public initializers are `DemoForceStateValue` and `DemoForceStateBoundary`. | local/static |
| UIUE bounded grep under `Core App Features Tests openspec Package.swift` for D16 stable names / force-state names | Exit 1, no premature D16/D17 consumption in bounded active surfaces | local/static |

## External Package Decode Probe

Probe path:

```text
/tmp/maformac-d16-gate4r-external-decode
```

Probe attempted:

```swift
let decoded = try JSONDecoder().decode(DemoForceStateContext.self, from: data)
```

Result with `bash -o pipefail -lc 'swift build --package-path /tmp/maformac-d16-gate4r-external-decode 2>&1 | tee /tmp/maformac-d16-gate4r-external-decode/build-output-r2.txt'`:

```text
exit=1
error: instance method 'decode(_:from:)' requires that 'DemoForceStateContext' conform to 'Decodable'
```

This directly closes the Gate4 Hermes reproduction path where an external package decoded `isolation=customer_facing` and received `proofClass = .localUnit`.

## Harness

| Item | Result |
| --- | --- |
| Lesson learned / metacognitive reflection | Public protocol conformance is an API surface. Fixing an initializer does not close synthesized decoding. |
| Pre-mortem | The repair could accidentally remove useful value DTO encoding, broaden runtime behavior, or call Gate4R open before auditor checks the external probe. |
| Local repo cross-search | Checked `DemoForceStateContext`, tests, OpenSpec tasks, and UIUE bounded active surfaces. |
| Necessary web cross-search | Not used. This is Swift local API conformance behavior and was proven by compile/runtime tools. |
| Iceberg visible symptom | External `JSONDecoder` could mint a `.customerFacing` context. |
| Iceberg underlying class | Construction bypass via synthesized protocol conformance. |
| Iceberg same-class risk map | Future DTOs with synthesized decoding, UIUE consumer DTOs, proof-class-bearing public contexts. |
| Immediate fix | Remove `Codable` from authoritative `DemoForceStateContext`. |
| Class-level fix | Use separate export DTOs or Encodable-only surfaces when serialization is needed; never make authoritative contexts externally decodable without validation. |
| Governance fix | Gate8 final Claude Code audit must include Gate3 explicit-init bypass and Gate4 Codable bypass. |
| Goal drift | No UIUE write, no runtime adapter, no store write, no production force-state, no push/PR/merge. |
| Authority | Dispatch 0A Gate4R amendment, Gate4 Hermes transcript, D16 OpenSpec `core-config-force-state`, Gate3/Gate4 receipts. |
| Claim-vs-proof | This proves local/unit/static closure of the external decode bypass. It is not runtime/mobile/true-device/live proof. |
| Boundary | UIUE remains blocked until Gate4R audit and final release decision. |
| If wrong, what proves it | `Core/Config/DemoForceStateBoundary.swift`, `Tests/MAformacCoreTests/DemoForceStateBoundaryTests.swift`, `/tmp/maformac-d16-gate4r-external-decode/build-output-r2.txt`, and `Reports/r5-d16-gate4-20260629T1808/hermes-output.txt`. |
| Post-audit correction | Pending Gate4R audit. |

## Release Decision

Pending one audit pass:

```yaml
d17_release_gate: pending_audit
external_decodable_bypass_closed: true
release_basis_if_audit_passes:
  - Gate4R removed DemoForceStateContext Decodable/Codable conformance
  - external package JSONDecoder probe fails to compile with Decodable requirement
  - local/unit/static/OpenSpec validation passed
  - UIUE bounded grep shows D17 has not started
not_release_basis:
  - not Gate3 Hermes PASS
  - not Gate4 Hermes PASS
  - not runtime/mobile/true-device/live/V-PASS proof
```

## Non-Claims

- No production-ready claim.
- No runtime-ready claim.
- No mobile, true-device, live API, V-PASS, S-PASS, U-PASS, A-2, UIUE merge, voice-ready, model-ready, golden-ready, or endpoint-ready claim.
- No UIUE implementation has started in Gate4R.
