#!/usr/bin/env bash
# PreCompact: copies the full transcript to ai/sessions/ before the context is compacted (not in git).
input=$(cat)
src=$(printf '%s' "$input" | sed -n 's/.*"transcript_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
[ -n "$src" ] && [ -f "$src" ] || exit 0
dir="${CLAUDE_PROJECT_DIR:-.}/ai/sessions"
mkdir -p "$dir"
cp "$src" "$dir/$(date +%Y-%m-%d_%H%M%S)-precompact.jsonl"
exit 0
