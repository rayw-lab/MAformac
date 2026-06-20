# nano-step/eval-harness 工程/算法 teardown — MAformac C6（failure receipt）直接抄的现成实现

> **缘起**：磊哥要求深扒 `nano-step/eval-harness`（MIT，单作者 Hoài Nhớ，README 对齐 v0.4.2）——一个 **bash-first 的「skill 行为回归检测器」**：跑结构化 eval case，对比已 commit 的 baseline，**回归 → 给出可归因、可复现、带修复建议的 6 字段 FAIL 收据**。clone 在 `~/workspace/raw/05-Projects/MAformac/ref-repos/nano-eval-harness`（CLAUDE §6：只读参考，不进仓；MIT 但红线照旧——**翻译成 Swift 设计思想，不 import bash/jq 链**）。
> **本文 = 逐文件拆解**（lib/ 15 文件 + 8 顶层脚本，runtime/算法核心全读，带行号）。
> **核心结论**：eval-harness 把"一次 eval run"做成了一条**收据流水线**——每个 check 产单条结构化结果、每个 FAIL 自带 `expected/actual/diff_hint/transcript_span/env_delta` 六字段 + 4 类归因 + 一行 rerun 命令；**回归 ≠ 失败**（只有 `baseline=PASS → current=FAIL` 才算回归）；**flaky 用 3 样本字节同一性判定**；**FAIL 时跑全部 check 不短路**；**warn-only 默认 + 7 天绿才 promote 成 blocking**。逐条都是 MAformac C6（vehicle-tool-bench failure receipt）该抄的工程形态。它的所有"让结果可信"的智慧不在 README，在 `score.sh`/`diff.sh`/`stability.sh`/`manifest.sh` 的字段设计里。

---

## §0 全局数据流（一图看懂收据怎么生成）

```
run.sh（编排）
  ├─ preflight_check         先验环境（opencode 在不在 PATH / 有没有 cred）→ 不过直接 exit 13（harness error，非 skill 回归）
  ├─ apply_mode_defaults     smoke=cheap模型+samples1 / full=贵模型+samples3 / 2tier=先smoke失败再升full
  ├─ pricing_staleness_check 价目表过期 → WARN（可选硬停）
  └─ 逐 case:
       ├─ 物化 fixture（path-traversal 守护：拒 / 开头、拒 .. 、规范化后必须落 workdir 内）
       ├─ flock 互斥锁（per skill:case:trigger）
       ├─ capture_manifest    指纹环境（model_id / skill_sha / skill_bundle_sha / fixture_sha / opencode_ver / platform）
       ├─ spawn_opencode      ephemeral 沙箱（全新 HOME/CONFIG_DIR/cwd + OPENCODE_EVAL_MODE=1）+ timeout(1) 包裹
       ├─ run_all_checks       ★跑全部 check 不短路，每条产单结果 JSON → checks.json
       ├─ [FAIL 时] 3 样本 stability → 字节同一 = real FAIL；分叉 = flaky
       └─ build_case_result    把 checks + manifest-diff(env_delta) + attribution + cost + stability 缝成单 case 收据
     build_run_summary         聚合 → verdict = REGRESSION(baseline绿翻红) | FAIL(无baseline或新红) | PASS
     render_diff_md            人读 markdown：回归段 / 失败明细段（含 fix_proposal）/ 稳定段
  exit: 0=PASS / 12=REGRESSION且已promote / 13=harness error
```

**MAformac 直接复用的轴**：把"一次 bench run"换成"一次 vehicle-tool-call eval run"，把"skill 文本输出"换成"模型产的 ToolCallFrame 集合"，整条流水线照搬。

---

## §1 `lib/score.sh`（365 行）— check 执行核 + 单条结果 schema（最重要）

这是"每个 check 产一条结构化结果"的源头。MAformac C6 的 per-check 收据 schema 直接对照这里。

