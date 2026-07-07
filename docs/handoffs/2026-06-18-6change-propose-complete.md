# Handoff 2026-06-18 — MAformac 6-change 全 propose 完成 + pre-mortem 机制建立

> ⚠️ **HISTORICAL 快照（T5）—— 文档级联 banner（2026-07-07 B4b）**
> 本文是 `docs/grill-tournament/cascade-inventory.md §T5` 标记的历史快照，当前仅保留溯源/交接价值；supersede 指针以 `docs/grill-tournament/cascade-inventory.md` 的 T5 账本为准。
> **活基线** = `CLAUDE.md §9` + `docs/grill-tournament/grill-decisions-master.md` + `docs/c5-recovery-2026-06-22/grill-decisions-amend-paradigm-tool-surface.md` + `docs/grill-tournament/cascade-inventory.md`。正文保留供溯源，勿据此推进。

## 一句话状态
6-change 全 propose done(契约层完整,24 artifact 全 validate ✅);change1 已 Codex 实装 **14/15**(iOS 1.1 等 Simulator);下一步 **纯 apply**(Codex 长跑实装)+ 磊哥审。

---

## 一、本 session 完成(按时间)

1. **脑暴模块 2-5 全拍板**(语音 ASR/TTS、UI+状态、MCP、架构 7 层+骨架),见 `docs/project/brainstorm-2026-06-17-demo-mvp.md §5`。
2. **6-change 全 propose**(proposal/design/specs/tasks × 6):
   | change | tasks | 关键 |
   |---|---|---|
   | 1 demo-mvp-contract | **14/15**(Codex 实装) | 骨架 + walking skeleton |
   | 2 capability-contract | 0/13 | 8 capability + cell schema 三合一 |
   | 3 execution-contract | 0/14 | ToolCallFrame + 错误枚举 + DemoGuard R0-R3 |
   | 4 voice-contract | 0/14 | WhisperKit + 归一化 + AVSpeech + 8 态机 |
   | 5 lora-pipeline | 0/11 | 5 态数据状态机 + 脱敏 fail-closed |
   | 6 vehicle-tool-bench | 0/12 | 四个 0 死门 + restraint + 评分分层 |
3. **change1 Codex apply 14/15** + CC 审计 **T-PASS**(独立复跑 swift test/边界/产物 + catch 3 漂移)。
4. **🌟 pre-mortem 机制建立(核心产出)**:
   - 起因:磊哥 catch「CC 凭知识库造 Pitfall-First 没先搜」(happy-path bias)。
   - adopt:**Pre-Mortem(Klein/HBR)** + vibecosystem `scout/oracle` + honnibal 10 类脆弱性 + tjboudreaux Elevate-or-Kill。
   - **四载体**:rules `pre-mortem-reflex.md` + skill `learned/pre-mortem.md` + config design rule + memory。
   - **双 agent**:Claude(`~/.claude/`)+ Codex(`~/.codex/AGENTS.md` 条目 + `skills/pre-mortem/` + `.curated` symlink)。
   - **oracle 原则**:每 agent 用自己的 subagent + web,**不跨厂商互派**。
   - skill 双通道:主动(`/pre-mortem` / `$pre-mortem` / trigger_phrases)+ reflex 自动。
5. **pre-mortem 双战**(机制立刻产值):voice 8 tiger / execution 8 发现(读 mlx-swift-lm 源码,根架构决策 adopt 薄层)。
6. **dispatch 机制**:`docs/dispatches/_TEMPLATE.md`(通用,CC↔Codex↔CC)+ `2026-06-18-define-demo-mvp-contract-apply.md`(第一个实例)。

---

## 二、🔴 坑点全清单(本 session 踩 / catch 的,起手必读)

### A. CC 元认知坑(自省,已入 lessons / 全局 rules)
1. **happy-path bias**:Step1 看 `<tool_call>` 干净就报「验证通过」,没搜坑 → Codex/pre-mortem 补 8 tiger。**happy path 通 ≠ 验证通过,先搜会怎么炸**。
2. **凭知识库造不先搜**:造 Pitfall-First 没搜业界 Pre-Mortem + 现成 skill → 磊哥 catch。**回答「怎么做 X」前先搜现成(github-first + pre-mortem)**。
3. **不沉淀磊哥习惯**:3 月协作没积累画像 → 已补 `memory/leige-search-first-intent-generalization`。
4. **不泛化意图**:字面执行 vs 泛化真意(磊哥「有什么方案」深层 = 先搜实践再答)。
5. **归因错位偏保守**:按车规 8155 算 demo M5+A16 硬件,过度担心 large-v3 延迟 → lessons B11(性能评估先锚定 baseline 硬件)。
6. **系统性弱化 ASR/LoRA**(早期):误导源传播 → lessons §E catch1。

