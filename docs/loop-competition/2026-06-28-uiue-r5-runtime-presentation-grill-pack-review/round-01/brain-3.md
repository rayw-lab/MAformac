# Brain 3 - Round 01 - BLUE UX/HMI Designer

## Scope And Blindness
- Files read:
  - `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/round-01/brain-3-prompt.md`
  - `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/contract.md`
  - `/Users/wanglei/workspace/MAformac-uiue/docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/candidates-blind.md`
- Forbidden files not read:
  - original grill pack
  - `candidate-map-private.md`
  - other reviewer files
  - judge files
  - ledger
- Proof class: `docs/local + subagent_readonly + BLUE blind scoring`

## Executive Verdict
- status: PASS_WITH_NOTES
- strongest keep clusters: direct-touch/display-only policy, a11y/VoiceOver/readback source, Reduced Motion, terminal UI states, proof-class caps, card hierarchy and active/refused cell priority.
- weakest/rewrite clusters: model/golden/endpoint items often matter but are not BLUE HMI blockers unless they surface as stale UI, false voice readiness, or fake proof.
- merge/drop candidates: many later rows restate earlier schema/proof/terminal/a11y concerns; merge into canonical UX gates rather than keep as parallel tickets.
- missing risks: no explicit occlusion/z-order safe-area gate, no first-run demo operator path, no language-length overflow check, no visible stale-state recovery affordance.

