<!--
DRAFT SKELETON (2026-06-23) — delta 占位待补，人审定 propose 时细化 Requirement/Scenario。
本 delta ADDED 新 capability `voice-pipeline`（target: openspec/specs/voice-pipeline/spec.md，new_file）。
方向锚（cascade-inventory T1 new_file + asr-alignment-research D14 + ASR amend + U6/U19/U28/U30）：
  - ASRBackend 抽象 = 系统 SFSpeechRecognizer 主 + WhisperKit/sherpa fallback(不砍)。
  - AVSpeechSynthesizer 系统朗读(中文 TTS preflight U28)。
  - promptTokens + usePrefillPrompt 热词(非 contextualStrings)；SpeechTextNormalizer 层；8 态机。
  - 端侧不跑 post-ASR LLM 纠错；ASR 属 C7 不当 C6 硬门。
  - iOS18 API 必 #available(U19/U30)；U6 麦克风 key + memory entitlement。
  - 作 C1-C3 上游契约。
-->

## ADDED Requirements

### Requirement: voice pipeline SHALL abstract ASR backend with system-primary and fallback
voice-pipeline SHALL 经 ASRBackend 抽象，系统 SFSpeechRecognizer 主 + WhisperKit/sherpa fallback（不砍）；热词 SHALL 用 promptTokens + usePrefillPrompt（非 contextualStrings）；SHALL 含 SpeechTextNormalizer 层 + 8 态机；端侧 SHALL NOT 跑 post-ASR LLM 纠错；ASR SHALL NOT 当 C6 硬门（属 C7）。
> DRAFT 占位 — Requirement/Scenario 待人审 propose 时按 D14 + ASR amend + cascade-inventory T1 voice-pipeline verdict 填实。

#### Scenario: ASR backend abstraction with fallback (placeholder)
- **GIVEN** DRAFT 骨架（占位 Scenario，待 propose 填实）
- **WHEN** 人审定 propose
- **THEN** 在此填实 Scenario（系统主+fallback 切换、promptTokens 热词、8 态机转移、normalizer）

### Requirement: voice pipeline SHALL use system TTS with iOS18 availability guards
TTS SHALL 用 AVSpeechSynthesizer 系统朗读 + 中文 TTS preflight；iOS18 API SHALL 用 `#available` 保护；App 工程前置 SHALL 含麦克风 NSMicrophoneUsageDescription key + memory entitlement（U6 demo-blocker）。
> DRAFT 占位 — Requirement/Scenario 待人审 propose 时按 U28/U19/U30/U6 填实。

#### Scenario: System TTS preflight and availability guards (placeholder)
- **GIVEN** DRAFT 骨架（占位 Scenario，待 propose 填实）
- **WHEN** 人审定 propose
- **THEN** 在此填实 Scenario（AVSpeechSynthesizer 朗读、中文 preflight、#available 保护、麦克风 key preflight）
