#!/bin/bash
# nix.stack Offline-Setup
# Fuer Maschinen ohne Internet und ohne Git (z.B. Ansible-Controller)
#
# Installiert:
# - Schutz-Hook (PreToolUse) + ansible-lint Hook (PostToolUse)
# - Skills: /kritiker, /rolle-erstellen
# - Rules fuer Session-Kontext
# - ansible-lint Konfiguration

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Zielverzeichnis abfragen
if [[ -n "${1:-}" ]]; then
  PROJECT_DIR="$1"
else
  echo "Verwendung: $0 <projektverzeichnis>"
  echo "Beispiel:   $0 /mnt/hgfs/llm/home/ansible"
  exit 1
fi

if [[ ! -d "$PROJECT_DIR" ]]; then
  echo "FEHLER: Verzeichnis $PROJECT_DIR existiert nicht."
  exit 1
fi

CLAUDE_DIR="$PROJECT_DIR/.claude"

echo "=== nix.stack Offline-Setup ==="
echo "Ziel: $PROJECT_DIR"
echo ""

# 1. Verzeichnisstruktur erstellen
mkdir -p "$CLAUDE_DIR"/{hooks,rules,skills/kritiker,skills/rolle-erstellen}

# 2. Hooks kopieren
cp "$SCRIPT_DIR/hooks/schutz.sh" "$CLAUDE_DIR/hooks/"
cp "$SCRIPT_DIR/hooks/ansible-lint.sh" "$CLAUDE_DIR/hooks/"
chmod +x "$CLAUDE_DIR/hooks/"*.sh
echo "[OK] Hooks installiert: schutz.sh, ansible-lint.sh"

# 3. Skills kopieren
cp "$SCRIPT_DIR/skills/kritiker/SKILL.md" "$CLAUDE_DIR/skills/kritiker/"
cp "$SCRIPT_DIR/skills/rolle-erstellen/SKILL.md" "$CLAUDE_DIR/skills/rolle-erstellen/"
echo "[OK] Skills installiert: /kritiker, /rolle-erstellen"

# 4. Rules kopieren
cp "$SCRIPT_DIR/rules/arbeitsumgebung.md" "$CLAUDE_DIR/rules/"
echo "[OK] Rules installiert: arbeitsumgebung.md"

# 5. ansible-lint Konfiguration (nur wenn noch nicht vorhanden)
if [[ ! -f "$PROJECT_DIR/.ansible-lint" ]]; then
  cp "$SCRIPT_DIR/ansible-lint.example" "$PROJECT_DIR/.ansible-lint"
  echo "[OK] .ansible-lint Konfiguration erstellt"
else
  echo "[OK] .ansible-lint existiert bereits — uebersprungen"
fi

# 6. CLAUDE.md (nur wenn noch nicht vorhanden)
if [[ ! -f "$PROJECT_DIR/CLAUDE.md" ]]; then
  cp "$SCRIPT_DIR/CLAUDE.md.example" "$PROJECT_DIR/CLAUDE.md"
  echo "[OK] CLAUDE.md erstellt"
else
  echo "[OK] CLAUDE.md existiert bereits — uebersprungen"
fi

# 7. Hook-Registrierung
if [[ -f "$CLAUDE_DIR/settings.local.json" ]]; then
  echo ""
  echo "[INFO] settings.local.json existiert bereits."
  echo "       Pruefe ob die Hooks dort registriert sind."
  echo "       Referenz: $SCRIPT_DIR/settings-snippet.json"
else
  # Pfade im Snippet anpassen und kopieren
  cat > "$CLAUDE_DIR/settings.local.json" << SETTINGS_EOF
{
  "permissions": {
    "allow": []
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_DIR/hooks/schutz.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_DIR/hooks/ansible-lint.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
SETTINGS_EOF
  echo "[OK] settings.local.json erstellt mit Hook-Konfiguration"
fi

# 8. Test
echo ""
echo "=== Schutz-Hook Test ==="
echo '{"tool_input":{"command":"rm -rf roles/test"}}' | "$CLAUDE_DIR/hooks/schutz.sh" 2>&1 && echo "[FEHLER] Hook hat nicht blockiert!" || echo "[OK] Destruktiver Befehl blockiert (Exit $?)"

echo ""
echo "=== Setup abgeschlossen ==="
echo ""
echo "Installierte Dateien:"
find "$CLAUDE_DIR" -type f | sort | sed "s|$PROJECT_DIR/||"
echo ""
echo "Starte Claude Code neu damit Hooks und Skills greifen."
