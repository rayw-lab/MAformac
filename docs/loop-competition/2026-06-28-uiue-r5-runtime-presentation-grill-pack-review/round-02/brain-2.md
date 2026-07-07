# Brain 2 - Round 02 - ORANGE Test Engineer

## Scope And Blindness
- Files read: `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/round-02/brain-2-prompt.md`; `contract.md`; `candidates-blind.md`; allowed source-pool authority/code/spec/test files: UIUE `AGENTS.md`, `CLAUDE.md`, `docs/CURRENT.md`, `docs/README.md`, the two R5 handoffs, `uiue-r5-phase1-consumer-grill-2026-06-28.md`, UIUE `Core/Presentation/PresentationSnapshot.swift`, UIUE `Core/Presentation/DemoRuntimeResultPresentationMatrix.swift`, mainline `Core/Presentation/RuntimePresentationBridge.swift`, mainline `Tests/MAformacCoreTests/RuntimePresentationBridgeTests.swift`, mainline `openspec/changes/define-runtime-presentation-bridge/specs/runtime-presentation-bridge/spec.md`, mainline `docs/project/phase0/runtime-presentation-bridge-phase1-grill-2026-06-28.md`.
- Forbidden files not read: original runtime-presentation grill pack, `candidate-map-private.md`, Round 1 reviewer/judge files, Round 2 other reviewer files, judge files, ledger.
- Proof class: docs/local + subagent_readonly + source-pool code/spec/test inspection. No runtime/mobile/true_device/voice/model/golden/endpoint/V-PASS claim.

## Executive Verdict
- status: PASS_WITH_NOTES
- strongest keep clusters: terminal snapshot fixture matrix; proof-class/no-promotion checker; failure taxonomy and terminality tests; UIUE/mainline DTO crosswalk; stale async mutation after cancel/interruption/timeout.
- weakest/rewrite clusters: declarative architecture statements that need fixture/checker wording; external inspiration/provenance questions; model/golden/voice items that are important but belong to future lanes, not R5 presentation-runtime proof.
- merge/drop candidates: merge the repeated outcome taxonomy rows; merge sample snapshot rows into one table-driven fixture manifest; drop/move external repo/license inspiration items unless actual import happens.
- missing risks: no single machine-readable fixture manifest; no receipt/screenshot no-promotion checker; no deterministic late-async mutation test; no schema-diff receipt for UIUE `activeCells/scopeOrigins` vs mainline flat `cards/scopeOrigin`; no device-drift separation for simulator vs true device.

