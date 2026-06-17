# Reference Repo Manifest

Project: offline on-device vehicle-control Agent App for macOS/iOS.

This folder collects upstream repositories for local inspection. Repositories are cloned under `repos/<owner>__<repo>` to avoid name collisions.

## Repository Set

| # | Repo | Category | Why It Matters |
|---:|---|---|---|
| 1 | https://github.com/Bosch-Connected-Experience-26/Canals | Vehicle voice agent | Closest local-first SDV voice assistant prototype found. |
| 2 | https://github.com/reinhardjurk/agent-tester | Vehicle agent evaluation | In-vehicle voice assistant testing framework with tool-call traces. |
| 3 | https://github.com/dengky23/nlu-pipeline-vehicle | Vehicle NLU pipeline | Intent, slot, NER normalization, evaluation pipeline for in-vehicle voice. |
| 4 | https://github.com/weathour/vehicle-offline-voice-android | Offline vehicle voice | Offline voice pipeline with vehicle state integration, Android reference. |
| 5 | https://github.com/COVESA/vehicle_signal_specification | Vehicle signal standard | Canonical vehicle signal naming and semantics. |
| 6 | https://github.com/COVESA/vss-tools | VSS tooling | Converts and validates VSS specs for downstream schema generation. |
| 7 | https://github.com/eclipse-kuksa/kuksa-databroker | Vehicle data broker | Local VSS gRPC broker for vehicle state and actuator mock. |
| 8 | https://github.com/eclipse-kuksa/kuksa-can-provider | CAN/VSS bridge | CAN provider linking low-level vehicle messages to VSS broker. |
| 9 | https://github.com/eclipse-velocitas/vehicle-app-python-template | SDV app template | Runnable template for Velocitas vehicle apps. |
| 10 | https://github.com/eclipse-autowrx/autowrx | SDV prototyping | digital.auto-style API catalog and SDV prototype platform. |
| 11 | https://github.com/COVESA/vdm | Vehicle data model | Emerging semantic vehicle data model beyond VSS. |
| 12 | https://github.com/COVESA/vehicle-edge | Vehicle edge stack | Interface layer between vehicle data sources and agnostic apps. |
| 13 | https://github.com/OHF-Voice/hassil | Deterministic NLU | Template sentence intent parser for fast rule path. |
| 14 | https://github.com/OHF-Voice/intents | Intent sentence corpus | Local voice-control sentence templates and tests. |
| 15 | https://github.com/rhasspy/rhasspy | Offline voice assistant | Full offline voice assistant architecture, archived but instructive. |
| 16 | https://github.com/argmaxinc/argmax-oss-swift | Apple speech AI | WhisperKit/TTSKit/SpeakerKit for on-device Apple speech. |
| 17 | https://github.com/k2-fsa/sherpa-onnx | Offline speech stack | ASR, TTS, VAD, KWS across iOS/macOS and embedded platforms. |
| 18 | https://github.com/ggml-org/whisper.cpp | Offline ASR runtime | C/C++ Whisper runtime with SwiftUI example. |
| 19 | https://github.com/wizcheu/iOSLLMFrameworkBenchmark | iOS LLM benchmark | Direct MLX Swift vs llama.cpp vs MLC-LLM benchmark on Qwen3. |
| 20 | https://github.com/mattt/llama.swift | Swift llama.cpp wrapper | Semantically versioned Swift access to llama.cpp XCFramework. |
| 21 | https://github.com/StanfordSpezi/SpeziLLM | Swift LLM app framework | Local/cloud/fog LLM abstractions for Swift apps. |
| 22 | https://github.com/ml-explore/mlx-swift-lm | MLX Swift LLM | Apple-native LLM/VLM library for Swift. |
| 23 | https://github.com/ggml-org/llama.cpp | Local LLM runtime | GGUF, Metal, constrained JSON, server and iOS build path. |
| 24 | https://github.com/ShishirPatil/gorilla | Function-call eval | Official Gorilla/BFCL source for tool-calling evaluation patterns. |
| 25 | https://github.com/javierlimt6/tiny-tool-bench | Tiny model tool eval | Sub-2B function-calling benchmark for on-device models. |
| 26 | https://github.com/noamgat/lm-format-enforcer | Structured output | JSON Schema and regex output enforcement for model eval/prototyping. |
| 27 | https://github.com/dottxt-ai/outlines | Structured generation | Python structured-output generation and function schema workflow. |
| 28 | https://github.com/guidance-ai/guidance | Controlled generation | Grammar/regex/JSON constrained generation and prompt control. |
| 29 | https://github.com/instructor-ai/instructor | Structured extraction | Pydantic-first structured extraction and validation pattern. |
| 30 | https://github.com/alexa/alexa-auto-sdk | Auto voice SDK | Archived automotive assistant SDK, useful for domain boundaries. |
| 31 | https://github.com/shawnq-msft/azure-voice-live-for-car-android | Car voice UX | Online Android car voice assistant UX reference. |
| 32 | https://github.com/huggingface/swift-transformers | Swift model integration | HF Swift package for tokenizer, Hub download, and inference APIs. |
| 33 | https://github.com/tattn/LocalLLMClient | Swift LLM runtime facade | Unified Swift client over llama.cpp, MLX, and Apple Foundation Models style backends. |
| 34 | https://github.com/qualcomm/nexa-sdk | Local LLM/VLM SDK | Day-0 local model SDK with device-oriented function-calling direction. |
| 35 | https://github.com/mozilla-ai/llamafile | Single-file LLM runtime | Mac-friendly one-file LLM server/runtime reference, useful for prototype fallback. |
| 36 | https://github.com/MadeAgents/Hammer | Small model function calling | Function-calling model/tool-use reference around small Qwen-style models. |
| 37 | https://github.com/argmaxinc/WhisperKit | Apple offline ASR | Swift-native Whisper pipeline for iOS/macOS speech recognition. |
| 38 | https://github.com/modelcontextprotocol/swift-sdk | Swift MCP integration | Official Swift SDK for MCP-style tool/resource protocol integration. |
