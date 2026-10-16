#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Cross-check JS/Python plans of public inventories, without Qt/game claims."""
import argparse, hashlib, json, subprocess, sys
from pathlib import Path
ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT.parent))
from pattern_grid_solver import plan


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def probe(inventory_root, registry_file, output):
    if output.exists() or output.is_symlink():
        raise FileExistsError('Use a fresh pure probe output')
    registry_raw = registry_file.read_bytes()
    registry = json.loads(registry_raw)
    payloads, observations, hashes = [], [], {}
    for activity in ['redraw', 'redraw_symmetrical', 'mosaic']:
        path = inventory_root/('inventory-'+activity)/'result.json'
        raw = path.read_bytes()
        receipt = json.loads(raw)
        if receipt['case_result']['failures'] or not receipt['passed']:
            raise ValueError('Public inventory was not successful')
        hashes[activity] = digest(raw)
        for board in receipt['case_result']['boards']:
            def signature(row):
                if activity == 'mosaic':
                    return registry['images'][row['source']]['signature']
                return row['color']
            question = [{'frame': row['frame'], 'signature': signature(row)}
                        for row in board['question']]
            answer = [{'frame': row['frame']} for row in board['answer']]
            offered = board['selector' if activity == 'mosaic' else 'palette']
            palette = []
            for row in offered:
                if row.get('status') != 1 or not row.get('source', '').startswith('qrc:/'):
                    continue
                identity = row['source']
                if activity == 'mosaic':
                    painted = registry['images'][identity]['signature']
                else:
                    painted = next(s['signature'] for s in registry['palette_samples'][activity]
                                   if s['id'] == identity)
                palette.append({'id': identity, 'signature': painted, 'frame': row['frame']})
            payload = {'question': question, 'answer': answer, 'palette': palette,
                       'mirror': activity == 'redraw_symmetrical'}
            result = plan(question, answer, palette, mirror=payload['mirror'])
            payloads.append(payload)
            observations.append({'activity': activity, 'level': board['level'],
                                 'rows': result['rows'], 'columns': result['columns'],
                                 'cells': len(result['placements']), 'python': result})
    script = '''const fs=require('node:fs'),vm=require('node:vm');
const context=vm.createContext({});vm.runInContext(fs.readFileSync(process.argv[1],'utf8'),context);
const payloads=JSON.parse(fs.readFileSync(0,'utf8'));
console.log(JSON.stringify(payloads.map(p=>context.visiblePlan(p.question,p.answer,p.palette,p.mirror))));'''
    completed = subprocess.run(['node', '-e', script, str(ROOT/'planner.js')],
                               input=json.dumps(payloads), text=True, capture_output=True)
    if completed.returncode:
        raise ValueError('Pure JS probe refused: '+completed.stderr)
    javascript = json.loads(completed.stdout)
    if len(javascript) != len(observations):
        raise ValueError('Pure JS probe omitted boards')
    for expected, actual in zip(observations, javascript):
        python = expected.pop('python')
        if any(actual[key] != python[key] for key in ['rows', 'columns', 'placements']):
            raise ValueError('Independent JS/Python plans disagree: '+str(expected))
        expected['placements_sha256'] = digest(json.dumps(actual['placements'], sort_keys=True).encode())
    report = {'scope': 'Pure plans from historical public observations only; no Qt or game completion',
              'registry_sha256': digest(registry_raw), 'inventory_receipts_sha256': hashes,
              'planner_js_sha256': digest((ROOT/'planner.js').read_bytes()),
              'node_argv': completed.args, 'node_exit_code': completed.returncode,
              'boards': observations, 'total_boards': len(observations),
              'total_cells': sum(b['cells'] for b in observations)}
    with output.open('x') as stream:
        stream.write(json.dumps(report, indent=2)+'\n')
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--inventory-root', type=Path, required=True)
    parser.add_argument('--registry', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = probe(args.inventory_root, args.registry, args.output)
    print(json.dumps({'boards': result['total_boards'], 'cells': result['total_cells'],
                      'scope': result['scope']}))
