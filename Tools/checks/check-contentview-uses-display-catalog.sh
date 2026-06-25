#!/usr/bin/env bash
# check-contentview-uses-display-catalog.sh — UIUE Phase 4a 接线 enforce（spec ui-presentation R2/R3 + claim-vs-reality）
#
# 防前任「接线丢失、单测绿、注释里有词、以为做完」重演（proof 图正因此丢）：
#   ContentView body 必须【真调用】VehicleCardDisplay.familyDisplays(from:)，且 Grid 固定列非 LazyVGrid。
# 🔴 grep 是辅助门；主 anti-claim 门 = force-state 截图 artifact（Reports/uiue-phase4a-proof/，PR 硬段）。
#
# 用法:    Tools/checks/check-contentview-uses-display-catalog.sh   (exit 1 = 命中违规)
# 挂载:    .githooks/pre-commit 调用（core.hooksPath=.githooks 已生效）
# 逃生:    SKIP_CONTENTVIEW_WIRING_CHECK=1 git commit ...
set -uo pipefail
[ "${SKIP_CONTENTVIEW_WIRING_CHECK:-0}" = "1" ] && { echo "⏭  [contentview-wiring] skipped (SKIP_CONTENTVIEW_WIRING_CHECK=1)"; exit 0; }

ROOT="$(git rev-parse --show-toplevel)"
CV="$ROOT/App/ContentView.swift"
[ -f "$CV" ] || { echo "❌ [contentview-wiring] $CV 不存在"; exit 1; }

# strip 注释（行首 + 行内 // → EOL），防 `// familyDisplays(from:` 纯注释假绿。
# 注：ContentView 字符串内无 `//`，sed strip 安全。
CODE="$(sed -E 's@//.*@@' "$CV")"

fail=0
# 1) 必须【真调用】familyDisplays(from:（注释 strip 后仍命中=真接线，非仅注释/字符串提及）
if ! printf '%s\n' "$CODE" | grep -qE 'familyDisplays\(from:'; then
  echo "❌ [contentview-wiring] ContentView 未真调用 VehicleCardDisplay.familyDisplays(from:)（接线缺失/仅注释提及）"
  fail=1
fi
# 2) Grid 固定列（spec R3/C22），禁 LazyVGrid.adaptive 漂移
if printf '%s\n' "$CODE" | grep -qE 'LazyVGrid'; then
  echo "❌ [contentview-wiring] ContentView 仍有 LazyVGrid（spec C22 要求 Grid 固定列非 adaptive）"
  fail=1
fi
# 3) familyDisplays 必须被 VehicleCardsGrid 真消费，且数据源必须【是 family model】（gptpro 跨厂商审第3点升级）。
#    从「VehicleCardsGrid(displays: 出现」升到「displays: 实参 == familyDisplays」——
#    防 grid 接了个非 family 数据源（device 级/空数组/别的 var）字符串出现但语义错的假绿。
if ! printf '%s\n' "$CODE" | grep -qE 'VehicleCardsGrid\(displays:[[:space:]]*familyDisplays\)'; then
  echo "❌ [contentview-wiring] VehicleCardsGrid 的 displays 数据源必须是 familyDisplays（10 族 model）——接别的源/未消费=假绿"
  fail=1
fi

[ "$fail" -eq 0 ] && echo "✅ [contentview-wiring] ContentView 真调用 familyDisplays(from: + VehicleCardsGrid 真消费 + Grid 固定列（无 LazyVGrid）"
exit "$fail"
