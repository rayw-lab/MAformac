#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RECEIPT_DIR="${D1H_RECEIPT_DIR:-$REPO_ROOT/Reports/d1h-three-switch}"
RECEIPT="$RECEIPT_DIR/three-switch-walkthrough.md"
NEGATIVE_MODE=0

if [[ "${1:-}" == "--negative-self-test" ]]; then
  NEGATIVE_MODE=1
fi

mkdir -p "$RECEIPT_DIR"

DOMAIN="com.apple.universalaccess"
KEYS=(reduceTransparency increaseContrast reduceMotion)

ORIGINAL_reduceTransparency=""
ORIGINAL_increaseContrast=""
ORIGINAL_reduceMotion=""
HAD_reduceTransparency=0
HAD_increaseContrast=0
HAD_reduceMotion=0

read_pref() {
  local key="$1"
  if value="$(defaults read "$DOMAIN" "$key" 2>/dev/null)"; then
    eval "ORIGINAL_${key}=\"\$value\""
    eval "HAD_${key}=1"
  else
    eval "ORIGINAL_${key}=\"\""
    eval "HAD_${key}=0"
  fi
}

write_pref() {
  local key="$1"
  local enabled="$2"
  defaults write "$DOMAIN" "$key" -bool "$enabled"
}

restore_pref() {
  local key="$1"
  local had_var="HAD_${key}"
  local original_var="ORIGINAL_${key}"
  if [[ "${!had_var}" == "1" ]]; then
    defaults write "$DOMAIN" "$key" "${!original_var}"
  else
    defaults delete "$DOMAIN" "$key" >/dev/null 2>&1 || true
  fi
}

restore_all() {
  for key in "${KEYS[@]}"; do
    restore_pref "$key"
  done
}
trap restore_all EXIT

for key in "${KEYS[@]}"; do
  read_pref "$key"
done

run_swift_gate() {
  local label="$1"
  shift
  local log="$RECEIPT_DIR/${label}.log"
  set +e
  (
    cd "$REPO_ROOT"
    "$@"
  ) >"$log" 2>&1
  local rc=$?
  set -e
  {
    echo "## $label"
    echo
    echo "- command: \`$*\`"
    echo "- rc: \`$rc\`"
    echo "- log: \`$log\`"
    echo
  } >>"$RECEIPT"
  return "$rc"
}

{
  echo "# D1H 三开关走查 receipt"
  echo
  echo "- captured_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "- proof_class: local"
  echo "- mode: $([[ "$NEGATIVE_MODE" == "1" ]] && echo negative_self_test || echo walkthrough)"
  echo
} >"$RECEIPT"

if [[ "$NEGATIVE_MODE" == "1" ]]; then
  if D1H_U17_FORCE_BAD_SAMPLE=changing run_swift_gate \
    "negative-u17-ssim" \
    swift test --filter U17HeadlessSnapshotSSIMTests/testU17SevenStateHeadlessSnapshotsMatchSSIMBaselines; then
    u17_rc=0
  else
    u17_rc=$?
  fi

  if D1H_L2_CONTRAST_FORCE_BAD_SAMPLE=1 run_swift_gate \
    "negative-l2-contrast" \
    swift test --filter D1HLiquidGlassSwitchContrastTests/testL2ContrastStaysGreenAcrossThreeSwitchCombinations; then
    l2_rc=0
  else
    l2_rc=$?
  fi

  {
    echo "## Negative Verdict"
    echo
    echo "- U17 bad sample rc: \`$u17_rc\`"
    echo "- L2 bad sample rc: \`$l2_rc\`"
  } >>"$RECEIPT"

  if [[ "$u17_rc" == "0" || "$l2_rc" == "0" ]]; then
    echo "D1H_NEGATIVE_SELFTEST_FAILED receipt=$RECEIPT"
    exit 65
  fi

  echo "D1H_NEGATIVE_SELFTEST_PASS receipt=$RECEIPT"
  exit 0
fi

for key in "${KEYS[@]}"; do
  for candidate in "${KEYS[@]}"; do
    if [[ "$candidate" == "$key" ]]; then
      write_pref "$candidate" true
    else
      write_pref "$candidate" false
    fi
  done

  run_swift_gate \
    "switch-${key}-u17-ssim" \
    swift test --filter U17HeadlessSnapshotSSIMTests/testU17SevenStateHeadlessSnapshotsMatchSSIMBaselines
  run_swift_gate \
    "switch-${key}-l2-contrast" \
    swift test --filter D1HLiquidGlassSwitchContrastTests/testL2ContrastStaysGreenAcrossThreeSwitchCombinations
done

restore_all
echo "D1H_THREE_SWITCH_WALKTHROUGH_PASS receipt=$RECEIPT"
