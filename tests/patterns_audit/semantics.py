# SPDX-License-Identifier: GPL-3.0-or-later
"""Finite functional checks over the anchored native observations and pixels."""
import io
from collections import Counter
import json
import sys
from pathlib import Path
from PIL import Image
from store import require, sha
from grid_semantics import validate_board
from mosaic_pixels import classify_crop
TESTS=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(TESTS))
LEVELS={'redraw':38,'redraw_symmetrical':21,'mosaic':22,'polygons':9}

def picture(reader,path):
    return Image.open(io.BytesIO(reader.artifact(path))).convert('RGBA')

def registry_inputs(reader,receipts):
    phase=reader.capture['runs']['complete-mosaic']['source']
    source=reader.capture['sources'][phase]['files']
    registry=json.loads(reader.blob(source['tests/functional_patterns/observed-assets.json']))
    for name in ('redraw','redraw_symmetrical'):
        receipt=receipts['calibrate2-'+name]
        require(registry['calibration_receipts'][name]==sha(reader.artifact('runs/calibrate2-'+name+'/result.json')),'Registry bound to actual native calibration receipt')
        samples=receipt['case_result']['samples']
        require(len(samples)==7 and receipt['case_result']['wins']==0,'Seven non-winning public color probes')
        require(registry['palette_samples'][name]==[{'id':s['id'],'signature':s['after']['color']} for s in samples],'Registry uses the actual painted color')
        require(all(s['signature']==s['after']['color'] and s['paint']['x']==s['after']['frame']['x'] and s['paint']['y']==s['after']['frame']['y'] for s in samples),'Probe signatures refer to the clicked painted rectangles')
    pictures={};signatures=set()
    for uri,row in registry['images'].items():
        require(uri.startswith('qrc:/gcompris/src/activities/mosaic/resource/'),'Public Mosaic image URI')
        raw=reader.artifact('canonical/mosaic/files/'+uri.removeprefix('qrc:/'))
        require(sha(raw)==row['resource_sha256'],'Actual resource bytes underlying image signature')
        logical='auxiliary/'+row['rendered'].removeprefix('.scratch/pt-pt/functional-patterns/')
        rendered=reader.artifact(logical)
        require(sha(rendered)==row['rendered_sha256'],'Historical normalized render bytes')
        image=Image.open(io.BytesIO(rendered)).convert('RGBA')
        require(image.size==(160,160) and 'rgba160-sha256:'+sha(image.tobytes())==row['signature'],'Recomputed physical RGBA picture fingerprint')
        require(row['signature'] not in signatures,'Distinct physical picture fingerprints')
        signatures.add(row['signature']);pictures[uri]=image
    require(len(pictures)==25,'All physical Mosaic pictures, including blank')
    return registry,pictures

def bind_cells(cells,activity,registry):
    for cell in cells:
        if activity=='mosaic':
            require(cell['status']==1 and cell['source'] in registry['images'] and cell['signature']==registry['images'][cell['source']]['signature'],'Ready public image bound to its physical pixels')
        else:
            require(cell['signature']==cell['color'],'Actual rectangle QtColorString')

