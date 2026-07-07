status: `draft_deferred`
status_source: `D-115/N4`
status_updated: `2026-07-07`

> ⚠️ DRAFT SKELETON（2026-06-23 第一个长跑起草，标 DRAFT 待人审 propose）
> 本 change 仅为骨架：proposal Why/What Changes 指向已拍决策，specs delta 占位待补，tasks 待细化。
> **守 agree-before-build：人审定 propose 前不进 apply、不写实现代码。** 决策权威源见下。
>
> 🔴🔴 **DEFERRED 延后整体（磊哥 2026-06-23「训练 + 后端开发延后」决策）**：本 change（demo 炸场合同回放 + voice ASR/TTS/VAD）= **纯后端/交付层，整体延后不排期，A2 之后独立重新立项**。**不在 A2**（A2 = code-only 范式对齐，终点落老 C5 LoRA 训练前）。

## Why

demo 现场炸场剧本（demo-golden-run）+ 语音链路（voice-pipeline）+ UIUE 决策（U1-U31）目前散落在草案/raw 档，无正式契约。范式翻案 + A2 重构落地后，需把炸场剧本锁成 **合同回放**（非脚本回放）单源 SSOT，把语音/UIUE 拍板物理化进契约，否则现场脱靶 + UI 翻车（万能红字混 / 七态压二值）。

本 change = **A2 之后独立阶段**（demo 交付层，**不在 A2 范围**），依赖 `migrate-d-domain-tool-surface`（D-domain 工具名）+ `rebuild-c6-four-layer-bench`（must_pass + c6_case_id_derived 关联）。新建两个 capability：`demo-golden-run`（炸场合同回放 SSOT）+ `voice-pipeline`（ASR/TTS/VAD 链路契约）。

**决策权威源**：
- demo-golden-run：paradigm §18 U8/U9（不新起独立 → 并入 demo-golden-run carrier；升级合同回放非脚本回放）+ F3（golden 100% 硬门 / K_abs 不拍数 DEFERRED / step schema）+ grill-decisions BG3（demo 脚本单源 SSOT）
- UIUE U1-U31：paradigm §18 第一批 U1-U10 已拍 + `docs/research/2026-06-22-uiue-ultracode`（待落档）+ raw GRILL-MASTER.md（31 条，U11-U31 待续批）
- ASR/voice：`docs/research/2026-06-19-asr-alignment-research.md`（D14 sherpa 中文主 + WhisperKit fallback + ASRBackend 抽象）+ ASR amend（系统 SFSpeechRecognizer 主 + sherpa/Whisper fallback 不砍 + promptTokens 热词 + AVSpeechSynthesizer 系统朗读 + SpeechTextNormalizer + 8 态机）+ U6/U19/U28/U30
- 级联账本：`docs/grill-tournament/cascade-inventory.md`

## What Changes

> 以下指向已拍决策，**具体逐文件改法 = `docs/grill-tournament/cascade-inventory.md` 各 path 的 verdict + what_to_change**。

- **新建 `demo-golden-run` capability**（cascade-inventory T1 new_file）：`contracts/demo-golden-run.v1.yaml` + `openspec/specs/demo-golden-run`，SSOT schema = [step_id/act_id/utterance_zh/expected_readback/source_contract_row/contract_refs/expected_route_derived/must_pass/uiue_scene_tag/c6_case_id_derived]；关联 C6 must_pass + UIUE 五幕 + L1 覆盖；未建 state cell 步禁进 golden（U9/Q37）；炸场 case 锁 10 族（现场不脱靶，B3）；K_abs = required must_pass step count（解冻后推，F3 DEFERRED 不拍数）。
- **新建 `voice-pipeline` capability**（cascade-inventory T1 new_file）：`openspec/specs/voice-pipeline`，吸收 voice-pipeline-from-raw.md 的 ASR/TTS/VAD 决策；ASRBackend 抽象 = 系统 SFSpeechRecognizer 主 + WhisperKit/sherpa fallback（不砍）；AVSpeechSynthesizer 系统朗读（中文 TTS preflight U28）；promptTokens + usePrefillPrompt 热词（非 contextualStrings）；SpeechTextNormalizer 层；8 态机；作 C1-C3 上游契约。
- **UIUE U1-U31 落契约**：U1-U10 已拍物理落点（demo_sop primary_device=mac / control_glass token / presentation_kind dial-card-badge / golden step ambient_color_wash / Metal 水波一期 / App 工程前置 preflight U6 麦克风 key+memory entitlement / native SwiftUI translation / DemoVisualState 7 态 clarify/unsupported/safety/crash 分显 U10）；U11-U31 待续批（UIX1-9 议题）。
- **demo 脚本占位 → 真实话术**：`demo-experience-script-placeholders.md` 五幕脚本占位符 → demo-golden-run.v1.yaml 真实话术单源（Act2 slot4 已实，剩 14 处待补）。
- **iOS18 API #available**：U19/U30 iOS18 API 必 `#available`；U12 XcodeGen P1。
- spec ADDED：`demo-golden-run`（新 capability）+ `voice-pipeline`（新 capability）。

