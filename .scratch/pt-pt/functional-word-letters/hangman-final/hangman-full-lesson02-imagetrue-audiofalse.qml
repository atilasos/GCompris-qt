// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteHangmanLessonPT"
    when:activity.visible
    property var expectedWords: {"bark.ogg": "ladrar", "beat.ogg": "bater", "beg.ogg": "implorar", "bite.ogg": "morder", "blink.ogg": "piscar", "boil.ogg": "ferver", "break.ogg": "despedaçar", "call.ogg": "chamar", "catch.ogg": "apanhar", "chat.ogg": "conversar", "chop.ogg": "cortar", "clap.ogg": "bater palmas", "clean.ogg": "tomar banho", "cook.ogg": "cozinhar", "cough.ogg": "tossir", "crawl.ogg": "gatinhar", "croak.ogg": "coaxar", "cry.ogg": "chorar", "cut.ogg": "cortar", "dig.ogg": "cavar", "draw.ogg": "desenhar", "dream.ogg": "sonhar", "to_drink.ogg": "beber", "drive.ogg": "conduzir", "drool.ogg": "salivar", "dry.ogg": "secar", "eat.ogg": "comer", "feed.ogg": "alimentar", "fall.ogg": "cair", "fetch.ogg": "buscar", "find.ogg": "encontrar", "float.ogg": "flutuar", "fly.ogg": "voar", "freeze.ogg": "congelar", "growl.ogg": "rosnar", "hatch.ogg": "chocar", "hear.ogg": "ouvir", "howl.ogg": "uivar", "hug.ogg": "abraçar", "jump.ogg": "saltar", "kiss.ogg": "beijar", "kneel.ogg": "ajoelhar", "knit.ogg": "tricotar", "lick.ogg": "lamber", "look.ogg": "olhar", "meet.ogg": "travar conhecimento", "nap.ogg": "dormitar", "peck.ogg": "bicar", "play.ogg": "brincar", "plow.ogg": "lavrar", "pounce.ogg": "atacar", "pull.ogg": "puxar", "quarrel.ogg": "discutir", "read.ogg": "ler", "rip.ogg": "rasgar", "rise.ogg": "subir", "run.ogg": "correr", "scare.ogg": "assustar", "scratch.ogg": "arranhar", "scream.ogg": "gritar", "scribble.ogg": "rabiscar", "see.ogg": "ver", "shake.ogg": "chocalhar", "shave.ogg": "tosquiar", "sing.ogg": "cantar", "sip.ogg": "sorver", "sit.ogg": "sentar", "slam.ogg": "marcar", "sleep.ogg": "dormir", "smell.ogg": "cheirar", "smooch.ogg": "beijocar", "sniff.ogg": "farejar", "speak.ogg": "falar", "spill.ogg": "entornar", "splash.ogg": "salpicar", "spray.ogg": "aspergir", "spread.ogg": "espalhar", "spring.ogg": "pular", "squat.ogg": "agachar", "stare.ogg": "fitar", "sting.ogg": "aferroar", "stitch.ogg": "coser", "stop.ogg": "parar", "stretch.ogg": "esticar", "study.ogg": "estudar", "teach.ogg": "ensinar", "tear.ogg": "rasgar", "think.ogg": "pensar", "touch.ogg": "tocar", "wag.ogg": "abanar", "walk.ogg": "andar", "wash.ogg": "lavar", "whisper.ogg": "sussurrar", "win.ogg": "ganhar", "write.ogg": "escrever"}
    property int lessonIndex: 1
    property bool externalWords: true
    property bool imageHint: true
    property bool audioHint: false
    property var completed:[]
    property var unicodeInput:null
    property int physicalInputs:0
    property int virtualInputs:0
    property var accented:({})
    function checked(actual,expected,message) {
        if(actual!==expected)console.log("WORD_FAILURE",JSON.stringify({actual:actual,expected:expected,message:message}));
        compare(actual,expected,message||"");
    }
    function findKey(item,text) {
        if(item.text!==undefined && item.text===text && item.visible)return item;
        if(item.children)for(var i=0;i<item.children.length;i++) {
            var result=findKey(item.children[i],text);if(result)return result;
        }
        return null;
    }
    function physical(text) {
        textinput.forceActiveFocus();
        if(text.charCodeAt(0)>127) {
            if(unicodeInput===null)unicodeInput=Qt.createQmlObject('import "file:__QA_SOURCE__/build/functional-input"; UnicodeInput {}',this);
            var previous=items.hidden.text;
            verify(unicodeInput.preedit(textinput,text));
            checked(items.hidden.text,previous,"IME preedit is not a guess");
            verify(unicodeInput.commit(textinput,text));
        } else keyClick(text,Qt.NoModifier,0);
        physicalInputs++;
    }
    function virtualKey(text) {
        var button=findKey(keyboard,text);
        verify(button!==null,"Real virtual key exists for "+text);
        mouseClick(button,button.width/2,button.height/2,Qt.LeftButton,Qt.NoModifier,50);
        virtualInputs++;
    }
    function mask(word,guessed) {
        var result="";
        for(var i=0;i<word.length;i++)result+=(word[i]===" "?" ":guessed[word[i].toLowerCase()]?word[i]:"_")+" ";
        return result;
    }
    function test_complete_entire_lesson() {
        wait(1800);
        ApplicationSettings.isVirtualKeyboard=true;
        ApplicationSettings.isAudioVoicesEnabled=true;
        items.easyModeImage=imageHint;
        items.easyModeAudio=audioHint;
        // Public launch level selects the lesson. Only configuration is changed.
        checked(items.currentLevel,lessonIndex);
        checked(ApplicationSettings.useExternalWordset(),externalWords);
        checked(activityBackground.englishFallback,false);
        checked(score.numberOfSubLevels,Object.keys(expectedWords).length);
        tryCompare(keyboard,"visible",true,3000);
        wait(300);
        var seen={};
        for(var ordinal=0;ordinal<Object.keys(expectedWords).length;ordinal++) {
            checked(items.currentLevel,lessonIndex);
            checked(score.currentSubLevel,ordinal+1);
            checked(items.remainingLife,6);
            var source=String(wordImage.source);
            var key=source.slice(source.lastIndexOf('/')+1).replace('.webp','.ogg');
            var target=expectedWords[key];
            verify(target!==undefined,"Displayed image belongs to audited lesson");
            verify(!seen[key],"No word repeated before exhausting lesson");
            seen[key]=true;
            var guessed={},letters=[];
            checked(items.hidden.text,mask(target,guessed));
            if(ordinal===0) {
                physical("1");physical("2");physical("#");
                checked(items.remainingLife,3,"Three wrong guesses cost three lives");
                physical("#");
                checked(items.remainingLife,3,"Repeated wrong guess costs no extra life");
                checked(items.hidden.text,mask(target,guessed));
            }
            for(var i=0;i<target.length;i++) {
                var character=target[i].toLowerCase();
                if(character===' ' || letters.indexOf(character)!==-1)continue;
                letters.push(character);
                var life=items.remainingLife;
                if(i%2===0)physical(character.toUpperCase());
                else virtualKey(character);
                guessed[character]=true;
                checked(items.remainingLife,life,"Correct accented/case-folded letter costs no life");
                if(character.charCodeAt(0)>127)accented[character]=true;
                var expectedMask=mask(target,guessed);
                if(expectedMask.indexOf('_')>=0) {
                    checked(items.hidden.text,expectedMask,"Exact source positions revealed");
                    checked(goodIcon.visible,false);
                }
            }
            checked(items.hidden.text,target);
            checked(goodIcon.visible,true);
            completed.push({ordinal:ordinal+1,key:key,word:target,remainingLife:items.remainingLife});
            console.log("HANGMAN_COMPLETED",JSON.stringify(completed[completed.length-1]));
            if(ordinal===0)grabImage(pageView).save("__QA_OUTPUT__/first-word.png");
            if(ordinal===Object.keys(expectedWords).length-1) {
                tryCompare(items,"currentLevel",(lessonIndex+1)%items.numberOfLevel,8500);
                checked(score.currentSubLevel,1);
            } else {
                tryCompare(score,"currentSubLevel",ordinal+2,8500);
                tryCompare(goodIcon,"visible",false,1000);
            }
            wait(40);
        }
        checked(Object.keys(seen).length,Object.keys(expectedWords).length);
        verify(physicalInputs>0 && virtualInputs>0);
    }
    function cleanupTestCase(){console.log("NATIVE_RESULT",JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,lesson:lessonIndex,externalWords:externalWords,imageHint:imageHint,audioHint:audioHint,physicalInputs:physicalInputs,virtualInputs:virtualInputs,accented:accented,completed:completed}));}
}