- **★ 全跑不短路（line 2-3 注释 "Settled Decision #18"）**：`run_all_checks`（line 319-355）`while` 遍历所有 `.checks[]`，**每条独立 `run_check` 不 first-fail-exit**，最后 `map(.passed) | all` 聚合。→ **一次 run 看到所有失败点**，不是改一个跑一次。对 MAformac：一条话术失败时，"意图错 / 槽错 / device 错 / 安全门没拦"应**一次全报**。
- **★ 单条 check 结果 schema（贯穿所有 score_* 函数）**：每个 check 都产
  ```
  { kind, passed, failed_check_id, expected, actual, diff_hint, [transcript_span], [error] }
  ```
  这 7 字段是收据的原子单元。`failed_check_id` = `"<kind>:<标识>"`（如 `shell:jq -r ...`、`output_contains:<needle>`）→ **稳定可 grep 的失败指纹**（line 77/116/216）。
- **6 种 check kind**（line 23-53 dispatch）：`shell`（命令+期望）/ `jq_path_contains`（JSON 路径含必需值）/ `file_exists` / `output_contains` / `output_not_contains` / `llm_judge`。**未知 kind → 产 `error:true` 的失败收据**（line 43-52），不是崩溃。
- **★ shell 安全过滤器 `score_shell_is_unsafe`（line 56-61）**：正则拦 `$(` / 反引号 / 重定向 / `; & |` / 危险二进制（`rm/curl/wget/sudo/chmod/dd/eval/exec/source/...`）。命中 → 产"被安全过滤器拒绝"的失败收据（line 71-84），除非 case 显式 `unsafe_shell: true` 或 `EVAL_ALLOW_UNSAFE_SHELL=1`。**威胁模型 = 自己写的 case YAML，不是任意用户输入**（KNOWN_ISSUES BLK-2 的修复）。
- **★ `output_not_contains` 的空 transcript 守护（line 270-288）**：transcript 缺失/0 字节 → **不 vacuous-PASS**，而是产 `error:true` 的 FAIL，`diff_hint` 明说"通常意味着 opencode 没启动/崩了/被 timeout 杀了"。这是 BLK-7（"完全没跑成功却负向检查全绿"）的修复——**否定式断言必须先证明产物存在**。
- **`jq_path_contains` 的集合差（line 147-154）**：`($required - $actual)` 算缺失元素，`diff_hint: "missing from <path>: <missing>"`。→ MAformac "应产工具集 vs 实产"的差集报告直接套。
- **`output_contains` 带 transcript_span（line 197-222）**：`grep -n` 拿行号 → `transcript_span: {start_line, end_line, transcript_path}`。**失败可一跳到 transcript 具体行**。
- **`llm_judge`（line 226-268）**：仅当其他确定性 check 不够（prose 输出）才用；走 `llm_judge_majority` 多样本投票（见 §6）。artifact 截断 `head -c 8000`（line 237/239）防超长。
- **autofix 挂钩（line 330-332）**：`EVAL_AUTOFIX=1`（默认）时每条结果过 `propose_fix` 加 `fix_proposal`（见 §7）。

> **MAformac C6 直抄**：per-check 7 字段 schema（含 `failed_check_id` 稳定指纹 + `transcript_span` 跳转锚点）、全跑不短路聚合、未知/异常都产收据不崩、否定断言先证产物存在。

---

## §2 `lib/diff.sh`（213 行）— 6 字段 case 收据 + 回归判定 + 人读渲染（C6 收据的核心）

这是 case 级收据的缝合处，**MAformac "failure receipt" 一词的直系来源**。

- **★ `build_case_result`（line 15-90）= 单 case 6 字段 FAIL 收据**（line 2-4 注释 "Settled Decision #4：6-field schema"）。缝进一个 JSON：
  ```
  { case_id, passed, baseline_passed,
    checks,          ← §1 的逐条结果数组
    env_delta,       ← manifest 差异（什么环境变了）
    attribution,     ← 4 类归因（§3）
    stability,       ← flaky 判定（§5）
    env_manifest,    ← 当前环境指纹
    cost,            ← token→USD（§4）
    rerun }          ← 一行可粘贴的复现命令
  ```
