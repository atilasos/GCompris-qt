// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"ReadingAllPortugueseLevels"
    when:items.wordlist.maxLevel>0 && activity.visible
    property int solved:0
    property int rejected:0
    property var levels:[]
    property var speeds:[]
    property var presentByLevel:({})
    property var absentByLevel:({})
    property string phase:"initialization"
    function checked(value,message) {
        if(!value)console.log("READING_FAILURE",phase,message||"condition", "index",items.currentIndex);
        verify(value,message||"");
    }
    function equal(actual,expected,message) {
        if(actual!==expected)console.log("READING_FAILURE",phase,String(actual),String(expected),message||"");
        compare(actual,expected,message||"");
    }
    function until(object,property,value,timeout) {
        try {tryCompare(object,property,value,timeout);}
        catch(error){console.log("READING_FAILURE",phase,property,String(object[property]),String(value));throw error;}
    }
    function capture(label){grabImage(activityBackground).save("__QA_OUTPUT__/"+label+".png");}
    function watchSequence() {
        equal(iAmReady.visible,true);
        equal(answerButtonsFlow.visible,false);
        equal(items.currentIndex,-1);
        var target=items.textToFind;
        var seen=[];
        mouseClick(iAmReady);
        equal(iAmReady.visible,false);
        equal(wordDropTimer.running,true);
        for(var index=0;index<wordDisplayRepeater.count;index++) {
            until(items,"currentIndex",index,2000);
            var displayed=wordDisplayRepeater.itemAt(index);
            equal(displayed.opacity,1);
            checked(displayed.visible,"Presented word must not remain hidden after wrapping");
            equal(answerButtonsFlow.visible,false);
            seen.push(displayed.text);
            if(index>0)equal(wordDisplayRepeater.itemAt(index-1).opacity,0);
            if(index===2 && solved%10===0)capture("level-"+(items.currentLevel+1)+"-words-"+rejected);
        }
        until(answerButtonsFlow,"visible",true,2000);
        equal(wordDropTimer.running,false);
        for(var j=0;j<wordDisplayRepeater.count;j++)equal(wordDisplayRepeater.itemAt(j).opacity,0);
        var present=seen.indexOf(target)>=0;
        equal(answerButtonFound.isCorrectAnswer,present);
        equal(answerButtonNotFound.isCorrectAnswer,!present);
        return present;
    }
    function test_all_levels_correct_wrong_and_completion() {
        wait(1600);
        equal(items.wordlist.wordList.locale,"pt");
        checked(String(items.wordlist.filename).endsWith("default-pt.json"));
        equal(items.wordlist.maxLevel,3);
        equal(activity.numberOfLevel,3);
        checked(items.wordlist.wordList.levels[2].words.indexOf("música")>=0,"Private RCC uses corrected PT vocabulary");
        equal(items.currentLevel,0);
        equal(wordDisplayList.flow,activity.mode==="readingh"?Flow.LeftToRight:Flow.TopToBottom);
        equal(answerButtonFound.textLabel,"Sim, eu vi-a!");
        equal(answerButtonNotFound.textLabel,"Não, não estava lá!");
        checked(wordToFindBox.text.indexOf("Verifica se a palavra")>=0);
        // Lifecycle fixtures change supported settings only; all answers use mouse events.
        activityBackground.stop();
        activity.speedSetting=10;
        activityBackground.start();
        for(var level=0;level<3;level++) {
            phase="level-"+(level+1);
            equal(items.currentLevel,level);
            equal(score.currentSubLevel,0);
            equal(score.numberOfSubLevels,10);
            presentByLevel[level]=0;absentByLevel[level]=0;
            var present=watchSequence();
            var oldTarget=items.textToFind;
            mouseClick(present?answerButtonNotFound:answerButtonFound);
            equal(score.currentSubLevel,0);
            equal(items.buttonsBlocked,true);
            // A second click during the real feedback animation must not score.
            mouseClick(present?answerButtonFound:answerButtonNotFound);
            equal(score.currentSubLevel,0);
            until(iAmReady,"visible",true,5000);
            checked(items.wordlist.randomWordList.indexOf(oldTarget)>=0 || items.textToFind===oldTarget,
                   "Wrong target returns to the random word queue");
            rejected++;
            for(var round=0;round<10;round++) {
                phase="level-"+(level+1)+"-round-"+(round+1);
                console.log("READING_PROGRESS",activity.mode,phase);
                present=watchSequence();
                if(present)presentByLevel[level]++;else absentByLevel[level]++;
                mouseClick(present?answerButtonFound:answerButtonNotFound);
                equal(score.currentSubLevel,round+1);
                equal(items.buttonsBlocked,true);
                solved++;
                if(round===0)capture("level-"+(level+1)+"-correct");
                if(round<9)until(iAmReady,"visible",true,5000);
                else {
                    until(items,"currentLevel",(level+1)%3,8000);
                    wait(700);
                    until(bonus,"isPlaying",false,5000);
                }
            }
            levels.push(level+1);
        }
        checked(Object.keys(presentByLevel).some(function(level){return presentByLevel[level]>0;}) &&
                Object.keys(absentByLevel).some(function(level){return absentByLevel[level]>0;}),
                "Both target outcomes observed across the complete activity; all deterministic branches are tested in Node");
        phase="explicit-locale-restart";
        activityBackground.stop();
        activityBackground.locale="pt_PT.UTF-8";
        activityBackground.start();
        equal(items.currentLevel,0);equal(score.currentSubLevel,0);
        checked(String(items.wordlist.filename).endsWith("default-pt.json"));
        equal(iAmReady.visible,true);equal(wordDropTimer.running,false);
        phase="speed-settings";
        for(var speed=1;speed<=10;speed++) {
            activityBackground.stop();activity.speedSetting=speed;activityBackground.start();
            mouseClick(iAmReady);
            until(items,"currentIndex",0,1000);
            equal(wordDropTimer.interval,Math.floor(5000/speed));
            var started=Date.now();
            until(items,"currentIndex",1,6000);
            var elapsed=Date.now()-started;
            checked(elapsed>=wordDropTimer.interval-100 && elapsed<=wordDropTimer.interval+1000,"Real word timer respects speed "+speed);
            speeds.push({setting:speed,interval:wordDropTimer.interval,elapsed:elapsed});
        }
        activityBackground.stop();activityBackground.start();
        equal(items.currentIndex,-1);equal(score.currentSubLevel,0);
        capture("restart");
    }
    function cleanupTestCase(){console.log("NATIVE_READING_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,
        mode:activity.mode,solved:solved,rejected:rejected,completedLevels:levels,presentByLevel:presentByLevel,
        absentByLevel:absentByLevel,speeds:speeds,phase:phase}));}
}
