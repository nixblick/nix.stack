# Context-Schema — nixblick Projekte

## Zweck

Einheitliche Projekt-Kontextdateien für Claude Code und André.
Jedes aktive nixblick-Repo bekommt eine YAML-Datei in `context/repos/`.

## Schema (v1)

```yaml
name: string                    # Repo-/Projektname
url: string | null              # Live-URL (null wenn kein Web)
repo: string                    # GitHub: nixblick/<name>
type: enum                      # web-app | cli | bot | infra | static-site | collection
stack: list[string]             # Technologien
hosting: string | null          # Wo läuft es
deploy: string | null           # Wie wird deployed
status: enum                    # live | dev | dormant

purpose: string                 # Was macht das Projekt, 2-3 Sätze

api: object | null              # Nur wenn API vorhanden
  base: string
  auth: string
  secrets: string               # Pfad relativ zu nixblick/

depends_on: list[string]        # Andere nixblick-Repos
shared_integration: object      # Status der shared-Einbindung
  analytics: bool
  datenschutz: bool
  impressum: bool

owner: André Hinz
contact:
  mail: mail@andrehinz.de
  telegram: André

notes: string | null            # Besonderheiten, Kontext

last_review: date               # Letztes Review-Datum
review_interval: wöchentlich    # Aktueller Zyklus
```

## Regeln

- **Scope:** Nur eigene nixblick-Projekte. Job-Repos und Archive sind out of scope.
- **Review:** Wöchentlich prüfen ob Dateien noch aktuell sind. Zyklus wird bei Bedarf verlängert.
- **Pflege:** Bei größeren Änderungen (neues Feature, Hosting-Wechsel, neues Repo) sofort updaten.
- **Übersicht:** `OVERVIEW.md` ist die zentrale Karte aller Projekte — immer synchron halten.

## Typen

| type | Beschreibung |
|------|-------------|
| `web-app` | Dynamische Webanwendung mit Backend |
| `static-site` | Statische Website (HTML/CSS/JS) |
| `bot` | Telegram-Bot oder ähnlicher Dienst |
| `infra` | Ansible, Docker, Server-Konfiguration |
| `cli` | Kommandozeilen-Tool |
| `collection` | Skript-/Dateisammlung ohne eigene Anwendung |
