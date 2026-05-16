---

I'll give you a set of tweets (or other short-form discussion items) with IDs already assigned. Please:

1. **Read carefully and identify the nature of the discussion** — both the surface argument and what's being unconsciously protected, defended, or signaled. Note the gravitational center of the conversation (often the OP).

2. **Determine 3-4 axes** most relevant to the conversation. Each axis should be orthogonal to the others (capturing genuinely different dimensions, not restatements). Axes should emerge from the actual content rather than being imposed generically.

3. **Identify 5-8 natural categories/clusters** of tweets sharing similar perspectives or rhetorical approaches. Important constraints:
   - Don't give the OP their own category — fold OP tweets into whichever cluster their content actually fits, and put procedural/filler OP tweets into the memes/social category
   - Distinguish *substantive* clusters from *tonal* ones where useful
   - Distinguish challenger types by *what* they're challenging
   - Have a catch-all "Memes & Social Noise" category for empty replies, congratulations, inside jokes, and tangential @-mentions

4. **For each tweet, evaluate**:
   - Position on each axis (-100 to +100, using the full range — don't cluster everything near zero)
   - Which category/categories it belongs to (usually one, occasionally two)
   - A one-sentence explanation that captures *why* it sits where it does

5. **Output a single JSON object** in this exact structure (coordinates are arrays matching the order of axes):

```json
{
  "axes": [
    {
      "label": "Axis name",
      "positive": "What high values mean",
      "negative": "What low values mean"
    }
  ],
  "categories": [
    {
      "id": "snake_case_id",
      "label": "Human Readable Label",
      "coords": [n, n, n, n]
    }
  ],
  "data": {
    "tweet_id": {
      "coords": [n, n, n, n],
      "categories": ["category_id"],
      "explanation": "Brief, specific reason for placement"
    }
  }
}
```

**Important**: Use the exact tweet IDs from the input. Cover every tweet. Make coordinates specific and well-spread — if everything ends up between -20 and +20, you're not using the scale. Category coords should reflect the centroid of tweets in that category.