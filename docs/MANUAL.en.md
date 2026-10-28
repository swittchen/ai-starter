# ai-starter — the manual in plain words

## What it is, in two sentences

Imagine Claude is a skilled builder who arrives at the site every morning **with total memory loss**.
ai-starter is the **site logbook** kept right on the site: page one says **what we are building** (the goal), then **where we stopped yesterday** and **what to do today**, plus a **handbook** of everything learned so far.

The builder reads the logbook first and carries on as if nothing was forgotten. The logbook is the `ai/` folder in your project. Claude reads it by itself — you paste nothing.

---

## Step 1. What you need

```bash
claude --version
git --version
python3 --version
```
A version number means it is installed; `command not found` means it is not.
python is only needed in one case (step 4) and is optional. On Windows, use **Git Bash** (comes with Git for Windows) or WSL.

## Step 2. Download ai-starter (once per computer)

```bash
git clone https://github.com/swittchen/ai-starter.git ~/tools/ai-starter
```
`~` is your home folder. Any other location works too.

## Step 3. Make a short command (once)

An **alias** is a shortcut for the terminal:
```bash
echo "alias ai-starter='bash ~/tools/ai-starter/install.sh'" >> ~/.bashrc
source ~/.bashrc
```
The first line adds the shortcut to `~/.bashrc` (read by every new terminal); the second activates it now. On macOS with zsh use `~/.zshrc` instead. Check: `ai-starter --help`.

## Step 4. Add it to a project

**New project:**
```bash
ai-starter ~/projects/my-project          # add --lang ru for Russian templates
cd ~/projects/my-project && git init
```
**Existing project:**
```bash
cd ~/projects/my-service
ai-starter .
```
`.` means "this folder". Nothing of yours is overwritten: your `CLAUDE.md` gets 4 lines appended; your `.claude/settings.json` is merged (backup: `settings.json.bak` — this is where python is needed); your code is not touched.

### Where is `.claude` and why can't I see it?
It is **inside the project folder**. Names starting with a dot are hidden. In a terminal: `ls -a`. Linux file manager: `Ctrl+H`; macOS Finder: `Cmd+Shift+.`; Windows Explorer: View → Hidden items.
**You never need to put anything there by hand.** There is also a personal `~/.claude` in your home folder (global Claude Code settings) — leave it alone.

## Step 5. First run

1. In the project folder run `claude`.
2. Claude Code asks whether you **trust this folder** — answer **yes** (otherwise it skips part of the project settings).
3. Type `/kickoff`. Claude interviews you, one question at a time: what must exist at the end; why and for whom; **how to verify it is done** (it insists on specifics — "`./mvnw test` passes", not "a nice service"); non-goals; constraints. For existing code it surveys the project first and fills the map `ai/MAP.md`.
4. Read the draft `ai/GOAL.draft.md`, adjust it, and **freeze** it:
   ```bash
   mv ai/GOAL.draft.md ai/GOAL.md
   chmod a-w ai/GOAL.md        # makes the file read-only
   ```
5. First commit — Claude suggests the message.

## Step 6. Every day — one task at a time

| You do | What happens |
|---|---|
| `claude` | Claude reads the logbook and says: goal / where we are / next step |
| work on **one** task | taken from `ai/PLAN.md` |
| `/save` | Claude writes everything important down and suggests a commit message |
| `git add -A && git commit -m "…"` | **you** commit |
| `/clear` | the conversation is wiped — fine, everything is in the logbook |

**Why one task and `/clear`?** Every message you send is sent together with the *whole* conversation so far. Long conversations get more expensive with every step and eat your limit. Short sessions are cheap.

**Forgot `/save`?** After 40 minutes of unsaved work Claude stops and saves by itself. Session crashed? Next start it says "the previous session ended abruptly" and saves first.

## Commands

| Command | What it does | When |
|---|---|---|
| `/kickoff` | interview + plan | once, at the start |
| `/save` | write everything to the logbook | after each task and at the end |
| `/breakdown` | split a big chunk into small tasks | when a task is too big |
| `/check` | verify the done-criteria | when it feels finished |
| `/ingest ai/raw/file` | read a document, file the knowledge into the handbook | after adding an article, spec, notes |
| `/query question` | answer from the handbook | to recall what is already known |
| `/lint` | tidy up the handbook | weekly |
| `/drift` | "have we drifted off course?" | every few sessions |
| `/context` | how full the conversation memory is | any time |
| `/clear` | wipe the conversation | after `/save` |

## What is in the logbook (`ai/`)

| File | In plain words |
|---|---|
| `GOAL.md` | **What we build.** Only you edit it |
| `STATE.md` | **Where we stopped** and what is next |
| `PLAN.md` | **The plan:** big milestones and small tasks |
| `MAP.md` | **The map:** parts of the program or chapters of the book |
| `DECISIONS.md` | **Decision log:** what we chose and why — no re-arguing |
| `LOG.md` | **Diary:** 3–5 lines per session |
| `BACKLOG.md` | **"Later" box** — so you don't get distracted now |
| `wiki/` | **Handbook** of everything learned; `wiki/index.md` is its table of contents |
| `raw/` | **Sources** you brought in; Claude only reads them |
| `sessions/` | safety copies of conversations; not in git, safe to delete |
| `RULES.md` | rules for Claude in this project |

Every session Claude reads only **goal, state and plan** — short files. Everything else is opened on demand, and only the needed part. That is why the start costs about the same on a tiny and a huge project.

## For programmers
- `ai/MAP.md` lists modules and packages, not every file.
- Put build and test commands in the root `CLAUDE.md` below the ai-starter block (`/kickoff` offers to).
- "How to verify" = tests. A task is done when its test is green.
- Module-specific rules can live in a `CLAUDE.md` inside that module's folder — Claude reads it only when working there.
- Pitfalls like "this service returns dates without a time zone" belong in `ai/wiki/`.

## For a book
- Chapters in `book/` (`ch01.md` …), 1–3 lines per chapter in the map.
- `ai/wiki/` is the "book bible": characters, places, timeline, rules of the world. Claude opens the right handbook page instead of re-reading all chapters.

## What Claude may not do (verified)
- Change `ai/GOAL.md` — not with the editor, not with tricks like `mv`, `cp`, `echo >>`.
- Change sources in `ai/raw/`.
- Run `git add`, `commit`, `push`, `reset`, `checkout`.
Everything else is fine: write code, run tests, look at `git status` and `git diff`.

## Troubleshooting

| Problem | Fix |
|---|---|
| Claude "remembers" nothing at start | run `claude` in the project **root** and answer "yes" to the trust question |
| Hooks are silent | `chmod +x .claude/hooks/*.sh` |
| Claude Code complains about a line in `settings.json` | delete that line — it may have been renamed in a newer Claude Code |
| Asks for `/save` too often | raise `MINUTES=40` / `MAXFILES=15` in `.claude/hooks/stop-check.sh` |
| I want to change the goal | `chmod u+w ai/GOAL.md` → edit → `chmod a-w ai/GOAL.md` |
| New ai-starter version | `cd ~/tools/ai-starter && git pull`, then in the project `ai-starter . --update` (the logbook is untouched) |
| Claude reads lots of files in a row | stop it: "use MAP.md and search, don't read everything" |
| The conversation got slow | `/save` → commit → `/clear` |
