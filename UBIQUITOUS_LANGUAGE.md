# Ubiquitous Language

## Route gates and review

| Term | Definition | Aliases to avoid |
| --- | --- | --- |
| **R-L17 Deframing Gate** | A high-stakes governance gate that challenges the route frame before C5/C6 claims are promoted. | Same-vendor vote, model majority, normal audit |
| **Route Deframing Verdict** | A one-time human-signed route decision that may unlock `rebuild-c6` construction but not C6 acceptance or C5 training. | R-L17 pass, route pass, pre-pass |
| **Candidate Signoff Verdict** | A later human-signed quality decision required before C6 acceptance, C5 candidate promotion, golden-run, or readiness claims. | Route verdict, training approval, C6 pass |
| **Human Owner** | The accountable human reviewer who reads first-hand evidence and records the final high-stakes route or candidate decision. | Majority voter, final model judge |
| **Heterogeneous Judge** | A reviewer outside the Claude-family frame who performs an independent deframing audit. | More agents, same-vendor review, rubber-stamp judge |
| **Default Same-Vendor Self-Check** | A useful same-family or self-frame review that can find defects but does not count as heterogeneous signoff unless explicitly accepted by the human owner with an independent audit trace. | Cross-frame review, R-L17 proof |
| **Codex/OpenAI Independent Review** | A non-Claude-family review trace that may count as a second source only when the human owner explicitly accepts it and pairs it with an independent audit such as GLM. | Default pre-check, automatic R-L17 proof |
| **Consistent-PASS Signal** | A multi-reviewer agreement that no obvious objection was found, not a substitute for human-owner review. | Certification, approval, signoff |

## C6 and C5 sequencing

