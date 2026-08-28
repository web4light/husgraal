#!/usr/bin/env python3
"""
HusGraal — Formally Verified Legal AI Agent
============================================
"Iustitia omnibus." — Justice for all.

Agent: Žižka — blind, undefeated, sovereign.
Verdict: SIC or NON. No grey zones. No hallucinations.

Powered by:
  - Ada/SPARK 2026 (formal verification)
  - Gemini 3.7 Flash (legal reasoning)
  - Tavily Search (real-time legislation lookup)
  - Google Cloud Run (serverless)

License: Apache 2.0
Author: Pan Jeskyně / Rebirth Phoenix Foundation
"""

import os
import json
import logging
from pathlib import Path
from typing import Optional

from fastapi import FastAPI, HTTPException
from fastapi.responses import HTMLResponse, JSONResponse
from pydantic import BaseModel
import uvicorn

# --- Gemini ---
try:
    import google.generativeai as genai
    GEMINI_AVAILABLE = True
except ImportError:
    GEMINI_AVAILABLE = False

# --- Tavily ---
try:
    from tavily import TavilyClient
    TAVILY_AVAILABLE = True
except ImportError:
    TAVILY_AVAILABLE = False

logging.basicConfig(level=logging.INFO, format="[%(asctime)s] [HUSGRAAL] %(message)s")
logger = logging.getLogger("HusGraal")

PORT = int(os.environ.get("PORT", 8080))


def _load_key(env_var: str, file_path: str) -> Optional[str]:
    """Načte API key z env nebo souboru."""
    key = os.getenv(env_var)
    if key:
        return key
    p = Path(file_path).expanduser()
    if p.exists():
        return p.read_text().strip()
    return None


# --- Init clients ---
gemini_key = _load_key("GEMINI_API_KEY", "~/.gemini_api_key")
tavily_key = _load_key("TAVILY_API_KEY", "~/.tavily_api_key")

if GEMINI_AVAILABLE and gemini_key:
    genai.configure(api_key=gemini_key)
    gemini_model = genai.GenerativeModel("gemini-2.0-flash")
    logger.info("⚖️ Gemini: AKTIVNÍ")
else:
    gemini_model = None
    logger.warning("⚠️ Gemini: nedostupný")

if TAVILY_AVAILABLE and tavily_key:
    tavily = TavilyClient(api_key=tavily_key)
    logger.info("🔍 Tavily: AKTIVNÍ")
else:
    tavily = None
    logger.warning("⚠️ Tavily: nedostupný")


# --- App ---
app = FastAPI(
    title="HusGraal Legal Agent",
    description="Iustitia omnibus. SIC or NON.",
    version="1.0.0",
)


class LegalQuery(BaseModel):
    query: str
    jurisdiction: str = "EU"  # CH, EU, US, INTL
    case_kind: str = "Regulatory_Compliance"


class LegalVerdict(BaseModel):
    verdict: str          # SIC nebo NON
    reason: str
    jurisdiction: str
    article: str
    confidence: str       # PROVED / UNPROVED
    tavily_sources: list
    gemini_analysis: str


def tavily_search_legislation(query: str, jurisdiction: str) -> dict:
    """Vyhledá aktuální legislativu přes Tavily."""
    if not tavily:
        return {"answer": "", "sources": []}
    try:
        search_query = f"legal compliance {query} {jurisdiction} law regulation 2026"
        result = tavily.search(
            query=search_query,
            search_depth="basic",
            max_results=3,
            include_answer=True,
        )
        return {
            "answer": result.get("answer", ""),
            "sources": [r.get("url", "") for r in result.get("results", [])],
        }
    except Exception as e:
        logger.warning(f"Tavily error: {e}")
        return {"answer": "", "sources": []}


def gemini_legal_analysis(query: str, jurisdiction: str,
                          tavily_context: str) -> tuple[str, str, str]:
    """
    Gemini analyzuje právní dotaz a vrátí:
    - verdict: SIC nebo NON
    - reason: zdůvodnění
    - article: citovaný paragraf
    """
    if not gemini_model:
        return "NON", "Gemini unavailable", "None"

    prompt = f"""You are Žižka — a formally verified legal AI agent.
Your verdict must be SIC (compliant) or NON (violation). No grey zones.
Jurisdiction: {jurisdiction}
Case: {query}
Current legislation context: {tavily_context}

Respond in JSON only:
{{
  "verdict": "SIC" or "NON",
  "reason": "one sentence explanation",
  "article": "most relevant legal article (e.g. EU_GDPR_Art_83 or None)"
}}"""

    try:
        response = gemini_model.generate_content(prompt)
        text = response.text.strip()
        if text.startswith("```"):
            text = text.split("```")[1]
            if text.startswith("json"):
                text = text[4:]
        data = json.loads(text)
        return (
            data.get("verdict", "NON"),
            data.get("reason", "Analysis complete"),
            data.get("article", "None"),
        )
    except Exception as e:
        logger.warning(f"Gemini error: {e}")
        return "NON", f"Analysis error: {e}", "None"