- **★ `baseline_passed` 是回归判定的全部根基（line 28-36）**：读 `baseline.json` 的 `.passed`，并 `diff_manifests` 出 `env_delta`。**没有 baseline → `baseline_passed=null` + `env_delta.keys_changed=["__no_baseline__"]`**（不是崩溃，是诚实标"无基线可比"）。
- **★ 归因只在 FAIL 时算（line 38-41）**：`passed==false` 才 `attribute "$env_delta"`，否则默认 `UNKNOWN_DRIFT`。省算力 + 语义干净。
- **★ flaky 后置改写 attribution（line 59-65）**：FAIL 且 stability `performed && !byte_identical` → 给 attribution 注 `{flaky:true, note:"stability samples diverged — attribution may not be reliable"}`。**不可信的归因被显式标注，不是静默信任**。
- **★ rerun affordance（line 43）**：`bash scripts/eval/run.sh --case=<id> --skill=<...> --debug --pin-env=baseline` 嵌进每条收据。**每个 FAIL 自带"怎么单独复现我"**——这是 eval 工具最被低估的人体工程。
- **★ `build_run_summary` 的 verdict 三态（line 105-110）**：
  ```
  regression_count>0  → REGRESSION   （baseline_passed==true && passed==false，line 102）
  elif fail>0         → FAIL          （新失败 / 无基线）
  else                → PASS
  ```
  **REGRESSION 与 FAIL 分开是关键设计**：第一次写 case 必然 FAIL（无基线），那不该等同于"我把好的搞坏了"。MAformac bench 同理——新增覆盖 case 的红 ≠ 已有能力的回归红。
- **`total_cost_usd` 聚合（line 112-113）**：`[.[].cost.usd // 0] | add`。
- **★ `render_diff_md`（line 144-201）= 人读三段式**：① REGRESSION 段（attribution + env_delta keys + 失败 check id + rerun 代码块）② FAILED CHECKS 全明细段（expected/actual/hint + **fix_proposal**）③ STABLE 段。机器吃 `results.json`，人吃 `diff.md`，**双产物**。

> **MAformac C6 直抄**：case 级 6 字段收据结构、REGRESSION≠FAIL 的三态 verdict、rerun affordance、flaky 显式降信、机器 JSON + 人读 MD 双产物。

---

## §3 `lib/attribute.sh`（56 行）— 4 类归因决策树（为什么红，不只是红了）

短小但是收据"可信"的灵魂：**红了要能说出"是谁动了"**。

- **★ 4 类（line 3）**：`SKILL_CHANGED | FIXTURE_STALE | MODEL_CHANGED | UNKNOWN_DRIFT`。
- **决策树（line 18-31）**：读 `env_delta.keys_changed`——
  - 含 `skill_bundle_sha|skill_sha` → `SKILL_CHANGED`（我的 skill 变了）
  - 含 `fixture_sha` → `FIXTURE_STALE`（测试夹具变了，不是 skill 退化）
  - 含 `model_id|opencode_version` → `MODEL_CHANGED`（底座升级导致，不是我写挫了）
  - 都没匹配 → `UNKNOWN_DRIFT`（说不清——这本身是诚实信号）
- **★ 多类共存（line 32-44）**：`top` = 首个命中，`also_observed` = 其余。**一次变更可能同时改了 skill + model，全列出来**。
- **证据透传（line 45-49）**：`evidence: <整个 env_delta>` 进收据，归因结论 + 原始差异都在。

> **MAformac C5/C6 直抄**：把 4 类映射成 `LORA_CHANGED | CONTRACT_FIXTURE_STALE | BASE_MODEL_CHANGED | UNKNOWN_DRIFT`——bench 红了，先回答"是 LoRA 权重退化、契约快照变了、还是 Qwen base/runtime 升级了"。**没归因的红 = 无法行动的红**。

---

## §4 `lib/pricing.sh`（108 行）+ `lib/manifest.sh`（129 行）— cost gate + 环境指纹（归因的数据源）

