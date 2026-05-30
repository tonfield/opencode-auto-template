#!/bin/sh

EVENT="${1:-unknown}"
MESSAGE="${2:-OpenCode needs attention}"
PROJECT="${3:-}"

case "$EVENT" in
  complete)
    TITLE="✅ OpenCode Done"
    SOUND="bright"
    ;;
  permission|question)
    TITLE="⚠️ OpenCode Needs Input"
    SOUND="bugle"
    ;;
  error)
    TITLE="❌ OpenCode Error"
    SOUND="siren"
    ;;
  plan_exit)
    TITLE="📝 OpenCode Plan Ready"
    SOUND="bright"
    ;;
  *)
    TITLE="OpenCode"
    SOUND="pushover"
    ;;
esac

if [ -n "$PROJECT" ]; then
  TITLE="$TITLE — $PROJECT"
fi

find_pushover_notify() {
  if [ -n "${PUSHOVER_NOTIFY:-}" ] && command -v "$PUSHOVER_NOTIFY" >/dev/null 2>&1; then
    command -v "$PUSHOVER_NOTIFY"
    return 0
  fi

  if command -v pushover-notify >/dev/null 2>&1; then
    command -v pushover-notify
    return 0
  fi

  if [ -x "$HOME/bin/pushover-notify" ]; then
    printf '%s\n' "$HOME/bin/pushover-notify"
    return 0
  fi

  LEGACY_PUSHOVER_NOTIFY="${OPENCODE_PUSHOVER_LEGACY_PATH:-/Users/ton/bin/pushover-notify}"
  if [ -x "$LEGACY_PUSHOVER_NOTIFY" ]; then
    printf '%s\n' "$LEGACY_PUSHOVER_NOTIFY"
    return 0
  fi

  return 1
}

NOTIFIER="$(find_pushover_notify || true)"
if [ -z "$NOTIFIER" ]; then
  exit 0
fi

exec "$NOTIFIER" "$TITLE" "$MESSAGE" "$SOUND"
