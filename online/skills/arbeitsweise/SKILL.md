---
name: arbeitsweise
description: Analysiert Changelogs und Commits aller nixblick-Repos, studiert Arbeitsmuster und gibt Feedback wie Andre effektiver mit Claude Code arbeiten kann
user-invocable: true
argument-hint: [zeitraum, z.B. "letzte Woche" oder "letzter Monat"]
---

# Arbeitsweise-Review

Analysiere Andres Arbeitsweise mit Claude Code und gib konkretes, ehrliches Feedback.

## Datenquellen

### 1. Git-Analyse (alle nixblick-Repos)
Fuer jedes Repo unter ~/GitHub/nixblick/ das ein .git hat:
```bash
# Commits im Zeitraum (default: letzte 2 Wochen)
git -C <repo> log --since="$ARGUMENTS" --oneline --format="%h %s (%ar)"
```

Analysiere:
- **Commit-Frequenz:** Wann wird gearbeitet? (Tageszeit, Wochentage)
- **Commit-Messages:** Aussagekraeftig? Konsistent? Version im Message?
- **Commit-Groesse:** Zu grosse Commits? Zu kleinteilig?
- **Co-Authored-By:** Wie oft arbeitet Claude mit? Welche Aufgaben macht Andre allein?
- **Welche Repos:** Wo fliesst die meiste Arbeit hin? Sind Projekte vernachlaessigt?

### 2. CHANGELOG-Analyse
Fuer jedes Repo mit CHANGELOG.md:
- Wird das Changelog konsistent gepflegt?
- Sind Eintraege beschreibend genug?
- Versionierung korrekt? (Patch/Minor/Major sinnvoll vergeben?)

### 3. TODO.md-Analyse
Fuer jedes Repo mit TODO.md:
- Wie viele offene Punkte? Wie alt sind sie?
- Werden Sicherheitspunkte zeitnah bearbeitet?
- Wachsen die TODOs schneller als sie abgearbeitet werden?

### 4. Harness-Nutzung
- Welche Skills werden genutzt? (gstack-Analytics falls vorhanden)
- Werden die Hooks tatsaechlich ausgeloest?
- Wird Memory aktiv gepflegt?

## Feedback-Bereiche

### Effizienz
- Arbeitet Andre an zu vielen Projekten gleichzeitig?
- Gibt es Muster die Zeit kosten? (z.B. gleiche Fehler wiederholt, gleiche Setups manuell)
- Welche Aufgaben koennten staerker automatisiert werden?

### Claude Code Nutzung
- Werden die richtigen Skills fuer die richtigen Aufgaben genutzt?
- Gibt es ungenutztes Potential? (z.B. /qa nie genutzt, aber manuelle Tests)
- Ist die CLAUDE.md effektiv oder zu lang/zu kurz?
- Werden Subagenten sinnvoll eingesetzt?

### Qualitaet
- Werden Sicherheitsfindings zeitnah gefixt?
- Ist der Code-Review-Workflow effektiv?
- Gibt es wiederkehrende Probleme die systematisch geloest werden koennten?

### Work-Life-Balance
- Gibt es Anzeichen fuer zu viel gleichzeitig? (viele angefangene, wenig fertige Projekte)
- Welche Projekte bringen echten Wert vs. welche sind Zeitfresser?

## Ausgabeformat

### Arbeitsweise-Review: [Zeitraum]

**Aktivitaet:**
- X Commits in Y Repos, Z davon mit Claude
- Aktivste Repos: ...
- Aktivste Tage/Zeiten: ...

**Was gut laeuft:**
- Konkrete Beobachtungen

**Was besser sein koennte:**
- Konkrete Beobachtung + konkreter Vorschlag

**Claude Code Tipps:**
- Spezifische Tipps basierend auf der Analyse

**Fokus-Empfehlung fuer naechste Woche:**
- Top 3 Prioritaeten basierend auf offenen TODOs und Projektstand

Ton: Ehrlich, konstruktiv, konkret. Wie ein guter Tech-Lead der einem hilft besser zu werden — nicht wie ein Manager der KPIs misst.
