# How to work in this project (claude-project-memory)

You remember nothing between sessions. **Your memory is only the files in `ai/` plus git history.** If it is not there, you do not know it.
The goal (ai/GOAL.md), state (ai/STATE.md) and plan (ai/PLAN.md) are already loaded into your context.

## File map
| File | What | Who edits | How to read |
|---|---|---|---|
| ai/GOAL.md | Goal, done-criteria K with a way to verify, non-goals | the human only | already loaded |
| ai/PLAN.md | Milestones M → criteria K; tasks T of the active milestone | you | already loaded, ≤ 40 lines |
| ai/STATE.md | Where we are, milestone, task, next step, open questions, active decisions | you, full rewrite | already loaded, ≤ 60 lines |
| ai/MAP.md | Map of the output: code modules/packages or book chapters, 1–3 lines each | you | first, before searching the project |
| ai/wiki/index.md | Knowledge base catalog | you | first, before opening ai/wiki/ |
| ai/wiki/ | Knowledge base (Karpathy-style LLM wiki) | you | only the pages you need |
| ai/DECISIONS.md | Decision log D-NNN | you, append only | `grep` only, never read in full |
| ai/LOG.md | Session log | you, append only | the end only (`tail`) |
| ai/BACKLOG.md | Deferred ideas | you | when needed |
| ai/raw/ | Primary sources | the human only | via /ingest |
| ai/PLAN-archive.md, ai/sessions/ | Closed milestones; transcript copies | — | only when the human asks |
| everything else | The actual output: code, chapters, texts | you | only what you need, large files in parts |

## Session protocol
**Start.** A hook added the tail of the log and the git status. If it says files changed after the last /save, the previous session ended abruptly: run /save first. Then answer in three lines: goal / where we are / next step.

**Work in tasks.** A task fits into one session. Take the next open task of the active milestone in ai/PLAN.md. If it turns out bigger, split it first (/breakdown), then do the first part.

**Course check.** Before a task, name the milestone M and the criterion K it moves. None? Stop and ask. Interesting but "not now" → one line in ai/BACKLOG.md, then back to the task.
(While ai/GOAL.md carries the `project-memory:unset` marker, the only task is /kickoff.)

**Decisions.** Check "Active decisions" in STATE and `grep` ai/DECISIONS.md. Never silently revisit a decision: write a new D-NNN entry with the reason.

**Knowledge.** Durable knowledge (how the system works, a pitfall, a fact about the book's world) → ai/wiki/, not STATE.

**Checkpoint.** /save after a finished task, before a big new task, at the end of a session, after a context compaction. The Stop hook will demand /save if STATE lags behind for too long.

**Done.** A milestone is closed only when its criterion's "Check" passes (/check).

**Git.** Only the human commits. You never run `git add/commit/push/reset/checkout` — after /save you suggest a one-line commit message.

## Saving context and tokens
- Never read the whole project or ai/wiki/. Path: ai/MAP.md / ai/wiki/index.md → search (`grep`, glob) → the file → the part you need.
- A broad code survey (many files) goes through an Explore subagent: only the conclusion comes back, not file contents.
- Do not re-read an unchanged file. Edit precisely (Edit), do not rewrite whole files — except ai/STATE.md.
- Do not paste file contents back to the human. Keep reports short.
- Build/test output: only the tail and the errors (`| tail -50`).
- Subagents save this session's context but cost the same tokens — use them only when there is a lot to read.
- The conversation got long → /save, then the human runs /clear.

## Code (if the project is software)
- The "Check" of criteria and tasks is a build/test command. A task is done when its test passes.
- ai/MAP.md lists modules and packages, not every file.
- Rules that apply to one module only go into a CLAUDE.md inside that module's folder (Claude Code loads it only when working there).

## Wiki rules (after Karpathy)
- ai/raw/ — primary sources, immutable. ai/wiki/ — your pages.
- ai/wiki/index.md — catalog: link + one line "what is here and when to read it". Over ~80 entries → split into sections with their own index.md.
- ai/wiki/log.md — operations log, append only.
- One topic = one page, ≤ 300 lines. Check the index before creating a page.
- Every fact has a source: `raw/…`, a code path, or `session YYYY-MM-DD`. Do not overwrite contradictions — mark `⚠ contradiction:` with links to both sides.
- Operations: /ingest, /query, /lint.

## Forbidden
- Never change ai/GOAL.md or ai/raw/ in any way. Want to change the goal? Put a proposal under "Open questions" in STATE.
- No duplicates: if it is in the wiki or DECISIONS, STATE only links to it.
