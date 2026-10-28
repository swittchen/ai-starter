#!/usr/bin/env bash
# ai-starter: shared helpers for all hooks / общие функции хуков.
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
STATE=ai/STATE.md
GOAL=ai/GOAL.md
AI_LANG=$(cat .claude/ai-starter-lang 2>/dev/null || echo en)

if [ "$AI_LANG" = "ru" ]; then
  H_GOAL="Цель одной фразой"; H_MS="Текущая веха"; H_TASK="Текущая задача"
  M_UNSET="Статус проекта: цель ещё не задана, ai/GOAL.md — шаблон. Первая задача — /kickoff."
  M_COMPACT="Произошло сжатие контекста. ai/STATE.md мог отстать от разговора; первое действие — /save."
  M_UNSAVED="После последнего /save изменено файлов: %s — прошлая сессия, вероятно, оборвалась. Сначала /save."
  M_LOG="--- Хвост ai/LOG.md ---"
  M_COMMITS="--- Последние коммиты ---"
  M_UNCOMMITTED="Незакоммичено файлов: %s (коммит делает человек; при /save предложи сообщение)."
  M_ANCHOR="Ориентир — цель: %s | веха: %s | задача: %s"
  M_STOP="ai/STATE.md отстаёт от работы: %s изменённых файлов не отражены в нём. Выполни /save, затем заканчивай."
else
  H_GOAL="Goal in one sentence"; H_MS="Current milestone"; H_TASK="Current task"
  M_UNSET="Project status: no goal yet, ai/GOAL.md is still the template. First task: /kickoff."
  M_COMPACT="The context was just compacted. ai/STATE.md may lag behind the conversation; first action: /save."
  M_UNSAVED="Files changed since the last /save: %s. The previous session probably ended abruptly. Run /save first."
  M_LOG="--- Tail of ai/LOG.md ---"
  M_COMMITS="--- Latest commits ---"
  M_UNCOMMITTED="Uncommitted files: %s (the human commits; suggest a commit message at /save)."
  M_ANCHOR="Anchor: goal: %s | milestone: %s | task: %s"
  M_STOP="ai/STATE.md lags behind the work: %s changed files are not reflected in it. Run /save, then finish."
fi

# The template GOAL.md carries this marker; the real goal written by /kickoff does not.
goal_is_template() { grep -q 'ai-starter:unset' "$GOAL" 2>/dev/null; }

# First non-empty line under a "## heading" in a file.
section() { awk -v h="## $2" '$0==h{f=1;next} f&&/^## /{exit} f&&NF{print;exit}' "$1" 2>/dev/null; }

# How many project files changed after the last /save (= newer than ai/STATE.md).
# In git repos: modified + untracked files from git (respects .gitignore, so builds/deps don't count).
# Without git: find, skipping heavy folders. Logs are not counted.
count_unsaved() {
  [ -f "$STATE" ] || { echo 0; return; }
  local n=0 f
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    while IFS= read -r -d '' f; do
      case "$f" in "$STATE"|ai/LOG.md|ai/wiki/log.md|ai/sessions/*|.claude/.dirty-since) continue;; esac
      [ "$f" -nt "$STATE" ] && n=$((n+1))
    done < <(git ls-files -z -m -o --exclude-standard 2>/dev/null)
  else
    n=$(find . \( -name .git -o -name node_modules -o -name target -o -name build -o -name dist \
        -o -name .idea -o -name .gradle -o -path ./ai/sessions \) -prune -o -type f -newer "$STATE" \
        ! -path ./ai/LOG.md ! -path ./ai/wiki/log.md ! -path ./.claude/.dirty-since -print 2>/dev/null | wc -l | tr -d ' ')
  fi
  echo "$n"
}
