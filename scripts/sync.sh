#!/usr/bin/env bash
# Pull the latest published gh-pages content into the local worktree.
# Because threads/ and output/ are symlinks into .site/, they update in place.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
site="$repo_root/.site"

git -C "$site" rev-parse --git-dir >/dev/null 2>&1 || {
  echo "No .site worktree. Run ./scripts/setup.sh first." >&2; exit 1; }

if git -C "$site" remote get-url origin >/dev/null 2>&1; then
  git -C "$site" pull --ff-only origin gh-pages
  echo "Synced — threads/ and output/ are up to date with gh-pages."
else
  echo "No 'origin' remote — nothing to sync."
fi
