// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteLetterInWordLessonPT"
    when:activity.visible
    property var expectedWords:{"bathing_suit.ogg": "fato de banho", "bib.ogg": "babete", "button.ogg": "botão", "cap.ogg": "boné", "cape.ogg": "capa", "coat.ogg": "casaco", "dress.ogg": "vestido", "glove.ogg": "luva", "hat.ogg": "chapéu", "heel.ogg": "salto", "helmet.ogg": "capacete", "jacket.ogg": "casaco", "kimono.ogg": "quimono", "nightgown.ogg": "camisa de dormir", "pajamas.ogg": "pijamas", "panties.ogg": "cuecas", "pants.ogg": "calças", "patch.ogg": "remendo", "pocket.ogg": "bolso", "pompon.ogg": "pompom", "pullover.ogg": "camisola", "raincoat.ogg": "capa para a chuva", "robe.ogg": "manto", "sandals.ogg": "sandálias", "sash.ogg": "faixa", "scarf.ogg": "cachecol", "shirt.ogg": "camisa", "shoe.ogg": "sapato", "shoelace.ogg": "atacador", "short.ogg": "calções", "skirt.ogg": "saia", "sleeve.ogg": "manga", "slippers.ogg": "chinelos", "smock.ogg": "avental", "sneaker.ogg": "sapatilhas", "sock.ogg": "meia", "sole_shoe.ogg": "sola", "suit.ogg": "fato", "sweatshirt.ogg": "camisola cardada", "uniform.ogg": "farda", "vest.ogg": "colete", "zipper.ogg": "fecho de correr"}
    property var incidence:{"m": ["kimono.ogg", "nightgown.ogg", "pajamas.ogg", "patch.ogg", "pompon.ogg", "pullover.ogg", "robe.ogg", "shirt.ogg", "sleeve.ogg", "sock.ogg", "sweatshirt.ogg"], "r": ["nightgown.ogg", "patch.ogg", "raincoat.ogg", "shoelace.ogg", "sweatshirt.ogg", "uniform.ogg", "zipper.ogg"], "u": ["glove.ogg", "hat.ogg", "kimono.ogg", "panties.ogg", "raincoat.ogg"], "q": ["kimono.ogg"], "x": ["sash.ogg"], "á": ["sandals.ogg"], "t": ["bathing_suit.ogg", "bib.ogg", "button.ogg", "dress.ogg", "heel.ogg", "helmet.ogg", "robe.ogg", "shoe.ogg", "shoelace.ogg", "smock.ogg", "sneaker.ogg", "suit.ogg", "vest.ogg"], "d": ["bathing_suit.ogg", "dress.ogg", "nightgown.ogg", "patch.ogg", "sandals.ogg", "shoelace.ogg", "sweatshirt.ogg", "uniform.ogg", "zipper.ogg"], "i": ["dress.ogg", "kimono.ogg", "nightgown.ogg", "pajamas.ogg", "pullover.ogg", "sandals.ogg", "sash.ogg", "shirt.ogg", "skirt.ogg", "slippers.ogg", "sneaker.ogg", "sock.ogg", "sweatshirt.ogg"], "ç": ["pants.ogg", "short.ogg"], "l": ["glove.ogg", "heel.ogg", "pants.ogg", "pocket.ogg", "pullover.ogg", "sandals.ogg", "scarf.ogg", "short.ogg", "slippers.ogg", "smock.ogg", "sneaker.ogg", "sole_shoe.ogg", "sweatshirt.ogg", "vest.ogg"], "j": ["pajamas.ogg"], "a": ["bathing_suit.ogg", "bib.ogg", "cape.ogg", "coat.ogg", "glove.ogg", "hat.ogg", "heel.ogg", "helmet.ogg", "jacket.ogg", "nightgown.ogg", "pajamas.ogg", "panties.ogg", "pants.ogg", "pullover.ogg", "raincoat.ogg", "robe.ogg", "sandals.ogg", "sash.ogg", "scarf.ogg", "shirt.ogg", "shoe.ogg", "shoelace.ogg", "short.ogg", "skirt.ogg", "sleeve.ogg", "smock.ogg", "sneaker.ogg", "sock.ogg", "sole_shoe.ogg", "suit.ogg", "sweatshirt.ogg", "uniform.ogg"], "p": ["cape.ogg", "hat.ogg", "helmet.ogg", "pajamas.ogg", "pompon.ogg", "raincoat.ogg", "shoe.ogg", "sneaker.ogg"], "h": ["bathing_suit.ogg", "hat.ogg", "raincoat.ogg", "scarf.ogg", "slippers.ogg", "sneaker.ogg", "zipper.ogg"], "õ": ["short.ogg"], "n": ["bathing_suit.ogg", "cap.ogg", "kimono.ogg", "patch.ogg", "robe.ogg", "sandals.ogg", "sleeve.ogg", "slippers.ogg", "smock.ogg"], "g": ["sleeve.ogg"], "é": ["cap.ogg", "hat.ogg"], "s": ["coat.ogg", "dress.ogg", "heel.ogg", "jacket.ogg", "nightgown.ogg", "pajamas.ogg", "panties.ogg", "pants.ogg", "pocket.ogg", "pullover.ogg", "sandals.ogg", "shirt.ogg", "shoe.ogg", "short.ogg", "skirt.ogg", "slippers.ogg", "sneaker.ogg", "sole_shoe.ogg", "sweatshirt.ogg"], "o": ["bathing_suit.ogg", "button.ogg", "cap.ogg", "coat.ogg", "dress.ogg", "heel.ogg", "jacket.ogg", "kimono.ogg", "nightgown.ogg", "patch.ogg", "pocket.ogg", "pompon.ogg", "pullover.ogg", "robe.ogg", "scarf.ogg", "shoe.ogg", "shoelace.ogg", "slippers.ogg", "sole_shoe.ogg", "suit.ogg", "sweatshirt.ogg", "vest.ogg", "zipper.ogg"], "c": ["cape.ogg", "coat.ogg", "hat.ogg", "helmet.ogg", "jacket.ogg", "nightgown.ogg", "panties.ogg", "pants.ogg", "pullover.ogg", "raincoat.ogg", "scarf.ogg", "shirt.ogg", "shoelace.ogg", "short.ogg", "slippers.ogg", "sweatshirt.ogg", "vest.ogg", "zipper.ogg"], "f": ["bathing_suit.ogg", "sash.ogg", "suit.ogg", "uniform.ogg", "zipper.ogg"], "e": ["bathing_suit.ogg", "bib.ogg", "dress.ogg", "helmet.ogg", "nightgown.ogg", "panties.ogg", "patch.ogg", "scarf.ogg", "short.ogg", "slippers.ogg", "smock.ogg", "sock.ogg", "vest.ogg", "zipper.ogg"], "b": ["bathing_suit.ogg", "bib.ogg", "button.ogg", "cap.ogg", "pocket.ogg"], "v": ["dress.ogg", "glove.ogg", "raincoat.ogg", "smock.ogg"], "ã": ["button.ogg"]}
    property var counts:{"bathing_suit.ogg": {"f": 1, "a": 2, "t": 1, "o": 2, "d": 1, "e": 1, "b": 1, "n": 1, "h": 1}, "bib.ogg": {"b": 2, "a": 1, "e": 2, "t": 1}, "button.ogg": {"b": 1, "o": 2, "t": 1, "ã": 1}, "cap.ogg": {"b": 1, "o": 1, "n": 1, "é": 1}, "cape.ogg": {"c": 1, "a": 2, "p": 1}, "coat.ogg": {"c": 2, "a": 2, "s": 1, "o": 1}, "dress.ogg": {"v": 1, "e": 1, "s": 1, "t": 1, "i": 1, "d": 1, "o": 1}, "glove.ogg": {"l": 1, "u": 1, "v": 1, "a": 1}, "hat.ogg": {"c": 1, "h": 1, "a": 1, "p": 1, "é": 1, "u": 1}, "heel.ogg": {"s": 1, "a": 1, "l": 1, "t": 1, "o": 1}, "helmet.ogg": {"c": 2, "a": 2, "p": 1, "e": 2, "t": 1}, "jacket.ogg": {"c": 2, "a": 2, "s": 1, "o": 1}, "kimono.ogg": {"q": 1, "u": 1, "i": 1, "m": 1, "o": 2, "n": 1}, "nightgown.ogg": {"c": 1, "a": 2, "m": 2, "i": 2, "s": 1, "d": 2, "e": 1, "o": 1, "r": 2}, "pajamas.ogg": {"p": 1, "i": 1, "j": 1, "a": 2, "m": 1, "s": 1}, "panties.ogg": {"c": 2, "u": 1, "e": 1, "a": 1, "s": 1}, "pants.ogg": {"c": 1, "a": 2, "l": 1, "ç": 1, "s": 1}, "patch.ogg": {"r": 1, "e": 2, "m": 1, "n": 1, "d": 1, "o": 1}, "pocket.ogg": {"b": 1, "o": 2, "l": 1, "s": 1}, "pompon.ogg": {"p": 2, "o": 2, "m": 2}, "pullover.ogg": {"c": 1, "a": 2, "m": 1, "i": 1, "s": 1, "o": 1, "l": 1}, "raincoat.ogg": {"c": 2, "a": 6, "p": 2, "r": 1, "h": 1, "u": 1, "v": 1}, "robe.ogg": {"m": 1, "a": 1, "n": 1, "t": 1, "o": 1}, "sandals.ogg": {"s": 2, "a": 2, "n": 1, "d": 1, "á": 1, "l": 1, "i": 1}, "sash.ogg": {"f": 1, "a": 2, "i": 1, "x": 1}, "scarf.ogg": {"c": 3, "a": 1, "h": 1, "e": 1, "o": 1, "l": 1}, "shirt.ogg": {"c": 1, "a": 2, "m": 1, "i": 1, "s": 1}, "shoe.ogg": {"s": 1, "a": 2, "p": 1, "t": 1, "o": 1}, "shoelace.ogg": {"a": 3, "t": 1, "c": 1, "d": 1, "o": 1, "r": 1}, "short.ogg": {"c": 1, "a": 1, "l": 1, "ç": 1, "õ": 1, "e": 1, "s": 1}, "skirt.ogg": {"s": 1, "a": 2, "i": 1}, "sleeve.ogg": {"m": 1, "a": 2, "n": 1, "g": 1}, "slippers.ogg": {"c": 1, "h": 1, "i": 1, "n": 1, "e": 1, "l": 1, "o": 1, "s": 1}, "smock.ogg": {"a": 2, "v": 1, "e": 1, "n": 1, "t": 1, "l": 1}, "sneaker.ogg": {"s": 2, "a": 3, "p": 1, "t": 1, "i": 1, "l": 1, "h": 1}, "sock.ogg": {"m": 1, "e": 1, "i": 1, "a": 1}, "sole_shoe.ogg": {"s": 1, "o": 1, "l": 1, "a": 1}, "suit.ogg": {"f": 1, "a": 1, "t": 1, "o": 1}, "sweatshirt.ogg": {"c": 2, "a": 5, "m": 1, "i": 1, "s": 1, "o": 1, "l": 1, "r": 1, "d": 2}, "uniform.ogg": {"f": 1, "a": 2, "r": 1, "d": 1}, "vest.ogg": {"c": 1, "o": 1, "l": 1, "e": 2, "t": 1}, "zipper.ogg": {"f": 1, "e": 3, "c": 2, "h": 1, "o": 2, "d": 1, "r": 3}}
    property int lessonIndex:6
    property int configuredMode:5
    property int configuredCase:2
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
