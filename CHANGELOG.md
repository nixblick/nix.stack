# Changelog — nix.stack

## 2026-03-28 — v3.4.0
- **Dave Inbox-Poll** — alle 10 Minuten checkt Dave die Telegram-Inbox
  - Andre schickt `/dave smoke test skyrun` per Telegram → Dave fuehrt es aus → Ergebnis per Telegram zurueck
  - Funktioniert solange Claude Code in tmux laeuft (Session-only CronJob, 7 Tage Limit)
  - Dave als "immer erreichbarer" DevOps-Assistent per Telegram

## 2026-03-28 — v3.3.0
- **Bot-Commands bei Telegram registriert** — /dave, /einstein, /bodo, /casi mit Autocomplete
- **Inline-Mentions** — /dave und @einstein funktionieren jetzt auch mitten im Text
- **Einstein Datenquellen erweitert** — todomanager/docs/ (LEBEN.md, PROJEKTE.md, 8 Themenmodule) als Kontext
- **Inbox bereinigt** — alte Coach-Nachrichten entfernt

## 2026-03-28 — v3.2.0
- **Bidirektionale Telegram-Kommunikation** ueber CoachNixBot:
  - `telegram-send` zum Senden (alle 4 Assistenten)
  - `telegram-receive` zum Empfangen (liest Inbox-Datei)
  - CoachNixBot (todomanager) erweitert: schreibt eingehende Nachrichten in `~/.claude/telegram_inbox.jsonl`
  - Bot neugestartet mit Inbox-Feature
  - Einstein nutzt jetzt auch Telegram (Erinnerungen, Briefings, Retro)
  - Alle Assistenten pruefen bei CronJobs ob Andre per Telegram geantwortet hat

## 2026-03-28 — v3.1.0
- **Telegram-Bot-Integration** fuer nix.stack auf Rocky (eigener Bot, unabhaengig von clawd/Nano):
  - `shared/scripts/telegram-send.sh` — universelles Send-Script fuer alle Assistenten
  - Symlink nach `~/.local/bin/telegram-send` (im PATH)
  - Secrets in `~/.secrets/nix_stack_bot.env` (BOT_TOKEN + CHAT_ID)
  - setup.sh erstellt Symlink und prueft Secrets automatisch
- Dave und CaSi auf lokales `telegram-send` umgestellt (kein SSH zum Nano noetig)
- Funktioniert auch unterwegs ohne Homelab-Zugriff

## 2026-03-28 — v3.0.0
- **Alle 4 Assistenten-Rollen grundlegend ueberarbeitet** basierend auf Q&A mit Andre:
- **Einstein v2** — vom Produktivitaets-Tool zum guten Freund:
  - Behaelt das grosse Ganze im Blick (Job, Kinder, Gesundheit)
  - Neuer CronJob: Wochen-Retro (Fr) — gemeinsamer Rueckblick, keine Einweg-Reports
  - todomanager/leben.nixblick.de als zentrale Datenquelle und Pflegeobjekt
  - Fragt aktiv nach fehlenden Aufgaben, sammelt alles (nicht nur Code)
  - Arbeitet unabhaengig von Dave, Bodo, CaSi
- **Bodo v2** — mit echten Zahlen:
  - Konkrete Kosten: 150 EUR/Monat (Claude 100 + Goneo 20 + Strom 30), 0 EUR Einnahmen
  - Portfolio-Wert als eigene Kategorie (Freelance-Akquise)
  - Hakt nach ob letzte Vorschlaege umgesetzt wurden
  - Aufwand-Schaetzungen bei jedem Vorschlag
- **CaSi v2** — strenger Waechter statt Allrounder:
  - CaSi FIXT NICHTS — nur analysieren, berichten, Anweisungen geben
  - BSI IT-Grundschutz-Kompendium als Referenz-Framework
  - Workflow: CaSi findet → Andre entscheidet → Dave fixt → CaSi prueft
  - SSH-Zugriff (nur lesend) auf AIGude, Homelab, Nano
  - Telegram fuer kritische Findings
  - Urteilt ueber Daves Security-Arbeit

