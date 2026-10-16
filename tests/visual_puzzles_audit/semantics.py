# SPDX-License-Identifier: GPL-3.0-or-later
"""Finite observable contracts, kept separate from historical partial cases."""
import ast,io,json,math,re
from pathlib import Path
from PIL import Image
from store import require,sha
LEVELS={'details':21,'paintings':22,'photo_hunter':10}
PIECES={'details':106,'paintings':261}

def near(a,b,tolerance=1e-5):return abs(a-b)<=tolerance
def menu(value):require(value=={'depth':1,'busy':False,'isMenu':True},'Actual return to menu')
def center(frame,normalized):return (frame['x']-frame['width']/2+frame['width']*normalized[0],frame['y']-frame['height']/2+frame['height']*normalized[1])
def same_point(observed,expected,tolerance=1e-5):require(near(observed['x'],expected[0],tolerance) and near(observed['y'],expected[1],tolerance),'Independent visible pixel location')
def valid_bonus(source):require(source.startswith('qrc:/gcompris/src/core/resource/bonus/') and source.endswith('_good.svg'),'Actual good Bonus')
def count_levels(records,total):require(len(records)==total and [r['level'] for r in records]==list(range(1,total+1)),'Nonempty complete finite level coverage')

def photo_level(rule,record):
 initial=record['initial'];require(initial['found']==0 and initial['total']>0,'Photo initially advertises nonempty differences');require(record['wrong']['score']==initial and record['wrong']['mark']['source'].endswith('/cross.svg'),'Wrong unchanged score and physical marker')
 frame=record['frame'];size=rule['image_size']
 def point(pixel):return center(frame,[(pixel[0]+.5)/size[0],(pixel[1]+.5)/size[1]])
 same_point(record['wrong']['point'],point(rule['wrong_pixel']));progress=0;positive=0
 for attempt in record['attempts']:
  require(attempt['candidate'] in rule['candidates'],'Attempt comes from actual screenshot difference component');same_point(attempt['point'],point(attempt['candidate']['pixel']));before=attempt['before'];after=attempt['after']
  require(before['found']==progress and before['total']==after['total']==initial['total'] and after['found'] in [progress,progress+1],'Honest photo counter progression');require(len(attempt['circles'])==after['found'],'Painted found circles follow public counter')
  positive+=after['found']-progress;progress=after['found']
 require(record['complete']['found']==record['complete']['total']==initial['total']==progress and positive==progress,'All advertised visible differences, no empty completion');valid_bonus(record['bonus']);return positive

def placement_board(rule,board,strict_model=False):
 require(board['frame']['source']==rule['background'],'Actual displayed background identity');placements=board['placements'];answers=rule['answers'];require(len(placements)==len(answers) and {p['piece'] for p in placements}==set(answers),'Every distinct visible piece placed once')
 for placement in placements:
  expected=answers[placement['piece']];target=placement['target'];match=target['pixelMatch'];same_point(target,center(board['frame'],expected['center']))
  require(match['piece_sha256']==expected['piece_sha256'] and all(near(a,b) for a,b in zip(match['center'],expected['center'])),'Raw image bytes and independently recalculated center')
  if 'pixel_box' in expected:require(all(match[key]==expected[key] for key in ['pixel_box','top_left','mean_sample_error','sample_count','equal_minima']),'Recomputed detail template match')
  if 'visible_circle_index' in expected:
   require(match['visible_circle_index']==expected['visible_circle_index'],'Recomputed opaque-ID painting arrangement')
   if strict_model:require(match['method']==expected['method'] and match['pixel_model']==expected['pixel_model'],'Recomputed painting model method and every diagnostic')
 wrong=board['wrong'];require(len(wrong)==2 and len(board['errors'])>=2,'Two deliberately swapped pieces visibly rejected')
 for i,move in enumerate(wrong):
  require(move['source']==placements[i]['piece'] and move['placed']['source']==move['source'],'Actual wrong piece drag and painted placement')
  same_point(move['target'],(placements[1-i]['target']['x'],placements[1-i]['target']['y']));same_point(move['placed'],(move['target']['x'],move['target']['y']),1.)
  require(any(error['source'].endswith('/error.svg') and math.hypot(error['x']-move['target']['x'],error['y']-move['target']['y'])<1.5 for error in board['errors']),'Physical error marker at deliberately wrong position')
 valid_bonus(board['bonus']);return len(placements)

def catalogue(raw):
 result={}
 for block in re.split(r'\n\s*\n',raw.decode()):
  fields={};key=None
  for line in block.splitlines():
   match=re.match(r'(msgctxt|msgid|msgstr) (".*")$',line)
   if match:key=match[1];fields[key]=ast.literal_eval(match[2])
   elif line.startswith('"') and key:fields[key]+=ast.literal_eval(line)
  if 'msgid' in fields:result[(fields.get('msgctxt',''),fields['msgid'])]=fields.get('msgstr','')
 return result

