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

read_pref() {
  local key="$1"
  local value
  if value="$(defaults read "$DOMAIN" "$key" 2>/dev/null)"; then
    echo "$value"
  else
    echo "missing"
  fi
}

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

record_current_os_switches() {
  {
    echo "## OS Switch Probe"
    echo
    echo "- probe_class: read_only_defaults"
    echo "- writes: forbidden"
    echo "- reduceTransparency: \`$(read_pref reduceTransparency)\`"
    echo "- increaseContrast: \`$(read_pref increaseContrast)\`"
    echo "- reduceMotion: \`$(read_pref reduceMotion)\`"
    echo
  } >>"$RECEIPT"
}

run_injected_gate() {
  local label="$1"
  local reduce_transparency="$2"
  local increase_contrast="$3"
  local reduce_motion="$4"
  shift 4
  {
    echo "## Injection $label"
    echo
    echo "- D1H_A11Y_REDUCE_TRANSPARENCY: \`$reduce_transparency\`"
    echo "- D1H_A11Y_INCREASE_CONTRAST: \`$increase_contrast\`"
    echo "- D1H_A11Y_REDUCE_MOTION: \`$reduce_motion\`"
    echo
  } >>"$RECEIPT"
  D1H_A11Y_REDUCE_TRANSPARENCY="$reduce_transparency" \
    D1H_A11Y_INCREASE_CONTRAST="$increase_contrast" \
    D1H_A11Y_REDUCE_MOTION="$reduce_motion" \
    run_swift_gate "$label" "$@"
}

{
  echo "# D1H 三开关走查 receipt"
  echo
  echo "- captured_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "- proof_class: local"
  echo "- mode: $([[ "$NEGATIVE_MODE" == "1" ]] && echo negative_self_test || echo walkthrough)"
  echo "- os_switch_mode: read_only_probe_no_writes"
  echo
} >"$RECEIPT"

record_current_os_switches

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

LABELS=(default reduceTransparency increaseContrast reduceMotion reduceTransparency+reduceMotion reduceTransparency+increaseContrast reduceMotion+increaseContrast allOn)
RT_VALUES=(0 1 0 0 1 1 0 1)
IC_VALUES=(0 0 1 0 0 1 1 1)
RM_VALUES=(0 0 0 1 1 0 1 1)

for index in "${!LABELS[@]}"; do
  label="${LABELS[$index]}"
  rt="${RT_VALUES[$index]}"
  ic="${IC_VALUES[$index]}"
  rm="${RM_VALUES[$index]}"

  run_injected_gate \
    "switch-${label}-u17-injected-render" \
    "$rt" "$ic" "$rm" \
    swift test --filter U17HeadlessSnapshotSSIMTests/testU17AccessibilityInjectedHeadlessSnapshotsRenderAllStates
  run_injected_gate \
    "switch-${label}-l2-contrast" \
    "$rt" "$ic" "$rm" \
    swift test --filter D1HLiquidGlassSwitchContrastTests/testL2ContrastStaysGreenForInjectedEnvironmentCombination
done

{
  echo "## Operator Manual Checklist"
  echo
  echo "- checklist: \`docs/grill-checklist/d1h-three-switch-operator-checklist.md\`"
  echo "- status: manual_operator_step_only"
  echo "- non_claim: this script does not write OS accessibility settings and does not claim true-device or desktop_operator_equivalent pass"
} >>"$RECEIPT"

echo "D1H_THREE_SWITCH_WALKTHROUGH_PASS receipt=$RECEIPT"
