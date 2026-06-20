## Context

`define-voice-contract` 实装 change1 的语音协议位(`VoiceController` / `SpeechRecognizer` / `SpeechTextNormalizer` / `SpeechSynthesisEngine`)。pre-mortem 全料见 `docs/voice-pre-mortem-2026-06-18.md`(8 tiger,oracle 14 路 WebSearch + 一手 WhisperKit/AVSpeech issue)。依赖 change2 `capabilities.yaml.aliases`(热词来源)。**演示设备锁 iPhone 15 Pro Max(8GB),6GB 标准版出支持矩阵**。

## Goals / Non-Goals

**Goals:** ASR(只产文本+置信)/ 归一化 / confidence 拦截 / TTS(只播报、可中断)/ push-to-talk 状态机的行为契约 + 功能坑防护。
**Non-Goals:** VAD 自动端点 / 高拟人大模型 TTS / barge-in 全双工 / 模型降级 / 唤醒词。

## Decisions

### 语音状态机(push-to-talk,无自动端点)
```
Idle → Recording(按住;录音期流式预转作 UI 预览)
     → [松手即端点,无 Endpointing 态] → Transcribing(整段批式重转出最终文本)
     → ResolvingIntent(归一化 → confidence 拦截 → IntentEngine)
     → Executing → Speaking(TTS 可中断) → Idle
Speaking + 按 mic → Interrupted → Recording(无缝)
```
VAD/KWS 接口预留,Phase2 barge-in 接入(**非砍,是预留**)。

### 链路(强制明确)
```
录音(push-to-talk + AudioStreamTranscriber 流式预转,仅 UI 预览)
 → 松手 → 整段批式 transcribe 出最终文本(T3.1 防丢尾,IntentEngine 只吃这个)
 → SpeechTextNormalizer(raw_text/normalized_text/rewrite_rules/confidence_delta
    + 幻觉短语黑名单[T1.1] + 最短录音门 + 热词回声剥离[T2.4])
 → confidence 拦截(ASR 低置信→澄清不交 LLM;高置信模糊→走 LLM)
 → IntentEngine → ...(execution-contract)... → readback
 → SpeechSynthesisEngine(AVSpeech,只播操作对象+readback,可中断)
```

### 待解冻 adopt:端到端 span 分层(Q1)
Mastra trace teardown 已归档到 `docs/research/2026-06-20-mastra-teardown-workflow-eval-trace.md`,38 项 backlog 归档到 `docs/优化待讨论-吸收内化措施38项-2026-06-20.md`。C7 解冻时 ASR/normalization 层 SHALL 产上层 span,挂同一个 `runId/traceId` 树；C3 五段仍只保留 `decode/plan/guard/execute/readback`,作为语音链路下游子树。低置信澄清、ASR 拒识、TTS 播报状态写 C7 span attributes,不新增 C3 stage。

### 关键决策表
| 决策 | 选 | 不选(原因) |
|---|---|---|
| ASR | WhisperKit large-v3(8GB 设备) | small(仅性能降级档) |
| 热词 | `promptTokens + usePrefillPrompt`(spike 验不返空) | `contextualStrings`(源码不存在) |
| 最终文本 | 松手**整段批式重转** | 流式 confirmed 缓冲(丢尾 T3.1) |
| 端点 | push-to-talk 松手 | VAD 自动(二期;且 VAD 是短指令幻觉解药,砍后用黑名单补) |
| TTS | AVSpeech + Premium 音校验 + warm-up | 默认音(机械 T5.1)/ 临场合成(首响 T5.3) |
| 双保险 | WhisperKit 主 + sherpa 备 | 单 ASR |
| 会话 | 录/播**串行互斥** | 录播并发(static T6.1) |
| confidence | 区分 ASR 置信(低→澄清)vs 意图模糊(→LLM) | 「FastPath 命中才继续」(挡住模糊意图) |

## Risks / Trade-offs(voice-pre-mortem 实证,带来源)

**功能坑(MVP 必防)**:
- [T2.1 promptTokens 致转写返回空,同款 626MB] → spike go/no-go;空则热词走归一化 fallback。源:[WhisperKit #372](https://github.com/argmaxinc/WhisperKit/issues/372)。
- [T3.1 松手最后词卡 unconfirmed 丢尾] → 最终文本整段批式重转。源:[WhisperKit #173](https://github.com/argmaxinc/WhisperKit/issues/173)。
- [T1.1 短指令/静音字幕幻觉「请不吝点赞」(砍 VAD 副作用)] → 幻觉黑名单 + 最短录音门 + RMS 能量门。源:[openai/whisper #1783](https://github.com/openai/whisper/discussions/1783)。
- [ANE 首跑编译卡死(像死机)] → 演示前 warm-up + 启动预热 UI + encoder 走 GPU。源:[WhisperKit #268](https://github.com/argmaxinc/WhisperKit/issues/268)。
- [T6.1 录播同会话 static] → 录/播会话串行互斥 invariant。源:[Apple Forums 659975](https://developer.apple.com/forums/thread/659975)。

**性能指标(后续迭代,磊哥定先做出来)**:
- [T5.1 AVSpeech 默认机械音 + Siri 音不可用] → 装 Premium 中文音 + 按 identifier 选;不够再 CosyVoice。源:[Apple Forums 738048](https://developer.apple.com/forums/thread/738048)。
- [T5.3 首响 0.6-1s 吃穿 800ms] → 启动 warm-up 空格音 + 高频回复预合成缓存。源:[Apple Forums 731238](https://developer.apple.com/forums/thread/731238)。
- [large-v3 iPhone 首字延迟(官方 200ms 是 Mac 数字)] → 真机实测;超线降 small。

**已化解**:6GB OOM(#112)→ 锁 iPhone 15 Pro Max 8GB。

## Migration Plan

实装 change1 语音协议位。`Package.swift` pin WhisperKit exact tag。演示设备锁 8GB+。回滚 git revert。

## Open Questions

- TTS 中文 voice / rate / pitch 的 S-PASS(磊哥听感拍板)。
- sherpa 备份启用阈值(WhisperKit 错「三档/外循环/座椅通风/氛围灯」补归一化补不住才启 sherpa)。
