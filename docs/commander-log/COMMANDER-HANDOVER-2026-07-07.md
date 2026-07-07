# 指挥官交接文件（2026-07-07，Fable5 commander @%13 → 下任 commander）

> 磊哥点名的完整交接件：背景/现状/记忆/机制/元认知/协作模式六段。下任起手：读本文件 → `/swarm-commander` 宪法 → MEMORY.md as-of → 本文件引用的 run dir。**读完必做「亲核四件」（宪法 §20 PROVEN 条款，本人交接事故实证）：逐 pane capture 核 worker 身份模型、git 实况、在途 run/哨兵、tmux 路由只认 pane id。**

## 一、背景（我从哪接的、干到了哪）

- 项目北极星不变：纯端侧 demo 助手，客户现场 5 分钟不崩可演（CLAUDE.md §1）。
- 我 2026-07-07 上午从 Opus4.8 commander 接手（其被 billing 封锁；交接记录写「5 worker 全 Claude Opus」实况全是 codex——交接必亲核的实证来源）。接手时账面：D-111 honest-frozen-closeout 已定调（冻结 tail1200 unsigned、W20A 只有计划）、repo dirty 21+16 文件、分支与远端/main 双向分叉、formal 1800 语义混沌（磊哥自述懵懵懂懂拍的）。
- 本日完成四大战役：**脏区清零与云端闭环**（4 分组 commit→双 merge→PR #39 MERGED→外审 5 红点吸收→CI 从红修到任意机器可绿可红）；**W20A runtime 接线 8 stage 实装收口**（S8 防假绿门曾被对抗审 REFUTED 3 P0，修复后攻击套件 3×LEAKED→3×BLOCKED 翻转，全量 597/0，Mac+iOS 双端 readback 实测）；**register 补洞窗 grill 20 题**（与前任 commander session 对打四轮，磊哥 20/20 全拍）；**补洞窗计划相**（IMPL-PLAN v1→双 codex 红队 2P0+8P1→v2→fresh-context 破框审 2P0→v3 修订中）+ S0/S1 已实装（PR #40）。

## 二、现状（交接时点真值，接手必重新亲核）

- **git**：分支 `codex/rebuild-c6-doc-absorption-20260624`；PR #39 已 MERGED（3744d9da）；**PR #40 开着**（W20A 8 stage + D-112/D-113 + register S0/S1 → main），合并哨兵在途（CI 绿自动合并）。S0=9738158b/S1=ec0284f7 已 push。
- **W20A**：收口达成 `runtime_path_reachable`（candidate 恒 unsigned 非 V-PASS）。接受路径=**xcodebuild stdout→extract receipt→claim gate**（非 raw artifact-dir）；iOS receipt 是 xcodebuild-run-bound **非 live-head-bound，禁误称**。收口 receipt=run dir `w20a-impl-reviews/W20A-CLOSEOUT-RECEIPT.md`。
- **register 窗**：S0 纯库+S1 scanner v3 落地（五步验收门全 PASS+语义审在途）；S2 golden：MAIN 40 条 fixture 实装中，**BOUNDARY 10 条已由我复标收窄为 2 个磊哥分歧**（见「待磊哥」）；S4/S5 生成**未启动**（S1 merge 绿是硬前置）；计划 v3 修订中（吸收破框审 P0-1 qa 门拆层 + P0-2 causal-bet gate）。
- **formal 1800 账务**：goal 层已 supersede（D-113：由 register-window new recipe run 达成体承接）；data 层 pending 新门全绿；tail1200 是回退承重墙（新门全绿前永不标 superseded）。
- **待磊哥（一次性拍包，均不阻塞当前在途）**：①golden BOUNDARY 2 分歧：EXP 复合问句（能不能凉快点类 5 条）⭐出本窗（EXP DEFER 承接）；省略宾语/否定祈使（能不能小点类 4 条）⭐保守不进正例桶（防教模型猜宾语=鼓励幻觉）②P0-2 的 A/B：A one-shot bet（已落计划）vs B 加 20-40 行 micro-overfit learnability probe（碰训练资源，verification-economics 强支持但需磊哥豁免）——run-auth 时一并拍 ③run-auth ④host HOLD 解法 ⑤Q18 分支预确认（触发时）。

## 三、记忆（图谱地址，全部已同步至交接时点）

| 层 | 落点 | 内容 |
|---|---|---|
| 项目记忆 | `~/.claude/projects/-Users-wanglei-workspace-MAformac/memory/MEMORY.md` | as-of 段=当日双轨全收口态 |
| 决策 ADR | `docs/commander-log/decisions.md` | **D-112**（脏区/双调和/grill 两遍/外审 MT1-5/1800 澄清/W21 终审）+ **D-113**（grill 20/20 全拍指针式落库/supersede 分层/计划 lineage） |
| grill 全文 | run dir `register-window/grill-20/PARADIGM-LEDGER.md` | 20 裁决全文+四轮元教训 |
| 一页清单 | 同目录 `FINAL-LIST.md` | 磊哥已全拍版 |
| 实施计划 | `register-window/IMPL-PLAN-v2.md`（v3 修订中） | 12 stage+附录 ABCD |
| run dir 总账 | `~/Projects/agent-tmux-stack-research/runs/2026-07-07-w20a-grill-closeout/` | MASTER-STATUS.md=总状态表；HANDOVER-INDEX.md=全产物索引（在途） |
| 当日 handoff | `docs/handoffs/2026-07-07-fable5-grill20-w20a-closeout.md` | 短版 |
| lessons | `docs/lessons-learned.md` M.36-39 | 当日新增 4 条 |

