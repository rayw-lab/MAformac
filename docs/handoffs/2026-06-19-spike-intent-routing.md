# Handoff 2026-06-19 — spike E3(GO) + intent-routing propose(7-change 完结)

## 一句话状态
**7-change 全 propose done**(1/2 archive,3-6 + intent-routing propose done);spike E3 **GO**(base 1.7B 意图 87.5%);下一步 **apply change3 主体**(execution 链)→ intent-routing。已 commit `99c49fa`,工作树 clean。

## 本 session 完成(超长高密度)
1. change2 capability apply(Codex 16/16)+ deep-audit cross-vendor 35/40 YELLOW(catch「superseded 测试自证」已修)+ archive;change1 archive。
2. **座舱语音三层原理调研**(scout 本机 raw FunctionCall 手册 + oracle 联网 + magnet 语料 三方互证)→ 真实座舱**三层非二分**(规则 NLU / FC 快思考泛化 / 慢思考),纠 CC 二分盲点。落档 `docs/cockpit-voice-fc-premortem-2026-06-18.md`。
3. **spike E3**(base Qwen3-1.7B function call,`dev/spike-e3/` 隔离包,Xcode 解 metallib)→ **GO**;cross-vendor 审计 catch「G2 22.5% 格式通道问题 > 意图,真实意图 87.5%」→ change3 加 content-fallback(候选→统一 guard)拉 ~95%,LoRA 重定义为修 `<tool_call>` 格式(非教意图)。
4. **intent-routing(第 7 个 change)propose**:4 轮 cross-agent grill(判定/横切/端状态+FC泛化/规则L1+边界)+ pre-mortem(9 坑)+ 7 段 design approve + propose 4 artifact + self-audit catch 5 finding 全整改。全料 `docs/intent-routing-explore-2026-06-18.md`。
5. spike 回流:change3 design E1a(候选门)/ change5 LoRA 重定义 / change6 二分漂移登记。

## 7-change 状态
- 1 demo-mvp ✅archive / 2 capability ✅archive
- 3 execution:propose done,**spike GO**,待主体实装(content-fallback + DemoGuard 完整 R0-R3 + 错误枚举三态 + 两层 decode)
- 4 voice / 5 lora / 6 eval:propose done
- 7 intent-routing:propose done(审计 + 整改闭环)

## 待拍板 / 待办
- **change3 主体 dispatch**(照 spike v2 实测坑:mlx-swift-lm pin 3.31.3 / API 差异 ModelConfiguration / metallib 走 Xcode)
- **change6 二分对齐**(apply 时 MODIFIED `vehicle-tool-bench/design.md:38/:46` route fast|slow → route_kind 多态,见 intent-routing proposal Impact)
- demo must-pass 15-25 清单 / TTS 中文 S-PASS / LoRA 运行态 DB 抽取授权
- G5 mini-spike(验 G3 开放词映射,当前 2 样本未验证)

## 关键机制 / 模式(本 session 沉淀)
- **cross-agent grill**:CC 出 grill 问题(自包含+候选+倾向+反问)→ 磊哥贴另一窗口 answer → CC 辩证吸收(不迎合,核引用,找 catch)→ 记 explore 笔记 → 逐轮收敛 → pre-mortem → present design approve → propose。
- **self-audit 对抗**(CC subagent 审 CC 主线程,catch 主线程 explore 标了 propose 漏的)。
- pre-mortem reflex(propose 前 oracle 联网扫新坑,9 坑超 4 轮 grill)。

## 🟡 demo 边界(magnet 重申)
不接真车;量产标准(ISO26262/端云/QPS/误吸率)豁免;安全门思想/参数规划/读 mock 态/工具约束/LoRA 保留。

## 起手读
CLAUDE.md → 本 handoff → `docs/intent-routing-explore-2026-06-18.md` → `docs/cockpit-voice-fc-premortem-2026-06-18.md` → MEMORY.md。

## 环境
iOS 26.5 Simulator ready(change2 后 iOS build SUCCEEDED);本机 M5 + Swift 6.3.2;Xcode 路径解 metallib;Apple Developer 未配。git: commit `99c49fa`,工作树 clean。
