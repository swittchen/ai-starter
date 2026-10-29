# Changelog

## 1.1.0 — 2026-10-29
- Renamed from `ai-starter` to **claude-project-memory**; the shell alias is now `project-memory`.
- Projects installed under the old name keep working and are migrated on `--update` (language file, CLAUDE.md block and GOAL marker are recognised).
- README: demo GIF, badges, "Why not just CLAUDE.md or auto-memory?".
- 3 new smoke checks for upgrading old installs (38 in total).

## 1.0.0 — 2026-10-26
- First public version.
- Memory folder `ai/` with goal, state, plan, map, decision log, session log, backlog.
- Karpathy-style knowledge base (`ai/raw/` → `ai/wiki/`) with /ingest, /query, /lint.
- Hooks: session-start, goal-anchor, stop-check, backup-transcript.
- Skills: /kickoff, /save, /breakdown, /check, /drift.
- Installer for new and existing projects (merges CLAUDE.md, settings.json, .gitignore), `--lang en|ru`, `--update`.
- Smoke tests + GitHub Actions (Linux, macOS).