## Scores
| Candidate | Importance | Verifiability | NonDuplication | DecisionLeverage | RiskRevelation | Total | Verdict | Short reason |
|---|---:|---:|---:|---:|---:|---:|---|---|
| C001 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C002 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C003 | 4 | 4 | 3 | 4 | 4 | 19 | Keep | good candidate for a focused contract/unit/checker gate |
| C004 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C005 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C006 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C007 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C008 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C009 | 4 | 4 | 3 | 4 | 4 | 19 | Keep | good candidate for a focused contract/unit/checker gate |
| C010 | 4 | 4 | 3 | 4 | 4 | 19 | Keep | good candidate for a focused contract/unit/checker gate |
| C011 | 4 | 4 | 3 | 4 | 4 | 19 | Keep | good candidate for a focused contract/unit/checker gate |
| C012 | 4 | 4 | 3 | 4 | 4 | 19 | Keep | good candidate for a focused contract/unit/checker gate |
| C013 | 4 | 4 | 3 | 4 | 4 | 19 | Keep | good candidate for a focused contract/unit/checker gate |
| C014 | 4 | 4 | 3 | 4 | 4 | 19 | Keep | good candidate for a focused contract/unit/checker gate |
| C015 | 4 | 4 | 3 | 4 | 4 | 19 | Keep | good candidate for a focused contract/unit/checker gate |
| C016 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C017 | 4 | 4 | 3 | 4 | 4 | 19 | Keep | good candidate for a focused contract/unit/checker gate |
| C018 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C019 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C020 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C021 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C022 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C023 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C024 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C025 | 5 | 5 | 3 | 5 | 5 | 23 | Keep | proof-class cap/checker item; high value for stopping simulator/local proof promotion |
| C026 | 3 | 2 | 3 | 2 | 3 | 13 | DeferFutureLane | good candidate for a focused contract/unit/checker gate |
| C027 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C028 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C029 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C030 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C031 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C032 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C033 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C034 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C035 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C036 | 5 | 5 | 3 | 5 | 5 | 23 | Keep | proof-class cap/checker item; high value for stopping simulator/local proof promotion |
| C037 | 3 | 2 | 3 | 2 | 3 | 13 | DeferFutureLane | good candidate for a focused contract/unit/checker gate |
| C038 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C039 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C040 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C041 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C042 | 3 | 2 | 3 | 2 | 3 | 13 | DeferFutureLane | good candidate for a focused contract/unit/checker gate |
| C043 | 3 | 2 | 3 | 2 | 3 | 13 | DeferFutureLane | good candidate for a focused contract/unit/checker gate |
| C044 | 3 | 2 | 3 | 2 | 3 | 13 | DeferFutureLane | good candidate for a focused contract/unit/checker gate |
| C045 | 5 | 5 | 3 | 5 | 5 | 23 | Keep | proof-class cap/checker item; high value for stopping simulator/local proof promotion |
| C046 | 5 | 5 | 3 | 5 | 5 | 23 | Rewrite | proof-class cap/checker item; high value for stopping simulator/local proof promotion |
| C047 | 5 | 5 | 3 | 5 | 5 | 23 | Keep | proof-class cap/checker item; high value for stopping simulator/local proof promotion |
| C048 | 5 | 5 | 3 | 5 | 5 | 23 | Keep | good candidate for a focused contract/unit/checker gate |
| C049 | 5 | 5 | 3 | 5 | 5 | 23 | Keep | good candidate for a focused contract/unit/checker gate |
| C050 | 5 | 5 | 3 | 5 | 5 | 23 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C051 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | duplicates adjacent cluster; keep evidence under Merge C030/C073-C075 |
| C052 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C053 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | duplicates adjacent cluster; keep evidence under Merge C021/C090-C091/C181 |
| C054 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | failure taxonomy and terminality must be locked with unit fixtures, not copy review |
| C055 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | failure taxonomy and terminality must be locked with unit fixtures, not copy review |
| C056 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | failure taxonomy and terminality must be locked with unit fixtures, not copy review |
| C057 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | failure taxonomy and terminality must be locked with unit fixtures, not copy review |
| C058 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | failure taxonomy and terminality must be locked with unit fixtures, not copy review |
| C059 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | failure taxonomy and terminality must be locked with unit fixtures, not copy review |
| C060 | 5 | 5 | 3 | 5 | 5 | 23 | Rewrite | failure taxonomy and terminality must be locked with unit fixtures, not copy review |
| C061 | 5 | 5 | 3 | 5 | 5 | 23 | Rewrite | failure taxonomy and terminality must be locked with unit fixtures, not copy review |
| C062 | 5 | 5 | 3 | 5 | 5 | 23 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C063 | 5 | 5 | 3 | 5 | 5 | 23 | Keep | good candidate for a focused contract/unit/checker gate |
| C064 | 5 | 5 | 3 | 5 | 5 | 23 | Keep | terminal fixture/sample coverage is directly testable and prevents silent fake-green outcomes |
| C065 | 5 | 5 | 3 | 5 | 5 | 23 | Keep | terminal fixture/sample coverage is directly testable and prevents silent fake-green outcomes |
| C066 | 5 | 5 | 3 | 5 | 5 | 23 | Keep | terminal fixture/sample coverage is directly testable and prevents silent fake-green outcomes |
| C067 | 5 | 5 | 3 | 5 | 5 | 23 | Keep | terminal fixture/sample coverage is directly testable and prevents silent fake-green outcomes |
| C068 | 5 | 5 | 3 | 5 | 5 | 23 | Keep | terminal fixture/sample coverage is directly testable and prevents silent fake-green outcomes |
| C069 | 5 | 5 | 3 | 5 | 5 | 23 | Keep | terminal fixture/sample coverage is directly testable and prevents silent fake-green outcomes |
| C070 | 5 | 5 | 3 | 5 | 5 | 23 | Keep | terminal fixture/sample coverage is directly testable and prevents silent fake-green outcomes |
| C071 | 5 | 5 | 3 | 5 | 5 | 23 | Keep | terminal fixture/sample coverage is directly testable and prevents silent fake-green outcomes |
| C072 | 5 | 5 | 3 | 5 | 5 | 23 | Keep | terminal fixture/sample coverage is directly testable and prevents silent fake-green outcomes |
| C073 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C074 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C075 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C076 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C077 | 4 | 4 | 3 | 4 | 4 | 19 | Keep | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C078 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C079 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C080 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C081 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C082 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C083 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C084 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C085 | 5 | 5 | 2 | 5 | 5 | 22 | Merge | duplicates adjacent cluster; keep evidence under Merge C058/C166 |
| C086 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | duplicates adjacent cluster; keep evidence under Merge C052/C183 |
| C087 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | duplicates adjacent cluster; keep evidence under Merge C146 |
| C088 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | duplicates adjacent cluster; keep evidence under Merge C147 |
| C089 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | duplicates adjacent cluster; keep evidence under Merge C022/C145/C186 |
| C090 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | duplicates adjacent cluster; keep evidence under Merge C053/C181 |
| C091 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | duplicates adjacent cluster; keep evidence under Merge C053 |
| C092 | 4 | 4 | 3 | 4 | 4 | 19 | Keep | good candidate for a focused contract/unit/checker gate |
| C093 | 4 | 4 | 3 | 4 | 4 | 19 | Keep | good candidate for a focused contract/unit/checker gate |
| C094 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | duplicates adjacent cluster; keep evidence under Merge C148 |
| C095 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | duplicates adjacent cluster; keep evidence under Merge C034/C167 |
| C096 | 4 | 2 | 3 | 3 | 4 | 16 | Spike | needs empirical spike before turning into a stable regression gate |
| C097 | 5 | 5 | 3 | 5 | 5 | 23 | Keep | proof-class cap/checker item; high value for stopping simulator/local proof promotion |
| C098 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C099 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C100 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C101 | 5 | 5 | 3 | 5 | 5 | 23 | Rewrite | terminal fixture/sample coverage is directly testable and prevents silent fake-green outcomes |
| C102 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C103 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C104 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C105 | 5 | 5 | 3 | 5 | 5 | 23 | Keep | proof-class cap/checker item; high value for stopping simulator/local proof promotion |
| C106 | 5 | 5 | 3 | 5 | 5 | 23 | Keep | proof-class cap/checker item; high value for stopping simulator/local proof promotion |
| C107 | 5 | 5 | 3 | 5 | 5 | 23 | Rewrite | proof-class cap/checker item; high value for stopping simulator/local proof promotion |
| C108 | 5 | 5 | 3 | 5 | 5 | 23 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C109 | 5 | 5 | 3 | 5 | 5 | 23 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C110 | 5 | 5 | 3 | 5 | 5 | 23 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C111 | 5 | 5 | 3 | 5 | 5 | 23 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C112 | 3 | 2 | 3 | 2 | 3 | 13 | DeferFutureLane | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane |
| C113 | 3 | 2 | 3 | 2 | 3 | 13 | DeferFutureLane | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane |
| C114 | 3 | 2 | 3 | 2 | 3 | 13 | DeferFutureLane | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane |
| C115 | 3 | 2 | 3 | 2 | 3 | 13 | DeferFutureLane | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane |
| C116 | 3 | 2 | 3 | 2 | 3 | 13 | DeferFutureLane | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane |
| C117 | 4 | 2 | 3 | 3 | 4 | 16 | Spike | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane |
| C118 | 3 | 2 | 3 | 2 | 3 | 13 | DeferFutureLane | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane |
| C119 | 3 | 2 | 3 | 2 | 3 | 13 | DeferFutureLane | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane |
| C120 | 5 | 5 | 3 | 5 | 5 | 23 | Rewrite | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C121 | 5 | 5 | 3 | 5 | 5 | 23 | Rewrite | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C122 | 5 | 4 | 3 | 4 | 5 | 21 | DeferFutureLane | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C123 | 5 | 4 | 3 | 4 | 5 | 21 | DeferFutureLane | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C124 | 4 | 2 | 3 | 3 | 4 | 16 | Spike | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C125 | 4 | 2 | 3 | 3 | 4 | 16 | Spike | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C126 | 2 | 2 | 2 | 2 | 2 | 10 | Drop | low direct leverage for ORANGE test lane; keep as provenance checklist outside this matrix |
| C127 | 2 | 2 | 2 | 2 | 2 | 10 | Drop | low direct leverage for ORANGE test lane; keep as provenance checklist outside this matrix |
| C128 | 2 | 2 | 2 | 2 | 2 | 10 | Drop | low direct leverage for ORANGE test lane; keep as provenance checklist outside this matrix |
| C129 | 2 | 2 | 2 | 2 | 2 | 10 | Drop | low direct leverage for ORANGE test lane; keep as provenance checklist outside this matrix |
| C130 | 3 | 2 | 3 | 3 | 3 | 14 | DeferHuman | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C131 | 3 | 2 | 3 | 3 | 3 | 14 | DeferHuman | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C132 | 3 | 2 | 3 | 3 | 3 | 14 | DeferHuman | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C133 | 3 | 2 | 3 | 2 | 3 | 13 | DeferFutureLane | good candidate for a focused contract/unit/checker gate |
| C134 | 3 | 2 | 3 | 3 | 3 | 14 | DeferHuman | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C135 | 3 | 2 | 3 | 3 | 3 | 14 | DeferHuman | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C136 | 5 | 5 | 2 | 5 | 5 | 22 | Merge | failure taxonomy and terminality must be locked with unit fixtures, not copy review |
| C137 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | duplicates adjacent cluster; keep evidence under Merge C063 |
| C138 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | duplicates adjacent cluster; keep evidence under Merge C187 |
| C139 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | duplicates adjacent cluster; keep evidence under Merge C080 |
| C140 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | duplicates adjacent cluster; keep evidence under Merge C078 |
| C141 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | duplicates adjacent cluster; keep evidence under Merge C079/C158 |
| C142 | 5 | 5 | 2 | 5 | 5 | 22 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C143 | 5 | 5 | 2 | 5 | 5 | 22 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C144 | 5 | 5 | 2 | 5 | 5 | 22 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C145 | 5 | 5 | 2 | 5 | 5 | 22 | Merge | failure taxonomy and terminality must be locked with unit fixtures, not copy review |
| C146 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | duplicates adjacent cluster; keep evidence under Merge C087 |
| C147 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | duplicates adjacent cluster; keep evidence under Merge C088 |
| C148 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | duplicates adjacent cluster; keep evidence under Merge C094 |
| C149 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C150 | 5 | 5 | 3 | 5 | 5 | 23 | Rewrite | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C151 | 4 | 4 | 3 | 4 | 4 | 19 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C152 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C153 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C154 | 5 | 5 | 2 | 5 | 5 | 22 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C155 | 5 | 2 | 3 | 5 | 5 | 20 | DeferHuman | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C156 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C157 | 5 | 5 | 3 | 5 | 5 | 23 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C158 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C159 | 4 | 3 | 3 | 3 | 3 | 16 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C160 | 3 | 2 | 3 | 3 | 3 | 14 | DeferHuman | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C161 | 3 | 2 | 3 | 3 | 3 | 14 | DeferHuman | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C162 | 3 | 2 | 3 | 3 | 3 | 14 | DeferHuman | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C163 | 3 | 2 | 3 | 3 | 3 | 14 | DeferHuman | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C164 | 3 | 2 | 3 | 3 | 3 | 14 | DeferHuman | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C165 | 5 | 5 | 2 | 5 | 5 | 22 | Merge | failure taxonomy and terminality must be locked with unit fixtures, not copy review |
| C166 | 5 | 5 | 2 | 5 | 5 | 22 | Merge | failure taxonomy and terminality must be locked with unit fixtures, not copy review |
| C167 | 4 | 3 | 2 | 4 | 4 | 17 | Merge | duplicates adjacent cluster; keep evidence under Merge C034/C095 |
| C168 | 4 | 3 | 2 | 4 | 4 | 17 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C169 | 4 | 3 | 2 | 4 | 4 | 17 | Merge | duplicates adjacent cluster; keep evidence under Merge C029/C030 |
| C170 | 5 | 5 | 2 | 5 | 5 | 22 | Merge | terminal fixture/sample coverage is directly testable and prevents silent fake-green outcomes |
| C171 | 5 | 5 | 2 | 5 | 5 | 22 | Merge | proof-class cap/checker item; high value for stopping simulator/local proof promotion |
| C172 | 3 | 2 | 3 | 3 | 3 | 14 | DeferHuman | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C173 | 5 | 2 | 3 | 5 | 5 | 20 | DeferHuman | proof-class cap/checker item; high value for stopping simulator/local proof promotion |
| C174 | 4 | 3 | 2 | 4 | 4 | 17 | Merge | duplicates adjacent cluster; keep evidence under Merge C053/C181 |
| C175 | 4 | 3 | 2 | 4 | 4 | 17 | Merge | duplicates adjacent cluster; keep evidence under Merge C023/C118 |
| C176 | 5 | 5 | 2 | 5 | 5 | 22 | Merge | failure taxonomy and terminality must be locked with unit fixtures, not copy review |
| C177 | 5 | 5 | 2 | 5 | 5 | 22 | Merge | terminal fixture/sample coverage is directly testable and prevents silent fake-green outcomes |
| C178 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | duplicates adjacent cluster; keep evidence under Merge C017/C098/C157 |
| C179 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C180 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C181 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | duplicates adjacent cluster; keep evidence under Merge C053/C090 |
| C182 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C183 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | duplicates adjacent cluster; keep evidence under Merge C052/C086 |
| C184 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C185 | 5 | 5 | 3 | 5 | 5 | 23 | Rewrite | failure taxonomy and terminality must be locked with unit fixtures, not copy review |
| C186 | 5 | 5 | 3 | 5 | 5 | 23 | Rewrite | failure taxonomy and terminality must be locked with unit fixtures, not copy review |
| C187 | 5 | 5 | 3 | 5 | 5 | 23 | Rewrite | failure taxonomy and terminality must be locked with unit fixtures, not copy review |
| C188 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | duplicates adjacent cluster; keep evidence under Merge C102 |
| C189 | 5 | 5 | 2 | 5 | 5 | 22 | Merge | proof-class cap/checker item; high value for stopping simulator/local proof promotion |
| C190 | 3 | 2 | 3 | 2 | 3 | 13 | DeferFutureLane | good candidate for a focused contract/unit/checker gate |
| C191 | 3 | 2 | 3 | 2 | 3 | 13 | DeferFutureLane | good candidate for a focused contract/unit/checker gate |
| C192 | 3 | 2 | 3 | 3 | 3 | 14 | DeferHuman | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C193 | 5 | 5 | 3 | 5 | 5 | 23 | Rewrite | proof-class cap/checker item; high value for stopping simulator/local proof promotion |
| C194 | 3 | 2 | 3 | 3 | 3 | 14 | DeferHuman | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C195 | 5 | 5 | 3 | 5 | 5 | 23 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C196 | 5 | 5 | 3 | 5 | 5 | 23 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C197 | 4 | 2 | 3 | 3 | 4 | 16 | Spike | needs empirical spike before turning into a stable regression gate |
| C198 | 5 | 5 | 2 | 5 | 5 | 22 | Merge | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C199 | 5 | 5 | 2 | 5 | 5 | 22 | Merge | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C200 | 5 | 5 | 2 | 5 | 5 | 22 | Merge | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C201 | 5 | 5 | 2 | 5 | 5 | 22 | Merge | duplicates adjacent cluster; keep evidence under Merge C017/C157 |
| C202 | 3 | 2 | 3 | 2 | 3 | 13 | DeferFutureLane | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane |
| C203 | 4 | 3 | 2 | 4 | 4 | 17 | Merge | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane |
| C204 | 4 | 3 | 2 | 4 | 4 | 17 | Merge | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane |
| C205 | 5 | 5 | 2 | 5 | 5 | 22 | Merge | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane |
| C206 | 5 | 5 | 2 | 5 | 5 | 22 | Merge | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane |
| C207 | 4 | 2 | 3 | 3 | 4 | 16 | Spike | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C208 | 5 | 4 | 3 | 4 | 5 | 21 | DeferFutureLane | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C209 | 4 | 2 | 3 | 3 | 4 | 16 | Spike | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C210 | 4 | 2 | 3 | 3 | 4 | 16 | Spike | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C211 | 3 | 2 | 3 | 2 | 3 | 13 | DeferFutureLane | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C212 | 3 | 2 | 3 | 2 | 3 | 13 | DeferFutureLane | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C213 | 5 | 5 | 3 | 5 | 5 | 23 | Rewrite | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C214 | 5 | 5 | 2 | 5 | 5 | 22 | Merge | failure taxonomy and terminality must be locked with unit fixtures, not copy review |
| C215 | 5 | 4 | 3 | 4 | 5 | 21 | DeferFutureLane | golden/model/eval candidate is important but not R5 presentation-runtime proof |

