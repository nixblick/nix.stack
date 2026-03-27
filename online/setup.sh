#!/bin/bash
# nix.stack Online-Setup
# Fuer Maschinen mit Internet und Git-Zugriff
#
# Installiert:
# - Schutz-Hook (PreToolUse) in ~/.claude/hooks/
# - Notification-Hook in ~/.claude/hooks/
# - Web-Kritiker Skill
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

# 3. Web-Kritiker Skill installieren
mkdir -p "$SKILLS_DIR/kritiker-web"
cp "$SCRIPT_DIR/skills/kritiker-web/SKILL.md" "$SKILLS_DIR/kritiker-web/SKILL.md"
echo "[OK] Skill /kritiker-web installiert: $SKILLS_DIR/kritiker-web/"

# 4. Hook in settings.json registrieren (falls noch nicht vorhanden)
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

# 5. Hinweis auf Rules
echo ""
echo "[INFO] Optional: Rules fuer Session-Kontext kopieren:"
echo "       cp $SCRIPT_DIR/rules/arbeitsumgebung.md <projekt>/.claude/rules/"
echo ""

# 6. tmux.conf (optional)
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

# 7. Test
echo "=== Schutz-Hook Test ==="
echo '{"tool_input":{"command":"rm -rf /home/test/GitHub"}}' | "$HOOKS_DIR/schutz.sh" 2>&1 && echo "[FEHLER] Hook hat nicht blockiert!" || echo "[OK] Destruktiver Befehl blockiert (Exit $?)"
echo '{"tool_input":{"command":"ls -la"}}' | "$HOOKS_DIR/schutz.sh" 2>&1 && echo "[OK] Sicherer Befehl erlaubt" || echo "[FEHLER] Sicherer Befehl blockiert!"

echo ""
echo "=== Setup abgeschlossen ==="
echo "Starte Claude Code neu damit die Hooks greifen."