## 2026-03-28 — v2.1.0
- **Projekt-Kontext** als Symlink verfuegbar: `~/.claude/context/` → `nix.stack/context/`
  - OVERVIEW.md (zentrale Projekt-Map), SCHEMA.md, repos/*.yml (13 Projekte)
  - Alle Assistenten und Skills koennen Projektdaten ueber `~/.claude/context/` lesen
  - setup.sh erstellt den Symlink automatisch
- `context/` Verzeichnis in Git aufgenommen (war bisher unversioniert)

## 2026-03-28 — v2.0.0
- **Architektur-Umbau:** Assistenten (Dave, Einstein, Bodo) von `online/assistants/` nach `online/skills/*/rolle.md` migriert
  - SKILL.md Dateien jetzt im Repo statt nur als Kopien in `~/.claude/skills/`
  - Jeder Assistent hat `SKILL.md` (Einstiegspunkt) + `rolle.md` (Rollenbeschreibung)
  - `online/assistants/` Verzeichnis entfernt — eine Quelle der Wahrheit
- **Setup auf Symlinks umgestellt:** `setup.sh` erstellt jetzt Symlinks statt Kopien
  - Aenderungen im Repo wirken sofort, kein erneutes setup.sh noetig
  - Alte Kopien werden automatisch durch Symlinks ersetzt
- **CaSi** — neuer Informationssicherheits-Guru als 4. Assistent:
  - Vereinigt `/kritiker-web` (Code-Audit), `/cso` (gstack Infrastruktur-Audit) und `vulnerabilities.yml` (Wissensbasis)
  - 4 CronJobs: Secrets-Scan (Mo-Fr), Dependency-Audit (Di/Fr), Web-Security-Check (Mi), Wochen-Report (Mo)
  - Manuell aufrufbar: `/casi scan`, `/casi audit`, `/casi headers`, `/casi report`
- Assistenten-Uebersicht: Dave (DevOps), Einstein (Produktivitaet), Bodo (Finanzen), CaSi (Sicherheit)

## 2026-03-28 — v1.6.0
- Einstein-Prompts aktualisiert: Morgen-Briefing und Feierabend-Check nutzen jetzt fetch-todos.sh fuer Eisenhower-Daten von leben.nixblick.de API
- Datenquellen-Sektion in einstein.md praezisiert: API-first mit Fallback auf TODO.md
- SKILL.md synchron mit Assistenten-Definition

## 2026-03-28 — v1.5.0
- Schwachstellen-Wissensbasis aus infra.security migriert → `shared/security_knowledge/vulnerabilities.yml`
  - 19 Schwachstellentypen mit check_hints, severity, OWASP/CWE-Referenzen
  - Kategorien: Injection, XSS, CSRF, Auth, Sessions, HTTP-Header, Uploads, Credentials, Infra
- `/kritiker-web` Skill nutzt jetzt die Wissensbasis als zusaetzliche Checkliste
- infra.security Repo kann nach dieser Migration aufgeloest werden (Credential-Rotation war einziger weiterer Inhalt — wird in job-bezogenen Repos weiterentwickelt)

## 2026-03-27 — v1.4.0
- Drei KI-Assistenten als CronJob-Rollen + Skills definiert:
  - `/dave` — DevOps-Assistent: Workflow-Check, Site-Monitor, Repo-Health, Smoke Tests, Tagesbericht
  - `/einstein` — Persoenlicher Assistent: Morgen-Briefing, Mittags-Check, Pausen, Feierabend, Bett-Erinnerung
  - `/bodo` — Money Coach: ROI-Analyse, Monetarisierungs-Radar, Deep-Dive pro Projekt
- Rollenbeschreibungen in `online/assistants/{dave,einstein,bodo}.md`
- Skills in `~/.claude/skills/{dave,einstein,bodo}/SKILL.md`
- Jeder Assistent per `/name einrichten` aktivierbar (CronJobs) oder sofort aufrufbar (`/dave check`, `/bodo roi` etc.)

## 2026-03-27 — v1.3.0
- `/harness-review` Skill: Meta-Review des Harness — prueft ob Skills, Hooks, Rules noch sinnvoll sind
- `/arbeitsweise` Skill: Analysiert Commits, Changelogs, Arbeitsmuster und gibt Feedback zur Claude Code Nutzung
- `/repo-health` Skill: Health-Check ueber alle nixblick-Repos (Dependencies, TODOs, Sicherheit, Shared-Ressourcen)
- `/site-monitor` Skill: Live-Site-Pruefung (Erreichbarkeit, SSL, Security-Header, Performance, Console-Errors)
- `/neues-projekt` Skill: Bootstrapper fuer neue Projekte mit Standard-Struktur und Shared-Ressourcen

## 2026-03-27 — v1.2.0
- Pre-Commit Workflow: Zweistufige Pruefung vor jedem git commit
  - Command-Hook: Blockiert Commit wenn CHANGELOG.md fehlt oder Secrets im Diff
  - Agent-Hook: Kritiker-Review auf Sicherheit, Qualitaet, Sinn und Docs-Bedarf
- Workflow-Reihenfolge: Aenderung → Kritiker → Fixes → Docs → Commit → Push
- Pre-Commit-Check Prompt als Referenzdatei dokumentiert

## 2026-03-27 — v1.1.0
- Notification-Hook: Desktop-Benachrichtigung wenn Claude auf Eingabe wartet (notify-send/osascript)
- Web-Kritiker Skill: `/kritiker-web` fuer OWASP Top 10, XSS, Auth, CSP, Performance, a11y
- tmux.conf Symlink: Setup-Scripts bieten optional Verlinkung nach ~/.tmux.conf an
- Setup-Scripts erweitert: Installieren jetzt auch Notification-Hook und Web-Kritiker Skill

## 2026-03-27 — v1.0.0
- Initiale Erstellung des Repos
- Online-Harness: Schutz-Hook, Rules, Setup-Script (fuer Rocky-Notebook mit gstack)
- Offline-Harness: Schutz-Hook, ansible-lint Hook, Skills (/kritiker, /rolle-erstellen), Rules, Setup-Script
- Shared: Konfigurierbarer Basis-Schutz-Hook
- HARNESS.md: Theorie und Praxis-Dokumentation
- README.md mit Schnellstart-Anleitung
