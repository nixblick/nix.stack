#!/bin/bash
# telegram-receive.sh — Liest Nachrichten aus der Telegram-Inbox
#
# Die Inbox wird vom CoachNixBot gefuellt (todomanager/coach/bot.py).
# Nachrichten haben ein "target" Feld: coach, dave, einstein, bodo, casi
#
# Nutzung:
#   telegram-receive                     # Alle Nachrichten
#   telegram-receive --for dave          # Nur Nachrichten an Dave
#   telegram-receive --for einstein      # Nur Nachrichten an Einstein
#   telegram-receive --since 1h          # Nachrichten der letzten Stunde
#   telegram-receive --for dave --since 2h  # Kombination
#   telegram-receive --last 5            # Letzte 5 Nachrichten
#   telegram-receive --clear             # Inbox leeren
#   telegram-receive --clear dave        # Nur Daves Nachrichten loeschen
#
# Format: {"time":"...","target":"dave","text":"Nachricht"}

set -euo pipefail

INBOX_FILE="$HOME/.claude/telegram_inbox.jsonl"

if [[ ! -f "$INBOX_FILE" ]]; then
  echo "Keine Nachrichten."
  exit 0
fi

# Argumente parsen
TARGET=""
SINCE=""
LAST=""
CLEAR=false
CLEAR_TARGET=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --for)    TARGET="$2"; shift 2 ;;
    --since)  SINCE="$2"; shift 2 ;;
    --last)   LAST="$2"; shift 2 ;;
    --clear)
      CLEAR=true
      if [[ "${2:-}" != "" && "${2:-}" != --* ]]; then
        CLEAR_TARGET="$2"; shift 2
      else
        shift 1
      fi
      ;;
    *)        shift ;;
  esac
done

# Clear-Modus
if $CLEAR; then
  if [[ -n "$CLEAR_TARGET" ]]; then
    # Nur Nachrichten eines bestimmten Targets loeschen
    BEFORE=$(wc -l < "$INBOX_FILE")
    jq -c "select(.target != \"$CLEAR_TARGET\")" "$INBOX_FILE" > "${INBOX_FILE}.tmp" 2>/dev/null || true
    mv "${INBOX_FILE}.tmp" "$INBOX_FILE"
    AFTER=$(wc -l < "$INBOX_FILE")
    echo "$((BEFORE - AFTER)) Nachrichten fuer $CLEAR_TARGET geloescht."
  else
    LINES=$(wc -l < "$INBOX_FILE")
    : > "$INBOX_FILE"
    echo "$LINES Nachrichten geloescht."
  fi
  exit 0
fi

# Filter bauen
FILTER="."
if [[ -n "$TARGET" ]]; then
  FILTER="select(.target == \"$TARGET\")"
fi
if [[ -n "$SINCE" ]]; then
  SINCE_TS=$(date -d "-${SINCE}" +%Y-%m-%dT%H:%M:%S 2>/dev/null || date -v-"${SINCE}" +%Y-%m-%dT%H:%M:%S 2>/dev/null)
  if [[ -n "$SINCE_TS" ]]; then
    FILTER="${FILTER} | select(.time >= \"$SINCE_TS\")"
  fi
fi

# Ausgabe
if [[ -n "$LAST" ]]; then
  tail -n "$LAST" "$INBOX_FILE" | jq -r "$FILTER | \"[\(.target // \"coach\")] \(.text)\"" 2>/dev/null
else
  if [[ -s "$INBOX_FILE" ]]; then
    jq -r "$FILTER | \"[\(.target // \"coach\")] \(.text)\"" "$INBOX_FILE" 2>/dev/null
  else
    echo "Keine Nachrichten."
  fi
fi