## Scores
| Candidate | Importance | Verifiability | NonDuplication | DecisionLeverage | RiskRevelation | Total | Verdict | Short reason |
|---|---:|---:|---:|---:|---:|---:|---|---|
| C001 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | prevents hidden UI store mutation |
| C002 | 4 | 5 | 4 | 5 | 4 | 22 | Keep | clarifies demo ownership lanes |
| C003 | 3 | 4 | 4 | 4 | 3 | 18 | Keep | avoids label/field drift |
| C004 | 4 | 5 | 4 | 5 | 4 | 22 | Keep | snapshot boundary protects UI |
| C005 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | touch path must be controlled |
| C006 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | user events need closed set |
| C007 | 3 | 4 | 4 | 4 | 4 | 19 | Keep | provenance avoids misleading copy |
| C008 | 5 | 5 | 4 | 5 | 5 | 24 | Keep | copy must not infer scope |
| C009 | 3 | 4 | 4 | 3 | 3 | 17 | Keep | readable state needs enum |
| C010 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | refusal copy differs by cause |
| C011 | 5 | 5 | 5 | 5 | 5 | 25 | Keep | visual state is user contract |
| C012 | 5 | 5 | 4 | 5 | 5 | 24 | Keep | denial must be presentable |
| C013 | 5 | 4 | 5 | 5 | 5 | 24 | Keep | safety display is demo-critical |
| C014 | 5 | 5 | 4 | 5 | 5 | 24 | Keep | no-op cannot look like change |
| C015 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | clamp readback must be honest |
| C016 | 3 | 4 | 4 | 4 | 3 | 18 | Keep | limits multi-intent theatrics |
| C017 | 5 | 4 | 5 | 5 | 5 | 24 | Keep | mixed outcome visibility matters |
| C018 | 3 | 4 | 3 | 3 | 3 | 16 | Keep | macro source affects UX truth |
| C019 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | context display must not become card |
| C020 | 4 | 5 | 4 | 4 | 4 | 21 | Keep | reset must clear visible residue |
| C021 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | avoids fake thinking theater |
| C022 | 5 | 4 | 4 | 5 | 5 | 23 | Keep | interruptions need final UI |
| C023 | 5 | 4 | 4 | 5 | 5 | 23 | Keep | blocks false voice readiness |
| C024 | 3 | 4 | 4 | 3 | 4 | 18 | Keep | trace redaction supports review |
| C025 | 5 | 5 | 4 | 5 | 5 | 24 | Keep | proof cap prevents fake green |
| C026 | 3 | 3 | 4 | 3 | 3 | 16 | DeferFutureLane | LoRA semantics not HMI now |
| C027 | 3 | 4 | 4 | 3 | 3 | 17 | Keep | prevents duplicate range UI |
| C028 | 3 | 4 | 4 | 3 | 3 | 17 | Keep | range source affects controls |
| C029 | 5 | 5 | 4 | 5 | 5 | 24 | Keep | active/refused hierarchy visible |
| C030 | 5 | 5 | 4 | 5 | 5 | 24 | Keep | card schema drives hierarchy |
| C031 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | context/card taxonomy visible |
| C032 | 5 | 4 | 5 | 5 | 5 | 24 | Keep | copy ownership affects trust |
| C033 | 5 | 4 | 4 | 5 | 4 | 22 | Keep | orb must reflect state |
| C034 | 5 | 5 | 5 | 5 | 5 | 25 | Keep | accessibility hard gate |
| C035 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | cross-platform semantics align |
| C036 | 5 | 5 | 4 | 5 | 5 | 24 | Keep | simulator cannot prove feel |
| C037 | 3 | 5 | 4 | 3 | 3 | 18 | Keep | offline constraint affects demo |
| C038 | 3 | 4 | 4 | 3 | 3 | 17 | Keep | avoids memory surprise |
| C039 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | error state must not mask refusal |
| C040 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | separates theme from control |
| C041 | 3 | 4 | 4 | 3 | 4 | 18 | Keep | screenshots are not golden |
| C042 | 2 | 4 | 4 | 2 | 3 | 15 | DeferFutureLane | model choice outside HMI |
| C043 | 3 | 4 | 4 | 3 | 4 | 18 | Keep | copy reuse can leak bias |
| C044 | 5 | 4 | 5 | 5 | 5 | 24 | Keep | a11y cannot vanish |
| C045 | 4 | 5 | 4 | 4 | 4 | 21 | Keep | anchors need proof labels |
| C046 | 4 | 5 | 4 | 4 | 4 | 21 | Keep | receipt protects proof boundary |
| C047 | 3 | 4 | 4 | 3 | 4 | 18 | Keep | prevents merge-ready inflation |
| C048 | 3 | 5 | 4 | 3 | 4 | 19 | Keep | stale review undermines UX proof |
| C049 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | carry-forward avoids dropped blockers |
| C050 | 4 | 4 | 4 | 5 | 4 | 21 | Keep | landing matrix prevents lane blur |
| C051 | 5 | 5 | 3 | 5 | 5 | 23 | Merge | overlaps C030 with sibling detail |
| C052 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | demo controls need provenance |
| C053 | 4 | 4 | 3 | 4 | 4 | 19 | Merge | refine C021 not separate |
| C054 | 3 | 4 | 4 | 4 | 4 | 19 | Keep | outcome mapping affects UI states |
| C055 | 4 | 4 | 3 | 4 | 4 | 19 | Merge | duplicate of refusal taxonomy |
| C056 | 3 | 4 | 4 | 3 | 3 | 17 | Keep | missing scope should clarify |
| C057 | 4 | 4 | 3 | 4 | 4 | 19 | Merge | same family as C010/C055 |
| C058 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | errors need distinct UX |
| C059 | 5 | 4 | 4 | 5 | 5 | 23 | Keep | interruption recovery visible |
| C060 | 5 | 5 | 4 | 5 | 5 | 24 | Keep | silent failure is UX failure |
| C061 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | retry can duplicate visible state |
| C062 | 5 | 5 | 4 | 5 | 5 | 24 | Keep | raw model output unsafe for UI |
| C063 | 3 | 4 | 4 | 3 | 3 | 17 | Keep | source aids review trail |
| C064 | 4 | 5 | 4 | 4 | 4 | 21 | Keep | accepted fixture proves path |
| C065 | 4 | 5 | 4 | 4 | 4 | 21 | Keep | clarify fixture needed |
| C066 | 4 | 5 | 4 | 4 | 4 | 21 | Keep | unsupported fixture needed |
| C067 | 5 | 5 | 4 | 5 | 5 | 24 | Keep | safety fixture visible |
| C068 | 5 | 5 | 4 | 5 | 5 | 24 | Keep | no-op fixture visible |
| C069 | 4 | 5 | 4 | 4 | 4 | 21 | Keep | timeout fixture needed |
| C070 | 4 | 5 | 4 | 4 | 4 | 21 | Keep | cancelled fixture needed |
| C071 | 5 | 5 | 4 | 5 | 5 | 24 | Keep | barge-in fixture needed |
| C072 | 5 | 4 | 4 | 5 | 5 | 23 | Keep | partial outcome is visible |
| C073 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | flat vs active alignment |
| C074 | 5 | 4 | 4 | 5 | 5 | 23 | Keep | sibling mode affects layout |
| C075 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | multiple refusals need display |
| C076 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | scope granularity affects labels |
| C077 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | context channel affects capsule |
| C078 | 5 | 4 | 4 | 5 | 5 | 23 | Keep | readback order affects VO/TTS |
| C079 | 5 | 4 | 4 | 5 | 5 | 23 | Keep | copy priority is HMI core |
| C080 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | empty state must be intentional |
| C081 | 3 | 4 | 4 | 3 | 3 | 17 | Keep | timestamp semantics aid trace |
| C082 | 3 | 4 | 4 | 3 | 3 | 17 | Keep | animation gate may need event |
| C083 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | readback readiness visible |
| C084 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | TTS lifecycle affects HMI |
| C085 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | timeout layers must align |
| C086 | 3 | 4 | 4 | 3 | 3 | 17 | Keep | force event boundary |
| C087 | 5 | 5 | 4 | 5 | 5 | 24 | Keep | tap payload fail-closed |
| C088 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | mic state user-visible |
| C089 | 5 | 4 | 4 | 5 | 5 | 23 | Keep | background must terminalize |
| C090 | 4 | 4 | 3 | 4 | 4 | 19 | Merge | same as think split |
| C091 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | theater duration boundary |
| C092 | 3 | 4 | 4 | 3 | 3 | 17 | Keep | macro source governance |
| C093 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | narration avoids fake call flow |
| C094 | 5 | 5 | 4 | 5 | 5 | 24 | Keep | orb/voice conflict visible |
| C095 | 5 | 5 | 3 | 5 | 5 | 23 | Merge | duplicate of Reduced Motion gate |
| C096 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | GPU effects can harm demo |
| C097 | 4 | 5 | 3 | 4 | 4 | 20 | Merge | proof crosswalk duplicate |
| C098 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | partial absence affects UI |
| C099 | 3 | 4 | 4 | 3 | 3 | 17 | Keep | nil scope must not imply default |
| C100 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | string-key migration risk |
| C101 | 4 | 5 | 4 | 4 | 4 | 21 | Keep | fixture breadth matters |
| C102 | 4 | 5 | 4 | 4 | 5 | 22 | Keep | rename prevents false runtime claim |
| C103 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | proof precedence affects closeout |
| C104 | 3 | 4 | 4 | 4 | 3 | 18 | Keep | shared field discipline |
| C105 | 5 | 5 | 4 | 5 | 5 | 24 | Keep | proof ladder is core guard |
| C106 | 5 | 5 | 4 | 5 | 5 | 24 | Keep | screenshot cannot promote |
| C107 | 4 | 5 | 4 | 4 | 5 | 22 | Keep | non-claims stop fake green |
| C108 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | gates must match touched paths |
| C109 | 3 | 4 | 4 | 3 | 4 | 18 | Keep | stale wording affects claims |
| C110 | 3 | 5 | 4 | 3 | 4 | 19 | Keep | repo status separation |
| C111 | 3 | 4 | 4 | 3 | 3 | 17 | Keep | specs separate per repo |
| C112 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | raw ASR must not become truth |
| C113 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | low confidence affects focus |
| C114 | 5 | 4 | 4 | 5 | 5 | 23 | Keep | context after UX commit |
| C115 | 5 | 4 | 4 | 5 | 5 | 23 | Keep | barge-in stale facts risk |
| C116 | 5 | 4 | 4 | 5 | 5 | 23 | Keep | voice session conflict visible |
| C117 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | voice fallback needed |
| C118 | 5 | 5 | 4 | 5 | 5 | 24 | Keep | unavailable != idle |
| C119 | 5 | 5 | 4 | 5 | 5 | 24 | Keep | mic copy mismatch hurts UX |
| C120 | 3 | 4 | 4 | 3 | 3 | 17 | DeferFutureLane | golden precheck not HMI gate |
| C121 | 3 | 4 | 4 | 3 | 3 | 17 | DeferFutureLane | golden replay later lane |
| C122 | 3 | 4 | 4 | 3 | 4 | 18 | Keep | storyboard copy reuse risk |
| C123 | 2 | 4 | 4 | 2 | 3 | 15 | DeferFutureLane | model proof separation later |
| C124 | 2 | 3 | 4 | 2 | 3 | 14 | DeferFutureLane | sampling not BLUE gate |
| C125 | 3 | 3 | 4 | 3 | 3 | 16 | DeferFutureLane | prewarm affects demo latency later |
| C126 | 2 | 4 | 4 | 2 | 3 | 15 | Drop | external H5 not HMI burndown |
| C127 | 2 | 4 | 4 | 2 | 3 | 15 | Drop | teardown inspiration only |
| C128 | 3 | 4 | 4 | 3 | 4 | 18 | Keep | asset provenance affects UI |
| C129 | 2 | 4 | 4 | 2 | 3 | 15 | Drop | external issue not local proof |
| C130 | 5 | 5 | 5 | 5 | 5 | 25 | Keep | read-only affordance is crucial |
| C131 | 5 | 4 | 5 | 5 | 5 | 24 | Keep | direct-control policy needed |
| C132 | 5 | 5 | 5 | 5 | 5 | 25 | Keep | gear touch safety critical |
| C133 | 5 | 5 | 5 | 5 | 5 | 25 | Keep | mobile/a11y proof ladder |
| C134 | 4 | 4 | 5 | 4 | 5 | 22 | Keep | visual threshold cannot fake pass |
| C135 | 3 | 4 | 5 | 3 | 3 | 18 | Keep | visual taste lane separation |
| C136 | 3 | 4 | 3 | 3 | 3 | 16 | Merge | outcome priority duplicate |
| C137 | 3 | 4 | 3 | 3 | 3 | 16 | Merge | source fill duplicate |
| C138 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | terminal state affects UI |
| C139 | 4 | 4 | 3 | 4 | 4 | 19 | Merge | empty cards duplicate |
| C140 | 5 | 4 | 3 | 5 | 5 | 22 | Merge | readback order duplicate |
| C141 | 5 | 4 | 3 | 5 | 5 | 22 | Merge | copy priority duplicate |
| C142 | 3 | 4 | 4 | 3 | 3 | 17 | Keep | trace consistency useful |
| C143 | 3 | 4 | 4 | 3 | 3 | 17 | Keep | trace order aids diagnosis |
| C144 | 3 | 4 | 3 | 3 | 3 | 16 | Merge | timestamp duplicate |
| C145 | 5 | 4 | 3 | 5 | 5 | 22 | Merge | cancel/interruption duplicate |
| C146 | 5 | 5 | 3 | 5 | 5 | 23 | Merge | cardTap duplicate |
| C147 | 4 | 4 | 3 | 4 | 4 | 19 | Merge | mic state duplicate |
| C148 | 5 | 5 | 3 | 5 | 5 | 23 | Merge | orb/voice duplicate |
| C149 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | display caps affect claims |
| C150 | 4 | 5 | 4 | 4 | 4 | 21 | Keep | unknown proof fail-closed |
| C151 | 3 | 3 | 4 | 3 | 3 | 16 | DeferFutureLane | readiness API future-facing |
| C152 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | mirrored scope reason |
| C153 | 3 | 4 | 3 | 3 | 3 | 16 | Merge | scope nil duplicate |
| C154 | 4 | 5 | 3 | 4 | 4 | 20 | Merge | proof enum crosswalk duplicate |
| C155 | 5 | 5 | 5 | 5 | 5 | 25 | Keep | operator review not product acceptance |
| C156 | 4 | 4 | 3 | 4 | 4 | 19 | Merge | proof precedence duplicate |
| C157 | 5 | 4 | 4 | 5 | 5 | 23 | Keep | partial UI needs per-cell data |
| C158 | 5 | 4 | 3 | 5 | 5 | 22 | Merge | copy source duplicate |
| C159 | 5 | 5 | 5 | 5 | 5 | 25 | Keep | no-op vs accepted a11y |
| C160 | 5 | 5 | 5 | 5 | 5 | 25 | Keep | card labels need semantics |
| C161 | 5 | 5 | 5 | 5 | 5 | 25 | Keep | control a11y range/hint |
| C162 | 5 | 5 | 5 | 5 | 5 | 25 | Keep | mic wording mismatch obvious |
| C163 | 4 | 5 | 5 | 4 | 4 | 22 | Keep | context capsule VO coverage |
| C164 | 5 | 5 | 5 | 5 | 5 | 25 | Keep | overlay focus/escape gate |
| C165 | 5 | 4 | 4 | 5 | 5 | 23 | Keep | cancelled needs announcement |
| C166 | 4 | 4 | 3 | 4 | 4 | 19 | Merge | runtime error duplicate |
| C167 | 5 | 5 | 3 | 5 | 5 | 23 | Merge | Reduced Motion duplicate |
| C168 | 4 | 4 | 3 | 4 | 4 | 19 | Merge | string-key duplicate |
| C169 | 5 | 5 | 5 | 5 | 5 | 25 | Keep | focus priority in mixed active |
| C170 | 4 | 5 | 4 | 4 | 4 | 21 | Keep | counterexample fixtures valuable |
| C171 | 5 | 5 | 3 | 5 | 5 | 23 | Merge | screenshot promotion duplicate |
| C172 | 5 | 5 | 4 | 5 | 5 | 24 | Keep | display-only a11y wording |
| C173 | 5 | 5 | 3 | 5 | 5 | 23 | Merge | a11y ladder duplicate |
| C174 | 5 | 4 | 5 | 5 | 5 | 24 | Keep | refusal lifecycle conflict |
| C175 | 5 | 4 | 5 | 5 | 5 | 24 | Keep | mock voice contradiction visible |
| C176 | 3 | 4 | 2 | 3 | 3 | 15 | Merge | ToolError mapping duplicate |
| C177 | 4 | 5 | 2 | 4 | 4 | 19 | Merge | terminal fixture duplicate |
| C178 | 4 | 4 | 3 | 4 | 4 | 19 | Merge | partial canonical duplicate |
| C179 | 4 | 5 | 4 | 4 | 4 | 21 | Keep | raw enum leak risk |
| C180 | 4 | 4 | 3 | 4 | 4 | 19 | Merge | displayCaps duplicate |
| C181 | 4 | 4 | 2 | 4 | 4 | 18 | Merge | think split duplicate |
| C182 | 4 | 4 | 3 | 4 | 4 | 19 | Merge | event kind duplicate |
| C183 | 4 | 4 | 3 | 4 | 4 | 19 | Merge | force context duplicate |
| C184 | 5 | 4 | 3 | 5 | 5 | 22 | Merge | active/sibling duplicate |
| C185 | 5 | 5 | 4 | 5 | 5 | 24 | Keep | no-op revision proof |
| C186 | 5 | 4 | 5 | 5 | 5 | 24 | Keep | stale async UI mutation |
| C187 | 5 | 5 | 5 | 5 | 5 | 25 | Keep | terminal transition invariant |
| C188 | 4 | 5 | 3 | 4 | 5 | 21 | Merge | runtime-driven wording duplicate |
| C189 | 5 | 5 | 4 | 5 | 5 | 24 | Keep | proof lanes must stay separate |
| C190 | 3 | 3 | 4 | 3 | 3 | 16 | DeferFutureLane | C6 thaw later |
| C191 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | voice first gate not UI state |
| C192 | 2 | 4 | 3 | 2 | 3 | 14 | Drop | external copy checklist low HMI |
| C193 | 5 | 5 | 5 | 5 | 5 | 25 | Keep | visual levels tied to proof cap |
| C194 | 5 | 5 | 3 | 5 | 5 | 23 | Merge | direct touch policy duplicate |
| C195 | 3 | 5 | 4 | 3 | 4 | 19 | Keep | dirty residual must be visible |
| C196 | 4 | 4 | 4 | 4 | 4 | 20 | Keep | validation gate by touch type |
| C197 | 3 | 3 | 4 | 3 | 3 | 16 | Spike | parser repair UX needs spike |
| C198 | 3 | 4 | 3 | 3 | 3 | 16 | Merge | golden precheck duplicate |
| C199 | 3 | 4 | 3 | 3 | 3 | 16 | Merge | golden replay duplicate |
| C200 | 5 | 5 | 4 | 5 | 5 | 24 | Keep | no-op not success delta |
| C201 | 5 | 4 | 4 | 5 | 5 | 23 | Keep | partial readback per cell |
| C202 | 3 | 3 | 4 | 3 | 3 | 16 | DeferFutureLane | voice memory seeds later |
| C203 | 5 | 4 | 3 | 5 | 5 | 22 | Merge | TTS/UX commit duplicate |
| C204 | 4 | 4 | 3 | 4 | 4 | 19 | Merge | raw ASR duplicate |
| C205 | 5 | 4 | 4 | 5 | 5 | 23 | Keep | low-confidence voice fixture |
| C206 | 5 | 4 | 3 | 5 | 5 | 22 | Merge | TTS/recording duplicate |
| C207 | 2 | 3 | 4 | 2 | 3 | 14 | DeferFutureLane | endpoint stats outside HMI |
| C208 | 3 | 4 | 4 | 3 | 4 | 18 | Keep | dev-only proof label matters |
| C209 | 2 | 3 | 3 | 2 | 3 | 13 | Merge | sampling duplicate |
| C210 | 3 | 3 | 3 | 3 | 3 | 15 | Merge | prewarm duplicate |
| C211 | 3 | 4 | 3 | 3 | 4 | 17 | Merge | copy-to-training duplicate |
| C212 | 3 | 4 | 4 | 3 | 4 | 18 | Keep | planned_not_golden label |
| C213 | 5 | 5 | 4 | 5 | 5 | 24 | Keep | unknown proof fail-closed |
| C214 | 5 | 5 | 4 | 5 | 5 | 24 | Keep | finality blocks stale UI |
| C215 | 3 | 4 | 4 | 3 | 4 | 18 | Keep | local shape vs model quality |

