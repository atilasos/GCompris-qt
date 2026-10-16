#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Inventory PT-PT source coverage. This does not certify runtime behaviour."""

import argparse
import ast
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import subprocess


ROOT = Path(__file__).resolve().parents[1]
PLACEHOLDER = re.compile(r"%(?:L?(?:[1-9][0-9]?|n))")
FIELD = re.compile(r'(msgctxt|msgid_plural|msgid|msgstr(?:\[\d+\])?)\s+(".*")$')


def read_po(path):
    """Read active PO entries, including contexts, plurals and continuations.

    Previous translations (#|) and obsolete entries (#~ and #~|) are comments.
    Fail on unknown active syntax instead of silently undercounting coverage.
    """
    entries = []
    entry = {"flags": [], "references": []}
    field = None
    for number, raw in enumerate(path.read_text(encoding="utf-8").splitlines() + [""], 1):
        line = raw.strip()
        if not line:
            if entry.get("msgid"):
                entry["line"] = start
                entries.append(entry)
            entry = {"flags": [], "references": []}
            field = None
        elif line.startswith("#,"):
            entry["flags"].extend(part.strip() for part in line[2:].split(","))
        elif line.startswith("#:"):
            entry["references"].extend(line[2:].split())
        elif line.startswith("#"):
            continue
        else:
            match = FIELD.fullmatch(line)
            if match:
                field, quoted = match.groups()
                if field == "msgid":
                    start = number
                entry[field] = ast.literal_eval(quoted)
            elif line.startswith('"') and field:
                entry[field] += ast.literal_eval(line)
            else:
                raise ValueError(f"{path}:{number}: unsupported PO syntax: {line}")
    return entries


def inspect_catalog(root, relative):
    entries = read_po(root / relative)
    findings = []
    counts = Counter()
    for entry in entries:
        translations = [(key, value) for key, value in entry.items()
                        if key == "msgstr" or key.startswith("msgstr[")]
        reasons = []
        # Both audited catalogs declare the Portuguese two-form plural rule.
        expected_keys = {"msgstr[0]", "msgstr[1]"} if "msgid_plural" in entry else {"msgstr"}
        if {key for key, _ in translations} != expected_keys or any(not value.strip() for _, value in translations):
            reasons.append("untranslated")
        if "fuzzy" in entry["flags"]:
            reasons.append("fuzzy")
        for key, value in translations:
            source = entry.get("msgid_plural", entry["msgid"]) if key not in ("msgstr", "msgstr[0]") else entry["msgid"]
            if value.strip() and Counter(PLACEHOLDER.findall(source)) != Counter(PLACEHOLDER.findall(value)):
                reasons.append("placeholder-mismatch")
                break
        counts.update(reasons)
        if reasons:
            findings.append({"line": entry["line"], "context": entry.get("msgctxt", ""),
                             "source": entry["msgid"], "reasons": reasons,
                             "references": entry["references"]})
    return {"path": relative, "entries": len(entries),
            "counts": dict(sorted(counts.items())), "findings": findings}


