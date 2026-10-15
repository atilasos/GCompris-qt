#!/usr/bin/env python3
"""Verify final native Hanoi receipts and write their evidence index."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
CASES = {
    "classic-visual-order": ("hanoi_real", "tests/hanoi_real.qml"),
    "simplified-visual-order": ("hanoi", "tests/hanoi_simplified.qml"),
    "controls-real-settled": ("hanoi_real", "tests/hanoi_controls.qml"),
    "controls-simplified-settled": ("hanoi", "tests/hanoi_controls.qml"),
    "covered-classic": ("hanoi_real", "tests/hanoi_covered.qml"),
    "covered-simplified": ("hanoi", "tests/hanoi_covered.qml"),
}


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def audit():
    receipts = []
    for name, (activity, case) in CASES.items():
        directory = HERE / name
        result = json.loads((directory / "result.json").read_text())
        assert result["passed"] and result["exit_code"] == 0
        assert not result["timeout"] and not result["qml_errors"]
        assert result["activity"] == activity and result["locale"] == "pt_PT"
        assert result["network"] == "docker-none"
        assert result["runtime_uid"] == result["runtime_gid"] == 1000
        assert result["private_file_ownership_verified"]
        assert result["case_sha256"] == sha(ROOT / case)
        assert result["runner_sha256"] == sha(ROOT / "tools/run-native-qml-case.py")
        assert result["source_sha256"] == sha(ROOT / "src/activities" / result["qml_file"])
        assert result["portuguese_catalogue_sha256"] == sha(ROOT / "poqm/pt/gcompris_qt.po")
        for screenshot in result["screenshots"]:
            assert sha(directory / screenshot["file"]) == screenshot["sha256"]
        record = result["case_result"]
        assert record["failures"] == 0 and record["passes"] == 2
        if name == "classic-visual-order":
            assert record["completed"] == [
                {"level": n - 2, "discs": n, "moves": 2**n - 1}
                for n in (3, 4, 5)
            ]
            assert record["moves"] == 53 and record["rejected"] == 3
        elif name == "simplified-visual-order":
            assert [x["level"] for x in record["completed"]] == list(range(1, 7))
            assert [x["height"] for x in record["completed"]] == [5, 5, 6, 7, 8, 9]
            assert [x["auxiliaryPegs"] for x in record["completed"]] == [3, 4, 5, 6, 6, 5]
            assert all(len(x["reference"]) == x["height"] for x in record["completed"])
            assert sum(x["moves"] for x in record["completed"]) == record["moves"] == 213
            assert record["rejected"] == 12
        elif name.startswith("covered-"):
            covered = record["covered"]
            assert covered["activity"] == activity
            assert covered["coveredNeverMoved"] and covered["onlyTopRedirected"] and covered["exposedMoved"]
            lower = covered["selectedLower"]
            assert not covered["initial"][lower]["enabled"]
            assert len(covered["redirects"]) == (2 if activity == "hanoi_real" else 3)
            for step in covered["redirects"]:
                before, after, upper = step["before"], step["after"], step["upper"]
                assert not before[lower]["enabled"] and before[upper]["enabled"]
                assert before[upper]["parent"] != after[upper]["parent"]
                assert before[lower]["x"] == step["start"][0] and before[lower]["y"] == step["start"][1]
                assert len(before) == len(after)
                for index in range(len(before)):
                    if index != upper:
                        assert all(before[index][field] == after[index][field]
                                   for field in ("parent", "x", "y", "width", "height"))
            assert covered["exposedBefore"][lower]["enabled"]
            assert covered["exposedBefore"][lower]["parent"] != covered["exposedAfter"][lower]["parent"]
        else:
            controls = record["controls"]
            assert controls["helpClosedWithEscape"] and controls["reloadClearedPartial"]
            assert controls["dragAfterHelp"] and controls["activity"] == activity
            assert controls["levels"] == (3 if activity == "hanoi_real" else 6)
            assert len(controls["resources"]) == (3 if activity == "hanoi_real" else 4)
            for resource in controls["resources"]:
                relative = resource.removeprefix("qrc:/gcompris/")
                assert sha(ROOT / relative) == sha(directory / Path(relative).name)
        receipts.append({"directory": name, "activity": activity, "case": case,
                         "case_sha256": result["case_sha256"], "result": record})
    artifacts = {str(path.relative_to(HERE)): sha(path)
                 for name in CASES for path in sorted((HERE / name).iterdir())
                 if path.is_file()}
    return {"passed": True, "scope": "Linux native offline; six final cases only",
            "cases": receipts, "artifact_sha256": artifacts}


if __name__ == "__main__":
    output = audit()
    (HERE / "index.json").write_text(json.dumps(output, indent=2, ensure_ascii=False) + "\n")
    print(json.dumps({"passed": True, "cases": len(output["cases"]),
                      "artifacts": len(output["artifact_sha256"])}))
