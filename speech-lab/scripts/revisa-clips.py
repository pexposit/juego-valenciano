#!/usr/bin/env python3
"""Pàgina local per a revisar el text dels clips abans d'entrenar.

Per a cada clip d'un dataset de segmenta-veu.py mostra l'àudio, el text (editable)
i, com a pista, el que va entendre la transcripció del capítol sencer. Els clips
ixen en l'ordre de revisio.tsv: primer els dubtosos. Cada canvi es guarda en el
moment en `metadata.csv` (els descartats se'n lleven) i l'estat en `revisat.json`,
així que es pot tancar i continuar després.

  .venv-voz/bin/python scripts/revisa-clips.py voz-dataset/clips-doraemon voz-dataset/clips-nobita
  # i obrir http://localhost:8765

Tecles: Intro = text correcte i següent · Ctrl+Supr = descartar · Ctrl+Espai = tornar a escoltar.
Només escolta en localhost: els àudios tenen drets i no han d'eixir de la màquina.
"""
from __future__ import annotations

import argparse
import csv
import json
import mimetypes
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, unquote, urlparse

PAGINA = """<!doctype html><html lang="ca"><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>Revisió de clips</title>
<style>
:root{--bg:#fafaf8;--fg:#1d1d1b;--mut:#6b6b66;--vora:#ddddd6;--ok:#2e7d4f;--ko:#b3412f;--act:#fff;--sel:#e8f0fe}
@media (prefers-color-scheme:dark){:root{--bg:#1b1b1a;--fg:#ececea;--mut:#a3a39d;--vora:#3a3a37;--ok:#5fbf86;--ko:#e57a66;--act:#242423;--sel:#23324a}}
body{margin:0;background:var(--bg);color:var(--fg);font:15px/1.45 system-ui,sans-serif}
header{position:sticky;top:0;background:var(--bg);border-bottom:1px solid var(--vora);padding:10px 16px;display:flex;gap:12px;align-items:center;flex-wrap:wrap;z-index:1}
main{max-width:900px;margin:0 auto;padding:12px 16px 80px}
.clip{border:1px solid var(--vora);border-radius:8px;padding:10px 12px;margin:10px 0;background:var(--act)}
.clip.actiu{outline:2px solid #4c8bf5;background:var(--sel)}
.clip.ok{border-left:5px solid var(--ok)} .clip.descartat{border-left:5px solid var(--ko);opacity:.55}
.cap{display:flex;gap:10px;align-items:center;color:var(--mut);font-size:13px;flex-wrap:wrap}
textarea{width:100%;box-sizing:border-box;font:inherit;padding:6px;margin:6px 0;border:1px solid var(--vora);border-radius:6px;background:var(--bg);color:var(--fg);resize:vertical}
.pista{color:var(--mut);font-size:13px} audio{height:32px;max-width:100%}
button{font:inherit;padding:4px 10px;border-radius:6px;border:1px solid var(--vora);background:var(--act);color:var(--fg);cursor:pointer}
button.b-ok{border-color:var(--ok);color:var(--ok)} button.b-ko{border-color:var(--ko);color:var(--ko)}
select{font:inherit;padding:3px}
</style>
<header><select id="dades"></select><span id="compte"></span>
<span class="pista">Intro: correcte i següent · Ctrl+Supr: descartar · Ctrl+Espai: escoltar</span></header>
<main id="llista"></main>
<script>
const $=s=>document.querySelector(s);let dades,clips=[],actiu=0;
async function carrega(){const r=await fetch('/api/llista?d='+encodeURIComponent(dades));clips=await r.json();pinta();
 actiu=Math.max(0,clips.findIndex(c=>!c.estat));activa(actiu,false)}
function pinta(){const l=$('#llista');l.innerHTML='';clips.forEach((c,i)=>{const d=document.createElement('div');
 d.className='clip '+(c.estat||'');d.id='c'+i;d.innerHTML=`<div class="cap"><b>${c.id}</b><span>${c.durada} s</span>
 <span>acord ${c.acord}</span>${c.sospitoses?`<span>⚠ ${c.sospitoses}</span>`:''}</div>
 <audio controls preload="none" src="/wav/${encodeURIComponent(dades)}/${encodeURIComponent(c.id)}.wav"></audio>
 <textarea rows="2"></textarea><div class="pista">capítol sencer: ${c.text_llarg}</div>
 <button class="b-ok">Correcte</button> <button class="b-ko">Descartar</button>`;
 const t=d.querySelector('textarea');t.value=c.text;
 t.onfocus=()=>activa(i,true);
 d.querySelector('.b-ok').onclick=()=>desa(i,'ok');d.querySelector('.b-ko').onclick=()=>desa(i,'descartat');
 l.appendChild(d)});compte()}
function compte(){const ok=clips.filter(c=>c.estat=='ok').length,ko=clips.filter(c=>c.estat=='descartat').length;
 $('#compte').textContent=`${ok} correctes · ${ko} descartats · ${clips.length-ok-ko} per revisar de ${clips.length}`}
function activa(i,sona){document.querySelectorAll('.clip.actiu').forEach(e=>e.classList.remove('actiu'));
 actiu=i;const d=$('#c'+i);if(!d)return;d.classList.add('actiu');
 if(document.activeElement!==d.querySelector('textarea')){d.querySelector('textarea').focus({preventScroll:true});d.scrollIntoView({block:'center'})}
 if(sona){document.querySelectorAll('audio').forEach(a=>a.pause());const a=d.querySelector('audio');a.currentTime=0;a.play().catch(()=>{})}}
async function desa(i,estat){const c=clips[i],d=$('#c'+i);c.text=d.querySelector('textarea').value.trim();c.estat=estat;
 await fetch('/api/desa',{method:'POST',body:JSON.stringify({d:dades,id:c.id,text:c.text,estat})});
 d.className='clip '+estat;compte();if(i+1<clips.length)activa(i+1,true)}
document.addEventListener('keydown',e=>{if(e.key=='Enter'&&!e.shiftKey){e.preventDefault();desa(actiu,'ok')}
 else if(e.key=='Delete'&&e.ctrlKey){e.preventDefault();desa(actiu,'descartat')}
 else if(e.key==' '&&e.ctrlKey){e.preventDefault();activa(actiu,true)}});
fetch('/api/dades').then(r=>r.json()).then(ds=>{const s=$('#dades');ds.forEach(d=>s.add(new Option(d,d)));
 dades=ds[0];s.onchange=()=>{dades=s.value;carrega()};carrega()});
</script></html>"""


