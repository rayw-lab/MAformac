# UIUE D1-D5 Loop Competition Scorecard

> Source: `docs/grill-tournament/uiue-d1-d6-grill.md`
>
> Scope: D1-D5 only, 25 landed Q points. D6 is intentionally excluded because it is not grilled yet.
>
> Method: three scoring loops, each 0-10. Higher is better.
>
> - Round 1 `demo_value`: Does this visibly improve the 5-minute demo?
> - Round 2 `implementation_readiness`: Can it enter the ui-presentation skeleton without blocking on unresolved upstream work?
> - Round 3 `evidence_control`: Is the claim physically bounded by source, gate, fallback, or verification?
> - Final score = `0.4 * demo_value + 0.3 * implementation_readiness + 0.3 * evidence_control`.

## Round Notes

### Loop 1: Demo Value

Highest-value items are the ones a customer will directly perceive: iPhone standalone, focus transition, serialized multi-intent, boot reveal, FamilyCard consistency, and standalone smoke. Pure governance items score only when they prevent demo-visible failure.

### Loop 2: Implementation Readiness

Items depending on A2/C5/state-cells or true-device proof are penalized even when the design is directionally right. This drops `family_priority.json`, `voice_device_coverage.json`, `ui_value_type`, and iPhone full stack below their raw demo value.

### Loop 3: Evidence Control

Items with explicit gates, fallbacks, or source correction score high. Superseded claims are scored as rewrite/drop even if the replacement is strong elsewhere.

## 25-Point Score Table

| Rank | Point | Short name | R1 demo | R2 ready | R3 evidence | Final | Verdict |
|---:|---|---|---:|---:|---:|---:|---|
| 1 | D5.Q5.3 | opacityScale fallback + ripple ungate | 9 | 8 | 10 | 8.9 | promote first |
| 2 | D3.Q3.4 | FamilyCardLayout + snapshot consistency | 9 | 8 | 9 | 8.7 | promote first |
| 3 | D1.Q1.2 | MultiCallSequencer + max one highlight | 8 | 9 | 9 | 8.6 | promote first |
| 4 | D2.Q2.4 | one expansion + serialized multi-intent | 8 | 9 | 9 | 8.6 | promote first |
| 5 | D4.Q4.5 | iPhone is not minimal, standalone full demo | 9 | 7 | 10 | 8.6 | promote first |
| 6 | D5.Q5.1 | matchedGeometry fact correction + boundary | 8 | 8 | 10 | 8.6 | promote first |
| 7 | D1.Q1.1 | boot reveal happens-before voice | 9 | 8 | 8 | 8.4 | promote |
| 8 | D1.Q1.5 | D5 gate + one-shot ripple | 9 | 7 | 9 | 8.4 | promote |
| 9 | D4.Q4.4 | Mac/iPhone standalone smoke | 10 | 6 | 9 | 8.4 | promote with dependency |
| 10 | D2.Q2.1 | ExpandIntent single entry | 8 | 8 | 9 | 8.3 | promote |
| 11 | D5.Q5.4 | 320ms focus state machine | 8 | 8 | 9 | 8.3 | promote |
| 12 | D5.Q5.5 | gated matchedGeometry promotion criteria | 8 | 8 | 9 | 8.3 | promote |
| 13 | D4.Q4.1 | iPhone independent full-function screen | 10 | 5 | 9 | 8.2 | high value, blocked by iOS stack |
| 14 | D5.Q5.2 | Grid policy to avoid LazyVGrid conflict | 8 | 7 | 9 | 8.0 | promote |
| 15 | D4.Q4.3 | iPhone vertical full-function voice layout | 9 | 6 | 8 | 7.8 | promote after iOS baseline |
| 16 | D2.Q2.2 | blur discipline + ExpansionAnimation enum | 8 | 7 | 8 | 7.7 | promote |
| 17 | D3.Q3.1 | generated ui_value_type + exhaustive switch | 9 | 5 | 9 | 7.7 | blocked by state-cells expansion |
| 18 | D2.Q2.3 | family_priority.json from col O | 9 | 5 | 8 | 7.5 | high value, upstream-gated |
| 19 | D3.Q3.3 | GPUBudgetCoordinator + GPU budget | 8 | 6 | 8 | 7.4 | promote after smoke scope |
| 20 | D1.Q1.3 | idle breathe + showcase all families | 7 | 7 | 8 | 7.3 | useful, not first knife |
| 21 | D3.Q3.5 | AnyView performance spike + enum rationale | 6 | 8 | 9 | 7.3 | keep as guardrail |
| 22 | D4.Q4.2 | TransportKind none/bonjour | 7 | 6 | 9 | 7.3 | optional spike, not baseline |
| 23 | D2.Q2.5 | derived badge + voice_device_coverage | 8 | 5 | 8 | 7.1 | upstream-gated |
| 24 | D3.Q3.2 | component adoption matrix + RGB/seat spikes | 6 | 7 | 8 | 6.9 | keep, lower priority |
| 25 | D1.Q1.4 | old iPhone mirror transport | 1 | 1 | 9 | 3.4 | drop/rewrite; superseded by D4 |

