# discourse-tools

Turn an X/Twitter thread into an interactive, shareable visualization — an
**argument graph** or a **tweet plot** — with the help of an LLM.

🔗 **Published outputs:** <!-- PAGES-LINK -->[https://huttj.github.io/discourse-tools/](https://huttj.github.io/discourse-tools/)<!-- /PAGES-LINK -->

## Setup

```sh
./scripts/setup.sh
```

Run this once after cloning or forking. It creates the `gh-pages` worktree and
the `threads/` + `output/` folders (symlinks into that worktree) and pulls any
already-published content.

To publish to the web, add a GitHub remote, push, and enable GitHub Pages
(repo **Settings → Pages → Branch: `gh-pages`**):

```sh
git remote add origin git@github.com:<you>/<repo>.git
git push -u origin main
./scripts/publish.sh "first publish"
./scripts/setup.sh   # refreshes the Pages link in this README — commit the change
```

## Usage

1. Install the scraper bookmarklet from `bookmarklet.html`, scrape a thread,
   and save the JSON into `threads/` (or just drop it in the repo root — the
   LLM will move it).
2. Ask an LLM to build a graph or a chart. In this repo, Claude Code follows
   [`CLAUDE.md`](CLAUDE.md).
3. The result lands in `output/<slug>-graph.html` (or `-chart.html`). Open it
   in a browser directly, or...
4. Run `./scripts/publish.sh "..."` to push it live on GitHub Pages.

## How it's laid out

- **`main` branch** — templates, the scraper bookmarklet, scripts, docs.
  No inputs or outputs.
- **`gh-pages` branch** — every `threads/` input and `output/` visualization,
  plus an auto-generated `index.html`. This is what GitHub Pages serves.
- Locally, `threads/` and `output/` are symlinks into `.site/` — a git worktree
  checked out to `gh-pages`. You see them as ordinary folders, but they are
  git-ignored on `main`, so they never get committed there by accident.

### Scripts

| Script                   | What it does                                              |
| ------------------------ | --------------------------------------------------------- |
| `scripts/setup.sh`       | One-time setup: gh-pages worktree + `threads`/`output` links. Re-run any time; it's idempotent. |
| `scripts/publish.sh`     | Commit + push `threads/` and `output/` to `gh-pages`.     |
| `scripts/sync.sh`        | Pull the latest published `gh-pages` content.             |
| `scripts/build-index.sh` | Regenerate the `gh-pages` `index.html` (called by the others). |

See [`CLAUDE.md`](CLAUDE.md) for the full LLM workflow.
