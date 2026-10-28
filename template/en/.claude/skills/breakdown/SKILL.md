---
name: breakdown
description: Split a milestone (default — the active one) into tasks that each fit one session, and write them into ai/PLAN.md. Use when the active milestone has no tasks or a task turned out too big.
argument-hint: [M-number or T-number]
---

Split $ARGUMENTS (if empty — the active milestone in ai/PLAN.md) into tasks.

A good task:
- fits one session (roughly: the result can be made and verified in 1–2 hours of work);
- has a tangible result: a file, a function with a test, a chapter, a wiki page;
- tasks are ordered by dependency; the first is the one that removes the most uncertainty fastest;
- 3–8 tasks per milestone; more means the milestone should be split in two.

Format under "Tasks of the active milestone" in ai/PLAN.md:
`- [ ] T<n>: <action> → result: <what will exist>`

If you lack information to split it, ask me 1–3 questions first. Finally update "Current task" in ai/STATE.md.
