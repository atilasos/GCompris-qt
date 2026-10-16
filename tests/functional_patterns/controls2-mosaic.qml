// SPDX-License-Identifier: GPL-3.0-or-later
// Prepared controls case, not a native success receipt.
TestCase {
    id: qa
    name: 'VisiblePatternPublicControls'
    when: activity.visible && activity.numberOfLevel>0
    property var boards: []
    property var evidence: ({})
    property var registry: ({})
    property int wins: 0
    property int actions: 0
    property string activityName: ''
    Connections {target: bonus; function onWin() {qa.wins++;}}
// SPDX-License-Identifier: GPL-3.0-or-later
// Pure, current-widget geometry. No QML engine state or authored models.
function demand(value, message) {
    if (!value) throw new Error(message);
}
function opaqueKey(value) {
    if (value === null) return 'null';
    if (typeof value === 'string' || typeof value === 'boolean') return JSON.stringify(value);
    if (typeof value === 'number') {
        demand(Number.isFinite(value), 'Nonfinite signature');
        return JSON.stringify(value);
    }
    if (Array.isArray(value)) return '[' + value.map(opaqueKey).join(',') + ']';
    demand(typeof value === 'object', 'Signature must be finite JSON');
    return '{' + Object.keys(value).sort().map(k=>JSON.stringify(k)+':'+opaqueKey(value[k])).join(',') + '}';
}
function clone(value) { return JSON.parse(JSON.stringify(value)); }
function median(values) {
    var sorted = values.slice().sort((a,b)=>a-b), n = sorted.length;
    return n % 2 ? sorted[(n-1)/2] : (sorted[n/2-1]+sorted[n/2])/2;
}
function gridAxis(values, size) {
    var tolerance = size * 1e-6, groups = [];
    values.slice().sort((a,b)=>a-b).forEach(value=>{
        if (!groups.length || value-groups[groups.length-1][0] > tolerance) groups.push([value]);
        else groups[groups.length-1].push(value);
    });
    var centers = groups.map(median), steps = [];
    for (var i=1;i<centers.length;i++) steps.push(centers[i]-centers[i-1]);
    if (steps.length) {
        var step = median(steps);
        demand(steps.every(s=>s+tolerance>=size), 'Overlapping visible cells');
        demand(steps.every(s=>Math.abs(s-step)<=2*tolerance), 'Irregular visible grid');
    }
    return centers;
}
function visibleGrid(cells) {
    demand(Array.isArray(cells) && cells.length>0, 'Empty visible grid');
    cells.forEach(cell=>{
        demand(cell && cell.frame, 'Nested public frame required');
        ['x','y','width','height'].forEach(key=>demand(typeof cell.frame[key]==='number' && Number.isFinite(cell.frame[key]),'Nonfinite visible frame'));
        demand(cell.frame.width>0 && cell.frame.height>0,'Nonpositive visible frame');
    });
    var width=median(cells.map(c=>c.frame.width)), height=median(cells.map(c=>c.frame.height));
    demand(cells.every(c=>Math.abs(c.frame.width-width)<=width*1e-6 && Math.abs(c.frame.height-height)<=height*1e-6),'Inconsistent visible cell dimensions');
    var xs=gridAxis(cells.map(c=>c.frame.x),width), ys=gridAxis(cells.map(c=>c.frame.y),height), indexed=Object.create(null);
    cells.forEach(cell=>{
        var columns=[],rows=[];
        xs.forEach((x,i)=>{if(Math.abs(x-cell.frame.x)<=width*1e-6)columns.push(i);});
        ys.forEach((y,i)=>{if(Math.abs(y-cell.frame.y)<=height*1e-6)rows.push(i);});
        demand(columns.length===1 && rows.length===1,'Ambiguous visible cell membership');
        var key=rows[0]+':'+columns[0];demand(indexed[key]===undefined,'Duplicate visible cell');indexed[key]=cell;
    });
    demand(cells.length===xs.length*ys.length,'Incomplete visible rectangle');
    return {xs:xs,ys:ys,cells:indexed};
}
function visiblePlan(question, answer, palette, mirror) {
    demand(typeof mirror==='boolean','Explicit public mirror mode required');
    demand(Array.isArray(palette)&&palette.length>0,'Empty calibrated palette');
    var paints=Object.create(null),ids=Object.create(null);
    palette.forEach(sample=>{
        var signature=opaqueKey(sample.signature),id=opaqueKey(sample.id);
        demand(paints[signature]===undefined && ids[id]===undefined,'Duplicate palette signature or id');
        paints[signature]=sample;ids[id]=true;
    });
    var q=visibleGrid(question),a=visibleGrid(answer),placements=[];
    demand(q.xs.length===a.xs.length && q.ys.length===a.ys.length,'Visible grid dimensions differ');
    for(var row=0;row<q.ys.length;row++)for(var column=0;column<q.xs.length;column++) {
        var cell=q.cells[row+':'+column],key=opaqueKey(cell.signature),paint=paints[key];
        demand(paint!==undefined,'Observed signature has no calibrated palette');
        placements.push({question_frame:clone(cell.frame),target_frame:clone(a.cells[row+':'+(mirror?q.xs.length-1-column:column)].frame),signature:clone(cell.signature),palette_id:clone(paint.id)});
    }
    return {rows:q.ys.length,columns:q.xs.length,placements:placements,
            diagnostics:{method:'visible regular grid and calibrated signatures',mirror:mirror,toleranceFraction:1e-6}};
}

// SPDX-License-Identifier: GPL-3.0-or-later
function expectedTotal() {
    check(activity.activityInfo.shortName(),'mosaic','Public mosaic activity');
    return 22;
}
function publicMirror() { return false; }
function questionObjects() { return publicImages(question); }
function answerObjects() { return publicImages(answer); }
function isRenderedReady(item) { return item.status===Image.Ready; }
function paletteObjects() { return publicImages(selector); }
function renderedSignature(item) {
    var uri=String(item.source),entry=registry.images && registry.images[uri];
    ensure(entry!==undefined && typeof entry.signature==='string','Current public image has a physical RGBA signature');
    return entry.signature;
}
function paletteSignature(item) { return renderedSignature(item); }

// SPDX-License-Identifier: GPL-3.0-or-later
function ensure(value, message) {
    if (!value) evidence.failure={message:message,stack:new Error().stack};
    verify(value,message);
}
function check(actual, expected, message) {
    if (actual!==expected) evidence.failure={message:message,actual:String(actual),expected:String(expected),stack:new Error().stack};
    compare(actual,expected,message);
}
function allVisible(root) {
    var out=[];
    if (!root.visible || root.opacity<=0) return out;
    out.push(root);
    if(root.children)for(var child of root.children)out=out.concat(allVisible(child));
    return out;
}
function pose(item) {
    var center=item.mapToItem(pageView,item.width/2,item.height/2);
    var corners=[[0,0],[item.width,0],[0,item.height],[item.width,item.height]].map(p=>item.mapToItem(pageView,p[0],p[1]));
    var xs=corners.map(p=>p.x),ys=corners.map(p=>p.y);
    return {x:center.x,y:center.y,width:Math.max.apply(null,xs)-Math.min.apply(null,xs),height:Math.max.apply(null,ys)-Math.min.apply(null,ys),visible:item.visible,opacity:item.opacity};
}
function pointerClick(frame) {
    ensure(frame.x>=0 && frame.y>=0 && frame.x<pageView.width && frame.y<bar.y,'Pointer targets an actual visible activity cell');
    mouseClick(pageView,frame.x,frame.y,Qt.LeftButton,Qt.NoModifier,0);
    return {x:frame.x,y:frame.y};
}
function publicImages(root) {
    return allVisible(root).filter(o=>o.source!==undefined && o.status!==undefined && String(o.source).startsWith('qrc:/') && o.width>5 && o.height>5);
}
function frameMatches(a,b) {
    return Math.abs(a.x-b.x)<=b.width*1e-6 && Math.abs(a.y-b.y)<=b.height*1e-6;
}
function answerAt(frame) {
    var matches=answerObjects().filter(o=>frameMatches(pose(o),frame));
    check(matches.length,1,'One actual painted target at the derived geometric center');
    return matches[0];
}
function viewCells(objects) {
    return objects.map(o=>{
        var row={frame:pose(o),signature:renderedSignature(o)};
        if(o.source!==undefined){row.source=String(o.source);row.status=o.status;}
        else row.color=String(o.color);
        return row;
    });
}
function paletteViews() {
    return paletteObjects().map(o=>{ensure(o.status===Image.Ready,'Palette image is actually ready');return {id:String(o.source),signature:paletteSignature(o),frame:pose(o)};});
}
function paint(placement, signature, role, record) {
    var visiblePalette=paletteViews(),matches=visiblePalette.filter(p=>opaqueKey(p.signature)===opaqueKey(signature));
    check(matches.length,1,'Exactly one current visible calibrated paint');
    var palette=matches[0],icons=paletteObjects().filter(o=>String(o.source)===palette.id);
    check(icons.length,1,'Public image URI identifies one physical palette icon');
    var entry={role:role,target:clone(placement.target_frame),expected_signature:clone(signature),palette:{id:palette.id,signature:clone(palette.signature),frame:pose(icons[0])},before:viewCells([answerAt(placement.target_frame)])[0]};
    record.actions.push(entry);
    entry.selection=pointerClick(entry.palette.frame);
    wait(30);
    entry.click=pointerClick(pose(answerAt(placement.target_frame)));
    actions++;
    tryVerify(()=>{var actual=answerAt(placement.target_frame);return isRenderedReady(actual) && opaqueKey(renderedSignature(actual))===opaqueKey(signature);},2500,'Wait for the actual ready rendered color/image, including ColorAnimation');
    entry.after=viewCells([answerAt(placement.target_frame)])[0];
    return entry;
}
function differentlyPainted(signature) {
    var alternatives=paletteViews().filter(p=>opaqueKey(p.signature)!==opaqueKey(signature));
    ensure(alternatives.length>0,'A visibly different current calibrated paint exists');
    alternatives.sort((a,b)=>a.frame.y-b.frame.y || a.frame.x-b.frame.x);
    return alternatives[0];
}
function staysWrong(level, beforeWins, holdout, record) {
    check(activity.currentLevel,level-1,'No premature level advance');
    check(wins,beforeWins,'No premature Win signal');
    ensure(!bonus.isPlaying,'No Bonus while a painted target is wrong');
    var wrong=renderedSignature(answerAt(holdout.target_frame));
    ensure(opaqueKey(wrong)!==opaqueKey(holdout.signature),'The holdout is physically painted with a different signature');
    record.plan.placements.forEach(p=>{
        if(!frameMatches(p.target_frame,holdout.target_frame))check(opaqueKey(renderedSignature(answerAt(p.target_frame))),opaqueKey(p.signature),'All other actual targets are already correct');
    });
}

// SPDX-License-Identifier: GPL-3.0-or-later
function cursorFrameMatches(a,b) {
    var dx=Math.abs(a.x-b.x),dy=Math.abs(a.y-b.y),matches=dx<=1&&dy<=1;
    if(matches&&(dx>1e-6||dy>1e-6)){
        if(!evidence.cursorRoundingObservations)evidence.cursorRoundingObservations=[];
        evidence.cursorRoundingObservations.push({cursor:a,cell:b,dx:dx,dy:dy,limit:1});
    }
    return matches;
}
// Prepared UI controls. No authored answer/state indices are read or assigned.
function ctrlClick(item) {
    var p=pose(item);
    ensure(p.x>=0 && p.y>=0 && p.x<pageView.width && p.y<pageView.height,'Control is physically inside the scene');
    mouseClick(pageView,p.x,p.y,Qt.LeftButton,Qt.NoModifier,0);wait(100);
    return {frame:p,click:{x:p.x,y:p.y}};
}
function ctrlIcon(suffix) {
    var found=allVisible(bar).filter(o=>o.source!==undefined && String(o.source).endsWith(suffix) && o.width>5);
    check(found.length,1,'One offered bar control '+suffix);
    return ctrlClick(found[0]);
}
function ctrlKey(name,key) {
    keyClick(key);wait(70);evidence.keys.push(name);
}
function ctrlReady() {
    tryVerify(()=>questionObjects().length>0 && questionObjects().every(isRenderedReady) && answerObjects().length>0 && answerObjects().every(isRenderedReady) && paletteObjects().length>1 && paletteObjects().every(o=>o.status===Image.Ready),4000);
    wait(250);
}
function ctrlPlan() {
    try {return visiblePlan(viewCells(questionObjects()),viewCells(answerObjects()),paletteViews(),publicMirror());}
    catch(error){evidence.failure={message:'Control plan refused',error:String(error)};verify(false,String(error));}
}
function ctrlNavigate(next) {
    var before=activity.currentLevel,total=activity.numberOfLevel;
    var event=ctrlIcon(next?'bar_next.svg':'bar_previous.svg');
    tryCompare(activity,'currentLevel',(before+(next?1:total-1))%total,2500);ctrlReady();
    return {before:before,after:activity.currentLevel,event:event,total:total};
}
function ctrlChooseTwoDimensionalLevel() {
    var limit=activity.numberOfLevel;
    for(var step=0;step<limit;step++) {
        ctrlReady();var current=ctrlPlan();
        evidence.levelSearch.push({level:activity.currentLevel+1,rows:current.rows,columns:current.columns,palette:paletteViews()});
        var requiredPaints=activityName==='mosaic'?3:registry.palette_samples[activityName].length;
        if(current.rows>1 && current.columns>1 && paletteViews().length>=requiredPaints)return current;
        ctrlNavigate(true);
    }
    ensure(false,'A public two-dimensional level offers the required visible palette');
}
function ctrlCursor(area) {
    if(activityName!=='mosaic')return rectangles(drawingArea).filter(o=>o.border.width>=3);
    return allVisible(area).filter(o=>o.color!==undefined && String(o.color)==='#ff0000' && o.border!==undefined && o.border.width>0 && Math.abs(o.opacity-0.5)<1e-6 && o.width>5);
}
function ctrlCursorFrame(area) {
    var found=ctrlCursor(area);check(found.length,1,'One actually drawn keyboard cursor');return pose(found[0]);
}
function ctrlAwaitCursor(area,frame) {
    tryVerify(()=>ctrlCursor(area).length===1 && cursorFrameMatches(pose(ctrlCursor(area)[0]),frame),2500,'Keyboard cursor reaches the visible geometric neighbor');
    return ctrlCursorFrame(area);
}
function ctrlAlignedCursor(area) {
    tryVerify(()=>ctrlCursor(area).length===1 && answerObjects().some(o=>cursorFrameMatches(pose(o),pose(ctrlCursor(area)[0]))),2500,'Wait until the painted keyboard highlight aligns with a visible cell');
    return ctrlCursorFrame(area);
}
function ctrlMoveCursorToTopLeft(area) {
    var grid=visibleGrid(viewCells(answerObjects())),limit=grid.xs.length+grid.ys.length+2;ctrlAlignedCursor(area);
    for(var i=0;i<limit && ctrlCursorFrame(area).x>grid.xs[0]+1e-4;i++){ctrlKey('Left',Qt.Key_Left);ctrlAlignedCursor(area);}
    for(var j=0;j<limit && ctrlCursorFrame(area).y>grid.ys[0]+1e-4;j++){ctrlKey('Up',Qt.Key_Up);ctrlAlignedCursor(area);}
    return ctrlAwaitCursor(area,grid.cells['0:0'].frame);
}
function ctrlArrowRoundTrip(area) {
    var grid=visibleGrid(viewCells(answerObjects())),record=[];
    ctrlMoveCursorToTopLeft(area);
    var steps=[['Right',Qt.Key_Right,'0:1'],['Left',Qt.Key_Left,'0:0'],['Down',Qt.Key_Down,'1:0'],['Up',Qt.Key_Up,'0:0']];
    steps.forEach(step=>{
        var before=ctrlCursorFrame(area);ctrlKey(step[0],step[1]);
        record.push({key:step[0],before:before,after:ctrlAwaitCursor(area,grid.cells[step[2]].frame)});
    });
    return record;
}
function ctrlKeyboardRedraw(label) {
    var record={label:label,actions:[],before:viewCells(answerObjects())},plan=ctrlPlan();
    var wrong=plan.placements.filter(p=>opaqueKey(renderedSignature(answerAt(p.target_frame)))!==opaqueKey(p.signature));
    ensure(wrong.length>=2,'Other visible errors prevent premature keyboard completion');
    var first=visibleGrid(viewCells(answerObjects())).cells['0:0'].frame;
    mouseMove(pageView,first.x,first.y,60);
    tryVerify(()=>ctrlCursor(drawingArea).length===1,2000);
    record.arrows=ctrlArrowRoundTrip(drawingArea);
    var frame=ctrlCursorFrame(drawingArea),blank=renderedSignature(answerAt(frame));
    var labels=allVisible(colorSelector).filter(o=>o.text!==undefined && /^[0-9]$/.test(String(o.text)) && o.width>5);
    var icons=paletteViews(),offered=[];
    labels.forEach(text=>{
        var p=pose(text),near=icons.map(icon=>({icon:icon,distance:Math.hypot(icon.frame.x-p.x,icon.frame.y-p.y)})).sort((a,b)=>a.distance-b.distance);
        ensure(near.length>0 && (!near[1] || near[0].distance<near[1].distance),'Visible digit label identifies one palette icon geometrically');
        offered.push({digit:String(text.text),frame:p,palette:near[0].icon});
    });
    ensure(offered.length>1,'Public numeric palette labels are drawn');
    var candidates=offered.filter(o=>opaqueKey(o.palette.signature)!==opaqueKey(blank));
    ensure(candidates.length>0,'A labelled paint changes the current visible blank');
    candidates.sort((a,b)=>a.frame.y-b.frame.y || a.frame.x-b.frame.x);
    var selected=candidates[0];record.offeredDigits=offered;record.selectedDigit=selected;record.digits=[];
    check(offered.map(o=>o.digit).filter((digit,i,values)=>values.indexOf(digit)===i).length,offered.length,'Each offered digit is visibly unique');
    offered.forEach(shortcut=>{
        if(renderedSignature(answerAt(frame))===shortcut.palette.signature) {
            var seed=paletteViews().find(p=>p.signature!==shortcut.palette.signature);
            ensure(seed!==undefined,'A different visible seed makes the numeric shortcut effect observable');
            paint({target_frame:frame},seed.signature,'numeric-shortcut-seed',record);
        }
        var before=viewCells([answerAt(frame)])[0];
        ctrlKey('Digit '+shortcut.digit,Qt.Key_0+Number(shortcut.digit));ctrlKey('Space after digit '+shortcut.digit,Qt.Key_Space);
        tryVerify(()=>renderedSignature(answerAt(frame))===shortcut.palette.signature,2500);
        var after=viewCells([answerAt(frame)])[0];ensure(before.signature!==after.signature,'Every offered numeric shortcut visibly changes the paint');
        record.digits.push({shortcut:shortcut,before:before,after:after});check(wins,0);ensure(!bonus.isPlaying);
    });
    ctrlKey('Delete after numeric shortcuts',Qt.Key_Delete);tryVerify(()=>renderedSignature(answerAt(frame))===blank,2500);
    ctrlKey('Digit '+selected.digit,Qt.Key_0+Number(selected.digit));
    [['Space',Qt.Key_Space],['Return',Qt.Key_Return],['Enter',Qt.Key_Enter]].forEach(step=>{
        var before=viewCells([answerAt(frame)])[0];ctrlKey(step[0],step[1]);
        tryVerify(()=>renderedSignature(answerAt(frame))===selected.palette.signature,2500);
        var after=viewCells([answerAt(frame)])[0];ensure(before.signature!==after.signature,'Keyboard painting visibly changes the cell');
        record.actions.push({key:step[0],before:before,after:after,signature:selected.palette.signature});
        check(wins,0,'No Bonus conclusion in a controls case');ensure(!bonus.isPlaying,'Other visible errors still prevent success');
        var deletion=step[0]==='Return'?['Backspace',Qt.Key_Backspace]:['Delete',Qt.Key_Delete];
        ctrlKey(deletion[0],deletion[1]);tryVerify(()=>renderedSignature(answerAt(frame))===blank,2500);
        record.actions.push({key:deletion[0],after:viewCells([answerAt(frame)])[0],expected_blank:blank});
    });
    record.after=viewCells(answerObjects());return record;
}
function ctrlMosaicAnswerFocus() {
    ctrlKey('Right to expose keyboard cursor',Qt.Key_Right);
    for(var i=0;i<3 && ctrlCursor(answer).length!==1;i++)ctrlKey('Tab to answer',Qt.Key_Tab);
    tryVerify(()=>ctrlCursor(answer).length===1,2000);
}
function ctrlMosaicChooseDifferent(excluded) {
    ctrlKey('Tab to selector',Qt.Key_Tab);
    tryVerify(()=>ctrlCursor(selector).length===1,2000);
    var offered=paletteViews();
    for(var step=0;step<=offered.length;step++) {
        tryVerify(()=>ctrlCursor(selector).length===1 && paletteViews().some(p=>cursorFrameMatches(p.frame,pose(ctrlCursor(selector)[0]))),2500,'Wait until the selector highlight reaches an actual image');
        var current=ctrlCursorFrame(selector),matches=paletteViews().filter(p=>cursorFrameMatches(p.frame,current));
        check(matches.length,1,'Drawn selector cursor identifies one public image');
        if(excluded.every(signature=>opaqueKey(signature)!==opaqueKey(matches[0].signature)))return matches[0];
        ctrlKey('Right in selector',Qt.Key_Right);
    }
    ensure(false,'Selector keyboard can reach a visibly different paint');
}
function ctrlKeyboardMosaic(label) {
    var record={label:label,actions:[],before:viewCells(answerObjects())};ctrlMosaicAnswerFocus();
    record.arrows=ctrlArrowRoundTrip(answer);
    var frame=ctrlCursorFrame(answer),plan=ctrlPlan(),placement=plan.placements.find(p=>cursorFrameMatches(p.target_frame,frame));
    ensure(placement!==undefined,'Cursor corresponds to a current public geometric target');
    [['Space',Qt.Key_Space],['Return',Qt.Key_Return],['Enter',Qt.Key_Enter]].forEach(step=>{
        var before=viewCells([answerAt(frame)])[0],choice=ctrlMosaicChooseDifferent([before.signature,placement.signature]);
        ctrlKey(step[0]+' select image',step[1]);
        ctrlKey('Tab to answer',Qt.Key_Tab);ctrlAwaitCursor(answer,frame);
        ctrlKey(step[0]+' paint target',step[1]);
        tryVerify(()=>isRenderedReady(answerAt(frame)) && renderedSignature(answerAt(frame))===choice.signature,2500);
        var after=viewCells([answerAt(frame)])[0];ensure(before.signature!==after.signature,'Keyboard image selection and painting visibly change the target');
        check(wins,0);ensure(!bonus.isPlaying,'The keyboard target deliberately remains visibly wrong');
        record.actions.push({key:step[0],selected:choice,before:before,after:after,expected_question_signature:placement.signature});
    });
    record.after=viewCells(answerObjects());return record;
}
function ctrlDragRedraw() {
    var plan=ctrlPlan(),grid=visibleGrid(viewCells(answerObjects()));
    var first=plan.placements.find(p=>cursorFrameMatches(p.target_frame,grid.cells['0:0'].frame)),second=plan.placements.find(p=>cursorFrameMatches(p.target_frame,grid.cells['0:1'].frame));
    var guard=plan.placements.find(p=>!cursorFrameMatches(p.target_frame,first.target_frame)&&!cursorFrameMatches(p.target_frame,second.target_frame));
    ensure(guard!==undefined,'An independent visible guard prevents drag completion');
    var record={actions:[],before:viewCells(answerObjects())};
    record.guard=paint(guard,differentlyPainted(guard.signature).signature,'drag-guard',record);
    var beforeFirst=viewCells([answerAt(first.target_frame)])[0],beforeSecond=viewCells([answerAt(second.target_frame)])[0];
    var palettes=paletteViews().filter(p=>p.signature!==beforeFirst.signature && p.signature!==beforeSecond.signature);
    ensure(palettes.length>0,'A drag paint differs from both actual cells');
    var selected=palettes[0],icon=paletteObjects().filter(o=>String(o.source)===selected.id);check(icon.length,1);record.selection=ctrlClick(icon[0]);
    var a=pose(answerAt(first.target_frame)),b=pose(answerAt(second.target_frame));
    mousePress(pageView,a.x,a.y,Qt.LeftButton,Qt.NoModifier,0);
    for(var i=1;i<=14;i++)mouseMove(pageView,a.x+(b.x-a.x)*i/14,a.y+(b.y-a.y)*i/14,30);
    mouseRelease(pageView,b.x,b.y,Qt.LeftButton,Qt.NoModifier,0);
    tryVerify(()=>renderedSignature(answerAt(first.target_frame))===selected.signature && renderedSignature(answerAt(second.target_frame))===selected.signature,2500);
    check(wins,0);ensure(!bonus.isPlaying,'Visible guard still prevents a drag conclusion');
    record.drag={from:a,to:b,signature:selected.signature,before:[beforeFirst,beforeSecond],after:[viewCells([answerAt(first.target_frame)])[0],viewCells([answerAt(second.target_frame)])[0]]};
    record.after=viewCells(answerObjects());return record;
}
function ctrlRestartPartial(initial) {
    var before=viewCells(answerObjects());ensure(before.some(cell=>opaqueKey(cell.signature)!==opaqueKey(initial[0].signature)),'There is an actual partial edit to reset');
    var next=ctrlNavigate(true),previous=ctrlNavigate(false),after=viewCells(answerObjects());
    ensure(after.every(cell=>opaqueKey(cell.signature)===opaqueKey(initial[0].signature)),'Level navigation clears the actual partial edit');
    return {method:'offered next/previous level controls',before:before,next:next,previous:previous,after:after,initial_blank:initial[0].signature,questionAfter:viewCells(questionObjects())};
}
function ctrlHelpAndEscape() {
    var depth=pageView.depth,opened=ctrlIcon('bar_help.svg');
    tryCompare(pageView,'depth',depth+1,2500);tryCompare(pageView,'busy',false,2500);wait(300);
    var help=pageView.currentItem,titles={redraw:'Voltar a desenhar a imagem atual',redraw_symmetrical:'Espelho da imagem indicada',mosaic:'Reconstruir o mosaico'};
    check(help.title,titles[activityName],'Actual PT-PT help title');
    ensure(String(help.content).indexOf(String(activity.activityInfo.manual))>=0,'The real help panel contains the activity manual');
    ensure(String(help.content).indexOf('Controlos do teclado')>=0 && String(help.content).toLowerCase().indexOf('espa')>=0,'Portuguese keyboard instructions are actually shown');
    var record={opened:opened,title:String(help.title),content:String(help.content),manual:String(activity.activityInfo.manual),depth:pageView.depth};
    grabImage(pageView).save('__QA_OUTPUT__/controls-help.png');ctrlKey('Escape close help',Qt.Key_Escape);
    tryCompare(pageView,'depth',depth,2500);tryCompare(pageView,'busy',false,2500);wait(300);record.closedDepth=pageView.depth;
    return record;
}
function ctrlBringIntoView(item,panel) {
    var flicks=allVisible(panel).filter(o=>o.contentHeight!==undefined && o.contentY!==undefined && o.flickableDirection!==undefined && o.height>20 && o.contentHeight>o.height);
    if(!flicks.length)return;
    check(flicks.length,1,'One public scroll viewport in the data-set dialog');var flick=flicks[0];
    for(var step=0;step<16;step++) {
        var p=pose(item),view=pose(flick),top=view.y-view.height/2,bottom=view.y+view.height/2;
        if(p.y>top+8 && p.y<bottom-8)return;
        var upward=p.y>=bottom,start={x:view.x,y:top+view.height*(upward?0.75:0.25)},end={x:view.x,y:top+view.height*(upward?0.25:0.75)},before=flick.contentY;
        mousePress(pageView,start.x,start.y,Qt.LeftButton,Qt.NoModifier,0);
        for(var i=1;i<=12;i++)mouseMove(pageView,start.x,start.y+(end.y-start.y)*i/12,25);
        mouseRelease(pageView,end.x,end.y,Qt.LeftButton,Qt.NoModifier,0);tryCompare(flick,'moving',false,2500);
        evidence.configScroll.push({from:start,to:end,before:before,after:flick.contentY});
    }
    ensure(false,'Offered scrolling brings a data-set checkbox into view');
}
function ctrlDatasets() {
    var count=activityName==='mosaic'?4:3,depth=pageView.depth,records=[];
    for(var choice=0;choice<count;choice++) {
        ctrlIcon('bar_activity_config.svg');tryCompare(pageView,'depth',depth+1,2500);tryCompare(pageView,'busy',false,2500);wait(300);
        var panel=pageView.currentItem,checks=allVisible(panel).filter(o=>o.checked!==undefined && o.indicatorImageHeight!==undefined && o.text!==undefined);
        checks.sort((a,b)=>pose(a).y-pose(b).y || pose(a).x-pose(b).x);check(checks.length,count,'Every publicly labelled data set is present');
        if(!checks[choice].checked){ctrlBringIntoView(checks[choice],panel);ctrlClick(checks[choice]);}
        for(var j=0;j<count;j++)if(j!==choice && checks[j].checked){ctrlBringIntoView(checks[j],panel);ctrlClick(checks[j]);}
        var labels=checks.map(o=>({text:String(o.text),checked:o.checked,frame:pose(o)}));
        check(labels.filter(o=>o.checked).length,1,'Exactly one data set selected through checkboxes');ensure(labels[choice].checked,'The requested visible data-set label is selected');
        var save=allVisible(panel).filter(o=>o.text!==undefined && String(o.text)==='Gravar' && o.clicked!==undefined);check(save.length,1,'Offered Portuguese save control');
        grabImage(pageView).save('__QA_OUTPUT__/controls-dataset-'+choice+'.png');var saveEvent=ctrlClick(save[0]);
        tryCompare(pageView,'depth',depth,3000);tryCompare(pageView,'busy',false,2500);tryCompare(activity,'currentLevel',0,2500);ctrlReady();
        ensure(activity.numberOfLevel>0,'Selected data set advertises a nonempty public level range');
        records.push({labels:labels,save:saveEvent,levels:activity.numberOfLevel,currentLevel:activity.currentLevel,question:viewCells(questionObjects()),answer:viewCells(answerObjects()),palette:paletteViews()});
        check(wins,0,'Configuration/navigation is separate from game conclusions');
    }
    return records;
}
function run_public_controls() {
    wait(1500);activityName=activity.activityInfo.shortName();check(activity.numberOfLevel,expectedTotal());
    var file=Qt.createQmlObject('import core 1.0; File {}',this);registry=JSON.parse(file.read('__QA_SOURCE__/tests/functional_patterns/observed-assets.json'));
    evidence.keys=[];evidence.levelSearch=[];evidence.configScroll=[];
    ctrlChooseTwoDimensionalLevel();var initial=viewCells(answerObjects());
    ensure(initial.every(cell=>opaqueKey(cell.signature)===opaqueKey(initial[0].signature)),'Initial edit grid is visibly blank');
    evidence.initial={level:activity.currentLevel+1,total:activity.numberOfLevel,question:viewCells(questionObjects()),answer:initial,palette:paletteViews()};
    evidence.keyboardBeforeHelp=activityName==='mosaic'?ctrlKeyboardMosaic('before-help'):ctrlKeyboardRedraw('before-help');
    if(activityName!=='mosaic')evidence.drag=ctrlDragRedraw();
    evidence.restart=ctrlRestartPartial(initial);
    evidence.help=ctrlHelpAndEscape();
    evidence.keyboardAfterHelp=activityName==='mosaic'?ctrlKeyboardMosaic('after-help'):ctrlKeyboardRedraw('after-help');
    evidence.datasets=ctrlDatasets();
    var plan=ctrlPlan(),holdout=plan.placements[0],partial={actions:[],question:viewCells(questionObjects()),answerBefore:viewCells(answerObjects()),plan:plan,palette:paletteViews()};
    partial.edit=paint(holdout,differentlyPainted(holdout.signature).signature,'partial-before-menu',partial);
    partial.answerAfter=viewCells(answerObjects());evidence.partialBeforeMenu=partial;
    check(wins,0);ensure(!bonus.isPlaying,'Partial menu exit never counts as success');
    grabImage(pageView).save('__QA_OUTPUT__/controls-partial.png');ActivityInfoTree.startingActivity='';evidence.home=ctrlIcon('bar_home.svg');
    tryCompare(pageView,'depth',1,2500);tryCompare(pageView,'busy',false,2500);ensure(pageView.currentItem.isMenu,'Actual menu during a partial activity');
    evidence.menuDuringActivity={depth:pageView.depth,busy:pageView.busy,isMenu:pageView.currentItem.isMenu};grabImage(pageView).save('__QA_OUTPUT__/controls-menu.png');
}
function test_public_controls(){try{run_public_controls();}catch(error){if(!evidence.failure)evidence.failure={message:String(error),stack:error.stack};throw error;}}
function cleanupTestCase() {
    if(qtest_results.failCount)grabImage(pageView).save('__QA_OUTPUT__/failure.png');
    console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,activity:activityName,wins:wins,pointerPaintActions:actions,evidence:evidence,scope:'Prepared controls observations; navigation/configuration are not game conclusions'}));
}

}
