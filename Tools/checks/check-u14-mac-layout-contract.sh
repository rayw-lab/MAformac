#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SOURCE="$ROOT/App/ContentView.swift"

if [[ ! -f "$SOURCE" ]]; then
  echo "FAIL: missing App/ContentView.swift" >&2
  exit 1
fi

clean_source="$(sed -E 's,//.*$,,' "$SOURCE")"

require_contains() {
  local needle="$1"
  local label="$2"
  if ! grep -Fq "$needle" <<<"$clean_source"; then
    echo "FAIL: missing $label ($needle)" >&2
    exit 1
  fi
}

require_absent() {
  local needle="$1"
  local label="$2"
  if grep -Fq "$needle" <<<"$clean_source"; then
    echo "FAIL: forbidden $label ($needle)" >&2
    exit 1
  fi
}

uses_mac_split_body="$(
  awk '
    /private func usesMacSplit\(size: CGSize\) -> Bool/ { capture = 1 }
    capture { print }
    capture && /^    private func / && !/usesMacSplit/ { exit }
  ' "$SOURCE"
)"

require_contains "private func stageBody(size: CGSize)" "stageBody gate"
require_contains "usesMacSplit(size: size)" "stageBody -> usesMacSplit"
require_contains "AnyLayout(HStackLayout" "Mac split AnyLayout(HStackLayout)"
require_contains "layout: .macPanorama" "Mac panorama layout"
require_contains "private func usesMacSplit(size: CGSize) -> Bool" "usesMacSplit helper"
require_absent "NavigationSplitView" "NavigationSplitView in U14 Mac split"
require_absent "LazyVGrid" "adaptive LazyVGrid in ContentView"

if ! grep -Fq "#if os(macOS)" <<<"$uses_mac_split_body"; then
  echo "FAIL: usesMacSplit must keep macOS compile gate" >&2
  exit 1
fi

if ! grep -Fq "size.width" <<<"$uses_mac_split_body"; then
  echo "FAIL: usesMacSplit must be geometry-width driven" >&2
  exit 1
fi

if grep -Fq "horizontalSizeClass" <<<"$uses_mac_split_body" || grep -Fq "sizeClass" <<<"$uses_mac_split_body"; then
  echo "FAIL: Mac split gate must not be sizeClass-driven" >&2
  exit 1
fi

echo "PASS: U14 Mac layout contract locked"
