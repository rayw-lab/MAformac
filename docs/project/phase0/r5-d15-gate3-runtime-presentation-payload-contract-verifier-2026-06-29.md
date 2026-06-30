# R5 D15 Gate 3 - Runtime Presentation Payload Contract Verifier

Date: 2026-06-29
Gate: 3 of 4
Label: `D15_GATE_3_PAYLOAD_VERIFIER_BOUNDARY`
Candidate proof class before audit closure: `local_static` / `local_unit` / `OpenSpec` / refreshed `GitNexus`
Audit proof may add a CC substitute verifier only after explicit operator override and CC PASS with empty high/P0/P1 findings. This is not a Hermes PASS and does not upgrade proof class.
Scope: main verifier receipt, OpenSpec task status, clean-worktree verification, and UIUE read-only boundary guard

## Verdict

Final Gate 3 status: `DONE_WITH_OPERATOR_HERMES_OVERRIDE_AND_CC_SUBSTITUTE_PASS`.

Gate 3 verifies the committed Gate 1/Gate 2 D15 payload contract from a clean detached worktree at `ab9a6820a2b024900b603c17a54f36f02994cf41`. It confirms that the D15 main payload contract remains additive, sanitized, local/unit-proved, and not consumed by UIUE in this gate.

Gate 3 does not implement UIUE consumer integration, does not add payload fields in UIUE, and does not upgrade proof beyond local/static/local-unit/OpenSpec/GitNexus plus gate audits.

Operator override:
After Codex and Hermes both correctly flagged a claim-vs-proof mismatch in the first Gate 3 candidate, the operator explicitly superseded the remaining D15 Hermes requirement: "不需要安排hermes审计了后续，剩余gate就用subagentcc". Gate 3 therefore uses CC substitute hard audit for the repaired candidate. The earlier Hermes FAIL is retained as pitfall evidence, not as pass evidence.

## Dirty Split Before Gate 3 Writes

Main repo before Gate 3 writes:

```text
HEAD ab9a6820a2b024900b603c17a54f36f02994cf41
branch codex/rebuild-c6-doc-absorption-20260624
preserve-unowned dirty:
 M AGENTS.md
 M CLAUDE.md
 M docs/CURRENT.md
 M docs/README.md
?? .xcodebuildmcp/
?? Tools/agent-platform-plugin-refs/
cached: empty
```

UIUE repo before Gate 3 read-only guard:

```text
HEAD 3bab4c80ee8d360cb7ebdfcfcb8869d6ababb2d7
branch uiue/phase4-default-scope-presentation
untracked source artifacts:
?? docs/dispatches/2026-06-29-uiue-r5-d12-runtime-adapter-v0-code-train-dispatch.md
?? docs/dispatches/2026-06-29-uiue-r5-d13-c3-runtime-adapter-integration-dispatch.md
?? docs/dispatches/2026-06-29-uiue-r5-d14-runtime-adapter-residual-train-dispatch.md
?? docs/dispatches/2026-06-29-uiue-r5-d15-runtime-presentation-payload-contract-dispatch.md
?? docs/research/2026-06-29-visual-acceptance-standard/
cached: empty
```

## Clean Worktree Verifier

Verifier worktree:

```text
/tmp/maformac-d15-g3-verify
HEAD ab9a6820a2b024900b603c17a54f36f02994cf41
status: clean detached worktree
```

Gate 2 commit diff surface from the clean verifier worktree:

```text
M Core/Presentation/RuntimePresentationBridge.swift
M Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift
A docs/project/phase0/r5-d15-gate2-runtime-presentation-payload-contract-code-2026-06-29.md
M openspec/changes/define-runtime-presentation-bridge/tasks.md
```

Interpretation:
The committed Gate 2 payload code changes are limited to the intended Core Presentation contract file, focused test file, Gate 2 receipt, and task ledger. No UIUE path, dispatch source file, preserve-unowned file, or unrelated main code path appears in the Gate 2 commit diff.

## Forbidden-Field Verification

Command class:

```text
git diff HEAD~1 HEAD -- Core/Presentation/RuntimePresentationBridge.swift Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift
rg "DemoRuntimeAdapter|RuntimeAdapterBox|requestFingerprint|parentRequestFingerprint|failureLedger|successLedger|settledParentPlan|runtimeStore|rawModelOutput|trainingReceipt"
```

Result:
`PASS_WITH_NEGATIVE_CONTEXT`.

Interpretation:
The forbidden terms appear only in the sanitizer redaction token list and negative tests that inject private markers and assert the encoded `RuntimePresentationPayload` does not contain them. They are not exposed as payload field names, public DTO property names, UIUE shared fields, or stable consumer vocabulary.

## UIUE Read-Only Boundary Guard

Command class:

```text
rg -n "RuntimePresentationPayload|PresentationReconciliation|DemoRuntimeAdapter|RuntimeAdapterBox|requestFingerprint|parentRequestFingerprint|failureLedger|successLedger|settledParentPlan|runtimeStore|rawModelOutput|trainingReceipt|RuntimePresentationConsumer|Payload" \
  /Users/wanglei/workspace/MAformac-uiue/App \
  /Users/wanglei/workspace/MAformac-uiue/Tests \
  /Users/wanglei/workspace/MAformac-uiue/docs
```

Result:
`PASS_WITH_HISTORICAL_DOC_CONTEXT`.

Interpretation:

- Existing `RuntimePresentationConsumerMapping` Swift/tests in UIUE predate D15 and map stable mainline presentation names under local/unit proof cap; they are not D15 runtime payload consumer integration.
- D12/D13/D14/D15 dispatch and receipt documents contain forbidden adapter terms as negative guard vocabulary or historical evidence.
- No UIUE code was modified in Gate 3.
- No UIUE code consumes `RuntimePresentationPayload`, `PresentationReconciliation`, `DemoRuntimeAdapter*`, `RuntimeAdapterBox`, request fingerprints, ledger internals, raw store, raw model output, or training receipt as D15 shared fields.

Pitfall repair:
The first Gate 3 receipt under-scoped UIUE code grep to `App`, `Tests`, and `docs` while discussing `Core/Presentation/RuntimePresentationConsumerMapping.swift`. The repaired guard adds a full UIUE Swift-code grep:

```text
rg -n "RuntimePresentationPayload|PresentationReconciliation|DemoRuntimeAdapter|RuntimeAdapterBox|requestFingerprint|parentRequestFingerprint|failureLedger|successLedger|settledParentPlan|runtimeStore|rawModelOutput|trainingReceipt" \
  /Users/wanglei/workspace/MAformac-uiue \
  --glob '*.swift' \
  --glob '!docs/dispatches/**'
```

Result:
`PASS`, no matches in UIUE Swift code.

## GitNexus Verifier

GitNexus index refresh:

```text
node .gitnexus/run.cjs analyze
PASS
27,888 nodes | 49,213 edges | 993 clusters | 300 flows
/Users/wanglei/workspace/MAformac
```

GitNexus clean-worktree compare:

```text
detect_changes(scope=compare, base_ref=HEAD~1, worktree=/tmp/maformac-d15-g3-verify)
summary: changed_count=71, changed_files=4, affected_count=0, risk_level=low
affected_processes: []
```

Interpretation:
GitNexus sees the Gate 2 payload contract diff as low risk with no affected indexed execution process. This supports the narrow local/code-boundary claim only; it does not prove runtime/mobile/true-device/live readiness.

## Harness

Pre-mortem:
Gate 3 can fake green if it verifies the dirty main worktree instead of the committed Gate 2 diff, if it treats negative-test forbidden terms as leaks without context, if it overlooks a UIUE consumer created outside main, or if a low-risk GitNexus result is promoted into runtime proof.

Lesson learned / metacognitive reflection:
The verifier needs two separate lenses: committed main diff truth and UIUE boundary truth. A clean main worktree verifier prevents preserve-unowned dirty files from influencing the evidence, while UIUE read-only grep prevents D15 from quietly turning into D17.