## Candidate Notes
| Candidate | Action | Route | Note |
|---|---|---|---|
| C001 | keep | parallel_with_guard | keep as UI store-boundary guard |
| C002 | keep | parallel_with_guard | lane taxonomy is needed before UX burndown |
| C003 | keep | mainline_first | field names should come from carrier |
| C004 | keep | parallel_with_guard | snapshot-only presentation is core HMI boundary |
| C005 | keep | uiue_first_main_after | touch/event write path needs executor boundary |
| C006 | keep | mainline_first | closed event set protects all UI states |
| C007 | keep | mainline_first | provenance/source split protects copy truth |
| C008 | keep | parallel_with_guard | structured scope is a BLUE hard gate |
| C009 | keep | mainline_first | machine-readable enum prevents vague UI |
| C010 | keep | parallel_with_guard | user refusal reason must be differentiated |
| C011 | keep | uiue_first_main_after | visual mapping deserves own UI gate |
| C012 | keep | parallel_with_guard | denial snapshot must be safe to show |
| C013 | keep | uiue_first_main_after | active/refused/safety display is customer-visible |
| C014 | keep | parallel_with_guard | already-state must read as no-op |
| C015 | keep | parallel_with_guard | clamp copy must show actual value |
| C016 | keep | mainline_first | constrains expected demo capability |
| C017 | keep | parallel_with_guard | partial mixed state requires per-cell HMI |
| C018 | keep | mainline_first | macro source should not hide in UIUE |
| C019 | keep | uiue_first_main_after | context capsule cannot look like car control |
| C020 | keep | uiue_first_main_after | reset must remove all visible residue |
| C021 | keep | uiue_first_main_after | thinking should be event-driven |
| C022 | keep | parallel_with_guard | every abort path needs terminal UI |
| C023 | keep | human_review | voice proof must be separated from text backend |
| C024 | keep | mainline_first | trace redaction supports safe review |
| C025 | keep | parallel_with_guard | proof cap is high leverage |
| C026 | defer | future_lane | semantic feeling lane is later, not R5 HMI blocker |
| C027 | keep | mainline_first | reuse normalization/range contract |
| C028 | keep | mainline_first | range source affects control affordance |
| C029 | keep | uiue_first_main_after | active/refused priority drives visual hierarchy |
| C030 | keep | parallel_with_guard | card schema must carry HMI semantics |
| C031 | keep | uiue_first_main_after | family taxonomy impacts scanability |
| C032 | keep | parallel_with_guard | dialogue/copy source must be governed |
| C033 | keep | uiue_first_main_after | orb cannot be decorative only |
| C034 | keep | uiue_first | Reduced Motion non-animation channel required |
| C035 | keep | parallel_with_guard | platform layout may differ, semantics cannot |
| C036 | keep | human_review | true device lane needed for feel/audio/perf |
| C037 | keep | mainline_first | offline/no-Python affects demo promise |
| C038 | keep | uiue_first_main_after | memory boundary shapes user expectations |
| C039 | keep | parallel_with_guard | unknown/crash state cannot mask refusal |
| C040 | keep | uiue_first_main_after | settings UI must not imply runtime control |
| C041 | keep | merge_only | scripted runs are candidate evidence only |
| C042 | defer | future_lane | model comparison is outside BLUE lane |
| C043 | keep | human_review | copy-to-training requires explicit contract |
| C044 | keep | uiue_first | accessibility deferred still needs ledger line |
| C045 | keep | uiue_first | screenshot anchors need proof/source naming |
| C046 | keep | parallel_with_guard | receipts should include residual and proof class |
| C047 | keep | merge_only | wording must not say merged/ready |
| C048 | keep | merge_only | reviewer evidence needs live head |
| C049 | keep | parallel_with_guard | carry-forward prevents hidden HMI debt |
| C050 | keep | parallel_with_guard | landing matrix avoids duplicated UX work |
| C051 | merge | merge_only | merge into C030 as sibling/secondary detail |
| C052 | keep | parallel_with_guard | force-state input must be visibly demo-scoped |
| C053 | merge | merge_only | merge into C021 as think-state exception |
| C054 | keep | mainline_first | mapping table informs UI terminal states |
| C055 | merge | merge_only | merge with C010/C057 refusal taxonomy |
| C056 | keep | mainline_first | missing scope should become clarify UX |
| C057 | merge | merge_only | merge into refusal taxonomy cluster |
| C058 | keep | mainline_first | runtime error subtype affects visible recovery |
| C059 | keep | parallel_with_guard | cancellation and interruption differ for user |
| C060 | keep | mainline_first | throw path still needs terminal presentation |
| C061 | keep | mainline_first | retry idempotency protects visible state |
| C062 | keep | parallel_with_guard | never show raw model output |
| C063 | keep | mainline_first | source preservation helps explain accepted path |
| C064 | keep | mainline_first | accepted snapshot fixture required |
| C065 | keep | mainline_first | clarify snapshot fixture required |
| C066 | keep | mainline_first | unsupported snapshot fixture required |
| C067 | keep | parallel_with_guard | safety snapshot fixture required |
| C068 | keep | parallel_with_guard | no-op snapshot fixture required |
| C069 | keep | mainline_first | timeout snapshot fixture required |
| C070 | keep | mainline_first | cancelled snapshot fixture required |
| C071 | keep | parallel_with_guard | barge-in snapshot fixture required |
| C072 | keep | parallel_with_guard | partial fixture or local-only flag required |
| C073 | keep | parallel_with_guard | cards/activeCells alignment affects UI adapter |
| C074 | keep | parallel_with_guard | sibling/mode expression is HMI-critical |
| C075 | keep | parallel_with_guard | multiple refused cells need display model |
| C076 | keep | mainline_first | scope origin granularity needs decision |
| C077 | keep | parallel_with_guard | context channel affects non-control facts |
| C078 | keep | parallel_with_guard | readback order affects TTS/VO |
| C079 | keep | parallel_with_guard | copy priority is a user-facing contract |
| C080 | keep | uiue_first_main_after | empty cards need visible empty-state rules |
| C081 | keep | mainline_first | timestamp meaning supports review |
| C082 | keep | mainline_first | changing event may drive transition timing |
| C083 | keep | mainline_first | readback ready may gate speech/UI |
| C084 | keep | parallel_with_guard | TTS events need lifecycle placement |
| C085 | keep | parallel_with_guard | timeout needs event/result/snapshot alignment |
| C086 | keep | mainline_first | force context event needs explicit kind |
| C087 | keep | parallel_with_guard | cardTap payload must fail closed |
| C088 | keep | parallel_with_guard | mic events should align with voiceState |
| C089 | keep | parallel_with_guard | background/resume must not leave running UI |
| C090 | merge | merge_only | merge into C021/C053 think typing |
| C091 | keep | uiue_first_main_after | duration policy avoids fake theatrics |
| C092 | keep | mainline_first | UIUE should not judge macro semantics |
| C093 | keep | uiue_first_main_after | narration fields prevent fake calling script |
| C094 | keep | uiue_first_main_after | orb vs voice conflict needs precedence |
| C095 | merge | merge_only | merge into C034 Reduced Motion gate |
| C096 | keep | uiue_first | GPU/shader budget affects live demo feel |
| C097 | merge | merge_only | merge into C105 proof ladder |
| C098 | keep | parallel_with_guard | partial absence must be resolved |
| C099 | keep | mainline_first | nil scope cannot mean defaulted |
| C100 | keep | parallel_with_guard | string-key migration can silently break UI |
| C101 | keep | mainline_first | fixture coverage covers visible outcomes |
| C102 | keep | merge_only | wording should say fixture-driven if no logs |
| C103 | keep | parallel_with_guard | matrix vs snapshot proof precedence needed |
| C104 | keep | mainline_first | shared fields need mainline verdict |
| C105 | keep | parallel_with_guard | proof ladder should be explicit |
| C106 | keep | uiue_first | machine guard prevents screenshot promotion |
| C107 | keep | parallel_with_guard | non-claims checkbox protects closeout |
| C108 | keep | parallel_with_guard | validation should follow touched surface |
| C109 | keep | merge_only | stale wording grep protects status language |
| C110 | keep | parallel_with_guard | dirty status must stay per repo |
| C111 | keep | parallel_with_guard | strict checks per repo prevent false alignment |
| C112 | keep | mainline_first | raw ASR only trace, not authority |
| C113 | keep | mainline_first | confidence gate affects focus update |
| C114 | keep | parallel_with_guard | assistant context should follow committed UX |
| C115 | keep | parallel_with_guard | barge-in must not seed stale facts |
| C116 | keep | parallel_with_guard | recording/TTS must be mutually exclusive |
| C117 | keep | human_review | real voice fallback is user-visible |
| C118 | keep | uiue_first_main_after | unavailable and idle need different UI |
| C119 | keep | uiue_first | mic interaction copy must match behavior |
| C120 | defer | future_lane | golden setup is lower BLUE leverage |
| C121 | defer | future_lane | replay assertions are later-lane |
| C122 | keep | human_review | script text should not become dataset silently |
| C123 | defer | future_lane | C6 model quality not R5 HMI |
| C124 | defer | future_lane | sampling split outside UX review |
| C125 | defer | future_lane | prewarm affects latency but needs later proof |
| C126 | drop | reject_duplicate | not MAformac SSOT; only cautionary |
| C127 | drop | reject_duplicate | local teardown inspiration only |
| C128 | keep | human_review | external assets affect UI provenance |
| C129 | drop | reject_duplicate | external issue cannot verify local UX |
| C130 | keep | uiue_first | display-only direct touch must be unmistakable |
| C131 | keep | human_review | summary control policy needs product choice |
| C132 | keep | human_review | gear touch default should be display-only |
| C133 | keep | human_review | mobile/a11y/44pt proof must be separate |
| C134 | keep | uiue_first | visual threshold should stay WARN if unproven |
| C135 | keep | human_review | final-art taste should not block R5 dispatch |
| C136 | merge | merge_only | merge with C014/C152 outcome priority |
| C137 | merge | merge_only | merge with C063 behavior source |
| C138 | keep | mainline_first | terminal derivation affects UI certainty |
| C139 | merge | merge_only | merge with C080 empty cards |
| C140 | merge | merge_only | merge with C078 readback order |
| C141 | merge | merge_only | merge with C079 copy priority |
| C142 | keep | mainline_first | trace ID consistency helps proof trail |
| C143 | keep | mainline_first | append-only trace reduces dispute |
| C144 | merge | merge_only | merge with C081 timestamp semantics |
| C145 | merge | merge_only | merge with C059 cancel/interruption |
| C146 | merge | merge_only | merge with C087 cardTap payload |
| C147 | merge | merge_only | merge with C088 mic events |
| C148 | merge | merge_only | merge with C094 orb/voice conflict |
| C149 | keep | mainline_first | displayCaps empty must be contract or temporary |
| C150 | keep | parallel_with_guard | unknown proof must fail closed |
| C151 | defer | future_lane | readiness claim API is not current HMI |
| C152 | keep | mainline_first | scope failure reason mirroring matters |
| C153 | merge | merge_only | merge with C099 scope nil |
| C154 | merge | merge_only | merge with C097/C105 proof crosswalk |
| C155 | keep | human_review | operatorReview must not appear as acceptance |
| C156 | merge | merge_only | merge with C103 proof precedence |
| C157 | keep | parallel_with_guard | mixed outcome needs per-cell payload |
| C158 | merge | merge_only | merge with C079/C141 copy source |
| C159 | keep | uiue_first | a11y must distinguish no-op and accepted |
| C160 | keep | uiue_first | card accessibility label needs semantics |
| C161 | keep | uiue_first | direct controls need range/value/hint |
| C162 | keep | uiue_first | tap vs hold mismatch is visible |
| C163 | keep | uiue_first | context capsule should read meaningful facts |
| C164 | keep | uiue_first | overlay escape/focus return is essential |
| C165 | keep | parallel_with_guard | cancel normal mapping still needs announcement |
| C166 | merge | merge_only | merge with C058 runtime error taxonomy |
| C167 | merge | merge_only | merge with C034/C095 Reduced Motion |
| C168 | merge | merge_only | merge with C100 string-key migration |
| C169 | keep | uiue_first | multiple active cells need focus priority |
| C170 | keep | uiue_first | counterexamples cover missing HMI edge cases |
| C171 | merge | merge_only | merge with C106 screenshot no-promotion |
| C172 | keep | uiue_first | display-only controls need VO wording |
| C173 | merge | merge_only | merge with C133 accessibility proof ladder |
| C174 | keep | uiue_first_main_after | safety refusal lifecycle can contradict itself |
| C175 | keep | uiue_first | mock voice contradiction must be labeled |
| C176 | merge | merge_only | merge with C054 ToolExecutionError mapping |
| C177 | merge | merge_only | merge with C064-C072 terminal fixtures |
| C178 | merge | merge_only | merge with C098 partial canonical decision |
| C179 | keep | mainline_first | proof enum translation avoids raw leak |
| C180 | merge | merge_only | merge with C149 displayCaps decision |
| C181 | merge | merge_only | merge with C021/C053 think semantics |
| C182 | merge | merge_only | merge with C082-C084 event kinds |
| C183 | merge | merge_only | merge with C052 force context |
| C184 | merge | merge_only | merge with C074 active/sibling cells |
| C185 | keep | parallel_with_guard | no-op proof needs revision/readback evidence |
| C186 | keep | parallel_with_guard | stale async mutation is a visible defect |
| C187 | keep | parallel_with_guard | terminal transition invariant prevents zombie UI |
| C188 | merge | merge_only | merge with C102 runtime-driven wording |
| C189 | keep | parallel_with_guard | voice/golden/model lanes must stay separate |
| C190 | defer | future_lane | C6 thaw depends on bridge completion |
| C191 | keep | human_review | voice lane starts with real function spike |
| C192 | drop | reject_duplicate | external copy checklist repeats provenance guard |
| C193 | keep | parallel_with_guard | visual proof levels must cap claims |
| C194 | merge | merge_only | merge with C130-C132 direct touch policy |
| C195 | keep | parallel_with_guard | closeout must show both repo residuals |
| C196 | keep | parallel_with_guard | validation gate changes by touched files |
| C197 | spike | spike_required | parser fallback UX needs exploration |
| C198 | merge | merge_only | merge with C120 golden precheck |
| C199 | merge | merge_only | merge with C121 golden replay |
| C200 | keep | parallel_with_guard | already-state sample must not count delta |
| C201 | keep | parallel_with_guard | partial readback needs per-cell split |
| C202 | defer | future_lane | voice memory seeds need later decision |
| C203 | merge | merge_only | merge with C114/C115 context commit |
| C204 | merge | merge_only | merge with C112 raw ASR |
| C205 | keep | parallel_with_guard | low-confidence ASR must not prove voice-ready |
| C206 | merge | merge_only | merge with C116 session exclusivity |
| C207 | defer | future_lane | endpoint decode stats outside HMI lane |
| C208 | keep | merge_only | dev-only proof label prevents iOS inflation |
| C209 | merge | merge_only | merge with C124 sampling split |
| C210 | merge | merge_only | merge with C125 prewarm hash |
| C211 | merge | merge_only | merge with C122 copy-to-dataset guard |
| C212 | keep | merge_only | planned_not_golden label is useful |
| C213 | keep | parallel_with_guard | unknown fixture proof must fail closed |
| C214 | keep | parallel_with_guard | terminal finality prevents stale async cards |
| C215 | keep | future_lane | distinguish local shape from model quality |

