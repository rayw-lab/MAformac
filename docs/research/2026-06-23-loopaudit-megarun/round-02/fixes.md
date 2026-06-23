# Round-02 修复官 fixes（2026-06-23）

> 第2轮修复官。审计发现 6 个 finding（全 P1），逐条本机核实后修复。决策锚：口径终拍 562（磊哥 2026-06-23 亲拍，旧 534/2086/52.3%/1004/1904 系列全废）+ ASR amend（系统 SFSpeechRecognizer 主）+ 范式翻案（generic frame→D-domain 具名工具）。

**修复数：6 finding（实际去重后 5 个独立问题——finding #3/#4 同指 final-grill-list:7 裸锚 534，finding #2/#6 同指 cascade-inventory CLAUDE-row drift；均完整修复）。**

## files_touched

1. `/Users/wanglei/workspace/MAformac/CLAUDE.md`
2. `/Users/wanglei/workspace/MAformac/docs/README.md`
3. `/Users/wanglei/workspace/MAformac/docs/grill-tournament/cascade-inventory.md`
4. `/Users/wanglei/workspace/MAformac/docs/grill-tournament/final-grill-list.md`
5. `/Users/wanglei/workspace/MAformac/docs/grill-tournament/ledger.md`
6. `/Users/wanglei/workspace/MAformac/contracts/function-spec-full.yaml`

## 逐条 finding → 本机核实 → 怎么改

### P1 #1 — ASR amend（系统 SFSpeechRecognizer 主）未级联进活基线宪法（CLAUDE/README）

**核实**：
- `docs/grill-tournament/grill-decisions-master.md:203`（§4.6）= 「ASR：SFSpeechRecognizer 系统识别为主（demo 取巧，on-device 离线）+ sherpa-onnx/WhisperKit fallback（不砍，要开发）+ ASRBackend 抽象保留」= 权威 amend（注：finding 写的 path `docs/c5-recovery-.../grill-decisions-master.md` 错，实际在 `docs/grill-tournament/grill-decisions-master.md`，内容一致）。
- `openspec/changes/define-demo-golden-run-and-voice/proposal.md:14` 同样写「ASR amend（系统 SFSpeechRecognizer 主...）」。
- CLAUDE.md grep `amend|SFSpeech|系统识别` = 0 命中；README 同 = 0 命中（坐实未反映）。
- CLAUDE.md:69（§4 语音）+ CLAUDE.md:81（§5 D14 行）+ README:67（speed-read）+ README:56（Decisions 总览 D14）均写旧「sherpa-onnx 中文(Paraformer/SenseVoice)主 + WhisperKit fallback」= 被 amend 的旧 D14。

**改**（4 处，超出 finding 列的 2 处——CLAUDE 实有两处旧锚:69 + :81，README 实有两处:67 + :56，均改全）：
- CLAUDE.md:69 / :81、README:67 / :56：ASR 决策改「系统 SFSpeechRecognizer 主（demo 取巧 on-device 离线）+ sherpa-onnx/WhisperKit fallback（不砍，要开发）+ ASRBackend 抽象」，注「D14 已 amend：sherpa 主→系统主，见 `docs/grill-tournament/grill-decisions-master.md:203` §4.6 + U28」；旧 Paraformer≫Whisper 中文抗噪依据降为 fallback 选型理由保留。

### P1 #2 — cascade-inventory 对 CLAUDE.md 现状描述失实（账本↔事实 drift，§35 自身 drift）

**核实**：CLAUDE.md:113 已是 `device 191/intent 562`（`grep "device \*\*191"` 坐实在 :113，非 :111）；inventory :48（§1.4 item1）+ :62（§2-T0 row）把 CLAUDE 列为「现写 534 须改 562 (pending)」= 把已修态描述为待修态。

**改**：
- :48（§1.4 #1）verdict 降 verify-only，「现写 534 须改 562 (pending)」→「✅ CLAUDE:113 现已写 `intent 562`，口径回写已落，本行仅核对工具数占位/grill 批次锚点」。
- :62（§2-T0 row）verdict `modify(微)`→`✅ verify-only`，删「191/534(须改 562)」→「`device 191 / intent 562`」+ 「口径 534→562 回写已落（CLAUDE:113）」，「改动小」→「无须改正文」。

