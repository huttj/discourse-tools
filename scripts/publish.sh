#!/usr/bin/env bash
# Commit and push everything under threads/ and output/ to the gh-pages branch.
# Usage: ./scripts/publish.sh "short message"
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
site="$repo_root/.site"

git -C "$site" rev-parse --git-dir >/dev/null 2>&1 || {
  echo "No .site worktree. Run ./scripts/setup.sh first." >&2; exit 1; }

# Refresh the landing page before committing.
bash "$repo_root/scripts/build-index.sh"

cd "$site"
git add -A
if git diff --cached --quiet; then
  echo "Nothing to publish — threads/ and output/ are unchanged."
  exit 0
fi

msg="${*:-Publish outputs ($(date +%Y-%m-%d))}"
git commit -q -m "$msg"
echo "Committed to gh-pages: $msg"

if git remote get-url origin >/dev/null 2>&1; then
  git push -u origin gh-pages
  echo "Pushed gh-pages to origin."
else
  echo "No 'origin' remote — committed locally only."
  echo "Add a remote, then run this script again to push."
fi
