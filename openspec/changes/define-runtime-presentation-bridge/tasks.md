## 1. Carrier validation

- [x] 1.1 Create the mainline-visible carrier under `openspec/changes/define-runtime-presentation-bridge/`.
- [x] 1.2 Record HR-01/HR-02/HR-03 in the carrier wording.
- [x] 1.3 Record C01/C03/C06/C18 as dispatch-readiness dispositions, not runtime/mobile proof.
- [x] 1.4 Keep this change contract-only; do not implement Swift.

## 2. Contract fields

- [x] 2.1 Define Runtime -> Presentation authority mapping and no-second-SSOT rule.
- [x] 2.2 Define runtime result vocabulary covering accepted tool calls, clarify/missing slot, unsupported refusal, safety/policy refusal, already-state no-op, runtime error, and cancelled/interrupted.
- [x] 2.3 Define presentation snapshot requirements for trace identity, cards, dialog/readbacks, scope origin, optional voice/orb display state, and finite proof class.
- [x] 2.4 Define `ScopeOrigin` disposition: no Core `missing`; missing/unresolved scope uses result/presentation metadata or explicit failure reason.
- [x] 2.5 Define proof-class display caps so docs/local proof cannot be upgraded by UI copy.

## 3. Document cascade

- [x] 3.1 Update `docs/CURRENT.md` so bridge state is no longer `not_proposed`.
- [x] 3.2 Update `docs/README.md` with the carrier and unblock receipt.
- [x] 3.3 Update/supersede `docs/project/phase0/uiue-r4-mainline-coauthor-receipt-2026-06-28.md` without claiming runtime proof.
- [x] 3.4 Create `docs/project/phase0/mainline-runtime-presentation-bridge-unblock-2026-06-28.md` with dirty ownership and validation receipt.

## 4. Red lines

- [x] 4.1 Do not edit `/Users/wanglei/workspace/MAformac-uiue`.
- [x] 4.2 Do not start UIUE R5 implementation.
- [x] 4.3 Do not claim runtime-ready, voice-ready, model-ready, golden-ready, endpoint-ready, mobile, true_device, V-PASS, S-PASS, U-PASS, or UIUE merge.

## 5. Validation

- [x] 5.1 Run `openspec validate define-runtime-presentation-bridge --strict`.
- [x] 5.2 Run `openspec validate --all --strict`.
- [x] 5.3 Run `git diff --check`.

## 6. Phase1 typed bridge contract

- [x] 6.1 Add `DemoInteractionEvent`, `DemoRuntimeResult`, `DemoRuntimeOutcome`, `PresentationSnapshot`, `TraceEnvelope`, and finite `PresentationProofClass` as mainline Core contract types.
- [x] 6.2 Preserve upstream `VehicleToolBehaviorClass.toolCall` while mapping it to bridge `accepted_tool_call`.
- [x] 6.3 Carry missing/unresolved scope through explicit reason metadata, not `ScopeOrigin.missing`.
- [x] 6.4 Add focused unit tests for behavior mapping, scope-missing disposition, proof-class fail-closed behavior, and snapshot codability.

## 7. Phase1 terminal snapshot adapter behavior proof

- [x] 7.1 Add a minimal terminal snapshot adapter/factory for guard-denial, thrown-error, partial accept/refuse, and stop outcomes.
- [x] 7.2 Prove guard denial maps to a terminal presentation-safe `refusal_safety_or_policy` snapshot without raw model/store/training fields.
- [x] 7.3 Prove thrown adapter/runtime failure maps to a terminal `runtime_error` snapshot with trace identity and safe reason.
- [x] 7.4 Prove partial accept/refuse carries accepted readbacks and mixed card state in a terminal snapshot.
- [x] 7.5 Prove cancel, interruption, timeout, and backgrounding all emit terminal snapshots.
- [x] 7.6 Run Codex native subagent P0/P1 audit and resolve or record findings.
- [x] 7.7 Run Hermes/GLM P0/P1 audit loop and resolve or record findings.

## 8. R5 Dispatch 2 mainline contract/test hardening

