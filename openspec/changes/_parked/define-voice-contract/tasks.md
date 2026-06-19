> 范围:6-change 第 4 个。实装 change1 语音协议位为完整链路。pre-mortem 全料 `docs/voice-pre-mortem-2026-06-18.md`(8 tiger,**功能坑进 MVP / 性能指标后续优化**)。依赖 change2 `capabilities.yaml.aliases`(热词)。演示设备锁 iPhone 15 Pro Max(8GB)。

## 0. promptTokens spike(go/no-go,起手必做)

- [ ] 0.1 热词 `promptTokens` 在目标 626MB 模型 + 中文车控短句上**实测不返回空**(T2.1)。验收:转写非空 + 热词命中率提升。**go/no-go**:返回空 → 热词改走归一化层后处理 fallback。**叠加 Superpowers: verification**。

## 1. ASR(WhisperKit)

- [ ] 1.1 接入 WhisperKit large-v3(`Package.swift` pin exact tag)+ push-to-talk + 录音期流式预转(`AudioStreamTranscriber`,仅 UI 预览)。验收:按住出预览、松手触发最终识别。
- [ ] 1.2 **松手对整段录音批式重转出最终文本**(T3.1 防丢尾),IntentEngine 只吃最终文本。验收:「打开主驾车窗」不丢尾成「打开主驾」。
- [ ] 1.3 ANE 冷启动:启动 warm-up 跑 + 预热 UI + iPhone encoder 走 GPU(T2/#268 防卡死)。验收:首次启动不卡在加载屏。

## 2. 归一化 + confidence 拦截

- [ ] 2.1 `SpeechTextNormalizer` 独立层:`raw_text / normalized_text / rewrite_rules / confidence_delta`;trace 与 ASR 错分栏。验收:输出四字段,意图层只吃 normalized。
- [ ] 2.2 幻觉短语黑名单(「请不吝点赞」类)+ 最短录音时长门 + 轻量 RMS 能量门 + 热词回声剥离(T1.1/T2.4,砍 VAD 补偿)。验收:近静音/超短录音的幻觉被拒识。
- [ ] 2.3 confidence 拦截(归一化后、IntentEngine 前):ASR 低置信→澄清不交 LLM;高置信模糊→走 LLM。验收:低识别置信不交 LLM;高置信模糊不被「仅明确指令才继续」挡。

## 3. TTS(AVSpeech)

- [ ] 3.1 接入 `AVSpeechSynthesizer`(只播操作对象+readback,可中断)+ **校验 Premium 中文音已装**(缺失降级提示非静默机械音,T5.1)+ 启动 warm-up 空格音(T5.3 首响)。验收:Premium 音校验通过 + 首响不冷启动。
- [ ] 3.2 打断:`stopSpeaking` + 状态机转 Interrupted,**不依赖 `didCancel`**(iOS15+ 回 didFinish)+ 防在 `preUtteranceDelay` 期调用崩(T5.3)。验收:播报中打断不崩、状态正确转。

## 4. 状态机 + 会话

- [ ] 4.1 8 态语音状态机(Idle→Recording→Transcribing→ResolvingIntent→Executing→Speaking→Interrupted,**无 Endpointing/VAD**;VAD/KWS 接口预留 Phase2)。验收:push-to-talk 全态转移正确。
- [ ] 4.2 录/播会话**串行互斥** invariant(T6.1 防 static);deactivate 前确保 I/O 停(防 560030580)。验收:录→播切换无 static 杂音。

## 5. 验收门

- [ ] 5.1 **50 条中文车控短句 demo must-pass = 100%**(覆盖空调/车窗/座椅/灯光/模糊说/负样本)。**叠加 Superpowers: TDD**。
- [ ] 5.2 WhisperKit 主 + sherpa 备双保险:错「三档/外循环/座椅通风/氛围灯」先补归一化,补不住启 sherpa。验收:50 条错词经归一化/ sherpa 修正。
- [ ] 5.3 断网全程可演 + `openspec validate define-voice-contract` 通过。