## Merge / Rewrite / Drop Log
| Candidate(s) | Proposed action | Reason |
|---|---|---|
| C051 -> C030 | Merge | sibling/secondary fields are card-schema details, not separate UX workstream |
| C053, C090, C181 -> C021 | Merge | all ask for typed think semantics and theater boundary |
| C055, C057 -> C010 | Merge | refusal taxonomy should be one canonical decision |
| C095, C167 -> C034 | Merge | Reduced Motion should have one hard accessibility gate |
| C097, C154 -> C105 | Merge | proof crosswalk belongs to one proof ladder item |
| C140, C141, C158 -> C078/C079 | Merge | readback/copy priority should be a single HMI copy-source contract |
| C145-C148 -> C059/C087/C088/C094 | Merge | duplicate event and conflict-detail variants |
| C171 -> C106 | Merge | screenshot no-promotion is the same risk |
| C176-C178 -> C054/C064-C072/C098 | Merge | outcome fixture/mapping duplicates |
| C194 -> C130-C132 | Merge | direct touch policy should be one visible-control cluster |
| C198-C199 -> C120-C121 | Merge | golden precheck/replay duplicates |
| C203-C206 -> C112/C114-C116 | Merge | voice context and ASR/TTS lifecycle duplicates |
| C126, C127, C129, C192 | Drop | external inspiration/provenance cautions are low leverage for BLUE blind HMI scoring |

