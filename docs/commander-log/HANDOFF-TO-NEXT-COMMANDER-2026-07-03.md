---
authority: commander_to_commander_full_handoff
from: claude-commander %42（Fable 5，2026-07-02 日班接管 → 07-03 通宵收官）
to: 下一任指挥官（压缩后重生的我，或全新 session）
created: 2026-07-03 凌晨
必读顺序: 本文件 → docs/CURRENT.md → 晨报 docs/handoffs/2026-07-03-overnight-v6-verdict-morning-brief.md → commander-log/decisions.md D-015~039 → v6 verdict
---

# 指挥官全景交接（2026-07-03）

## 0. 你是谁、在哪
你是 MAformac 的 **claude-commander**，tmux session `ma-status-swarm` pane **%42**，指挥 3 个 codex worker（gpt-5.5 high）。磊哥定位你是「上帝」：**纯编排不执行**，一切执行下沉 worker，你负责派单/亲核/裁决/记忆维护。压缩后重生先读 `COMMANDER-INDEX.md` + 本文件。

## 1. 协作模式（磊哥拍定的铁律，别退化）
- **swarm 拓扑**：tmux 2×2 = 1 commander（%42）+ 3 worker（%44=codex-1 / %45=codex-3 主线树、%43=codex-2 uiue 树）。**不 reflex-spawn subagent CC 干 worker 的活**（磊哥截图纠过）；subagent CC 仅终极 cross-vendor 审计用，且本晚磊哥明确「审计就让 3 worker 交叉互审，不派 hermes/gptpro，下个 hermes 审计点等通知」。
- **派单纪律**：SPEC 文件（复杂任务）或 self-contained 长消息（inline SSOT 关键决策+file:line，不只给指针）；ID 段分官职；「BLOCKED 或终稿才 REPORT %42」写进每单；**收稿以 output file 为准，口头 REPORT 不算**；硬三件=output file+证据表+residual risk。
- 🔴 **tmux 消息四步 SOP**（L.5，两次实证）：`send-keys -l "$MSG"` → 单独 Enter → sleep → capture 验证进对话流。别把 tmux 消息和 gh 写操作混一条命令（拒批连坐消息静默丢）。worker 回写也可能停输入框——见 idle 无 REPORT 先 capture 查滞留，必要时替它补 Enter。
- **worker 卡死救援梯**（PROVEN）：ESC→C-c→`kill $(pgrep -P pane_pid 的 codex child)`→codex 重启→self-contained 重派。识别特征：`0 in · 0 out` 且 Working 计时走但零 token 流动。
- **磊哥偏好**：中文、称磊哥、选择题打字列+⭐（不弹窗）、sleep 轮询 ≤5min、worker context 不用管（自动压缩牛）、codex 额度管够 worker 绝不闲置（空了立即填 backlog 打杂：文档/预研/归档/形态分析）、不要频繁发消息问他、**不卡壳全自动**。

## 2. 三个 worker 的画像（本晚 ~20 单实战观察）
| pane | 树/分支 | 画像 | 用法 |
|---|---|---|---|
| **%44**（codex-1） | 主线树 rebuild-c6 分支 | **工程主刀**。P3H harness 全链作者（v1→v2→v3），两轮训练+probe 执行者。执行力最强、REPORT 最规范（结构化 key=value）、机械修复快且顺手补回归测试（mlx_lm API 兼容）、诚实（residual 从不漏写）。 | 关键路径重活/真跑/训练/harness/需要 background 长命令的 |
| **%43**（codex-2） | **uiue 树** phase4 分支 | **最强审计官**。PR26/P12 交叉审全抓真 P1（自己构造 bypass 探针）；消减稿机械展开核对两轮各抓一漏（GF-126→GF-148）；D 轴退化形态图出「query→actuation 安全级」发现；还会纠 commander 口误（SPEC 计数）。 | 交叉审/异源核对/形态分析/drift 排查/机械 PR 操作。注意它在 uiue 树，不派主线代码实装 |
| **%45**（codex-3） | 主线树 rebuild-c6 分支 | **契约与数据主刀**。P12 A+ 契约作者、G7 桥接/surface 修复、wave-1 proto 4500 build。产出质量高、量化分析强（长度违规三解模拟）。⚠️ **有卡死史**（本晚两次 0-in-0-out 死循环，救援梯有效）——长跑时多盯；且**习惯不 commit**（两次交付裸挂 working tree，收稿必查 git status）。 | 契约/数据/生成管道/量化分析。派单加一句「完成即 commit」 |

