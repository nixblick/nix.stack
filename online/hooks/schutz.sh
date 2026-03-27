#!/bin/bash
# nix.stack Online-Schutz-Hook (PreToolUse auf Bash)
# Fuer Maschinen mit Internet und Git-Zugriff (z.B. Rocky-Notebook)
#
# Basiert auf shared/hooks/schutz.sh mit online-spezifischen Erweiterungen

input=$(cat)

command=$(echo "$input" | jq -r '.tool_input.command // empty')

if [[ -z "$command" ]]; then
  exit 0
fi

# --- 1. rm -rf auf kritische Verzeichnisse ---

if echo "$command" | grep -qP 'rm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+|.*--force).*/home/anhi/GitHub\b'; then
  echo "BLOCKIERT: rm -rf auf GitHub-Verzeichnis: $command" >&2
  exit 2
fi

if echo "$command" | grep -qP 'rm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+|.*--force).*(/home/anhi/?|~/?)(\s|$)'; then
  echo "BLOCKIERT: rm -rf auf Home-Verzeichnis: $command" >&2
  exit 2
fi

if echo "$command" | grep -qP 'rm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+|.*--force).*/home/anhi/\.claude\b'; then
  echo "BLOCKIERT: rm -rf auf .claude-Konfiguration: $command" >&2
  exit 2
fi

if echo "$command" | grep -qP 'rm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+|.*--force).*/home/anhi/\.ssh\b'; then
  echo "BLOCKIERT: rm -rf auf .ssh-Verzeichnis: $command" >&2
  exit 2
fi

# --- 2. Secrets und sensible Dateien ---

if echo "$command" | grep -qP 'cat\s+.*\.env\b'; then
  echo "BLOCKIERT: cat auf .env-Datei (Leak-Risiko): $command" >&2
  exit 2
fi

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