## Capabilities

### New Capabilities

- `demo-golden-run`: 炸场合同回放 SSOT（step schema + must_pass + c6_case_id_derived 关联 + UIUE 五幕 + L1 覆盖；未建 state cell 步禁进 golden）。
- `voice-pipeline`: ASR/TTS/VAD 链路契约（ASRBackend 抽象系统主 + fallback / AVSpeechSynthesizer / promptTokens 热词 / SpeechTextNormalizer / 8 态机），C1-C3 上游契约。

### Modified Capabilities

- None.（UIUE 物理落点改的是 contracts/docs，非现有 archived capability spec；demo-experience 行为契约 no_change，见 cascade-inventory T1。）

## Non-Goals

- 不新起独立「演示编排 change」（U8 → 并入 demo-golden-run carrier，demo 脚本单源）。
- 不做长时云记忆框架（短时记忆 DialogueState 3 轮，砍长时）。
- 不砍 ASR fallback（系统主 + sherpa/Whisper fallback 不砍 + ASRBackend 抽象）。
- 不跑 post-ASR LLM 纠错（端侧不跑）。
- 不当 voice-pipeline 进 C6 硬门（ASR 属 C7 不当 C6 硬门）。
- 不拍 K_abs 数（F3 DEFERRED，解冻后推）。
- 不进未建 state cell 的 golden step（U9/Q37）。
- 不追全集泛化（现场只说 10 族，族外 unsupported 兜底）。
- 不复制真实座舱原文语料 / raw 热词词表入仓（分级脱敏红线）。

## Success Criteria

> DRAFT 占位，propose 时细化为可验收标准。骨架方向：

- `openspec validate define-demo-golden-run-and-voice --strict` + `--all --strict` pass。
- `demo-golden-run.v1.yaml` schema 完整（10 字段），每 golden step 关联 c6_case_id_derived + must_pass + state cell（未建 cell 步被拒）。
- 炸场 case 全锁 10 族（无族外脱靶 case 进 golden）。
- `voice-pipeline` spec 含 ASRBackend 抽象 / 系统主+fallback / AVSpeechSynthesizer / promptTokens 热词 / 8 态机。
- UIUE U1-U10 物理落点全部有 contract/code 锚（demo_sop/token/presentation_kind/preflight/DemoVisualState 7 态）。
- demo 脚本占位符全替换为 demo-golden-run.v1.yaml 真实话术（14 处补全）。
- iOS18 API 全 `#available` 保护。

## Non-Automated Success Signals

- 方案经理可照 demo-golden-run.v1.yaml 现场 5 分钟跑通 10 族炸场，断网全过，无脱靶。
- UI 七态（clarify/unsupported/safety_refusal/crash）分开显示，无万能红字混（U10 翻车点闭合）。

## Impact

- 新建 `contracts/demo-golden-run.v1.yaml` + `openspec/specs/demo-golden-run/spec.md` + `openspec/specs/voice-pipeline/spec.md`。
- 影响 `ContentView`（native SwiftUI translation / DemoVisualState 7 态消费）、`tool-card-map.demo10.json`（presentation_kind）、`state-cells`、`demo-experience-script-placeholders.md`（→ golden-run SSOT）、`voice-pipeline-from-raw.md`（ASR 纠正）。
- 依赖 `migrate-d-domain-tool-surface`（D-domain 工具名）+ `rebuild-c6-four-layer-bench`（must_pass / c6_case_id_derived）。
- delta spec：`specs/demo-golden-run/spec.md`（ADDED）+ `specs/voice-pipeline/spec.md`（ADDED）。
