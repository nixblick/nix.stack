#!/bin/bash
# Hook: Gefaehrliche Befehle blockieren (PreToolUse auf Bash)

input=$(cat)

command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Nichts zu pruefen wenn kein Command
if [[ -z "$command" ]]; then
  exit 0
fi

# Muster die blockiert werden sollen
# rm -rf auf Projekt- oder Rollenverzeichnisse
if echo "$command" | grep -qP 'rm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+|.*--force).*(roles|playbooks|inventories|host_vars|group_vars)/'; then
  echo "BLOCKIERT: Loeschbefehl auf kritisches Verzeichnis erkannt: $command" >&2
  exit 2
fi

# rm -rf auf das gesamte Projektverzeichnis
if echo "$command" | grep -qP 'rm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+|.*--force).*/mnt/hgfs/llm/home/ansible\b'; then
  echo "BLOCKIERT: Loeschbefehl auf Projektverzeichnis erkannt: $command" >&2
  exit 2
fi

# Versehentliches Ueberschreiben von host_vars/group_vars mit > (Redirect)
if echo "$command" | grep -qP '>\s*(host_vars|group_vars)/'; then
  echo "BLOCKIERT: Redirect-Ueberschreibung auf host_vars/group_vars erkannt: $command" >&2
  exit 2
fi

exit 0
