#!/bin/bash
# nix.stack Online-Setup
# Fuer Maschinen mit Internet und Git-Zugriff
#
# Installiert:
# - Schutz-Hook (PreToolUse) in ~/.claude/hooks/
# - Notification-Hook in ~/.claude/hooks/
# - Alle Skills als Symlinks nach ~/.claude/skills/ (eine Quelle der Wahrheit)
# - Registriert Hooks in ~/.claude/settings.json
# - Rules fuer Session-Kontext
# - Optional: tmux.conf nach ~/.tmux.conf symlinken

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SKILLS_DIR="$CLAUDE_DIR/skills"

echo "=== nix.stack Online-Setup ==="
echo ""

# 1. Hooks-Verzeichnis erstellen
mkdir -p "$HOOKS_DIR"

# 2. Hooks kopieren
cp "$SCRIPT_DIR/hooks/schutz.sh" "$HOOKS_DIR/schutz.sh"
cp "$SCRIPT_DIR/hooks/pre-commit-check.sh" "$HOOKS_DIR/pre-commit-check.sh"
cp "$REPO_DIR/shared/hooks/notification.sh" "$HOOKS_DIR/notification.sh"
chmod +x "$HOOKS_DIR/schutz.sh" "$HOOKS_DIR/pre-commit-check.sh" "$HOOKS_DIR/notification.sh"
echo "[OK] Schutz-Hook installiert: $HOOKS_DIR/schutz.sh"
echo "[OK] Pre-Commit-Check installiert: $HOOKS_DIR/pre-commit-check.sh"
echo "[OK] Notification-Hook installiert: $HOOKS_DIR/notification.sh"