交叉互审对抗 fixture 破双盲是磊哥点名满意的范式（memory: feedback-swarm-worker-usage-pattern）——%43 审 %44/%45 的产出、%45 修自己被 %43 审出的 finding、commander 亲核裁决，全晚跑通 5 轮零虚审。

## 3. 本次会话干了什么（jsonl 沟通重点，按时序）
1. **磊哥通宵 /goal 全授权**（原文已转写 `docs/project/phase0/r-l17-human-review-evidence/v6-overnight-run-auth-2026-07-02.md`）：tiny 跑完+wave-1 真生成+数据门+A+ 五件+镜像门+worker 硬三件+遇问题先 grill/iceberg+审计 worker 自理+不卡壳。
2. **Phase 1-3 收口**：P12 A+ 契约（镜像门 old v5 exit66/new v6 exit0 我双亲核）+ P3H harness（v1 亲核抓 P1 truncate 前导换行→v2）+ P3D 四轴探针设计收割。
3. **v6 训练真跑**（600 iters loss 0.072）→ probe 全 empty → **四步排除法**（prompt 面一致→loss shift 对→labels 对齐 17/17→teacher-forcing 17/17 满分）→ 实锤 **probe 没挂 tools**（训练面带 E-2 两级挂载 737 token）→ harness v3 挂载修复。
4. **v6-probe2 出 verdict**：**A 轴 adapter 15/15 满分 =「A+ 契约是否解 v5 NO_TOOL」YES**；B 11/15（close 极性翻转+细分设备=数据稀疏）；paired 配对暴露 D delta -10 过拟合窄化（磊哥六拍④当晚兑现）。
5. **v6.1 EOS 增量**（GF-153）：重训+probe——A 保持满分、重复病理 68/68→1/68。
6. **wave-1 推进到只差凭证**：G7 mock 端到端、labeler slots 桥接、行级 surface 字段贯通+missing_surface 硬门、**proto 4500 行 build+C5DataGate 全量 exit0 全零**、长度违规 294 条量化解（E-2 降档挂载全收 max 1793）。
7. **governance-fit grill 三官 121 决策**（W1 契约/W2 门与词表/W3 制度）+ GF-141~156 两轮 harness grill + 消减 31 组终审 APPROVE_FOR_UPLIFT（映射 136/136）。
8. **第四轮 iceberg**：same-surface 是复合对象→维度分解表治理；扩散点（G7 生成行缺 surface 字段）当晚闭环。
9. **杂项**：drift 27 条批量回写、CURRENT/MEMORY/lessons M.8-10/宪法 §9.x 级联、run 目录 INDEX×2、%45 两次卡死救援、PR 26/27/28 开出+双审 APPROVE。

## 4. 当前进度 & 卡点
**进度**：通宵 goal 可兑现项 100% 兑现（详见晨报 goal 兑现账表）。决策 D-028~039。
**卡点（全部是磊哥层输入，非技术）**：
1. 🔴 **GitHub billing/spending limit**——三 PR CI 全 FAILURE 均此因（annotation: account payments failed / spending limit）。磊哥修 billing → CI 重跑即绿（代码层 whitespace 已修）。
2. 🔴 **wave-1 云凭证**——Anthropic generator + OpenAI judge 的 env/key/模型 ID 不在 repo，live 生成路径代码有意 fail-closed 等接线。
3. **PR merge 权限**——classifier 拒 commander 自合（合理），三 PR 双审 APPROVE 在案等磊哥一键。
4. （小）sibling UIUE fixture hash drift 使 repo-wide swift test 5 failures（非回归，M4 收口消解）。

## 5. 树与分支全景（2026-07-03 凌晨 git 一手）
**活跃（别动/待合）**：
- 主线树 `MAformac` @ `codex/rebuild-c6-doc-absorption-20260624`——**commander 决策/grill/verdict 全在此，领先 main 77 commits 未 push**🔴（下任第一要务之一：push + 开 docs PR，或磊哥拍直接合）。untracked：runs/（仓外证据镜像）、XSWAP-23-fix.md、.xcodebuildmcp/、Tools/agent-platform-plugin-refs/（历史遗留，别误 commit）。
- `MAformac-p3h-probe` @ codex/p3h-probe-harness-20260702 = **PR #26**（clean）
- `MAformac-p12-loss-contract` @ codex/p12-v61-eos-span-20260703 = **PR #28**（含 #27 的分支历史；worktree 现在 checkout 的是 v61 分支）
- `MAformac-p5w-wave1-bridge` @ codex/p5w-wave1-bridge-20260703 = G7 surface+hardgate，**收工时刚令 %45 commit+push+开 PR（查收！）**
- `MAformac-uiue` @ uiue/phase4 = %43 驻地，M4 待收，R7 blocks uiue_merge
- `MAformac-m1g` @ main = 干净 main 镜像
**历史/清理 backlog（M2，磊哥未授权删除，绝不直合——分支 tip 落后会回退 main）**：g2-mask/g5/g6/g7/g7a-d/g8-tool/grill/w1/w2/p1fix/p2c6/p2g7/rat/.d24×3/.d25/.step0/.tiny-ablation/hermes-audit + /tmp 若干 detached。