## Candidate Notes
| Candidate | Action | Route | Note |
|---|---|---|---|
| C001 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C002 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C003 | keep | mainline_first | good candidate for a focused contract/unit/checker gate |
| C004 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C005 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C006 | rewrite | mainline_first | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C007 | rewrite | mainline_first | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C008 | rewrite | mainline_first | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C009 | keep | mainline_first | good candidate for a focused contract/unit/checker gate |
| C010 | keep | mainline_first | good candidate for a focused contract/unit/checker gate |
| C011 | keep | parallel_with_guard | good candidate for a focused contract/unit/checker gate |
| C012 | keep | mainline_first | good candidate for a focused contract/unit/checker gate |
| C013 | keep | mainline_first | good candidate for a focused contract/unit/checker gate |
| C014 | keep | mainline_first | good candidate for a focused contract/unit/checker gate |
| C015 | keep | mainline_first | good candidate for a focused contract/unit/checker gate |
| C016 | rewrite | mainline_first | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C017 | keep | mainline_first | good candidate for a focused contract/unit/checker gate |
| C018 | rewrite | mainline_first | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C019 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C020 | rewrite | mainline_first | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C021 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C022 | rewrite | mainline_first | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C023 | rewrite | mainline_first | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C024 | rewrite | mainline_first | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C025 | keep | merge_only | proof-class cap/checker item; high value for stopping simulator/local proof promotion |
| C026 | defer-future-lane | future_lane | good candidate for a focused contract/unit/checker gate |
| C027 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C028 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C029 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C030 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C031 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C032 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C033 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C034 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C035 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C036 | keep | future_lane | proof-class cap/checker item; high value for stopping simulator/local proof promotion |
| C037 | defer-future-lane | future_lane | good candidate for a focused contract/unit/checker gate |
| C038 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C039 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C040 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C041 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C042 | defer-future-lane | future_lane | good candidate for a focused contract/unit/checker gate |
| C043 | defer-future-lane | future_lane | good candidate for a focused contract/unit/checker gate |
| C044 | defer-future-lane | future_lane | good candidate for a focused contract/unit/checker gate |
| C045 | keep | main_first_uiue_after | proof-class cap/checker item; high value for stopping simulator/local proof promotion |
| C046 | rewrite | mainline_first | proof-class cap/checker item; high value for stopping simulator/local proof promotion |
| C047 | keep | human_review | proof-class cap/checker item; high value for stopping simulator/local proof promotion |
| C048 | keep | merge_only | good candidate for a focused contract/unit/checker gate |
| C049 | keep | merge_only | good candidate for a focused contract/unit/checker gate |
| C050 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C051 | merge | mainline_first | duplicates adjacent cluster; keep evidence under Merge C030/C073-C075; proposed cluster: Merge C030/C073-C075 |
| C052 | rewrite | mainline_first | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C053 | merge | mainline_first | duplicates adjacent cluster; keep evidence under Merge C021/C090-C091/C181; proposed cluster: Merge C021/C090-C091/C181 |
| C054 | rewrite | mainline_first | failure taxonomy and terminality must be locked with unit fixtures, not copy review |
| C055 | merge | mainline_first | failure taxonomy and terminality must be locked with unit fixtures, not copy review; proposed cluster: Merge C010/C054/C057/C176 |
| C056 | merge | mainline_first | failure taxonomy and terminality must be locked with unit fixtures, not copy review; proposed cluster: Merge C065/C136/C152 |
| C057 | merge | mainline_first | failure taxonomy and terminality must be locked with unit fixtures, not copy review; proposed cluster: Merge C010/C055 |
| C058 | merge | mainline_first | failure taxonomy and terminality must be locked with unit fixtures, not copy review; proposed cluster: Merge C166/C176 |
| C059 | merge | mainline_first | failure taxonomy and terminality must be locked with unit fixtures, not copy review; proposed cluster: Merge C022/C145 |
| C060 | rewrite | mainline_first | failure taxonomy and terminality must be locked with unit fixtures, not copy review |
| C061 | rewrite | mainline_first | failure taxonomy and terminality must be locked with unit fixtures, not copy review |
| C062 | rewrite | mainline_first | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C063 | keep | mainline_first | good candidate for a focused contract/unit/checker gate |
| C064 | keep | mainline_first | terminal fixture/sample coverage is directly testable and prevents silent fake-green outcomes |
| C065 | keep | mainline_first | terminal fixture/sample coverage is directly testable and prevents silent fake-green outcomes |
| C066 | keep | mainline_first | terminal fixture/sample coverage is directly testable and prevents silent fake-green outcomes |
| C067 | keep | mainline_first | terminal fixture/sample coverage is directly testable and prevents silent fake-green outcomes |
| C068 | keep | mainline_first | terminal fixture/sample coverage is directly testable and prevents silent fake-green outcomes |
| C069 | keep | mainline_first | terminal fixture/sample coverage is directly testable and prevents silent fake-green outcomes |
| C070 | keep | mainline_first | terminal fixture/sample coverage is directly testable and prevents silent fake-green outcomes |
| C071 | keep | mainline_first | terminal fixture/sample coverage is directly testable and prevents silent fake-green outcomes |
| C072 | keep | mainline_first | terminal fixture/sample coverage is directly testable and prevents silent fake-green outcomes |
| C073 | merge | mainline_first | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C030/C051/C184 |
| C074 | merge | mainline_first | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C051/C184 |
| C075 | merge | mainline_first | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C017/C157 |
| C076 | merge | mainline_first | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C007/C099/C153 |
| C077 | keep | mainline_first | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C078 | merge | mainline_first | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C079/C140/C158 |
| C079 | merge | mainline_first | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C141/C158 |
| C080 | merge | mainline_first | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C139 |
| C081 | merge | mainline_first | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C144 |
| C082 | merge | mainline_first | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C182 |
| C083 | merge | mainline_first | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C182 |
| C084 | merge | mainline_first | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C182 |
| C085 | merge | mainline_first | duplicates adjacent cluster; keep evidence under Merge C058/C166; proposed cluster: Merge C058/C166 |
| C086 | merge | mainline_first | duplicates adjacent cluster; keep evidence under Merge C052/C183; proposed cluster: Merge C052/C183 |
| C087 | merge | mainline_first | duplicates adjacent cluster; keep evidence under Merge C146; proposed cluster: Merge C146 |
| C088 | merge | mainline_first | duplicates adjacent cluster; keep evidence under Merge C147; proposed cluster: Merge C147 |
| C089 | merge | mainline_first | duplicates adjacent cluster; keep evidence under Merge C022/C145/C186; proposed cluster: Merge C022/C145/C186 |
| C090 | merge | mainline_first | duplicates adjacent cluster; keep evidence under Merge C053/C181; proposed cluster: Merge C053/C181 |
| C091 | merge | mainline_first | duplicates adjacent cluster; keep evidence under Merge C053; proposed cluster: Merge C053 |
| C092 | keep | parallel_with_guard | good candidate for a focused contract/unit/checker gate |
| C093 | keep | parallel_with_guard | good candidate for a focused contract/unit/checker gate |
| C094 | merge | parallel_with_guard | duplicates adjacent cluster; keep evidence under Merge C148; proposed cluster: Merge C148 |
| C095 | merge | parallel_with_guard | duplicates adjacent cluster; keep evidence under Merge C034/C167; proposed cluster: Merge C034/C167 |
| C096 | spike | spike_required | needs empirical spike before turning into a stable regression gate |
| C097 | keep | parallel_with_guard | proof-class cap/checker item; high value for stopping simulator/local proof promotion |
| C098 | merge | parallel_with_guard | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C009/C054/C136 |
| C099 | merge | parallel_with_guard | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C153 |
| C100 | merge | parallel_with_guard | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C168 |
| C101 | rewrite | mainline_first | terminal fixture/sample coverage is directly testable and prevents silent fake-green outcomes |
| C102 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C103 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C104 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C105 | keep | parallel_with_guard | proof-class cap/checker item; high value for stopping simulator/local proof promotion |
| C106 | keep | uiue_first_main_after | proof-class cap/checker item; high value for stopping simulator/local proof promotion |
| C107 | rewrite | parallel_with_guard | proof-class cap/checker item; high value for stopping simulator/local proof promotion |
| C108 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C109 | rewrite | uiue_first | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C110 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C111 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C112 | defer-future-lane | future_lane | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane |
| C113 | defer-future-lane | future_lane | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane |
| C114 | defer-future-lane | future_lane | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane |
| C115 | defer-future-lane | future_lane | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane |
| C116 | defer-future-lane | future_lane | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane |
| C117 | spike | spike_required | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane |
| C118 | defer-future-lane | future_lane | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane |
| C119 | defer-future-lane | future_lane | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane |
| C120 | rewrite | future_lane | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C121 | rewrite | future_lane | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C122 | defer-future-lane | future_lane | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C123 | defer-future-lane | future_lane | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C124 | spike | spike_required | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C125 | spike | spike_required | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C126 | drop | future_lane | low direct leverage for ORANGE test lane; keep as provenance checklist outside this matrix |
| C127 | drop | future_lane | low direct leverage for ORANGE test lane; keep as provenance checklist outside this matrix |
| C128 | drop | future_lane | low direct leverage for ORANGE test lane; keep as provenance checklist outside this matrix |
| C129 | drop | future_lane | low direct leverage for ORANGE test lane; keep as provenance checklist outside this matrix |
| C130 | defer-human | human_review | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C131 | defer-human | human_review | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C132 | defer-human | human_review | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C133 | defer-future-lane | future_lane | good candidate for a focused contract/unit/checker gate |
| C134 | defer-human | human_review | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C135 | defer-human | human_review | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C136 | merge | mainline_first | failure taxonomy and terminality must be locked with unit fixtures, not copy review; proposed cluster: Merge C054/C056/C152 |
| C137 | merge | mainline_first | duplicates adjacent cluster; keep evidence under Merge C063; proposed cluster: Merge C063 |
| C138 | merge | mainline_first | duplicates adjacent cluster; keep evidence under Merge C187; proposed cluster: Merge C187 |
| C139 | merge | mainline_first | duplicates adjacent cluster; keep evidence under Merge C080; proposed cluster: Merge C080 |
| C140 | merge | mainline_first | duplicates adjacent cluster; keep evidence under Merge C078; proposed cluster: Merge C078 |
| C141 | merge | mainline_first | duplicates adjacent cluster; keep evidence under Merge C079/C158; proposed cluster: Merge C079/C158 |
| C142 | merge | mainline_first | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge trace contract cluster |
| C143 | merge | mainline_first | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge trace contract cluster |
| C144 | merge | mainline_first | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C081 |
| C145 | merge | mainline_first | failure taxonomy and terminality must be locked with unit fixtures, not copy review; proposed cluster: Merge C059 |
| C146 | merge | mainline_first | duplicates adjacent cluster; keep evidence under Merge C087; proposed cluster: Merge C087 |
| C147 | merge | mainline_first | duplicates adjacent cluster; keep evidence under Merge C088; proposed cluster: Merge C088 |
| C148 | merge | mainline_first | duplicates adjacent cluster; keep evidence under Merge C094; proposed cluster: Merge C094 |
| C149 | merge | mainline_first | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C180 |
| C150 | rewrite | mainline_first | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface |
| C151 | rewrite | mainline_first | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C152 | merge | mainline_first | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C056/C136 |
| C153 | merge | mainline_first | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C099 |
| C154 | merge | parallel_with_guard | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C097 |
| C155 | defer-human | human_review | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C156 | merge | mainline_first | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C103 |
| C157 | rewrite | mainline_first | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C158 | merge | mainline_first | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C079/C141 |
| C159 | rewrite | uiue_first_main_after | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C160 | defer-human | human_review | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C161 | defer-human | human_review | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C162 | defer-human | human_review | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C163 | defer-human | human_review | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C164 | defer-human | human_review | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C165 | merge | mainline_first | failure taxonomy and terminality must be locked with unit fixtures, not copy review; proposed cluster: Merge C059/C145 |
| C166 | merge | mainline_first | failure taxonomy and terminality must be locked with unit fixtures, not copy review; proposed cluster: Merge C058 |
| C167 | merge | uiue_first_main_after | duplicates adjacent cluster; keep evidence under Merge C034/C095; proposed cluster: Merge C034/C095 |
| C168 | merge | uiue_first_main_after | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C100 |
| C169 | merge | uiue_first_main_after | duplicates adjacent cluster; keep evidence under Merge C029/C030; proposed cluster: Merge C029/C030 |
| C170 | merge | mainline_first | terminal fixture/sample coverage is directly testable and prevents silent fake-green outcomes; proposed cluster: Merge C101/C177 |
| C171 | merge | uiue_first_main_after | proof-class cap/checker item; high value for stopping simulator/local proof promotion; proposed cluster: Merge C045/C106 |
| C172 | defer-human | human_review | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C173 | defer-human | human_review | proof-class cap/checker item; high value for stopping simulator/local proof promotion |
| C174 | merge | uiue_first_main_after | duplicates adjacent cluster; keep evidence under Merge C053/C181; proposed cluster: Merge C053/C181 |
| C175 | merge | uiue_first_main_after | duplicates adjacent cluster; keep evidence under Merge C023/C118; proposed cluster: Merge C023/C118 |
| C176 | merge | mainline_first | failure taxonomy and terminality must be locked with unit fixtures, not copy review; proposed cluster: Merge C054/C055/C058 |
| C177 | merge | mainline_first | terminal fixture/sample coverage is directly testable and prevents silent fake-green outcomes; proposed cluster: Merge C064-C072 |
| C178 | merge | mainline_first | duplicates adjacent cluster; keep evidence under Merge C017/C098/C157; proposed cluster: Merge C017/C098/C157 |
| C179 | merge | mainline_first | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C097/C154 |
| C180 | merge | mainline_first | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C149 |
| C181 | merge | mainline_first | duplicates adjacent cluster; keep evidence under Merge C053/C090; proposed cluster: Merge C053/C090 |
| C182 | merge | mainline_first | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C082-C084 |
| C183 | merge | mainline_first | duplicates adjacent cluster; keep evidence under Merge C052/C086; proposed cluster: Merge C052/C086 |
| C184 | merge | mainline_first | shared DTO/crosswalk ambiguity; needs merge to one authoritative contract test surface; proposed cluster: Merge C051/C073-C074 |
| C185 | rewrite | mainline_first | failure taxonomy and terminality must be locked with unit fixtures, not copy review |
| C186 | rewrite | mainline_first | failure taxonomy and terminality must be locked with unit fixtures, not copy review |
| C187 | rewrite | mainline_first | failure taxonomy and terminality must be locked with unit fixtures, not copy review |
| C188 | merge | mainline_first | duplicates adjacent cluster; keep evidence under Merge C102; proposed cluster: Merge C102 |
| C189 | merge | parallel_with_guard | proof-class cap/checker item; high value for stopping simulator/local proof promotion; proposed cluster: Merge C105/C107/C193 |
| C190 | defer-future-lane | future_lane | good candidate for a focused contract/unit/checker gate |
| C191 | defer-future-lane | future_lane | good candidate for a focused contract/unit/checker gate |
| C192 | defer-human | human_review | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C193 | rewrite | parallel_with_guard | proof-class cap/checker item; high value for stopping simulator/local proof promotion |
| C194 | defer-human | human_review | policy or visual/a11y judgment needs human/product lane before executable test can be final |
| C195 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C196 | rewrite | parallel_with_guard | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C197 | spike | spike_required | needs empirical spike before turning into a stable regression gate |
| C198 | merge | future_lane | golden/model/eval candidate is important but not R5 presentation-runtime proof; proposed cluster: Merge C120 |
| C199 | merge | future_lane | golden/model/eval candidate is important but not R5 presentation-runtime proof; proposed cluster: Merge C121 |
| C200 | merge | future_lane | golden/model/eval candidate is important but not R5 presentation-runtime proof; proposed cluster: Merge C014/C185 |
| C201 | merge | mainline_first | duplicates adjacent cluster; keep evidence under Merge C017/C157; proposed cluster: Merge C017/C157 |
| C202 | defer-future-lane | future_lane | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane |
| C203 | merge | future_lane | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane; proposed cluster: Merge C114/C115 |
| C204 | merge | future_lane | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane; proposed cluster: Merge C112 |
| C205 | merge | future_lane | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane; proposed cluster: Merge C113/C191 |
| C206 | merge | future_lane | voice/ASR/TTS state-machine risk is real but belongs to separate proof lane; proposed cluster: Merge C116 |
| C207 | spike | spike_required | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C208 | defer-future-lane | future_lane | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C209 | spike | spike_required | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C210 | spike | spike_required | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C211 | defer-future-lane | future_lane | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C212 | defer-future-lane | future_lane | golden/model/eval candidate is important but not R5 presentation-runtime proof |
| C213 | rewrite | uiue_first_main_after | valuable but phrased as broad assertion; rewrite into fixture/checker/verifiable acceptance criterion |
| C214 | merge | mainline_first | failure taxonomy and terminality must be locked with unit fixtures, not copy review; proposed cluster: Merge C022/C060/C186/C187 |
| C215 | defer-future-lane | future_lane | golden/model/eval candidate is important but not R5 presentation-runtime proof |