## Missing Risks Added By This Persona
| Proposed ID | Question | Why it matters | Suggested route | Verification |
|---|---|---|---|---|
| BLUE-M01 | Expanded overlays, orb, MicDock, banners, and cards must have z-order/safe-area rules so critical readback and cancel affordances are never occluded. | The candidate set covers focus return but not visual occlusion or safe-area conflict. | uiue_first | simulator screenshot matrix + manual visual review, proof capped at simulator/local |
| BLUE-M02 | Long Chinese readbacks, refusal reasons, and scope labels need truncation/wrapping rules for Mac and iOS. | Demo copy can be correct yet visually broken or overlap controls. | uiue_first | fixed text fixtures across narrow/wide breakpoints |
| BLUE-M03 | The first-run operator path needs one visible state checklist: reset done, proof class, voice unavailable/idle, display-only controls. | A clean customer demo depends on operator-readable readiness, not only backend state. | human_review | docs checklist + local UI screenshot, not runtime acceptance |
| BLUE-M04 | Stale terminal state recovery must have visible user affordance: retry, reset, or explain non-action. | Terminal correctness without recovery can still feel broken in a live demo. | parallel_with_guard | terminal fixture screenshots and VO labels |
| BLUE-M05 | High-contrast and color-only state encoding must be checked separately from Reduced Motion. | Reduced Motion does not cover color blindness, contrast, or non-color state recognition. | uiue_first | static contrast audit + screenshot fixture labels |

## Divergence Forecast
| Candidate | Expected dispute type | Why | Recommended routing |
|---|---|---|---|
| C023 | 混合 | Engineers may treat text backend as enough; BLUE needs real ASR/TTS proof separation. | human_review |
| C034 | 口径型 | Some may call accessibility deferred; BLUE treats non-animation equivalent as current gate. | uiue_first |
| C130-C132 | 混合 | Product may want touchable controls; safety/affordance policy is unresolved. | human_review |
| C155 | 口径型 | `operatorReview` may be misread as acceptance or product UI state. | human_review |
| C174-C175 | 事实型 | Mock voice/orb contradictions require source-level verification before closeout. | uiue_first_main_after |
| C189 | 口径型 | Proof lanes are easy to collapse in closeout language. | parallel_with_guard |

## Residual Risk
- This review did not read source-pool authority files; scores are based on blind candidate text plus contract boundaries only.
- BLUE ranking intentionally favors user-visible correctness over backend completeness, so some model/golden/endpoint items are deferred even if they are important elsewhere.
- Several `Merge` items should not be dropped from implementation; they should be merged into a smaller set of enforceable UX/HMI gates.
