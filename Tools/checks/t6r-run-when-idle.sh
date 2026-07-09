#!/usr/bin/env bash
set -euo pipefail

# T6R idle-window screenshot pack v2.
#
# Purpose:
# - Prepare the macOS idle-window visual review package for commander Gate 5.
# - Rebuild the old T6a/T6b split with the new mac hero layout assumptions.
# - Fail closed before every real screenshot unless the target app is the
#   exclusive frontmost window and the current Space is mechanically clean.
#
# Proof boundary:
# - Screenshots produced by this script are local/mac_runtime_smoke only.
# - They are not 5 Gate approval, operator-pass, true-device proof, V-PASS, or C6 acceptance.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RUN_DIR="${T6R_RUN_DIR:-/Users/wanglei/Projects/agent-tmux-stack-research/runs/2026-07-09-ma10-uiue-runtime}"
OUT_ROOT="${T6R_OUT_ROOT:-$RUN_DIR/t6r-idle-window-v2}"
DERIVED_DATA="${T6R_DERIVED_DATA:-$OUT_ROOT/derived-data}"
APP="${T6R_APP:-$DERIVED_DATA/Build/Products/Debug/MAformacMac.app}"
APP_NAME="${APP_NAME:-MAformacMac}"
BUNDLE_ID="${BUNDLE_ID:-lab.rayw.MAformac.mac}"
SCHEME="${T6R_SCHEME:-MAformacMac}"
PROJECT="${T6R_PROJECT:-$ROOT/MAformac.xcodeproj}"
VISUAL_SWAP_ON_ARGS="${T6R_VISUAL_SWAP_ON_ARGS:--visualSwap}"
VISUAL_SWAP_OFF_ARGS="${T6R_VISUAL_SWAP_OFF_ARGS:-}"

SHOT_DIR="$OUT_ROOT/screenshots"
RECEIPT_DIR="$OUT_ROOT/receipts"
PLAN_DIR="$OUT_ROOT/plans"
LOG_DIR="$OUT_ROOT/logs"
CAPTURE_TSV="$OUT_ROOT/capture-items.tsv"
RECEIPT="$RECEIPT_DIR/t6r-idle-window-v2-receipt.json"
CROP_CHECKLIST="$OUT_ROOT/t6r-gate5-crop-checklist.md"
CAPTURE_PLAN="$PLAN_DIR/t6r-capture-plan.json"

DRY_RUN=0
NO_BUILD=0

usage() {
  cat <<'USAGE'
Usage: Tools/checks/t6r-run-when-idle.sh [--dry-run] [--no-build]

Environment overrides:
  T6R_OUT_ROOT               Output root. Default: run-dir/t6r-idle-window-v2
  T6R_APP                    Prebuilt MAformacMac.app path.
  APP_NAME                   Accessibility process name. Default: MAformacMac
  BUNDLE_ID                  macOS bundle id. Default: lab.rayw.MAformac.mac
  T6R_VISUAL_SWAP_ON_ARGS    Args for visual-swap on. Default: -visualSwap
  T6R_VISUAL_SWAP_OFF_ARGS   Args for visual-swap off. Default: empty

Exit codes:
  0   package generated
  2   missing local dependency or app bundle
  65  privacy guard failed before a real screenshot
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --no-build)
      NO_BUILD=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

mkdir -p "$SHOT_DIR" "$RECEIPT_DIR" "$PLAN_DIR" "$LOG_DIR"
: > "$CAPTURE_TSV"
printf 'group\tcase_id\twindow_tier\tvisual_swap\tstatus\tlaunch_args\twindow_bounds\tscreenshot_path\tscreenshot_sha256\tprivacy_guard\n' > "$CAPTURE_TSV"

json_escape() {
  python3 -c 'import json,sys; print(json.dumps(sys.stdin.read())[1:-1])'
}

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "error: missing required tool: $1" >&2
    exit 2
  fi
}

