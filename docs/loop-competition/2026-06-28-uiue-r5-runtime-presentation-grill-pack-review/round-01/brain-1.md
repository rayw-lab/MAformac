# Brain 1 - Round 01 - RED Failure Auditor

## Scope And Blindness
- Files read:
  - `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/round-01/brain-1-prompt.md`
  - `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/contract.md`
  - `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/candidates-blind.md`
  - `/Users/wanglei/workspace/MAformac-uiue/AGENTS.md`
  - `/Users/wanglei/workspace/MAformac-uiue/CLAUDE.md`
  - `/Users/wanglei/workspace/MAformac-uiue/docs/CURRENT.md`
  - `/Users/wanglei/workspace/MAformac-uiue/docs/README.md`
  - `/Users/wanglei/workspace/MAformac-uiue/docs/handoffs/2026-06-28-uiue-r5-readiness-from-r4-closeout.md`
  - `/Users/wanglei/workspace/MAformac-uiue/docs/handoffs/uiue-r5-readiness-after-mainline-bridge-2026-06-28.md`
  - `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/PresentationSnapshot.swift`
  - `/Users/wanglei/workspace/MAformac-uiue/Core/Presentation/DemoRuntimeResultPresentationMatrix.swift`
  - `/Users/wanglei/workspace/MAformac/Core/Presentation/RuntimePresentationBridge.swift`
  - `/Users/wanglei/workspace/MAformac/Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift`
  - `/Users/wanglei/workspace/MAformac/openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md`
- Forbidden files not read: original grill pack, candidate-map-private, other reviewer files, judge files, ledger.
- Proof class: docs/local + subagent_readonly + controller_judge; no runtime/mobile/true_device/voice/model/golden/endpoint/V-PASS claim.

## Executive Verdict
- status: PASS_WITH_NOTES
- strongest keep clusters: proof-class/non-claim gates; mainline carrier and snapshot authority; terminal snapshot/fail-closed behavior; dirty-scope/receipt separation; voice/golden/model lane isolation.
- weakest/rewrite clusters: vague visual/UX taste rows without owner or command; duplicate event/snapshot micro-rows; future C5/C6/model rows that must not block R5 dispatch.
- merge/drop candidates: no hard drops; many duplicate rows should merge into canonical clusters instead of expanding burndown count.
- missing risks: downgrade wording when proof is absent, stale async mutation after cancellation, unknown proof enum fail-closed in every consumer, and UIUE-to-mainline field-name freeze before Swift implementation.

