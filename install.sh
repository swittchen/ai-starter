#!/usr/bin/env bash
# ai-starter installer — adds persistent project memory for Claude Code to a new or existing project.
#
#   bash install.sh <project-folder> [--lang en|ru] [--update]
#
#   --lang en|ru  language of the template files and messages (default: en; on --update: keep current)
#   --update      update hooks and skills to this version (your ai/ memory is never touched)
set -euo pipefail

# Resolve the real location even when called through a symlink or alias
self="$0"
while [ -L "$self" ]; do
  link=$(readlink "$self"); case "$link" in /*) self="$link";; *) self="$(dirname "$self")/$link";; esac
done
HERE="$(cd "$(dirname "$self")" && pwd)"
TPL="$HERE/template"

DST=""; LANG_OPT=""; MODE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --lang) LANG_OPT="${2:-}"; shift 2;;
    --lang=*) LANG_OPT="${1#--lang=}"; shift;;
    --update) MODE="--update"; shift;;
    -h|--help) sed -n '2,7p' "$self"; exit 0;;
    *) DST="$1"; shift;;
  esac
done
[ -n "$DST" ] || { sed -n '2,7p' "$self"; exit 1; }
mkdir -p "$DST"; DST="$(cd "$DST" && pwd)"

# Language: explicit flag > already installed > en
L="${LANG_OPT:-$(cat "$DST/.claude/ai-starter-lang" 2>/dev/null || echo en)}"
case "$L" in en|ru) ;; *) echo "Unknown language: $L (use en or ru)"; exit 1;; esac
SRC="$TPL/$L"; COM="$TPL/common"

if [ "$L" = ru ]; then
  T_HEAD="ai-starter → %s (язык: ru)"; T_AI_KEEP="ai/ уже есть — не трогаю"; T_AI_NEW="создана ai/ (цель, состояние, план, база знаний)"
  T_HOOKS="хуки и скрипты: .claude/hooks/, .claude/scripts/"; T_SK_UPD="навык /%s обновлён"
  T_SK_KEEP="навык /%s уже есть и отличается — оставил твой (обновить: --update)"; T_SK="навыки: .claude/skills/"
  T_SET_NEW="создан .claude/settings.json"; T_SET_MERGE="объединил с твоим .claude/settings.json (копия: settings.json.bak)"
  T_SET_MANUAL="ВНИМАНИЕ: нет python — объедини вручную .claude/settings.ai-starter.json с .claude/settings.json"
  T_CL_NEW="создан CLAUDE.md"; T_CL_OK="CLAUDE.md уже подключён"; T_CL_ADD="в твой CLAUDE.md дописан блок ai-starter (в конце)"
  T_GI=".gitignore дополнен"; T_DONE="Готово. Дальше:"; T_NEXT="затем набери  /kickoff"
else
  T_HEAD="ai-starter → %s (language: en)"; T_AI_KEEP="ai/ already exists — left untouched"; T_AI_NEW="created ai/ (goal, state, plan, knowledge base)"
  T_HOOKS="hooks and scripts: .claude/hooks/, .claude/scripts/"; T_SK_UPD="skill /%s updated"
  T_SK_KEEP="skill /%s exists and differs — kept yours (to update: --update)"; T_SK="skills: .claude/skills/"
  T_SET_NEW="created .claude/settings.json"; T_SET_MERGE="merged into your .claude/settings.json (backup: settings.json.bak)"
  T_SET_MANUAL="WARNING: no python — merge .claude/settings.ai-starter.json into .claude/settings.json by hand"
  T_CL_NEW="created CLAUDE.md"; T_CL_OK="CLAUDE.md already wired up"; T_CL_ADD="appended the ai-starter block to your CLAUDE.md"
  T_GI=".gitignore updated"; T_DONE="Done. Next:"; T_NEXT="then type  /kickoff"
fi
say() { printf "  • $1\n" "${2:-}"; }
printf "$T_HEAD\n" "$DST"

# 1. Memory folder ai/ — never overwritten
if [ -d "$DST/ai" ]; then say "$T_AI_KEEP"
else cp -R "$SRC/ai" "$DST/ai"; mkdir -p "$DST/ai/sessions"; say "$T_AI_NEW"; fi

# 2. Hooks and scripts — owned by ai-starter, always refreshed
mkdir -p "$DST/.claude/hooks" "$DST/.claude/scripts" "$DST/.claude/skills"
cp "$COM/.claude/hooks/"*.sh "$DST/.claude/hooks/"
cp "$COM/.claude/scripts/"*.sh "$DST/.claude/scripts/"
chmod +x "$DST/.claude/hooks/"*.sh "$DST/.claude/scripts/"*.sh
echo "$L" > "$DST/.claude/ai-starter-lang"
say "$T_HOOKS"

# 3. Skills (/save, /kickoff …): yours are kept unless --update
for s in "$SRC/.claude/skills/"*/; do
  n=$(basename "$s"); t="$DST/.claude/skills/$n"
  if [ ! -e "$t" ]; then cp -R "$s" "$t"
  elif ! cmp -s "$s/SKILL.md" "$t/SKILL.md"; then
    if [ "$MODE" = "--update" ]; then cp "$s/SKILL.md" "$t/SKILL.md"; say "$T_SK_UPD" "$n"
    else say "$T_SK_KEEP" "$n"; fi
  fi
