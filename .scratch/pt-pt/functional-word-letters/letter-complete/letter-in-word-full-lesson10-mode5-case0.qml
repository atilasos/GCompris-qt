// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteLetterInWordLessonPT"
    when:activity.visible
    property var expectedWords:{"wedding.ogg": "casamento", "boy.ogg": "rapaz", "bride.ogg": "noiva", "brother.ogg": "irmão", "child.ogg": "filho", "couple.ogg": "par", "dad.ogg": "pai", "dwarf.ogg": "anão", "family.ogg": "família", "friend.ogg": "amigo", "girl.ogg": "rapariga", "grandmother.ogg": "avó", "husband.ogg": "marido", "lady.ogg": "senhora", "man.ogg": "homem", "mate.ogg": "companheiro", "mom.ogg": "mãe", "mother.ogg": "mãe", "pal.ogg": "camarada", "people.ogg": "pessoas", "sister.ogg": "irmã", "son.ogg": "filho", "tribe.ogg": "tribo", "twin_boys.ogg": "gémeos", "twin_girls.ogg": "gémeas", "wife.ogg": "esposa", "woman.ogg": "mulher"}
    property var incidence:{"m": ["wedding.ogg", "brother.ogg", "family.ogg", "friend.ogg", "husband.ogg", "man.ogg", "mate.ogg", "mom.ogg", "mother.ogg", "pal.ogg", "sister.ogg", "twin_boys.ogg", "twin_girls.ogg", "woman.ogg"], "r": ["boy.ogg", "brother.ogg", "couple.ogg", "girl.ogg", "husband.ogg", "lady.ogg", "mate.ogg", "pal.ogg", "sister.ogg", "tribe.ogg", "woman.ogg"], "u": ["woman.ogg"], "t": ["wedding.ogg", "tribe.ogg"], "í": ["family.ogg"], "d": ["husband.ogg", "pal.ogg"], "i": ["bride.ogg", "brother.ogg", "child.ogg", "dad.ogg", "family.ogg", "friend.ogg", "girl.ogg", "husband.ogg", "mate.ogg", "sister.ogg", "son.ogg", "tribe.ogg"], "l": ["child.ogg", "family.ogg", "son.ogg", "woman.ogg"], "a": ["wedding.ogg", "boy.ogg", "bride.ogg", "couple.ogg", "dad.ogg", "dwarf.ogg", "family.ogg", "friend.ogg", "girl.ogg", "grandmother.ogg", "husband.ogg", "lady.ogg", "mate.ogg", "pal.ogg", "people.ogg", "twin_girls.ogg", "wife.ogg"], "p": ["boy.ogg", "couple.ogg", "dad.ogg", "girl.ogg", "mate.ogg", "people.ogg", "wife.ogg"], "h": ["child.ogg", "lady.ogg", "man.ogg", "mate.ogg", "son.ogg", "woman.ogg"], "n": ["wedding.ogg", "bride.ogg", "dwarf.ogg", "lady.ogg", "mate.ogg"], "g": ["friend.ogg", "girl.ogg", "twin_boys.ogg", "twin_girls.ogg"], "z": ["boy.ogg"], "é": ["twin_boys.ogg", "twin_girls.ogg"], "s": ["wedding.ogg", "lady.ogg", "people.ogg", "twin_boys.ogg", "twin_girls.ogg", "wife.ogg"], "o": ["wedding.ogg", "bride.ogg", "brother.ogg", "child.ogg", "dwarf.ogg", "friend.ogg", "husband.ogg", "lady.ogg", "man.ogg", "mate.ogg", "people.ogg", "son.ogg", "tribe.ogg", "twin_boys.ogg", "wife.ogg"], "c": ["wedding.ogg", "mate.ogg", "pal.ogg"], "f": ["child.ogg", "family.ogg", "son.ogg"], "e": ["wedding.ogg", "lady.ogg", "man.ogg", "mate.ogg", "mom.ogg", "mother.ogg", "people.ogg", "twin_boys.ogg", "twin_girls.ogg", "wife.ogg", "woman.ogg"], "b": ["tribe.ogg"], "v": ["bride.ogg", "grandmother.ogg"], "ã": ["brother.ogg", "dwarf.ogg", "mom.ogg", "mother.ogg", "sister.ogg"], "ó": ["grandmother.ogg"]}
    property var counts:{"wedding.ogg": {"c": 1, "a": 2, "s": 1, "m": 1, "e": 1, "n": 1, "t": 1, "o": 1}, "boy.ogg": {"r": 1, "a": 2, "p": 1, "z": 1}, "bride.ogg": {"n": 1, "o": 1, "i": 1, "v": 1, "a": 1}, "brother.ogg": {"i": 1, "r": 1, "m": 1, "ã": 1, "o": 1}, "child.ogg": {"f": 1, "i": 1, "l": 1, "h": 1, "o": 1}, "couple.ogg": {"p": 1, "a": 1, "r": 1}, "dad.ogg": {"p": 1, "a": 1, "i": 1}, "dwarf.ogg": {"a": 1, "n": 1, "ã": 1, "o": 1}, "family.ogg": {"f": 1, "a": 2, "m": 1, "í": 1, "l": 1, "i": 1}, "friend.ogg": {"a": 1, "m": 1, "i": 1, "g": 1, "o": 1}, "girl.ogg": {"r": 2, "a": 3, "p": 1, "i": 1, "g": 1}, "grandmother.ogg": {"a": 1, "v": 1, "ó": 1}, "husband.ogg": {"m": 1, "a": 1, "r": 1, "i": 1, "d": 1, "o": 1}, "lady.ogg": {"s": 1, "e": 1, "n": 1, "h": 1, "o": 1, "r": 1, "a": 1}, "man.ogg": {"h": 1, "o": 1, "m": 2, "e": 1}, "mate.ogg": {"c": 1, "o": 2, "m": 1, "p": 1, "a": 1, "n": 1, "h": 1, "e": 1, "i": 1, "r": 1}, "mom.ogg": {"m": 1, "ã": 1, "e": 1}, "mother.ogg": {"m": 1, "ã": 1, "e": 1}, "pal.ogg": {"c": 1, "a": 4, "m": 1, "r": 1, "d": 1}, "people.ogg": {"p": 1, "e": 1, "s": 3, "o": 1, "a": 1}, "sister.ogg": {"i": 1, "r": 1, "m": 1, "ã": 1}, "son.ogg": {"f": 1, "i": 1, "l": 1, "h": 1, "o": 1}, "tribe.ogg": {"t": 1, "r": 1, "i": 1, "b": 1, "o": 1}, "twin_boys.ogg": {"g": 1, "é": 1, "m": 1, "e": 1, "o": 1, "s": 1}, "twin_girls.ogg": {"g": 1, "é": 1, "m": 1, "e": 1, "a": 1, "s": 1}, "wife.ogg": {"e": 1, "s": 2, "p": 1, "o": 1, "a": 1}, "woman.ogg": {"m": 1, "u": 1, "l": 1, "h": 1, "e": 1, "r": 1}}
    property int lessonIndex:9
    property int configuredMode:5
    property int configuredCase:0
    property bool externalWords:true
    property var completed:[]
    property int expectedQuestions:0
    property int physicalSelections:0
    property int mouseSelections:0
    Component.onCompleted: {
        // Configure before the normal first start, retaining the CLI lesson.
        items.currentMode=configuredMode;
        items.currentLetterCase=configuredCase;
    }
    function checked(actual,expected,message) {
        if(actual!==expected)console.log("WORD_FAILURE",JSON.stringify({actual:actual,expected:expected,message:message}));
        compare(actual,expected,message||"");
    }
    function keyFor(index) {
        var source=wordsModel.get(index).imgurl;
        return source.slice(source.lastIndexOf('/')+1).replace('.webp','.ogg');
    }
    function navigate(index) {
        activityBackground.forceActiveFocus();
        if(wordsView.currentIndex<0)keyClick(Qt.Key_Right);
        var columns=Math.max(1,Math.floor(wordsView.width/wordsView.cellWidth));
        for(var step=0;step<wordsModel.count*3 && wordsView.currentIndex!==index;step++) {
            var current=wordsView.currentIndex;
            var row=Math.floor(current/columns),targetRow=Math.floor(index/columns);
            keyClick(row<targetRow?Qt.Key_Down:row>targetRow?Qt.Key_Up:current<index?Qt.Key_Right:Qt.Key_Left);
            verify(wordsView.currentIndex!==current,"Arrow moves selection");
        }
        checked(wordsView.currentIndex,index,"Keyboard navigation reaches real card");
    }
    function choose(index,keyboardInput) {
        var before=wordsModel.get(index).selected;
        if(keyboardInput) {
            navigate(index);keyClick(Qt.Key_Space);
            physicalSelections++;
        } else {
            var card=wordsView.itemAtIndex(index);verify(card!==null);
            mouseClick(card,card.width/2,card.height/2,Qt.LeftButton,Qt.NoModifier,50);
            mouseSelections++;
        }
        checked(wordsModel.get(index).selected,!before,"One event toggles one card");
    }
    function test_complete_all_generated_questions() {
        wait(1800);
        wait(300);
        checked(items.currentLevel,lessonIndex);
        checked(ApplicationSettings.useExternalWordset(),externalWords);
        checked(activityBackground.englishFallback,false);
        checked(wordsModel.count,Math.min(configuredMode,Object.keys(expectedWords).length));
        var frequencies={},keys=[];
        for(var index=0;index<wordsModel.count;index++) {
            var key=keyFor(index);keys.push(key);
            checked(wordsModel.get(index).spelling,expectedWords[key]);
            for(var character in counts[key])frequencies[character]=(frequencies[character]||0)+counts[key][character];
        }
        var values=[];
        for(var letter in frequencies)values.push(frequencies[letter]);
        values.sort(function(a,b){return b-a;});
        expectedQuestions=Math.min(10,values.length);
        checked(score.numberOfSubLevels,expectedQuestions);
        var seen={};
        for(var questionIndex=0;questionIndex<expectedQuestions;questionIndex++) {
            tryCompare(items,"buttonsBlocked",false,5000);
            checked(score.currentSubLevel,questionIndex);
            var question=questionItem.text;
            verify(!seen[question]);seen[question]=true;
            verify(frequencies[question]>=values[expectedQuestions-1],"Question belongs to the ten most frequent characters, ties allowed");
            if(configuredCase===0)verify(questionItem.font.capitalization===Font.AllUppercase || questionItem.font.capitalization===Font.AllLowercase);
            else checked(questionItem.font.capitalization,configuredCase);
            for(var i=0;i<wordsModel.count;i++)checked(wordsModel.get(i).selected,false);
            if(questionIndex===0) {
                activityBackground.forceActiveFocus();keyClick(Qt.Key_Return);
                checked(score.currentSubLevel,0,"Empty answer is rejected");
                verify(items.buttonsBlocked);
                tryCompare(items,"buttonsBlocked",false,3000);
            }
            var selected=[];
            for(var cardIndex=0;cardIndex<wordsModel.count;cardIndex++) {
                var expected=incidence[question].indexOf(keys[cardIndex])!==-1;
                if(expected) {choose(cardIndex,questionIndex%2===0);selected.push(keys[cardIndex]);}
                checked(wordsModel.get(cardIndex).selected,expected);
            }
            verify(selected.length>0);
            if(questionIndex%2===0){activityBackground.forceActiveFocus();keyClick(Qt.Key_Return);}
            else mouseClick(ok);
            checked(score.currentSubLevel,questionIndex+1);
            completed.push({question:question,capitalization:questionItem.font.capitalization,selected:selected,cards:keys});
            console.log("LETTER_COMPLETED",JSON.stringify(completed[completed.length-1]));
            if(questionIndex===0)grabImage(pageView).save("__QA_OUTPUT__/first-question.png");
            if(questionIndex===expectedQuestions-1) {
                tryCompare(items,"currentLevel",(lessonIndex+1)%items.numberOfLevel,6500);
                checked(score.currentSubLevel,0);
            } else {
                tryCompare(score,"isWinAnimationPlaying",false,3500);
                tryCompare(items,"buttonsBlocked",false,2000);
            }
            wait(60);
        }
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,expectedQuestions:expectedQuestions,lesson:lessonIndex,externalWords:externalWords,mode:configuredMode,letterCase:configuredCase,physicalSelections:physicalSelections,mouseSelections:mouseSelections,completed:completed}));}
}
