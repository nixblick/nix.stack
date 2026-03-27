#!/bin/bash
# nix.stack Pre-Commit Check (PreToolUse auf Bash)
# Blockiert git commit wenn grundlegende Regeln nicht eingehalten werden.
# Exit 2 = Commit wird nicht ausgefuehrt
# Exit 0 = Alles ok, Commit darf weiterlaufen

input=$(cat)

command=$(echo "$input" | jq -r '.tool_input.command // empty')

# Nur bei git commit pruefen
if [[ -z "$command" ]] || ! echo "$command" | grep -qP 'git\s+commit'; then
  exit 0
fi

# Bei --amend weniger streng (CHANGELOG muss nicht nochmal geaendert sein)
is_amend=false
if echo "$command" | grep -qP '\-\-amend'; then
  is_amend=true
fi

errors=()

# --- 1. CHANGELOG.md muss in staged files sein ---
if [[ "$is_amend" == false ]]; then
  staged_files=$(git diff --cached --name-only 2>/dev/null)

  if [[ -n "$staged_files" ]]; then
    # Pruefen ob ueberhaupt Code-Dateien geaendert wurden (nicht nur Docs)
    has_code_changes=false
    while IFS= read -r file; do
      if [[ ! "$file" =~ ^(CHANGELOG|README|LICENSE|TODO|HARNESS|\.md$) ]] && [[ "$file" != "CHANGELOG.md" ]] && [[ "$file" != "README.md" ]]; then
        has_code_changes=true
        break
      fi
    done <<< "$staged_files"

    if [[ "$has_code_changes" == true ]]; then
      if ! echo "$staged_files" | grep -q "CHANGELOG.md"; then
        errors+=("CHANGELOG.md nicht aktualisiert! Bitte Version hochzaehlen und Aenderung dokumentieren.")
      fi
    fi
  fi
fi

# --- 2. Secrets-Check im Diff ---
staged_diff=$(git diff --cached 2>/dev/null)

if [[ -n "$staged_diff" ]]; then
  # API-Keys und Tokens (haeufige Muster)
  if echo "$staged_diff" | grep -qP '^\+.*(?:api[_-]?key|api[_-]?secret|access[_-]?token|secret[_-]?key|private[_-]?key)\s*[:=]\s*["\x27][A-Za-z0-9+/=_-]{20,}'; then
    errors+=("MOEGLICHES SECRET IM CODE! API-Key/Token in staged changes gefunden. Bitte pruefen und ggf. in .env oder Vault auslagern.")
  fi

  # Hardcodierte Passwoerter
  if echo "$staged_diff" | grep -qP '^\+.*(?:password|passwd|pwd)\s*[:=]\s*["\x27][^\s"'\'']{8,}'; then
    errors+=("MOEGLICHES PASSWORT IM CODE! Hardcodiertes Passwort in staged changes gefunden.")
  fi

  # .env-Dateien committed
  if git diff --cached --name-only 2>/dev/null | grep -qP '\.env(\.|$)'; then
    errors+=(".env-DATEI IM COMMIT! .env-Dateien gehoeren in .gitignore, nicht ins Repo.")
  fi

  # SSH Private Keys
  if echo "$staged_diff" | grep -qP '^\+.*BEGIN (RSA |DSA |EC |OPENSSH )?PRIVATE KEY'; then
    errors+=("SSH PRIVATE KEY IM COMMIT! Private Keys duerfen nie ins Repo.")
  fi
fi

# --- Ergebnis ---
if [[ ${#errors[@]} -gt 0 ]]; then
  echo "" >&2
  echo "=== nix.stack Pre-Commit Check: BLOCKIERT ===" >&2
  echo "" >&2
  for err in "${errors[@]}"; do
    echo "  [FEHLER] $err" >&2
  done
  echo "" >&2
  echo "Commit wurde verhindert. Bitte die Probleme beheben und erneut committen." >&2
  exit 2
fi

exit 0
