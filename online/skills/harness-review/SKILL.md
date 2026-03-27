---
name: harness-review
description: Meta-Review des gesamten nix.stack Harness — prueft ob Skills, Hooks, Rules, MDs noch sinnvoll sind und schlaegt Verbesserungen vor
user-invocable: true
argument-hint:
---

# Harness Self-Review

Das System reviewt sich selbst. Pruefe den gesamten nix.stack Harness und alle Claude Code Konfigurationen auf Aktualitaet, Sinnhaftigkeit und Verbesserungspotential.

## Was wird geprueft

### 1. Hooks (~/.claude/hooks/)
- Funktionieren alle Hooks noch? (Syntax, Pfade, Permissions)
- Sind die Regex-Patterns aktuell? (neue Gefahren abgedeckt?)
- Gibt es Hooks die nie triggern oder redundant sind?
- Fehlen Hooks fuer neue Risiken?
- Performance: Bremsen Hooks den Workflow aus? (Timeouts pruefen)

### 2. Skills (~/.claude/skills/)
- Welche Skills sind installiert? (ls ~/.claude/skills/)
- Werden alle Skills regelmaessig genutzt? (Wenn gstack-Analytics vorhanden: ~/.gstack/analytics/skill-usage.jsonl pruefen)
- Sind die Skill-Beschreibungen praezise genug fuer korrektes Triggering?
- Gibt es Ueberlappungen zwischen Skills?
- Fehlen Skills fuer wiederkehrende Aufgaben?
- Sind domainspezifische Skills (kritiker-web, etc.) noch aktuell?

### 3. Rules und CLAUDE.md
- Globale CLAUDE.md (~/.claude/CLAUDE.md): Noch aktuell? Widerspruechlich?
- Projekt-CLAUDE.md Dateien: Konsistent untereinander?
- Rules (.claude/rules/): Laden sie den richtigen Kontext?
- Sind Anweisungen zu lang? (Token-Kosten vs. Nutzen)

### 4. Memory (~/.claude/projects/*/memory/)
- Veraltete Memories identifizieren (Projekte die nicht mehr existieren, falscher Stand)
- Fehlende Memories (wichtige Kontexte die nicht gespeichert sind)
- Memory-Index (MEMORY.md) aktuell?

### 5. Settings
- ~/.claude/settings.json: Hooks korrekt registriert? Permissions sinnvoll?
- ~/.claude/settings.local.json: Permissions zu breit oder zu eng?
- Projekt-settings: Konsistent?

### 6. Gesamtbild
- Ist der Harness noch schlank genug? (Prinzip: 5 essentielle Teile > 40 unuebersichtliche)
- Gibt es tote oder nie genutzte Konfiguration?
- Was fehlt am meisten?

## Vorgehen

1. Lies alle relevanten Dateien systematisch
2. Pruefe jeden Bereich
3. Teste Hooks wo moeglich (echo Test-Input | hook.sh)
4. Vergleiche mit Best Practices aus HARNESS.md

## Ausgabeformat

### Harness Health Score: X/10

**Aktuell und gut:**
- Was funktioniert, kurz bestaetigen

**Veraltet oder problematisch:**
- Was nicht mehr stimmt + konkreter Fix

**Fehlt:**
- Was ergaenzt werden sollte + warum

**Empfehlung:**
- Top 3 Massnahmen nach Aufwand/Nutzen sortiert

Am Ende: Aenderungen direkt umsetzen falls gewuenscht, oder als TODO.md-Eintraege vormerken.
