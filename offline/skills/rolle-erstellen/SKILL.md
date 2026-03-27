---
name: rolle-erstellen
description: Erstellt eine neue Ansible-Rolle mit vollstaendiger Verzeichnisstruktur nach Projektstandard (nummerierte Tasks, defaults, handlers, CHANGELOG)
user-invocable: true
argument-hint: <rollenname> <kurzbeschreibung>
---

# Neue Ansible-Rolle erstellen

Erstelle eine neue Ansible-Rolle unter `roles/$0` mit folgender Struktur und Konventionen.

## Verzeichnisstruktur

```
roles/$0/
  defaults/main.yml
  handlers/main.yml
  tasks/main.yml
  tasks/01_install.yml
  tasks/02_configure.yml
  tasks/03_verify.yml
  CHANGELOG.md
```

Falls die Rolle keinen Install- oder Verify-Schritt braucht, verwende stattdessen:

```
roles/$0/
  defaults/main.yml
  handlers/main.yml
  tasks/main.yml
  tasks/present.yml
  tasks/absent.yml
  CHANGELOG.md
```

## Konventionen

### Variablen
- Alle Variablen mit Rollenname als Prefix, Punkte durch Unterstriche ersetzen
- Beispiel: Rolle `system.daemon.sshd` -> Variable `system_daemon_sshd_port`
- Defaults in `defaults/main.yml` mit **deutschen Kommentaren** dokumentieren
- Nichts hardcoden: Domains, IPs, Pfade, Ports, Usernamen -> Variablen

### Tasks
- Jeder Task hat einen lint-konformen **englischen** `name:`
- `become: true` nur pro Task/Block, nie global
- Tags: Rollenname als Tag, z.B. `tags: [$0]`
- `ansible.builtin.` Prefix bei allen Modulen
- Kein `command`/`shell` wenn ein Ansible-Modul existiert
- `no_log: true` bei Tasks die Secrets verarbeiten
- `changed_when` bei command/shell Tasks

### tasks/main.yml
- Kurzer Kopfkommentar was die Rolle tut
- Inkludiert Teildateien per `ansible.builtin.include_tasks`
- Verwendet `state` Variable (default: `present`) zur Steuerung

### handlers/main.yml
- Handler mit `listen:` statt nur `notify:` Name
- `become: true` nur wenn noetig

### CHANGELOG.md
- Erster Eintrag mit heutigem Datum und "Initiale Erstellung"

## Vorgehen

1. Frage nach wenn die Kurzbeschreibung (`$1`) fehlt oder unklar ist
2. Erstelle alle Dateien
3. Fuehre den Kritiker-Skill auf die neue Rolle aus
4. Zeige eine Zusammenfassung der erstellten Dateien

---

## Referenz: Beispiel einer vollstaendigen Rolle

Nachfolgend eine idealisierte Beispiel-Rolle `system.daemon.beispiel` als Vorlage.
Orientiere dich an diesem Muster fuer Stil, Struktur und Konventionen.

### defaults/main.yml
```yaml
---

# Zustand der Rolle: present = installieren/konfigurieren, absent = entfernen
# Erlaubte Werte: present, absent
system_daemon_beispiel_state: present

# Port auf dem der Dienst lauscht
system_daemon_beispiel_port: 8080

# Konfigurationsdatei-Pfad
system_daemon_beispiel_config_path: "/etc/beispiel/beispiel.conf"

# Paketname(n) die installiert werden sollen
system_daemon_beispiel_packages:
  - beispiel
  - beispiel-utils

# Dienst aktivieren und starten
system_daemon_beispiel_service_enabled: true
```