done
say "$T_SK"

# 4. Settings: create, or merge carefully into the existing file
PY=$(command -v python3 || command -v python || true)
if [ ! -f "$DST/.claude/settings.json" ]; then
  cp "$COM/.claude/settings.json" "$DST/.claude/settings.json"; say "$T_SET_NEW"
elif [ -n "$PY" ]; then
  cp "$DST/.claude/settings.json" "$DST/.claude/settings.json.bak"
  "$PY" - "$COM/.claude/settings.json" "$DST/.claude/settings.json" <<'PYEOF'
import io, json, sys
src = json.load(io.open(sys.argv[1], encoding="utf-8"))
dst = json.load(io.open(sys.argv[2], encoding="utf-8"))
for k in ("autoMemoryEnabled", "autoCompactWindow"):
    dst.setdefault(k, src[k])
deny = dst.setdefault("permissions", {}).setdefault("deny", [])
for r in src["permissions"]["deny"]:
    if r not in deny:
        deny.append(r)
hooks = dst.setdefault("hooks", {})
for ev, groups in src["hooks"].items():
    have = set(h.get("command") for grp in hooks.get(ev, []) for h in grp.get("hooks", []))
    for g in groups:
        if g["hooks"][0]["command"] not in have:
            hooks.setdefault(ev, []).append(g)
with io.open(sys.argv[2], "w", encoding="utf-8") as f:
    f.write(json.dumps(dst, ensure_ascii=False, indent=2) + "\n")
PYEOF
  say "$T_SET_MERGE"
else
  cp "$COM/.claude/settings.json" "$DST/.claude/settings.ai-starter.json"; say "$T_SET_MANUAL"
fi

# 5. Root CLAUDE.md: create, or append the import block
if [ ! -f "$DST/CLAUDE.md" ]; then
  cp "$SRC/CLAUDE.md" "$DST/CLAUDE.md"; say "$T_CL_NEW"
elif grep -q 'ai-starter: begin' "$DST/CLAUDE.md"; then
  say "$T_CL_OK"
else
  { echo; sed -n '/ai-starter: begin/,/ai-starter: end/p' "$SRC/CLAUDE.md"; } >> "$DST/CLAUDE.md"; say "$T_CL_ADD"
fi

# 6. .gitignore
touch "$DST/.gitignore"
while IFS= read -r l; do grep -qxF "$l" "$DST/.gitignore" || echo "$l" >> "$DST/.gitignore"; done < "$COM/gitignore.append"
say "$T_GI"

echo; echo "$T_DONE"
[ -d "$DST/.git" ] || echo "  cd \"$DST\" && git init"
echo "  cd \"$DST\" && claude      → $T_NEXT"
