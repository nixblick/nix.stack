# Changelog — nix.stack

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
