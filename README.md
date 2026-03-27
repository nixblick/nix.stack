# nix.stack

Claude Code Agent Harness fuer nixblick-Projekte — in zwei Varianten:

| Variante | Umgebung | Git | Internet | Browser |
|----------|----------|-----|----------|---------|
| **online/** | Rocky-Notebook, Webserver | Ja | Ja | gstack |
| **offline/** | Ansible-Controller (VM) | Nein | Nein | Nein |

## Was ist ein Agent Harness?

Ein Agent Harness ist das "Betriebssystem" um Claude Code herum: Hooks, Skills, Rules und Konfiguration, die den Agenten sicherer, konsistenter und produktiver machen.

**Prinzipien:**
- Mechanische Durchsetzung statt Dokumentation (Hooks > Prompts)
- Schutz vor destruktiven Aktionen (PreToolUse-Hooks)
- Domainspezifische Skills statt generische Prompts
- Session-Kontext automatisch laden (Rules)
- So wenig wie noetig, so viel wie sinnvoll

## Schnellstart

### Online (Rocky-Notebook mit gstack)

```bash
cd ~/GitHub/nixblick/nix.stack
./online/setup.sh
```

Installiert:
- **Schutz-Hook** — blockiert `rm -rf` auf GitHub/, .claude/, .ssh/, .env-Leaks, force-push, reset --hard
- **Notification-Hook** — Desktop-Benachrichtigung wenn Claude auf Eingabe wartet
- **Web-Kritiker Skill** (`/kritiker-web`) — OWASP Top 10, XSS, Auth, CSP, Performance, a11y
- **Rules** — Session-Kontext (wer, was, wie)
- **tmux.conf** — optional nach ~/.tmux.conf symlinken
- Arbeitet zusammen mit gstack (28+ Skills bleiben aktiv)

### Offline (Ansible-Controller)

```bash
cd /pfad/zu/nix.stack
./offline/setup.sh /mnt/hgfs/llm/home/ansible
```

Installiert:
- **Schutz-Hook** — blockiert `rm -rf` auf roles/, playbooks/, inventories/
- **ansible-lint Hook** — automatisches Linting nach Edit/Write auf YAML
- **Skills:** `/kritiker` (Code-Review), `/rolle-erstellen` (Scaffold)
- **Rules** — Offline-Kontext (kein Git, kein Internet, kein vault-password-file)
- **.ansible-lint** — Projekt-weite Lint-Konfiguration

## Verzeichnisstruktur

```
nix.stack/
├── online/                     # Fuer Maschinen mit Internet + Git
│   ├── hooks/schutz.sh         # PreToolUse: Destruktions-Schutz
│   ├── skills/kritiker-web/    # /kritiker-web — Web-Security + Quality Review
│   ├── rules/arbeitsumgebung.md
│   ├── settings-snippet.json   # Hook-Registrierung (Referenz)
│   └── setup.sh                # Ein-Klick-Installation
├── offline/                    # Fuer Maschinen ohne Internet/Git
│   ├── hooks/
│   │   ├── schutz.sh           # PreToolUse: Ansible-spezifischer Schutz
│   │   └── ansible-lint.sh     # PostToolUse: Lint nach Edit/Write
│   ├── skills/
│   │   ├── kritiker/SKILL.md   # /kritiker — Ansible Code-Review
│   │   └── rolle-erstellen/SKILL.md  # /rolle-erstellen — Rollen-Scaffold
│   ├── rules/arbeitsumgebung.md
│   ├── ansible-lint.example    # .ansible-lint Template
│   ├── CLAUDE.md.example       # Projektregeln Template
│   ├── settings-snippet.json   # Hook-Registrierung (Referenz)
│   └── setup.sh                # Ein-Klick-Installation
├── shared/                     # Gemeinsame Bausteine
│   ├── hooks/schutz.sh         # Konfigurierbarer Basis-Schutz-Hook
│   ├── hooks/notification.sh   # Desktop-Benachrichtigung (Linux + macOS)
│   └── tmux.conf               # tmux-Konfiguration (optional)
├── HARNESS.md                  # Theorie + Dokumentation des Harness-Ansatzes
├── CHANGELOG.md
└── README.md
```

## Schutz-Hook im Detail

Der Schutz-Hook laeuft als PreToolUse-Hook **vor** jedem Bash-Befehl und blockiert:

| Kategorie | Was wird blockiert |
|---|---|
| Dateisystem | `rm -rf` auf Projekt-, Home-, .claude-, .ssh-Verzeichnisse |
| Secrets | `cat` auf .env-Dateien und SSH-Keys |
| Git | `push --force`, `reset --hard`, `branch -d/-D` |
| System | `systemctl stop/disable` auf sshd, firewalld, NetworkManager |

Blockierte Befehle geben Exit-Code 2 zurueck — der Befehl wird **nicht** ausgefuehrt.

## Zusammenspiel mit gstack

nix.stack **ersetzt** gstack nicht — es **ergaenzt** es:

- gstack liefert: QA, Browser, Ship, Review, Security-Audit, Design
- nix.stack liefert: Schutz-Hooks, Session-Kontext, domainspezifische Skills

Die PreToolUse-Hooks von nix.stack laufen **vor** allen gstack-Skills und schuetzen so auch gstack-Operationen.

## Eigene Anpassungen

### Schutz-Hook erweitern

Neue Regeln in `hooks/schutz.sh` einfuegen. Format:

```bash
if echo "$command" | grep -qP 'MUSTER'; then
  echo "BLOCKIERT: Beschreibung: $command" >&2
  exit 2
fi
```

### Shared-Hook mit eigenen Pfaden

Der Hook in `shared/hooks/schutz.sh` ist konfigurierbar:

```bash
export NIX_STACK_PROTECTED_PATHS="/home/user/projects,/var/www"
```

### Neue Skills erstellen

Skill-Datei anlegen: `.claude/skills/<name>/SKILL.md` mit Frontmatter:

```yaml
---
name: skill-name
description: Was der Skill tut
user-invocable: true
argument-hint: <argument>
---
```