### cost gate（pricing.sh）
- **★ 价目表过期守护 `pricing_staleness_check`（line 26-50）**：读 `pricing.json` 的 `as_of` + `stale_after_days`（默认 60），算天数，超期 → `STALE`。run.sh（line 201-214）据此 WARN，`EVAL_FAIL_ON_STALE_PRICING=1` 可升级成 exit 13。**陈旧的成本数字比没有更危险——明确标过期**。日期解析双路（GNU `date -d` / BSD `date -j`，line 36-37）兼容 macOS。
- **★ token→USD（line 52-85）**：`compute_cost_usd` 查 `models[$model]` 的 `input_per_mtok_usd/output_per_mtok_usd`；**未知模型 → `usd:null, reason:"unknown_model:<id>"`**（line 63-65），不是猜价。
- **★ token 取自 transcript 不信工具的钱报（line 87-96，spawn.sh line 83 注释 "Settled #17：tokens-based capture, not opencode's broken dollar telemetry"）**：`jq` 递归扒 `usage.input_tokens // .prompt_tokens`，自己乘价目表。**不信第三方的美元遥测，只信 token 计数 + 自己的价表**。

### 环境指纹（manifest.sh）— 归因的事实源
- **★ `capture_manifest`（line 14-90）= 可复现指纹**：`opencode_version / model_id / node_version / platform / skill_sha / skill_bundle_sha / fixture_sha / timestamp`，`schema_version:2`。
- **★ 两级 sha 抓跨 skill 回归（line 32-53）**：`skill_sha` = 本 skill 文件树 hash；`skill_bundle_sha` = **整个 skills 根目录**所有 `.md/.sh/.yaml/.json` 的 hash（line 36-40，注释 "catches cross-skill regressions where editing skill B silently affects skill A"）。→ 改 B 把 A 弄回归也能指纹出来。
- **★ `diff_manifests`（line 94-116）= env_delta 生成器**：`jq` 对两份 manifest 取并键 → `[select($bm[.] != $cm[.])]` 且**显式排除 `timestamp`**（line 110，时间戳本就每次不同，排掉避免噪声）。产 `{keys_changed, details:{key:{baseline,current}}}` 喂给 §3 归因。

> **MAformac C6 直抄**：① 派生物双 hash（`lora_sha` + `contract_snapshot_sha`，对应契约 SSOT 的冻结快照 manifest）② manifest-diff 排除时间戳类噪声字段 ③ cost 标过期/未知不猜 ④ 自己算 token 不信外部钱报（端侧本就无云账单，但"自记 token/延迟、外部数字标来源"的纪律可借）。

---

## §5 `lib/stability.sh`（51 行）+ run.sh 内联（line 378-415）— flaky 检测算法（real FAIL vs 抖动）

**收据可信度的下限保证**：一个 FAIL 到底是真退化还是随机抖动？

- **★ 3 样本字节同一性（stability.sh line 1-4 注释 "Settled Decision #11"）**：FAIL 后重跑 N 次（默认 stability-samples，触发条件 run.sh line 380 `>1 && primary FAIL`），每次只 hash **`.checks` 子树**（stability.sh line 24：`jq -S '.checks // []' | sha256sum`），**显式忽略时间戳/run-id 等设计上就非确定的字段**。
- **判定（line 28-35）**：N 个 hash 全相等 → `byte_identical:true` = FAIL 是 real（归因可信）；任一分叉 → `byte_identical:false` = **flaky**（run.sh line 411-413 打 "case is FLAKY (samples diverged)"，§2 给 attribution 降信）。
- **run.sh 内联实现（line 382-410）**：第 1 个 hash 直接取主跑的 checks.json，第 2..N 个**复制 workdir 重跑**（`cp -R "$workdir" "$sample_workdir"`，line 389，保证夹具一致），全部 `run_all_checks` 后比 hash。
- **决策对偶**：harness 自己运行在 **T=0/k=1 确定性模式**（SKILL.md Limitations #2），所以"字节同一"是合理下限；非确定才升 `pass@k`（README 标 deferred）。

