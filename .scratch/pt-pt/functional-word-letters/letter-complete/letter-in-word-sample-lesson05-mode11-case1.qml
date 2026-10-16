// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteLetterInWordLessonPT"
    when:activity.visible
    property var expectedWords:{"animal.ogg": "animal", "bear.ogg": "urso", "bee.ogg": "abelha", "beetle.ogg": "escaravelho", "bird.ogg": "pássaro", "bug.ogg": "besouro", "bull.ogg": "bói", "butterfly.ogg": "borboleta", "camel.ogg": "camelo", "cat.ogg": "gato", "chicken.ogg": "galinha", "cow.ogg": "vaca", "dog.ogg": "cão", "dolphin.ogg": "golfinho", "dragon.ogg": "dragão", "duck.ogg": "pato", "fish.ogg": "peixe", "flies.ogg": "moscas", "fox.ogg": "raposa", "frog.ogg": "sapo", "giraffe.ogg": "girafa", "gorilla.ogg": "gorila", "hedgehog.ogg": "porco-espinho", "hippopotamus.ogg": "hipopótamo", "horse.ogg": "cavalo", "kangaroo.ogg": "canguru", "lizard.ogg": "lagarto", "mosquito.ogg": "mosquito", "mouse.ogg": "rato", "owl.ogg": "coruja", "panda.ogg": "panda", "pig.ogg": "porco", "rabbit.ogg": "coelho", "reptile.ogg": "réptil", "rhinoceros.ogg": "rinoceronte", "shark.ogg": "tubarão", "sheep.ogg": "ovelha", "snail.ogg": "caracol", "snake.ogg": "cobra", "spider.ogg": "aranha", "turkey.ogg": "peru", "turtle.ogg": "tartaruga", "whale.ogg": "baleia", "wolf.ogg": "lobo"}
    property var incidence:{"m": ["animal.ogg", "camel.ogg", "flies.ogg", "hippopotamus.ogg", "mosquito.ogg"], "r": ["bear.ogg", "beetle.ogg", "bird.ogg", "bug.ogg", "butterfly.ogg", "dragon.ogg", "fox.ogg", "giraffe.ogg", "gorilla.ogg", "hedgehog.ogg", "kangaroo.ogg", "lizard.ogg", "mouse.ogg", "owl.ogg", "pig.ogg", "reptile.ogg", "rhinoceros.ogg", "shark.ogg", "snail.ogg", "snake.ogg", "spider.ogg", "turkey.ogg", "turtle.ogg"], "u": ["bear.ogg", "bug.ogg", "kangaroo.ogg", "mosquito.ogg", "owl.ogg", "shark.ogg", "turkey.ogg", "turtle.ogg"], "q": ["mosquito.ogg"], "-": ["hedgehog.ogg"], "x": ["fish.ogg"], "á": ["bird.ogg"], "t": ["butterfly.ogg", "cat.ogg", "duck.ogg", "hippopotamus.ogg", "lizard.ogg", "mosquito.ogg", "mouse.ogg", "reptile.ogg", "rhinoceros.ogg", "shark.ogg", "turtle.ogg"], "d": ["dragon.ogg", "panda.ogg"], "i": ["animal.ogg", "bull.ogg", "chicken.ogg", "dolphin.ogg", "fish.ogg", "giraffe.ogg", "gorilla.ogg", "hedgehog.ogg", "hippopotamus.ogg", "mosquito.ogg", "reptile.ogg", "rhinoceros.ogg", "whale.ogg"], "l": ["animal.ogg", "bee.ogg", "beetle.ogg", "butterfly.ogg", "camel.ogg", "chicken.ogg", "dolphin.ogg", "gorilla.ogg", "horse.ogg", "lizard.ogg", "rabbit.ogg", "reptile.ogg", "sheep.ogg", "snail.ogg", "whale.ogg", "wolf.ogg"], "j": ["owl.ogg"], "a": ["animal.ogg", "bee.ogg", "beetle.ogg", "bird.ogg", "butterfly.ogg", "camel.ogg", "cat.ogg", "chicken.ogg", "cow.ogg", "dragon.ogg", "duck.ogg", "flies.ogg", "fox.ogg", "frog.ogg", "giraffe.ogg", "gorilla.ogg", "hippopotamus.ogg", "horse.ogg", "kangaroo.ogg", "lizard.ogg", "mouse.ogg", "owl.ogg", "panda.ogg", "shark.ogg", "sheep.ogg", "snail.ogg", "snake.ogg", "spider.ogg", "turtle.ogg", "whale.ogg"], "p": ["bird.ogg", "duck.ogg", "fish.ogg", "fox.ogg", "frog.ogg", "hedgehog.ogg", "hippopotamus.ogg", "panda.ogg", "pig.ogg", "reptile.ogg", "turkey.ogg"], "h": ["bee.ogg", "beetle.ogg", "chicken.ogg", "dolphin.ogg", "hedgehog.ogg", "hippopotamus.ogg", "rabbit.ogg", "sheep.ogg", "spider.ogg"], "n": ["animal.ogg", "chicken.ogg", "dolphin.ogg", "hedgehog.ogg", "kangaroo.ogg", "panda.ogg", "rhinoceros.ogg", "spider.ogg"], "g": ["cat.ogg", "chicken.ogg", "dolphin.ogg", "dragon.ogg", "giraffe.ogg", "gorilla.ogg", "kangaroo.ogg", "lizard.ogg", "turtle.ogg"], "é": ["reptile.ogg"], "s": ["bear.ogg", "beetle.ogg", "bird.ogg", "bug.ogg", "flies.ogg", "fox.ogg", "frog.ogg", "hedgehog.ogg", "mosquito.ogg"], "o": ["bear.ogg", "beetle.ogg", "bird.ogg", "bug.ogg", "butterfly.ogg", "camel.ogg", "cat.ogg", "dog.ogg", "dolphin.ogg", "dragon.ogg", "duck.ogg", "flies.ogg", "fox.ogg", "frog.ogg", "gorilla.ogg", "hedgehog.ogg", "hippopotamus.ogg", "horse.ogg", "lizard.ogg", "mosquito.ogg", "mouse.ogg", "owl.ogg", "pig.ogg", "rabbit.ogg", "rhinoceros.ogg", "shark.ogg", "sheep.ogg", "snail.ogg", "snake.ogg", "wolf.ogg"], "c": ["beetle.ogg", "camel.ogg", "cow.ogg", "dog.ogg", "flies.ogg", "hedgehog.ogg", "horse.ogg", "kangaroo.ogg", "owl.ogg", "pig.ogg", "rabbit.ogg", "rhinoceros.ogg", "snail.ogg", "snake.ogg"], "f": ["dolphin.ogg", "giraffe.ogg"], "e": ["bee.ogg", "beetle.ogg", "bug.ogg", "butterfly.ogg", "camel.ogg", "fish.ogg", "hedgehog.ogg", "rabbit.ogg", "rhinoceros.ogg", "sheep.ogg", "turkey.ogg", "whale.ogg"], "b": ["bee.ogg", "bug.ogg", "bull.ogg", "butterfly.ogg", "shark.ogg", "snake.ogg", "whale.ogg", "wolf.ogg"], "v": ["beetle.ogg", "cow.ogg", "horse.ogg", "sheep.ogg"], "ã": ["dog.ogg", "dragon.ogg", "shark.ogg"], "ó": ["bull.ogg", "hippopotamus.ogg"]}
    property var counts:{"animal.ogg": {"a": 2, "n": 1, "i": 1, "m": 1, "l": 1}, "bear.ogg": {"u": 1, "r": 1, "s": 1, "o": 1}, "bee.ogg": {"a": 2, "b": 1, "e": 1, "l": 1, "h": 1}, "beetle.ogg": {"e": 2, "s": 1, "c": 1, "a": 2, "r": 1, "v": 1, "l": 1, "h": 1, "o": 1}, "bird.ogg": {"p": 1, "á": 1, "s": 2, "a": 1, "r": 1, "o": 1}, "bug.ogg": {"b": 1, "e": 1, "s": 1, "o": 2, "u": 1, "r": 1}, "bull.ogg": {"b": 1, "ó": 1, "i": 1}, "butterfly.ogg": {"b": 2, "o": 2, "r": 1, "l": 1, "e": 1, "t": 1, "a": 1}, "camel.ogg": {"c": 1, "a": 1, "m": 1, "e": 1, "l": 1, "o": 1}, "cat.ogg": {"g": 1, "a": 1, "t": 1, "o": 1}, "chicken.ogg": {"g": 1, "a": 2, "l": 1, "i": 1, "n": 1, "h": 1}, "cow.ogg": {"v": 1, "a": 2, "c": 1}, "dog.ogg": {"c": 1, "ã": 1, "o": 1}, "dolphin.ogg": {"g": 1, "o": 2, "l": 1, "f": 1, "i": 1, "n": 1, "h": 1}, "dragon.ogg": {"d": 1, "r": 1, "a": 1, "g": 1, "ã": 1, "o": 1}, "duck.ogg": {"p": 1, "a": 1, "t": 1, "o": 1}, "fish.ogg": {"p": 1, "e": 2, "i": 1, "x": 1}, "flies.ogg": {"m": 1, "o": 1, "s": 2, "c": 1, "a": 1}, "fox.ogg": {"r": 1, "a": 2, "p": 1, "o": 1, "s": 1}, "frog.ogg": {"s": 1, "a": 1, "p": 1, "o": 1}, "giraffe.ogg": {"g": 1, "i": 1, "r": 1, "a": 2, "f": 1}, "gorilla.ogg": {"g": 1, "o": 1, "r": 1, "i": 1, "l": 1, "a": 1}, "hedgehog.ogg": {"p": 2, "o": 3, "r": 1, "c": 1, "-": 1, "e": 1, "s": 1, "i": 1, "n": 1, "h": 1}, "hippopotamus.ogg": {"h": 1, "i": 1, "p": 2, "o": 2, "ó": 1, "t": 1, "a": 1, "m": 1}, "horse.ogg": {"c": 1, "a": 2, "v": 1, "l": 1, "o": 1}, "kangaroo.ogg": {"c": 1, "a": 1, "n": 1, "g": 1, "u": 2, "r": 1}, "lizard.ogg": {"l": 1, "a": 2, "g": 1, "r": 1, "t": 1, "o": 1}, "mosquito.ogg": {"m": 1, "o": 2, "s": 1, "q": 1, "u": 1, "i": 1, "t": 1}, "mouse.ogg": {"r": 1, "a": 1, "t": 1, "o": 1}, "owl.ogg": {"c": 1, "o": 1, "r": 1, "u": 1, "j": 1, "a": 1}, "panda.ogg": {"p": 1, "a": 2, "n": 1, "d": 1}, "pig.ogg": {"p": 1, "o": 2, "r": 1, "c": 1}, "rabbit.ogg": {"c": 1, "o": 2, "e": 1, "l": 1, "h": 1}, "reptile.ogg": {"r": 1, "é": 1, "p": 1, "t": 1, "i": 1, "l": 1}, "rhinoceros.ogg": {"r": 2, "i": 1, "n": 2, "o": 2, "c": 1, "e": 2, "t": 1}, "shark.ogg": {"t": 1, "u": 1, "b": 1, "a": 1, "r": 1, "ã": 1, "o": 1}, "sheep.ogg": {"o": 1, "v": 1, "e": 1, "l": 1, "h": 1, "a": 1}, "snail.ogg": {"c": 2, "a": 2, "r": 1, "o": 1, "l": 1}, "snake.ogg": {"c": 1, "o": 1, "b": 1, "r": 1, "a": 1}, "spider.ogg": {"a": 3, "r": 1, "n": 1, "h": 1}, "turkey.ogg": {"p": 1, "e": 1, "r": 1, "u": 1}, "turtle.ogg": {"t": 2, "a": 3, "r": 2, "u": 1, "g": 1}, "whale.ogg": {"b": 1, "a": 2, "l": 1, "e": 1, "i": 1}, "wolf.ogg": {"l": 1, "o": 2, "b": 1}}
    property int lessonIndex:4
    property int configuredMode:11
    property int configuredCase:1
    property bool externalWords:false
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
