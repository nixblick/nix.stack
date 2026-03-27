---
name: site-monitor
description: Prueft alle nixblick Live-Sites auf Erreichbarkeit, SSL, Performance, Security-Header und Console-Errors
user-invocable: true
argument-hint: [url oder "alle"]
---

# Site Monitor

Prueft nixblick Live-Sites auf Gesundheit. Nutzt /browse fuer tiefergehende Checks.

## Bekannte Sites

Pruefe alle bekannten Sites (oder nur die per Argument angegebene):

| Site | URL | Typ |
|------|-----|-----|
| BVK Frankfurt | https://bvkfrankfurt.de | PHP/Webseite |
| Leben | https://leben.nixblick.de | PHP-App |
| Todomanager | (URL falls deployed) | Web-App |
| ChessAnimator | (URL falls deployed) | Web-App |
| Skyrun | (URL falls deployed) | Web-App |

Falls eine URL nicht bekannt ist: ueberspringen und als "URL unbekannt" melden.

## Checks pro Site

### 1. Erreichbarkeit (curl)
```bash
curl -sI -o /dev/null -w "%{http_code} %{time_total}s" <URL>
```
- HTTP-Statuscode (200 = ok, alles andere = Problem)
- Response-Time (Warnung wenn > 3s)
- Redirect-Chain pruefen (zu viele Redirects?)

### 2. SSL-Zertifikat
```bash
echo | openssl s_client -servername <domain> -connect <domain>:443 2>/dev/null | openssl x509 -noout -dates -subject
```
- Gueltig bis wann?
- Warnung wenn < 14 Tage bis Ablauf
- Aussteller pruefen (Let's Encrypt etc.)

### 3. Security-Header
Pruefe ob folgende Header gesetzt sind:
- `X-Frame-Options` (Clickjacking-Schutz)
- `X-Content-Type-Options: nosniff`
- `Content-Security-Policy` (CSP)
- `Strict-Transport-Security` (HSTS)
- `Referrer-Policy`
- `Permissions-Policy`

### 4. Browser-Check (mit /browse falls verfuegbar)
Falls der Browse-Daemon laeuft:
- Seite laden, Screenshot machen
- Console-Errors pruefen
- Broken Images / Broken Links?
- Mixed Content (HTTP auf HTTPS-Seite)?

### 5. Performance
- Time to First Byte (TTFB)
- Seitengroesse (HTML + Ressourcen)
- Komprimierung aktiv? (Content-Encoding: gzip/br)

## Ausgabeformat

### Site Monitor Report — [Datum]

| Site | Status | SSL | TTFB | Headers | Score |
|------|--------|-----|------|---------|-------|
| bvkfrankfurt.de | 200 OK | bis 2026-06-15 | 0.4s | 4/6 | 8/10 |
| ... | ... | ... | ... | ... | ... |

**Probleme gefunden:**
- Site: Problem + Empfehlung + Dringlichkeit

**Security-Header Empfehlung:**
- Site: Fehlende Header + wie setzen

**Alles ok bei:**
- Sites die keine Probleme haben

Falls Probleme kritisch sind: In TODO.md des jeweiligen Repos eintragen.