## Merge / Rewrite / Drop Log
| Candidate(s) | Proposed action | Reason |
|---|---|---|
| C054-C058, C136-C138, C165-C166, C176 | Merge into one failure-taxonomy + outcome-priority gate | Same risk surface: ToolExecutionError/result/reason/missingSlot/scopeFailureReason mapping must become one table plus tests. |
| C064-C072, C101, C170, C177, C214 | Merge into terminal snapshot fixture matrix | ORANGE highest leverage: one manifest should enumerate every terminal outcome, terminal bit, trace, readback, proof class, and stale-async guard. |
| C025, C045-C048, C097, C105-C108, C171, C173, C189, C193 | Merge proof-class/no-promotion checker cluster | Prevents local/simulator/operator artifacts from being cited as runtime/mobile/true_device/voice/model/golden/V-PASS. |
| C073-C084, C098-C100, C142-C156, C168, C179-C184 | Merge shared DTO/crosswalk cluster | Multiple questions name the same API drift risk; judge should collapse into one mainline-first contract/cross-repo test pack. |
| C120-C125, C198-C215 | Defer/merge into model-golden-voice proof lanes | Important but outside R5 presentation-runtime dispatch proof; keep non-claims and future gates explicit. |
| C126-C129, C192 | Drop or move to provenance checklist | External inspiration/license issues matter, but they are not strong ORANGE R5 runtime-presentation test candidates unless code/assets are imported. |