def captions(reader,receipts):
 pairs={};runs=reader.capture['runs'];sources=reader.capture['sources'];mismatches=0;total_records=0;changed_translations={}
 for name,contract in runs.items():
  if contract['kind']!='captions':continue
  pairs.setdefault(contract['activity'],[]).append(name)
 require(set(pairs)=={'details','paintings'} and all(len(names)==2 for names in pairs.values()),'Two independent caption red/green pairs')
 for activity,names in pairs.items():
  red=next(name for name in names if runs[name]['expected_exit']==1);green=next(name for name in names if runs[name]['expected_exit']==0);rs=sources[runs[red]['source']]['files'];gs=sources[runs[green]['source']]['files'];expected_path='tests/functional_visual_puzzles/expected-titles.json'
  require(reader.artifact('runs/'+red+'/case.qml')==reader.artifact('runs/'+green+'/case.qml') and rs[expected_path]==gs[expected_path],'Exactly identical lexical case and researched expectations')
  require(set(rs)==set(gs) and {p for p in rs if rs[p]!=gs[p]}=={'poqm/pt/gcompris_qt.po','tests/functional_visual_puzzles/build_oracle.py'},'Caption production changes restrict to PT catalogue; only unrelated frozen build_oracle relocation helper also differs')
  before=catalogue(reader.blob(rs['poqm/pt/gcompris_qt.po']));after=catalogue(reader.blob(gs['poqm/pt/gcompris_qt.po']));require(set(before)==set(after),'Caption English bindings unchanged')
  for key in before:
   if before[key]!=after[key]:changed_translations[key]=(before[key],after[key])
  expected=json.loads(reader.blob(gs[expected_path]))[activity];left=receipts[red]['case_result'];right=receipts[green]['case_result'];count_levels(left['records'],LEVELS[activity]);count_levels(right['records'],LEVELS[activity]);total_records+=len(right['records'])
  def wrong(records):return [{'level':row['level'],'observed':row['text'],'expected':expected[str(row['level'])]} for row in records if str(row['level']) in expected and row['text']!=expected[str(row['level'])]]
  bad=wrong(left['records']);require(left['mismatches']==bad and len(bad)==len(expected) and right['mismatches']==[] and wrong(right['records'])==[],'Exact researched red mismatch/green caption observations');mismatches+=len(bad)
  require(all(a['text']==b['text'] for a,b in zip(left['records'],right['records']) if str(a['level']) not in expected),'Other public captions preserved')
 require(mismatches==len(changed_translations)==6 and total_records==43,'Six corrected PT messages and43records per lexical color')
 return {'caption_infrastructure_difference':'build_oracle.py adds a base parameter; not executed by the identical caption QML cases','caption_pairs':2,'caption_red_mismatches':6,'caption_green_mismatches':0,'caption_records_per_color':43}