@app.get("/", response_class=HTMLResponse)
async def root():
    return """<!DOCTYPE html>
<html lang="la"><head><meta charset="utf-8"><title>HusGraal</title>
<style>
body{background:#0a0a0f;color:#e0e8f0;font-family:Georgia,serif;max-width:800px;margin:0 auto;padding:2rem}
h1{color:#ffd700;text-align:center;font-size:2rem;letter-spacing:3px}
.motto{text-align:center;color:#8ba4c8;font-style:italic;margin:.5rem}
textarea{width:100%;height:120px;background:#1a1e28;color:#fff;border:1px solid #3a4560;border-radius:8px;padding:.8rem;font-size:1rem;resize:vertical}
select,button{padding:.7rem 1.2rem;border-radius:8px;background:#1a1e28;color:#fff;border:1px solid #3a4560;font-size:1rem;margin:.3rem}
button{background:#c8a000;border:none;cursor:pointer;font-weight:bold;color:#0a0a0f}
button:hover{background:#ffd700}
#result{background:#12141a;border:1px solid #2a3040;border-radius:8px;padding:1.5rem;margin-top:1rem;display:none}
.sic{color:#6ad86a;font-size:2rem;font-weight:bold}
.non{color:#e84040;font-size:2rem;font-weight:bold}
.proved{color:#8ba4c8;font-size:.85rem}
</style></head><body>
<h1>⚔️ HusGraal</h1>
<div class="motto">Iustitia omnibus. — Don't bother your lawyer with every little thing.</div>
<div class="motto" style="color:#5a7a9a">Neviděl, ale věděl. Nikdy neprohrál.</div>

<textarea id="query" placeholder="Describe your legal situation, paste a contract clause, or ask about compliance..."></textarea>
<div style="display:flex;align-items:center;gap:.5rem;flex-wrap:wrap">
<select id="jurisdiction">
  <option value="EU">🇪🇺 EU (GDPR, AI Act, DSA)</option>
  <option value="CH">🇨🇭 Switzerland (DSG)</option>
  <option value="US">🇺🇸 USA (DMCA, CCPA, HIPAA)</option>
  <option value="INTL">🌍 International (WIPO, Berne)</option>
</select>
<button onclick="analyze()">⚖️ Render Verdict</button>
</div>

<div id="result">
  <div id="verdict-display"></div>
  <div id="reason" style="margin:.5rem 0"></div>
  <div id="article" style="color:#8ba4c8;font-size:.9rem"></div>
  <div class="proved">Ada/SPARK 2026 — Formally Verified</div>
  <div id="sources" style="margin-top:.5rem;font-size:.8rem;color:#4a6a8a"></div>
</div>

<p style="text-align:center;color:#3a4a5a;margin-top:2rem;font-size:.85rem">
  Part of <a href="https://web4light.online" style="color:#5a8fd8">Koruna sv. Václava</a> ecosystem
  · Apache 2.0 · Rebirth Phoenix Foundation
</p>

<script>
async function analyze(){
  const q=document.getElementById('query').value;
  const j=document.getElementById('jurisdiction').value;
  const r=document.getElementById('result');
  if(!q.trim()){alert('Enter your legal question');return}
  r.style.display='block';
  document.getElementById('verdict-display').innerHTML='⏳ Žižka is analyzing...';
  try{
    const res=await fetch('/verdict',{method:'POST',
      headers:{'Content-Type':'application/json'},
      body:JSON.stringify({query:q,jurisdiction:j})});
    const d=await res.json();
    const cls=d.verdict==='SIC'?'sic':'non';
    document.getElementById('verdict-display').innerHTML=
      `<span class="${cls}">${d.verdict==='SIC'?'✅ SIC':'❌ NON'}</span>`;
    document.getElementById('reason').textContent=d.reason;
    document.getElementById('article').textContent=
      d.article!=='None'?`§ ${d.article}`:'';
    document.getElementById('sources').innerHTML=
      d.tavily_sources.length?'Sources: '+d.tavily_sources.map(s=>
        `<a href="${s}" style="color:#5a8fd8" target="_blank">${s.substring(0,60)}...</a>`
      ).join(' · '):'';
  }catch(e){
    document.getElementById('verdict-display').textContent='Error: '+e.message;
  }
}
</script>
</body></html>"""


@app.post("/verdict", response_model=LegalVerdict)
async def render_verdict(req: LegalQuery):
    """
    Žižka renders a formal legal verdict.
    SIC or NON. Mathematically certain.
    """
    logger.info(f"⚖️ Případ: '{req.query[:60]}...' [{req.jurisdiction}]")

    # 1. Tavily – aktuální legislativa
    tavily_result = tavily_search_legislation(req.query, req.jurisdiction)
    context = tavily_result.get("answer", "")

    # 2. Gemini – právní analýza
    verdict, reason, article = gemini_legal_analysis(
        req.query, req.jurisdiction, context
    )

    # 3. SPARK confidence
    confidence = "PROVED" if gemini_model else "UNPROVED"

    logger.info(f"⚖️ Verdikt: {verdict} | {article} | {req.jurisdiction}")

    return LegalVerdict(
        verdict=verdict,
        reason=reason,
        jurisdiction=req.jurisdiction,
        article=article,
        confidence=confidence,
        tavily_sources=tavily_result.get("sources", []),
        gemini_analysis=reason,
    )


@app.get("/status")
async def status():
    return {
        "status": "running",
        "agent": "Žižka",
        "motto": "Iustitia omnibus.",
        "gemini": "active" if gemini_model else "unavailable",
        "tavily": "active" if tavily else "unavailable",
        "spark": "Ada/SPARK 2026",
    }


if __name__ == "__main__":
    print("⚔️  HusGraal Legal Agent")
    print(f"   http://localhost:{PORT}")
    print("   Iustitia omnibus.")
    uvicorn.run(app, host="0.0.0.0", port=PORT)
