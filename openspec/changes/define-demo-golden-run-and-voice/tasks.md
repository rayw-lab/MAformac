<!--
DRAFT SKELETON (2026-06-23) — tasks 占位待细化，人审定 propose 时展开为可验收逐项。
依赖序：本 change = demo 交付末端，依赖 migrate-d-domain([1] D-domain 工具名) + rebuild-c6(must_pass/c6_case_id_derived)。
incremental，禁大爆炸。
-->

> Unchecked downstream tasks are not execution authorization. Follow `docs/superpowers/plans/2026-06-25-post-c6-backend-training-uiue-roadmap.md`, the GPT Pro architecture verdict, and the relevant accepted child plan before implementation. This file does not authorize golden-run execution, voice readiness, ASR/TTS readiness, endpoint readiness, UIUE merge, training, C6 acceptance, candidate comparison, model-quality evaluation, or V/S/U-PASS.

## 1. 前置依赖

- [ ] 1.1 确认 `migrate-d-domain-tool-surface` 已 archive（D-domain 工具名可引用）。
- [ ] 1.2 确认 `rebuild-c6-four-layer-bench` must_pass + c6_case_id_derived 可关联。
- [ ] 1.3 Confirm `define-demo-default-scope` is proposed and validated before freezing golden-run IDs, C6 case IDs, readback text, `scope_origin` policy, fan-out aggregate labels, or UIUE scene tags. This task depends on the default-scope carrier and must not redefine omitted-scope behavior inside golden-run/voice.

## 2. demo-golden-run capability（new）

- [ ] 2.1 `contracts/demo-golden-run.v1.yaml` schema（10 字段：step_id/act_id/utterance_zh/expected_readback/source_contract_row/contract_refs/expected_route_derived/must_pass/uiue_scene_tag/c6_case_id_derived）（DRAFT 待细化）。
- [ ] 2.2 炸场 case 锁 10 族（现场不脱靶）；未建 state cell 步禁进 golden（U9/Q37）。
- [ ] 2.3 demo 脚本占位符 → 真实话术单源（demo-experience-script-placeholders.md 14 处补全 → golden-run SSOT）。
- [ ] 2.4 K_abs = required must_pass step count（F3 DEFERRED 不拍数，解冻后推）。
- [ ] 2.5 D10 `already_state` dedicated case：add one state-noop golden seed before freezing IDs. Example shape: user asks a temperature/status utterance while `ac.power=off`; renderer answers that the AC is already off and temperature is unavailable/unchanged. This case must assert `already_state` separately from unsupported, safety, success, and clarify, and must carry `scope_origin` metadata.

## 3. UIUE 落契约

- [ ] 3.1 U1-U10 物理落点（demo_sop primary_device=mac / control_glass token / presentation_kind dial-card-badge / ambient_color_wash golden step / Metal 水波一期 / preflight U6 麦克风 key+memory entitlement / native SwiftUI translation / DemoVisualState 7 态分显 U10）。
- [ ] 3.2 UIUE 落档 `docs/research/2026-06-22-uiue-ultracode`（吸收 raw GRILL-MASTER.md 31 条；U11-U31 待续批）。

## 4. voice-pipeline capability（new）

- [ ] 4.1 `openspec/specs/voice-pipeline/spec.md` ASRBackend 抽象（系统主 SFSpeechRecognizer + WhisperKit/sherpa fallback 不砍）（DRAFT 待细化）。
- [ ] 4.2 AVSpeechSynthesizer 系统朗读 + 中文 TTS preflight（U28）；promptTokens 热词 + SpeechTextNormalizer + 8 态机。
- [ ] 4.3 `voice-pipeline-from-raw.md` ASR 纠正（contextualStrings→promptTokens / TTS 调教 / confidence_delta 实装）。
- [ ] 4.4 iOS18 API #available 保护（U19/U30）；U12 XcodeGen P1。

## 5. 验证与收口

- [ ] 5.1 `openspec validate define-demo-golden-run-and-voice --strict` + `--all --strict` pass。
- [ ] 5.2 红线检查：无原文语料 / raw 热词词表 / PII 入仓。
- [ ] 5.3 非自动化信号：方案经理照 golden-run 现场 5 分钟跑通 10 族炸场断网全过；七态分显无万能红字混。
