# discourse-tools — instructions for the LLM

This repo turns an X/Twitter thread into an interactive, shareable, single-file
HTML visualization. There are two pipelines. Each is a **prompt** + an LLM +
a self-contained **HTML template**.

## Pipelines

### 1. Argument Graph — `graph-template/`
- `graph-template/prompt.md` — extracts the argument *structure* of a thread
  (claims, support, rebuttals) into a node/edge graph.
- `graph-template/graph-template.html` — the visualizer. Data slot: the literal
  string `"__GRAPH_DATA_PLACEHOLDER__"` (quotes included).
- Data shape: **one** JSON object `{ pfps, tweets, nodes, edges }`. The prompt
  describes the full mechanical conversion from the scraped thread.

### 2. Tweet Plot / Chart — `chart-template/`
- `chart-template/prompt.md` — places each tweet on 3–4 axes and into
  categories.
- `chart-template/chart-template.html` — the visualizer. Data slot: the literal
  string `"__CHART_DATA_PLACEHOLDER__"` (quotes included).
- The prompt outputs `{ axes, categories, data }`. The template needs the
  scraped tweets too — combine them with the nested form the template accepts:
  `{ "tweetData": <scraped thread JSON>, "categorizationData": <prompt output> }`.

`bookmarklet.html` (repo root) installs the browser bookmarklet that scrapes a
thread into the raw JSON these pipelines consume.

## Inputs — `threads/`

Raw scraped thread JSON lives in `threads/<slug>.json`.

**If a `.json` file appears at the repo root** — a user dropped it there — move
it into `threads/` first, renamed to a kebab-case slug
(e.g. a root `Dark_Matter.json` becomes `threads/dark-matter.json`). Always
process threads from `threads/`, never from the repo root.

## Outputs — `output/`

Every finished visualization goes in `output/`:
- Graph: `output/<slug>-graph.html`
- Chart: `output/<slug>-chart.html`

To build one: copy the template HTML into `output/`, then replace its
placeholder string (quotes included) with the combined JSON object.

## Workflow for a request

1. Find the input thread JSON in `threads/`. If the user dropped one at the
   repo root, move it into `threads/<slug>.json` first.
2. Pick the pipeline the user asked for (graph or chart).
3. Run that folder's `prompt.md` against the thread JSON to produce the data.
4. Copy the template into `output/<slug>-<graph|chart>.html`.
5. Replace the `"__*_DATA_PLACEHOLDER__"` string with the combined JSON object.
6. Publish — see below.

## Publishing — IMPORTANT

`threads/` and `output/` are **not part of the `main` branch**. Locally they
are symlinks into `.site/`, a git worktree checked out to the `gh-pages`
branch. `main` stays clean (templates + scripts only); inputs and outputs are
versioned and published on `gh-pages`.

- **To publish** new or changed outputs, run: `./scripts/publish.sh "short message"`
  It commits everything under `threads/` + `output/`, regenerates the gh-pages
  `index.html`, and pushes `gh-pages` (if a remote is set).
- **Never** `git add` / `git commit` files under `threads/` or `output/`
  yourself, and never try to commit them to `main`. Use `publish.sh`. On `main`
  these paths are git-ignored, so a stray `git add -A` silently skips them —
  that is intentional, not a bug.
- **First run / fresh clone:** run `./scripts/setup.sh` once. It creates the
  `gh-pages` worktree and the `threads/` + `output/` symlinks, and pulls any
  already-published content.
- **To pull teammates' published outputs:** `./scripts/sync.sh`.
- Do not run destructive git commands inside `.site/`.
- Adding the GitHub remote is the user's job, not yours.

## Naming conventions

- Slugs: kebab-case (`dark-matter`, not `dark_matter`).
- Thread input: `threads/<slug>.json`.
- Output: `output/<slug>-graph.html` or `output/<slug>-chart.html`.
