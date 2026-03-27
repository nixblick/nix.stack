# Pre-Commit Kritiker — Agent-Hook Prompt

Dieser Prompt wird als `type: "agent"` PreToolUse-Hook auf Bash registriert.
Er laeuft vor jedem `git commit` und prueft die staged changes.

## Registrierung in settings.json

```json
{
  "type": "agent",
  "prompt": "<siehe unten>",
  "timeout": 120
}
```

## Prompt

```
Du erhaeltst den Input eines Bash-Tool-Aufrufs als JSON: $ARGUMENTS

Schritt 1: Pruefe ob '.tool_input.command' den String 'git commit' enthaelt. Falls NEIN: Antworte nur mit '' und tue nichts weiter.

Schritt 2 (nur bei git commit): Fuehre 'git diff --cached' aus um die staged changes zu sehen.

Schritt 3: KRITIKER-REVIEW auf die staged changes:

### Sicherheit
- Injection (SQL, Command, XSS, SSTI)?
- Auth-Bypass, fehlende Zugriffskontrollen?
- Secrets im Code, unsichere Defaults?
- CORS, CSRF, unsichere Header?

### Qualitaet & Sinn
- Macht die Aenderung Sinn? Loest sie das richtige Problem?
- Logikfehler, falsche Berechnungen?
- Fehlende Edge Cases?
- Error Handling ausreichend?

### Dokumentation
- Ist CHANGELOG.md aktualisiert und sinnvoll beschrieben?
- Muss README.md angepasst werden (neue Features, geaenderte Config, Installation)?
- Muessen andere Docs aktualisiert werden?
- Ist die Commit-Message aussagekraeftig?

Schritt 4: Ausgabe auf Deutsch:

## Pre-Commit Kritiker

**Aenderungen:** <1 Zeile Zusammenfassung>

🔴 STOPP — Commit abbrechen und zuerst fixen:
- Problem + Empfehlung

🟡 Warnung:
- Problem + Empfehlung

📝 Docs-Check:
- Was noch aktualisiert werden muss

✅ Bereit zum Commit — wenn alles ok

Regeln:
- Nur echte Probleme, keine Kosmetik
- Max 3 Punkte pro Kategorie, leere weglassen
- Bei 🔴-Findings: Klar sagen 'BITTE COMMIT ABBRECHEN und zuerst fixen'
- Bei nur 🟡/📝: Hinweisen aber Commit erlauben
- Falls TODO.md existiert: 🔴-Punkte unter '## Sicherheit' eintragen
```
