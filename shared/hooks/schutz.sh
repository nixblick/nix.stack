#!/bin/bash
# nix.stack Schutz-Hook (PreToolUse auf Bash)
# Blockiert gefaehrliche Befehle bevor sie ausgefuehrt werden.
# Exit 2 = Befehl wird nicht ausgefuehrt (Claude sieht die Meldung)
#
# Anpassung:
# - NIX_STACK_PROTECTED_PATHS: Komma-separierte Liste von Pfaden die geschuetzt werden
# - Falls nicht gesetzt, wird $HOME/GitHub geschuetzt

input=$(cat)

command=$(echo "$input" | jq -r '.tool_input.command // empty')

if [[ -z "$command" ]]; then
  exit 0
fi

# Geschuetzte Pfade (konfigurierbar)
IFS=',' read -ra PROTECTED <<< "${NIX_STACK_PROTECTED_PATHS:-$HOME/GitHub}"

# --- 1. rm -rf auf geschuetzte Verzeichnisse ---
for path in "${PROTECTED[@]}"; do
  path=$(echo "$path" | xargs)  # Whitespace trimmen
  escaped=$(echo "$path" | sed 's/[.[\*^$()+?{|\\]/\\&/g')
  if echo "$command" | grep -qP "rm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+|.*--force).*${escaped}"; then
    echo "BLOCKIERT: rm -rf auf geschuetztes Verzeichnis ($path): $command" >&2
    exit 2
  fi
done

# Home-Verzeichnis direkt
if echo "$command" | grep -qP "rm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+|.*--force).*(${HOME}/?|~/?)(\s|$)"; then
  echo "BLOCKIERT: rm -rf auf Home-Verzeichnis: $command" >&2
  exit 2
fi

# Claude-Konfiguration
if echo "$command" | grep -qP "rm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+|.*--force).*${HOME}/\.claude\b"; then
  echo "BLOCKIERT: rm -rf auf .claude-Konfiguration: $command" >&2
  exit 2
fi

# SSH-Verzeichnis
if echo "$command" | grep -qP "rm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+|.*--force).*${HOME}/\.ssh\b"; then
  echo "BLOCKIERT: rm -rf auf .ssh-Verzeichnis: $command" >&2
  exit 2
fi

# --- 2. Secrets und sensible Dateien ---

# .env-Dateien lesen (Leak-Risiko)
if echo "$command" | grep -qP 'cat\s+.*\.env\b'; then
  echo "BLOCKIERT: cat auf .env-Datei (Leak-Risiko): $command" >&2
  exit 2
fi

# SSH Private Keys lesen
if echo "$command" | grep -qP 'cat\s+.*\.ssh/(id_|.*key)'; then
  echo "BLOCKIERT: cat auf SSH-Key (Leak-Risiko): $command" >&2
  exit 2
fi

# --- 3. Destruktive Git-Operationen ---

if echo "$command" | grep -qP 'git\s+push\s+.*--force'; then
  echo "BLOCKIERT: git push --force — bitte bestaetigen lassen: $command" >&2
  exit 2
fi

if echo "$command" | grep -qP 'git\s+reset\s+--hard'; then
  echo "BLOCKIERT: git reset --hard — bitte bestaetigen lassen: $command" >&2
  exit 2
fi

if echo "$command" | grep -qP 'git\s+branch\s+.*-[dD]\s'; then
  echo "BLOCKIERT: git branch delete — bitte bestaetigen lassen: $command" >&2
  exit 2
fi

# --- 4. Systemkritisch ---

if echo "$command" | grep -qP 'systemctl\s+(stop|disable)\s+(sshd|firewalld|NetworkManager)'; then
  echo "BLOCKIERT: Stoppen von kritischem System-Service: $command" >&2
  exit 2
fi

exit 0
