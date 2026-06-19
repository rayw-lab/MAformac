# Handoff 2026-06-19 — change3 PR #1 + GPT Pro 审计 REQUEST_CHANGES(待整改)

## 一句话状态
change3 已开 PR #1(OPEN)+ GPT Pro(gpt-5.5 pro)8 维审计 verdict=**REQUEST_CHANGES**(catch 出 F2 真 bug)。CC1 已辩证分类(真 bug 必修 / 已知范围部分采纳 / 工程择优)。**下一步 = 写整改 dispatch 派 Codex**(上次写到一半被工具 bug 打断未存成,需重写)。

## git 状态(关键)
- 当前分支 `feat/change3-execution-contract`(f46ef88),工作树干净
- 本地 main = 云端 main = 99c49fa(已对齐;change1/2 + spike 已推云端)
- **PR #1** https://github.com/rayw-lab/MAformac/pull/1 (base=main 99c49fa ← head=f46ef88, OPEN)
- **GPT Pro 审计报告**:`~/Downloads/pr_audit_1(1).md`(21k,magnet 已下载,起手必读)

## 本 session 完成(超长高密度)
1. **change3 对抗审计 PASS**:Codex 实装(638e520)→ CC1 **自跑核实**(swift test 33/33 真绿非自报)+ 6 catch 客观全过 + DemoGuard schema 门/fixture 真实性逻辑核实。
2. **Codex 幻觉事件查清**:Codex 报告一个不存在的 commit(9863b9f)+ archive,真实仓库干净 → 沉淀多 agent 三纪律。
3. **多 agent 协作 pre-mortem**(oracle 联网 + 本机 superpowers):无银弹框架,模式优先。**三纪律**(一 agent 一 worktree 一分支 / main 单写者 / 强制 ground-truth git 验证)已入 `docs/dispatches/_TEMPLATE.md`。
4. **红线校准**:magnet 定 private + 内网 + demo 优先,红线不洁癖;lessons §B3 脱敏完成(奇瑞/yangliu104 仓里本就零命中,真红线只 T19CFL/E0V 车型代号)。
5. **change3 PR #1 上云**:git 安全流程(避 reset hook:push `99c49fa:main` + feature branch),GPT Pro 审计派发(audit_pr.py + watcher,自动启 GitHub connector 实读 PR)。

## GPT Pro 审计辩证分类(CC1 已做,= 整改依据)
**🔴 A 真 bug(我们盲点,必修)**
- **F2** executor 硬编码参数优先级(`Core/Execution/DemoActionExecutor.swift:33-49` `desiredMockValue` 取 `["power","level","percent",...]` 第一个 scalar)→ `set_cabin_ac{power:on,target_temperature:25}` 只写 power、温度丢 → **readback 实际错**(违 readback mismatch=0)。
- **F3** referenceBinding.allowedValues 未进 guard(power:unchanged 可能写入 state)。

**🟡 B 已知范围(GPT Pro 不知我们 change 切分,部分采纳)**
- **F1** schema-valid 负例可执行 = 我们已知的 **DemoGuard schema 门 ≠ 语义拒识门**(design T9);intent gate 归 **intent-routing(第7 change)**,非 change3。**但采纳**:Codex 把 content-fallback 默认开了(executedCount==43 含负例执行),偏离 design"可配置开关" → 改**默认关**(fail-closed)+ 测试 isNegative 零执行断言 + N002/N016/N017 作 known-issue(非主成功口径)。

**⚪ C 工程择优**:F4 JSON string 内花括号 scanner(改 JSONDecoder 整体)/ F5 decoder-guard reason 统一(SchemaViolationReason)/ F6 codegen drift check / F7 CI(demo 部分豁免,但 swift test + drift Action 值得加)。

## 下次第一步(明确)
**重写 change3 整改 dispatch** `docs/dispatches/2026-06-19-change3-gptpro-fix.md` 派 Codex:
- **P0**:F2 executor 多参数语义(capabilities.yaml 加 mock transition spec 或按 schema 字段落地,删硬编码 key 优先级)+ content-fallback 默认关 + 测试 fail-closed(isNegative 零执行)
- **P1**:F3 allowedValues 校验 + F4 JSONDecoder 整体 decode + F5 reason 统一 + F6 codegen drift check
- **归 intent-routing(第7)**:F1 intent/restraint gate(change3 只留 `intentConfirmed` hook 点)
- **🔴 Codex 用隔离 worktree**(三纪律首次实践):`git worktree add ../MAformac-change3-fix feat/change3-execution-contract`,dispatch 写死 cwd=该 worktree,只在 feature 分支 commit,报告附实跑 git stdout
- 整改后 push 更新 PR #1 → GPT Pro 复审

## 机制沉淀(本 session,深度 learn-eval 下个对话)
- **多 agent 三纪律**(已入 _TEMPLATE.md):worktree 隔离 / main 单写者 / ground-truth git 验证(防 Codex 幻觉)。
- **cross-vendor 审计价值兑现**:GPT Pro 独立 catch F2(我们 self-audit 盲点)。Layer1(CC self-audit)+ Layer2(GPT Pro cross-vendor)互补。
- **辩证吸收**:不盲从 GPT Pro(F1 是我们已知范围切分),采纳真 bug(F2)+ 实装偏离(content-fallback 默认开)。
- **工具 bug**:本 session Write/Bash 工具调用多次 malformed(渲染成文本),长 content Write 易触发,下次写文档分段或精简。

## 🟡 demo 边界
不接真车;量产标准(ISO26262 / CI gate / 端云 / QPS)豁免;安全门思想 / 参数规划 / 读 mock 态 / LoRA 保留。

## 待办小尾巴
- `feat/lora-dataset-build`(97f3f92,lora 数据层 3670 条 + 脱敏 blocklist)+ stale worktree(`git worktree prune`),后续 merge 你定
- 整改 dispatch 需重写(工具 bug 未存成)

## 起手读
CLAUDE.md → 本 handoff → `~/Downloads/pr_audit_1(1).md`(GPT Pro 全报告)→ `docs/dispatches/_TEMPLATE.md`(三纪律)→ `openspec/changes/define-execution-contract/design.md`(T9 DemoGuard 边界)

## 环境
M5 + Swift 6.3.2;change3 契约层 `swift test` 不需 metallib/Simulator;Chrome-Automation(CDP 9222)已起(GPT Pro 桥);gh auth=RayWong1990(admin rayw-lab/MAformac private)。
