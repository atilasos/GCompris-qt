"""Verifica os tickets publicados contra a divisão e dependências aprovadas."""

from pathlib import Path
import re


ROOT = Path(__file__).resolve().parent
EXPECTED_BLOCKERS = {
    2: [], 3: [2], 4: [3], 5: [4], 6: [3], 7: [6],
    8: [3], 9: [8], 10: [3], 11: [10], 12: [3], 13: [12],
    14: [3], 15: [14], 16: [3], 17: [16],
    18: [5, 7, 9, 11, 13, 15, 17],
}


def verify():
    tickets = {}
    for path in sorted((ROOT / "issues").glob("[0-9][0-9]-*.md")):
        number = int(path.name[:2])
        assert number not in tickets, f"Número repetido: {number:02d}"
        tickets[number] = path

    assert set(tickets) == {1, *EXPECTED_BLOCKERS}, "Inventário de tickets incorreto"
    progress = {}
    for number, blockers in EXPECTED_BLOCKERS.items():
        path = tickets[number]
        body = path.read_text()
        assert body.startswith(f"# {number:02d}: "), path.name
        assert "\nStatus: ready-for-agent\n" in body, path.name
        assert "\nType: task\n" in body, path.name
        state = re.search(r"^Progress: (open|claimed|resolved)$", body, re.M)
        assert state, f"Progresso inválido: {path.name}"
        progress[number] = state.group(1)
        field = re.search(r"^Blocked by: (.+)$", body, re.M)
        assert field, f"Bloqueios ausentes: {path.name}"
        declared = field.group(1)
        if blockers:
            assert re.fullmatch(r"\d{2}(, \d{2})*", declared), path.name
            actual = [int(value) for value in declared.split(", ")]
        else:
            assert declared == "None (can start immediately)", path.name
            actual = []
        assert actual == blockers, f"Dependências diferentes das aprovadas: {path.name}"
        assert all(blocker in tickets and blocker < number for blocker in actual), path.name
        assert "\nParent: 01," in body, path.name
        assert "**What to build:** " in body, path.name
        assert len(re.findall(r"^- \[[ x]\] ", body, re.M)) >= 6, path.name
        assert "## Comments" in body, path.name

    map_text = (ROOT / "map.md").read_text()
    linked_tickets = set()
    for target in re.findall(r"\]\(([^)]+)\)", map_text):
        assert (ROOT / target).is_file(), f"Ligação inexistente: {target}"
        if target.startswith("issues/"):
            linked_tickets.add(int(Path(target).name[:2]))
    assert linked_tickets == set(tickets), "O mapa não referencia todos os tickets"

    frontier = [
        f"{number:02d}" for number, blockers in EXPECTED_BLOCKERS.items()
        if progress[number] == "open"
        and all(progress[blocker] == "resolved" for blocker in blockers)
    ]
    print("17 tickets verificados: numeração, metadados, critérios, mapa e dependências aprovadas sem ciclos.")
    print("Fronteira disponível: " + (", ".join(frontier) or "nenhuma"))


if __name__ == "__main__":
    verify()
