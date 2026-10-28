#!/usr/bin/env bash
# UserPromptSubmit: adds one line (goal / milestone / task, ~30 tokens) to every user message.
cat >/dev/null
. "$(dirname "$0")/lib.sh"
goal_is_template && exit 0
printf "$M_ANCHOR\n" "$(section "$GOAL" "$H_GOAL")" "$(section "$STATE" "$H_MS")" "$(section "$STATE" "$H_TASK")"
exit 0