Local repo cross-search:
Main `RuntimePresentationBridge.swift` contains the D15 payload and sanitizer implementation. Main `DemoRuntimeAdapter.swift` and `C3ExecutionPipeline.swift` remain private execution surfaces. UIUE `RuntimePresentationConsumerMapping.swift` is existing stable presentation mapping, not D15 payload parsing.

External method references:

- Google AIP-180 backward compatibility: `https://google.aip.dev/180`
- Google AIP-185 versioning: `https://google.aip.dev/185`
- OWASP Logging Cheat Sheet, data to exclude: `https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html`

These sources support compatibility and redaction discipline only. Repo OpenSpec and committed code remain authority.

Pitfall loop - premature audit completion claim:

| field | finding |
| --- | --- |
| visible symptom | `tasks.md` initially marked 9.7 complete while the Gate 3 receipt still listed Codex/Hermes audit evidence as pending. |
| underlying class | Checklist state can drift ahead of evidence when a candidate receipt is staged before hard-gate audit closure. |
| same-class risk map | Gate 4 proceeds from a candidate gate; final verdict inherits an audit-pending task as complete; proof class inflates from local verifier to hard-audited verifier. |
| immediate fix | Reverted 9.7 to pending, retained 9.6 because clean-worktree/GitNexus/UIUE verifier evidence is complete, and replaced Hermes requirement only after explicit operator override. |
| class-level fix | Do not mark an audit task complete until the receipt contains the final audit result and the candidate has been revalidated. |
| governance fix | CC substitute audit must inspect the repaired staged diff; any high/P0/P1 finding blocks Gate 3. |

Pitfall loop - controller closed running Codex verifiers:

| field | finding |
| --- | --- |
| visible symptom | Two Codex verifier agents were accidentally closed while running, producing no valid audit evidence. |
| underlying class | Misusing close as wait can silently destroy an in-flight hard-gate reviewer. |
| same-class risk map | A controller may count a shutdown as an audit, lose reviewer state, or proceed without independent evidence. |
| immediate fix | Discarded both shutdown agents as evidence, discovered and used `wait_agent`, and retained only completed verifier/CC output. |
| class-level fix | Treat `close_agent(previous_status=running)` as a controller pitfall, never as verifier result. |
| governance fix | Gate receipts must identify which audit outputs count and which were discarded. |

Pitfall loop - UIUE grep scope:

| field | finding |
| --- | --- |
| visible symptom | The first UIUE grep omitted the UIUE `Core` directory while interpreting existing `RuntimePresentationConsumerMapping` context. |
| underlying class | Boundary grep can under-cover a repo if it enumerates familiar folders instead of the full code surface. |
| same-class risk map | New UIUE consumer code under `Core`, `Sources`, package folders, or scripts could evade a narrow grep. |
| immediate fix | Added full UIUE Swift-code grep at repo root and recorded no matches for D15 payload/private adapter tokens. |
| class-level fix | Consumer-boundary guards should grep the whole code surface first, then classify docs/historical hits separately. |
| governance fix | Gate 4 reconcile must keep UIUE docs-only and must not introduce Swift consumer files. |

Iceberg teardown:

| field | finding |
| --- | --- |
| visible symptom | Gate 3 verifier needs to prove the D15 payload contract did not leak private runtime vocabulary or create UIUE consumption. |
| underlying class | Boundary verification can fail by mixing negative-evidence vocabulary with public contract vocabulary, or by using a dirty worktree as proof. |
| same-class risk map | private terms appear in docs and are mistaken for payload fields; UIUE old mapping is mistaken for D15 consumer; GitNexus stale/low result is over-claimed; local tests are promoted to runtime proof. |
| immediate fix | Verify the committed Gate 2 diff in a clean worktree, classify forbidden-term hits by context, grep UIUE read-only, refresh GitNexus, and keep proof class capped. |
| class-level fix | Future verifier gates should separate "negative guard term present" from "public payload field exposed" with explicit context notes. |
| governance fix | Gate 4 reconcile must preserve D17 as the consumer integration lane and must not stage source dispatch files or UIUE untracked research. |

Goal-drift check:
Gate 3 is verifier-only. It does not change Swift code, does not implement UIUE consumer integration, does not touch UIUE docs, and does not claim runtime/mobile/true-device/live proof.

