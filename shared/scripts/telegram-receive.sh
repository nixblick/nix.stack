#!/bin/bash
# telegram-receive.sh — Liest Nachrichten aus der Telegram-Inbox
#
# Die Inbox wird vom CoachNixBot gefuellt (todomanager/coach/bot.py).
# Jede Nachricht die Andre an den Bot schickt, landet als JSONL-Zeile.
#
# Nutzung:
#   telegram-receive.sh              # Alle ungelesenen Nachrichten
#   telegram-receive.sh --since 1h   # Nachrichten der letzten Stunde
#   telegram-receive.sh --last 5     # Letzte 5 Nachrichten
#   telegram-receive.sh --clear      # Inbox leeren (nach dem Lesen)
#
# Format pro Zeile: {"time":"2026-03-28T20:15:00","text":"Nachricht von Andre"}

set -euo pipefail

INBOX_FILE="$HOME/.claude/telegram_inbox.jsonl"

if [[ ! -f "$INBOX_FILE" ]]; then
  echo "Keine Nachrichten (Inbox existiert nicht)."
  exit 0
fi

MODE="${1:---all}"

case "$MODE" in
  --since)
    # Nachrichten seit X (z.B. 1h, 30m, 2d)
    DURATION="${2:-1h}"
    SINCE=$(date -d "-${DURATION}" +%Y-%m-%dT%H:%M:%S 2>/dev/null || date -v-"${DURATION}" +%Y-%m-%dT%H:%M:%S 2>/dev/null)
    if [[ -n "$SINCE" ]]; then
      jq -r "select(.time >= \"$SINCE\") | \"[\(.time)] \(.text)\"" "$INBOX_FILE" 2>/dev/null
    else
      echo "Fehler: Ungueltige Dauer '$DURATION'" >&2
      exit 1
    fi
    ;;
  --last)
    COUNT="${2:-5}"
    tail -n "$COUNT" "$INBOX_FILE" | jq -r '"[\(.time)] \(.text)"' 2>/dev/null
    ;;
  --clear)
    LINES=$(wc -l < "$INBOX_FILE")
    : > "$INBOX_FILE"
    echo "$LINES Nachrichten geloescht."
    ;;
  --all|*)
    if [[ -s "$INBOX_FILE" ]]; then
      jq -r '"[\(.time)] \(.text)"' "$INBOX_FILE" 2>/dev/null
    else
      echo "Keine Nachrichten."
    fi
    ;;
esac
