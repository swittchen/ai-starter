---
name: ingest
description: Process a new source from ai/raw/ into the ai/wiki/ knowledge base (Karpathy-style LLM wiki). Argument — path to a file in ai/raw/.
argument-hint: ai/raw/<file>
context: fork
---

Process the source: $ARGUMENTS

0. Size: if the source is longer than ~40 pages / ~15,000 words, do not read it all. Process the first part (chapter/section) and list the remaining parts in the report so the human can run /ingest part by part.
1. Read ai/wiki/index.md — what already exists.
2. Read the source (or its part).
3. Create ai/wiki/src-<short-name>.md: what the source is about, 5–10 key takeaways, link to the file in ai/raw/.
4. Update concept pages the source extends or contradicts (read only those, found via the index). New pages only for topics that do not exist yet. Contradictions → `⚠ contradiction:` with links.
5. Every added fact has a link to its source.
6. Update ai/wiki/index.md; append to ai/wiki/log.md: `## [YYYY-MM-DD] ingest | <source> | touched: <pages>`.
7. Return a SHORT report (≤ 10 lines): key takeaways and the list of touched pages. Do not retell the source.