Authority check:
Gate 1 commit `c2128633af5c80ccafad68c4217fa892b0b15897` defines the OpenSpec boundary; Gate 2 commit `ab9a6820a2b024900b603c17a54f36f02994cf41` implements the main local/unit contract. Gate 3 checks those commits rather than old prose.

Claim-vs-proof:
Gate 3 proves local/static, local/unit regression, OpenSpec validity, refreshed GitNexus low-risk compare, and UIUE read-only absence of D15 consumer integration. It does not prove production runtime execution, durable ledger, mobile, true-device, live API, UIUE merge, or D17 consumer readiness.

Boundary check:
The D15 payload still forbids exposing `DemoRuntimeAdapter*`, `RuntimeAdapterBox`, `requestFingerprint`, `parentRequestFingerprint`, `failureLedger`, success/failure ledger internals, settled parent-plan internals, raw runtime store, raw model output, training receipt, or adapter-local private names as stable payload fields.

Self-question:
If this verifier is wrong, one of these commands would prove it: `git diff HEAD~1 HEAD --name-status` in `/tmp/maformac-d15-g3-verify` would show extra paths; encoded payload tests would leak forbidden markers; UIUE `rg` would show new code consuming D15 payload fields; GitNexus compare would report unexpected high-risk affected processes.

Post-audit correction rule:
Any CC substitute high/P0/P1 finding, staged no-touch path, missing substitute audit output, or claim-vs-proof mismatch blocks Gate 3 under the operator override. Any P2/lower finding triggers a pitfall loop, local and web cross-search as needed, iceberg teardown, candidate repair, validation rerun, and audit rerun if content changes.

## Validation Evidence

```text
git diff --check HEAD~1 HEAD in clean verifier worktree: PASS
openspec validate define-runtime-presentation-bridge --strict: PASS
openspec validate --all --strict: PASS, 17 passed, 0 failed
swift test --filter 'RuntimePresentationBridgeTests|DemoRuntimeAdapterTests|C3ExecutionPipelineTests|VehicleStateStoreContractTests'
PASS, 51 tests, 0 failures
node .gitnexus/run.cjs analyze: PASS, 27,888 nodes / 49,213 edges / 993 clusters / 300 flows
GitNexus detect_changes compare from clean worktree: LOW, 4 files, 71 changed symbols, 0 affected processes
UIUE read-only grep: PASS_WITH_HISTORICAL_DOC_CONTEXT
```

## Gate 3 Substitute Audit Evidence

Operator override replaced Hermes with CC substitute hard audit for remaining D15 gates. This is not a Hermes PASS and does not upgrade proof class.

```text
CC substitute hard audit: PASS
findings_high_P0_P1: []
findings_P2_lower:
  - Validation Evidence is self-reported in the receipt; CC substitute audit role is structural/boundary verification only. Controller local validation output is recorded above.
  - Pending substitute audit evidence section needed bookkeeping update; this section is that update.
confidence: high
git diff --cached --check after repair: PASS
```

CC evidence summary:

- Staged surface exactly `{Gate3 receipt, openspec tasks.md}`.
- No source, UIUE, source dispatch, or preserve-unowned path staged.
- Candidate tasks 9.6/9.7 were pending during audit; final completion is recorded only after CC PASS and this bookkeeping update.
- Receipt contains clean-worktree verifier at `ab9a6820a2b024900b603c17a54f36f02994cf41`, full UIUE Swift grep repair with no matches, GitNexus LOW / 0 affected processes, proof cap, operator override, pitfall loops, and non-claims.
- No affirmative runtime-ready, mobile-proof, true-device, UIUE merge, D17 consumer integrated, or V/S/U-PASS claim appears in staged content.

## Non-Claims

- no R5 complete
- no runtime-ready
- no mobile proof
- no true_device proof
- no voice-ready
- no model-ready
- no golden-ready
- no endpoint-ready
- no production runtime proof
- no durable ledger proof
- no live API proof
- no UIUE merge
- no UIUE runtime consumer integrated
- no V-PASS / S-PASS / U-PASS
- no A-2 ready / complete
