// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteLetterInWordLessonPT"
    when:activity.visible
    property var expectedWords:{"alphabet.ogg": "alfabeto", "angel.ogg": "anjo", "behind.ogg": "atrás", "bit.ogg": "dentada", "bone.ogg": "osso", "bubble.ogg": "bolha", "camp.ogg": "acampar", "carnival.ogg": "carnaval", "chores.ogg": "afazeres", "christmas.ogg": "natal", "craft.ogg": "artesanato", "dot.ogg": "ponto", "engine.ogg": "motor", "fairy.ogg": "fada", "flat.ogg": "andar", "front.ogg": "em frente", "gnome.ogg": "gnomo", "guignol.ogg": "roberto", "half.ogg": "metade", "king.ogg": "rei", "knight.ogg": "cavaleiro", "lad.ogg": "moço", "left.ogg": "esquerda", "light.ogg": "luz", "line.ogg": "linha", "link.ogg": "elo", "movie.ogg": "cinema", "music.ogg": "música", "number.ogg": "número", "on.ogg": "em cima", "pedal.ogg": "pedal", "pirate.ogg": "pirata", "pope.ogg": "papa", "porthole.ogg": "escotilha", "president.ogg": "presidente", "price.ogg": "preço", "prince.ogg": "príncipe", "princess.ogg": "princesa", "prisoner.ogg": "prisioneiro", "queen.ogg": "rainha", "question.ogg": "pergunta", "quiz.ogg": "questionário", "right.ogg": "direita", "rocket.ogg": "foguetão", "round.ogg": "redondo", "science.ogg": "ciência", "splatter.ogg": "salpico", "spot.ogg": "mancha", "square.ogg": "quadrado", "stand.ogg": "de pé", "stripe.ogg": "tira", "student.ogg": "estudante", "text.ogg": "texto", "thief.ogg": "ladrão", "triangle.ogg": "triângulo", "trip.ogg": "viagem", "tune.ogg": "música", "under.ogg": "debaixo", "vowel.ogg": "vogal", "weight.ogg": "peso", "word.ogg": "palavra"}
    property var incidence:{"m": ["camp.ogg", "engine.ogg", "front.ogg", "gnome.ogg", "half.ogg", "lad.ogg", "movie.ogg", "music.ogg", "number.ogg", "on.ogg", "spot.ogg", "trip.ogg", "tune.ogg"], "x": ["text.ogg", "under.ogg"], "t": ["alphabet.ogg", "behind.ogg", "bit.ogg", "christmas.ogg", "craft.ogg", "dot.ogg", "engine.ogg", "front.ogg", "guignol.ogg", "half.ogg", "pirate.ogg", "porthole.ogg", "president.ogg", "question.ogg", "quiz.ogg", "right.ogg", "rocket.ogg", "stripe.ogg", "student.ogg", "text.ogg", "triangle.ogg"], "d": ["bit.ogg", "fairy.ogg", "flat.ogg", "half.ogg", "left.ogg", "pedal.ogg", "president.ogg", "right.ogg", "round.ogg", "square.ogg", "stand.ogg", "student.ogg", "thief.ogg", "under.ogg"], "i": ["king.ogg", "knight.ogg", "line.ogg", "movie.ogg", "music.ogg", "on.ogg", "pirate.ogg", "porthole.ogg", "president.ogg", "prince.ogg", "princess.ogg", "prisoner.ogg", "queen.ogg", "quiz.ogg", "right.ogg", "science.ogg", "splatter.ogg", "stripe.ogg", "triangle.ogg", "trip.ogg", "tune.ogg", "under.ogg"], "â": ["triangle.ogg"], "j": ["angel.ogg"], "g": ["gnome.ogg", "question.ogg", "rocket.ogg", "triangle.ogg", "trip.ogg", "vowel.ogg"], "z": ["chores.ogg", "light.ogg"], "s": ["behind.ogg", "bone.ogg", "chores.ogg", "craft.ogg", "left.ogg", "music.ogg", "porthole.ogg", "president.ogg", "princess.ogg", "prisoner.ogg", "quiz.ogg", "splatter.ogg", "student.ogg", "tune.ogg", "weight.ogg"], "o": ["alphabet.ogg", "angel.ogg", "bone.ogg", "bubble.ogg", "craft.ogg", "dot.ogg", "engine.ogg", "gnome.ogg", "guignol.ogg", "knight.ogg", "lad.ogg", "link.ogg", "number.ogg", "porthole.ogg", "price.ogg", "prisoner.ogg", "quiz.ogg", "rocket.ogg", "round.ogg", "splatter.ogg", "square.ogg", "text.ogg", "thief.ogg", "triangle.ogg", "under.ogg", "vowel.ogg", "weight.ogg"], "c": ["camp.ogg", "carnival.ogg", "knight.ogg", "movie.ogg", "music.ogg", "on.ogg", "porthole.ogg", "prince.ogg", "princess.ogg", "science.ogg", "splatter.ogg", "spot.ogg", "tune.ogg"], "f": ["alphabet.ogg", "chores.ogg", "fairy.ogg", "front.ogg", "rocket.ogg"], "e": ["alphabet.ogg", "bit.ogg", "chores.ogg", "craft.ogg", "front.ogg", "guignol.ogg", "half.ogg", "king.ogg", "knight.ogg", "left.ogg", "link.ogg", "movie.ogg", "number.ogg", "on.ogg", "pedal.ogg", "porthole.ogg", "president.ogg", "price.ogg", "prince.ogg", "princess.ogg", "prisoner.ogg", "question.ogg", "quiz.ogg", "right.ogg", "rocket.ogg", "round.ogg", "stand.ogg", "student.ogg", "text.ogg", "trip.ogg", "under.ogg", "weight.ogg"], "v": ["carnival.ogg", "knight.ogg", "trip.ogg", "vowel.ogg", "word.ogg"], "ã": ["rocket.ogg", "thief.ogg"], "ê": ["science.ogg"], "r": ["behind.ogg", "camp.ogg", "carnival.ogg", "chores.ogg", "craft.ogg", "engine.ogg", "flat.ogg", "front.ogg", "guignol.ogg", "king.ogg", "knight.ogg", "left.ogg", "number.ogg", "pirate.ogg", "president.ogg", "price.ogg", "prince.ogg", "princess.ogg", "prisoner.ogg", "queen.ogg", "question.ogg", "quiz.ogg", "right.ogg", "round.ogg", "square.ogg", "stripe.ogg", "thief.ogg", "triangle.ogg", "word.ogg"], "u": ["left.ogg", "light.ogg", "question.ogg", "quiz.ogg", "rocket.ogg", "square.ogg", "student.ogg", "triangle.ogg"], "q": ["left.ogg", "quiz.ogg", "square.ogg"], "á": ["behind.ogg", "quiz.ogg"], "í": ["prince.ogg"], "ç": ["lad.ogg", "price.ogg"], "l": ["alphabet.ogg", "bubble.ogg", "carnival.ogg", "christmas.ogg", "knight.ogg", "light.ogg", "line.ogg", "link.ogg", "pedal.ogg", "porthole.ogg", "splatter.ogg", "thief.ogg", "triangle.ogg", "vowel.ogg", "word.ogg"], "ú": ["music.ogg", "number.ogg", "tune.ogg"], "a": ["alphabet.ogg", "angel.ogg", "behind.ogg", "bit.ogg", "bubble.ogg", "camp.ogg", "carnival.ogg", "chores.ogg", "christmas.ogg", "craft.ogg", "fairy.ogg", "flat.ogg", "half.ogg", "knight.ogg", "left.ogg", "line.ogg", "movie.ogg", "music.ogg", "on.ogg", "pedal.ogg", "pirate.ogg", "pope.ogg", "porthole.ogg", "princess.ogg", "queen.ogg", "question.ogg", "right.ogg", "science.ogg", "splatter.ogg", "spot.ogg", "square.ogg", "stripe.ogg", "student.ogg", "thief.ogg", "trip.ogg", "tune.ogg", "under.ogg", "vowel.ogg", "word.ogg"], "p": ["camp.ogg", "dot.ogg", "pedal.ogg", "pirate.ogg", "pope.ogg", "president.ogg", "price.ogg", "prince.ogg", "princess.ogg", "prisoner.ogg", "question.ogg", "splatter.ogg", "stand.ogg", "weight.ogg", "word.ogg"], "h": ["bubble.ogg", "line.ogg", "porthole.ogg", "queen.ogg", "spot.ogg"], "n": ["angel.ogg", "bit.ogg", "carnival.ogg", "christmas.ogg", "craft.ogg", "dot.ogg", "flat.ogg", "front.ogg", "gnome.ogg", "line.ogg", "movie.ogg", "number.ogg", "president.ogg", "prince.ogg", "princess.ogg", "prisoner.ogg", "queen.ogg", "question.ogg", "quiz.ogg", "round.ogg", "science.ogg", "spot.ogg", "student.ogg", "triangle.ogg"], "é": ["stand.ogg"], "b": ["alphabet.ogg", "bubble.ogg", "guignol.ogg", "under.ogg"]}
    property var counts:{"alphabet.ogg": {"a": 2, "l": 1, "f": 1, "b": 1, "e": 1, "t": 1, "o": 1}, "angel.ogg": {"a": 1, "n": 1, "j": 1, "o": 1}, "behind.ogg": {"a": 1, "t": 1, "r": 1, "á": 1, "s": 1}, "bit.ogg": {"d": 2, "e": 1, "n": 1, "t": 1, "a": 2}, "bone.ogg": {"o": 2, "s": 2}, "bubble.ogg": {"b": 1, "o": 1, "l": 1, "h": 1, "a": 1}, "camp.ogg": {"a": 3, "c": 1, "m": 1, "p": 1, "r": 1}, "carnival.ogg": {"c": 1, "a": 3, "r": 1, "n": 1, "v": 1, "l": 1}, "chores.ogg": {"a": 2, "f": 1, "z": 1, "e": 2, "r": 1, "s": 1}, "christmas.ogg": {"n": 1, "a": 2, "t": 1, "l": 1}, "craft.ogg": {"a": 3, "r": 1, "t": 2, "e": 1, "s": 1, "n": 1, "o": 1}, "dot.ogg": {"p": 1, "o": 2, "n": 1, "t": 1}, "engine.ogg": {"m": 1, "o": 2, "t": 1, "r": 1}, "fairy.ogg": {"f": 1, "a": 2, "d": 1}, "flat.ogg": {"a": 2, "n": 1, "d": 1, "r": 1}, "front.ogg": {"e": 3, "m": 1, "f": 1, "r": 1, "n": 1, "t": 1}, "gnome.ogg": {"g": 1, "n": 1, "o": 2, "m": 1}, "guignol.ogg": {"r": 2, "o": 2, "b": 1, "e": 1, "t": 1}, "half.ogg": {"m": 1, "e": 2, "t": 1, "a": 1, "d": 1}, "king.ogg": {"r": 1, "e": 1, "i": 1}, "knight.ogg": {"c": 1, "a": 2, "v": 1, "l": 1, "e": 1, "i": 1, "r": 1, "o": 1}, "lad.ogg": {"m": 1, "o": 2, "ç": 1}, "left.ogg": {"e": 2, "s": 1, "q": 1, "u": 1, "r": 1, "d": 1, "a": 1}, "light.ogg": {"l": 1, "u": 1, "z": 1}, "line.ogg": {"l": 1, "i": 1, "n": 1, "h": 1, "a": 1}, "link.ogg": {"e": 1, "l": 1, "o": 1}, "movie.ogg": {"c": 1, "i": 1, "n": 1, "e": 1, "m": 1, "a": 1}, "music.ogg": {"m": 1, "ú": 1, "s": 1, "i": 1, "c": 1, "a": 1}, "number.ogg": {"n": 1, "ú": 1, "m": 1, "e": 1, "r": 1, "o": 1}, "on.ogg": {"e": 1, "m": 2, "c": 1, "i": 1, "a": 1}, "pedal.ogg": {"p": 1, "e": 1, "d": 1, "a": 1, "l": 1}, "pirate.ogg": {"p": 1, "i": 1, "r": 1, "a": 2, "t": 1}, "pope.ogg": {"p": 2, "a": 2}, "porthole.ogg": {"e": 1, "s": 1, "c": 1, "o": 1, "t": 1, "i": 1, "l": 1, "h": 1, "a": 1}, "president.ogg": {"p": 1, "r": 1, "e": 3, "s": 1, "i": 1, "d": 1, "n": 1, "t": 1}, "price.ogg": {"p": 1, "r": 1, "e": 1, "ç": 1, "o": 1}, "prince.ogg": {"p": 2, "r": 1, "í": 1, "n": 1, "c": 1, "i": 1, "e": 1}, "princess.ogg": {"p": 1, "r": 1, "i": 1, "n": 1, "c": 1, "e": 1, "s": 1, "a": 1}, "prisoner.ogg": {"p": 1, "r": 2, "i": 3, "s": 1, "o": 2, "n": 1, "e": 1}, "queen.ogg": {"r": 1, "a": 2, "i": 1, "n": 1, "h": 1}, "question.ogg": {"p": 1, "e": 1, "r": 1, "g": 1, "u": 1, "n": 1, "t": 1, "a": 1}, "quiz.ogg": {"q": 1, "u": 1, "e": 1, "s": 1, "t": 1, "i": 2, "o": 2, "n": 1, "á": 1, "r": 1}, "right.ogg": {"d": 1, "i": 2, "r": 1, "e": 1, "t": 1, "a": 1}, "rocket.ogg": {"f": 1, "o": 2, "g": 1, "u": 1, "e": 1, "t": 1, "ã": 1}, "round.ogg": {"r": 1, "e": 1, "d": 2, "o": 2, "n": 1}, "science.ogg": {"c": 2, "i": 2, "ê": 1, "n": 1, "a": 1}, "splatter.ogg": {"s": 1, "a": 1, "l": 1, "p": 1, "i": 1, "c": 1, "o": 1}, "spot.ogg": {"m": 1, "a": 2, "n": 1, "c": 1, "h": 1}, "square.ogg": {"q": 1, "u": 1, "a": 2, "d": 2, "r": 1, "o": 1}, "stand.ogg": {"d": 1, "e": 1, "p": 1, "é": 1}, "stripe.ogg": {"t": 1, "i": 1, "r": 1, "a": 1}, "student.ogg": {"e": 2, "s": 1, "t": 2, "u": 1, "d": 1, "a": 1, "n": 1}, "text.ogg": {"t": 2, "e": 1, "x": 1, "o": 1}, "thief.ogg": {"l": 1, "a": 1, "d": 1, "r": 1, "ã": 1, "o": 1}, "triangle.ogg": {"t": 1, "r": 1, "i": 1, "â": 1, "n": 1, "g": 1, "u": 1, "l": 1, "o": 1}, "trip.ogg": {"v": 1, "i": 1, "a": 1, "g": 1, "e": 1, "m": 1}, "tune.ogg": {"m": 1, "ú": 1, "s": 1, "i": 1, "c": 1, "a": 1}, "under.ogg": {"d": 1, "e": 1, "b": 1, "a": 1, "i": 1, "x": 1, "o": 1}, "vowel.ogg": {"v": 1, "o": 1, "g": 1, "a": 1, "l": 1}, "weight.ogg": {"p": 1, "e": 1, "s": 1, "o": 1}, "word.ogg": {"p": 1, "a": 3, "l": 1, "v": 1, "r": 1}}
    property int lessonIndex:0
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
