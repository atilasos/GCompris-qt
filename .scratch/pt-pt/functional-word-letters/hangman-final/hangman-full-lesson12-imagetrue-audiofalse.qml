// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteHangmanLessonPT"
    when:activity.visible
    property var expectedWords: {"bread.ogg": "pão", "bun.ogg": "pão de forma", "butter.ogg": "manteiga", "cake.ogg": "bolo", "candy.ogg": "rebuçado", "cereal.ogg": "cereal", "cheese.ogg": "queijo", "chocolate.ogg": "chocolate", "coffee.ogg": "café", "cookie.ogg": "bolacha", "crepe.ogg": "crepe", "crumb.ogg": "migalha", "crust.ogg": "crosta", "dessert.ogg": "sobremesa", "doughnut.ogg": "donut", "drink.ogg": "bebida", "egg.ogg": "ovo", "feast.ogg": "festa", "flour.ogg": "farinha", "fries.ogg": "batatas fritas", "fudge.ogg": "caramelo", "gum.ogg": "pastilha elástica", "ham.ogg": "presunto", "hamburger.ogg": "hambúrguer", "hot_dog.ogg": "cachorro-quente", "ice.ogg": "gelo", "jam.ogg": "compota", "jelly.ogg": "gelatina", "juice.ogg": "sumo", "lemonade.ogg": "limonada", "lunch.ogg": "almoço", "mashed_potatoes.ogg": "puré de batata", "meal.ogg": "refeição", "meat.ogg": "carne", "milk.ogg": "leite", "pepper.ogg": "pimenta", "pie.ogg": "tarte", "pizza.ogg": "pizza", "popcorn.ogg": "pipocas", "rice.ogg": "arroz", "roast.ogg": "assado", "sandwich.ogg": "sanduíche", "sauce.ogg": "molho", "sausage.ogg": "salsicha", "snack.ogg": "lanche", "soup.ogg": "sopa", "spaghetti.ogg": "esparguete", "spice.ogg": "especiarias", "sprinkle.ogg": "pepitas", "stew.ogg": "guisado", "sugar.ogg": "açúcar", "treat.ogg": "guloseima", "yogurt.ogg": "iogurte"}
    property int lessonIndex: 11
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
