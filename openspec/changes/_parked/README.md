# _parked — 旧 7-change 路线暂缓区(2026-06-19)

> ⛔ **本目录所有 change 已 PARKED — 不删、不 archive、不继续 apply。**
> OpenSpec change 无 status 字段,故**物理移出 `changes/` 根**(`/opsx:list` 扫不到 = 工具层防误 apply)。

## 为什么 park

2026-06-19 基座深度内化 → **全量重构**(推翻旧「8 扁平能力 + 二分路由」路线)。新路线以**契约 SSOT 为根**:`define-c1c2-contract`(C1 源行级 JSONL 语义契约 + C2 场景端态协议)。这 5 个旧 change 的**输入契约已变**(扁平 `capabilities.yaml` → value 四件套 + device×原语×槽三元 + 场景端态),不能继续当可执行路线;但设计资产不丢,等 C1/C2 archive 后逐个按新契约 rebase/重写为 C3–C7。

决策出处:Q1–Q15 脑暴(CC↔codex)+ `docs/c1-q1-q10-claude-oracle-grill-2026-06-19.md` + `docs/adr/0001-generated-full-contract-with-mixed-delivery.md`。

## 复用度(rebase 依据)

| parked change | 复用度 | 说明 | 未来 |
|---|---|---|---|
| `define-voice-contract` | 🟢 高可复用 | WhisperKit/ASR/TTS/barge-in 与契约无关,基本整体复用 | → C7 |
| `define-execution-contract` | 🟡 骨架可复用 | change3 已实装 executor/guard/decoder(worktree `46340f1`);arguments 扁平→value 四件套 + position fan-out 要重做 | → C3 |
| `define-intent-routing` | 🔴 重写 | 二分→三层 + 意图收缩 `clarifyTag` + state-dict,强依赖新契约 | → C4 |
| `define-lora-pipeline` | 🔴 重写 | adopt Hammer/xLAM/unsloth + 全集语料,依赖 C1 JSONL | → C5 |
| `define-vehicle-tool-bench` | 🔴 重写 | 双轴(format/decision)+ OOS + 全集覆盖率,依赖 C1/C2 | → C6 |

## rebase 触发

`define-c1c2-contract` apply+archive 后,按上表逐个把 parked change 移回 `changes/` 并按新契约重写/局部复用,作为 C3–C7。
