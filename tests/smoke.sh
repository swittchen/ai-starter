#!/usr/bin/env bash
# Smoke test: installs ai-starter into temp projects (en + ru) and exercises every hook.
# No Claude Code and no tokens needed. Run: bash tests/smoke.sh
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
fails=0
ok()   { echo "  ok   $1"; }
fail() { echo "  FAIL $1"; fails=$((fails+1)); }
check() { if eval "$2"; then ok "$1"; else fail "$1"; fi; }
gitc() { git -c user.email=t@t -c user.name=t "$@"; }

for L in en ru; do
  echo "== language: $L"
  P="$TMP/new-$L"; export CLAUDE_PROJECT_DIR="$P"
  bash "$ROOT/install.sh" "$P" --lang "$L" >/dev/null
  check "files installed" '[ -f "$P/ai/GOAL.md" ] && [ -f "$P/.claude/settings.json" ] && [ -f "$P/.claude/skills/save/SKILL.md" ]'
  check "language stored" '[ "$(cat "$P/.claude/ai-starter-lang")" = "$L" ]'
  ( cd "$P" && git init -q && gitc add -A && gitc commit -qm init )
  H="$P/.claude/hooks"

  out=$(echo '{"source":"startup"}' | bash "$H/session-start.sh")
  check "template goal → points to /kickoff" 'echo "$out" | grep -q "/kickoff"'
  check "anchor silent while goal unset" '[ -z "$(echo "{}" | bash "$H/goal-anchor.sh")" ]'

  if [ "$L" = ru ]; then hg="Цель одной фразой"; hm="Текущая веха"; ht="Текущая задача"
  else hg="Goal in one sentence"; hm="Current milestone"; ht="Current task"; fi
  printf '# G\n\n## %s\nTest goal X\n' "$hg" > "$P/ai/GOAL.md"
  printf '# S\n\n## %s\nM1 — first (K1)\n\n## %s\nT1 — do it\n' "$hm" "$ht" > "$P/ai/STATE.md"
  ( cd "$P" && gitc add -A && gitc commit -qm goal )

  a=$(echo '{}' | bash "$H/goal-anchor.sh")
  check "anchor shows goal, milestone, task" 'echo "$a" | grep -q "Test goal X" && echo "$a" | grep -q "M1 — first" && echo "$a" | grep -q "T1 — do it"'

  echo '{}' | bash "$H/stop-check.sh" 2>/dev/null; check "stop: nothing unsaved → allowed" '[ $? -eq 0 ]'
  sleep 1; echo x > "$P/work.txt"
  echo '{}' | bash "$H/stop-check.sh" 2>/dev/null; r=$?
  check "stop: fresh change → allowed, marker set" '[ $r -eq 0 ] && [ -f "$P/.claude/.dirty-since" ]'
  touch -d '-50 minutes' "$P/.claude/.dirty-since" 2>/dev/null || touch -t "$(date -v-50M +%Y%m%d%H%M 2>/dev/null)" "$P/.claude/.dirty-since"
  echo '{}' | bash "$H/stop-check.sh" 2>/dev/null; r=$?
  check "stop: unsaved 50 min → blocked (exit 2)" '[ $r -eq 2 ]'
  echo '{"stop_hook_active": true}' | bash "$H/stop-check.sh" 2>/dev/null; r=$?
  check "stop: no endless loop" '[ $r -eq 0 ]'
  out=$(echo '{"source":"startup"}' | bash "$H/session-start.sh")
  check "start: detects interrupted session" 'echo "$out" | grep -q "/save"'
  sleep 1; touch "$P/ai/STATE.md"
  echo '{}' | bash "$H/stop-check.sh" 2>/dev/null; r=$?
  check "after /save → allowed, marker cleared" '[ $r -eq 0 ] && [ ! -f "$P/.claude/.dirty-since" ]'
  out=$(echo '{"source":"compact"}' | bash "$H/session-start.sh")
  check "start after compaction → asks for /save" 'echo "$out" | grep -q "/save"'

  tr="$TMP/t-$L.jsonl"; echo '{}' > "$tr"
  echo "{\"transcript_path\":\"$tr\"}" | bash "$H/backup-transcript.sh"
  check "transcript backed up before compaction" '[ -n "$(ls "$P/ai/sessions/" 2>/dev/null)" ]'
  check "wiki-lint clean on template" 'bash "$P/.claude/scripts/wiki-lint.sh" | grep -q "OK"'
  check "ai/sessions is git-ignored" '( cd "$P" && git check-ignore -q ai/sessions/x )'
done

echo "== existing project with its own CLAUDE.md and settings.json"
P="$TMP/existing"; mkdir -p "$P/.claude"; export CLAUDE_PROJECT_DIR="$P"
printf '# Mine\n' > "$P/CLAUDE.md"
printf '{"permissions":{"deny":["Read(./.env)"]},"hooks":{"Stop":[{"hooks":[{"type":"command","command":"echo mine"}]}]}}\n' > "$P/.claude/settings.json"
bash "$ROOT/install.sh" "$P" >/dev/null; bash "$ROOT/install.sh" "$P" >/dev/null
check "own CLAUDE.md kept + block appended once" 'grep -q "^# Mine" "$P/CLAUDE.md" && [ "$(grep -c "ai-starter: begin" "$P/CLAUDE.md")" -eq 1 ]'
check "own settings kept" 'grep -q "Read(./.env)" "$P/.claude/settings.json" && grep -q "echo mine" "$P/.claude/settings.json"'
check "hooks merged once (idempotent)" '[ "$(grep -c "stop-check.sh" "$P/.claude/settings.json")" -eq 1 ]'
check "settings still valid JSON" 'python3 -m json.tool "$P/.claude/settings.json" >/dev/null 2>&1 || python -m json.tool "$P/.claude/settings.json" >/dev/null'

echo "== install through a symlink (alias-style use)"
ln -s "$ROOT/install.sh" "$TMP/ai-starter"
check "symlinked installer works" 'bash "$TMP/ai-starter" "$TMP/via-link" >/dev/null && [ -f "$TMP/via-link/ai/RULES.md" ]'

echo
if [ "$fails" -eq 0 ]; then echo "ALL TESTS PASSED"; else echo "$fails TEST(S) FAILED"; exit 1; fi
