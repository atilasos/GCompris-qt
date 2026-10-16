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
function test_all_current_patterns() {
    wait(1500);
    activityName=activity.activityInfo.shortName();
    check(activity.numberOfLevel,expectedTotal(),'Finite total of the public activity mode');
    var file=Qt.createQmlObject('import core 1.0; File {}',this);
    registry=JSON.parse(file.read('__QA_SOURCE__/tests/functional_patterns/observed-assets.json'));
    var total=activity.numberOfLevel;
    for(var level=1;level<=total;level++) {
        check(activity.currentLevel,level-1,'Natural entry into next level');
        tryVerify(()=>questionObjects().length>0 && questionObjects().every(isRenderedReady) && answerObjects().length>0 && answerObjects().every(isRenderedReady) && paletteObjects().length>1 && paletteObjects().every(o=>o.status===Image.Ready),4000,'Current public widgets are ready');
        wait(250);
        var beforeWins=wins,questionView=viewCells(questionObjects()),answerView=viewCells(answerObjects()),palette=paletteViews();
        var record={level:level,total:total,activity:activityName,completed:false,question:questionView,answerInitial:answerView,palette:palette,actions:[]};
        boards.push(record);
        try {record.plan=visiblePlan(questionView,answerView,palette,publicMirror());}
        catch(error){evidence.failure={message:'Visible dynamic plan refused',error:String(error),level:level};verify(false,String(error));}
        var mismatches=record.plan.placements.filter(p=>opaqueKey(renderedSignature(answerAt(p.target_frame)))!==opaqueKey(p.signature));
        ensure(mismatches.length>0,'Current visible question initially requires painting');
        var holdout=mismatches[0],different=differentlyPainted(holdout.signature);
        record.holdout=clone(holdout);
        grabImage(pageView).save('__QA_OUTPUT__/level-'+level+'-question.png');
        if(mismatches.length===1) {
            var guard=record.plan.placements.find(p=>!frameMatches(p.target_frame,holdout.target_frame));
            ensure(guard!==undefined,'A second public cell prevents completion during the correct-to-wrong probe');
            var guardPaint=differentlyPainted(guard.signature);
            record.guard=paint(guard,guardPaint.signature,'temporary-guard',record);
            check(wins,beforeWins,'No success after creating a visible guard error');
            ensure(!bonus.isPlaying,'Guard prevents premature completion');
        }
        record.prepaint=paint(holdout,holdout.signature,'holdout-correct-before-wrong',record);
        check(wins,beforeWins,'Other errors prevent success during the first correct paint');
        ensure(!bonus.isPlaying,'No Bonus before the wrong paint');
        record.holdWrong=paint(holdout,different.signature,'holdout-wrong',record);
        record.plan.placements.forEach(p=>{
            if(!frameMatches(p.target_frame,holdout.target_frame) && opaqueKey(renderedSignature(answerAt(p.target_frame)))!==opaqueKey(p.signature))paint(p,p.signature,'complete-other-target',record);
        });
        staysWrong(level,beforeWins,holdout,record);
        wait(500);
        staysWrong(level,beforeWins,holdout,record);
        record.wrong={target:clone(holdout.target_frame),expected_signature:clone(holdout.signature),observed_signature:clone(renderedSignature(answerAt(holdout.target_frame))),answer:viewCells(answerObjects()),wins_before:beforeWins,wins_after:wins,currentLevel:activity.currentLevel,bonusPlaying:bonus.isPlaying,observed_without_success_ms:500};
        grabImage(pageView).save('__QA_OUTPUT__/level-'+level+'-wrong.png');
        record.repair=paint(holdout,holdout.signature,'repair-holdout',record);
        record.repaired={answer:viewCells(answerObjects()),currentLevel:activity.currentLevel};
        record.plan.placements.forEach(p=>check(opaqueKey(renderedSignature(answerAt(p.target_frame))),opaqueKey(p.signature),'Every actual rendered target matches the visible question after repair'));
        tryCompare(bonus,'isPlaying',true,2500);
        ensure(String(bonus.source).endsWith('_good.svg'),'Actual good Bonus image after pointer repair');
        record.bonus=String(bonus.source);
        grabImage(pageView).save('__QA_OUTPUT__/level-'+level+'-success.png');
        tryCompare(qa,'wins',beforeWins+1,10000);
        tryCompare(activity,'currentLevel',level%total,3000);
        record.completed=true;record.nextLevel=activity.currentLevel;record.winsAfter=wins;
        console.log('PATTERN_HEARTBEAT',level,wins);
    }
    check(wins,total,'One natural Win per current level');
    ActivityInfoTree.startingActivity='';keyClick(Qt.Key_W,Qt.ControlModifier);
    tryCompare(pageView,'depth',1,2000);tryCompare(pageView,'busy',false,2000);
    ensure(pageView.currentItem.isMenu,'Actual menu after last success');
    evidence.menuAfterSuccess={depth:pageView.depth,busy:pageView.busy,isMenu:pageView.currentItem.isMenu};
    grabImage(pageView).save('__QA_OUTPUT__/menu-after-success.png');
}
function cleanupTestCase() {
    if(qtest_results.failCount)grabImage(pageView).save('__QA_OUTPUT__/failure.png');
    console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,activity:activityName,boards:boards,wins:wins,actions:actions,evidence:evidence,scope:'Current visible patterns; no authored answer model consulted'}));
}
