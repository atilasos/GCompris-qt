#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Read finite, completed raw receipts; emit semantic verification only."""
import argparse
import hashlib
import json
from pathlib import Path
from . import validate_controls

POSITIVE = ['controls2-redraw', 'controls3-redraw_symmetrical', 'controls3-mosaic']
NEGATIVE = ['controls-redraw', 'controls-redraw_symmetrical', 'controls-mosaic',
            'controls2-mosaic', 'controls2-redraw_symmetrical']


def verify(root):
    records = []
    for name in POSITIVE + NEGATIVE:
        raw = (root/name/'result.json').read_bytes()
        case = json.loads(raw)['case_result']
        observed = {'run': name, 'raw_receipt_sha256': hashlib.sha256(raw).hexdigest()}
        try:
            summary = validate_controls(case)
        except ValueError as error:
            if name in POSITIVE:
                raise
            observed.update(accepted=False, rejection=str(error))
        else:
            if name in NEGATIVE:
                raise ValueError('Historical negative was accepted: '+name)
            observed.update(accepted=True, summary=summary)
        records.append(observed)
    return {'scope': 'Semantic copied/raw JSON records only; physical source/resources/PNGs/returns audited separately',
            'positive_records': len(POSITIVE), 'negative_records': len(NEGATIVE), 'records': records}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root-evidence', type=Path, required=True)
    arguments = parser.parse_args()
    print(json.dumps(verify(arguments.root_evidence), indent=2))