write_crop_checklist() {
  cat > "$CROP_CHECKLIST" <<'EOF'
# T6R Gate 5 Crop Checklist

status: review_package_template
proof_class: local/mac_runtime_smoke
non_claims: not_5_gate_approval, not_operator_pass, not_true_device, not_v_pass

## Capture Groups

| group | expected files | Gate 5 crop focus |
|---|---|---|
| `mac-hero-idle` | `visual-swap-{off,on}/mac-hero-idle-*` | Hero 大字对比：右栏 AC hero 值应明显大于次卡值；标题/状态不截断；hero 不因 1280/1440/1728 三档消失。 |
| `waterfall-first-frame` | `visual-swap-{off,on}/waterfall-first-frame-*` | 瀑布首帧：hero(0) -> 次卡行优先 1-9 的出现顺序；首帧不应整排同时完全可见；无 layout 跳动、右缘裁切。 |
| `force-state-seven` | `visual-swap-{off,on}/force-state-*` | 七态终端视觉：normal/satisfied/changing/blocked_with_alternative/blocked_hard/unsafe/unknown 的色、图标、文本三通道分离；force-state 只作 `terminal_visual_only`。 |
| `energy-line-probe` | `visual-swap-on/energy-line-probe-*` | 能量线路径：从左栏 orb 中心到右栏目标卡中心；不穿过 hero 大字主体；命中点在目标卡内部；若截图为 idle 未触发线，标记 `not_visible_in_static_idle`，不得写 PASS。 |

## Per-Image Crop List

1. Hero card text crop
   - Crop: right pane hero column, title row + value + status line.
   - Check: hero value >= 1.5x compact value by visual comparison; Chinese text readable; no ellipsis/truncation in hero.

2. Secondary 3x3 grid crop
   - Crop: right pane secondary grid excluding hero.
   - Check: exactly 9 secondary cards; 3 columns x 3 rows; spacing appears even; trailing padding stays visible.

3. Left-stage crop
   - Crop: left orb + conversation + mic dock.
   - Check: app is the only foreground app; no Feishu/IM/private window contamination; orb is not cropped.

4. Waterfall first-frame crop
   - Crop: full right pane at first-frame delay.
   - Check: staged reveal visible; no card overlaps; no right-edge clipping.

5. Energy-line path crop
   - Crop: full window, left orb to active/hero card path.
   - Check: line path starts at orb, terminates at target card, remains above background, does not create fake extra card focus.

6. Visual-swap comparison crop
   - Crop: same case id in `visual-swap-off` and `visual-swap-on`.
   - Check: on/off pair uses identical window tier and launch scenario; differences are attributable to visual-swap only.

## Review Rules

- Do not use force-state screenshots as main idle anchor evidence.
- Do not approve screenshots if any non-target app window is visible.
- Do not mark energy-line PASS from a static idle screenshot where the line is not visible.
- Commander Gate 5 verdict must remain human/operator scoped; this package only makes evidence easy to inspect.
EOF
}

write_capture_plan() {
  python3 - "$CAPTURE_PLAN" "$OUT_ROOT" "$APP_NAME" "$BUNDLE_ID" <<'PY'
import json
import sys
from pathlib import Path

plan_path = Path(sys.argv[1])
payload = {
    "artifact_kind": "t6r_idle_window_capture_plan_v2",
    "output_root": sys.argv[2],
    "app_name": sys.argv[3],
    "bundle_id": sys.argv[4],
    "window_tiers": [
        {"id": "compact", "width": 1280, "height": 800, "purpose": "minimum review tier; hero must not disappear"},
        {"id": "review", "width": 1440, "height": 900, "purpose": "standard commander review tier"},
        {"id": "hero", "width": 1728, "height": 1117, "purpose": "large mac hero tier"}
    ],
    "force_states": [
        "normal",
        "satisfied",
        "changing",
        "blocked_with_alternative",
        "blocked_hard",
        "unsafe",
        "unknown"
    ],
    "visual_swap_pairs": [
        {"id": "off", "default_args": []},
        {"id": "on", "default_args": ["-visualSwap"]}
    ],
    "privacy_guard": {
        "required_before_each_real_screenshot": True,
        "checks": [
            "frontmost process name equals target app",
            "target app has exactly one normal visible window",
            "no non-target app has a visible non-minimized window in the active Space"
        ],
        "failure_exit_code": 65
    },
    "non_claims": [
        "not_5_gate_approval",
        "not_operator_pass",
        "not_true_device",
        "not_v_pass",
        "not_c6_acceptance"
    ]
}
plan_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
PY
}