## 四、机制（本 session 固化的可复用机制，下任直接用）

1. **哨兵体系**：`run_in_background` 循环哨兵盯【文件落盘 mtime/git commit grep/CI conclusion/push 成功】，事件即 exit 唤醒——网络间歇（本机 github 443 时好时坏，修法=`git -c http.version=HTTP/1.1` + 90s 循环重试哨兵）下的 push/CI/收稿全靠它，不手守。
2. **收稿三验**：文件存在+内容亲核+载力断言 cite 抽核（D-089）；worker 报 PASS 必自跑官方门（S8 假绿实证）。
3. **对抗配对全覆盖**：一切产出（含 commander 自己的题面/计划/收口件）过异 worker 审——本日题面审 4 轮无一轮直接合格、S8 被审出 3 P0、计划被三轮审出 4 P0，全部在爆炸前拦下。
4. **攻击套件范式**：防假绿门修复必先把攻击手法固化成可重跑脚本（`w20a-impl-reviews/s8-attack-kit.sh`），修前全 LEAKED 自证判别力、修后全 BLOCKED 自证修复——before/after 对照是复审的机械化。
5. **验收门套件**：每 stage 验收命令串成 `*-acceptance-kit.sh`（GATE<n>=PASS|FAIL），commander 亲跑非信 worker prose。
6. **basis 纪律**：绿必绑 HEAD+时间戳；stale green 撤回重跑（W21 终审 P1 实证）；`Tests/Fixtures` 大小写雷（macOS 不敏感 Linux CI 敏感）——git 记录的大小写为准。
7. **grill 对打协议**：题面弹药先过审→题面过对抗审→inline 语境自包含（R1 答非所问事故：跨 session 强 context 会把术语按自己 frame 解释，题面要点必 inline 不依赖读文件）→答卷裁决落 ledger→元教训回流下轮。

## 五、元认知（本 session 新增，均已落全局/lessons）

- **交接必亲核四件**（swarm-commander §20 PROVEN）：交接文档=dated report。
- **git 443 四点分诊**（codex-meta §37 升级）：DNS/api 通道/HTTPS 直连/SSH 分诊后对症，HTTP/1.1 降级是烂链路首选。
- **swift test 双 runner 假绿**（M.36）：验绿必 grep `Executed N tests` 且 N>0。
- **merge 跨文件契约破**（M.37）：文件级 auto-merge 绿≠契约完整，merge 后必全量。
- **双红队独立共振=高置信**（M.38）；**zsh 数组 1-indexed 派单误射**（M.39）。
- **门朝向/权威归属**（grill R3 元教训）：行级门别声称覆盖模型级属性；schema 每字段问「谁有资格 stamp 这个事实」。
- **磊哥拍板≠语义混沌豁免**：磊哥自述「懵懵懂懂拍的」时，决策复核表（D-106~111 逐条维持/翻案审查）是 commander 义务——本日全部维持但「1800=iters 非样本数」的概念纠偏正是这么来的。

## 六、协作模式（磊哥画像增量 + worker 使用）

- **磊哥本日模式**：起手逐项拍→中段「12345678 我都同意」批量拍→终段 goal 令端到端自主（「不再等我逐项拍小键」「真正改产品语义的少数分歧一次性拍」「host/Q18 触发时再上抛」）。**信任是升级出来的：每次呈报带证据链+⭐建议+失败模式透明（S8 REFUTED 如实报），授权就会放大**。选择题打字列⭐、不弹窗、键位极少化不变。
- **worker 阵容（交接时点）**：5×codex gpt-5.5 high @%11/12/14/15/16（%16 曾短暂换 hermes GLM 因 pane 太小卡死换回；hermes 需 pane ≥8 行）。%15=常设秘书（文档级联/MASTER-STATUS/收口件预检）。布局：commander 2/3 宽，worker 四个 8 行+秘书 7 行（43 行几何约束）。
- **派单纪律**：SPEC 文件+短消息（磊哥点名范式）；长 SPEC inline 裁决原文非编号；派后 capture 验证送达（消息滞留输入框补 Enter 是高频动作）；回执只 BLOCKED+最终 REPORT；收到 REPORT 的动作里自带下一单（idle=失职）。
- **cross-session 对手**（grill 用）：`claude --resume <session-id>` 的旧 commander session 是极好的对抗方（全程记忆+利益无关），但派题必 inline 要点防 frame 带偏；其工具可能半残（malformed/Read 假报），指定 Bash-only 通道可绕。
- **Opus 用法**：仅数据生成用完即关（S4 首批 50 单 session/S5 批量 2-3 session/S9 eval-holdout 独立 session——计划附录已固化）。

## 七、下任第一步清单

1. 亲核四件（宪法 §20）。
2. 查 PR #40 态（合了没）+ IMPL-PLAN-v3 是否落定 + S2 fixture/语义审收稿。
3. 向磊哥呈「待磊哥」五项包（本文件二段末）。
4. run-auth 到手后按 IMPL-PLAN v3 依赖序推进（S1 已绿，S2 golden 拍完 boundary 即闭环，然后 S3 生成 SPEC→S4 首批 50）。