### B. 技术坑 — voice(8 tiger,详 `docs/voice-pre-mortem-2026-06-18.md`)
1. **promptTokens 返回空**(WhisperKit #372 OPEN,同款 626MB)→ spike go/no-go + 归一化层 fallback。
2. 松手最后词卡 unconfirmed **丢尾**(#173)→ 最终文本整段批式重转。
3. iPhone **6GB OOM**(#112)→ **磊哥 15 Pro Max 8GB 化解**,支持矩阵锁 8GB+。
4. 短指令**字幕幻觉**「请不吝点赞」(砍 VAD 副作用)→ 黑名单 + 最短录音门 + RMS 能量门。
5. **ANE 首跑编译卡死**(#268,像死机)→ warm-up + 预热 UI + encoder 走 GPU。
6. AVSpeech 默认**机械音** + Siri 音 API 不可用 → 校验 Premium 中文音。
7. AVSpeech 首响 **0.6-1s 吃穿 800ms** → 预合成缓存 + warm-up。
8. TTS×录音同会话 **static**(659975)→ 录/播会话串行互斥。

### C. 技术坑 — execution(8 发现,详 `docs/execution-pre-mortem-2026-06-18.md`,oracle 读 mlx-swift-lm 源码)
1. **mlx-swift-lm 已内置 parser** → **adopt 薄层不自建**(E1 根架构决策)。
2. `infer()` model_type **静默失配**(tool call 漏进普通文本)→ 显式锁 `.json`。
3. `parse()` 全失败归 `nil`(无区分信号)→ 自写 `throws` decoder 三态。
4. enum 加 `unknown` 不够(合成 decoder 抛 dataCorrupted)→ 手写 `init(from:)` + **禁 try!/try?**。
5. `arguments` string-vs-object(数组/标量静默丢)→ 全类型归一 `[String:JSONValue]`。
6. **两层 decode**(validator 门挂第②层 `execute()` 前,E2)。
7. **Qwen3-1.7B base tool-call 可靠性未验证**(前置生死线,E3)→ spike 量化触发率。
8. `contextualStrings` 不存在(lessons B12,workflow 按「同款机制」假设错,Codex 读源码 catch)→ `promptTokens + usePrefillPrompt`。

### D. 契约漂移坑(审计 catch)
- **subagent 审计 4 HIGH(已修)**:H1 spec 混文件名 / H2 config 未回写 6-change / H3 边界漏训练集 / H4 字段漏 display_zh。
- **Codex P1/P2/P3(已修)**:proposal 边界自相矛盾(line 5 vs 53)/ 5 幕标签漂移 / spec 写 capabilities.yaml 文件名。
- **change1 占位 3 漂移(待 change2/3 对齐)**:visualState 枚举(idle/active… vs normal/satisfied…)/ cell 命名(`hvac.ac` vs `cabin.ac`、`fragrance/sunroof` vs `screen_brightness/seat_ventilation`)/ arguments 类型(`[String:String]` → `[String:JSONValue]`)。

---

## 三、未完成 / 待办

- change1 task 1.1 **iOS Simulator**(本机 iOS 26.5 未装,等 Simulator 下完补勾)。
- **Apple Developer 签名**(真机演示,未配;演示机 = iPhone 15 Pro Max)。
- 完整 Xcode iOS Simulator 下载(进行中)。
- **磊哥待拍板项**:
  - demo must-pass **15-25 条具体清单**(change6 定稿,需磊哥确认 5 幕话术 → 指令映射)。
  - TTS 中文 voice/rate/pitch **S-PASS**(磊哥听感)。
  - LoRA 从运行态 DB 抽 50 条 redacted candidate **授权**(change5)。
  - runtime 首轮顺序(已同意:server 先行 → Swift 嵌入)。

---

## 四、apply 顺序(下次,依赖序)
`1 demo-mvp(补 iOS)→ 2 capability(对齐 change1 3 漂移)→ 3 execution(spike E3 起手:1.7B 触发率)→ 4 voice(spike promptTokens 起手:不返空)→ 5 lora(需磊哥授权 DB 抽取)→ 6 eval(must-pass 清单磊哥确认)`。
- change2 必先于 5/6(LoRA 数据 + eval 依赖 capability 定义)。
- 每个 change apply 前跑 pre-mortem(reflex 自动)。

---

## 五、关键文件(优先读)
1. `openspec/changes/*/`(6 change × 4 artifact)+ `openspec/config.yaml`(context + rules,含 6-change 拆法 + Pre-Mortem rule)
2. `docs/{voice,execution}-pre-mortem-2026-06-18.md`(坑点全料 + 源码锚点)
3. `docs/qwen3-engineering-notes.md`(Qwen3 工程硬约束 + 4 隐藏层)
4. `docs/dispatches/`(派单模板 + change1 dispatch)
5. `docs/lessons-learned.md`(B11-14 + §E catch1-2)+ `~/.claude/rules/pre-mortem-reflex.md`

## 六、当前状态
- **git**:MAformac 仓,大量 untracked(代码 + docs + openspec/changes),**未 commit**(待磊哥要求)。
- **swift test**:4 测试 / 1 通过 / 3 skip / 0 fail。
- **xcodebuild MAformacMac**:BUILD SUCCEEDED;iOS target 存在但 Simulator 缺。
- 工程:`App/ Core/ Features/ contracts/ Tests/` 落地(16 文件)。

## 七、下次第一步
开 Codex 窗口喂 `docs/dispatches/2026-06-18-define-demo-mvp-contract-apply.md` 补 change1 iOS(或 iOS 不急 → 直接 apply change2,我写 change2 dispatch 带 3 漂移对齐)。或磊哥先拍待办的 4 个拍板项。
