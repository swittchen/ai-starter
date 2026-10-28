---
name: lint
description: Health check of the ai/wiki/ knowledge base — catalog, links, page length, duplicates, contradictions, facts without a source.
disable-model-invocation: true
---

1. Run `bash .claude/scripts/wiki-lint.sh` — the mechanical part (catalog, broken links, long pages) is checked by the script without reading pages.
2. Fix what it found.
3. The semantic part — frugally: read only ai/wiki/index.md and use it to pick pairs of pages on similar topics (candidate duplicates/contradictions), at most 6 pages per /lint. Read each page only once.
4. Fix the obvious, list the debatable for me. Append to ai/wiki/log.md: `## [YYYY-MM-DD] lint | <result>`.
