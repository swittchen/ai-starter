---
name: save
description: Project checkpoint — moves what matters from the conversation into the ai/ memory files and suggests a commit message. After a finished task, before a big new task, at the end of a session, after a context compaction, or when the Stop hook asks.
---

Checkpoint. Be frugal: ai/GOAL.md, ai/STATE.md, ai/PLAN.md are already in context — do not re-read them; never read ai/DECISIONS.md or ai/LOG.md in full — only append.
Order matters: ai/STATE.md is written LAST (hooks use its modification time to know everything is saved).

0. Course (silently): what was done since the last /save and which K it served. Name any "off-goal" work in the report.
1. ai/PLAN.md: tick finished tasks [x]. Milestone closed and verified (/check) → one line in the table, its tasks go to ai/PLAN-archive.md. Active milestone changed and has no tasks → split it (as in /breakdown). PLAN ≤ 40 lines.
2. ai/DECISIONS.md: append this session's new decisions.
3. ai/wiki/: this session's durable knowledge → pages; update index.md, append to ai/wiki/log.md.
4. ai/MAP.md: modules/files/chapters added, renamed or substantially changed → update entries.
5. ai/BACKLOG.md: everything that drops out of the old STATE but is still relevant.
6. ai/LOG.md: append 3–5 lines (date, session, done, D-…, wiki pages).
7. ai/STATE.md — rewrite in full, ≤ 60 lines: where we are, milestone, task, ONE concrete next step, open questions, active decisions (≤ 10, D-NNN), important wiki pages.
8. Do NOT commit. Output exactly:
   - "Next step: …"
   - "Suggested commit: `<type>: <what was done, ≤ 72 chars>`"
   - if the conversation is already long — "I recommend /clear".