def validate(reader,receipts):
 runs=reader.capture['runs'];require(runs,'No finite observations')
 for kind in ['inventory','complete','controls']:
  selected=[r['activity'] for r in runs.values() if r['kind']==kind];require(sorted(selected)==sorted(LEVELS),'One final finite contract per activity and kind; historical cases are separate')
 require(sum(r['kind']=='calibration' for r in runs.values())==1,'Neutral painting calibration required')
 require(all(r['kind'] in ['inventory','calibration','complete','controls','negative','pilot','captions'] for r in runs.values()),'Unsupported proof role')
 require(sum(r['kind']=='negative' for r in runs.values())>=4 and sum(r['kind']=='pilot' for r in runs.values())==1,'Historical fixture/oracle negatives and pilot retained separately')
 expected_algorithms={'tests/functional_visual_puzzles/pixels.py','tests/painting_pixel_solver/solver.py','tests/painting_pixel_solver/observation.py','tests/painting_rectangular_solver/__init__.py','tests/painting_rectangular_solver/solver.py'}
 require(set(reader.capture.get('algorithms',{}))==expected_algorithms,'Every external pixel algorithm bound to its final frozen source')
 for path,digest in reader.capture['algorithms'].items():require(sha((Path(__file__).resolve().parents[2]/path).read_bytes())==digest,'External pixel algorithm differs from physically frozen phase')
 from recompute import oracles
 inventory,answers=oracles(reader,receipts,runs)
 for activity,boards in inventory.items():
  count_levels(boards,LEVELS[activity]);require(all(b['total']==LEVELS[activity] for b in boards),'Public finite total on every inventoried board')
  if activity in PIECES:
   require(all(len(b['drawnCircles'])==len({p['source'] for page in b['pages'] for p in page})>1 for b in boards),'One visible slot for every public distinct piece')
   require(sum(len({p['source'] for page in b['pages'] for p in page}) for b in boards)==PIECES[activity],'Every public piece and sidebar page inventoried')
 calibration=next(receipts[n]['case_result']['boards'] for n,c in runs.items() if c['kind']=='calibration');count_levels(calibration,22);require(all(b['total']==22 for b in calibration),'All22neutral calibration observations')
 summary={'details_boards':0,'detail_pieces':0,'painting_boards':0,'painting_pieces':0,'photo_levels':0,'photo_positive_clicks':0,'photo_differences':0,'wrong_repaired':0,'natural_bonus':0,'controls':0,'historical_partial_painting_wins':0}
 for name,contract in runs.items():
  result=receipts[name]['case_result'];activity=contract['activity'];kind=contract['kind']
  if kind=='complete':
   total=LEVELS[activity];marker={'details':'DETAIL','paintings':'PAINTING','photo_hunter':'PHOTO'}[activity];observed=re.findall(r'^qml: '+marker+r'_HEARTBEAT (\d+) (\d+)$',reader.artifact('runs/'+name+'/native.log').decode(),re.M);require(observed==[(str(i),str(i)) for i in range(1,total+1)],'Natural level/Bonus heartbeats in raw Qt log')
  if kind=='complete' or kind=='pilot' or (kind=='negative' and 'completed_prefix' in contract):
   if activity=='photo_hunter':
    rows=result['levels'];count_levels(rows,10);require(result['wins']==10,'All photo Bonus signals');positive=sum(photo_level(answers[activity][r['level']],r) for r in rows);require(positive==sum(r['complete']['total'] for r in rows)==35,'All35actual photo differences')
    summary.update(photo_levels=10,photo_positive_clicks=positive,photo_differences=35);summary['wrong_repaired']+=10;summary['natural_bonus']+=10;menu(result['evidence']['menuAfterSuccess']);continue
   count=LEVELS[activity] if kind=='complete' else len(contract['levels']) if kind=='pilot' else contract['completed_prefix'];boards=result['boards'];count_levels(boards,count);require(result['wins']==count,'Actual natural Bonus count')
   total=sum(placement_board(answers[activity][b['level']],b,strict_model=kind=='complete') for b in boards)
   if kind=='complete':
    require(total==PIECES[activity] and result['moves']==total+2*count,'Finite successful drags plus two repairs per board');menu(result['evidence']['menuAfterSuccess']);ready=result['evidence']['validationReadiness'];require(len(ready)==2*count and all(x['after']['enabled'] is True and x['after']['pose']['width']>60 for x in ready),'Waited actual validation control readiness')
    summary['details_boards' if activity=='details' else 'painting_boards']=count;summary['detail_pieces' if activity=='details' else 'painting_pieces']=total;summary['wrong_repaired']+=count;summary['natural_bonus']+=count
   elif kind=='negative':require(activity=='paintings' and count==19 and result['failures']==1 and 'menuAfterSuccess' not in result['evidence'],'Historical failed pixel oracle remains partial');summary['historical_partial_painting_wins']=19
  if kind=='controls':
   e=result['evidence'];menu(e['menuDuringActivity'])
   if activity!='photo_hunter':
    require(e['levels']==LEVELS[activity] and all(e.get(k) is True for k in ['partialRestartByNavigation','keyboardDropDelete','keyboardAfterHelp','helpPortuguese']),'Real navigation/restart/keyboard/help/focus controls')
    if activity=='details':require([d['levels'] for d in e['datasets']]==[8,6,7] and all(len([r for r in d['labels'] if r['checked']])==1 for d in e['datasets']),'All three offered detail datasets selected')
    else:require(e['datasets']==[],'Painting dataset configuration is not offered')
   else:require(e['partialRestart'] is True and e['mouseAfterHelp'] is True and 'diferenças' in e['help']['manual'] and e['hint']['after']['value']>.7 and e['hint']['after']['opacity']<.3,'Actual photo restart/help/mouse/hint slider')
   summary['controls']+=1
 require((summary['details_boards'],summary['detail_pieces'],summary['painting_boards'],summary['painting_pieces'],summary['photo_levels'],summary['photo_differences'],summary['natural_bonus'],summary['wrong_repaired'],summary['controls'])==(21,106,22,261,10,35,53,53,3),'Complete final finite coverage, no historical substitution')
 from media import verify_media
 summary.update(verify_media(reader));summary.update(captions(reader,receipts));summary.update(scope='Linux/software/offline only; host Qt libraries/plugins/libc were not sealed; pure portable verification is not autonomous native replay; Windows/devices/human audio/teacher acceptance pending')
 return summary
