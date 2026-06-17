#!/usr/bin/env bash
set -u

if [ "$#" -ne 1 ]; then
  printf 'usage: %s https://github.com/owner/repo\n' "$0" >&2
  exit 2
fi

url="$1"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPOS_DIR="$ROOT_DIR/repos"
repo="${url#https://github.com/}"
owner="${repo%%/*}"
name="${repo#*/}"
dir="$REPOS_DIR/${owner}__${name}"

mkdir -p "$REPOS_DIR"

if [ -d "$dir/.git" ]; then
  printf 'existing %s %s\n' "$repo" "$dir"
  exit 0
fi

rm -rf "$dir"
if GIT_TERMINAL_PROMPT=0 GIT_LFS_SKIP_SMUDGE=1 git \
  -c http.version=HTTP/1.1 \
  -c http.lowSpeedLimit=1000 \
  -c http.lowSpeedTime=45 \
  clone --depth 1 --no-tags --single-branch "$url" "$dir"; then
  printf 'cloned %s %s\n' "$repo" "$dir"
else
  rm -rf "$dir"
  printf 'clone_failed %s %s\n' "$repo" "$dir" >&2
  exit 1
fi