## Scores
| Candidate | Importance | Verifiability | NonDuplication | DecisionLeverage | RiskRevelation | Total | Verdict | Short reason |
|---|---:|---:|---:|---:|---:|---:|---|---|
| C001 | 4 | 4 | 5 | 5 | 4 | 22 | Keep | Keep as authority-bound contract question with direct verification path. |
| C002 | 4 | 4 | 5 | 5 | 4 | 22 | Keep | Keep as authority-bound contract question with direct verification path. |
| C003 | 4 | 4 | 5 | 5 | 4 | 22 | Keep | Keep as authority-bound contract question with direct verification path. |
| C004 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C005 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C006 | 5 | 4 | 3 | 3 | 5 | 20 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C007 | 4 | 4 | 3 | 3 | 4 | 18 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C008 | 4 | 4 | 5 | 5 | 4 | 22 | Keep | Keep; materially narrows an R5 false-green or ownership boundary. |
| C009 | 4 | 4 | 5 | 5 | 4 | 22 | Keep | Keep; materially narrows an R5 false-green or ownership boundary. |
| C010 | 5 | 4 | 5 | 5 | 5 | 24 | Keep | Keep; materially narrows an R5 false-green or ownership boundary. |
| C011 | 3 | 3 | 3 | 3 | 3 | 15 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C012 | 5 | 4 | 5 | 5 | 5 | 24 | Keep | Keep as authority-bound contract question with direct verification path. |
| C013 | 5 | 4 | 5 | 5 | 5 | 24 | Keep | Keep; materially narrows an R5 false-green or ownership boundary. |
| C014 | 3 | 3 | 5 | 5 | 3 | 19 | Keep | Keep; materially narrows an R5 false-green or ownership boundary. |
| C015 | 3 | 3 | 5 | 5 | 3 | 19 | Keep | Keep; materially narrows an R5 false-green or ownership boundary. |
| C016 | 3 | 3 | 3 | 3 | 3 | 15 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C017 | 4 | 4 | 5 | 5 | 4 | 22 | Keep | Keep as authority-bound contract question with direct verification path. |
| C018 | 3 | 3 | 5 | 5 | 3 | 19 | Keep | Keep; materially narrows an R5 false-green or ownership boundary. |
| C019 | 3 | 3 | 5 | 5 | 3 | 19 | Keep | Keep; materially narrows an R5 false-green or ownership boundary. |
| C020 | 4 | 3 | 5 | 5 | 4 | 21 | Keep | Keep; materially narrows an R5 false-green or ownership boundary. |
| C021 | 3 | 3 | 3 | 3 | 3 | 15 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C022 | 5 | 4 | 5 | 5 | 5 | 24 | Keep | RED anchor: forces terminal-state evidence, avoids silent/stale green. |
| C023 | 5 | 5 | 5 | 5 | 5 | 25 | Keep | RED anchor: prevents proof-class inflation and fake readiness. |
| C024 | 4 | 4 | 3 | 3 | 4 | 18 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C025 | 5 | 5 | 5 | 5 | 5 | 25 | Keep | RED anchor: prevents proof-class inflation and fake readiness. |
| C026 | 4 | 3 | 4 | 3 | 4 | 18 | DeferFutureLane | Valid risk, but belongs to later lane and must not block R5 dispatch scope. |
| C027 | 3 | 3 | 5 | 5 | 3 | 19 | Keep | Keep; materially narrows an R5 false-green or ownership boundary. |
| C028 | 3 | 3 | 5 | 5 | 3 | 19 | Keep | Keep; materially narrows an R5 false-green or ownership boundary. |
| C029 | 3 | 3 | 3 | 3 | 3 | 15 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C030 | 4 | 4 | 3 | 3 | 4 | 18 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C031 | 3 | 3 | 3 | 3 | 3 | 15 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C032 | 4 | 4 | 3 | 3 | 4 | 18 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C033 | 3 | 3 | 3 | 3 | 3 | 15 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C034 | 3 | 3 | 3 | 3 | 3 | 15 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C035 | 4 | 4 | 3 | 3 | 4 | 18 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C036 | 5 | 4 | 5 | 5 | 5 | 24 | Keep | RED anchor: prevents proof-class inflation and fake readiness. |
| C037 | 3 | 3 | 5 | 5 | 3 | 19 | Keep | Keep; materially narrows an R5 false-green or ownership boundary. |
| C038 | 3 | 3 | 3 | 3 | 3 | 15 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C039 | 3 | 3 | 5 | 5 | 3 | 19 | Keep | Keep; materially narrows an R5 false-green or ownership boundary. |
| C040 | 3 | 3 | 3 | 3 | 3 | 15 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C041 | 5 | 5 | 4 | 3 | 5 | 22 | DeferFutureLane | Valid risk, but belongs to later lane and must not block R5 dispatch scope. |
| C042 | 4 | 4 | 4 | 3 | 4 | 19 | DeferFutureLane | Valid risk, but belongs to later lane and must not block R5 dispatch scope. |
| C043 | 3 | 3 | 3 | 3 | 3 | 15 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C044 | 3 | 3 | 3 | 3 | 3 | 15 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C045 | 5 | 5 | 3 | 3 | 5 | 21 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C046 | 5 | 5 | 3 | 3 | 5 | 21 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C047 | 3 | 3 | 3 | 3 | 3 | 15 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C048 | 5 | 5 | 3 | 3 | 5 | 21 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C049 | 5 | 4 | 3 | 3 | 5 | 20 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C050 | 5 | 5 | 3 | 3 | 5 | 21 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C051 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C052 | 4 | 4 | 3 | 3 | 4 | 18 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C053 | 5 | 4 | 3 | 3 | 5 | 20 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C054 | 3 | 3 | 2 | 3 | 3 | 14 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C055 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C056 | 4 | 4 | 3 | 3 | 4 | 18 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C057 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C058 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C059 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C060 | 5 | 4 | 5 | 5 | 5 | 24 | Keep | RED anchor: forces terminal-state evidence, avoids silent/stale green. |
| C061 | 5 | 4 | 3 | 3 | 5 | 20 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C062 | 4 | 4 | 3 | 3 | 4 | 18 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C063 | 3 | 3 | 3 | 3 | 3 | 15 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C064 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C065 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C066 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C067 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C068 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C069 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C070 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C071 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C072 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C073 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C074 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C075 | 3 | 3 | 2 | 3 | 3 | 14 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C076 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C077 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C078 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C079 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C080 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C081 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C082 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C083 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C084 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C085 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C086 | 3 | 3 | 2 | 3 | 3 | 14 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C087 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C088 | 4 | 3 | 2 | 3 | 4 | 16 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C089 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C090 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C091 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C092 | 3 | 3 | 3 | 3 | 3 | 15 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C093 | 3 | 3 | 3 | 3 | 3 | 15 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C094 | 4 | 3 | 2 | 3 | 4 | 16 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C095 | 3 | 3 | 2 | 3 | 3 | 14 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C096 | 3 | 3 | 4 | 4 | 3 | 17 | Spike | Needs bounded spike before it can become an implementation gate. |
| C097 | 5 | 5 | 2 | 3 | 5 | 20 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C098 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C099 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C100 | 5 | 5 | 2 | 3 | 5 | 20 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C101 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C102 | 3 | 3 | 3 | 3 | 3 | 15 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C103 | 5 | 5 | 2 | 3 | 5 | 20 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C104 | 4 | 4 | 5 | 5 | 4 | 22 | Keep | Keep as authority-bound contract question with direct verification path. |
| C105 | 5 | 5 | 2 | 3 | 5 | 20 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C106 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C107 | 5 | 5 | 2 | 3 | 5 | 20 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C108 | 5 | 5 | 2 | 3 | 5 | 20 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C109 | 3 | 3 | 3 | 3 | 3 | 15 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C110 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C111 | 5 | 5 | 2 | 3 | 5 | 20 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C112 | 4 | 3 | 2 | 3 | 4 | 16 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C113 | 3 | 3 | 2 | 3 | 3 | 14 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C114 | 4 | 3 | 2 | 3 | 4 | 16 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C115 | 3 | 3 | 2 | 3 | 3 | 14 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C116 | 4 | 3 | 2 | 3 | 4 | 16 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C117 | 4 | 3 | 4 | 4 | 4 | 19 | Spike | Needs bounded spike before it can become an implementation gate. |
| C118 | 4 | 3 | 2 | 3 | 4 | 16 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C119 | 3 | 3 | 2 | 3 | 3 | 14 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C120 | 4 | 3 | 5 | 5 | 4 | 21 | Keep | Keep; materially narrows an R5 false-green or ownership boundary. |
| C121 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C122 | 4 | 3 | 2 | 3 | 4 | 16 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C123 | 5 | 5 | 4 | 3 | 5 | 22 | DeferFutureLane | Valid risk, but belongs to later lane and must not block R5 dispatch scope. |
| C124 | 4 | 3 | 4 | 3 | 4 | 18 | DeferFutureLane | Valid risk, but belongs to later lane and must not block R5 dispatch scope. |
| C125 | 4 | 3 | 2 | 3 | 4 | 16 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C126 | 3 | 3 | 4 | 3 | 3 | 16 | DeferFutureLane | Valid risk, but belongs to later lane and must not block R5 dispatch scope. |
| C127 | 3 | 3 | 4 | 3 | 3 | 16 | DeferFutureLane | Valid risk, but belongs to later lane and must not block R5 dispatch scope. |
| C128 | 3 | 3 | 2 | 3 | 3 | 14 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C129 | 5 | 5 | 2 | 3 | 5 | 20 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C130 | 3 | 3 | 2 | 3 | 3 | 14 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C131 | 5 | 4 | 3 | 3 | 5 | 20 | Rewrite | Right risk, but needs sharper owner/proof gate or less ambiguous wording. |
| C132 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C133 | 5 | 5 | 2 | 3 | 5 | 20 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C134 | 3 | 3 | 2 | 3 | 3 | 14 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C135 | 3 | 3 | 4 | 3 | 3 | 16 | DeferHuman | Human/product taste lane; keep out of technical readiness gates. |
| C136 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C137 | 3 | 3 | 2 | 3 | 3 | 14 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C138 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C139 | 3 | 3 | 2 | 3 | 3 | 14 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C140 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C141 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C142 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C143 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C144 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C145 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C146 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C147 | 4 | 3 | 2 | 3 | 4 | 16 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C148 | 4 | 3 | 2 | 3 | 4 | 16 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C149 | 3 | 3 | 2 | 3 | 3 | 14 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C150 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C151 | 3 | 3 | 2 | 3 | 3 | 14 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C152 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C153 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C154 | 5 | 5 | 2 | 3 | 5 | 20 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C155 | 3 | 3 | 2 | 3 | 3 | 14 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C156 | 5 | 5 | 2 | 3 | 5 | 20 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C157 | 3 | 3 | 2 | 3 | 3 | 14 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C158 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C159 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C160 | 5 | 5 | 2 | 3 | 5 | 20 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C161 | 3 | 3 | 2 | 3 | 3 | 14 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C162 | 3 | 3 | 2 | 3 | 3 | 14 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C163 | 3 | 3 | 2 | 3 | 3 | 14 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C164 | 3 | 3 | 2 | 3 | 3 | 14 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C165 | 5 | 5 | 2 | 3 | 5 | 20 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C166 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C167 | 5 | 5 | 2 | 3 | 5 | 20 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C168 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C169 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C170 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C171 | 5 | 5 | 5 | 5 | 5 | 25 | Keep | RED anchor: prevents proof-class inflation and fake readiness. |
| C172 | 3 | 3 | 2 | 3 | 3 | 14 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C173 | 5 | 5 | 2 | 3 | 5 | 20 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C174 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C175 | 4 | 3 | 2 | 3 | 4 | 16 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C176 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C177 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C178 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C179 | 5 | 5 | 2 | 3 | 5 | 20 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C180 | 3 | 3 | 2 | 3 | 3 | 14 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C181 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C182 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C183 | 3 | 3 | 2 | 3 | 3 | 14 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C184 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C185 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C186 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C187 | 5 | 5 | 2 | 3 | 5 | 20 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C188 | 3 | 3 | 2 | 3 | 3 | 14 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C189 | 5 | 5 | 5 | 5 | 5 | 25 | Keep | RED anchor: prevents proof-class inflation and fake readiness. |
| C190 | 4 | 4 | 4 | 3 | 4 | 19 | DeferFutureLane | Valid risk, but belongs to later lane and must not block R5 dispatch scope. |
| C191 | 4 | 3 | 4 | 3 | 4 | 18 | DeferFutureLane | Valid risk, but belongs to later lane and must not block R5 dispatch scope. |
| C192 | 3 | 3 | 2 | 3 | 3 | 14 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C193 | 5 | 5 | 2 | 3 | 5 | 20 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C194 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C195 | 5 | 4 | 5 | 5 | 5 | 24 | Keep | Keep as authority-bound contract question with direct verification path. |
| C196 | 5 | 5 | 2 | 3 | 5 | 20 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C197 | 5 | 4 | 4 | 4 | 5 | 22 | Spike | Needs bounded spike before it can become an implementation gate. |
| C198 | 4 | 3 | 5 | 5 | 4 | 21 | Keep | Keep; materially narrows an R5 false-green or ownership boundary. |
| C199 | 4 | 4 | 5 | 5 | 4 | 22 | Keep | Keep; materially narrows an R5 false-green or ownership boundary. |
| C200 | 4 | 3 | 2 | 3 | 4 | 16 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C201 | 4 | 4 | 2 | 3 | 4 | 17 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C202 | 4 | 3 | 4 | 3 | 4 | 18 | DeferFutureLane | Valid risk, but belongs to later lane and must not block R5 dispatch scope. |
| C203 | 4 | 3 | 2 | 3 | 4 | 16 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C204 | 4 | 3 | 5 | 5 | 4 | 21 | Keep | Keep; materially narrows an R5 false-green or ownership boundary. |
| C205 | 5 | 5 | 5 | 5 | 5 | 25 | Keep | Keep; materially narrows an R5 false-green or ownership boundary. |
| C206 | 4 | 3 | 2 | 3 | 4 | 16 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C207 | 5 | 4 | 4 | 4 | 5 | 22 | Spike | Needs bounded spike before it can become an implementation gate. |
| C208 | 5 | 5 | 4 | 4 | 5 | 23 | Spike | Needs bounded spike before it can become an implementation gate. |
| C209 | 4 | 3 | 4 | 3 | 4 | 18 | DeferFutureLane | Valid risk, but belongs to later lane and must not block R5 dispatch scope. |
| C210 | 4 | 3 | 2 | 3 | 4 | 16 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C211 | 4 | 3 | 2 | 3 | 4 | 16 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C212 | 4 | 3 | 4 | 3 | 4 | 18 | DeferFutureLane | Valid risk, but belongs to later lane and must not block R5 dispatch scope. |
| C213 | 5 | 5 | 5 | 5 | 5 | 25 | Keep | RED anchor: prevents proof-class inflation and fake readiness. |
| C214 | 5 | 4 | 2 | 3 | 5 | 19 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |
| C215 | 4 | 3 | 2 | 3 | 4 | 16 | Merge | Valid but overlaps a stronger sibling; merge into cluster to avoid score noise. |

