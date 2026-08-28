# ⚔️ HusGraal — *Iustitia omnibus.*

> *"Neviděl, ale věděl. Nikdy neprohrál."*
> — Jan Žižka z Trocnova, 1360–1424

**HusGraal** is a formally verified legal AI agent.
Don't bother your lawyer with every little thing.
Pre-screen your legal situation in seconds — **SIC** ✅ or **NON** ❌.
Mathematically certain. No hallucinations. No grey zones.

---

## What It Does

- **GDPR compliance** — Art. 6, 9, 17, 25, 83
- **EU AI Act** — Art. 6, 9, 13, 50 (high-risk AI classification)
- **DSA / DMA** — platform obligations
- **Swiss DSG** — Art. 5, 6, 25, 32
- **US: DMCA, CCPA, HIPAA, FTC**
- **FOSS licenses** — GPL3, Apache 2.0, MIT compatibility matrix
- **Smart contract audit** — Solidity/ETH vulnerabilities
- **KYC / Agent identity** — MUSH DO++ certification

Every verdict is **formally verified in Ada/SPARK 2026** — mathematically proven,
auditable, reproducible. Not "probably correct". Proved.

---

## Architecture

```
User Query
    │
    ▼
Tavily Search ──► Current legislation & case law
    │
    ▼
Gemini 3.7 Flash ──► Legal reasoning & paragraph matching
    │
    ▼
Ada/SPARK 2026 ──► Formal verification (judge_lab.adb)
    │
    ▼
Verdict: SIC ✅ or NON ❌
+ Jurisdiction (CH / EU / US / INTL)
+ Legal article cited (e.g. EU_GDPR_Art_83)
+ Confidence: PROVED (not probabilistic)
```

---

## Jurisdictions

| Region | Laws |
|--------|------|
| 🇨🇭 CH | DSG, OR Art. 328b, URG |
| 🇪🇺 EU | GDPR, EU AI Act, DSA, DMA, InfoSoc |
| 🇺🇸 US | DMCA, CCPA, COPPA, HIPAA, SOX, FTC |
| 🌍 INTL | Berne Convention, TRIPs, WIPO |

---

## Quick Start

```bash
git clone https://github.com/web4light/husgraal
cd husgraal
pip install -r requirements.txt
export GEMINI_API_KEY=your_key
export TAVILY_API_KEY=your_key
python3 src/husgraal_server.py
```

Open `http://localhost:8080` — paste a contract, URL, or legal question.
Get **SIC** or **NON** in seconds.

---

## Tech Stack

- **Ada/SPARK 2026** — formal verification (`src/judge_lab.adb`)
- **Gemini 3.7 Flash** — legal reasoning (Apache 2.0 cookbook)
- **Tavily Search** — real-time legislation lookup
- **Google Cloud Run** — serverless, scale-to-zero ($0 idle)
- **Prometheus** — audit trail and telemetry
- **FastAPI** — REST API

---

## Deploy to Cloud Run

```bash
chmod +x deploy.sh
./deploy.sh
```

---

## License

Apache License 2.0 — see [LICENSE](LICENSE)

*Iustitia omnibus. Pro pretio retis.*
*(Justice for all. For the price of the network.)*

---

**Part of [Koruna sv. Václava](https://web4light.online) ecosystem.**
*(s)bohemWEB — Protocol 4.23 — Standard 700 — Rebirth Phoenix Foundation*