privacy_guard() {
  osascript - "$APP_NAME" <<'OSA'
on joinList(xs, sep)
  set oldDelims to AppleScript's text item delimiters
  set AppleScript's text item delimiters to sep
  set outText to xs as text
  set AppleScript's text item delimiters to oldDelims
  return outText
end joinList

on run argv
  set appName to item 1 of argv
  tell application "System Events"
    if not (exists process appName) then return "FAIL_NO_TARGET_PROCESS"
    set frontProc to first application process whose frontmost is true
    set frontName to name of frontProc
    if frontName is not appName then return "FAIL_FRONTMOST:" & frontName

    tell process appName
      set targetVisibleWindowCount to 0
      repeat with w in windows
        set minimized to false
        try
          set minimized to value of attribute "AXMinimized" of w
        end try
        if minimized is false then set targetVisibleWindowCount to targetVisibleWindowCount + 1
      end repeat
      if targetVisibleWindowCount is not 1 then return "FAIL_TARGET_VISIBLE_WINDOW_COUNT:" & (targetVisibleWindowCount as text)
    end tell

    set offenders to {}
    repeat with p in application processes
      set pname to name of p
      if pname is not appName then
        try
          if visible of p is true then
            set visibleWindowCount to 0
            repeat with w in windows of p
              set minimized to false
              try
                set minimized to value of attribute "AXMinimized" of w
              end try
              if minimized is false then set visibleWindowCount to visibleWindowCount + 1
            end repeat
            if visibleWindowCount > 0 then set end of offenders to (pname & "(" & (visibleWindowCount as text) & ")")
          end if
        end try
      end if
    end repeat
    if (count of offenders) > 0 then return "FAIL_DIRTY_SPACE:" & joinList(offenders, ",")
  end tell
  return "PASS"
end run
OSA
}

window_bounds() {
  osascript - "$APP_NAME" <<'OSA'
on run argv
  set appName to item 1 of argv
  tell application "System Events"
    if not (exists process appName) then return "PENDING_APP"
    tell process appName
      if (count of windows) is 0 then return "PENDING_WINDOW"
      set p to position of window 1
      set s to size of window 1
      return ((item 1 of p as integer) as text) & "," & ((item 2 of p as integer) as text) & "," & ((item 1 of s as integer) as text) & "," & ((item 2 of s as integer) as text)
    end tell
  end tell
end run
OSA
}

set_window_size() {
  local width="$1"
  local height="$2"
  osascript - "$APP_NAME" "$width" "$height" <<'OSA'
on run argv
  set appName to item 1 of argv
  set targetW to item 2 of argv as integer
  set targetH to item 3 of argv as integer
  tell application "System Events"
    if not (exists process appName) then return "PENDING_APP"
    tell process appName
      if (count of windows) is 0 then return "PENDING_WINDOW"
      set position of window 1 to {80, 80}
      set size of window 1 to {targetW, targetH}
      delay 0.25
      set p to position of window 1
      set s to size of window 1
      return ((item 1 of p as integer) as text) & "," & ((item 2 of p as integer) as text) & "," & ((item 1 of s as integer) as text) & "," & ((item 2 of s as integer) as text)
    end tell
  end tell
end run
OSA
}

quit_app() {
  osascript -e "tell application id \"$BUNDLE_ID\" to quit" >/dev/null 2>&1 || true
  pkill -x "$APP_NAME" >/dev/null 2>&1 || true
}

