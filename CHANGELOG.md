# Changelog — nix.stack

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