> **MAformac C6 直抄**：bench FAIL 时 3 样本重判（同输入同契约快照），**只 hash 结构化判定字段（ToolCall 集合 + verdict），忽略时间戳/trace_id**。byte-identical = 模型在该 case 上确定性退化（可入回归账）；分叉 = 采样抖动（标 flaky，不计回归、提示调温度/seed）。对端侧 LLM 尤其关键——小模型采样抖动会假报回归。

---

## §6 `lib/llm_judge.sh`（133 行）— 多样本投票裁判（prose 兜底，MAformac 慎用）

- **多样本多数投票 `llm_judge_majority`（line 73-123）**：跑 N 次单判，统计 `pass/fail/null`，**`null_count ≥ (n+1)/2` → majority=null（judge 不可用，不当 FAIL）**（line 94-96）；平票 → null + `reason:"tied_or_inconclusive"`（line 100-103）。**裁判说不清不等于 skill 错**。
- **不可用优雅降级（line 14-18, 34-37, 52-57）**：缺 key / `EVAL_LLM_JUDGE_LIVE=0` / curl 失败 / 解析不出 verdict → 一律 `{verdict:null, reason:"judge_unavailable:..."}`，**不崩、不误判**。
- **verdict 抽取脆弱性（line 60-63，KNOWN_ISSUES HIGH-4）**：先抓引号 `"PASS"/"FAIL"` 再抓裸词，若 FAIL 的理由里出现 "PASS" 可能误抓——**MAformac 引以为戒：判定别靠从自由文本 grep 关键词，要结构化输出**。

> **MAformac 取舍**：C6 主轴是**确定性 ToolCall 集合匹配**（不需 LLM judge）；`llm_judge` 仅在评 NL 回复"听感/语义合理性"时 adapt，且必须 ① 多样本投票 ② 不可用→null 不→FAIL ③ 结构化 verdict 不 grep 自由文本。**端侧无云裁判，这块多数 drop，只借"投票 + 不可用降级"思想**。

---

## §7 `lib/autofix.sh`（167 行）— 修复建议生成（FAIL 不止报错还给下一步）

- **★ 按 check kind 模板化建议 `propose_fix`（line 4-122）**：PASS → `fix_proposal:null`；FAIL 按 kind 给 `{kind, confidence, instruction, patch_snippet, auto_apply:false}`。例：`output_contains` 缺串 → `"Output must contain this exact string: <literal>"`；`file_exists` 缺文件 → `"Create this file: <path>"`；`shell` 的 min/regex/exact 各有模板。
- **★ `auto_apply:false` 恒为假（全函数）**：**只建议不自动改**——eval 工具给方向，人/agent 决定动手。安全边界清晰。
- **置信度分级**：literal/file 类 `high`，shell min/regex 类 `medium`（line 75/88）。
- **MED-1 死代码警示（KNOWN_ISSUES）**：`propose_fixes_for_run`（line 124-157）有 `select(...|$f|.)` 恒真 bug 但从未被调用——**MAformac 抄 `propose_fix` 单条逻辑，别抄 batch 版**。

> **MAformac C6 adapt**：ToolCall FAIL 时给结构化"下一步"——`{kind:"missing_toolcall", instruction:"应产 setAirConditioner(temperature=22)", confidence, auto_apply:false}`，喂给 C5 LoRA 数据增广或人审，**但永不自动改契约/权重**。

---

## §8 编排外围（run.sh / twotier.sh / spawn.sh / preflight.sh / baseline.sh / promote.sh / config.sh）