def build_report(root):
    activity_list = root / "src/activities/activities.txt"
    activities = [line.split("#", 1)[0].strip() for line in activity_list.read_text().splitlines()]
    activities = [name for name in activities if name]
    if len(activities) != len(set(activities)):
        raise ValueError("Duplicate activity in activities.txt")
    catalogs = [inspect_catalog(root, path) for path in
                ("poqm/pt/gcompris_qt.po", "po/pt/gcompris_voices.po")]
    rows = []
    inputs = {activity_list, *(root / catalog["path"] for catalog in catalogs)}
    for name in activities:
        folder = root / "src/activities" / name
        metadata = folder / "ActivityInfo.qml"
        if not metadata.is_file():
            raise ValueError(f"Missing {metadata}")
        inputs.add(metadata)
        content = metadata.read_text(encoding="utf-8")
        title = re.search(r'title:\s*qsTr\("((?:[^"\\]|\\.)*)"\)', content)
        portuguese_files = []
        candidate_gaps = []
        invalid_json = []
        for path in sorted(folder.rglob("*.json")):
            inputs.add(path)
            relative = path.relative_to(root).as_posix()
            if re.search(r"-(?:pt|pt_PT)\.json$", path.name):
                portuguese_files.append(relative)
                try:
                    json.loads(path.read_text(encoding="utf-8"))
                except (ValueError, UnicodeError) as error:
                    invalid_json.append({"path": relative, "error": str(error)})
            if path.name.endswith("-en.json"):
                stem = path.name[:-len("-en.json")]
                if not any((path.parent / f"{stem}-{locale}.json").is_file() for locale in ("pt", "pt_PT")):
                    candidate_gaps.append(relative)
        # Qt's extractor writes references relative to src/, not the repo root.
        prefix = f"activities/{name}/"
        catalog_findings = [finding for finding in catalogs[0]["findings"]
                            if any(prefix in reference for reference in finding["references"])]
        rows.append({"id": name, "title_source": title.group(1) if title else None,
                     "catalog_findings": len(catalog_findings),
                     "portuguese_json": portuguese_files,
                     "english_json_without_portuguese_peer": candidate_gaps,
                     "invalid_portuguese_json": invalid_json})
    digest = hashlib.sha256()
    for path in sorted(inputs):
        digest.update(path.relative_to(root).as_posix().encode() + b"\0" + path.read_bytes() + b"\0")
    revision = subprocess.check_output(["git", "-C", str(root), "rev-parse", "HEAD"], text=True).strip()
    return {"schema_version": 1, "revision": revision, "input_sha256": digest.hexdigest(),
            "scope": "Source inventory only; runtime, audio, offline packaging and linguistic quality are unverified.",
            "resource_warning": "Missing JSON peers are inspection candidates, not proof of a defect. Shared resources and QML datasets require separate inspection.",
            "activity_count": len(rows), "catalogs": catalogs, "activities": rows}


def render_markdown(report):
    lines = ["# Inventário estático PT-PT", "", f"Revisão base: `{report['revision']}`.",
             f"Entradas das fontes: `{report['input_sha256']}`.", "",
             f"Atividades listadas: {report['activity_count']}.", "",
             "Este inventário não certifica execução, áudio, qualidade linguística ou funcionamento offline.",
             "As ausências de ficheiros JSON são pistas para inspeção. Há recursos partilhados e dados em QML.",
             "", "| Catálogo | Mensagens | Sem tradução | Fuzzy | Marcadores diferentes |",
             "| --- | ---: | ---: | ---: | ---: |"]
    for catalog in report["catalogs"]:
        counts = catalog["counts"]
        lines.append(f"| `{catalog['path']}` | {catalog['entries']} | {counts.get('untranslated', 0)} | {counts.get('fuzzy', 0)} | {counts.get('placeholder-mismatch', 0)} |")
    lines.extend(["", "Os detalhes de cada mensagem estão em `audit.json`. Fuzzy significa revisão pendente.",
                  "", "| Atividade | Mensagens com problemas | JSON PT | JSON inglês sem equivalente PT |",
                  "| --- | ---: | ---: | --- |"])
    for row in report["activities"]:
        gaps = ", ".join(f"`{path}`" for path in row["english_json_without_portuguese_peer"]) or "—"
        lines.append(f"| `{row['id']}` | {row['catalog_findings']} | {len(row['portuguese_json'])} | {gaps} |")
    return "\n".join(lines) + "\n"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True, help="Directory for generated audit.json and inventory.md")
    parser.add_argument("--check", action="store_true", help="Exit 1 for known catalog gaps or invalid Portuguese JSON; not a runtime certification")
    args = parser.parse_args()
    report = build_report(ROOT)
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / "audit.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    (args.output / "inventory.md").write_text(render_markdown(report), encoding="utf-8")
    print(f"Inventariadas {report['activity_count']} atividades. Relatório: {args.output / 'inventory.md'}")
    has_gaps = any(catalog["findings"] for catalog in report["catalogs"]) or any(row["invalid_portuguese_json"] for row in report["activities"])
    return 1 if args.check and has_gaps else 0


if __name__ == "__main__":
    raise SystemExit(main())