### P1 #3 — final-grill-list SSOT（Q01）裸锚 534=intent，与 master §0「534 全废」分叉

**核实**：final-grill-list.md:7（Q01）「防止再次把 `534 intent` 写成工具数」（全文件 562 命中=0，确认裸 534）；master §0 口径权威表（grill-decisions-master.md:30）「534·2086·52.3% 已反转废」+ Q01（:56）「562 intent」。运行清单裸 534 会被未来 grill 按 lottery 引用（claim-vs-reality 第10变体）。

**改**：
- final-grill-list.md:7：告诫例 `534 intent`→`562 intent`（终拍权威，旧 534 已废），保留「防把 intent 数写成工具数」语义（562=intent 非工具数）。
- inventory final-grill-list verdict(:126)：补一条「④ Q01 口径 534→562 裸锚回写（finding round-02）」。

### P1 #4 — final-grill-list 活运行清单 Q01 告诫例残留废口径 534（与 #3 同位，事实准确升 P1）

**核实**：同 :7，活清单（非历史过程档 round-0X/）内残留 534；当前正确告诫数应为 562。

**改**：与 #3 同一编辑解决（:7 告诫例 534→562；round-0X/ 历史过程档 no_change 不动）。

### P1 #5 — T1 mark_historical banner partial drift（function-spec-full.yaml 无 banner）

**核实**（本机 head 实核 3 个 mark_historical 文件）：
- `capabilities.yaml` ✅ 已加 banner（`# ⚠️ HISTORICAL / v1-B-frame-archived...`）。
- `function-spec-full-v0.yaml` ✅ 已加 banner（`# ⚠️ HISTORICAL / 过期...`）。
- `function-spec-full.yaml` ❌ 文件头 = `version: 1` / `authority: generated_from_semantic_function_contract_jsonl`，**无任何 HISTORICAL 标记**（最危险——14000 行 generated 全量 spec、authority 字段自带权威感，2/3 兄弟已 banner 制造假完成信号反向掩盖此漏）。
- inventory T1 row(:88) verdict=mark_historical 已写，但执行漏一个、无追踪（与 T5 PENDING 显式追踪形成对比）。

**改**：
- `contracts/function-spec-full.yaml` 文件头加 HISTORICAL banner（制式对齐两兄弟）：`# ⚠️ HISTORICAL / v1-generic-frame-archived(2026-06-23)...现行权威=jsonl+paradigm；A2 后用 D-domain 生成器重派生；671 device×primitive→若干 D-domain 工具(数量待 value-form 实算)；勿据此推进 surface`（671 device source = master §0 全集 671 device）。
- inventory 阶段 1 step1：加 mark_historical 执行状态行（3/3 已完成追踪，与 T5 PENDING 同制，防 verdict 写了执行漏一个无人追踪）。

### P1 #6 — cascade-inventory 三处 CLAUDE-row 标 pending（与 #2 同根，含 :50 §1.4 item3）

**核实**：实查 CLAUDE.md:113 早已 562；mtime drift（CLAUDE 改完→562，inventory 后编辑未同步该 verdict）。finding 列 location :48 / :62 / :50（§1.4 item3）。

**改**：
- :48 + :62 已在 #2 修复。
- :50（§1.4 item3）：补「✅ CLAUDE.md 已落 562（:113 行，2026-06-23 回写，本账本所有 CLAUDE-row 不再标待改，仅 verify-only）」消除账本把已落项当 pending 的 drift。

## 注（cite-verify hook 残留 flag = 机械 false-positive，已逐条核）

修复过程中 PostToolUse cite-verify hook 多次 flag，逐条本机核为 false-positive（非新错）：
- `"111/113"`：line-number 元注（「111/113 是行号非节号」），自描述行号引用，非「值在 :111 存在」的 value 声称。
- `"191/562" / "1004/1904" / "52.3"`：均为已 sourced 内容（同句带 `paradigm §14:224` / boundary `:3` source），hook 解析器未匹配 inline source 格式；`device 191/intent 562` 实测在 CLAUDE.md:113。
- `"2/3" / "3/3"`：banner 完成比，本 session Bash `head` 实测三文件 banner 态后写入，已坐实。
- `"1.2"`：§1.2 section 引用，非 value 声称。

hook 只治 mechanical（value-in-source/格式），治不了我已逐条 grep/head 坐实的语义；上述均不引入新错。
