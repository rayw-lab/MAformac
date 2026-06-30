# R5 D23 Shared Public Fixture Schema Checker Main Receipt

Status: Gate1 main local closure passed under proof cap. Gate-level Hermes/Claude Code audits were skipped by user override for D23; post-gate review is one Codex subagent xhigh audit, then GPT Pro after fixes/push.

## Scope

- Main owns `Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json`.
- Main manifest now references that schema artifact with sha256, owner path, UIUE consumer path, and update rule.
- Main fixture tests validate the shared schema, fixture count/names, allowed fixture classes, proof class cap, public top-level fields, forbidden top-level/card timestamps, private/durable/raw marker denial, and typed result expressibility.
- This is local/unit/static fixture-contract proof only. It does not claim production runtime, runtime-ready status, mobile, true-device, live API, UIUE merge, V/S/U-PASS, A-2, R5 complete, voice/model/golden, or endpoint readiness.

## Changed Main Paths

- `Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json`
- `Tests/Fixtures/RuntimePresentationPayload/manifest.json`
- `Tests/MAformacCoreTests/RuntimePresentationPayloadPublicFixtureTests.swift`
- `openspec/changes/define-runtime-presentation-bridge/tasks.md`
- `docs/project/phase0/r5-d23-shared-schema-checker-main-receipt-2026-06-30.md`

## Gate Harness

| Gate | Verdict | Harness fields |
|---|---|---|
| Gate1 main shared schema/checker | local-pass | using-superpowers ledger: process governance only; lessons learned: schema authority must be a main artifact, not hidden Swift constants; pre-mortem: fixture/manifest drift, proof inflation, UIUE field invention; local search: D22 manifest/tests and bridge tasks; web search: not used, local repo/GitHub API only; iceberg: constants in tests were the surface symptom, missing portable schema was the class; goal drift: no fixture payload content changed; authority: D23 dispatch + D22 commander verdict + main bridge carrier; claim-vs-proof: local/unit/static only; boundary: no private Swift/durable/raw/runtime internals; self-question: `RuntimePresentationPayloadPublicFixtureTests` or schema sha mismatch should falsify the claim; post-advisory rule: any later review finding is request_changes/fixed-after-review, not retroactive PASS. |
| Gate2 UIUE adoption | main-side supporting evidence | Main artifact is copyable and digest-bound in manifest; UIUE owns consumer proof separately. |
| Gate3 PR remote truth | pending push at receipt creation | Existing PR #7 remote truth before D23 push: `3e716020eef958b3f18e90b2ab9df3f3b53bdc31`, CLEAN, checks SUCCESS. |
| Gate4 doc cascade | local-pass | This receipt and OpenSpec task cascade record D23 truth without staging source dispatch/D22 commander trace artifacts. |

## Validation Snapshot

- `swift test --filter RuntimePresentationPayloadPublicFixtureTests`: PASS, 8 tests.
- GitNexus impact before edits: `RuntimePresentationPayloadPublicFixtureTests` reported CRITICAL by import granularity, 0 affected processes; edits stayed in test/fixture/schema surfaces.

## Dirty Split

- `owned_by_D23`: changed paths listed above.
- `preserve_unowned_dirty`: `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`, `.xcodebuildmcp/`, `Tools/agent-platform-plugin-refs/`.
- `source_dispatch_trace_artifact`: D20/D21, D22, and D23 dispatch files under `docs/dispatches/`; not staged unless separately authorized.
- `trace_artifact_no_stage`: D22 commander verdict file.

## Lessons Learned

- A public schema/checker lane should be a portable artifact plus tests, not only hard-coded Swift constants.
- Schema result vocabulary should express the current fixture corpus subset and then prove that subset is typed by main, rather than widening the fixture contract to every possible runtime result.
- UIUE may maintain stricter local forbidden-marker guards, but those stricter UIUE guard names must not be pushed back into the main-owned public schema without main authority.
