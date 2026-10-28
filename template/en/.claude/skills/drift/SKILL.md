---
name: drift
description: Check whether the work has drifted away from the project goal over recent sessions.
disable-model-invocation: true
---

1. Take `tail -n 40 ai/LOG.md` and `git log --oneline -20` (never read the whole LOG); GOAL, STATE, PLAN are already in context.
2. For each piece of work, name the criterion K it moved. Work without a K is "off-goal".
3. Estimate the share of effort: how much went into criteria, how much off-goal.
4. Were any non-goals from ai/GOAL.md violated?
5. Suggest what to move to ai/BACKLOG.md to get back to the most important open milestone.