launch_app() {
  local args_text="$1"
  read -r -a launch_args <<< "$args_text"
  quit_app
  sleep 0.4
  open -n "$APP" --args "${launch_args[@]}" >/dev/null 2>&1
  sleep 0.8
  osascript -e "tell application id \"$BUNDLE_ID\" to activate" >/dev/null 2>&1 || true
}

append_row() {
  local group="$1" case_id="$2" tier="$3" swap="$4" status="$5" args="$6" bounds="$7" shot="$8" sha="$9" guard="${10}"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$group" "$case_id" "$tier" "$swap" "$status" "$args" "$bounds" "$shot" "$sha" "$guard" >> "$CAPTURE_TSV"
}

finalize_receipt() {
  local overall="$1"
  python3 - "$CAPTURE_TSV" "$RECEIPT" "$overall" "$OUT_ROOT" "$CROP_CHECKLIST" "$CAPTURE_PLAN" <<'PY'
import csv
import hashlib
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

tsv_path = Path(sys.argv[1])
receipt_path = Path(sys.argv[2])
overall = sys.argv[3]
out_root = Path(sys.argv[4])
crop_checklist = Path(sys.argv[5])
capture_plan = Path(sys.argv[6])

rows = []
with tsv_path.open(encoding="utf-8") as handle:
    for row in csv.DictReader(handle, delimiter="\t"):
        rows.append(row)

def rel(path_text: str) -> str:
    if not path_text:
        return ""
    path = Path(path_text)
    try:
        return str(path.relative_to(out_root))
    except ValueError:
        return path_text

items = []
for row in rows:
    items.append({
        "group": row["group"],
        "case_id": row["case_id"],
        "window_tier": row["window_tier"],
        "visual_swap": row["visual_swap"],
        "status": row["status"],
        "launch_args": row["launch_args"].split() if row["launch_args"] else [],
        "window_bounds": row["window_bounds"],
        "screenshot_path": rel(row["screenshot_path"]),
        "screenshot_sha256": row["screenshot_sha256"],
        "privacy_guard": row["privacy_guard"]
    })

payload = {
    "artifact_kind": "t6r_idle_window_v2_receipt",
    "status": overall,
    "captured_at_utc": datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z"),
    "proof_class": "local/mac_runtime_smoke" if overall != "DRY_RUN" else "local/dry_run_plan",
    "output_root": str(out_root),
    "items": items,
    "crop_checklist": rel(str(crop_checklist)),
    "capture_plan": rel(str(capture_plan)),
    "privacy_guard": {
        "mechanical": True,
        "before_each_real_screenshot": True,
        "failure_exit_code": 65
    },
    "non_claims": [
        "not_5_gate_approval",
        "not_operator_pass",
        "not_true_device",
        "not_v_pass",
        "not_c6_acceptance"
    ]
}
receipt_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(receipt_path)
PY
}

capture_case() {
  local group="$1"
  local case_id="$2"
  local tier="$3"
  local width="$4"
  local height="$5"
  local delay_seconds="$6"
  local visual_swap="$7"
  local scenario_args="$8"
  local swap_args="$9"
  local launch_args="$scenario_args $swap_args"
  local status="READY"
  local bounds=""
  local guard="NOT_RUN"
  local shot=""
  local sha=""

  if [[ "$DRY_RUN" == "1" ]]; then
    append_row "$group" "$case_id" "$tier" "$visual_swap" "DRY_RUN" "$launch_args" "" "" "" "DRY_RUN"
    return
  fi

  launch_app "$launch_args"
  bounds="$(set_window_size "$width" "$height" 2>/dev/null || true)"
  sleep "$delay_seconds"
  guard="$(privacy_guard 2>/dev/null || true)"
  if [[ "$guard" != "PASS" ]]; then
    append_row "$group" "$case_id" "$tier" "$visual_swap" "BLOCKED_PRIVACY_GUARD" "$launch_args" "$bounds" "" "" "$guard"
    finalize_receipt "BLOCKED_PRIVACY_GUARD" >/dev/null
    echo "error: privacy guard blocked screenshot for $case_id/$tier/$visual_swap: $guard" >&2
    exit 65
  fi

  bounds="$(window_bounds 2>/dev/null || true)"
  if [[ "$bounds" == "PENDING_APP" || "$bounds" == "PENDING_WINDOW" || -z "$bounds" ]]; then
    status="$bounds"
    append_row "$group" "$case_id" "$tier" "$visual_swap" "$status" "$launch_args" "$bounds" "" "" "$guard"
    return
  fi

  IFS=',' read -r x y w h <<< "$bounds"
  local dir="$SHOT_DIR/visual-swap-$visual_swap"
  mkdir -p "$dir"
  shot="$dir/${group}-${case_id}-${tier}.png"
  screencapture -x -R"${x},${y},${w},${h}" "$shot"
  sha="$(shasum -a 256 "$shot" | awk '{print $1}')"
  append_row "$group" "$case_id" "$tier" "$visual_swap" "$status" "$launch_args" "$bounds" "$shot" "$sha" "$guard"
}

