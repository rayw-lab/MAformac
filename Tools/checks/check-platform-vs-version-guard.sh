#!/usr/bin/env bash
# check-platform-vs-version-guard.sh — UIUE 加强2（2026-06-24，spec R3 的机械 enforce）
# 锁 iOS26/macOS26 后，App 层不该有 iOS17/18 版本守卫（deployment 已 ≥ 各 API 引入版本：
#   MeshGradient iOS18 / glassEffect iOS26 / matchedGeometry iOS14 / Gauge iOS16）。
# 拦习惯性补 #available(iOS 17/18, *) 偷偷回滚锁版本；平台差异(zoom)用 #if !os(macOS)，a11y 用 ReduceMotion（自然不命中本 pattern）。
#
# 用法:    Tools/checks/check-platform-vs-version-guard.sh   (exit 1 = 命中违规)
# 挂载:    .githooks/pre-commit；启用 git config core.hooksPath .githooks（Phase 3 D7 改完后，tasks 3.6）
# 逃生:    SKIP_VERSION_GUARD_CHECK=1 git commit ...
set -uo pipefail
[ "${SKIP_VERSION_GUARD_CHECK:-0}" = "1" ] && { echo "⏭  [platform-vs-version-guard] skipped (SKIP_VERSION_GUARD_CHECK=1)"; exit 0; }

fail=0
# 锁 iOS26 后禁 iOS17/18 版本守卫（app 源只在 App/）
if git grep -nE '#available\(iOS (17|18)' -- 'App/' 2>/dev/null; then
  echo "❌ [platform-vs-version-guard] 发现 #available(iOS 17/18)——demo 锁 iOS26，版本守卫多余且矛盾（spec R3）。删守卫直接用 API；平台差异(zoom)用 \`#if !os(macOS)\`，a11y 用 ReduceMotion。"
  fail=1
fi
# 提示（非拦）：iOS26 守卫 deployment=26 恒真可删
if git grep -nE '#available\(iOS 26' -- 'App/' 2>/dev/null; then
  echo "⚠️  [platform-vs-version-guard] #available(iOS 26)——deployment 已锁 26，此守卫恒真可删（不拦，提示）。"
fi
[ "$fail" -eq 0 ] && echo "✅ [platform-vs-version-guard] App/ 无 iOS17/18 版本守卫。"
exit "$fail"