| Term | Definition | Aliases to avoid |
| --- | --- | --- |
| **Unlock Layer** | The pre-code layer that clears route governance and paper absorption before execution work starts. | Architecture mainline, implementation phase |
| **Trusted Acceptance Gate** | A C6 gate whose denominators, layers, evidence, and anti-fake-green checks are credible enough to judge later model work. | Aggregate pass rate, C6 acceptance by default |
| **Rebuild-C6 Mainline** | The first execution mainline that rebuilds the C6 bench as the trusted yardstick before retraining. | C6 acceptance run, model evaluation |
| **Retrain-C5 Mainline** | The later execution mainline that trains or prepares LoRA only after the C6 yardstick is credible. | Immediate training, data generation now |
| **Embedded Runtime Spine** | The minimum contract replay foundation needed inside rebuild-C6, such as target resolution and planned effects. | Standalone harden-spine, architecture-purity track |
| **Contract Replay Engine** | The C6 replay mechanism that produces inspectable planned effects, state deltas, scope evidence, and readback expectations. | Second runtime, final-state string matcher |
| **C6 Replay Fact Bundle** | The minimum replay evidence bundle for `rebuild-c6`: reuse existing scope resolution and apply evidence, then add only the missing diagnostics, no-effect reason, bundle fingerprint, and readback hard-pass boundary. | Standalone spine, full runtime engine, from-scratch replay |
| **Slim Target Resolution** | The existing `ScopeResolution` + `ScopeOrigin` + scoped key output used as the current target-resolution source for C6 replay evidence. | New target resolver, C6-inferred scope |
| **Stringly Scoped Key** | The existing `cellID[scope]` scoped-state-key representation emitted by `C2ScopeResolver.scopedKey()`. It is acceptable for the minimum C6 replay foundation unless concrete parser drift defects require a struct. | Missing scoped key, mandatory struct |
| **No-Effect Reason** | The reason a correct case causes no state mutation, sourced from the same behavior-class SSOT used by C5 data receipts, C6 denominators, and apply/execution no-effect reasoning. | Third no-call taxonomy, C6-only label, apply-local enum |
| **Apply Diagnostics** | Execution-layer diagnostics produced with state application evidence, extending `ToolContractStateApplyResult`; C6 consumes them instead of inventing apply semantics. | C6 diagnostics, scorer patch, second runtime |
| **Bounded Upstream Producer Subtask** | A narrow apply/execution-layer producer task carried by the rebuild-C6 carrier only to emit applied-write facts required by C6 replay. | C6-owned producer, standalone harden-spine, hidden implementation expansion |
| **Apply Producer** | The apply/execution code path that emits descriptive facts about actual state writes. | C6 scorer, replay engine, planner |
| **C6 Consumer** | The C6 replay code path that reads apply facts and derives scoring outputs without changing apply semantics. | Apply producer, second runtime |
| **Carrier Carve-Out** | An explicit OpenSpec exception that permits a bounded upstream task inside the current carrier without changing the ownership layer. | Scope creep, oral exception, implementation shortcut |
| **Applied Write** | A descriptive apply-layer record of one state write: state key, before value, after value, scope origin, and write kind. | Planned effect, expected mutation |
| **Write Kind** | The apply-layer source of an applied write: `direct` for target-cell writes and `dependency` for `depends_on` side effects. | Noop, behavior class, planner reason |
| **Unexpected Mutation Keys** | C6-derived replay comparison output: applied or final-state keys that are not allowed by the case's expected delta and dependency policy. | Apply-layer diagnostics, applier errors |
| **Behavior-Class Taxonomy** | The shared C5/C6/apply source for tool call, clarify, unsupported refusal, safety refusal, and already-state no-op classes. C5 uses it for observed data counts, C6 for denominators/selectors, and apply/execution no-effect reasoning consumes it instead of inventing a local enum. | C6-only no-effect enum, apply-local no-effect enum, negative bucket |
| **Contract Bundle Fingerprint** | A rebuild-C6 receipt manifest with a schema version, component digests, and a bundle hash over the contract inputs needed to interpret replay. | Model artifact digest, per-run prompt hash, output hash, second opaque contract hash |
| **Model Hard Pass** | The C6 model-quality hard-pass basis after plan P: tool-call/no-call, state delta, and clarify/refusal gates, excluding renderer readback. | Readback pass, endpoint readiness, demo pass |
| **Readback Renderer Evidence** | Deterministic C2 `renderReadback` evidence used for gold validity and renderer/release reporting, separate from model hard-pass. | Model text quality, judge score, optional evidence |
| **Readback Exclusion Marker** | A receipt field stating that readback is excluded from model hard-pass while still being recorded as renderer evidence. | Readback deletion, judge downgrade |
| **C6 Construction Lane** | The route-gated work that builds the trusted C6 yardstick: expected-tool migration, selectors, denominators, replay receipts, base-anchor design, and proof boundaries. | C6 acceptance run, candidate comparison |
| **Candidate Comparison Lane** | The later work that compares a signed C5 candidate against base using the completed C6 harness. | C6 construction, training authorization, whole-change prerequisite |

## Evidence and anti-bypass

| Term | Definition | Aliases to avoid |
| --- | --- | --- |
| **Historical Failure Evidence** | Prior failure evidence, such as base 10/23 or 0/34, used to understand risks without blocking on a new C6 rebuild. | Active gate, current candidate proof |
| **Feed-Forward Evidence** | Evidence that informs the next gate without depending on that next gate's completion. | Circular dependency, back-edge |
| **Bypass Guard** | A lightweight verification guard that prevents checked-off training or C6 acceptance tasks before the route verdict is signed. | Full schema, heavy governance, status enum |
| **Directed Implication** | A status or gate relation whose direction must not be inferred in reverse. | Symmetric dependency, mutual blocking |
| **Governance Signoff** | A manual decision record for route or candidate approval, distinct from runtime outcome status. | Runtime enum, C24 status, test result |
| **Documentation Absorption** | A docs-only OpenSpec/ledger update that carries route decisions into proposal/design/tasks/spec text without implementation or model execution. | Apply, implementation, C6 acceptance |
| **Local Static Teardown** | Static inspection evidence from papers/repos/code that can inform design but is not executed validation or model-quality proof. | Test pass, benchmark result, live eval |
| **Historical Base Anchor** | Prior generic-frame failure evidence used for context and comparison design, not an active D-domain threshold. | Current base gate, active threshold |
| **Future D-Domain Base Anchor Design** | Deferred semantics for a future authorized D-domain base rerun, not permission to run recalibration now. | Active D-domain base anchor, current anchor |

