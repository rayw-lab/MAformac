#!/usr/bin/env bash
# check-no-binary-visualstate.sh — UIUE 补强1（2026-06-24，spec ui-presentation R1 的机械 enforce）
# 拦 DemoVisualState 7 态被压成二值 / default 吞态——把 spec R1 的 SHALL NOT 从声称层下沉到 pre-commit 事实层。
#
# 用法:    Tools/checks/check-no-binary-visualstate.sh   (exit 1 = 命中违规)
# 挂载:    .githooks/pre-commit 调用；启用 `git config core.hooksPath .githooks`
# ⚠️ 启用时机 = Phase 3 D7 改造完成后。此前 App/ContentView.swift:122/:126 是已知未修靶点，会命中 exit 1（预期）。
# 逃生:    SKIP_VISUALSTATE_CHECK=1 git commit ...
set -uo pipefail
[ "${SKIP_VISUALSTATE_CHECK:-0}" = "1" ] && { echo "⏭  [no-binary-visualstate] skipped (SKIP_VISUALSTATE_CHECK=1)"; exit 0; }

fail=0

# 1) 三元二值压缩: visualState == .xxx ? a : b （app 源只在 App/）
if git grep -nE 'visualState[[:space:]]*==[[:space:]]*\.[A-Za-z_]+[[:space:]]*\?' -- 'App/' 2>/dev/null; then
  echo "❌ [no-binary-visualstate] 发现 visualState 三元二值压缩（spec R1: SHALL NOT \`== .satisfied ? a : b\`）。改穷尽 @ViewBuilder switch（7 态逐 case）。"
  fail=1
fi

# 2) default 吞态（穷尽 switch 禁 default 兜底）
if git grep -nE 'default:.*(VisualState|ViewBuilder)' -- 'App/' 2>/dev/null; then
  echo "❌ [no-binary-visualstate] 发现 default: 吞 VisualState/ViewBuilder（spec R1: SHALL NOT default 兜底）。7 态逐 case 穷尽。"
  fail=1
fi

[ "$fail" -eq 0 ] && echo "✅ [no-binary-visualstate] App/ 无 visualState 二值压缩 / 无 default 吞态。"
exit "$fail"
