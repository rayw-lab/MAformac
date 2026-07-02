---
authority: p3h_harness_v2_grill_overnight
artifact_kind: grill_decision_matrix
status: proposed_running_on_default_per_overnight_auth（磊哥通宵授权按⭐default推进，醒后 lock/翻案）
created: 2026-07-03 凌晨
seed: base-only 冒烟抓到 base 输出`<think>`开头烧光 80 token + %43 PR26 交叉审 P1×2/P2×3
---

# P3H harness v2 grill — probe 输入面对齐 + 契约补全（GF-141~148）

## 证据链（commander 亲核一手）
1. 训练 tokenizer 被 patch 成默认 no-think：`Tools/C5TrainingCLI/main.swift:497-503`（template 条件 `enable_thinking is not defined or false` → no-think 分支）。
2. 训练渲染面：mlx-data/train.jsonl messages 经 patched tokenizer 渲染，assistant 起手带空 `<think>\n\n</think>` 块；target=`\n\n<tool_call>...`。
3. 冒烟 probe prompt tail（`p3h-smoke.../output/base/01-C6-MP-004.json`）= `<|im_start|>assistant\n` **无 think 块** → base 模型自开 `<think>` → max_tokens=80 烧光 → empty。**= v5 四根因 #3（train_probe_input_surface_mismatch）在 harness 层复发，冒烟拦住（未污染正式 probe）**。
4. system prompt 训练=冒烟一致（排除该维度）。

## 决策矩阵
| id | 议题 | 选项+⭐default | 量化理由 | 防惨败检查 | status |
|---|---|---|---|---|---|
| GF-141 | probe prompt 渲染源 | A. fallback 手写模板补 think 块；B. ⭐必走 patched tokenizer apply_chat_template，fallback **fail-closed 删除**（渲染不了=exit 2 invalid_probe） | prompt 面是 experiment-valid 根基；手写模板=第二 SSOT 必漂移 | 防输入面错配复发（v5 #3）；防双模板分叉 | proposed |
| GF-142 | 渲染正确性断言 | A. 信任 template；B. ⭐渲染后机械断言 prompt 含 `<think>\n\n</think>` 空块 + 尾部结构，fail-closed | 冒烟已证 apply_chat_template 可能没吃 patch（mlx_lm 读 template 来源待 %44 下钻） | 防 mechanism-true 假绿（template 存在≠被用） | proposed |
| GF-143 | paired fail-closed（%43 P1-1） | A. --adapter 可选；B. ⭐无 --adapter 即 exit 2，另设显式 `--base-only-smoke` 模式（输出 proof_class=base_smoke_not_paired） | base-only success 会被误读 paired ready | 防局部绿升格 | proposed |
| GF-144 | decode 契约字段（%43 P1-2 + GF-136） | A. 现 3 字段；B. ⭐补 `tokenizer_wrapper/prompt_skeleton_id/thinking=no_think_block/parser_id/tool_call_cardinality/output_boundary` 全进契约 json + summary/receipt，缺字段 fail-closed | 消费者须能机械证明四轴同面 | 防契约缺口让同面声称不可验 | proposed |
| GF-145 | raw 证据保留（%43 P2-3） | A. 存截断后；B. ⭐per-case 同时存 `raw_generation`（未截断）+`truncated_output`+`parse_errors`+tail 标记 | v5 教训：raw NO_TOOL×27 重复是第二信息层，截断会毁证据 | 防证据第二信息层丢失（lessons M#4） | proposed |
| GF-146 | multi-call 保留（%43 P2-4） | A. 截到首个 `</tool_call>`；B. ⭐按序提取全部 tool_call 为 observed list，D 轴 C6-MP-028 双 call 进 fixture | report-only 也必须保真证据 | 防第二 call 被 stop 策略抹掉 | proposed |
| GF-147 | max_tokens | A. 80；B. ⭐160（no-think 面下单 call 实测 ~40-60 token，双 call+裕量 160 足；think 已被空块抑制不再耗 budget） | C6-MP-028 双 call 需 >80；160 仍便宜 | 防截断把多意图判 empty | proposed |
| GF-148 | 冒烟 artifacts 入 PR（%43 P2-5） | A. 留 PR；B. ⭐移出 PR，RECEIPT 只留脱敏摘要+指针（本地绝对路径不入仓） | review 面与 SPEC 面一致 | 防 PR scope drift | proposed |

## 融合义务
- lock 后并入 F-044 v6 spec（decode 契约段）+ governance-fit landing。GF-142 结果回写 GF-W1 D3（decode 具体值）。
