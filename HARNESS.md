# Agent Harness — Theorie und Praxis

Ein Agent Harness ist das "KI-Betriebssystem" um ein LLM herum. Es besteht aus Regeln, Kontextdateien, Skills, Hooks und Konfiguration, die die reine Intelligenz des Modells (die "CPU") ergaenzen.

## 1. Die 5 Grundprinzipien

* **Sichtbarkeit:** Was der Agent nicht sehen kann, existiert fuer ihn nicht. Alles Relevante muss als Datei im Arbeitsbereich liegen.
* **Faehigkeiten statt Prompts:** Wenn der Agent scheitert, fehlt ihm ein Tool, eine Regel oder eine Referenzdatei — nicht ein besserer Prompt.
* **Mechanische Durchsetzung:** Hooks und Linter die automatisch fehlschlagen > theoretische Instruktionen die ignoriert werden koennen.
* **Augen geben:** Visuelles Feedback (Browser, Screenshots, Logs) macht den Agenten effektiver.
* **Karte, kein Handbuch:** Kurze architektonische Uebersicht statt hundertseitigem Dokument.

## 2. Bausteine

### Hooks (Mechanische Durchsetzung)

| Typ | Wann | Zweck |
|-----|------|-------|
| PreToolUse | Vor einem Tool-Aufruf | Gefaehrliche Befehle blockieren (Exit 2) |
| PostToolUse | Nach einem Tool-Aufruf | Automatisches Linting, Code-Review |
| Notification | Wenn Claude wartet | Desktop-Benachrichtigung |

**Warum Hooks statt Skills?**
- Hooks laufen deterministisch, verbrauchen keine Tokens
- Hooks koennen Befehle blockieren bevor sie ausgefuehrt werden
- Hooks sind unsichtbar wenn alles ok ist — null Overhead

### Skills (Wiederverwendbare Workflows)

Skills sind Markdown-Dateien die einen kompletten Workflow beschreiben. Aufruf mit `/skillname`.

**Gute Skills sind:**
- Domainspezifisch (Ansible-Kritiker > generischer Code-Reviewer)
- Enthalten Referenzmaterial (Beispiel-Code, Templates)
- Fuehren zu konkretem Output (nicht nur Analyse)
- Wenige, aber gut funktionierende (5 > 40 ungenutzte)

### Rules (Automatischer Kontext)

Rules werden bei jedem Session-Start geladen. Ideal fuer:
- Wer der User ist und wie er arbeitet
- Technische Einschraenkungen der Umgebung
- Wiederkehrende Anweisungen die sonst jede Session neu erklaert werden muessen

### Memory (Persistentes Gedaechtnis)

Memory-Dateien ueberleben Sessions und speichern:
- User-Profil und Praeferenzen
- Feedback-Regeln (was zu tun/lassen ist)
- Projekt-Kontext der nicht im Code steht

## 3. Online vs. Offline Harness

### Online (mit Internet, Git, gstack)

```
Schutz-Hook (PreToolUse)
    ↓
gstack Skills (28+ generische Workflows)
    ↓
Code-Review Hook (PostToolUse auf git commit)
    ↓
Session-Kontext (Rules)
    ↓
Memory (persistente Erinnerungen)
```

**Vorteile:** Browser-QA, Ship-Pipeline, Security-Audit, voller Git-Workflow
**Schutz durch:** PreToolUse-Hook blockiert vor allen anderen Aktionen

### Offline (kein Internet, kein Git)

```
Schutz-Hook (PreToolUse)
    ↓
ansible-lint Hook (PostToolUse)
    ↓
Domainspezifische Skills (/kritiker, /rolle-erstellen)
    ↓
Session-Kontext (Rules)
    ↓
Memory (persistente Erinnerungen)
```

**Vorteile:** Massgeschneidert, kein Token-Overhead durch irrelevante Skills
**Schutz durch:** PreToolUse-Hook + ansible-lint als automatische Qualitaetssicherung

## 4. Wichtigstes Mindset

**Verkompliziere es nicht.** Der groesste Fehler ist tagelang an einem komplexen Harness zu bauen. Fuenf essentielle, gut funktionierende Teile sind besser als 40 unuebersichtliche.

Das Harness waechst organisch:
1. Problem tritt auf → Hook oder Regel erstellen
2. Wiederholte Arbeit → Skill daraus machen
3. Kontext fehlt jede Session → Rule schreiben
4. Wissen geht verloren → Memory speichern

Nie auf Vorrat bauen. Immer aus echtem Bedarf.
