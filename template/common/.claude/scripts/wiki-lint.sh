#!/usr/bin/env bash
# Mechanical check of ai/wiki/ without the model (0 tokens): pages missing from a catalog,
# broken links (incl. catalog entries without a file), pages longer than 300 lines.
root="${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
L=$(cat "$root/.claude/ai-starter-lang" 2>/dev/null || echo en)
if [ "$L" = ru ]; then
  T_NOWIKI="Нет папки ai/wiki/"; T_NOIDX="Нет в каталоге"; T_BROKEN="Битая ссылка в"; T_LONG="Длинная страница, стоит разбить"
  T_OK="wiki OK: страниц %s, механических проблем нет."; T_PAGES="Страниц: %s"; T_LINES="строк"
else
  T_NOWIKI="No ai/wiki/ folder"; T_NOIDX="Not in any index"; T_BROKEN="Broken link in"; T_LONG="Long page, consider splitting"
  T_OK="wiki OK: %s pages, no mechanical problems."; T_PAGES="Pages: %s"; T_LINES="lines"
fi
cd "$root/ai/wiki" || { echo "$T_NOWIKI"; exit 1; }
out=""
add() { out="$out$1"$'\n'; }

while IFS= read -r p; do
  b=$(basename "$p")
  grep -rqF --include=index.md "$b)" . || add "$T_NOIDX: $p"
done < <(find . -name '*.md' ! -name index.md ! -name log.md | sed 's|^\./||' | sort)

while IFS= read -r p; do
  d=$(dirname "$p")
  while IFS= read -r l; do
    t="${l%%#*}"
    [ -z "$t" ] && continue
    [ -f "$d/$t" ] || [ -f "$root/$t" ] || [ -f "$root/ai/$t" ] || add "$T_BROKEN $p → $l"
  done < <(sed 's/`[^`]*`//g' "$p" | grep -o '](\([^)]*\.md[^)]*\))' | sed 's/^](//;s/)$//' | grep -v '^https\?:')
done < <(find . -name '*.md' | sed 's|^\./||' | sort)

while read -r n p; do
  [ "$p" = "total" ] && continue
  [ "$n" -gt 300 ] && add "$T_LONG ($n $T_LINES): ${p#./}"
done < <(find . -name '*.md' ! -name log.md -exec wc -l {} +)

pages=$(find . -name '*.md' ! -name index.md ! -name log.md | wc -l | tr -d ' ')
if [ -z "$out" ]; then printf "$T_OK\n" "$pages"
else printf "$T_PAGES\n%s" "$pages" "$out"; fi