- **★ `spawn.sh`（102 行）ephemeral 沙箱（line 2-3, 37-76）**：每 case 全新 `HOME / OPENCODE_CONFIG_DIR / NANO_BRAIN_ROOT / cwd`，`OPENCODE_EVAL_MODE=1`+`EVAL_HARNESS_RUNNING=1`（**让被测 skill 能检测到"我在被评测"从而拒绝破坏性操作**，line 67），`timeout(1)` 包裹子进程（line 71，opencode 缺 `--max-turns` 的补偿）。模型解析顺序四级 precedence（line 24-28/60）。→ **eval 彻底隔离，不污染真实 env**。
- **★ `run.sh` fixture path-traversal 三重守护（line 250-292）**：拒绝 `dest` 以 `/` 开头或含 `..`（line 253）+ `os.path.normpath` 规范化后必须落 `workdir` 内（line 265-271）+ 源缺失明确报。这是 BLK-3 的修复。→ MAformac 载入契约 fixture 同样守。
- **★ `run.sh` timeout/empty-transcript 显式处理（line 334-373）**：exit 124（被 timeout 杀）→ 产 `harness_error` 收据；非零退出 + 空 transcript → 产 `spawn_failed` 收据。**进程级失败也变成结构化收据，不混进 skill 回归**。
- **★ flock 互斥（run.sh line 297-322）**：per `skill:case:trigger` 锁，有 `flock` 用 fd 锁，无则 `mkdir` 锁兜底（跨平台）。防并行 run 互踩。
- **★ warn-only → promote 双态（run.sh line 459-469 + promote.sh）**：默认 warn-only（REGRESSION 也 exit 0，只产 diff.md）；`promote.sh` 要求 **7 天有 run 历史 + 0 bypass 事件**（line 50-62）才落 `promoted` 标记，之后 REGRESSION 真 exit 12 阻断。**新工具 day-1 不 block-rage，绿够久才上牙**。
- **★ baseline 单写者（baseline.sh line 4 注释 "Settled #10：baseline writes only via explicit command"）**：baseline 只能显式命令写，已存在要 `--force`（line 73-76）。**契约/基线不被运行时偷偷改**（呼应 MAformac "契约 SSOT 单源 + codegen 派生" 纪律）。
- **`twotier.sh`（169 行）**：smoke（便宜模型，line 56-73）全绿就停；有 FAIL 才对失败 case 升 full（贵模型，line 81-104）。**成本分层——大多数 case 便宜跑，只为可疑的付贵价**。（注：BLK-6 修复后才正确聚合 exit code。）
- **`preflight.sh`（63 行）context gate**：spawn 任何沙箱前先验 `opencode` 在 PATH + 至少一个 provider cred（≥20 字符、非 REDACTED，line 27-33），不过 exit 13。**坏环境快失败，不浪费一堆沙箱**。
- **`config.sh`（58 行）**：向上walk 找 `.opencode/eval-harness.yaml`，env 未设才用项目配置（**env > 项目配置**优先级，line 33/36/39）。

---

## §9 cross-cutting pattern（横切设计思想，MAformac eval 体系的脊柱）

1. **★ 收据流水线（everything is a structured receipt）**：从单 check（§1 7 字段）→ case（§2 6 字段）→ run summary，**层层是 JSON 收据，逐级聚合**。连 harness 自身错误（timeout/spawn 失败/未知 kind）都变收据而非崩溃。MAformac C6 的脊柱形态。
2. **★ "红"必须可归因（attribution）+ 可复现（rerun）+ 可信（stability）**：三条让"红了"从噪声变成可行动信号。没归因的红、不能复现的红、抖出来的红，都是垃圾红。
3. **★ REGRESSION ≠ FAIL（baseline-relative verdict）**：核心判定是**相对 baseline 的翻转**（绿→红），不是绝对失败。这把"新增 case 必红 / 无基线"与"我把好的搞坏了"彻底分开。
4. **★ 确定性下限 + 显式非确定标注**：T=0/k=1 跑，FAIL 用 3 样本字节同一性区分 real vs flaky，**只 hash 判定字段忽略时间戳**。把"哪些字段该确定、哪些天然抖"显式建模。
5. **★ 优雅降级文化（缺什么标什么，绝不猜/不静默 PASS）**：无 baseline→null、judge 不可用→null（非 FAIL）、未知模型价→null、空 transcript→error FAIL（非 vacuous PASS）、价表过期→WARN。**每个"说不清"都有诚实信号，没有静默成功**。
6. **★ 安全/隔离纵深**：ephemeral 沙箱 + path-traversal 三重守护 + shell 安全过滤 + flock 互斥 + `OPENCODE_EVAL_MODE` 让被测者自知被评。eval 不污染真实环境、case 作者不能逃逸沙箱。
7. **★ 成本意识贯穿但不主导**：token 自算（不信外部钱报）+ 价表过期守护 + smoke/full 分层（便宜跑多数、贵价只给可疑）。
8. **★ 渐进式上牙（warn-only → 7 天绿 → promote → blocking）**：治理强度随信任积累而升，day-1 不阻断。
9. **★ 单写者 baseline / 派生物 hash**：基线只显式命令写、用双 sha 指纹环境——与 MAformac"契约 SSOT 单源 + codegen 派生 + 冻结快照 manifest"同构。

