---
name: query
description: Answer a question from the ai/wiki/ knowledge base with links to pages; file a valuable answer back into the wiki.
argument-hint: <question>
---

Question: $ARGUMENTS

1. Read ai/wiki/index.md, pick the relevant pages, read them.
2. Answer with links to wiki pages (and through them to ai/raw/). If the wiki does not have it, say so — do not make it up.
3. If the answer is a new synthesis worth reusing (a comparison, a conclusion across several pages), save it as a page in ai/wiki/, update index.md and append to ai/wiki/log.md: `## [YYYY-MM-DD] query | <question> | page: <…>`.