# 3. Skills als Symlinks installieren (eine Quelle der Wahrheit)
for skill_dir in "$SCRIPT_DIR"/skills/*/; do
  skill_name=$(basename "$skill_dir")
  target="$SKILLS_DIR/$skill_name"
  # Alte Kopie oder kaputten Symlink entfernen
  if [[ -d "$target" && ! -L "$target" ]]; then
    rm -rf "$target"
    echo "[UPGRADE] Alte Kopie entfernt: $skill_name"
  elif [[ -L "$target" ]]; then
    rm "$target"
  fi
  ln -sf "$skill_dir" "$target"
  echo "[OK] Skill /$skill_name -> $(readlink -f "$target")"
done

# 4. Projekt-Kontext als Symlink (zentrale Projekt-Map fuer alle Assistenten)
CONTEXT_SRC="$REPO_DIR/context"
CONTEXT_DST="$CLAUDE_DIR/context"
if [[ -d "$CONTEXT_SRC" ]]; then
  if [[ -L "$CONTEXT_DST" ]]; then
    rm "$CONTEXT_DST"
  elif [[ -d "$CONTEXT_DST" ]]; then
    rm -rf "$CONTEXT_DST"
    echo "[UPGRADE] Alte Kontext-Kopie entfernt"
  fi
  ln -sf "$CONTEXT_SRC" "$CONTEXT_DST"
  echo "[OK] Kontext -> $CONTEXT_SRC"
fi

# 5. Hook in settings.json registrieren (falls noch nicht vorhanden)
SETTINGS="$CLAUDE_DIR/settings.json"
if [[ -f "$SETTINGS" ]]; then
  if grep -q "schutz.sh" "$SETTINGS"; then
    echo "[OK] Schutz-Hook bereits in settings.json registriert"
  else
    echo ""
    echo "[INFO] Schutz-Hook muss manuell in $SETTINGS eingetragen werden."
    echo "       Fuege diesen Block unter 'hooks' ein:"
    echo ""
    cat "$SCRIPT_DIR/settings-snippet.json"
    echo ""
    echo "       Oder kopiere die Datei settings-snippet.json als Referenz."
  fi
else
  echo "[INFO] $SETTINGS existiert nicht. Erstelle Basis-Konfiguration..."
  cat > "$SETTINGS" << 'SETTINGS_EOF'
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "HOOKS_DIR_PLACEHOLDER/schutz.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
SETTINGS_EOF
  sed -i "s|HOOKS_DIR_PLACEHOLDER|$HOOKS_DIR|g" "$SETTINGS"
  echo "[OK] settings.json erstellt mit Schutz-Hook"
fi

# 6. Telegram-Script als Symlink (Assistenten nutzen es zum Senden)
TELEGRAM_SRC="$REPO_DIR/shared/scripts/telegram-send.sh"
TELEGRAM_DST="$HOME/.local/bin/telegram-send"
if [[ -f "$TELEGRAM_SRC" ]]; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$TELEGRAM_SRC" "$TELEGRAM_DST"
  RECEIVE_SRC="$REPO_DIR/shared/scripts/telegram-receive.sh"
  RECEIVE_DST="$HOME/.local/bin/telegram-receive"
  ln -sf "$RECEIVE_SRC" "$RECEIVE_DST"
  echo "[OK] telegram-send -> $TELEGRAM_SRC"
  echo "[OK] telegram-receive -> $RECEIVE_SRC"
  if [[ -f "$HOME/.secrets/nix_stack_bot.env" ]]; then
    echo "[OK] Telegram-Secrets vorhanden"
  else
    echo ""
    echo "[TODO] Telegram-Bot einrichten:"
    echo "       1. Neuen Bot bei @BotFather erstellen"
    echo "       2. Bot-Token und Chat-ID eintragen:"
    echo "          echo 'TELEGRAM_BOT_TOKEN=dein_token' > ~/.secrets/nix_stack_bot.env"
    echo "          echo 'TELEGRAM_CHAT_ID=deine_chat_id' >> ~/.secrets/nix_stack_bot.env"
    echo "          chmod 600 ~/.secrets/nix_stack_bot.env"
    echo ""
  fi
fi

# 7. Hinweis auf Rules
echo ""
echo "[INFO] Optional: Rules fuer Session-Kontext kopieren:"
echo "       cp $SCRIPT_DIR/rules/arbeitsumgebung.md <projekt>/.claude/rules/"
echo ""

# 8. tmux.conf (optional)
TMUX_SRC="$REPO_DIR/shared/tmux.conf"
TMUX_DST="$HOME/.tmux.conf"
if [[ -f "$TMUX_SRC" ]]; then
  if [[ -L "$TMUX_DST" && "$(readlink -f "$TMUX_DST")" == "$(readlink -f "$TMUX_SRC")" ]]; then
    echo "[OK] tmux.conf bereits verlinkt"
  elif [[ -f "$TMUX_DST" ]]; then
    echo ""
    echo "[FRAGE] ~/.tmux.conf existiert bereits."
    read -rp "         Ueberschreiben mit Symlink auf nix.stack? [j/N] " answer
    if [[ "$answer" =~ ^[jJyY]$ ]]; then
      mv "$TMUX_DST" "${TMUX_DST}.backup"
      ln -sf "$TMUX_SRC" "$TMUX_DST"
      echo "[OK] tmux.conf verlinkt (Backup: ${TMUX_DST}.backup)"
    else
      echo "[OK] tmux.conf nicht veraendert"
    fi
  else
    ln -sf "$TMUX_SRC" "$TMUX_DST"
    echo "[OK] tmux.conf verlinkt: $TMUX_DST -> $TMUX_SRC"
  fi
fi

# 9. Test
echo "=== Schutz-Hook Test ==="
echo '{"tool_input":{"command":"rm -rf /home/test/GitHub"}}' | "$HOOKS_DIR/schutz.sh" 2>&1 && echo "[FEHLER] Hook hat nicht blockiert!" || echo "[OK] Destruktiver Befehl blockiert (Exit $?)"
echo '{"tool_input":{"command":"ls -la"}}' | "$HOOKS_DIR/schutz.sh" 2>&1 && echo "[OK] Sicherer Befehl erlaubt" || echo "[FEHLER] Sicherer Befehl blockiert!"

echo ""
echo "=== Setup abgeschlossen ==="
echo "Starte Claude Code neu damit die Hooks greifen."
