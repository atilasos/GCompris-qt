// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"NativePortugueseMemory"
    when:items.numberOfLevel>0 && activity.visible
    property var completed: []
    property int correctPairs: 0
    property int wrongPairs: 0
    property int blockedClicks: 0
    property var words: ["zero","um","dois","três","quatro","cinco","seis","sete","oito","nove","dez","onze","doze","treze","catorze","quinze","dezasseis","dezassete","dezoito","dezanove","vinte"]
    function check(actual,expected,message) {
        if(actual!==expected)console.log("NATIVE_MEMORY_FAILURE",String(actual),String(expected),message||"");
        compare(actual,expected,message||"");
    }
    function kind(){return activity.activityInfo.shortName();}
    function keyFor(data) {
        if(kind()==="memory-case-association") {
            var letter=String(data.image).match(/(?:lower|upper)([A-Z])\.svg$/);
            verify(letter!==null,"Alphabet image has a known letter");return letter[1];
        }
        var text=String(data.text);
        if(kind()==="memory-wordnumber") {
            if(/^\d+$/.test(text))return Number(text);
            var number=words.indexOf(text);verify(number>=0,"PT number spelling: "+text);return number;
        }
        if(text!=="")return Number(text);
        var model=data.repeaterModel;var count=0;
        var length=model.count!==undefined?model.count:model.length;
        for(var i=0;i<length;i++) {
            var entry=model.get!==undefined?model.get(i):model[i];
            if(entry.itemSize>0)count++;
        }
        return count;
    }
    function card(index){var item=cardGrid.itemAtIndex(index);verify(item!==null);return item;}
    function click(index){var item=card(index);mouseClick(item,item.width/2,item.height/2,Qt.LeftButton,Qt.NoModifier,0);}
    function keyboardSelect(index) {
        activityBackground.forceActiveFocus();
        var steps=0;
        while(cardGrid.currentIndex!==index && steps++<cardGrid.count+1)keyClick(Qt.Key_Right,Qt.NoModifier,0);
        check(cardGrid.currentIndex,index,"Requested card is reachable with arrows");
        keyClick(Qt.Key_Space,Qt.NoModifier,0);
    }
    function verifyData() {
        if(kind()==="memory-wordnumber") {
            var known={};
            for(var level of items.levels)for(var pair of level.texts) {
                check(pair[0],words[pair[1]],"European Portuguese number name");known[pair[1]]=true;
            }
            check(Object.keys(known).length,21);
        }
    }
    function runMode(players) {
        activityBackground.stop();items.playerCount=players;activityBackground.start();
        verify(!activity.withTux);verifyData();
        var levelCount={"memory-wordnumber":5,"memory-case-association":4,"memory-enumerate":8}[kind()];
        check(items.numberOfLevel,levelCount);
        for(var level=0;level<levelCount;level++) {
            check(items.currentLevel,level);wait(1100);
            check(items.player1Score.playerScore,0);check(items.player2Score.playerScore,0);
            check(items.player2Turn,false);check(items.selectionCount,0);
            var pairs={};
            for(var index=0;index<cardGrid.count;index++) {
                var key=String(keyFor(card(index).pairData));
                if(pairs[key]===undefined)pairs[key]=[];pairs[key].push(index);
            }
            var names=Object.keys(pairs);
            check(names.length,cardGrid.count/2);
            for(var name of names)check(pairs[name].length,2);
            // Real key event: one arrow must move one card, without bouncing
            // through ActivityBase into this handler twice.
            activityBackground.forceActiveFocus();
            var before=cardGrid.currentIndex;
            keyClick(Qt.Key_Right,Qt.NoModifier,0);
            check(cardGrid.currentIndex,(before+1)%cardGrid.count,"One arrow, one card");
            var first=pairs[names[0]][0], second=pairs[names[1]][0];
            var untouched=pairs[names[0]][1];
            click(first);check(items.selectionCount,1);verify(!card(first).isBack);
            click(first);check(items.selectionCount,1,"Exposed card cannot be selected twice");
            click(second);check(items.selectionCount,2);wrongPairs++;
            click(untouched);check(items.selectionCount,2);verify(card(untouched).isBack);blockedClicks++;
            wait(500);verify(!card(first).isBack && !card(second).isBack,"Wrong pair remains exposed during the memory delay");
            check(items.player1Score.playerScore+items.player2Score.playerScore,0);
            tryCompare(items,"selectionCount",0,2000);
            verify(card(first).isBack && card(second).isBack);
            check(items.player2Turn,players===2,"Wrong pair passes the turn only in two-player mode");
            if(level===0)grabImage(activityBackground).save("__QA_OUTPUT__/"+players+"players-board.png");
            for(var pairIndex=0;pairIndex<names.length;pairIndex++) {
                var indices=pairs[names[pairIndex]];
                var score1=items.player1Score.playerScore,score2=items.player2Score.playerScore;
                if(pairIndex===0) {keyboardSelect(indices[0]);keyboardSelect(indices[1]);}
                else {click(indices[0]);click(indices[1]);}
                check(items.selectionCount,2);
                wait(400);check(items.player1Score.playerScore,score1);check(items.player2Score.playerScore,score2);
                tryVerify(function(){return card(indices[0]).isFound && card(indices[1]).isFound;},2000);
                correctPairs++;
                check(items.player1Score.playerScore,players===1?score1+1:score1);
                check(items.player2Score.playerScore,players===2?score2+1:score2);
                if(pairIndex+1<names.length) {
                    click(indices[0]);check(items.selectionCount,0,"Matched card cannot be selected again");
                    check(items.blockClicks,false);
                }
            }
            verify(items.blockClicks,"Completion blocks further input");
            check(items.player1Score.playerScore+items.player2Score.playerScore,names.length);
            completed.push({players:players,level:level+1,pairs:names.length,score1:items.player1Score.playerScore,score2:items.player2Score.playerScore});
            console.log("NATIVE_MEMORY_LEVEL",JSON.stringify(completed[completed.length-1]));
            tryCompare(items,"currentLevel",(level+1)%levelCount,7000);
        }
    }
    function test_all_levels_and_player_modes(){wait(1600);runMode(1);runMode(2);}
    function cleanupTestCase(){console.log("NATIVE_MEMORY_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,correctPairs:correctPairs,wrongPairs:wrongPairs,blockedClicks:blockedClicks}));}
}