class Dataset:
    def __init__(self, dir_: Path) -> None:
        self.dir = dir_
        self.estat_path = dir_ / "revisat.json"
        self.estat = json.loads(self.estat_path.read_text(encoding="utf-8")) if self.estat_path.exists() else {}
        # metadata.orig.csv: tots els clips amb el text de partida (metadata.csv perd els descartats).
        orig = dir_ / "metadata.orig.csv"
        if not orig.exists():
            orig.write_bytes((dir_ / "metadata.csv").read_bytes())
        self.ordre, self.text = [], {}
        for linia in orig.read_text(encoding="utf-8").splitlines():
            if linia.strip():
                cid, text = linia.split("|", 1)
                self.ordre.append(cid)
                self.text[cid] = text
        for linia in (dir_ / "metadata.csv").read_text(encoding="utf-8").splitlines():
            if linia.strip():
                cid, text = linia.split("|", 1)
                self.text[cid] = text
        with open(dir_ / "revisio.tsv", encoding="utf-8") as fh:
            self.revisio = [r for r in csv.DictReader(fh, delimiter="\t") if r["id"] in self.text]

    def llista(self) -> list[dict]:
        return [{"id": r["id"], "durada": r["durada"], "acord": r["acord"], "sospitoses": r["sospitoses"],
                 "text_llarg": r["text_llarg"], "text": self.text[r["id"]],
                 "estat": self.estat.get(r["id"])} for r in self.revisio]

    def desa(self, cid: str, text: str, estat: str) -> None:
        if cid not in self.text or estat not in ("ok", "descartat") or "|" in text or "\n" in text:
            raise ValueError(cid)
        self.text[cid] = " ".join(text.split())
        self.estat[cid] = estat
        self.estat_path.write_text(json.dumps(self.estat, ensure_ascii=False, indent=1), encoding="utf-8")
        linies = [f"{c}|{self.text[c]}" for c in self.ordre if self.estat.get(c) != "descartat"]
        (self.dir / "metadata.csv").write_text("\n".join(linies) + "\n", encoding="utf-8")


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("clips", type=Path, nargs="+", help="carpetes de segmenta-veu.py")
    ap.add_argument("--port", type=int, default=8765)
    args = ap.parse_args()
    datasets = {d.name: Dataset(d) for d in args.clips}

    class Handler(BaseHTTPRequestHandler):
        def envia(self, codi: int, cos: bytes, tipus: str) -> None:
            self.send_response(codi)
            self.send_header("Content-Type", tipus)
            self.send_header("Content-Length", str(len(cos)))
            self.end_headers()
            self.wfile.write(cos)

        def json(self, obj: object) -> None:
            self.envia(200, json.dumps(obj, ensure_ascii=False).encode(), "application/json; charset=utf-8")

        def do_GET(self) -> None:  # noqa: N802
            url = urlparse(self.path)
            if url.path == "/":
                self.envia(200, PAGINA.encode(), "text/html; charset=utf-8")
            elif url.path == "/api/dades":
                self.json(list(datasets))
            elif url.path == "/api/llista":
                self.json(datasets[parse_qs(url.query)["d"][0]].llista())
            elif url.path.startswith("/wav/"):
                _, _, d, nom = unquote(url.path).split("/", 3)
                wav = datasets[d].dir / "wavs" / Path(nom).name
                if not wav.is_file():
                    return self.envia(404, b"", "text/plain")
                self.envia(200, wav.read_bytes(), mimetypes.guess_type(wav.name)[0] or "audio/wav")
            else:
                self.envia(404, b"", "text/plain")

        def do_POST(self) -> None:  # noqa: N802
            cos = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
            try:
                datasets[cos["d"]].desa(cos["id"], cos["text"], cos["estat"])
            except (KeyError, ValueError):
                return self.envia(400, b"", "text/plain")
            self.json({"ok": True})

        def log_message(self, *a) -> None:  # noqa: ANN002
            pass

    print(f"revisió en http://localhost:{args.port} ({', '.join(datasets)})")
    ThreadingHTTPServer(("127.0.0.1", args.port), Handler).serve_forever()


if __name__ == "__main__":
    main()
