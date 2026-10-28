#!/usr/bin/env bash
# Stop: if work has been unsaved for MINUTES (or MAXFILES files changed), Claude may not finish without /save.
# Costs nothing until it fires. Change the thresholds here.
MINUTES=40
MAXFILES=15
input=$(cat)
printf '%s' "$input" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0
. "$(dirname "$0")/lib.sh"
[ -f "$STATE" ] || exit 0
goal_is_template && exit 0

marker=.claude/.dirty-since
n=$(count_unsaved)
if [ "$n" -eq 0 ]; then rm -f "$marker"; exit 0; fi
[ -f "$marker" ] || touch "$marker"

if [ "$n" -ge "$MAXFILES" ] || [ -n "$(find "$marker" -mmin +"$MINUTES" 2>/dev/null)" ]; then
  printf "$M_STOP\n" "$n" >&2
  exit 2
fi
exit 0
