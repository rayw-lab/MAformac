## Why

ASR / TTS 是 MVP 必交付项(车控 + ASR + TTS + LoRA)。`define-voice-contract` 锁语音链路行为契约:WhisperKit 中文车控 ASR + `SpeechTextNormalizer` 归一化 + AVSpeech TTS + push-to-talk 状态机。pre-mortem(`docs/voice-pre-mortem-2026-06-18.md`)已搜出 8 个 tiger(promptTokens 返回空 / 松手丢尾 / 短指令幻觉 / ANE 卡死 / AVSpeech 机械音 / 首响吃预算 / 录播冲突 / 6GB OOM),分两层落本 change(**功能坑进 MVP / 性能指标后续优化**,磊哥拍板)。

## What Changes

- **ASR**:WhisperKit large-v3(首测;演示锁 iPhone 15 Pro Max 8GB,OOM 化解)+ push-to-talk + 录音期流式预转 + **松手出整段批式重转的最终文本**(T3.1 防丢尾,流式仅 UI 预览)。
- **热词**:`promptTokens + usePrefillPrompt`(**spike 验证不返回空** T2.1,失败 fallback 归一化层后处理);显式锁 ASR `.json` 行为;短词 / ≤200 / 动态裁剪。
- **SpeechTextNormalizer 独立层**:`raw_text / normalized_text / rewrite_rules / confidence_delta` + **幻觉短语黑名单**(T1.1,砍 VAD 的补偿)+ 最短录音门 + 轻量 RMS 能量门 + 热词回声剥离(T2.4)。
- **confidence 拦截**(归一化后、IntentEngine 前):ASR 低置信 → 澄清不交 LLM;ASR 高置信但意图模糊 → 走 LLM。
- **TTS**:AVSpeechSynthesizer(可中断,只播操作对象 + readback)+ **校验 Premium 中文音已装**(T5.1)+ **启动 warm-up**(T5.3 首响)+ 打断不依赖 `didCancel`。
- **8 态语音状态机**(无 VAD 自动端点,push-to-talk;VAD/KWS 接口预留 Phase2)+ **录/播会话串行互斥**(T6.1 防 static)。

## Capabilities

### New Capabilities
- `voice-pipeline`:录音 → ASR(只产文本+置信)→ 归一化 → confidence 拦截 → TTS(只播报、可中断)的行为契约,push-to-talk 状态机贯穿。

### Modified Capabilities
(无)

## Non-goals

- ❌ VAD 自动端点(push-to-talk;接口预留 Phase2)。
- ❌ 高拟人大模型 TTS(MVP AVSpeech;CosyVoice / TTSKit 二期)。
- ❌ barge-in 全双工(首版按钮打断 D13;二期)。
- ❌ 模型降级(large-v3 主线;small 仅性能降级档,非默认)。
- ❌ 唤醒词 / 全时对话(push-to-talk only)。

## Success Criteria(可验收)

- **promptTokens spike 前置门**(第一个 task):热词在目标 626MB 模型上**不返回空**(T2.1 go/no-go);空则热词走归一化层 fallback。
- **50 条中文车控短句 demo must-pass = 100%**(WhisperKit 主 + sherpa 备双保险)。
- 松手最终文本 = **整段批式重转**(不丢尾,T3.1);流式仅预览不入 IntentEngine。
- **短指令不跳幻觉**(「请不吝点赞」黑名单命中即拒识,T1.1)。
- ASR 低置信 → 澄清不交 LLM;高置信模糊 → 走 LLM(不被「FastPath 命中才继续」挡住)。
- TTS:**Premium 中文音校验通过**(缺失降级提示非静默机械音)+ 启动 warm-up + 可中断。
- 录 / 播会话**串行互斥**(无 static 杂音,T6.1)。

> **性能指标后续优化(磊哥定)**:800ms 闭环 / AVSpeech 拟人度 / large-v3 iPhone 首字延迟 = MVP 先跑通、后续迭代,不阻塞本 change。

## Impact

- 依赖 change1 骨架协议位:`VoiceController` / `SpeechRecognizer` / `SpeechTextNormalizer` / `SpeechSynthesisEngine`。
- 设备:演示锁 **iPhone 15 Pro Max(8GB)**,6GB 标准版出支持矩阵(OOM 化解)。
- 下游:`define-lora-pipeline`(归一化「模糊说 → 标准说」正是 LoRA 训练目标);热词别名来自 `capabilities.yaml.aliases`(change2)。
