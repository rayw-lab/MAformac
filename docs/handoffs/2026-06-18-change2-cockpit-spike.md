# Handoff 2026-06-18 — change2 apply + 座舱三层原理 + spike E3 dispatch

## 一句话状态
change1/2 **done+archive**;座舱语音**三层原理**多路调研落档;change3 起手 **spike E3 dispatch 已写,待开 Codex 跑**。新增第 7 个 change `define-intent-routing`。

## 本 session 完成
1. **change2 capability apply**(Codex 16/16)+ **deep-audit cross-vendor 35/40 YELLOW**(catch「superseded 测试自证重解释」,已修补三处 draft 反向指针)+ archive。报告 `~/workspace/data/exports/deep-audit-MAformac-change2-*.md`。
2. **change1 archive**(15/15,iOS Simulator 验过)。
3. **座舱语音 FC 原理多路调研**(scout 本机 raw + oracle 联网 + magnet 语料三方互证)→ 真实座舱**三层非二分**(规则NLU / FC快思考泛化 / 慢思考),核心「感受/开放词→参数=读端状态生成增量」`v≠current(f)`。落档 `docs/cockpit-voice-fc-premortem-2026-06-18.md`。
4. **pre-mortem 三分类**(T1 二分盲点 / T2 base 1.7B 触发率 55% / T3 参数规划须读状态 / T4 LoRA 口径偏窄;PT1-4;EL1-2)。
5. **决策**:新起 `define-intent-routing`(6→7 change),change3 保持纯 execution(消费上游 ToolCallFrame)。
6. **spike E3 dispatch 写好** `docs/dispatches/2026-06-18-spike-e3-function-call.md`(5 维硬 gate + dev/ 独立 SPM 隔离 mlx)。
7. 文档维护:CLAUDE §9+frontmatter / config 7-change / lessons §F / memory(项目状态+磊哥画像)。

## 下一步
1. **开 Codex 跑 spike E3**(生死线验 base 1.7B function call,冷启动 prompt 见 dispatch)。
2. spike 出数据 → explore `define-intent-routing`(用实测,不拍脑袋)。
3. spike go → change3 主体实装。

## 待拍板(4)
demo must-pass 15-25 清单(change6) / TTS 中文 S-PASS / LoRA DB 抽取授权(change5) / intent-routing 三层边界(spike 后)。

## 🟡 demo 边界(magnet 重申)
**不接真车**;量产标准(ISO26262/端云/QPS/误吸率)豁免;**安全门思想/参数规划/读mock态/工具约束/LoRA 保留**。

## 环境
iOS 26.5 Simulator ready(change2 后 iOS target BUILD SUCCEEDED);Apple Developer 未配(真机演示需,演示机 iPhone 15 Pro Max);本机 M5 + Swift 6.3.2;本 session 工作已 commit。

## 起手读
CLAUDE.md → 本 handoff → `docs/cockpit-voice-fc-premortem-2026-06-18.md` → MEMORY.md。
