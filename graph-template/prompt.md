# Tweets → Argument Graph

Paste this whole file to Claude, then attach the JSON file produced by the
Scrape Thread bookmarklet. Claude's job: turn the raw thread into one combined
JSON object that drops straight into `graph-template.html`.

---

I want to do an exercise where you read a bunch of tweets and then break them
out into conceptual space.

Some of the tweets might not have arguments, but for those that do, I want you
to:

1. Extract the arguments, as-is.
2. Try to detangle the arguments so that you can cleanly represent each of them
   separately (as much as possible).
3. Sort the arguments from general to specific — the first argument in the list
   is the "root," and all of the other arguments should branch off from that
   one or from subsequent ones (except for non sequiturs, those can be
   freestanding).
4. Consider the branching, and find a meaningful relation that turns the
   arguments into a graph, where the central argument is followed by the
   largest in-favor and counter arguments, which themselves are followed by
   more and more nuanced and detailed arguments.

Focus on argumentation, logic, and rationality here. I'm not asking you to
classify, categorize, or group tweets. What I'm looking for is the nature and
the structure of the argumentation — how each claim, implicit or explicit, good
faith or bad, plays off of the others. You can infer arguments from the way
people are speaking, but only if it's clear.

## Output format

Produce **a single JSON object** with exactly these four keys:

```json
{
  "pfps": {
    "<screen_name>": "<pfp_url>"
  },
  "tweets": [{
    "id": "<tweet id>",
    "author": "<screen_name>",
    "name": "<display name>",
    "text": "<tweet text>",
    "likes": <integer>,
    "timestamp": "<created_at>",
    "url": "https://x.com/<screen_name>/status/<tweet id>",
    "replyTo": "<parent tweet id or null>",
    "replyToScreenNames": ["<screen_name>"],
    "media": [ ... ]
  }],
  "nodes": [{
    "id": "<id>",
    "label": "<simple, concise description of the argument>",
    "description": "<more detailed explanation of the argument>",
    "tweets": ["<tweet id>"]
  }],
  "edges": [{
    "id": "<edge id>",
    "from": "<source node id>",
    "to": "<target node id>",
    "value": <integer>
  }]
}
```

### `pfps` and `tweets` — mechanical conversion of the scraper input

For every tweet in the scraper file, copy the fields straight across. The
scraper's raw field is on the left, the output field on the right:

| scraper field                                  | output field          |
| ----------------------------------------------- | --------------------- |
| `id`                                            | `id`                  |
| `screen_name`                                   | `author`              |
| `name`                                          | `name`                |
| `text`                                          | `text`                |
| `favorite_count` (default `0`)                  | `likes`               |
| `created_at`                                    | `timestamp`           |
| —                                               | `url` (build it)      |
| `inferred_in_reply_to_id` ?? `in_reply_to_status_id` ?? `null` | `replyTo` |
| `in_reply_to_screen_names` (default `[]`)        | `replyToScreenNames`  |
| `media` (default `[]`)                           | `media`               |

Skip any tweet missing an `id` or `screen_name`. For `pfps`, map each unique
`screen_name` to its `pfp_url` (first non-empty one wins).

### `nodes` and `edges` — the argument graph

The edge `value` indicates how much the `to` argument diverges from the `from`
argument. Most values are 1–10 in magnitude; some may reach 100 if extremely
divergent — use your judgement. The value is **positive** if the `to` argument
*extends* the `from` argument, and **negative** if it *contradicts* it. This is
about the specific `to`/`from` pair, not the root argument.

Each node's `tweets` array lists the IDs of the tweets that argument is drawn
from, so the visualizer can show the source.

Output only the final JSON object — no surrounding prose, no code fence
needed in the file. I'll paste it into `graph-template.html`.
