#!/usr/bin/env python3
# SPDX-FileCopyrightText: NONE
# SPDX-License-Identifier: CC0-1.0
"""Build only public files; no network, credentials or application build needed."""
import hashlib
import json
import shutil
from datetime import date
from html import escape
from pathlib import Path

SITE = Path(__file__).resolve().parent
OUT = SITE.parent / "build/fork-site"
data = json.loads((SITE / "content.json").read_text())
release = data["installer"]
assert len(release["sha256"]) == 64
assert release["bytes"] > 0
OUT.mkdir(parents=True, exist_ok=True)
# Rebuild the dedicated output to avoid publishing stale files.
for item in OUT.iterdir():
    shutil.rmtree(item) if item.is_dir() else item.unlink()
shutil.copytree(SITE / "assets", OUT / "assets")
for name in ("style.css", "gallery.js", "latest.js", "_headers", "_redirects", "404.html", "credits.html"):
    shutil.copyfile(SITE / name, OUT / name)

def pretty(value):
    d = date.fromisoformat(value)
    return f"{d.day:02d}.{d.month:02d}.{d.year}"

def image_card(item):
    name, title, description = (escape(item[k], quote=True) for k in ("file", "title", "description"))
    return f'''<figure class="game"><a class="zoom" href="assets/screenshots/{name}" aria-label="Ampliar captura: {title}"><img src="assets/screenshots/{name}" alt="{title}: captura real da atividade no GCompris" width="1280" height="800" loading="lazy"></a><figcaption><h3>{title}</h3><p>{description}</p></figcaption></figure>'''

cards = "\n".join(image_card(item) for item in data["screenshots"])
entries = []
for item in data["changes"]:
    details = "".join(f"<li>{escape(line)}</li>" for line in item["details"])
    entries.append(f'''<article class="entry"><div class="entry-date"><time datetime="{item['date']}">{pretty(item['date'])}</time><span>{escape(item['label'])}</span></div><div class="entry-body"><p class="pill">{escape(item['status'])}</p><h3>{escape(item['title'])}</h3><p>{escape(item['body'])}</p><ul>{details}</ul><a class="text-link" href="https://github.com/atilasos/GCompris-qt/commit/{item['commit']}">Ver alteração no código ↗</a></div></article>''')
template = (SITE / "index.html").read_text()
replacements = {
    "{{GALLERY}}": cards, "{{CHANGELOG}}": "\n".join(entries),
    "{{DOWNLOAD}}": escape(release["url"], quote=True), "{{SHA256}}": release["sha256"],
    "{{RELEASE_DATE}}": pretty(release["date"]), "{{SOURCE}}": release["source"][:10],
    "{{RUN}}": release["run"], "{{SIZE}}": f"{release['bytes'] / 1_000_000:.1f}".replace(".", ","),
    "{{UPDATED}}": pretty(data["updated"]),
}
for key, value in replacements.items():
    template = template.replace(key, value)
assert "{{" not in template
(OUT / "index.html").write_text(template)
(OUT / "release.json").write_text(json.dumps(release, indent=2) + "\n")
manifest = {str(p.relative_to(OUT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(OUT.rglob("*")) if p.is_file()}
print(f"Built {len(manifest)} public files in {OUT}")
operations = SITE.parent / "build/fork-site-ops"
operations.mkdir(parents=True, exist_ok=True)
(operations / "asset-hashes.json").write_text(json.dumps(manifest, indent=2) + "\n")