main() {
  require_tool python3
  if [[ "$DRY_RUN" != "1" ]]; then
    require_tool osascript
    require_tool screencapture
    require_tool shasum
  fi

  write_crop_checklist
  write_capture_plan

  if [[ "$DRY_RUN" != "1" ]]; then
    if [[ ! -d "$APP" ]]; then
      if [[ "$NO_BUILD" == "1" ]]; then
        echo "error: app bundle missing and --no-build set: $APP" >&2
        exit 2
      fi
      xcodebuild \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -configuration Debug \
        -destination 'platform=macOS' \
        -derivedDataPath "$DERIVED_DATA" \
        build 2>&1 | tee "$LOG_DIR/xcodebuild-$SCHEME.log"
    fi
    if [[ ! -d "$APP" ]]; then
      echo "error: app bundle missing after build: $APP" >&2
      exit 2
    fi
  fi

  local swap_id
  for swap_id in off on; do
    local swap_args=""
    if [[ "$swap_id" == "on" ]]; then
      swap_args="$VISUAL_SWAP_ON_ARGS"
    else
      swap_args="$VISUAL_SWAP_OFF_ARGS"
    fi

    capture_case "mac-hero-idle" "cooling-deep-space" "compact" 1280 800 1.25 "$swap_id" "-mockSnapshot cooling -mockTheme deepSpace -contextCapsuleRoute cLite" "$swap_args"
    capture_case "mac-hero-idle" "cooling-deep-space" "review" 1440 900 1.25 "$swap_id" "-mockSnapshot cooling -mockTheme deepSpace -contextCapsuleRoute cLite" "$swap_args"
    capture_case "mac-hero-idle" "cooling-deep-space" "hero" 1728 1117 1.25 "$swap_id" "-mockSnapshot cooling -mockTheme deepSpace -contextCapsuleRoute cLite" "$swap_args"
    capture_case "waterfall-first-frame" "cooling-deep-space" "hero" 1728 1117 0.18 "$swap_id" "-mockSnapshot cooling -mockTheme deepSpace -contextCapsuleRoute cLite" "$swap_args"
    capture_case "energy-line-probe" "golden-path-ac-success" "hero" 1728 1117 0.35 "$swap_id" "-goldenPathID uiue_g9b_ac_success_deep_space" "$swap_args"

    local state
    for state in normal satisfied changing blocked_with_alternative blocked_hard unsafe unknown; do
      capture_case "force-state-seven" "$state" "review" 1440 900 1.00 "$swap_id" "-forceVisualState $state -forceTheme deepSpace" "$swap_args"
    done
  done

  local overall="DONE"
  if [[ "$DRY_RUN" == "1" ]]; then
    overall="DRY_RUN"
  fi
  finalize_receipt "$overall" >/dev/null
  echo "T6R idle-window package: $OUT_ROOT"
  echo "Receipt: $RECEIPT"
  echo "Crop checklist: $CROP_CHECKLIST"
}

main "$@"
