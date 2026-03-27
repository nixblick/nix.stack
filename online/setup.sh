#!/bin/bash
# nix.stack Online-Setup
# Fuer Maschinen mit Internet und Git-Zugriff
#
# Installiert:
# - Schutz-Hook (PreToolUse) in ~/.claude/hooks/
# - Registriert den Hook in ~/.claude/settings.json
# - Rules fuer Session-Kontext

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"

echo "=== nix.stack Online-Setup ==="
echo ""

# 1. Hooks-Verzeichnis erstellen
mkdir -p "$HOOKS_DIR"

# 2. Schutz-Hook kopieren
cp "$SCRIPT_DIR/hooks/schutz.sh" "$HOOKS_DIR/schutz.sh"
chmod +x "$HOOKS_DIR/schutz.sh"
echo "[OK] Schutz-Hook installiert: $HOOKS_DIR/schutz.sh"

# 3. Hook in settings.json registrieren (falls noch nicht vorhanden)
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

# 4. Hinweis auf Rules
echo ""
echo "[INFO] Optional: Rules fuer Session-Kontext kopieren:"
echo "       cp $SCRIPT_DIR/rules/arbeitsumgebung.md <projekt>/.claude/rules/"
echo ""

# 5. Test
echo "=== Schutz-Hook Test ==="
echo '{"tool_input":{"command":"rm -rf /home/test/GitHub"}}' | "$HOOKS_DIR/schutz.sh" 2>&1 && echo "[FEHLER] Hook hat nicht blockiert!" || echo "[OK] Destruktiver Befehl blockiert (Exit $?)"
echo '{"tool_input":{"command":"ls -la"}}' | "$HOOKS_DIR/schutz.sh" 2>&1 && echo "[OK] Sicherer Befehl erlaubt" || echo "[FEHLER] Sicherer Befehl blockiert!"

echo ""
echo "=== Setup abgeschlossen ==="
echo "Starte Claude Code neu damit die Hooks greifen."
