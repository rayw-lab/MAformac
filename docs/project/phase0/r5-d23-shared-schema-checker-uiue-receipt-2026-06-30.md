# R5 D23 Shared Public Fixture Schema Checker UIUE Receipt

Status: Gate2 UIUE local closure passed under proof cap. Gate-level Hermes/Claude Code audits were skipped by user override for D23; post-gate review is one Codex subagent xhigh audit, then GPT Pro after fixes/push.

## Scope

- UIUE adopts the main-owned public fixture schema artifact as a copied JSON artifact at `Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json`.
- UIUE manifest now references the copied main-owned schema artifact with sha256, owner path, consumer path, and update rule.
- UIUE fixture consumer tests validate schema-driven fixture count/names, allowed fixture classes/results/proof classes, public field set, forbidden top-level/card timestamps, private/durable/raw marker denial, local result mapping, and local sibling main parity when the sibling main repo is available.
- This remains UIUE-local JSON fixture consumer proof into `PresentationSnapshot`. It is not runtime-ready, mobile, true-device, live, UIUE merge, V/S/U-PASS, A-2, R5 complete, voice/model/golden, or endpoint readiness.

## Changed UIUE Paths

- `Tests/Fixtures/RuntimePresentationPayload/public_fixture_schema.v1.json`
- `Tests/Fixtures/RuntimePresentationPayload/manifest.json`
- `Tests/MAformacCoreTests/RuntimePresentationPayloadFixtureConsumerTests.swift`
- `openspec/changes/ui-presentation/tasks.md`
- `docs/project/phase0/r5-d23-shared-schema-checker-uiue-receipt-2026-06-30.md`
- `docs/roadmaps/2026-06-28-uiue-r5-dispatch-ready-decomposition-map.md`

## Gate Harness

| Gate | Verdict | Harness fields |
|---|---|---|
| Gate1 main shared schema/checker | consumed | using-superpowers ledger: process governance only; lessons learned: UIUE consumes copied main schema, not private Swift; pre-mortem: UIUE field invention, schema drift, proof escalation; local search: D22 UIUE consumer tests/receipt/route map; web search: not used, local repo/GitHub API only; iceberg: manifest equality alone was not enough, schema drift needed a named artifact; goal drift: no UIUE runtime/frontstage wiring; authority: D23 dispatch + D22 commander verdict + main schema artifact; claim-vs-proof: local/unit/static only; boundary: no durable/runtime/raw/private import; self-question: `diff -qr` or `RuntimePresentationPayloadFixtureConsumerTests` should fail on drift; post-advisory rule: later review findings are request_changes/fixed-after-review, not retroactive PASS. |
| Gate2 UIUE adoption/parity | local-pass | UIUE schema file hash matches manifest reference; fixture directory matches sibling main locally; schema allowed results map through `RuntimePresentationConsumerMapping.localResultKind`. |
| Gate3 PR remote truth | pending push at receipt creation | Existing PR #6 remote truth before D23 push: `1c66467ee7485ea08200624f7bd6843999905f12`, CLEAN, checks SUCCESS. |
| Gate4 doc cascade | local-pass | Receipt, route map, and OpenSpec task cascade record D23 proof cap and no-claim boundary. |

## Validation Snapshot

- `swift test --filter RuntimePresentationPayloadFixtureConsumerTests`: PASS, 11 tests.
- `diff -qr /Users/wanglei/workspace/MAformac/Tests/Fixtures/RuntimePresentationPayload /Users/wanglei/workspace/MAformac-uiue/Tests/Fixtures/RuntimePresentationPayload`: PASS, no output.
- GitNexus impact before edits: `RuntimePresentationPayloadFixtureConsumerTests` reported CRITICAL by import granularity, 0 affected processes; edits stayed in test/fixture/schema surfaces.

## Dirty Split

- `owned_by_D23`: changed paths listed above.
- `preserve_unowned_dirty`: `AGENTS.md`, `CLAUDE.md`.
- `source_dispatch_trace_artifact`: existing D12-D19 dispatch files; not staged.
- `preserve_research_no_touch`: `docs/research/2026-06-29-visual-acceptance-standard/`.

## Lessons Learned

- Cross-repo parity needs a named schema artifact and an executable parity check. A manifest alone can preserve fixture hashes while still letting checker rules diverge.
- UIUE may be stricter than main for local guard names, but the main-owned public schema remains the shared authority; UIUE stricter guard names are subset/superset checks, not shared-field inventions.
- Conditional sibling-repo parity is useful locally and should be paired with explicit `diff -qr` validation in receipts, because CI may not checkout both repos side by side.