## Missing Risks Added By This Persona
| Proposed ID | Question | Why it matters | Suggested route | Verification |
|---|---|---|---|---|
| ORANGE-MR-01 | 是否存在一份 machine-readable terminal snapshot fixture manifest，逐 outcome 断言 result、isTerminal、traceID、readbacks、proofClass、scopeOrigin、stale-async mutate prohibition？ | 当前候选多次要求 sample，但缺一个统一可跑清单会导致补了样例仍漏断言。 | mainline_first | unit fixture manifest + checker; `RuntimePresentationBridgeTests` 扩展为 table-driven tests。 |
| ORANGE-MR-02 | UIUE/mainline proof-class crosswalk 是否有 no-promotion grep/checker，扫描 receipt/screenshot anchor/closeout 文案里的 forbidden readiness claims？ | proof cap 是最大假绿风险，人工读 closeout 不够稳定。 | parallel_with_guard | docs checker: local/simulator/operatorReview 不得伴随 runtime/mobile/true_device/voice/model/golden/V-PASS 等词。 |
| ORANGE-MR-03 | cancel/interruption/timeout 后的 late async mutation 是否有 deterministic fake clock 或 executor test？ | 终态 snapshot 存在不等于后续 async 不会改卡片/voice/orb。 | mainline_first | fake scheduler/unit test: terminal emitted后任何 pending callback 不得 mutate cards/readbacks/orb/voice。 |
| ORANGE-MR-04 | UIUE fixture 与 mainline DTO 字段差异是否有 schema-diff/crosswalk receipt？ | UIUE 现在有 `activeCells/scopeOrigins/refusedCell`，mainline carrier 是 flat `cards/scopeOrigin`; silent adapter drift 高。 | parallel_with_guard | JSON schema/codable sample roundtrip + field mapping table，变更时 fail-closed。 |
| ORANGE-MR-05 | device drift 是否有 simulator vs true-device proof tag separation，尤其 voice/a11y/thermal/GPU 与 MLX 并发？ | R5 很容易把 simulator visual proof 推成 mobile/true-device 或 voice readiness。 | future_lane | proof ladder checklist + true-device lane must remain independent until real device receipt exists。 |

## Divergence Forecast
| Candidate | Expected dispute type | Why | Recommended routing |
|---|---|---|---|
| C025 | 口径型 | 有人会认为 no-promotion 是文案问题；ORANGE 认为必须有 checker。 | parallel_with_guard |
| C064-C072/C177 | 混合 | 架构侧会说样例即可；测试侧要求 table-driven terminal fixture + assertions。 | mainline_first |
| C073-C084/C184 | 事实型 | UIUE `activeCells` 与 mainline flat `cards` 当前确实不等形；需字段 verdict。 | mainline_first |
| C120-C125/C198-C215 | 口径型 | model/golden/voice 问题重要，但容易越界关闭 R5 presentation-runtime gate。 | future_lane |
| C130-C135/C160-C164 | 混合 | 部分是 a11y/human policy，部分可静态检查；不能全部写成 unit-test gate。 | human_review |

## Residual Risk
- This is a blind ORANGE test-engineer score, not judge synthesis; duplicate collapse and final priority remain controller-owned.
- I did not run Swift tests because the assigned task is read-only review plus markdown artifact generation; validation here is artifact structure/count checking only.
- Several future-lane candidates are high product risk, but converting them into R5 gates now would inflate proof scope beyond docs/local + unit/simulator evidence.
