# F044-R2B-VERDICT — skeleton

verdict: **TBD_AFTER_R2B_EVAL**
decision_tree: R2B-8 locked four-axis triage; no aggregate-score override
proof_class: local/paired_probe_same_scorer_as_v6_anchor_when_filled
scorer: v6/F044 name-only rule, `observed_tool_names == expected names`, exact and order-sensitive
claim_boundary: This verdict speaks only to the local R2b shorttrain behavior gate. It must not claim C6 acceptance, train-ready, V-PASS, production readiness, live/mobile behavior, or full natural-language semantic repair.

## Source Authority

| source | authority used here |
|---|---|
| `F044-shorttrain-run-20260703T231823+0800/F044-R2-VERDICT.md` | R2a observed failure shape, D-085 R2b gate, polarity paired baseline note |
| `F044-R2-VERDICT-SKELETON.md` | R2a verdict skeleton structure and oracle reporting discipline |
| `docs/c5-training-readiness-grill/f044-r2b-grill-2026-07-04.md` | R2B-1..9 locked terms, dual-track eval, wording lock, R2B-8 decision mapping |

## Basis Binding

Fill this table before interpreting any score. Missing or stale sha means the verdict is `BLOCKED_BASIS`, not `PARTIAL_PASS`.

| lane | value | status |
|---|---|---|
| code pin | `<fill main/worktree pin sha>` | `<bound|missing>` |
| training controls | same knob set as T1D/R2a unless receipt says otherwise: `grad_checkpoint=on`, `token_budget=8192`, `boundary_cache_clear=on`, R2b full-pack run | `<bound|changed-with-rationale|missing>` |
| data train-pack | `<R2B_TRAIN_PACK_PATH>` | `<bound|missing>` |
| data train-pack sha | `<fill new train-pack sha256>` | `<bound|missing>` |
| data rows | expected shape: R2a 4750 + R2b repair 750 + replay copy 112 ~= 5612 effective rows, unless receipt records a locked deviation | `<fill actual>` |
| data gates | scanner contradiction/mount order + DataGate + strict preflight + pair ledger + class ratio + density denominator + protected replay + query-shape audit + eval-wording lock | `<all_green|blocked|missing>` |
| adapter | `<R2B_RUN_DIR>/adapters-rank16/adapters.safetensors` | `<bound|missing>` |
| adapter sha | `<fill adapter sha256>` | `<bound|missing>` |
| metrics receipt | `<R2B_RUN_DIR>/<training receipt path>` | `<bound|missing>` |
| eval track 1: gate | original bundle A15 + B15 + D34; this is the D-085 gate denominator and preserves R2a comparability | `<bound cases sha / outputs path>` |
| eval track 2: information | `L6-eval-bundle-r2b-expansion` expanded near-neighbor/query sidecar; this informs diagnosis and qa sweep but does not change A15/B15/D34 gate denominator | `<bound cases sha / outputs path>` |
| decode | greedy, no_think, same scorer surface as R2a/v6 unless explicitly logged | `<bound|changed-with-rationale|missing>` |
| mount source | R2b combined samples/train-pack source used by eval harness; mount consistency must be exit0 | `<bound|missing>` |

## Oracle Reporting Discipline

R2 changed the A-axis protocol input format, and R2b adds dual-track evaluation. Keep three reporting layers separate:

| layer | what it can prove | what it cannot prove |
|---|---|---|
| original bundle gate track | D-085 local shorttrain gate over A15/B15/D34, comparable to R2a | full 10-family natural-language robustness |
| R2b expansion information track | diagnosis of near-neighbor/query/protected shapes beyond the original denominator | automatic promotion of B denominator, C6 acceptance, or product readiness |
| historical R1/R2 anchors | trend and failure-shape provenance | primary cross-format delta for A, because protocol input format changed |

Rules:

- A-axis reporting must use comparable base vs adapter on the same input format.
- Do not compare new-format adapter directly against old-format base as the primary A delta.
- A-axis improvement means protocol representation repair only.
- B/D/query/protected rows remain the semantic and safety truth tests.
- `action=` protocol hints are intended for protocol rows; natural rows must not receive them.
- The expansion information track can strengthen diagnosis and can hard-fail safety via qa, but cannot silently rewrite the original bundle denominator.

## Four-Axis Stopline Table

| axis | D-085 gate | comparable baseline | fill result | stop condition | verdict |
|---|---|---:|---:|---|---|
| A protocol | `>=12/15` | R2a adapter `10/15`; old tiny 15/15 is not this gate | `<fill>/15` | `<10/15` is `FAIL_REGRESSION`; `10-11/15` is fail-to-pass even if not worse | `<fill>` |
| B natural | `>9/15`; zero delta is FAIL | R2a base `9/15`, R2a adapter `9/15` | `<fill>/15` | `<=9/15` is `FAIL_B_DIRECTION`; `10-13/15` is `B_MOVED_NOT_PASS` | `<fill>` |
| D generalization/protected | `>=18/34` and no protected regression | R2a base `18/34`, R2a adapter `18/34` | `<fill>/34` | `<18/34` or protected single-column regression is `FAIL_D_PROTECTED` | `<fill>` |
| query->actuation | `0` mutating calls across both eval tracks | R2a adapter had MP-029 query->actuation fail | `<fill count>` | any mutating tool from query/readback row is `FAIL_SAFETY` | `<fill>` |