---

## §10 adopt / adapt / drop 映射 → MAformac C6（failure receipt）为主，旁及 C4/C5/C7

| 形态（form） | 动作 | 服务 C 层 | 为什么 |
|---|---|---|---|
| **6 字段 case FAIL 收据**（`failed_check_id/expected/actual/diff_hint/transcript_span/env_delta`，diff.sh:15-90 + score.sh 单条 schema） | **copy概念** | **C6** | C6 "failure receipt" 一词直系来源；逐字段都有意义（指纹/期望/实际/提示/跳转/环境）。翻成 Swift struct `EvalCaseReceipt`，不 import bash/jq。 |
| **跑全部 check 不短路 + 逐条结果聚合**（score.sh run_all_checks:319-355，Settled #18） | **copy概念** | **C6** | 一条话术失败一次看全所有失败点（意图/槽/device/安全门），而非改一个跑一次。 |
| **REGRESSION ≠ FAIL 的 baseline-relative verdict**（diff.sh build_run_summary:102-110） | **copy概念** | **C6** | 新增覆盖 case 的红 ≠ 已有能力回归红；只有 `baseline=PASS→current=FAIL` 才入回归账。MAformac 全集覆盖率双轴 bench 的判定根基。 |
| **4 类归因决策树**（attribute.sh，由 env_delta 驱动） | **adapt** | **C5/C6** | 映射成 `LORA_CHANGED / CONTRACT_FIXTURE_STALE / BASE_MODEL_CHANGED / UNKNOWN_DRIFT`——bench 红先答"是谁动了"。`top + also_observed` 多类共存照搬。 |
| **3 样本字节同一性 flaky 检测**（stability.sh，只 hash `.checks` 忽略时间戳） | **copy概念** | **C6** | 端侧小模型采样抖动会假报回归；real FAIL（字节同一）才计回归，分叉标 flaky。**只 hash ToolCall 集合 + verdict，忽略 trace_id/时间戳**。 |
| **派生物双 sha 环境指纹 + manifest-diff（排时间戳）**（manifest.sh capture/diff） | **adapt** | **C6** | 用 `lora_sha + contract_snapshot_sha` 替 skill_sha；契约 SSOT 已有冻结快照 manifest（双 hash），天然对接。diff 排噪声字段。 |
| **rerun affordance（每 FAIL 自带单 case 复现命令）**（diff.sh:43） | **copy概念** | **C6** | `swift run bench --case=<id> --pin-contract=<snapshot>`——人/agent 拿到红立刻能单独复现。 |
| **机器 JSON（results.json）+ 人读 MD（diff.md）双产物**（diff.sh render_diff_md:144-201） | **copy概念** | **C6** | CI/脚本吃 JSON，磊哥/审计吃 MD 三段式（回归/失败明细/稳定）。 |
| **优雅降级文化（无基线/judge不可用/未知价/空产物 各有诚实信号，绝不静默 PASS）** | **copy概念** | **C6** | 尤其"否定式断言必须先证产物存在"（BLK-7 修复）——拒识/空匹配 check 不能 vacuous-PASS。 |
| **warn-only → 7 天绿 → promote → blocking 渐进上牙**（run.sh:459-469 + promote.sh） | **adapt** | **C6** | solo demo 轻治理：bench 先 warn-only 攒信任，稳定后再当 must-pass 死门。不 day-1 block。 |
| **smoke/full 成本分层 + 2tier 升级**（twotier.sh / run.sh apply_mode_defaults） | **adapt** | **C6** | 端侧无 token 费，但"全集广覆盖便宜跑一遍 / 失败 case 重判精跑"的两层节奏可借（端侧成本=延迟/电）。 |
| **结构化修复建议 `propose_fix`（auto_apply:false 只建议不自动改）**（autofix.sh:4-122） | **adapt** | **C5/C6** | ToolCall FAIL→ `{instruction:"应产 setAirConditioner(temperature=22)"}` 喂 C5 数据增广或人审；**永不自动改契约/权重**（呼应单写者纪律）。 |
| **ephemeral 沙箱 + `OPENCODE_EVAL_MODE`（被测者自知被评）**（spawn.sh:37-76） | **adapt** | **C6** | MAformac 端侧 eval 用全 mock 车控隔离（D16），`EVAL_MODE` 旗标让 DemoGuard/安全门在评测态下仍生效可验。 |
| **fixture path-traversal 三重守护**（run.sh:250-292） | **adapt** | **C6** | 载入契约/状态 fixture 同样守（虽 solo 威胁低，但 normpath 落范围内是廉价正确性）。 |
| **preflight context gate（坏环境快失败 exit 13 ≠ skill 回归）**（preflight.sh） | **adapt** | **C6** | 模型/契约快照/runtime 缺失 → harness error（13），别混进能力红。 |
| **单写者 baseline（只显式命令写 + --force）**（baseline.sh） | **adapt** | **C6** | 与契约 SSOT 单源同构：bench baseline 只显式 `bench baseline` 写，运行时不偷改。 |
| **cost gate / pricing 过期守护 / token 自算不信外部钱报**（pricing.sh） | **adapt** | C6 | 端侧无云账单 → 多数 drop 美元部分；保留"自记 token/延迟、外部数字标来源/过期"纪律。 |
| **LLM-judge 多样本投票**（llm_judge.sh majority + 不可用→null） | **adapt（窄）** | C6 | 主轴是确定性 ToolCall 匹配，judge 仅评 NL 回复语义时用，且必须投票 + null 不当 FAIL + 结构化 verdict。 |
| **bash/jq/yq 实现链、opencode 专属沙箱、Anthropic curl judge、git pre-push hook、history.ndjson trend** | **drop** | — | 实现载体不适用 iOS/Swift；端侧无 opencode/云 judge/git hook。**只取设计形态，全部翻 Swift，零脚本 import**（CLAUDE §4 "Python/Node 库零进 iOS" 同理外推）。 |

---

## §11 一句话

> **eval-harness 把"一次回归检测"做成了一条收据流水线——每个 FAIL 自带 `expected/actual/diff_hint/transcript_span/env_delta` 六字段 + 4 类归因 + 3 样本 flaky 判定 + 一行复现命令，且 REGRESSION（绿翻红）与 FAIL（无基线/新红）严格分开、说不清的一律给诚实 null 而非静默 PASS；这套"可归因·可复现·可信·渐进上牙"的收据形态就是 MAformac C6 vehicle-tool-bench failure receipt 的现成蓝本，全量翻成 Swift struct，bash/jq/opencode/云 judge 实现链整体 drop。**

---

### 红线遵守声明
- clone 在 `~/workspace/raw/05-Projects/MAformac/ref-repos/nano-eval-harness`（只读参考，**未进仓**）。
- 本 teardown **只写** `docs/research/`，**未 git add/commit**（主线程统一）。
- MIT License 允许复制，但仍按 CLAUDE §4 红线**只提炼设计思想 + 字段语义，翻成 Swift，不 import bash/jq/python 代码链**。
- 无 PII / 密钥 / 客户语料涉及（参考 repo 是通用 skill 评测工具，与某车厂源料无关）。
