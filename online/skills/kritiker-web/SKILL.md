---
name: kritiker-web
description: Prueft Webprojekte auf Sicherheit (OWASP Top 10), Performance, Accessibility und Code-Qualitaet
user-invocable: true
argument-hint: [datei-oder-verzeichnis]
---

# Web-Kritiker-Modus

Du bist jetzt im **Web-Kritiker-Modus**. Deine Aufgabe: den Code in `$ARGUMENTS` schonungslos aber konstruktiv pruefen.

Falls kein Argument angegeben: pruefe alle kuerzlich geaenderten Dateien (`git diff --name-only HEAD~1` oder das gesamte Projekt).

## Pruefbereiche

### 1. Sicherheit (OWASP Top 10 + Web-spezifisch)

**Injection:**
- SQL Injection (parameterisierte Queries?)
- Command Injection (Shell-Befehle mit User-Input?)
- XSS — Reflected, Stored, DOM-basiert (Output-Encoding?)
- Template Injection (SSTI)
- Path Traversal (../../../etc/passwd)

**Authentifizierung & Autorisierung:**
- Fehlende Auth-Checks auf Endpunkten
- Session-Management (sichere Cookies? HttpOnly? Secure? SameSite?)
- CSRF-Schutz vorhanden?
- JWT-Validierung korrekt? (Algorithmus, Expiry, Signatur)
- Rate Limiting auf Login/API-Endpunkten?

**Konfiguration & Secrets:**
- Secrets im Code (.env-Werte, API-Keys, Passwoerter hardcodiert?)
- CORS zu permissiv? (`Access-Control-Allow-Origin: *`)
- CSP-Header gesetzt und sinnvoll?
- HTTPS erzwungen?
- Security-Header: X-Frame-Options, X-Content-Type-Options, Referrer-Policy
- Debug-Modus in Produktion aktiv?

**Datenintegrierung:**
- User-Input validiert? (Server-seitig, nicht nur Client)
- File-Upload-Validierung (Typ, Groesse, Inhalt)?
- Sensitive Daten in Logs?
- Datenbank-Queries auf Mass Assignment geprueft?

### 2. Performance

- Unnoetige Reflows/Repaints im DOM?
- Bilder optimiert? (WebP, lazy loading, srcset)
- Bundle-Groesse auffaellig? (Tree-shaking, Code-Splitting)
- N+1 Queries in API/DB-Calls?
- Caching-Strategie vorhanden? (HTTP-Cache, Service Worker)
- Fonts: font-display: swap? Subset?

### 3. Accessibility (a11y)

- Semantisches HTML? (nav, main, article, button statt div)
- Alt-Texte auf Bildern?
- Keyboard-Navigation moeglich? (Tab-Order, Focus-Styles)
- Kontrastverhältnisse ausreichend? (WCAG AA: 4.5:1)
- aria-Labels wo noetig?
- Formulare: Labels mit for/id verknuepft?

### 4. Code-Qualitaet

- Logikfehler, Race Conditions
- Error-Handling (try/catch, HTTP-Fehler-Responses)
- Memory Leaks (Event-Listener nicht entfernt, Subscriptions offen)
- API-Responses: Konsistentes Format? Sinnvolle HTTP-Status-Codes?
- Responsive Design: Funktioniert auf Mobile?

## Vorgehen

1. Lies alle relevanten Dateien (HTML, CSS, JS/TS, Python, PHP, Config)
2. Pruefe jeden Bereich systematisch
3. Falls ein Webserver laeuft: empfehle `/browse` fuer visuellen Check

## Ausgabeformat

**Kritische Fehler** (muss gefixt werden):
- Datei:Zeile — Beschreibung — Empfehlung

**Warnungen** (sollte gefixt werden):
- Datei:Zeile — Beschreibung — Empfehlung

**Hinweise** (nice-to-have):
- Beschreibung

**Fazit:** Kurze Gesamtbewertung in 1-2 Saetzen.

## Regeln

- Nur echte Probleme, keine Kosmetik
- Max 5 Punkte pro Kategorie — die wichtigsten zuerst
- Leere Kategorien weglassen
- Falls TODO.md existiert: Kritische Fehler dort unter `## Sicherheit` eintragen
- Sprache: Deutsch fuer Beschreibung, Englisch fuer Code-Referenzen
