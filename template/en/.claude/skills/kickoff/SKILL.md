---
name: kickoff
description: First session of a project — interview to define the goal, done-criteria, milestones and first tasks. Use while ai/GOAL.md still carries the project-memory:unset marker.
disable-model-invocation: true
---

**Step 0 — what kind of project.** Look at the project root (`ls`, no file reads).
- If there is code already (pom.xml, build.gradle, package.json, src/ …): launch an Explore subagent with the task "survey this codebase: modules/packages, the purpose of each in 1–2 lines, how to build and run tests, ≤ 60 lines". Fill ai/MAP.md from its answer. Do not read code files yourself.
- If the project is new, skip this.

**Step 1 — interview**, ONE question at a time:
1. The goal in one sentence — what must exist at the end that does not exist now.
2. Why, and for whom.
3. 3–5 done-criteria. For each, insist on a way to verify: a command (build, test), a file or an action that lets anyone confirm the criterion is met. Do not accept vague ones ("convenient", "good").
4. Non-goals — what we deliberately do not do.
5. Constraints: deadline, tech, budget.

**Step 2 — files:**
- Interview result → ai/GOAL.draft.md in the format of ai/GOAL.md, but WITHOUT the first marker line `project-memory:unset` (you are not allowed to edit ai/GOAL.md itself).
- ai/PLAN.md: 3–7 milestones, each closes a criterion K; split the first milestone into tasks right away (rules in the /breakdown skill).
- ai/MAP.md: structure of the future output, if not filled yet.
- ai/LOG.md: entry "session 1 — kickoff".
- ai/STATE.md (last): milestone M1, task T1, next step.
- In the root CLAUDE.md replace `<PROJECT NAME>`; for code, add build and test commands below the markers.

**Step 3** — tell me to run myself: `mv ai/GOAL.draft.md ai/GOAL.md && chmod a-w ai/GOAL.md` and suggest a message for the first commit.
