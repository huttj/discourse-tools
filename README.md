# discourse-tools

Turn an X/Twitter thread into an interactive, shareable visualization — an
**argument graph** or a **tweet plot** — with the help of an LLM.

🔗 **Published outputs:** <!-- PAGES-LINK -->[https://huttj.github.io/discourse-tools/](https://huttj.github.io/discourse-tools/)<!-- /PAGES-LINK -->

## How it's laid out

- **`main` branch** — the tool: templates, the scraper bookmarklet, docs.
  No inputs or outputs.
- **`gh-pages` branch** — every thread input and finished visualization, plus a
  self-updating `index.html`. This is what GitHub Pages serves.
- **`published/`** — a git worktree checked out to `gh-pages`. Your inputs and
  outputs live here as ordinary files; it's git-ignored from `main`, so they're
  never committed there by accident.

## Setup

After cloning or forking, create the `published/` worktree once:

```sh
git worktree add published gh-pages
```

To publish to the web, add a GitHub remote, push, and enable GitHub Pages
(repo **Settings → Pages → Branch: `gh-pages`**):

```sh
git remote add origin git@github.com:<you>/<repo>.git
git push -u origin main
git push -u origin gh-pages
```

## Usage

1. Install the scraper bookmarklet from `bookmarklet.html`, scrape a thread,
   and save the JSON into `published/threads/` (or drop it in the repo root —
   the LLM will move it).
2. Ask an LLM to build a graph or a chart. In this repo, Claude Code follows
   [`CLAUDE.md`](CLAUDE.md).
3. The result lands in `published/output/<slug>-graph.html` (or `-chart.html`).
   Open it in a browser directly.
4. Publish it:

   ```sh
   cd published && git add -A && git commit -m "..." && git push
   ```

To pull others' published content: `cd published && git pull`.

See [`CLAUDE.md`](CLAUDE.md) for the full LLM workflow.