## Candidate Notes
| Candidate | Action | Route | Note |
|---|---|---|---|
| C001 | keep | mainline_first | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C002 | keep | mainline_first | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C003 | keep | mainline_first | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C004 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C005 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C006 | Rewrite | uiue_first_main_after | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C007 | Rewrite | parallel_with_guard | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C008 | keep | parallel_with_guard | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C009 | keep | mainline_first | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C010 | keep | parallel_with_guard | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C011 | Rewrite | uiue_first_main_after | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C012 | keep | mainline_first | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C013 | keep | parallel_with_guard | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C014 | keep | uiue_first_main_after | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C015 | keep | parallel_with_guard | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C016 | Rewrite | parallel_with_guard | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C017 | keep | mainline_first | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C018 | keep | mainline_first | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C019 | keep | parallel_with_guard | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C020 | keep | parallel_with_guard | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C021 | Rewrite | parallel_with_guard | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C022 | keep | mainline_first | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C023 | keep | parallel_with_guard | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C024 | Rewrite | mainline_first | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C025 | keep | parallel_with_guard | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C026 | DeferFutureLane | future_lane | Future-lane risk; record non-claim checkbox now, verify in its own lane later. |
| C027 | keep | uiue_first_main_after | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C028 | keep | parallel_with_guard | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C029 | Rewrite | parallel_with_guard | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C030 | Rewrite | mainline_first | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C031 | Rewrite | parallel_with_guard | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C032 | Rewrite | parallel_with_guard | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C033 | Rewrite | uiue_first_main_after | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C034 | Rewrite | uiue_first_main_after | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C035 | Rewrite | mainline_first | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C036 | keep | parallel_with_guard | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C037 | keep | parallel_with_guard | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C038 | Rewrite | parallel_with_guard | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C039 | keep | parallel_with_guard | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C040 | Rewrite | parallel_with_guard | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C041 | DeferFutureLane | future_lane | Future-lane risk; record non-claim checkbox now, verify in its own lane later. |
| C042 | DeferFutureLane | future_lane | Future-lane risk; record non-claim checkbox now, verify in its own lane later. |
| C043 | Rewrite | future_lane | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C044 | Rewrite | parallel_with_guard | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C045 | Rewrite | parallel_with_guard | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C046 | Rewrite | parallel_with_guard | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C047 | Rewrite | parallel_with_guard | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C048 | Rewrite | parallel_with_guard | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C049 | Rewrite | parallel_with_guard | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C050 | Rewrite | parallel_with_guard | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C051 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C052 | Rewrite | mainline_first | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C053 | Rewrite | parallel_with_guard | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C054 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C055 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C056 | Rewrite | mainline_first | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C057 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C058 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C059 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C060 | keep | mainline_first | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C061 | Rewrite | parallel_with_guard | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C062 | Rewrite | future_lane | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C063 | Rewrite | parallel_with_guard | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C064 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C065 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C066 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C067 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C068 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C069 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C070 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C071 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C072 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C073 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C074 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C075 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C076 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C077 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C078 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C079 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C080 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C081 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C082 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C083 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C084 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C085 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C086 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C087 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C088 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C089 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C090 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C091 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C092 | Rewrite | mainline_first | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C093 | Rewrite | parallel_with_guard | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C094 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C095 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C096 | Spike | spike_required | Spike first; current item is too empirical/vendor-dependent for a hard R5 gate. |
| C097 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C098 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C099 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C100 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C101 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C102 | Rewrite | uiue_first_main_after | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C103 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C104 | keep | mainline_first | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C105 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C106 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C107 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C108 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C109 | Rewrite | parallel_with_guard | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C110 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C111 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C112 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C113 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C114 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C115 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C116 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C117 | Spike | spike_required | Spike first; current item is too empirical/vendor-dependent for a hard R5 gate. |
| C118 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C119 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C120 | keep | future_lane | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C121 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C122 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C123 | DeferFutureLane | future_lane | Future-lane risk; record non-claim checkbox now, verify in its own lane later. |
| C124 | DeferFutureLane | future_lane | Future-lane risk; record non-claim checkbox now, verify in its own lane later. |
| C125 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C126 | DeferFutureLane | future_lane | Future-lane risk; record non-claim checkbox now, verify in its own lane later. |
| C127 | DeferFutureLane | future_lane | Future-lane risk; record non-claim checkbox now, verify in its own lane later. |
| C128 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C129 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C130 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C131 | Rewrite | uiue_first_main_after | Rewrite into explicit owner, allowed proof class, and pass/fail command or fixture. |
| C132 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C133 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C134 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C135 | DeferHuman | human_review | Human review lane; do not let taste acceptance masquerade as technical proof. |
| C136 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C137 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C138 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C139 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C140 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C141 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C142 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C143 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C144 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C145 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C146 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C147 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C148 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C149 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C150 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C151 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C152 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C153 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C154 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C155 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C156 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C157 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C158 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C159 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C160 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C161 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C162 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C163 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C164 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C165 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C166 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C167 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C168 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C169 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C170 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C171 | keep | parallel_with_guard | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C172 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C173 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C174 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C175 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C176 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C177 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C178 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C179 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C180 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C181 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C182 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C183 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C184 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C185 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C186 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C187 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C188 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C189 | keep | parallel_with_guard | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C190 | DeferFutureLane | future_lane | Future-lane risk; record non-claim checkbox now, verify in its own lane later. |
| C191 | DeferFutureLane | future_lane | Future-lane risk; record non-claim checkbox now, verify in its own lane later. |
| C192 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C193 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C194 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C195 | keep | parallel_with_guard | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C196 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C197 | Spike | spike_required | Spike first; current item is too empirical/vendor-dependent for a hard R5 gate. |
| C198 | keep | future_lane | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C199 | keep | future_lane | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C200 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C201 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C202 | DeferFutureLane | future_lane | Future-lane risk; record non-claim checkbox now, verify in its own lane later. |
| C203 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C204 | keep | parallel_with_guard | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C205 | keep | parallel_with_guard | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C206 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C207 | Spike | spike_required | Spike first; current item is too empirical/vendor-dependent for a hard R5 gate. |
| C208 | Spike | spike_required | Spike first; current item is too empirical/vendor-dependent for a hard R5 gate. |
| C209 | DeferFutureLane | future_lane | Future-lane risk; record non-claim checkbox now, verify in its own lane later. |
| C210 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C211 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C212 | DeferFutureLane | future_lane | Future-lane risk; record non-claim checkbox now, verify in its own lane later. |
| C213 | keep | parallel_with_guard | Keep as RED guardrail; require evidence before any readiness upgrade. |
| C214 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |
| C215 | Merge | merge_only | cluster-note: merge with stronger sibling covering the same failure mode. |