## Relationships

- A **Route Deframing Verdict** belongs to the **R-L17 Deframing Gate** and can unlock only `rebuild-c6` construction work.
- A **Candidate Signoff Verdict** belongs to the **R-L17 Deframing Gate** and is required before C6 acceptance, C5 candidate promotion, golden-run, or readiness claims.
- A **Heterogeneous Judge** complements the **Human Owner** but does not replace the **Human Owner**.
- A **Default Same-Vendor Self-Check** may inform a **Route Deframing Verdict**, but it cannot satisfy heterogeneous review by default.
- A **Codex/OpenAI Independent Review** can count as a second source only when the **Human Owner** explicitly accepts it with a separate audit trace; it is not automatic proof.
- **Historical Failure Evidence** can feed **Rebuild-C6 Mainline** design without making **Rebuild-C6 Mainline** a prerequisite of the route verdict.
- An **Embedded Runtime Spine** is part of **Rebuild-C6 Mainline**, not a standalone architecture track.
- A **C6 Replay Fact Bundle** reuses **Slim Target Resolution** and **Stringly Scoped Key** in the minimum foundation; it does not require a standalone **Contract Replay Engine** first.
- A **No-Effect Reason** must reuse the **Behavior-Class Taxonomy**; it must not become a third taxonomy beside C5 `data_class_observed_count`, C6 `C6Bucket` / selector denominators, and apply no-effect reasoning.
- **Apply Diagnostics** are produced by the apply/execution layer and consumed by **Rebuild-C6 Mainline**. They are not rebuild-C6 private scorer logic.
- A **Carrier Carve-Out** may carry a **Bounded Upstream Producer Subtask** without making C6 the **Apply Producer**.
- An **Apply Producer** emits facts. A **C6 Consumer** derives replay results from those facts.
- An **Applied Write** is descriptive evidence. **Unexpected Mutation Keys** are derived by C6 replay, because only C6 has the expected-state set.
- **Write Kind** labels the source of visible writes only. It cannot compensate for missing evidence; numeric direct, enum direct, and dependency writes must all emit **Applied Write** records.
- A **Contract Bundle Fingerprint** identifies the contract input set. It must preserve component digests and must not absorb per-run prompt/output hashes or model artifact digests.
- **Model Hard Pass** and **Readback Renderer Evidence** are separate axes. A **Readback Exclusion Marker** prevents readback renderer failure from being counted as model hard-pass failure, but it does not delete readback evidence or clarify/refusal text evidence.
- **C6 Construction Lane** precedes retraining and candidate comparison. **Candidate Comparison Lane** requires a completed yardstick and a signed candidate. A stale whole-change dependency declaration must not promote candidate availability into a construction prerequisite.
- **Documentation Absorption** can use **Local Static Teardown** as evidence, but it cannot promote teardown evidence into C6 acceptance or model-quality proof.
- **Historical Base Anchor** and **Future D-Domain Base Anchor Design** must stay distinct; neither is an active D-domain pass threshold without an authorized rerun.
- A **Bypass Guard** protects task progression, while **Governance Signoff** records human judgment.

## Example dialogue

