---
name: neues-projekt
description: Bootstrapper fuer neue nixblick-Projekte — erstellt Repo mit Standard-Struktur, Shared-Ressourcen, Claude Code Integration
user-invocable: true
argument-hint: <projektname> <kurzbeschreibung>
---

# Neues nixblick-Projekt erstellen

Erstelle ein neues Projekt unter ~/GitHub/nixblick/ mit vollstaendiger Standard-Ausstattung.

## Eingabe

- `$0` — Projektname (z.B. `meinprojekt`)
- `$1` — Kurzbeschreibung (z.B. "Portfolio-Webseite fuer Fotografen")

Falls Argumente fehlen: nachfragen.

## Schritt 1: Repo erstellen

```bash
cd ~/GitHub/nixblick
gh repo create nixblick/$0 --public --description "$1" --clone
cd $0
```

## Schritt 2: Standard-Dateien erstellen

### README.md
```markdown
# $0

$1

## Setup

[wird nach Implementierung ergaenzt]

## Lizenz

[nach Bedarf]
```

### CHANGELOG.md
```markdown
# Changelog — $0

## [Datum] — v0.1.0
- Initiale Erstellung
```

### TODO.md
```markdown
# TODO — $0

## Sicherheit

## Bugs / Funktionale Fehler

## Verbesserungen
```

### .gitignore
Basierend auf dem Projekttyp erstellen:
- Webprojekt: node_modules/, .env, dist/, .DS_Store
- Python: __pycache__/, .venv/, *.pyc, .env
- PHP: vendor/, .env
- Generisch: .env, .DS_Store, *.log

## Schritt 3: Shared-Ressourcen einbinden

Pruefe ~/GitHub/nixblick/shared/ und binde ein:

### Analytics (falls Webprojekt)
- Snippet aus `shared/snippets/analytics/` in HTML einbauen
- Pruefen ob das Snippet aktuell ist

### Datenschutz (falls Webprojekt mit Analytics)
- Template aus `shared/policies/` kopieren/anpassen
- Link im Footer einbauen

### Impressum (falls oeffentliches Webprojekt)
- Template aus `shared/policies/` kopieren/anpassen
- Link im Footer einbauen

## Schritt 4: Claude Code Integration

### CLAUDE.md erstellen
Projektspezifische Regeln basierend auf dem Projekttyp:
- Webprojekt: Web-Sicherheitsregeln, CSP, Dependencies
- Python: PEP 8, Type Hints, Testing
- PHP: Security-Best-Practices, Prepared Statements
- Allgemein: Kritiker-Review Workflow verweisen

### .claude/ Verzeichnis
```bash
mkdir -p .claude/rules
```

Optional: arbeitsumgebung.md aus nix.stack kopieren und anpassen.

## Schritt 5: Erster Commit

```bash
git add -A
git commit -m "v0.1.0: Initiale Projektstruktur"
git push -u origin main
```

## Schritt 6: Zusammenfassung

Zeige an:
- Erstelle Dateien
- GitHub-URL
- Naechste Schritte (was Andre als erstes implementieren sollte)
- Hinweis: `/kritiker-web` fuer den ersten Code-Review nutzen

## Regeln

- Frag IMMER nach dem Projekttyp wenn nicht klar (Web, CLI, API, Library, etc.)
- Frag nach der Zielsprache wenn nicht klar
- Erstelle nur das Minimum — kein Overengineering bei der Ersteinrichtung
- Shared-Ressourcen nur einbinden wenn es ein oeffentliches Webprojekt ist
