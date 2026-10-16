#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-or-later
"""Audit immutable native receipts against image semantics and actual drawn geometry."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import sys
import tempfile
from PIL import Image
sys.dont_write_bytecode=True
from archive import verify as verify_archive

if not __debug__:raise RuntimeError('Evidence checks require assertions; run without optimisation')
SOURCE='7276bb59230a4947ba32b32715d5da2025d94eb3'
ARCHIVE='6f601572ca7782df2226e5f5d66f4dd7ad8a136a35e54e639779a7946550a8b3'
CAPTURE='eedee85f435c10b3829ab6c0528d846c4b2762751536d47ef474eff4304cb32e'
DEFAULT=Path(__file__).resolve().parents[2]/'.scratch/pt-pt/functional-association'
NAMES=('babymatch','babyshapes','imagename')


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def load(path,name):
    spec=importlib.util.spec_from_file_location(name,path);module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module);return module


def near(a,b):return abs(a['x']-b['x'])<0.01 and abs(a['y']-b['y'])<0.01


def closest(circles,point):return min(circles,key=lambda c:(c['x']-point['x'])**2+(c['y']-point['y'])**2)


def expected(activity,piece,observed,oracle):
    circles=observed['circles'];base=Path(piece).name
    if activity=='babymatch':
        matches=[image for image in observed['backgrounds'] for left,right,reason in oracle['semantic']['relations'] if left==base and Path(image['image']).name==right]
        assert len(matches)==1;return closest(circles,matches[0])
    if activity=='imagename':
        name=oracle['semantic']['names'][base];labels=[label for label in observed['labels'] if label['text']==name];assert len(labels)==1
        return closest([c for c in circles if c['y']<labels[0]['y']],labels[0])
    if piece in oracle['silhouettes']:
        target=oracle['silhouettes'][piece]['target'];matches=[image for image in observed['backgrounds'] if image['image']==target];assert len(matches)==1
        return closest(circles,matches[0])
    if piece in oracle['semantic']['dog']:
        rule=oracle['semantic']['dog'][piece]['rule'];return min(circles,key=lambda c:c['y'] if rule=='topmost' else c['x'] if rule=='leftmost' else -c['x'])
    hole=oracle['holes'][piece];frame=observed['frame'];assert frame['image']==hole['background']
    return closest(circles,{'x':frame['x']+frame['width']*(hole['center'][0]-.5),'y':frame['y']+frame['height']*(hole['center'][1]-.5)})


def native(root,relative,activity,case,source,catalogue=None,red=False):
    directory=root/relative;result=json.loads((directory/'result.json').read_text());status=json.loads((directory/'launcher-status.json').read_text())
    assert result['activity']==activity and result['locale']=='pt_PT' and result['network']=='docker-none'
    assert result['source_sha256']==sha(source/'src/activities/babymatch/Babymatch.qml')
    assert result['case_sha256']==status['case_sha256']==sha(case)
    assert result['runner_sha256']==status['launcher_sha256']==sha(source/'tools/run-native-qml-case.py')
    assert result['portuguese_catalogue_sha256']==sha(catalogue or source/'poqm/pt/gcompris_qt.po')
    assert result['exit_code']==0 and not result['timeout'] and not result['qml_errors'] and result['private_file_ownership_verified']
    assert result['passed']==(not red) and result['case_result']['failures']==(1 if red else 0)
    assert result['case_result']['passes']==(1 if red else 2)
    assert status['format']==1 and status['kind']=='observed-subprocess-exit' and status['exit_code']==(1 if red else 0)
    assert status['native_receipt_sha256']==sha(directory/'result.json')
    original=json.loads((source.parent/'snapshot-manifest.json').read_text())['files'];expected_files=dict(original)
    expected_files['share/gcompris-qt/rcc/babymatch.rcc']=result['private_rcc_sha256'];expected_files['share/gcompris-qt/translations/gcompris_qt_pt.qm']=result['private_qm_sha256']
    assert result['resource_files_sha256']==expected_files and len(original)==269
    assert result['resource_manifest_sha256']==sha(source.parent/'snapshot-manifest.json') and result['binary_sha256']==original['bin/gcompris-qt']
    for image in result['screenshots']:
        assert sha(directory/image['file'])==image['sha256']
        with Image.open(directory/image['file']) as photo:photo.verify()
    return result['case_result'],result


def pixels(directory,row,portrait=False):
    prefix='level-'+str(row['level'])+'-board-'+str(row['sublevel'])
    with Image.open(directory/(prefix+'-question.png')) as image:
        image=image.convert('RGB')
        for circle in row['observed']['circles']:
            color=circle['color'];assert len(color)==7
            expected_rgb=tuple(int(color[i:i+2],16)for i in (1,3,5));actual=image.getpixel((round(circle['x']),round(circle['y'])))
            if portrait and row['sublevel']==3 and abs(circle['x']-536.5765876)<.01:
                # Actual caption covers this centre; this is an explicit visual limit.
                assert actual==(232,232,232)
            else:assert max(abs(a-b)for a,b in zip(actual,expected_rgb))<8
    with Image.open(directory/(prefix+'-wrong.png')) as image:
        image=image.convert('RGB')
        for error in row['errors']:
            x,y,w,h=error['x'],error['y'],error['width'],error['height']
            patch=image.crop((int(x-w/2),int(y-h/2),int(x+w/2),int(y+h/2)))
            assert sum(1 for r,g,b in list(patch.get_flattened_data() if hasattr(patch,'get_flattened_data') else patch.getdata()) if r>170 and g<120 and b<120)>3


def verify(root):
    assert sha(root/'archive/manifest.json')==ARCHIVE
    manifest=verify_archive(root/'archive');assert manifest['source_commit']==SOURCE
    assert CAPTURE!='PENDING' and sha(root/'capture.json')==CAPTURE
    capture=json.loads((root/'capture.json').read_text())
    for relative,identity in capture['files'].items():
        path=root/relative;assert path.is_file() and not path.is_symlink() and sha(path)==identity['sha256'] and path.stat().st_size==identity['bytes'],relative
    source=root/'archive/files';qa=source/'tests/functional_association';sys.path.insert(0,str(qa))
    inventory=load(qa/'inventory.py','frozen_association_inventory').collect(source)
    builder=load(qa/'build_oracle.py','frozen_association_builder')
    with tempfile.TemporaryDirectory(prefix='association-oracle-') as temporary:oracle=builder.build(source,Path(temporary))
    assert json.loads(json.dumps(oracle))==json.loads((qa/'visual-oracle.json').read_text())
    resources=load(qa/'resources.py','frozen_association_resources')
    report={'scope':'Linux Qt offline; Windows, physical input/audio and teacher pending','source_commit':SOURCE,'capture_commit':capture['capture_commit'],'levels':21,'boards':0,'associations':0,'wrong_boards':0,'natural_bonus':0,'native_positive_cases':10,'resource_copies':0,'question_pixels':0,'error_icons':0}
    for activity in NAMES:
        records=[b for b in inventory if b['activity']==activity]
        case,result=native(root,'final/'+activity+'-complete',activity,qa/'complete.qml',source)
        assert case['activity']==activity and case['wins']==7 and case['wrong']==len(records)==len(case['boards'])
        assert [(b['level'],b['sublevel'])for b in case['boards']]==[(b['level'],b['sublevel'])for b in records]
        for row,authored in zip(case['boards'],records):
            declared=sorted(p['pixmapfile']for p in authored['parts']if p.get('type') is None);observed=row['observed'];plan=row['pieces']
            assert sorted(p['piece']for p in plan)==declared and len(plan)==len(observed['circles'])
            assert len({(round(c['x'],3),round(c['y'],3))for c in observed['circles']})==len(plan)
            for piece in plan:assert piece['reason'] and near(piece['target'],expected(activity,piece['piece'],observed,oracle))
            assert len({(round(p['target']['x'],3),round(p['target']['y'],3))for p in plan})==len(plan)
            assert row['wrongPlacements'][0]['piece']==plan[0]['piece'] and near(row['wrongPlacements'][0]['target'],plan[1]['target'])
            assert row['wrongPlacements'][1]['piece']==plan[1]['piece'] and near(row['wrongPlacements'][1]['target'],plan[0]['target'])
            assert len(row['errors'])>=2;pixels(root/'final'/(activity+'-complete'),row)
            if activity=='imagename':assert sorted(label['text']for label in observed['labels'])==sorted(oracle['semantic']['names'][Path(p).name]for p in declared)
            report['boards']+=1;report['associations']+=len(plan);report['question_pixels']+=len(plan);report['error_icons']+=len(row['errors'])
        assert case['moves']==sum(len(b['pieces'])+2 for b in case['boards'])
        report['natural_bonus']+=case['wins'];report['wrong_boards']+=case['wrong']
        controls,_=native(root,'final/'+activity+'-controls',activity,qa/'controls.qml',source)
        evidence=controls['evidence'];assert evidence['levels']==7
        assert all(evidence[key]for key in ('noConfiguration','partialRestartByNavigation','previousNextWrap','keyboardDropDelete','keyboardAfterHelp','helpPortuguese','home'))
        resource_case,_=native(root,'final/'+activity+'-resources',activity,qa/(activity+'-resources.qml'),source)
        assert resource_case['resources']==resources.paths(activity,source)
        for relative in resource_case['resources']:assert sha(root/'final'/(activity+'-resources')/'resources'/relative)==sha(source/relative)
        report['resource_copies']+=len(resource_case['resources'])
    assert (report['boards'],report['associations'],report['wrong_boards'],report['natural_bonus'])==(25,119,25,21)
    portrait,result=native(root,'final/babyshapes-edge-portrait','babyshapes',qa/'edge-portrait.qml',source)
    assert portrait['wins']==1 and portrait['wrong']==5 and len(portrait['boards'])==5
    for row in portrait['boards']:
        for piece in row['pieces']:assert near(piece['target'],expected('babyshapes',piece['piece'],row['observed'],oracle))
        pixels(root/'final/babyshapes-edge-portrait',row,portrait=True)
    assert all(Image.open(root/'final/babyshapes-edge-portrait'/screenshot['file']).size==(800,801) for screenshot in result['screenshots'])
    for name in [activity+'-'+kind for kind in ('complete','controls','resources')for activity in NAMES]+['babyshapes-edge-portrait']:
        process=json.loads((root/'final'/(name+'.process.json')).read_text());directory=root/'final'/name
        assert process['kind']=='observed-supervisor-subprocess-exit' and process['case']==name and process['exit_code']==0
        assert process['receipt_sha256']==sha(directory/'result.json') and process['launcher_status_sha256']==sha(directory/'launcher-status.json')
        assert process['supervisor_sha256']==sha(source/'tools/run-native-qml-supervised.py')
    outer=json.loads((root/'final-tool.json').read_text());assert outer['kind']=='observed-exec-tool-return' and outer['exit_code']==0
    assert len(outer['process_files'])==10
    for name,identity in outer['process_files'].items():assert sha(root/'final'/name)==identity
    observed=json.loads((root/'observed-tools.json').read_text())
    for name,record in observed.items():
        assert record['native_receipt_sha256']==sha(root/name/'result.json')
        assert record['launcher_status_sha256']==sha(root/name/'launcher-status.json')
    for prefix,activity,casefile,oldpo,expectedboards in (
        ('names','imagename','names-redgreen.qml','before-oveiro.po',1),
        ('edge','babyshapes','edge-redgreen.qml','before-caption.po',5),
        ('caption','babyshapes','caption-redgreen.qml','before-caption.po',5)):
        oldcatalogue=root/'history'/oldpo
        greenpo=(root/'history/before-caption.po') if prefix in ('names','edge') else None
        red,_=native(root,prefix+'-red',activity,qa/casefile,source,catalogue=oldcatalogue,red=True)
        green,_=native(root,prefix+'-green',activity,qa/casefile,source,catalogue=greenpo)
        assert green['wins']==1 and len(green['boards'])==green['wrong']==expectedboards
        assert len(red['boards'])<expectedboards
        for suffix,exitcode in (('red',1),('green',0)):
            tool=observed[prefix+'-'+suffix];assert tool['kind']=='observed-exec-tool-return' and tool['exit_code']==exitcode
    assert (root/'history/before-drop.qml').read_bytes()!= (source/'src/activities/babymatch/DragListItem.qml').read_bytes()
    audio,_=native(root,'audio-observed','imagename',root/'history/audio.qml',source)
    assert len(audio['boards'])==audio['wrong']==audio['wins']==1
    evidence=audio['audio'];assert evidence['sources'] and evidence['hasAudio'] and 1 in evidence['playbackStates']
    assert set(evidence['sources'])=={'qrc:/gcompris/src/core/resource/sounds/scroll.wav','qrc:/gcompris/data/voices-ogg/pt/misc/super.ogg'}
    assert evidence['goodSource'].endswith('/completetask.wav') and evidence['badSource'].endswith('/crash.wav')
    assert not evidence['goodPlaying'] and not evidence['badPlaying']
    assert observed['audio-observed']['exit_code']==0
    # Word boards have no word-specific voice assignment; default selection is scroll.wav.
    for board in (source/'src/activities/imagename/resource').rglob('*.qml'):
        assert 'soundFile:' not in board.read_text() and 'toolTipText:' not in board.read_text()
    assert len(json.loads((root/'audio-decode.json').read_text()))==9
    decode=load(Path(__file__).with_name('decode.py'),'association_decoder')
    for row in json.loads((root/'audio-decode.json').read_text()):
        path=root/row['file'];assert sha(path)==row['sha256'] and decode.decode(path)==row['decoded']
    report.update(native_positive_cases=14,paired_red_cases=3,additional_portrait_boards=5,portrait_occluded_centres=1,audio=evidence,decoded_wav_copies=9)
    return report


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--evidence',type=Path,default=DEFAULT);args=parser.parse_args();print(json.dumps(verify(args.evidence),ensure_ascii=False,indent=2))