> **Dev:** "Can we say R-L17 is passed once the models all agree?"
> **Domain expert:** "No. That is only a **Consistent-PASS Signal**. The **Human Owner** still needs first-hand evidence and a **Heterogeneous Judge**."
> **Dev:** "Does R5 block route deframing until the new C6 is rebuilt?"
> **Domain expert:** "No. R5 may use **Historical Failure Evidence** as **Feed-Forward Evidence**. The route verdict must not be blocked by rebuild-C6."
> **Dev:** "So what can the route verdict unlock?"
> **Domain expert:** "Only **Rebuild-C6 Mainline** construction. **Candidate Signoff Verdict** is still required before C6 acceptance or C5 retraining claims."
> **Dev:** "Should we add C24 statuses for these two verdicts?"
> **Domain expert:** "No. They are **Governance Signoff**, not runtime outcome status."
> **Dev:** "Can rebuild-C6 implement **Applied Write** production?"
> **Domain expert:** "Only through a **Carrier Carve-Out** for a **Bounded Upstream Producer Subtask**. The code remains the **Apply Producer** in apply/execution, and C6 remains the **C6 Consumer**."

## Flagged ambiguities

- "过 R-L17" was ambiguous between **Route Deframing Verdict** and **Candidate Signoff Verdict**. Use the explicit term every time.
- "rebuild-c6" was ambiguous between building the C6 gate and running C6 acceptance. Use **Rebuild-C6 Mainline** for construction and "C6 acceptance" only for authorized evaluation.
- "harden spine" was ambiguous between a standalone architecture track and C6 replay foundation. Use **Embedded Runtime Spine** for the latter and avoid standalone "harden-spine" unless a new route explicitly accepts it.
- "replay foundation" was ambiguous between a full runtime engine and **C6 Replay Fact Bundle**. Use the latter when discussing the minimum pre-code `rebuild-c6` foundation.
- "ScopedStateKey" was ambiguous between mandatory new struct and current **Stringly Scoped Key**. Use **Stringly Scoped Key** for the existing `cellID[scope]` representation; reserve struct promotion for optional hardening.
- "StateApplyDiagnostics" was ambiguous between C6-owned evidence and apply-layer evidence. Use **Apply Diagnostics** for the latter; rebuild-C6 consumes it.
- "unexpected mutations" was ambiguous between apply-layer fact and C6 replay comparison. Use **Unexpected Mutation Keys** for the C6-derived comparison result.
- "write kind" was ambiguous between source tagging and semantic classification. Use **Write Kind** only for `direct` or `dependency`; never for `noop`.
- "no effect" was ambiguous between a C6-specific no-call bucket, an apply-local enum, and shared behavior classification. Use **No-Effect Reason** only when it is backed by the **Behavior-Class Taxonomy**.
- "contract fingerprint" was ambiguous between a contract input manifest and run/model identity. Use **Contract Bundle Fingerprint** only for the former; keep prompt/output/model artifact digests as per-run identity fields.
- "readback excluded" was ambiguous between removing readback and excluding it from model hard-pass. Use **Readback Exclusion Marker** only for the latter.
- "hard pass" was ambiguous between model quality and renderer/readback validity. Use **Model Hard Pass** for the model-quality basis and **Readback Renderer Evidence** for C2-rendered readback validity.
- "rebuild-c6" was ambiguous between building the yardstick and comparing a LoRA candidate. Use **C6 Construction Lane** for the former and **Candidate Comparison Lane** for the latter.
- "teardown" was ambiguous between static evidence and executed validation. Use **Local Static Teardown** only for static inspection evidence.
- "base anchor" was ambiguous between old failure evidence and a future active threshold. Use **Historical Base Anchor** or **Future D-Domain Base Anchor Design** explicitly.
- "审计" was ambiguous between **Default Same-Vendor Self-Check**, **Codex/OpenAI Independent Review**, **Heterogeneous Judge**, and **Human Owner** review. Name the review lane.
- "status" was ambiguous between runtime outcome status and manual governance verdict. Use **Governance Signoff** for R-L17 route/candidate decisions.
- "own producer" was ambiguous between OpenSpec carrier coordination and C6 runtime ownership. Use **Carrier Carve-Out** for the former and reserve **Apply Producer** for apply/execution code.
- "upstream subtask" was ambiguous until Q5.1. Use **Bounded Upstream Producer Subtask** only for `appliedWrites`; any broader apply policy or planner work needs a new accepted carrier.
