// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    id: qa
    name:'ImageAssociationFromVisibleContent'
    when: activity.visible && activity.numberOfLevel>0
    property int firstLevel: 1
    property int targetLevels: 1
    property var boards: []
    property int wins: 0
    property int wrong: 0
    property int moves: 0
    property var oracle: ({})
    Connections { target: bonus; function onWin(){qa.wins++;} }
    function check(a,b,message){if(a!==b)console.log('ASSOCIATION_ASSERT',a,b,message||'',new Error().stack);compare(a,b,message||'');}
    function ensure(v,message){if(!v)console.log('ASSOCIATION_ASSERT_FALSE',message||'',new Error().stack);verify(v,message||'');}
    function all(root,predicate){var out=[];function walk(o){if(!o.visible||o.opacity===0)return;if(predicate(o))out.push(o);if(o.children)for(var c of o.children)walk(c);}walk(root);return out;}
    function imageId(source){return String(source).split('/resource/').pop();}
    function point(item){var p=item.mapToItem(pageView,item.width/2,item.height/2);return {x:p.x,y:p.y};}
    function images(root){return all(root,function(o){return o.source!==undefined&&o.status!==undefined&&o.width>12&&o.height>12&&String(o.source).indexOf(String(activity.imagesUrl))===0;});}
    function blanks(){return Array.from(spotsContainer.children).filter(function(o){return o.visible&&o.radius!==undefined&&o.width>0&&o.width<30;});}
    function sidebar(){return images(availablePieces).filter(function(o){var p=point(o);return p.x>=0&&p.y>=0&&p.x<pageView.width&&p.y<bar.y;});}
    function click(item){ensure(item!==null);var p=point(item);mouseClick(pageView,p.x,p.y);wait(70);}
    function icon(root,suffix){var found=all(root,function(o){return o.source!==undefined&&String(o.source).endsWith(suffix)&&o.opacity>0&&o.width>5;});ensure(found.length>0,suffix);click(found[0]);}
    function nearest(items,p){var best=null,d=Infinity;for(var item of items){var q=point(item),dist=(q.x-p.x)*(q.x-p.x)+(q.y-p.y)*(q.y-p.y);if(dist<d){best=item;d=dist;}}ensure(best!==null);return best;}
    function drag(image,target){var a=point(image),b=point(target);mousePress(pageView,a.x,a.y);mouseMove(pageView,a.x+14,a.y,60);for(var i=1;i<=14;i++)mouseMove(pageView,a.x+(b.x-a.x)*i/14,a.y+(b.y-a.y)*i/14,20);mouseRelease(pageView,b.x,b.y);moves++;wait(520);}
    function answerFor(image,targets,backgrounds,labels){
        var name=imageId(image.source),base=name.split('/').pop(),activityName=activity.activityInfo.shortName();
        if(activityName==='imagename'){
            var text=oracle.semantic.names[base];ensure(text!==undefined,'Inspected image dictionary: '+base);
            var label=labels.filter(function(t){return String(t.text)===text;});ensure(label.length===1,'PT label for '+base+' must be '+text);
            var lp=point(label[0]);var above=targets.filter(function(t){var p=point(t);return p.y<lp.y;});return {target:nearest(above,lp),reason:'PT '+text,evidence:{name:text}};
        }
        if(activityName==='babymatch'){
            var pairs=oracle.semantic.relations.filter(function(r){return r[0]===base;});
            var matches=[];for(var pair of pairs)for(var background of backgrounds)if(imageId(background.source).split('/').pop()===pair[1])matches.push({image:background,reason:pair[2]});
            ensure(matches.length===1,'Inspected semantic relation '+base);return {target:nearest(targets,point(matches[0].image)),reason:matches[0].reason,evidence:{background:imageId(matches[0].image.source)}};
        }
        if(oracle.silhouettes[name]!==undefined){var match=oracle.silhouettes[name];var found=backgrounds.filter(function(t){return imageId(t.source)===match.target;});ensure(found.length===1);return {target:nearest(targets,point(found[0])),reason:'Rendered silhouette IoU '+match.iou,evidence:match};}
        if(oracle.semantic.dog[name]!==undefined){var rule=oracle.semantic.dog[name];var sorted=targets.slice();sorted.sort(function(a,b){var x=point(a),y=point(b);return rule.rule==='topmost'?x.y-y.y:rule.rule==='leftmost'?x.x-y.x:y.x-x.x;});return {target:sorted[0],reason:rule.reason,evidence:{rule:rule.rule}};}
        var hole=oracle.holes[name];ensure(hole!==undefined,'Independent visible hole '+name);check(imageId(backgroundImage.source),hole.background);var p=backgroundImage.mapToItem(pageView,backgroundImage.width*hole.center[0],backgroundImage.height*hole.center[1]);return {target:nearest(targets,p),reason:'Visible image hole geometry and edge continuity',evidence:hole};
    }
    property var evidence: ({})
    function keyboardCycle(removeKey){
        keyClick(Qt.Key_Right);keyClick(Qt.Key_Space);keyClick(Qt.Key_Space);wait(600);check(images(spotsContainer).length,1);
        keyClick(Qt.Key_Tab);keyClick(removeKey);wait(600);check(images(spotsContainer).length,0);check(score.currentSubLevel,0);keyClick(Qt.Key_Tab);
    }
    function test_controls(){
        wait(1500);check(activity.numberOfLevel,7);check(activity.currentLevel,0);
        ensure(all(bar,function(o){return o.source!==undefined&&String(o.source).endsWith('bar_activity_config.svg');}).length===0,'No configuration is exposed');
        var initial=sidebar();ensure(initial.length>=2);drag(initial[0],blanks()[0]);check(images(spotsContainer).length,1);
        icon(bar,'bar_previous.svg');check(activity.currentLevel,6);icon(bar,'bar_next.svg');check(activity.currentLevel,0);wait(200);check(images(spotsContainer).length,0);ensure(sidebar().length>=2);
        activityBackground.forceActiveFocus();keyboardCycle(Qt.Key_Delete);
        var depth=pageView.depth;icon(bar,'bar_help.svg');tryCompare(pageView,'depth',depth+1,2500);wait(800);var help=pageView.currentItem;
        check(help.title,activity.activityInfo.title);ensure(help.content.indexOf(activity.activityInfo.manual)>=0);ensure(activity.activityInfo.manual.indexOf('Espaço')>=0);grabImage(pageView).save('__QA_OUTPUT__/help.png');var title=help.title;
        keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth,2500);wait(600);keyboardCycle(Qt.Key_Backspace);
        evidence={title:title,levels:7,noConfiguration:true,partialRestartByNavigation:true,previousNextWrap:true,keyboardDropDelete:true,keyboardAfterHelp:true,helpPortuguese:true};
        ActivityInfoTree.startingActivity='';icon(bar,'bar_home.svg');tryCompare(pageView,'depth',1,2500);ensure(pageView.currentItem.isMenu);evidence.home=true;
    }
    function cleanupTestCase(){console.log('NATIVE_ASSOCIATION_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,activity:activity.activityInfo.shortName(),evidence:evidence}));}
}
