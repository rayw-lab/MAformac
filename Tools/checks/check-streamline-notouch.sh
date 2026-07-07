#!/usr/bin/env bash
# streamline 精简批次 no-touch 机械门（opt/streamline-macos-20260707 分支专用）
# 用法：每批 commit 前跑 `Tools/checks/check-streamline-notouch.sh`
# 检查 staged 改动是否触碰 no-touch 清单（D-114/D-115 + SYNTHESIS-v2 锁定）；命中即 exit 1。
# 权威出处：runs/2026-07-07-ma-opt-refactor/out/COMMANDER-SYNTHESIS-v2.md §B0
set -euo pipefail

STAGED=$(git diff --cached --name-only)
[ -z "$STAGED" ] && { echo "notouch: nothing staged"; exit 0; }

# no-touch 前缀清单（触碰任一 = 本批越界，需 commander 显式豁免说明）
NOTOUCH_PREFIXES=(
  "Tests/Fixtures/query-zero-tolerance/evidence/"   # 726 冻结判定证据
  "docs/evidence-frozen/"                            # 551 + 30 MANIFEST.sha256
  "contracts/"                                       # 契约 SSOT（B1c capabilities.yaml 需显式豁免）
  "generated/"                                       # codegen 产物 + diff gate 输入
  "openspec/specs/"                                  # 行为契约事实源
  "docs/c5-training-readiness-grill/"                # 训练证据链 69 件
  "docs/c5-recovery-2026-06-22/"                     # 训练证据链 11 件
  "MAformac.xcodeproj/"                              # iOS 冻结面（Q2=C）
  "MAformacIOSUITests/"                              # iOS 冻结面
  "Core/Presentation/PresentationHapticPolicy.swift"
  "Core/Presentation/LiquidGlassHardeningInventory.swift"
  "Core/Presentation/DistributionBoundaryGuard.swift"
  "Core/Presentation/VisualEvidenceReceipt.swift"
  "Core/Training/"                                   # C5 资产
  "Core/Bench/"                                      # C6 资产
  "Reports/"                                         # force-add 证据（本轮只出 plan 不动原件）
)

# 显式豁免：环境变量 STREAMLINE_NOTOUCH_ALLOW 传入逗号分隔前缀（commander 批准的单批豁免）
ALLOW="${STREAMLINE_NOTOUCH_ALLOW:-}"

violations=0
while IFS= read -r f; do
  for p in "${NOTOUCH_PREFIXES[@]}"; do
    case "$f" in
      "$p"*)
        allowed=0
        if [ -n "$ALLOW" ]; then
          IFS=',' read -ra ALLOWED_ARR <<< "$ALLOW"
          for a in "${ALLOWED_ARR[@]}"; do
            case "$f" in "$a"*) allowed=1;; esac
          done
        fi
        if [ "$allowed" -eq 0 ]; then
          echo "NOTOUCH VIOLATION: $f (matches $p)"
          violations=$((violations+1))
        else
          echo "notouch: $f allowed by explicit STREAMLINE_NOTOUCH_ALLOW"
        fi
        ;;
    esac
  done
done <<< "$STAGED"

if [ "$violations" -gt 0 ]; then
  echo "❌ streamline no-touch gate: $violations violation(s). Unstage or get commander explicit waiver."
  exit 1
fi
echo "✅ streamline no-touch gate: clean ($(echo "$STAGED" | wc -l | tr -d ' ') staged files)"