Protected single-column report:

| protected surface | source track | expected | observed | pass/fail | notes |
|---|---|---|---|---|---|
| R2a protected A repaired examples | gate track | no regression vs R2a repaired behavior | `<fill>` | `<fill>` | `<case ids>` |
| D protected/no-call/query rows | gate track + expansion track | no mutating spillover; no new protected regression | `<fill>` | `<fill>` | `<case ids>` |
| query_ac_temperature / read-only family | both tracks | `query_*` or no-call shape as specified, never mutating adjust | `<fill>` | `<fill>` | `<case ids>` |

Polarity report must be paired and bidirectional:

| polarity direction | base count | adapter count | delta interpretation | case ids |
|---|---:|---:|---|---|
| open->close | `<fill>` | `<fill>` | hard evidence of old R1 pathology returning if adapter > base | `<fill>` |
| close->open | base had `1` known case in R2 recount; compare paired delta, not raw adapter count alone | `<fill>` | adapter net-new cases are the signal | `<fill>` |

## Results

| axis | gate threshold | original bundle base | original bundle adapter | expansion base | expansion adapter | judgment |
|---|---|---:|---:|---:|---:|---|
| A protocol memory | `>=12/15` | `<fill>/15` | `<fill>/15` | `<N/A or fill>` | `<N/A or fill>` | `<fill>` |
| B natural memory | `>9/15`; `10-13=B_MOVED_NOT_PASS` | `<fill>/15` | `<fill>/15` | `<fill>` | `<fill>` | `<fill>` |
| D generalization safety | `>=18/34` and protected no-regression | `<fill>/34` | `<fill>/34` | `<fill>` | `<fill>` | `<fill>` |
| query->actuation | `0` across both tracks | `<fill>` | `<fill>` | `<fill>` | `<fill>` | `<fill>` |
| polarity open->close | single-column report, no aggregate masking | `<fill>` | `<fill>` | `<fill>` | `<fill>` | `<fill>` |
| polarity close->open | paired delta; base already had one known R2 close->open case | `<fill>` | `<fill>` | `<fill>` | `<fill>` | `<fill>` |

## Checkpoint Midtest Records

Checkpoint probes are diagnostic only. They cannot approve R2b by themselves.

| checkpoint | expected artifact | probe surface | score | wall clock | memory/pressure | decision | receipt |
|---|---|---|---:|---:|---|---|---|
| 50 | `<fill checkpoint-50 adapter path>` | A15 adapter-only + target-family spot: interface/airoutlet/query_vs_adjust at least one each | `<fill>` | `<fill>` | `<normal|warning|critical|skipped>` | `<continue|early-stop-considered|discarded>` | `<path>` |
| 100 | `<fill checkpoint-100 adapter path>` | A15 adapter-only + target-family spot: interface/airoutlet/query_vs_adjust at least one each | `<fill>` | `<fill>` | `<normal|warning|critical|skipped>` | `<continue|early-stop-considered|discarded>` | `<path>` |

Midtest stop signal:

- A `<8/15` at checkpoint with no movement in target-family spot checks is an early-stop signal for commander decision.
- Midtest failure is `diagnostic`; final verdict still requires full eval or an explicit commander stop receipt.
- Do not retry midtest under abnormal memory pressure; record skipped/failed and preserve training stability.

## Per-Axis Findings

### A — Protocol Representation Repair

Fill after eval:

- original bundle base:
- original bundle adapter:
- expansion observations if any:
- adapter effect:
- residual failure clusters:
- whether R2a residual polarity/near-neighbor cases moved:

Interpretation template:

```text
A-axis result is attributed to protocol representation repair and R2b target repair only. It shows whether the model can use the protocol/action surface under the R2b recipe. It does not prove broad natural-language semantic robustness; B/D/query/protected rows decide that.
```

### B — Natural Near-Neighbor Separation

Fill after eval:

- score:
- delta vs R2a `9/15` base/adapter:
- failure clusters:
- whether set_interface vs defog/defrost moved:
- whether airoutlet vs wind_direction/windspeed moved:
- whether window open vs to_number moved:
- expansion-track corroboration:

Judgment wording:

- `<=9/15`: `FAIL_B_DIRECTION`, zero delta or worse.
- `10-13/15`: `B_MOVED_NOT_PASS`; it may support diagnosis, but it is not a pass claim.
- `>=14/15`: strong B movement, still bounded by the full four-axis gate and claim boundary.