def validate(reader,receipts):
    runs=reader.capture['runs']
    require(Counter(r['kind'] for r in runs.values())=={'inventory':4,'complete':4,'controls':4,'calibration':2,'pilot':1,'partial':1,'negative':7},'Complete finite campaign, with every historical fixture retained separately')
    for kind in ('inventory','complete','controls'):
        require(sorted(row['activity'] for row in runs.values() if row['kind']==kind)==sorted(LEVELS),'Exactly one final contract per activity and role')
    for path,digest in reader.capture['algorithms'].items():
        require(sha((TESTS.parent/path).read_bytes())==digest,'External independent geometry algorithm matches its frozen native phase')
    for path,digest in reader.capture['verification_sources'].items():
        require(sha(reader.artifact('verification-source/'+path))==digest==sha((TESTS.parent/path).read_bytes()),'Independent verifier source is physically bound to the sealed phase')
    registry,pictures=registry_inputs(reader,receipts)
    from pattern_scene_pixels import check_cells,check_snapshot
    background_record=reader.json('auxiliary/background/pattern-background-render.json')
    background_bytes=reader.artifact('auxiliary/background/pattern-background.png')
    background_source=reader.artifact('canonical/redraw/files/gcompris/src/activities/redraw/resource/background.svg')
    require(sha(background_source)==background_record['source_sha256'] and sha(background_bytes)==background_record['output_sha256'],'Independent alpha background render bound to actual source')
    background=Image.open(io.BytesIO(background_bytes)).convert('RGBA')
    require(background.size==tuple(background_record['canvas'])==(800,800),'Actual background canvas geometry')
    counts={};pixel_checks=0;cell_pixel_counts={'opaque':0,'alpha':0}

    for name,contract in runs.items():
        if contract['kind']!='complete' or contract['activity']=='polygons':continue
        activity=contract['activity'];case=receipts[name]['case_result'];boards=case['boards'];total=LEVELS[activity]
        require([b['level'] for b in boards]==list(range(1,total+1)) and all(b['total']==total for b in boards),'Every public level exactly once')
        require(case['wins']==total and case['evidence']['menuAfterSuccess']=={'depth':1,'busy':False,'isMenu':True},'Natural wins and actual stable menu')
        cells=0
        for board in boards:
            cells+=validate_board(board,activity=='redraw_symmetrical')
            for group in (board['question'],board['answerInitial'],board['wrong']['answer'],board['repaired']['answer']):bind_cells(group,activity,registry)
            if activity=='mosaic':
                candidates={p['id']:pictures[p['id']] for p in board['palette']}
                for suffix,group in [('question',board['question']),('wrong',board['wrong']['answer']),('success',board['repaired']['answer'])]:
                    scene=picture(reader,f'runs/{name}/level-{board["level"]}-{suffix}.png')
                    for cell in group:
                        match=classify_crop(scene,cell['frame'],candidates)
                        require(registry['images'][match['id']]['signature']==cell['signature'],'Full-scene pixels independently identify the recorded picture')
                        pixel_checks+=1
            else:
                for suffix,group in [('question',board['question']+board['answerInitial']),('wrong',board['question']+board['wrong']['answer']),('success',board['question']+board['repaired']['answer'])]:
                    scene=picture(reader,f'runs/{name}/level-{board["level"]}-{suffix}.png')
                    result=check_cells(group,scene,background=background)
                    require(result['alpha_unverified']==0,'Every translucent cell checked against independent background')
                    cell_pixel_counts['opaque']+=result['opaque_checked'];cell_pixel_counts['alpha']+=result['alpha_checked']
        counts[activity]={'completed_levels':total,'cells':cells,'wrong_repaired':total,'sampling':'one current generated question per public level' if activity=='mosaic' else 'all fixed visible boards'}
    from polygon_observation_audit import validate_tutorial,validate_controls as validate_polygon_controls
    def snapshots(name):
        def check(state):
            return check_snapshot(state,picture(reader,'runs/'+name+'/'+state['label']+'.png'))
        return check
    tutorial=next(n for n,c in runs.items() if c['kind']=='complete' and c['activity']=='polygons')
    controls=next(n for n,c in runs.items() if c['kind']=='controls' and c['activity']=='polygons')
    counts['polygons']=validate_tutorial(receipts[tutorial]['case_result'],screenshots=snapshots(tutorial))
    counts['polygon_controls']=validate_polygon_controls(receipts[controls]['case_result'],screenshots=snapshots(controls))
    from pattern_controls_audit import validate_controls
    for name,contract in runs.items():
        if contract['kind']=='controls' and contract['activity']!='polygons':counts[contract['activity']+'_controls']=validate_controls(receipts[name]['case_result'])
    from media import verify_media
    return {'activities':counts,'media':verify_media(reader),'redraw_scene_cell_checks':cell_pixel_counts,'mosaic_full_scene_picture_checks':pixel_checks,'scope':'Finite Linux observations only; human hearing, teacher review, Windows and global acceptance pending'}