### tasks/main.yml
```yaml
---

# Rolle: system.daemon.beispiel
# Installiert und konfiguriert den Beispiel-Daemon oder entfernt ihn.

# WICHTIG: Dieses _delegate_to_host Pattern wird in fast allen Rollen verwendet.
# Es prueft per DNS ob der Zielhost schon einen A-Record hat (z.B. bei frisch
# deployten VMs) und entscheidet ob per FQDN oder IP-Adresse delegiert wird.
# Diesen Block uebernehmen wenn die Rolle auf remote Hosts ausgefuehrt wird.
- name: "Gather domain name service information."
  ansible.builtin.set_fact:
    _delegate_to_host: >-
      {{
        ( lookup ( 'community.general.dig',
          '{{ host_os_configuration.host_name }}.{{ datacenter_active_directory.domain_realm }}.' ) | trim == 'NXDOMAIN'
        ) | ternary
          (
            ( host_os_configuration.network_interfaces[lookup('ansible.utils.index_of', host_os_configuration.network_interfaces, 'eq',
              host_os_ad_membership.dynamic_dns_interface, 'name')].ipaddr | ansible.utils.ipaddr ),
            ( host_os_configuration.host_name + "." + datacenter_active_directory.domain_realm )
          )
      }}
  delegate_to: localhost

- name: "Include tasks for desired state."
  ansible.builtin.include_tasks:
    file: "{{ system_daemon_beispiel_state }}.yml"
  tags:
    - system.daemon.beispiel
```

**Hinweis zum delegate_to Pattern:** Wenn die Rolle `_delegate_to_host` nutzt, muessen
alle Tasks und Handler in present.yml, absent.yml und handlers/main.yml das folgende
`delegate_to` verwenden:
```yaml
  delegate_to: >-
    {{ ( _delegate_to_host | ansible.utils.ipaddr ) | ternary
      ( ( _delegate_to_host | ansible.utils.ipaddr ),
        ( _delegate_to_host )
      )
    }}
```

### tasks/present.yml
```yaml
---

# Installiert und konfiguriert den Beispiel-Daemon.

- name: "Install required packages for beispiel daemon."
  ansible.builtin.dnf:
    name: "{{ system_daemon_beispiel_packages }}"
    state: present
  become: true
  notify:
    - beispiel_daemon_enable
  tags:
    - system.daemon.beispiel

- name: "Deploy configuration file for beispiel daemon."
  ansible.builtin.template:
    src: "beispiel.conf.j2"
    dest: "{{ system_daemon_beispiel_config_path }}"
    owner: root
    group: root
    mode: "0644"
  become: true
  notify:
    - beispiel_daemon_restart
  tags:
    - system.daemon.beispiel

- name: "Flush handlers to apply changes immediately."
  ansible.builtin.meta:
    flush_handlers
  tags:
    - system.daemon.beispiel
```

### tasks/absent.yml
```yaml
---

# Entfernt den Beispiel-Daemon und seine Konfiguration.

- name: "Gather facts about installed services."
  ansible.builtin.service_facts:
  tags:
    - system.daemon.beispiel

- name: "Stop and disable beispiel daemon."
  ansible.builtin.systemd:
    name: beispiel.service
    state: stopped
    enabled: false
  become: true
  when:
    - "'beispiel.service' in services"
  tags:
    - system.daemon.beispiel

- name: "Remove configuration file for beispiel daemon."
  ansible.builtin.file:
    path: "{{ system_daemon_beispiel_config_path }}"
    state: absent
  become: true
  tags:
    - system.daemon.beispiel

- name: "Remove beispiel packages."
  ansible.builtin.dnf:
    name: "{{ system_daemon_beispiel_packages }}"
    state: absent
  become: true
  tags:
    - system.daemon.beispiel
```

### handlers/main.yml
```yaml
---

- name: "Enable and start beispiel daemon."
  ansible.builtin.systemd:
    name: beispiel.service
    state: started
    enabled: true
  listen: beispiel_daemon_enable
  become: true

- name: "Restart beispiel daemon to apply configuration changes."
  ansible.builtin.systemd:
    name: beispiel.service
    state: restarted
  listen: beispiel_daemon_restart
  become: true
```

### CHANGELOG.md
```markdown
# Changelog — system.daemon.beispiel

## 2026-03-27
- Initiale Erstellung der Rolle
- Betroffene Dateien: alle
```
