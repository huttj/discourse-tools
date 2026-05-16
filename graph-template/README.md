# Argument Graph Template

A self-contained kit for turning an X/Twitter thread into an interactive
argument graph. Everything you need is in this folder.

## Files

| File                   | What it is                                                    |
| ---------------------- | ------------------------------------------------------------- |
| `bookmarklet.html`     | Install page for the thread-scraper bookmarklet.              |
| `prompt.md`            | The prompt that turns scraped tweets into graph JSON.         |
| `graph-template.html`  | The visualizer, with a placeholder where the JSON goes.       |

`bookmarklet.html` and `graph-template.html` are fully self-contained — the
scraper code and the visualizer bundle are inlined, so the folder can be copied
or shared as-is.

## Workflow

**1. Scrape a thread.**
Open `bookmarklet.html` over `http://` (e.g. `python3 -m http.server` in this
folder, then visit `localhost:8000/bookmarklet.html`). Drag the **Scrape
Thread** link to your bookmarks bar. On any X/Twitter thread, click it,
auto-scroll, then **Download JSON**.

**2. Extract the graph.**
Hand the scraped JSON plus `prompt.md` to Claude. It returns one combined JSON
object: `{ pfps, tweets, nodes, edges }`.

**3. Render it.**
Duplicate `graph-template.html` (e.g. `cp graph-template.html my-thread.html`).
In the copy, replace the string `"__GRAPH_DATA_PLACEHOLDER__"` — quotes
included — with the JSON object from step 2, so the line reads:

```html
<script>window.__EMBEDDED_DATA__ = { "pfps": { ... }, "nodes": [ ... ] };</script>
```

Open the file in a browser. Done — a shareable, single-file graph.

## Notes

- `pfps` map profile-picture URLs straight through. They load fine in most
  browsers; if you need a fully offline file, the repo's `transform_tweets.js`
  can inline them as base64 instead.
- The visualizer also accepts `?load=<url>` to fetch a JSON file at runtime
  instead of embedding it.
- To regenerate `graph-template.html`/`bookmarklet.html` after changing the
  visualizer or scraper, rebuild from the project root.