## Final Tiers

### Tier S: Implement Skeleton First

- D5.Q5.3 opacityScale fallback + ripple ungate
- D3.Q3.4 FamilyCardLayout + snapshot consistency
- D1.Q1.2 MultiCallSequencer + max one highlight
- D2.Q2.4 one expansion + serialized multi-intent
- D4.Q4.5 iPhone standalone full demo decision
- D5.Q5.1 matchedGeometry fact correction

### Tier A: Promote Into ui-presentation With Clear Gates

- D1.Q1.1 boot reveal happens-before voice
- D1.Q1.5 D5 validation gate + one-shot ripple
- D4.Q4.4 standalone smoke
- D2.Q2.1 ExpandIntent single entry
- D5.Q5.4 focus state machine
- D5.Q5.5 gated matchedGeometry promotion
- D5.Q5.2 Grid policy

### Tier B: Keep, But Mark Upstream-Gated

- D4.Q4.1 iPhone independent full-function screen
- D4.Q4.3 iPhone vertical full-function voice layout
- D3.Q3.1 generated `ui_value_type`
- D2.Q2.3 `family_priority.json`
- D2.Q2.5 `voice_device_coverage`
- D3.Q3.3 GPU budget
- D4.Q4.2 optional Bonjour transport

### Tier C: Lower Priority Or Guardrail Only

- D1.Q1.3 idle breathe + showcase all families
- D3.Q3.5 AnyView spike guardrail
- D3.Q3.2 component adoption matrix + RGB/seat spikes

### Drop / Rewrite

- D1.Q1.4 old iPhone mirror transport. Keep only as historical superseded material. The live decision is D4: iPhone is standalone full-function; Bonjour is optional linkage.

## Competition Outcomes

1. The strongest immediate first knife is not the flashiest visual. It is the focus-transition fallback chain plus FamilyCard snapshot discipline. Without those, D1/D2 visual promises can drift silently.
2. D4 is strategically dominant but implementation-gated. Treat iPhone standalone as a product-level decision now, but do not let it block Mac-first UI skeleton work.
3. D2 and D3 have high architectural value but are mostly upstream-gated by `family_priority.json`, `voice_device_coverage.json`, and `ui_value_type`. Their docs should land now; implementation should wait for the data artifacts.
4. D1.Q1.4 must not leak into any new skeleton. Its historical text is explicitly superseded; any future `LocalDeviceLinkBridge` or shared-file iPhone mirror path should be treated as a regression.

## Required Back-Writes

- `grill-decisions-master.md`: mark D1.Q1.4 as dropped/superseded, not merely amended.
- `docs/design/INDEX.md`: point first implementation pass to Tier S and Tier A, not the whole D1-D5 surface.
- `ui-presentation` tasks: split Tier S/A into immediate skeleton tasks and Tier B into upstream-gated tasks.
- D4 decision crystal: state that iPhone standalone is a decision, while Bonjour linkage is optional and separately spiked.
