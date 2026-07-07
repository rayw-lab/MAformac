# GitNexus 深挖命令清单

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

状态: `candidate`  
用途: 供后续 OpenSpec / design / implementation 前快速复跑。

## 车辆协议与 mock 车控

```bash
gitnexus context -r COVESA__vss-tools generate_s2dm_schema
gitnexus query -r eclipse-kuksa__kuksa-databroker 'provide actuation target values current values allowed values authorization set request provider error'
gitnexus context -r Bosch-Connected-Experience-26__Canals _handle_lights_command
gitnexus query -r reinhardjurk__agent-tester 'tool call trace evaluator expected actual verdict'
gitnexus query -r dengky23__nlu-pipeline-vehicle 'parse rule keyword slot intent normalize'
```

## 离线语音与 Swift runtime

```bash
gitnexus context -r argmaxinc__WhisperKit transcribe
gitnexus context -r k2-fsa__sherpa-onnx SherpaOnnxVoiceActivityDetectorWrapper
gitnexus context -r tattn__LocalLLMClient 'Interface:Sources/LocalLLMClientCore/LLMClient.swift:LLMClient'
gitnexus query -r ml-explore__mlx-swift-lm 'LLMModelFactory tokenizer weights tool call format load model'
gitnexus context -r modelcontextprotocol__swift-sdk Tool
```

## 结构化输出、函数调用、评测

```bash
gitnexus context -r Fission-AI__OpenSpec applySpecs
gitnexus context -r noamgat__lm-format-enforcer TokenEnforcer
gitnexus query -r ShishirPatil__gorilla 'decode_execute agentic_checker ast_parse function call evaluation'
gitnexus query -r javierlimt6__tiny-tool-bench 'tool call benchmark expected arguments score'
gitnexus query -r dottxt-ai__outlines 'json schema grammar guided generation'
gitnexus query -r guidance-ai__guidance 'json regex constrained generation grammar tokenizer'
gitnexus query -r instructor-ai__instructor 'pydantic validation retry response model extraction'
```

## 降级仓库旁证

这三个仓库没有完整 GitNexus 图谱, 先只读既有报告或文件系统:

```bash
rg -n 'server|json|grammar|Metal|GGUF|iOS|Swift' referencerepo/repos/ggml-org__llama.cpp docs referencerepo/reports
rg -n 'SwiftUI|stream|whisper|Metal|ASR' referencerepo/repos/ggml-org__whisper.cpp docs referencerepo/reports
rg -n 'function|tool|android|ios|local model|SDK' referencerepo/repos/qualcomm__nexa-sdk docs referencerepo/reports
```

## 可复跑索引命令

```bash
find referencerepo/repos -mindepth 1 -maxdepth 1 -type d | sort | while read d; do
  name=${d#referencerepo/repos/}
  gitnexus analyze "$d" --index-only --skip-agents-md --skip-skills --name "$name" --workers 4 --worker-timeout 60 --max-file-size 512
done
```

对降级仓库, 下一次可以先加 `.gitnexusignore` 跳过 vendored C++ 文件, 再重跑:

```text
ggml/src/ggml-cpu/ops.cpp
examples/quantize/quantize.cpp
sdk/include/external/
```

