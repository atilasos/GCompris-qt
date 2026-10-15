// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteLetterInWordLessonPT"
    when:activity.visible
    property var expectedWords:{"acorn.ogg": "bolota", "apple_tree.ogg": "macieira", "branch.ogg": "ramo", "bud.ogg": "botão", "bush.ogg": "arbusto", "cactus.ogg": "cacto", "clover.ogg": "trevo", "daffodil.ogg": "narciso", "daisy.ogg": "margarida", "dandelion.ogg": "dente-de-leão", "flower.ogg": "flor", "grain.ogg": "grão", "grass.ogg": "erva", "hay.ogg": "palha", "hedge.ogg": "sebe", "lawn.ogg": "relva", "leaf.ogg": "folha", "lilac.ogg": "hortênsia", "maple.ogg": "plátano", "mimosa.ogg": "mimosa", "orchid.ogg": "orquídea", "palm_tree.ogg": "palmeira", "peony.ogg": "peónia", "petal.ogg": "pétala", "pine.ogg": "pinheiro", "pine_cone.ogg": "pinha", "pip.ogg": "pevide", "plant.ogg": "planta", "root.ogg": "raiz", "rose.ogg": "rosa", "seed.ogg": "semente", "shrub.ogg": "arbusto", "stem.ogg": "haste", "stick.ogg": "pau", "stump.ogg": "coto", "tree.ogg": "árvore", "tulip.ogg": "túlipa", "verdure.ogg": "verdura"}
    property var incidence:{"m": ["apple_tree.ogg", "branch.ogg", "daisy.ogg", "mimosa.ogg", "palm_tree.ogg", "seed.ogg"], "r": ["apple_tree.ogg", "branch.ogg", "bush.ogg", "clover.ogg", "daffodil.ogg", "daisy.ogg", "flower.ogg", "grain.ogg", "grass.ogg", "lawn.ogg", "lilac.ogg", "orchid.ogg", "palm_tree.ogg", "pine.ogg", "root.ogg", "rose.ogg", "shrub.ogg", "tree.ogg", "verdure.ogg"], "u": ["bush.ogg", "orchid.ogg", "shrub.ogg", "stick.ogg", "verdure.ogg"], "q": ["orchid.ogg"], "-": ["dandelion.ogg"], "á": ["maple.ogg", "tree.ogg"], "ó": ["peony.ogg"], "t": ["acorn.ogg", "bud.ogg", "bush.ogg", "cactus.ogg", "clover.ogg", "dandelion.ogg", "lilac.ogg", "maple.ogg", "petal.ogg", "plant.ogg", "seed.ogg", "shrub.ogg", "stem.ogg", "stump.ogg", "tulip.ogg"], "í": ["orchid.ogg"], "d": ["daisy.ogg", "dandelion.ogg", "orchid.ogg", "pip.ogg", "verdure.ogg"], "i": ["apple_tree.ogg", "daffodil.ogg", "daisy.ogg", "lilac.ogg", "mimosa.ogg", "palm_tree.ogg", "peony.ogg", "pine.ogg", "pine_cone.ogg", "pip.ogg", "root.ogg", "tulip.ogg"], "l": ["acorn.ogg", "dandelion.ogg", "flower.ogg", "hay.ogg", "lawn.ogg", "leaf.ogg", "maple.ogg", "palm_tree.ogg", "petal.ogg", "plant.ogg", "tulip.ogg"], "ú": ["tulip.ogg"], "a": ["acorn.ogg", "apple_tree.ogg", "branch.ogg", "bush.ogg", "cactus.ogg", "daffodil.ogg", "daisy.ogg", "grass.ogg", "hay.ogg", "lawn.ogg", "leaf.ogg", "lilac.ogg", "maple.ogg", "mimosa.ogg", "orchid.ogg", "palm_tree.ogg", "peony.ogg", "petal.ogg", "pine_cone.ogg", "plant.ogg", "root.ogg", "rose.ogg", "shrub.ogg", "stem.ogg", "stick.ogg", "tulip.ogg", "verdure.ogg"], "p": ["hay.ogg", "maple.ogg", "palm_tree.ogg", "peony.ogg", "petal.ogg", "pine.ogg", "pine_cone.ogg", "pip.ogg", "plant.ogg", "stick.ogg", "tulip.ogg"], "h": ["hay.ogg", "leaf.ogg", "lilac.ogg", "pine.ogg", "pine_cone.ogg", "stem.ogg"], "n": ["daffodil.ogg", "dandelion.ogg", "lilac.ogg", "maple.ogg", "peony.ogg", "pine.ogg", "pine_cone.ogg", "plant.ogg", "seed.ogg"], "g": ["daisy.ogg", "grain.ogg"], "z": ["root.ogg"], "é": ["petal.ogg"], "s": ["bush.ogg", "daffodil.ogg", "hedge.ogg", "lilac.ogg", "mimosa.ogg", "rose.ogg", "seed.ogg", "shrub.ogg", "stem.ogg"], "o": ["acorn.ogg", "branch.ogg", "bud.ogg", "bush.ogg", "cactus.ogg", "clover.ogg", "daffodil.ogg", "dandelion.ogg", "flower.ogg", "grain.ogg", "leaf.ogg", "lilac.ogg", "maple.ogg", "mimosa.ogg", "orchid.ogg", "pine.ogg", "rose.ogg", "shrub.ogg", "stump.ogg", "tree.ogg"], "c": ["apple_tree.ogg", "cactus.ogg", "daffodil.ogg", "stump.ogg"], "f": ["flower.ogg", "leaf.ogg"], "e": ["apple_tree.ogg", "clover.ogg", "dandelion.ogg", "grass.ogg", "hedge.ogg", "lawn.ogg", "orchid.ogg", "palm_tree.ogg", "peony.ogg", "pine.ogg", "pip.ogg", "seed.ogg", "stem.ogg", "tree.ogg", "verdure.ogg"], "b": ["acorn.ogg", "bud.ogg", "bush.ogg", "hedge.ogg", "shrub.ogg"], "v": ["clover.ogg", "grass.ogg", "lawn.ogg", "pip.ogg", "tree.ogg", "verdure.ogg"], "ã": ["bud.ogg", "dandelion.ogg", "grain.ogg"], "ê": ["lilac.ogg"]}
    property var counts:{"acorn.ogg": {"b": 1, "o": 2, "l": 1, "t": 1, "a": 1}, "apple_tree.ogg": {"m": 1, "a": 2, "c": 1, "i": 2, "e": 1, "r": 1}, "branch.ogg": {"r": 1, "a": 1, "m": 1, "o": 1}, "bud.ogg": {"b": 1, "o": 2, "t": 1, "ã": 1}, "bush.ogg": {"a": 1, "r": 1, "b": 1, "u": 1, "s": 1, "t": 1, "o": 1}, "cactus.ogg": {"c": 2, "a": 1, "t": 1, "o": 1}, "clover.ogg": {"t": 1, "r": 1, "e": 1, "v": 1, "o": 1}, "daffodil.ogg": {"n": 1, "a": 1, "r": 1, "c": 1, "i": 1, "s": 1, "o": 1}, "daisy.ogg": {"m": 1, "a": 3, "r": 2, "g": 1, "i": 1, "d": 1}, "dandelion.ogg": {"d": 2, "e": 4, "n": 1, "t": 1, "-": 2, "l": 1, "ã": 1, "o": 1}, "flower.ogg": {"f": 1, "l": 1, "o": 1, "r": 1}, "grain.ogg": {"g": 1, "r": 1, "ã": 1, "o": 1}, "grass.ogg": {"e": 1, "r": 1, "v": 1, "a": 1}, "hay.ogg": {"p": 1, "a": 2, "l": 1, "h": 1}, "hedge.ogg": {"s": 1, "e": 2, "b": 1}, "lawn.ogg": {"r": 1, "e": 1, "l": 1, "v": 1, "a": 1}, "leaf.ogg": {"f": 1, "o": 1, "l": 1, "h": 1, "a": 1}, "lilac.ogg": {"h": 1, "o": 1, "r": 1, "t": 1, "ê": 1, "n": 1, "s": 1, "i": 1, "a": 1}, "maple.ogg": {"p": 1, "l": 1, "á": 1, "t": 1, "a": 1, "n": 1, "o": 1}, "mimosa.ogg": {"m": 2, "i": 1, "o": 1, "s": 1, "a": 1}, "orchid.ogg": {"o": 1, "r": 1, "q": 1, "u": 1, "í": 1, "d": 1, "e": 1, "a": 1}, "palm_tree.ogg": {"p": 1, "a": 2, "l": 1, "m": 1, "e": 1, "i": 1, "r": 1}, "peony.ogg": {"p": 1, "e": 1, "ó": 1, "n": 1, "i": 1, "a": 1}, "petal.ogg": {"p": 1, "é": 1, "t": 1, "a": 2, "l": 1}, "pine.ogg": {"p": 1, "i": 2, "n": 1, "h": 1, "e": 1, "r": 1, "o": 1}, "pine_cone.ogg": {"p": 1, "i": 1, "n": 1, "h": 1, "a": 1}, "pip.ogg": {"p": 1, "e": 2, "v": 1, "i": 1, "d": 1}, "plant.ogg": {"p": 1, "l": 1, "a": 2, "n": 1, "t": 1}, "root.ogg": {"r": 1, "a": 1, "i": 1, "z": 1}, "rose.ogg": {"r": 1, "o": 1, "s": 1, "a": 1}, "seed.ogg": {"s": 1, "e": 3, "m": 1, "n": 1, "t": 1}, "shrub.ogg": {"a": 1, "r": 1, "b": 1, "u": 1, "s": 1, "t": 1, "o": 1}, "stem.ogg": {"h": 1, "a": 1, "s": 1, "t": 1, "e": 1}, "stick.ogg": {"p": 1, "a": 1, "u": 1}, "stump.ogg": {"c": 1, "o": 2, "t": 1}, "tree.ogg": {"á": 1, "r": 2, "v": 1, "o": 1, "e": 1}, "tulip.ogg": {"t": 1, "ú": 1, "l": 1, "i": 1, "p": 1, "a": 1}, "verdure.ogg": {"v": 1, "e": 1, "r": 2, "d": 1, "u": 1, "a": 1}}
    property int lessonIndex:15
    property int configuredMode:11
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
