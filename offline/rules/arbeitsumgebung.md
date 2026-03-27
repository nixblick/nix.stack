# Arbeitsumgebung und Kontext

## Wer
- Ansible-Administrator, verwaltet Linux- und Windows-Infrastruktur
- Fokus: Sicherheit, Haertung, Compliance (CCE/STIG), Automatisierung

## Infrastruktur
- **Zielplattformen:** AlmaLinux 9, Rocky Linux 9, Windows Server
- **Ansible-Controller:** lms006 (Offline-Umgebung, kein Internet)
- **Arbeitsverzeichnis hier:** `/mnt/hgfs/llm/home/ansible` — lokale Kopie, NICHT das produktive Repo
- **Inventories:** prod, preprod, stable, wachmonitore
- **34 Rollen** nach Namensschema: `bereich.funktion` (z.B. `system.daemon.sshd`, `app.elastic-agent`)
- **Playbooks** thematisch organisiert (alma.linux.9, linux.security.operations, vmware.vcenter.operations, ...)

## Wichtige Einschraenkungen
- **Kein Git hier:** Keine git-Befehle ausfuehren. User kopiert Aenderungen manuell zum Push
- **Kein Internet auf Zielhost:** Pakete muessen lokal verfuegbar sein oder vorab bereitgestellt werden
- **Kein --vault-password-file:** Nie in Befehlen oder Docs verwenden. Ist anders konfiguriert
- **Deployment:** User deployed selbst — nur Code schreiben, nicht ausfuehren

## Arbeitsweise
- Aenderungen an Rollen: immer CHANGELOG.md aktualisieren
- Am Ende jeder Session: alle geaenderten Repos/Rollen/Playbooks auflisten
- Nach jeder Aenderung: Kritiker-Review (Sicherheit, Stabilitaet, Funktionalitaet)
- host_vars sind die Basis, Vorschlaege fuer group_vars willkommen
- Sprache: Deutsch fuer Kommunikation, Englisch fuer Task-Namen und Code
