# R5 D25 K1 Voice Proof Boundary Receipt

label: UIUE_R5_D25_K1_SPIKE_LEDGER_FOUR_GATE_SUPERTRAIN
gate: D25_GATE_3_VOICE_PROOF_BOUNDARY
row: C117
status: DONE
proof_class: docs_local + local_static + runtime_probe

## 结论

C117 为 `PASS / future_lane`。本机 macOS `say -v '?'` 能枚举中文语音，且 Core 已有最小 `AVSpeechSynthesisEngine(language: "zh-CN")`；但这只证明本机语音枚举和代码边界，不证明 premium Mandarin、iOS true-device TTS、ASR、barge-in、首响、听感或 voice-ready。D25 只落 no-promotion boundary。

## Local Voice Probe

captured_at: 2026-06-30 17:38:02 CST
surface: macOS 26.6 / Build 25G5028f
command:

```bash
sw_vers
say -v '?' | rg -i 'zh_|zh-|chinese|mandarin|yue|ting|mei|sin-ji|Chinese|普通|粤'
```

observed voices included:

- zh_CN: Eddy, Flo, Grandma, Grandpa, Reed, Rocko, Sandy, Shelley, Tingting
- zh_TW: Eddy, Flo, Grandma, Grandpa, Meijia, Reed, Rocko, Sandy, Shelley
- zh_HK: Sinji

This is runtime_probe only for local macOS voice inventory. It is not iOS true-device proof and not product voice readiness.

## Evidence

| evidence | location | proves |
|---|---|---|
| Project voice route uses ASRBackend abstraction, system SFSpeechRecognizer primary, fallback retained. | `CLAUDE.md:88-90`, `:101` | Voice pipeline is broader than TTS enum. |
| Core TTS wrapper selects `AVSpeechSynthesisVoice(language: "zh-CN")`. | `Core/Voice/SpeechSynthesisEngine.swift:15-19` | Current code has a minimal TTS call surface, not premium preflight/fallback proof. |
| Runtime session sets `voiceState` from dialog text. | `Core/Execution/DemoRuntimeSessionRunner.swift:73-87` | `voiceState` is presentation state, not TTS/ASR readiness. |
| Voice-pipeline spec is a draft skeleton with future system TTS preflight. | `openspec/changes/define-demo-golden-run-and-voice/specs/voice-pipeline/spec.md:1-31` | Voice preflight/fallback requirements are not final implementation proof. |
| Bridge design forbids local/static/docs proof from displaying voice-ready. | `openspec/changes/define-runtime-presentation-bridge/design.md:38-40`, `:67-69` | Proof cap blocks voice-ready upgrade. |
| K1 matrix marks C117 as spike_required. | `docs/loop-competition/2026-06-28-uiue-r5-runtime-presentation-grill-pack-review/final-grill-matrix.md:177` | Needs separate voice lane evidence. |

## Harness

- skills_ledger: executing-plans, pre-mortem, bug-iceberg-teardown, OpenSpec, GitNexus stale-static context, local voice CLI oracle.
- lessons_learned: D20-D24 proof cap must keep `voiceState`/mock/simulator separate from true voice proof.
- metacognitive_check: 避免把“本机中文 voice exists”当成“premium Mandarin fallback ready”。
- pre_mortem: If C117 is upgraded now,现场可能遇到目标设备无 premium voice、首响慢、TTS/录音互斥、ASR 权限或 fallback 缺失，但 receipt 已错误写绿。
- iceberg_teardown: visible symptom 是 premium voice preflight；deeper class 是 display state、TTS inventory、ASR/TTS pipeline、true-device acceptance 四层混淆。
- local_search: `rg -n "voice-ready|voice_ready|ASR|TTS|AVSpeech|SFSpeech|voiceState|premium|fallback|C117"`; `say -v '?'` local probe.
- external_or_official_truth: local CLI/runtime probe only; no web docs needed for D25 no-promotion classification.
- goal_drift_check: no voice readiness, no golden run, no mobile/true-device, no live API, no UIUE merge.
- authority_check: governed by `CLAUDE.md`, voice-pipeline draft, runtime-presentation-bridge proof caps, K1 matrix.
- claim_vs_proof_check: runtime_probe proves local macOS voice inventory only; not voice_ready, true_device, mobile, S-PASS, V-PASS, or R5 complete.
- boundary_check: no code/spec edit; no audio playback acceptance claimed.
- self_question: If this were wrong, a target-device voice preflight with identifier, fallback path, ASR/TTS permissions, interruption behavior, and human listening verdict would prove it.

## Row Verdict

| row_id | status | proof_class | promotion_decision | residual |
|---|---|---|---|---|
| C117 | PASS | docs_local + local_static + runtime_probe | future_lane | Future voice lane must define premium Mandarin identifier/fallback, true-device TTS/ASR proof, and no-promotion wording. |
