#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPOS_DIR="$ROOT_DIR/repos"
URLS_FILE="$ROOT_DIR/repo_urls.txt"
STATUS_FILE="$ROOT_DIR/clone_status.md"

mkdir -p "$REPOS_DIR"
printf '# Clone Status\n\nGenerated: %s\n\n| Repo | Local Path | Status |\n|---|---|---|\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$STATUS_FILE"

while IFS= read -r url; do
  [ -z "$url" ] && continue
  repo="${url#https://github.com/}"
  owner="${repo%%/*}"
  name="${repo#*/}"
  dir="$REPOS_DIR/${owner}__${name}"

  if [ -d "$dir/.git" ]; then
    if [ "${CLONE_SKIP_EXISTING:-0}" = "1" ]; then
      printf '| `%s` | `%s` | existing |\n' "$repo" "$dir" >> "$STATUS_FILE"
      continue
    fi
    if GIT_TERMINAL_PROMPT=0 GIT_LFS_SKIP_SMUDGE=1 git -C "$dir" -c http.version=HTTP/1.1 -c http.lowSpeedLimit=1000 -c http.lowSpeedTime=45 fetch --all --prune --quiet &&
      GIT_TERMINAL_PROMPT=0 GIT_LFS_SKIP_SMUDGE=1 git -C "$dir" reset --hard --quiet HEAD; then
      printf '| `%s` | `%s` | updated |\n' "$repo" "$dir" >> "$STATUS_FILE"
    else
      printf '| `%s` | `%s` | fetch_failed |\n' "$repo" "$dir" >> "$STATUS_FILE"
    fi
  else
    if GIT_TERMINAL_PROMPT=0 GIT_LFS_SKIP_SMUDGE=1 git -c http.version=HTTP/1.1 -c http.lowSpeedLimit=1000 -c http.lowSpeedTime=45 clone --depth 1 --no-tags --single-branch "$url" "$dir"; then
      printf '| `%s` | `%s` | cloned |\n' "$repo" "$dir" >> "$STATUS_FILE"
    else
      rm -rf "$dir"
      printf '| `%s` | `%s` | clone_failed |\n' "$repo" "$dir" >> "$STATUS_FILE"
    fi
  fi
done < "$URLS_FILE"
