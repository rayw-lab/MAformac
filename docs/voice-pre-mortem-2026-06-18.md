# define-voice-contract Pre-Mortem(2026-06-18)

> ⚠️ **HISTORICAL 快照（2026-06-18）—— 文档级联 banner（2026-06-23）**
> 本文是语音契约早期 pre-mortem 历史快照（对应 change 已 PARKED，待 C7 rebase）。ASR 选型已演进：D14 二审改 sherpa-onnx 中文主 + WhisperKit fallback + ASRBackend 抽象（见 `docs/research/2026-06-19-asr-alignment-research.md`）；UIUE 拍板系统 ASR（SFSpeechRecognizer）主（见 `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md`）。**活基线** = `CLAUDE.md §9` + ASR research + voice 落档。正文保留供溯源（8 tiger 坑点仍有参考价值），勿据此推进选型。

> pre-mortem 首战产物(scout 本机 GitNexus/voice-pipeline/reports/02 + oracle CC subagent 14 路 WebSearch + 一手 GitHub issue 核实)。供 `define-voice-contract`(change 4)propose 时填 design Risks + tasks。机制见 `~/.claude/skills/learned/pre-mortem.md`。
>
> **磊哥拍板(2026-06-18)**:① 演示机 = iPhone **15 Pro Max(8GB)** → OOM tiger 化解,支持矩阵锁 8GB+,6GB 标准版出矩阵。② **先做出来、性能指标(800ms/拟人)后续优化**;但**功能性坑(让链路跑不通的)仍 MVP 必防**(不是指标)。

## A. 功能性坑 → 进 MVP tasks(低成本必防,否则「做出来」也是炸的)

| tiger | 一手来源 | mitigation → task |
|---|---|---|
| **promptTokens 致转写返回空** | WhisperKit **#372 OPEN**(同款 626MB)| **voice-contract 第一个 task = spike 验证(go/no-go);返回空则热词改走归一化层 fallback,不押 ASR 层注入** |
| 松手最后词卡 unconfirmed **丢尾** | #173 | 最终文本 = **整段批式重转**,流式仅 UI 预览(强化拍板) |
| 短指令/静音**字幕幻觉**(「请不吝点赞」)| openai/whisper #1783/#1873 | 幻觉短语黑名单 + 最短录音时长门 + 轻量 RMS 能量门(**砍 VAD 的补偿**) |
| **ANE 首跑编译卡死**(像死机)| WhisperKit #268 | 演示前 warm-up 跑 + 启动预热 UI + iPhone encoder 走 GPU |
| TTS×录音同会话 **static 杂音** | Apple Forums 659975 | 录/播会话**串行互斥** invariant |
| promptTokens 中文**回声泄漏**进转写 | Qwen3-ASR 同源机制 | 归一化层热词回声剥离 |

## B. 性能指标 → 后续迭代优化(磊哥定:先做出来)

| tiger | 后续优化方向 |
|---|---|
| AVSpeech 默认机械音 + Siri 音 API 不可用 | 装 Premium 中文音 + 按 identifier 选;不够再 §6.2 CosyVoice(触发点比预期早) |
| AVSpeech 首响 0.6-1s 吃穿 800ms | 高频回复语**预合成缓存** + 启动 warm-up 空格音 |
| large-v3 iPhone 首字延迟(官方 200ms 是 Mac 数字,iPhone 乐观)| 真机实测;超 800ms 降 small(性能档,非功能) |
| promptTokens 禁 prefill KV cache 增首字延迟 | 动态裁剪热词集(已拍板,本条提供延迟证据) |

## C. 已化解(磊哥设备 = 15 Pro Max 8GB)

- iPhone 6GB OOM(#112 + Apple 8GB 门槛)→ 15 Pro Max(8GB)化解;**支持矩阵锁 8GB+,6GB 标准版出矩阵**(写进 design Architecture Decision)。

## paper-tiger(push-to-talk 短指令场景天然规避,记录不慌)

- prev-text 条件化漂移(单轮短指令规避;显式关 prev-text 买保险)
- 流式长跑内存增长(按轮 Idle 重置 buffer 规避)
- Debug/Release 性能差(Release 构建 + 真机实测,常规工程)

## scout 本机印证

- `reports/02`:WhisperKit 解决转写、不解决唤醒/意图/安全/多意图;留 `AppleSpeechRecognizer`/`SherpaRecognizer` **可切换**;中文短命令准确率**必须实测**(车内噪音/同音/数字)。hassil = 规则快路径蓝本。
- `GitNexus §2`:WhisperKit 只产文本+置信;TTS 独立 `SpeechSynthesisEngine`(speak/stop,不读车控状态);8 态语音状态机。

## 来源索引

WhisperKit #372(promptTokens 空,OPEN)/ #173(丢尾)/ #112(OOM)/ #268(ANE 卡死);openai/whisper #1783/#1873(幻觉);Apple Forums 738048(Siri 音)/731238(首响)/691347(didFinish)/659975(录播冲突);arXiv 2501.11378(幻觉)/2507.10860(WhisperKit 延迟=Mac)。
