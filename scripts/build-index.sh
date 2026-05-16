#!/usr/bin/env bash
# Regenerate the gh-pages landing page (.site/index.html) listing all outputs.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
site="$repo_root/.site"

[ -d "$site" ] || { echo "No .site worktree — run scripts/setup.sh first." >&2; exit 1; }

out="$site/index.html"

{
  cat <<'HEAD'
<!doctype html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>discourse-tools — outputs</title>
<style>
  body{font:16px/1.6 system-ui,-apple-system,sans-serif;max-width:42rem;margin:3rem auto;padding:0 1.2rem;color:#111}
  h1{font-size:1.5rem;margin-bottom:.2rem}
  p.sub{color:#666;margin-top:0}
  ul{list-style:none;padding:0}
  li{margin:.45rem 0}
  a{color:#1d4ed8;text-decoration:none}
  a:hover{text-decoration:underline}
  .empty{color:#888}
</style>
</head>
<body>
<h1>discourse-tools</h1>
<p class="sub">Interactive visualizations of X/Twitter threads.</p>
<ul>
HEAD

  shopt -s nullglob
  found=0
  for f in "$site"/output/*.html; do
    found=1
    name="$(basename "$f")"
    printf '  <li><a href="output/%s">%s</a></li>\n' "$name" "$name"
  done
  [ "$found" -eq 0 ] && printf '  <li class="empty">No outputs published yet.</li>\n'

  cat <<'FOOT'
</ul>
</body>
</html>
FOOT
} > "$out"

echo "Built $out"
