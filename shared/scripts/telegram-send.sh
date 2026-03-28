#!/bin/bash
# telegram-send.sh — Sendet Nachrichten an Andre via Telegram
#
# Nutzung:
#   telegram-send.sh "Nachricht"
#   telegram-send.sh "Nachricht" --silent    # Kein Sound/Vibration
#   echo "Mehrzeilig" | telegram-send.sh -   # Von stdin lesen
#
# Konfiguration:
#   ~/.secrets/nix_stack_bot.env mit:
#     TELEGRAM_BOT_TOKEN=123456:ABC...
#     TELEGRAM_CHAT_ID=123456789
#
# Der Bot-Token kommt von @BotFather in Telegram.
# Die Chat-ID bekommt man z.B. mit: curl https://api.telegram.org/bot$TOKEN/getUpdates

set -euo pipefail

# Secrets laden
SECRETS_FILE="$HOME/.secrets/nix_stack_bot.env"

if [[ ! -f "$SECRETS_FILE" ]]; then
  echo "FEHLER: $SECRETS_FILE nicht gefunden." >&2
  echo "" >&2
  echo "Erstelle die Datei mit:" >&2
  echo "  echo 'TELEGRAM_BOT_TOKEN=dein_token' > $SECRETS_FILE" >&2
  echo "  echo 'TELEGRAM_CHAT_ID=deine_chat_id' >> $SECRETS_FILE" >&2
  echo "  chmod 600 $SECRETS_FILE" >&2
  exit 1
fi

# shellcheck source=/dev/null
source "$SECRETS_FILE"

if [[ -z "${TELEGRAM_BOT_TOKEN:-}" || -z "${TELEGRAM_CHAT_ID:-}" ]]; then
  echo "FEHLER: TELEGRAM_BOT_TOKEN oder TELEGRAM_CHAT_ID nicht gesetzt in $SECRETS_FILE" >&2
  exit 1
fi

# Nachricht zusammenbauen
SILENT=false
MESSAGE=""

for arg in "$@"; do
  case "$arg" in
    --silent) SILENT=true ;;
    -)        MESSAGE=$(cat) ;;
    *)        MESSAGE="$arg" ;;
  esac
done

if [[ -z "$MESSAGE" ]]; then
  echo "Nutzung: telegram-send.sh \"Nachricht\"" >&2
  exit 1
fi

# Telegram API aufrufen
API_URL="https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage"

PAYLOAD=$(jq -n \
  --arg chat_id "$TELEGRAM_CHAT_ID" \
  --arg text "$MESSAGE" \
  --argjson disable_notification "$SILENT" \
  '{chat_id: $chat_id, text: $text, parse_mode: "Markdown", disable_notification: $disable_notification}')

RESPONSE=$(curl -s -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  --connect-timeout 10 \
  --max-time 15)

# Ergebnis pruefen
if echo "$RESPONSE" | jq -e '.ok' > /dev/null 2>&1; then
  exit 0
else
  ERROR=$(echo "$RESPONSE" | jq -r '.description // "Unbekannter Fehler"' 2>/dev/null || echo "$RESPONSE")
  echo "FEHLER: Telegram API: $ERROR" >&2
  exit 1
fi