## 6. 云端 PR & 合并路线（依赖序）
| PR | 内容 | 状态 | 合并序 |
|---|---|---|---|
| #26 | P3H probe harness v1-v3 | 双审 APPROVE（%43 两轮）、CI 待 billing 重跑 | ① 独立可先合 |
| #27 | P12 A+ 契约+镜像门 | 交叉审→修复→Fix Re-review APPROVE、whitespace 已修 | ② 独立可合；**是 wave-1 拍点#1 的前置**（wave-1 pin 它合入后的 main） |
| #28 | v6.1 EOS 监督 | 基于 #27 分支 | ③ 在 #27 后合（或 rebase） |
| (new) | G7 surface+hardgate（p5w） | %45 开 PR 中 | ④ wave-1 live 前置，需一轮交叉审（%43） |
| (new) | commander docs 77 commits | 未 push | ⑤ 或磊哥拍直接快进合（纯 docs） |
**路线**：billing 修复 → CI 全绿 → 磊哥按 ①②③④⑤ merge → main 即具备 wave-1 全前置 → 云凭证接线 → wave-1 live。

## 7. 后续规划（本地关键节点，按依赖序）
1. **磊哥晨拍 0-5**（晨报清单）：billing → merge×3(+2) → wave-1 7 拍点（含长行 E-2 降档⭐/valid-test 监督契约）→ GF 137 决策 lock → F-044 阈值终值。
2. **wave-1 live 生成**（凭证到位后）：G7 pipeline（Anthropic gen + OpenAI judge 跨厂商）→ C5DataGate 全量 → 自然句数据并入（协议串底座 4500 已 ready）。配方锚（verdict 附录）：E-2 降档挂载/open-close 极性对称/query 反执行负例/D 轴退化 regression 锚/多 call 配对样本。
3. **wave-1 训练**（新 run-auth，R7 candidate 线仍 unsigned）：控 epoch/early-stop（tiny 218-epoch 等效过拟合是反面教材）；B/D 轴提升是目标，A 轴满分是 regression 底线。
4. **C6 acceptance/candidate comparison**——仍 BLOCKED 等 candidate signoff（R7 route-only 至 07-23）。
5. 挂起：M2 树清理（盘点好等授权）、M3 D25 receipts、M4 UIUE 收口、hermes 下个审计点（磊哥通知制）。

## 8. 记忆与经验教训索引（你的外脑）
- **MEMORY.md** as-of 已刷到本晚终态；worker 画像 memory 新增（见 memory/ 目录）。
- **lessons-learned.md**：K/L/M 段全在；本晚新增 L.5（tmux 送达）+ M.8（same-surface 维度分解表）+ M.9（复算工具假信号）+ M.10（paired 信息增益）。
- **宪法 `~/.claude/commands/swarm-commander.md`**：§8 外审 worker 化/救援梯/报告频率；§9.x 消息送达 SOP；P0 双 LLM 辩证条款。
- **verdict 及三附录** = 训练线的技术真值；**FINAL teardown + iceberg round4** = 方法论真值。
- 元认知快捷键：遇失败先四步排除法（每步一手复算）；「same-X」声称必展开维度表；机械修连续 3 次触发 fit-spot（GF-2xx D9）；写数字必 cite 源（v5 教训 receipt 全带命令）。

## 9. 下任立即动作清单
1. 读 CURRENT + 晨报 + 本文件恢复上下文（≤10min）。
2. 查收 %45 的 p5w PR 是否开出（我收工前最后一单）；未出则按 §5 保护现场。
3. 磊哥醒 → 按晨报 0-5 走拍板流程；拍完按 §7 依赖序推进。
4. worker 三个在待命（pane 存活）；重启派单前先 capture 各 pane 确认状态；%45 记得「完成即 commit」提醒。
