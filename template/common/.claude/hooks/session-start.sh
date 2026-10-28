#!/usr/bin/env bash
# SessionStart: short briefing (~20 lines max). Cost does not grow with the project.
input=$(cat)
. "$(dirname "$0")/lib.sh"
source=$(printf '%s' "$input" | sed -n 's/.*"source"[[:space:]]*:[[:space:]]*"\([a-z]*\)".*/\1/p' | head -1)

if goal_is_template; then echo "$M_UNSET"; exit 0; fi
[ "$source" = "compact" ] && echo "$M_COMPACT"

n=$(count_unsaved)
[ "$n" -gt 0 ] && printf "$M_UNSAVED\n" "$n"

if [ -f ai/LOG.md ]; then echo "$M_LOG"; tail -n 10 ai/LOG.md; fi

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "$M_COMMITS"
  git log --oneline -3 2>/dev/null
  c=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  [ "$c" -gt 0 ] && printf "$M_UNCOMMITTED\n" "$c"
fi
exit 0
