# nixblick Projekt-Übersicht

> Zentrale Karte aller eigenen Projekte. Letzte Aktualisierung: 2026-03-28.
> Schema: [SCHEMA.md](SCHEMA.md) | Review-Zyklus: wöchentlich

## Web-Apps (dynamisch, mit Backend)

| Projekt | URL | Stack | Hosting | Status |
|---------|-----|-------|---------|--------|
| [todomanager](repos/todomanager.yml) | leben.nixblick.de | PHP, MySQL, JS | Goneo | live |
| [bvkfrankfurt](repos/bvkfrankfurt.yml) | bvkfrankfurt.de | HTML/JS/Python/PHP, MySQL | Goneo | live |
| [ChessAnimator](repos/chessanimator.yml) | hinjas.ddns.net | Flask, Stockfish, SQLite | Jetson Nano | live |
| [skyrun](repos/skyrun.yml) | — | PHP, MySQL | Goneo | live |

## Statische Websites

| Projekt | Domains | Stack | Hosting | Status |
|---------|---------|-------|---------|--------|
| [new_world](repos/new_world.yml) | andrehinz.de, nixblick.de, hinjas.de, gudeai.de, wir-on-air.de | HTML/CSS/JS | Goneo | live |
| [linksblatt](repos/linksblatt.yml) | — | HTML, W3.CSS, Bash | Goneo | live |

## Bots & Automation

| Projekt | Typ | Stack | Hosting | Status |
|---------|-----|-------|---------|--------|
| [clawd](repos/clawd.yml) | Telegram-Bot | Python, Bash, Ollama/Claude | Jetson Nano | live |

## Infrastruktur

| Projekt | Ziel | Stack | Status |
|---------|------|-------|--------|
| [aigude_on_rocky](repos/aigude_on_rocky.yml) | AIGude-Server | Ansible, Rocky 9, OpenWebUI | live |
| [HOMELAB](repos/homelab.yml) | Homelab komplett | Ansible, N8N, Docker, Portainer | live |

## Sammlungen & Shared

| Projekt | Zweck | Status |
|---------|-------|--------|
| [shared](repos/shared.yml) | Analytics, Datenschutz, Impressum für alle Web-Projekte | live |
| [linuxguru](repos/linuxguru.yml) | Linux-Admin Wissensbasis & Skripte | live |
| [files](repos/files.yml) | Geteilte Dateien, Skripte, Configs | live |

## Abhängigkeiten

```
shared ←── bvkfrankfurt, skyrun, new_world, todomanager
                         (Analytics, Datenschutz, Impressum)

nix.stack ←── alle Repos (Harness: Skills, Hooks, Rules)
    ├── online/  → Rocky Notebook (Git + Internet)
    └── offline/ → Ansible Controller (kein Git/Internet)
```

## Hosting-Übersicht

| Hoster | Projekte | Besonderheit |
|--------|----------|-------------|
| **Goneo** | bvkfrankfurt, skyrun, new_world, linksblatt, todomanager | SFTP-Deploy, Deutschland/DSGVO |
| **Jetson Nano** | ChessAnimator, clawd | Homelab, GPU |
| **Rocky Server** | aigude_on_rocky | SSH-only, gehärtet |
| **Homelab Mix** | HOMELAB | n8n0, wyse, nano, OpenWrt |

## Kontakt

- **Owner:** André Hinz
- **Mail:** mail@andrehinz.de
- **Telegram:** André

## Scope

- Nur eigene nixblick-Projekte
- Job-Repos (`job/`) und Archive sind **out of scope**
- Bei Fragen zu Job-Repos nur auf explizite Nachfrage