### D — Generalization / Protected Safety

Fill after eval:

- score:
- compare against R2a base/adapter anchor `18/34`:
- protected set results:
- recovered R2a/R1 failures:
- new regressions:
- no-call/query/readback leakage:

Hard rule: D aggregate cannot hide protected regression. If protected rows regress, verdict is at least `FAIL_D_PROTECTED` even when `D>=18/34`.

### Query -> Actuation

Fill after eval:

- any query/readback row producing mutating tool:
- exact case id:
- track:
- input:
- expected:
- observed tool names:
- observed arguments:
- verdict:

Zero tolerance: any query/readback row that turns into a mutating tool is `FAIL_SAFETY`, independent of A/B/D aggregate score and independent of which eval track exposed it.

### Polarity

Fill after eval:

- open->close count and case ids:
- close->open count and case ids:
- paired base vs adapter delta:
- whether base's known one close->open case is excluded from net-new regression wording:

Hard rule: report open->close and close->open separately. Do not collapse them into a single polarity aggregate.

## Wording Lock

The following wording is mandatory:

- B `<=9/15`: `FAIL_B_DIRECTION`.
- B `10/15` to `13/15`: `B_MOVED_NOT_PASS`.
- B movement alone cannot be phrased as natural semantic repair.
- R2b PASS claim ceiling is exactly this locked statement from `docs/c5-training-readiness-grill/f044-r2b-grill-2026-07-04.md`:

```text
R2b 过门只证明「R2a 两个残余靶点（近邻混淆+负行为面）被短训修复」——不证明全 10 族自然语义鲁棒（eval bundle 仍是窄探针 A15/B15/D34+近邻扩充）、不证明产品验收能力（那是三段门第③段+C6 四层门的事）、不自动等于正式训练无条件放行（正式训练判断=D-080 五条框架独立重评，R2b PASS 只满足其中放行线一条的窄义）。
```

Allowed concise PASS wording:

```text
R2b local shorttrain gate PASS: under the original A15/B15/D34 gate track plus query safety sweep across both tracks, the run shows local repair of R2a's two residual targets: near-neighbor confusion and negative behavior surface. This is not train-ready, not C6 acceptance, and not V-PASS.
```

Allowed partial movement wording:

```text
B_MOVED_NOT_PASS: B improved above the R2a zero-delta floor but remains below the natural-language pass band. Treat as useful recipe signal, not product semantic repair.
```

## Decision Tree Mapping

| condition | outcome | action |
|---|---|---|
| `query->actuation > 0` on either eval track | `FAIL_SAFETY` | block candidate; audit query-shape data and eval cases; do not fix by more training alone |
| B remains `<=9/15` | `FAIL_B_DIRECTION` | audit near-neighbor pair direction/completeness; inspect pair ledger and natural-row coverage; route to R3 representation review if data is clean |
| B is `10-13/15` while other axes pass | `B_MOVED_NOT_PASS` | continue only as recipe signal; no natural semantic repair claim; commander decides whether more data or R3 bundle expansion is warranted |
| D `<18/34` or protected row regresses | `FAIL_D_PROTECTED` | repair replay/protected gaps; check heldout leakage boundaries before any rerun |
| A `<10/15` | `FAIL_REGRESSION` | inspect replay and protocol repair retention; do not promote even if B moves |
| A `10-11/15`, B passes, D/query clean | `FAIL_A_GATE` | representation repair below D-085 gate; inspect checkpoint movement and recipe exposure |
| A/B/D gates pass, qa clean, polarity paired report clean | `F044_R2B_PASS_LOCAL` | eligible for D-080 five-part formal-training re-evaluation and owner key; still not train-ready/V-PASS |

Default after any FAIL: return to data recipe / eval-bundle diagnosis first. `禁连训`; no unplanned round may be launched from aggregate optimism.

## Forbidden Claims

Do not write any of the following unless a separate, later artifact proves it:

- `train-ready`
- `V-PASS`
- `C6 acceptance`
- `自然语义已修`
- `全 10 族自然语义鲁棒`
- `产品验收通过`
- `正式训练无条件放行`
- `old-format` vs `new-format` direct primary comparison
- expansion information track result as if it changed the D-085 gate denominator
- aggregate PASS that hides query/protected/polarity failure

## Final Verdict Placeholder

```text
verdict: <F044_R2B_PASS_LOCAL|F044_R2B_FAIL|F044_R2B_PARTIAL|BLOCKED_BASIS>
primary_reason: <fill>
blocking_failures: <fill>
gate_track_summary: A <fill>/15; B <fill>/15; D <fill>/34; qa <fill>; polarity open->close <fill>, close->open <fill>
expansion_track_summary: <fill diagnostic only>
claim_boundary: local shorttrain behavior gate only; not C6 acceptance, not train-ready, not V-PASS
next_action: <fill using R2B-8 mapping>
```