## Merge / Rewrite / Drop Log
| Candidate(s) | Proposed action | Reason |
|---|---|---|
| C054-C059, C136-C158, C176-C187 | Merge into runtime outcome/event/snapshot contract cluster | Same failure family: enum taxonomy, event gates, terminality, trace/readback precedence. Keep canonical owners and one fixture matrix. |
| C025, C036, C045-C048, C097, C105-C107, C149-C156, C171-C173, C189-C195 | Merge into proof-class/non-claim ladder cluster | Highest RED value, but should produce one hard proof ladder and receipt checklist, not scattered prose gates. |
| C023, C112-C119, C191, C203-C206 | Merge/defer as voice lane | Voice rows are valid, but R5 must record non-claims and avoid turning UIUE voiceState into ASR/TTS readiness. |
| C041, C120-C125, C198-C215 | Split golden/model into future-lane gates | Keep local shape replay separate from model quality; do not let storyboard/script/golden words close runtime or C6 gates. |
| C126-C129, C192 | Rewrite as provenance checklist | External code/assets/issues/H5 are useful teardown inputs only; require source/license/provenance gates before any transfer. |
| C130-C135, C160-C164, C172-C173 | Rewrite or human-route UX/a11y rows | RED agrees they matter, but technical proof, human taste, and true-device a11y must remain separate lanes. |

