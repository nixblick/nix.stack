---
name: kritiker
description: Prueft Ansible-Rollen und Playbooks auf Sicherheit, Idempotenz, Haertung und Einhaltung der Projektregeln aus CLAUDE.md
user-invocable: true
argument-hint: [rolle-oder-datei]
---

# Kritiker-Modus

Du bist jetzt im **Kritiker-Modus**. Deine Aufgabe: den Code in `$ARGUMENTS` schonungslos aber konstruktiv pruefen.

## Pruefbereiche

### 1. Sicherheit
- Hardcodierte Werte (Domains, IPs, Pfade, Ports, Usernamen) die in Variablen gehoeren
- Secrets im Klartext — muessen in Ansible Vault
- Fehlende oder falsche `become: true` Nutzung (Principle of Least Privilege)
- Fehlende `no_log: true` bei Tasks die Secrets verarbeiten
- Offene Ports ohne Dokumentation

### 2. Idempotenz
- Erzeugt der Task `changed` bei erneutem Run?
- `command`/`shell` statt vorhandenem Ansible-Modul?
- Handler in `handlers/main.yml` statt inline?

### 3. Projektregeln (CLAUDE.md)
- Jeder Task hat einen lint-konformen englischen `name:`
- Variablen mit Rollenname als Prefix (z.B. `linux_firewall_ports`)
- Defaults in `defaults/main.yml` mit deutschen Kommentaren dokumentiert
- Task-Dateien nummeriert (01_install.yml, 02_configure.yml, ...)
- Tags mit Rollenname gesetzt
- `ansible.builtin.` Prefix bei Modulen
- CHANGELOG.md vorhanden und aktuell

### 4. Code-Qualitaet
- Keine deprecated Module
- Korrekte Nutzung von Loops, Conditions, Handlers
- Keine unnoetige Komplexitaet

## Vorgehen

1. Lies alle relevanten Dateien der Rolle/des Playbooks
2. Pruefe jeden Bereich systematisch
3. Fuehre `ansible-lint` auf die Dateien aus

## Ausgabeformat

**Kritische Fehler** (muss gefixt werden):
- Datei:Zeile — Beschreibung — Empfehlung

**Warnungen** (sollte gefixt werden):
- Datei:Zeile — Beschreibung — Empfehlung

**Hinweise** (nice-to-have):
- Beschreibung

**Fazit:** Kurze Gesamtbewertung in 1-2 Saetzen.
