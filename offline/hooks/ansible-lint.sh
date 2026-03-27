#!/bin/bash
# Hook: ansible-lint nach Edit/Write auf YAML-Dateien ausfuehren

input=$(cat)

# file_path aus tool_input extrahieren (Edit und Write nutzen file_path)
file=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Nur YAML-Dateien pruefen
if [[ -z "$file" || ! "$file" =~ \.(yml|yaml)$ ]]; then
  exit 0
fi

# Nur Ansible-relevante Dateien pruefen (roles/, playbooks/, tasks/, handlers/, defaults/, vars/)
if [[ ! "$file" =~ (roles|playbooks|tasks|handlers|defaults|vars|inventories)/ ]]; then
  exit 0
fi

# ansible-lint ausfuehren
output=$(ansible-lint -q "$file" 2>&1)
rc=$?

if [[ $rc -ne 0 && -n "$output" ]]; then
  # Fehler als stderr ausgeben damit Claude sie sieht
  echo "ansible-lint Fehler in $file:" >&2
  echo "$output" >&2
  exit 1
fi

exit 0
