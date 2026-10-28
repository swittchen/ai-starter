# Changelog

## 1.0.0 — 2026-10-26
- First public version.
- Memory folder `ai/` with goal, state, plan, map, decision log, session log, backlog.
- Karpathy-style knowledge base (`ai/raw/` → `ai/wiki/`) with /ingest, /query, /lint.
- Hooks: session-start, goal-anchor, stop-check, backup-transcript.
- Skills: /kickoff, /save, /breakdown, /check, /drift.
- Installer for new and existing projects (merges CLAUDE.md, settings.json, .gitignore), `--lang en|ru`, `--update`.
- Smoke tests + GitHub Actions (Linux, macOS).
