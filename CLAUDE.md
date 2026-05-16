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
- The prompt outputs `{ axes, categories, data }`. The template also needs the
  scraped tweets — combine them with the nested form the template accepts:
  `{ "tweetData": <scraped thread JSON>, "categorizationData": <prompt output> }`.

`bookmarklet.html` (repo root) installs the browser bookmarklet that scrapes a
thread into the raw JSON these pipelines consume.

## Where inputs and outputs live — `published/`

Inputs and outputs are **not part of the `main` branch**. They live in
`published/` — a git worktree checked out to the `gh-pages` branch. `main`
holds only the tool (templates, bookmarklet, docs); `gh-pages` holds the
content and is what GitHub Pages serves.

- **Inputs:** scraped thread JSON → `published/threads/<slug>.json`
- **Outputs:** finished visualizations → `published/output/<slug>-graph.html`
  or `published/output/<slug>-chart.html`

If `published/` does not exist yet (fresh clone or fork), create it once:

```sh
git worktree add published gh-pages
```

If a `.json` file appears at the **repo root** — a user dropped it there — move
it into `published/threads/`, renamed to a kebab-case slug (e.g. a root
`Dark_Matter.json` becomes `published/threads/dark-matter.json`). Always
process threads from `published/threads/`, never from the repo root.

## Workflow for a request

1. Ensure `published/` exists (see above). Find the input thread JSON in
   `published/threads/`, moving it there from the repo root if needed.
2. Pick the pipeline the user asked for (graph or chart).
3. Run that folder's `prompt.md` against the thread JSON to produce the data.
4. Copy the template into `published/output/<slug>-<graph|chart>.html`.
5. Replace the `"__*_DATA_PLACEHOLDER__"` string with the combined JSON object.
6. Publish — see below.

## Publishing

To publish new or changed inputs/outputs, commit them on the `gh-pages` branch
from inside the worktree and push:

```sh
cd published && git add -A && git commit -m "short message" && git push
```

That's the whole publish step — plain git, run inside `published/`.

- The `published/index.html` landing page lists outputs automatically; you
  never edit or regenerate it.
- Never commit inputs/outputs to `main`. On `main` the `published/` path is
  git-ignored, so a stray `git add -A` on `main` silently skips it — that is
  intentional, not a bug.
- To pull teammates' published content: `cd published && git pull`.
- Adding the GitHub remote is the user's job, not yours.

## Naming conventions

- Slugs: kebab-case (`dark-matter`, not `dark_matter`).
- Thread input: `published/threads/<slug>.json`.
- Output: `published/output/<slug>-graph.html` or `<slug>-chart.html`.
