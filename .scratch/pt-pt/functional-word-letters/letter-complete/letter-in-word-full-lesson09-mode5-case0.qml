// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteLetterInWordLessonPT"
    when:activity.visible
    property var expectedWords:{"accountant.ogg": "contabilista", "actor.ogg": "actor", "artist.ogg": "artista", "astronaut.ogg": "astronauta", "boxer.ogg": "pugilista", "banker_female.ogg": "bancária", "bricklayer.ogg": "pedreiro", "butcher.ogg": "talhante", "carpenter.ogg": "carpinteiro", "chef.ogg": "cozinheiro", "cleaning_lady.ogg": "empregada de limpeza", "clown.ogg": "palhaço", "coach.ogg": "treinador", "cowboy.ogg": "campino", "doctor.ogg": "médico", "electrician.ogg": "electricista", "engineer.ogg": "engenheiro", "farmer.ogg": "agricultor", "fireman.ogg": "bombeiro", "fisherman.ogg": "pescador", "hunter.ogg": "caçador", "job.ogg": "ocupação", "jockey.ogg": "jockey", "judge.ogg": "juiz", "juggler.ogg": "malabarista", "lawyer.ogg": "advogado", "librarian.ogg": "bibliotecária", "mechanic.ogg": "mecânico", "musician.ogg": "músico", "nun.ogg": "freira", "nurse.ogg": "enfermeira", "nurse_male.ogg": "enfermeiro", "pilot.ogg": "piloto", "plumber.ogg": "canalizador", "police.ogg": "polícia", "priest.ogg": "padre", "sailor.ogg": "marinheiro", "soldier.ogg": "soldado", "teacher.ogg": "professora", "vet.ogg": "veterinário", "worker.ogg": "operário"}
    property var incidence:{"m": ["cleaning_lady.ogg", "cowboy.ogg", "doctor.ogg", "fireman.ogg", "juggler.ogg", "mechanic.ogg", "musician.ogg", "nurse.ogg", "nurse_male.ogg", "sailor.ogg"], "r": ["actor.ogg", "artist.ogg", "astronaut.ogg", "banker_female.ogg", "bricklayer.ogg", "carpenter.ogg", "chef.ogg", "cleaning_lady.ogg", "coach.ogg", "electrician.ogg", "engineer.ogg", "farmer.ogg", "fireman.ogg", "fisherman.ogg", "hunter.ogg", "juggler.ogg", "librarian.ogg", "nun.ogg", "nurse.ogg", "nurse_male.ogg", "plumber.ogg", "priest.ogg", "sailor.ogg", "teacher.ogg", "vet.ogg", "worker.ogg"], "u": ["astronaut.ogg", "boxer.ogg", "farmer.ogg", "job.ogg", "judge.ogg"], "á": ["banker_female.ogg", "librarian.ogg", "vet.ogg", "worker.ogg"], "t": ["accountant.ogg", "actor.ogg", "artist.ogg", "astronaut.ogg", "boxer.ogg", "butcher.ogg", "carpenter.ogg", "coach.ogg", "electrician.ogg", "farmer.ogg", "juggler.ogg", "librarian.ogg", "pilot.ogg", "vet.ogg"], "í": ["police.ogg"], "d": ["bricklayer.ogg", "cleaning_lady.ogg", "coach.ogg", "doctor.ogg", "fisherman.ogg", "hunter.ogg", "lawyer.ogg", "plumber.ogg", "priest.ogg", "soldier.ogg"], "i": ["accountant.ogg", "artist.ogg", "boxer.ogg", "banker_female.ogg", "bricklayer.ogg", "carpenter.ogg", "chef.ogg", "cleaning_lady.ogg", "coach.ogg", "cowboy.ogg", "doctor.ogg", "electrician.ogg", "engineer.ogg", "farmer.ogg", "fireman.ogg", "judge.ogg", "juggler.ogg", "librarian.ogg", "mechanic.ogg", "musician.ogg", "nun.ogg", "nurse.ogg", "nurse_male.ogg", "pilot.ogg", "plumber.ogg", "police.ogg", "sailor.ogg", "vet.ogg", "worker.ogg"], "â": ["mechanic.ogg"], "ç": ["clown.ogg", "hunter.ogg", "job.ogg"], "j": ["jockey.ogg", "judge.ogg"], "l": ["accountant.ogg", "boxer.ogg", "butcher.ogg", "cleaning_lady.ogg", "clown.ogg", "electrician.ogg", "farmer.ogg", "juggler.ogg", "librarian.ogg", "pilot.ogg", "plumber.ogg", "police.ogg", "soldier.ogg"], "ú": ["musician.ogg"], "a": ["accountant.ogg", "actor.ogg", "artist.ogg", "astronaut.ogg", "boxer.ogg", "banker_female.ogg", "butcher.ogg", "carpenter.ogg", "cleaning_lady.ogg", "clown.ogg", "coach.ogg", "cowboy.ogg", "electrician.ogg", "farmer.ogg", "fisherman.ogg", "hunter.ogg", "job.ogg", "juggler.ogg", "lawyer.ogg", "librarian.ogg", "nun.ogg", "nurse.ogg", "plumber.ogg", "police.ogg", "priest.ogg", "sailor.ogg", "soldier.ogg", "teacher.ogg"], "p": ["boxer.ogg", "bricklayer.ogg", "carpenter.ogg", "cleaning_lady.ogg", "clown.ogg", "cowboy.ogg", "fisherman.ogg", "job.ogg", "pilot.ogg", "police.ogg", "priest.ogg", "teacher.ogg", "worker.ogg"], "y": ["jockey.ogg"], "h": ["butcher.ogg", "chef.ogg", "clown.ogg", "engineer.ogg", "sailor.ogg"], "k": ["jockey.ogg"], "n": ["accountant.ogg", "astronaut.ogg", "banker_female.ogg", "butcher.ogg", "carpenter.ogg", "chef.ogg", "coach.ogg", "cowboy.ogg", "engineer.ogg", "mechanic.ogg", "nurse.ogg", "nurse_male.ogg", "plumber.ogg", "sailor.ogg", "vet.ogg"], "g": ["boxer.ogg", "cleaning_lady.ogg", "engineer.ogg", "farmer.ogg", "lawyer.ogg"], "z": ["chef.ogg", "cleaning_lady.ogg", "judge.ogg", "plumber.ogg"], "é": ["doctor.ogg"], "s": ["accountant.ogg", "artist.ogg", "astronaut.ogg", "boxer.ogg", "electrician.ogg", "fisherman.ogg", "juggler.ogg", "musician.ogg", "soldier.ogg", "teacher.ogg"], "o": ["accountant.ogg", "actor.ogg", "astronaut.ogg", "bricklayer.ogg", "carpenter.ogg", "chef.ogg", "clown.ogg", "coach.ogg", "cowboy.ogg", "doctor.ogg", "engineer.ogg", "farmer.ogg", "fireman.ogg", "fisherman.ogg", "hunter.ogg", "job.ogg", "jockey.ogg", "lawyer.ogg", "librarian.ogg", "mechanic.ogg", "musician.ogg", "nurse_male.ogg", "pilot.ogg", "plumber.ogg", "police.ogg", "sailor.ogg", "soldier.ogg", "teacher.ogg", "vet.ogg", "worker.ogg"], "c": ["accountant.ogg", "actor.ogg", "banker_female.ogg", "carpenter.ogg", "chef.ogg", "cowboy.ogg", "doctor.ogg", "electrician.ogg", "farmer.ogg", "fisherman.ogg", "hunter.ogg", "job.ogg", "jockey.ogg", "librarian.ogg", "mechanic.ogg", "musician.ogg", "plumber.ogg", "police.ogg"], "f": ["nun.ogg", "nurse.ogg", "nurse_male.ogg", "teacher.ogg"], "e": ["bricklayer.ogg", "butcher.ogg", "carpenter.ogg", "chef.ogg", "cleaning_lady.ogg", "coach.ogg", "electrician.ogg", "engineer.ogg", "fireman.ogg", "fisherman.ogg", "jockey.ogg", "librarian.ogg", "mechanic.ogg", "nun.ogg", "nurse.ogg", "nurse_male.ogg", "priest.ogg", "sailor.ogg", "teacher.ogg", "vet.ogg", "worker.ogg"], "b": ["accountant.ogg", "banker_female.ogg", "fireman.ogg", "juggler.ogg", "librarian.ogg"], "v": ["lawyer.ogg", "vet.ogg"], "ã": ["job.ogg"]}
    property var counts:{"accountant.ogg": {"c": 1, "o": 1, "n": 1, "t": 2, "a": 2, "b": 1, "i": 2, "l": 1, "s": 1}, "actor.ogg": {"a": 1, "c": 1, "t": 1, "o": 1, "r": 1}, "artist.ogg": {"a": 2, "r": 1, "t": 2, "i": 1, "s": 1}, "astronaut.ogg": {"a": 3, "s": 1, "t": 2, "r": 1, "o": 1, "n": 1, "u": 1}, "boxer.ogg": {"p": 1, "u": 1, "g": 1, "i": 2, "l": 1, "s": 1, "t": 1, "a": 1}, "banker_female.ogg": {"b": 1, "a": 2, "n": 1, "c": 1, "á": 1, "r": 1, "i": 1}, "bricklayer.ogg": {"p": 1, "e": 2, "d": 1, "r": 2, "i": 1, "o": 1}, "butcher.ogg": {"t": 2, "a": 2, "l": 1, "h": 1, "n": 1, "e": 1}, "carpenter.ogg": {"c": 1, "a": 1, "r": 2, "p": 1, "i": 2, "n": 1, "t": 1, "e": 1, "o": 1}, "chef.ogg": {"c": 1, "o": 2, "z": 1, "i": 2, "n": 1, "h": 1, "e": 1, "r": 1}, "cleaning_lady.ogg": {"e": 4, "m": 2, "p": 2, "r": 1, "g": 1, "a": 3, "d": 2, "l": 1, "i": 1, "z": 1}, "clown.ogg": {"p": 1, "a": 2, "l": 1, "h": 1, "ç": 1, "o": 1}, "coach.ogg": {"t": 1, "r": 2, "e": 1, "i": 1, "n": 1, "a": 1, "d": 1, "o": 1}, "cowboy.ogg": {"c": 1, "a": 1, "m": 1, "p": 1, "i": 1, "n": 1, "o": 1}, "doctor.ogg": {"m": 1, "é": 1, "d": 1, "i": 1, "c": 1, "o": 1}, "electrician.ogg": {"e": 2, "l": 1, "c": 2, "t": 2, "r": 1, "i": 2, "s": 1, "a": 1}, "engineer.ogg": {"e": 3, "n": 2, "g": 1, "h": 1, "i": 1, "r": 1, "o": 1}, "farmer.ogg": {"a": 1, "g": 1, "r": 2, "i": 1, "c": 1, "u": 1, "l": 1, "t": 1, "o": 1}, "fireman.ogg": {"b": 2, "o": 2, "m": 1, "e": 1, "i": 1, "r": 1}, "fisherman.ogg": {"p": 1, "e": 1, "s": 1, "c": 1, "a": 1, "d": 1, "o": 1, "r": 1}, "hunter.ogg": {"c": 1, "a": 2, "ç": 1, "d": 1, "o": 1, "r": 1}, "job.ogg": {"o": 2, "c": 1, "u": 1, "p": 1, "a": 1, "ç": 1, "ã": 1}, "jockey.ogg": {"j": 1, "o": 1, "c": 1, "k": 1, "e": 1, "y": 1}, "judge.ogg": {"j": 1, "u": 1, "i": 1, "z": 1}, "juggler.ogg": {"m": 1, "a": 4, "l": 1, "b": 1, "r": 1, "i": 1, "s": 1, "t": 1}, "lawyer.ogg": {"a": 2, "d": 2, "v": 1, "o": 2, "g": 1}, "librarian.ogg": {"b": 2, "i": 3, "l": 1, "o": 1, "t": 1, "e": 1, "c": 1, "á": 1, "r": 1, "a": 1}, "mechanic.ogg": {"m": 1, "e": 1, "c": 2, "â": 1, "n": 1, "i": 1, "o": 1}, "musician.ogg": {"m": 1, "ú": 1, "s": 1, "i": 1, "c": 1, "o": 1}, "nun.ogg": {"f": 1, "r": 2, "e": 1, "i": 1, "a": 1}, "nurse.ogg": {"e": 3, "n": 1, "f": 1, "r": 2, "m": 1, "i": 1, "a": 1}, "nurse_male.ogg": {"e": 3, "n": 1, "f": 1, "r": 2, "m": 1, "i": 1, "o": 1}, "pilot.ogg": {"p": 1, "i": 1, "l": 1, "o": 2, "t": 1}, "plumber.ogg": {"c": 1, "a": 3, "n": 1, "l": 1, "i": 1, "z": 1, "d": 1, "o": 1, "r": 1}, "police.ogg": {"p": 1, "o": 1, "l": 1, "í": 1, "c": 1, "i": 1, "a": 1}, "priest.ogg": {"p": 1, "a": 1, "d": 1, "r": 1, "e": 1}, "sailor.ogg": {"m": 1, "a": 1, "r": 2, "i": 2, "n": 1, "h": 1, "e": 1, "o": 1}, "soldier.ogg": {"s": 1, "o": 2, "l": 1, "d": 2, "a": 1}, "teacher.ogg": {"p": 1, "r": 2, "o": 2, "f": 1, "e": 1, "s": 2, "a": 1}, "vet.ogg": {"v": 1, "e": 2, "t": 1, "r": 2, "i": 2, "n": 1, "á": 1, "o": 1}, "worker.ogg": {"o": 2, "p": 1, "e": 1, "r": 2, "á": 1, "i": 1}}
    property int lessonIndex:8
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
