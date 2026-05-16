#!/usr/bin/env bash
# One-time (idempotent) setup: create the gh-pages worktree at .site/ and make
# threads/ and output/ symlinks into it. Safe to re-run any time.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"
site="$repo_root/.site"

git rev-parse --git-dir >/dev/null 2>&1 || {
  echo "Not a git repository. Run 'git init' first." >&2; exit 1; }

have_remote() { git remote get-url origin >/dev/null 2>&1; }

commit_in_site() { # commit_in_site <message>
  git -C "$site" add -A
  git -C "$site" diff --cached --quiet && return 0
  if git -C "$site" config user.email >/dev/null 2>&1; then
    git -C "$site" commit -q -m "$1"
  else
    # No git identity configured anywhere — use a neutral fallback.
    git -C "$site" \
      -c user.name="${GIT_AUTHOR_NAME:-discourse-tools}" \
      -c user.email="${GIT_AUTHOR_EMAIL:-discourse-tools@local}" \
      commit -q -m "$1"
  fi
}

# --- 1. Ensure the .site worktree (checked out to gh-pages) exists -----------
if git -C "$site" rev-parse --git-dir >/dev/null 2>&1; then
  echo "Worktree .site/ already present."
elif git show-ref --verify --quiet refs/heads/gh-pages; then
  git worktree add "$site" gh-pages
  echo "Attached worktree .site/ to existing gh-pages branch."
elif have_remote && git ls-remote --exit-code --heads origin gh-pages >/dev/null 2>&1; then
  git fetch origin gh-pages:gh-pages
  git worktree add "$site" gh-pages
  echo "Fetched gh-pages from origin and attached worktree .site/."
else
  echo "Creating a fresh gh-pages branch..."
  git worktree add --detach "$site" >/dev/null
  git -C "$site" checkout --orphan gh-pages
  git -C "$site" rm -rf -q . >/dev/null 2>&1 || true
  mkdir -p "$site/threads" "$site/output"
  touch "$site/.nojekyll"
  printf '.DS_Store\n' > "$site/.gitignore"
  commit_in_site "Initialize gh-pages"
fi

mkdir -p "$site/threads" "$site/output"

# --- 2. Make threads/ and output/ symlinks into the worktree ----------------
for d in threads output; do
  if [ -L "$d" ]; then
    continue
  fi
  if [ -e "$d" ]; then            # a real folder with possibly-unpublished content
    mkdir -p "$site/$d"
    cp -R "$d/." "$site/$d/" 2>/dev/null || true
    rm -rf "$d"
  fi
  ln -s ".site/$d" "$d"
  echo "Linked $d -> .site/$d"
done

commit_in_site "Sync local threads/output into gh-pages"

# --- 3. Regenerate the gh-pages index ---------------------------------------
bash "$repo_root/scripts/build-index.sh"
commit_in_site "Update index"

# --- 4. Refresh the Pages link in README.md ---------------------------------
readme="$repo_root/README.md"
if [ -f "$readme" ]; then
  if have_remote; then
    url="$(git remote get-url origin)"; url="${url%.git}"
    path="$(printf '%s\n' "$url" | sed -E 's#^(git@|https?://)##; s#^[^/:]+[:/]##')"
    user="${path%%/*}"; repo="${path##*/}"
    if [ "$repo" = "$user.github.io" ]; then
      pages="https://$user.github.io/"
    else
      pages="https://$user.github.io/$repo/"
    fi
    link="[$pages]($pages)"
  else
    link='_Add a GitHub remote and re-run `./scripts/setup.sh` to fill this in._'
  fi
  LINK="$link" perl -0pi -e \
    's{<!-- PAGES-LINK -->.*?<!-- /PAGES-LINK -->}{<!-- PAGES-LINK -->$ENV{LINK}<!-- /PAGES-LINK -->}s' \
    "$readme"
fi

echo
echo "Setup complete."
if ! have_remote; then
  echo "No 'origin' remote yet. Add one and re-run setup.sh to enable"
  echo "publishing and to fill in the Pages link:"
  echo "  git remote add origin git@github.com:<you>/<repo>.git"
fi
