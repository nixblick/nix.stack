#!/bin/bash
# nix.stack Notification-Hook (Notification-Event)
# Sendet Desktop-Benachrichtigung wenn Claude Code auf Eingabe wartet.
#
# Funktioniert mit:
# - notify-send (Linux/GNOME/KDE)
# - osascript (macOS)
#
# Einrichten in ~/.claude/settings.json:
# "Notification": [{ "matcher": "", "hooks": [{ "type": "command", "command": "~/.claude/hooks/notification.sh" }] }]

# Linux (notify-send)
if command -v notify-send &>/dev/null; then
  notify-send -u normal -t 5000 'Claude Code' 'Claude Code wartet auf deine Eingabe'
  exit 0
fi

# macOS (osascript)
if command -v osascript &>/dev/null; then
  osascript -e 'display notification "Claude Code wartet auf deine Eingabe" with title "Claude Code"'
  exit 0
fi

# Kein Notification-System gefunden — still ignorieren
exit 0