## Missing Risks Added By This Persona
| Proposed ID | Question | Why it matters | Suggested route | Verification |
|---|---|---|---|---|
| RED-M01 | Any R5 artifact using ready/pass/closed must include proof-class ceiling in the same row. | Prevents local/mock evidence from being cited later as runtime or V-PASS. | parallel_with_guard | grep receipt and matrix for readiness words without proof_class/non_claims. |
| RED-M02 | UIUE must fail closed when a mainline bridge field is absent, renamed, or unknown. | Contract-only carrier is not Swift parity; silent nil/defaults create fake green. | mainline_first | add fixture with unknown proof enum, missing scope field, missing active cell key. |
| RED-M03 | Cancellation/interruption/backgrounding must prove no stale async card/readback mutation after terminal snapshot. | This is the likely iceberg under happy-path simulator proof. | parallel_with_guard | unit/integration fixture: terminal snapshot then delayed adapter callback, assert ignored. |
| RED-M04 | Every future lane checkbox must distinguish lane-start eligibility from lane acceptance. | Prevents dispatch readiness from becoming voice/model/golden readiness by wording drift. | future_lane | receipt schema requires eligible/started/passed/not_claimed columns. |

## Divergence Forecast
| Candidate | Expected dispute type | Why | Recommended routing |
|---|---|---|---|
| C025 | 口径型 | Green may treat proof ladder as checklist; RED treats it as hard anti-inflation gate. | Judge should keep as P0 canonical non-claim gate. |
| C104 | 混合 | UIUE desire for speed conflicts with mainline field authority. | Mainline-first until carrier/type verdict stabilizes. |
| C135 | 口径型 | Designer may value final art; RED says it cannot block/green technical readiness. | Human_review, not R5 hard technical gate. |
| C188 | 事实型 | If no runtime logs exist, runtime-driven naming is false. | Rename fixture-driven until runtime proof exists. |
| C205 | 混合 | Mock transcript can validate UI behavior but not voice readiness. | Voice lane plus explicit non-claim. |

## Residual Risk
- This is a blind review of candidate text plus allowed Source Pool facts; it did not inspect the forbidden original grill pack, private candidate map, other reviewer files, judge outputs, or ledger.
- Scoring is RED-weighted: duplicate but dangerous proof-class rows may still score high on risk, then receive Merge to reduce burndown sprawl.
- No implementation, staging, commit, push, or code edit was performed.
