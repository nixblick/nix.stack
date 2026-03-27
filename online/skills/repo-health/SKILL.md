---
name: repo-health
description: Health-Check ueber alle nixblick-Repos — Dependencies, TODOs, Sicherheit, Shared-Ressourcen, Aktualitaet
user-invocable: true
argument-hint:
---

# Repo Health-Check

Systematischer Gesundheitscheck aller nixblick-Repositories.

## Vorgehen

Iteriere ueber alle Repos unter ~/GitHub/nixblick/ die ein .git-Verzeichnis haben.

### Pro Repo pruefen:

#### 1. Grundlagen
- Letzter Commit: Wann? (Warnung wenn > 3 Monate inaktiv)
- README.md vorhanden und aktuell?
- CHANGELOG.md vorhanden und gepflegt?
- TODO.md: Offene Punkte zaehlen, aelteste identifizieren
- .gitignore vorhanden?

#### 2. Sicherheit
- `npm audit` / `pip audit` wo relevant (package.json / requirements.txt vorhanden?)
- .env-Dateien im Repo? (.gitignore pruefen!)
- Secrets in der Git-History? (`git log --all -p -S "password" --oneline | head -5`)
- Abgelaufene oder bald ablaufende Zertifikate? (wenn Live-URL bekannt)

#### 3. Shared-Ressourcen (nixblick-Standard)
Pruefe ob das Projekt den nixblick-Standard einfuegt:
- Analytics-Snippet aus ~/GitHub/nixblick/shared/snippets/analytics/ eingebunden?
- Datenschutzhinweis vorhanden? (Template aus shared/policies/)
- Impressum vorhanden? (Template aus shared/policies/)

#### 4. Dependencies
- package.json: `npm outdated` ausfuehren
- requirements.txt / pyproject.toml: Versions-Pins pruefen
- Sind Major-Updates verfuegbar die Breaking Changes haben koennten?

#### 5. Claude Code Integration
- Hat das Repo eine .claude/ Konfiguration?
- CLAUDE.md vorhanden?
- Sind nix.stack Hooks aktiv fuer dieses Repo?

### Live-Sites pruefen (wo URLs bekannt):
Bekannte nixblick-Sites:
- bvkfrankfurt.de
- leben.nixblick.de
- chessanimator (falls deployed)
- skyrun (falls deployed)

Fuer jede:
- HTTP-Status (curl -sI)
- SSL-Zertifikat gueltig? Ablaufdatum?
- Response-Time
- Security-Header vorhanden? (X-Frame-Options, CSP, etc.)

## Ausgabeformat

### Repo Health Report — [Datum]

**Zusammenfassung:**
- X Repos geprueft, Y aktiv (< 3 Monate), Z inaktiv
- Gesamt-Score: X/10

**Pro Repo (nur wenn Findings):**

| Repo | Letzter Commit | Score | Findings |
|------|----------------|-------|----------|
| name | vor X Tagen    | X/10  | Kurzbeschreibung |

**Kritisch (sofort handeln):**
- Repo: Problem + Empfehlung

**Warnung (bald handeln):**
- Repo: Problem + Empfehlung

**Live-Sites:**
| Site | Status | SSL | Response | Headers |
|------|--------|-----|----------|---------|

**Empfehlung:**
- Top 3 Massnahmen nach Dringlichkeit

Ergebnisse auch in die jeweiligen TODO.md Dateien eintragen wo relevant.