- [x] 8.1 Rewrite `C006` as: timeout is a terminal stop/result outcome, not a required interaction event kind; prove with unit test.
- [x] 8.2 Cover `C007` by separating event provenance/source from snapshot/readback/outcome scope metadata; prove with unit test.
- [x] 8.3 Cover `C024` by adding presentation-safe trace redaction for raw model output, training receipt, and raw runtime store markers; prove with unit test.
- [x] 8.4 Rewrite and cover `C029` as: refused/unsafe cards can outrank satisfied cards in deterministic presentation ordering; prove with unit test.
- [x] 8.5 Cover `C030` with machine-readable card semantics for role, active state, sibling keys, reason, and scope origin; prove with unit test.
- [x] 8.6 Cover `C143` with append-only trace envelope helper requiring matching trace identity and monotonic timestamps; prove with unit test.
- [x] 8.7 Rewrite `C052` as deferred: production force-state behavior is not created in this dispatch; future demo tooling owner must prove DEMO_MODE, trace provenance, and no production path.
- [x] 8.8 Rewrite `C061` as deferred: retry/idempotency no-double-write belongs to future runtime adapter execution tests, while bridge-level card/trace contracts remain local-unit only.
- [x] 8.9 Defer `C005` runtime write ownership to future runtime adapter wiring; current bridge surface remains snapshot/event contract-only.
- [x] 8.10 Defer `C018` SceneMacroRegistry/Core config ownership; mainline must own a future OpenSpec before UIUE treats it as shared runtime config.
- [x] 8.11 Run Codex native subagent P0/P1 audit and resolve or record findings.
- [x] 8.12 Run Hermes/GLM P0/P1 audit loop or user-authorized Codex equivalent after Hermes stall; resolve or record findings.

## 9. R5 D15 Runtime -> Presentation payload contract

- [x] 9.1 Gate 1: define main-owned payload/readback/reconciliation authority and forbidden adapter-private exposure in proposal, design, and spec.
- [x] 9.2 Gate 1: run local validation, Codex native subagent audit, and anchored Hermes audit.
- [x] 9.3 Gate 2: implement stable presentation-safe payload type or builder in main Core Presentation code.
- [x] 9.4 Gate 2: add focused local/unit tests for schema version, outcome, cards, readbacks, reconciliation status, proof cap, and forbidden private-field encoding.
- [x] 9.5 Gate 2: run GitNexus impact/detect, local validation, Codex native subagent audit, and anchored Hermes audit.
- [x] 9.6 Gate 3: verify committed Gate 1/2 diff from clean worktree, including forbidden-field search and UIUE read-only boundary guard.
- [x] 9.7 Gate 3: run GitNexus verifier, Codex native subagent audit, and anchored Hermes audit, or record an explicit operator override and substitute hard audit.
- [ ] 9.8 Gate 4: reconcile UIUE route map and burndown without implementing UIUE consumer integration.
- [ ] 9.9 Gate 4: run UIUE local validation, Codex native subagent audit, and anchored Hermes audit before exact-path docs commit.

## 10. R5 D20/D21 Public Fixture Contract

- [x] 10.1 Add deterministic presentation-safe public `RuntimePresentationPayload` fixture JSON set under `Tests/Fixtures/RuntimePresentationPayload/`.
- [x] 10.2 Record fixture sha256 entries in a manifest shared with the UIUE fixture copy.
- [x] 10.3 Prove main can generate the committed public fixture object from `RuntimePresentationPayload` while excluding non-public timestamp fields.
- [x] 10.4 Prove the public fixture set contains no adapter-private, durable-ledger, raw-runtime, raw-model, or training receipt markers.
- [x] 10.5 Preserve proof caps: fixture proof remains local/unit/static only and does not claim runtime-ready, mobile, true-device, live, UIUE merge, V/S/U-PASS, A-2, voice/model/golden/endpoint readiness, or R5 completion.
- [x] 10.6 Cover non-happy-path public payload boundaries for refusal safety, runtime error, reconciliation mismatch, and partial accept/refuse without adding private runtime fields.

## 11. R5 D22 Runtime Payload Corpus Expansion

- [x] 11.1 Add D22 manifest governance metadata for every public fixture entry: `caseID`, `fixtureClass`, `result`, `familyCoverage`, and `proofClass`.
- [x] 11.2 Preserve the existing 5 D20/D21 bridge-contract fixtures and classify them as `bridge_contract_fixture` without changing their JSON hashes.
- [x] 11.3 Add local runtime-generated public fixtures for `window.position`, `screen.brightness`, `ambient.brightness`, and `window.position` noop coverage.
- [x] 11.4 Assert generated fixtures match committed public JSON projection while stripping non-public timestamp volatility and preserving trace/readback semantics in tests.
- [x] 11.5 Keep the UIUE-facing contract presentation-safe: no adapter-private Swift types, durable ledger internals, raw runtime store, raw model output, training receipt, request fingerprint, or settled-plan internals.
- [x] 11.6 Preserve proof caps and fixture-class truth: `runtime_generated_fixture` is local/unit generator evidence, and `bridge_contract_fixture` is contract-boundary fixture evidence only.
- [x] 11.7 Fix first GPT Pro PR-pair P1 post-audit by adding public result `partial_accept_partial_refuse`, making the partial accept/refuse adapter emit it, and adding main public-vocabulary decoding coverage for all 9 fixtures.
- [x] 11.8 Record first GPT Pro audits as `REQUEST_CHANGES` fixed post-audit; user requested a post-fix GPT Pro rerun after push, without changing the first audit result into PASS.
