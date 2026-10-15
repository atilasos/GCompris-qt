// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteLetterInWordLessonPT"
    when:activity.visible
    property var expectedWords:{"bank.ogg": "banco", "barn.ogg": "celeiro", "bedroom.ogg": "quarto", "big_top.ogg": "tenda de circo", "bridge.ogg": "ponte", "cabin.ogg": "cabana", "cage.ogg": "jaula", "castle.ogg": "castelo", "chimney.ogg": "chaminé", "circus.ogg": "circo", "city.ogg": "cidade", "dam.ogg": "barragem", "door.ogg": "porta", "fair.ogg": "feira", "farm.ogg": "quinta", "fountain.ogg": "fonte", "garage.ogg": "garagem", "grave.ogg": "sepultura", "home.ogg": "lar", "hospital.ogg": "hospital", "house.ogg": "casa", "hut.ogg": "cabana", "kitchen.ogg": "cozinha", "lane.ogg": "estrada", "lighthouse.ogg": "farol", "merry-go-round.ogg": "carrossel", "mill.ogg": "moinho", "mosque.ogg": "mesquita", "office.ogg": "escritório", "pool.ogg": "piscina", "post.ogg": "marco de correio", "prison.ogg": "prisão", "pyramid.ogg": "pirâmide", "ramp.ogg": "rampa", "road.ogg": "estrada", "roof.ogg": "telhado", "room.ogg": "assoalhada", "school.ogg": "escola", "shed.ogg": "abrigo", "shop.ogg": "loja", "shutter.ogg": "persiana", "sidewalk.ogg": "passeio", "stage.ogg": "palco", "staircase.ogg": "escadaria", "steeple.ogg": "campanário", "step.ogg": "degrau", "store.ogg": "loja", "street.ogg": "rua", "temple.ogg": "templo", "tent.ogg": "tenda", "train_station.ogg": "estação de comboio", "wall.ogg": "parede", "window.ogg": "janela", "window_glass.ogg": "vidro da janela", "zoo.ogg": "jardim zoológico", "class.ogg": "aula"}
    property var incidence:{"m": ["chimney.ogg", "dam.ogg", "garage.ogg", "mill.ogg", "mosque.ogg", "post.ogg", "pyramid.ogg", "ramp.ogg", "steeple.ogg", "temple.ogg", "train_station.ogg", "zoo.ogg"], "r": ["barn.ogg", "bedroom.ogg", "big_top.ogg", "circus.ogg", "dam.ogg", "door.ogg", "fair.ogg", "garage.ogg", "grave.ogg", "home.ogg", "lane.ogg", "lighthouse.ogg", "merry-go-round.ogg", "office.ogg", "post.ogg", "prison.ogg", "pyramid.ogg", "ramp.ogg", "road.ogg", "shed.ogg", "shutter.ogg", "staircase.ogg", "steeple.ogg", "step.ogg", "street.ogg", "wall.ogg", "window_glass.ogg", "zoo.ogg"], "u": ["bedroom.ogg", "cage.ogg", "farm.ogg", "grave.ogg", "mosque.ogg", "step.ogg", "street.ogg", "class.ogg"], "q": ["bedroom.ogg", "farm.ogg", "mosque.ogg"], "á": ["steeple.ogg"], "t": ["bedroom.ogg", "big_top.ogg", "bridge.ogg", "castle.ogg", "door.ogg", "farm.ogg", "fountain.ogg", "grave.ogg", "hospital.ogg", "lane.ogg", "mosque.ogg", "office.ogg", "road.ogg", "roof.ogg", "temple.ogg", "tent.ogg", "train_station.ogg"], "d": ["big_top.ogg", "city.ogg", "lane.ogg", "post.ogg", "pyramid.ogg", "road.ogg", "roof.ogg", "room.ogg", "staircase.ogg", "step.ogg", "tent.ogg", "train_station.ogg", "wall.ogg", "window_glass.ogg", "zoo.ogg"], "i": ["barn.ogg", "big_top.ogg", "chimney.ogg", "circus.ogg", "city.ogg", "fair.ogg", "farm.ogg", "hospital.ogg", "kitchen.ogg", "mill.ogg", "mosque.ogg", "office.ogg", "pool.ogg", "post.ogg", "prison.ogg", "pyramid.ogg", "shed.ogg", "shutter.ogg", "sidewalk.ogg", "staircase.ogg", "steeple.ogg", "train_station.ogg", "window_glass.ogg", "zoo.ogg"], "â": ["pyramid.ogg"], "ç": ["train_station.ogg"], "j": ["cage.ogg", "shop.ogg", "store.ogg", "window.ogg", "window_glass.ogg", "zoo.ogg"], "l": ["barn.ogg", "cage.ogg", "castle.ogg", "grave.ogg", "home.ogg", "hospital.ogg", "lighthouse.ogg", "merry-go-round.ogg", "roof.ogg", "room.ogg", "school.ogg", "shop.ogg", "stage.ogg", "store.ogg", "temple.ogg", "window.ogg", "window_glass.ogg", "zoo.ogg", "class.ogg"], "a": ["bank.ogg", "bedroom.ogg", "big_top.ogg", "cabin.ogg", "cage.ogg", "castle.ogg", "chimney.ogg", "city.ogg", "dam.ogg", "door.ogg", "fair.ogg", "farm.ogg", "garage.ogg", "grave.ogg", "home.ogg", "hospital.ogg", "house.ogg", "hut.ogg", "kitchen.ogg", "lane.ogg", "lighthouse.ogg", "merry-go-round.ogg", "mosque.ogg", "pool.ogg", "post.ogg", "ramp.ogg", "road.ogg", "roof.ogg", "room.ogg", "school.ogg", "shed.ogg", "shop.ogg", "shutter.ogg", "sidewalk.ogg", "stage.ogg", "staircase.ogg", "steeple.ogg", "step.ogg", "store.ogg", "street.ogg", "tent.ogg", "train_station.ogg", "wall.ogg", "window.ogg", "window_glass.ogg", "zoo.ogg", "class.ogg"], "p": ["bridge.ogg", "door.ogg", "grave.ogg", "hospital.ogg", "pool.ogg", "prison.ogg", "pyramid.ogg", "ramp.ogg", "shutter.ogg", "sidewalk.ogg", "stage.ogg", "steeple.ogg", "temple.ogg", "wall.ogg"], "h": ["chimney.ogg", "hospital.ogg", "kitchen.ogg", "mill.ogg", "roof.ogg", "room.ogg"], "n": ["bank.ogg", "big_top.ogg", "bridge.ogg", "cabin.ogg", "chimney.ogg", "farm.ogg", "fountain.ogg", "hut.ogg", "kitchen.ogg", "mill.ogg", "pool.ogg", "shutter.ogg", "steeple.ogg", "tent.ogg", "window.ogg", "window_glass.ogg"], "g": ["dam.ogg", "garage.ogg", "shed.ogg", "step.ogg", "zoo.ogg"], "z": ["kitchen.ogg", "zoo.ogg"], "é": ["chimney.ogg"], "s": ["castle.ogg", "grave.ogg", "hospital.ogg", "house.ogg", "lane.ogg", "merry-go-round.ogg", "mosque.ogg", "office.ogg", "pool.ogg", "prison.ogg", "road.ogg", "room.ogg", "school.ogg", "shutter.ogg", "sidewalk.ogg", "staircase.ogg", "train_station.ogg"], "o": ["bank.ogg", "barn.ogg", "bedroom.ogg", "big_top.ogg", "bridge.ogg", "castle.ogg", "circus.ogg", "door.ogg", "fountain.ogg", "hospital.ogg", "kitchen.ogg", "lighthouse.ogg", "merry-go-round.ogg", "mill.ogg", "office.ogg", "post.ogg", "prison.ogg", "roof.ogg", "room.ogg", "school.ogg", "shed.ogg", "shop.ogg", "sidewalk.ogg", "stage.ogg", "steeple.ogg", "store.ogg", "temple.ogg", "train_station.ogg", "window_glass.ogg", "zoo.ogg"], "c": ["bank.ogg", "barn.ogg", "big_top.ogg", "cabin.ogg", "castle.ogg", "chimney.ogg", "circus.ogg", "city.ogg", "house.ogg", "hut.ogg", "kitchen.ogg", "merry-go-round.ogg", "office.ogg", "pool.ogg", "post.ogg", "school.ogg", "stage.ogg", "staircase.ogg", "steeple.ogg", "train_station.ogg", "zoo.ogg"], "f": ["fair.ogg", "fountain.ogg", "lighthouse.ogg"], "e": ["barn.ogg", "big_top.ogg", "bridge.ogg", "castle.ogg", "city.ogg", "dam.ogg", "fair.ogg", "fountain.ogg", "garage.ogg", "grave.ogg", "lane.ogg", "merry-go-round.ogg", "mosque.ogg", "office.ogg", "post.ogg", "pyramid.ogg", "road.ogg", "roof.ogg", "school.ogg", "shutter.ogg", "sidewalk.ogg", "staircase.ogg", "step.ogg", "temple.ogg", "tent.ogg", "train_station.ogg", "wall.ogg", "window.ogg", "window_glass.ogg"], "b": ["bank.ogg", "cabin.ogg", "dam.ogg", "hut.ogg", "shed.ogg", "train_station.ogg"], "v": ["window_glass.ogg"], "ã": ["prison.ogg", "train_station.ogg"], "ó": ["office.ogg", "zoo.ogg"]}
    property var counts:{"bank.ogg": {"b": 1, "a": 1, "n": 1, "c": 1, "o": 1}, "barn.ogg": {"c": 1, "e": 2, "l": 1, "i": 1, "r": 1, "o": 1}, "bedroom.ogg": {"q": 1, "u": 1, "a": 1, "r": 1, "t": 1, "o": 1}, "big_top.ogg": {"t": 1, "e": 2, "n": 1, "d": 2, "a": 1, "c": 2, "i": 1, "r": 1, "o": 1}, "bridge.ogg": {"p": 1, "o": 1, "n": 1, "t": 1, "e": 1}, "cabin.ogg": {"c": 1, "a": 3, "b": 1, "n": 1}, "cage.ogg": {"j": 1, "a": 2, "u": 1, "l": 1}, "castle.ogg": {"c": 1, "a": 1, "s": 1, "t": 1, "e": 1, "l": 1, "o": 1}, "chimney.ogg": {"c": 1, "h": 1, "a": 1, "m": 1, "i": 1, "n": 1, "é": 1}, "circus.ogg": {"c": 2, "i": 1, "r": 1, "o": 1}, "city.ogg": {"c": 1, "i": 1, "d": 2, "a": 1, "e": 1}, "dam.ogg": {"b": 1, "a": 2, "r": 2, "g": 1, "e": 1, "m": 1}, "door.ogg": {"p": 1, "o": 1, "r": 1, "t": 1, "a": 1}, "fair.ogg": {"f": 1, "e": 1, "i": 1, "r": 1, "a": 1}, "farm.ogg": {"q": 1, "u": 1, "i": 1, "n": 1, "t": 1, "a": 1}, "fountain.ogg": {"f": 1, "o": 1, "n": 1, "t": 1, "e": 1}, "garage.ogg": {"g": 2, "a": 2, "r": 1, "e": 1, "m": 1}, "grave.ogg": {"s": 1, "e": 1, "p": 1, "u": 2, "l": 1, "t": 1, "r": 1, "a": 1}, "home.ogg": {"l": 1, "a": 1, "r": 1}, "hospital.ogg": {"h": 1, "o": 1, "s": 1, "p": 1, "i": 1, "t": 1, "a": 1, "l": 1}, "house.ogg": {"c": 1, "a": 2, "s": 1}, "hut.ogg": {"c": 1, "a": 3, "b": 1, "n": 1}, "kitchen.ogg": {"c": 1, "o": 1, "z": 1, "i": 1, "n": 1, "h": 1, "a": 1}, "lane.ogg": {"e": 1, "s": 1, "t": 1, "r": 1, "a": 2, "d": 1}, "lighthouse.ogg": {"f": 1, "a": 1, "r": 1, "o": 1, "l": 1}, "merry-go-round.ogg": {"c": 1, "a": 1, "r": 2, "o": 1, "s": 2, "e": 1, "l": 1}, "mill.ogg": {"m": 1, "o": 2, "i": 1, "n": 1, "h": 1}, "mosque.ogg": {"m": 1, "e": 1, "s": 1, "q": 1, "u": 1, "i": 1, "t": 1, "a": 1}, "office.ogg": {"e": 1, "s": 1, "c": 1, "r": 2, "i": 2, "t": 1, "ó": 1, "o": 1}, "pool.ogg": {"p": 1, "i": 2, "s": 1, "c": 1, "n": 1, "a": 1}, "post.ogg": {"m": 1, "a": 1, "r": 3, "c": 2, "o": 3, "d": 1, "e": 2, "i": 1}, "prison.ogg": {"p": 1, "r": 1, "i": 1, "s": 1, "ã": 1, "o": 1}, "pyramid.ogg": {"p": 1, "i": 2, "r": 1, "â": 1, "m": 1, "d": 1, "e": 1}, "ramp.ogg": {"r": 1, "a": 2, "m": 1, "p": 1}, "road.ogg": {"e": 1, "s": 1, "t": 1, "r": 1, "a": 2, "d": 1}, "roof.ogg": {"t": 1, "e": 1, "l": 1, "h": 1, "a": 1, "d": 1, "o": 1}, "room.ogg": {"a": 4, "s": 2, "o": 1, "l": 1, "h": 1, "d": 1}, "school.ogg": {"e": 1, "s": 1, "c": 1, "o": 1, "l": 1, "a": 1}, "shed.ogg": {"a": 1, "b": 1, "r": 1, "i": 1, "g": 1, "o": 1}, "shop.ogg": {"l": 1, "o": 1, "j": 1, "a": 1}, "shutter.ogg": {"p": 1, "e": 1, "r": 1, "s": 1, "i": 1, "a": 2, "n": 1}, "sidewalk.ogg": {"p": 1, "a": 1, "s": 2, "e": 1, "i": 1, "o": 1}, "stage.ogg": {"p": 1, "a": 1, "l": 1, "c": 1, "o": 1}, "staircase.ogg": {"e": 1, "s": 1, "c": 1, "a": 3, "d": 1, "r": 1, "i": 1}, "steeple.ogg": {"c": 1, "a": 2, "m": 1, "p": 1, "n": 1, "á": 1, "r": 1, "i": 1, "o": 1}, "step.ogg": {"d": 1, "e": 1, "g": 1, "r": 1, "a": 1, "u": 1}, "store.ogg": {"l": 1, "o": 1, "j": 1, "a": 1}, "street.ogg": {"r": 1, "u": 1, "a": 1}, "temple.ogg": {"t": 1, "e": 1, "m": 1, "p": 1, "l": 1, "o": 1}, "tent.ogg": {"t": 1, "e": 1, "n": 1, "d": 1, "a": 1}, "train_station.ogg": {"e": 2, "s": 1, "t": 1, "a": 1, "ç": 1, "ã": 1, "o": 4, "d": 1, "c": 1, "m": 1, "b": 1, "i": 1}, "wall.ogg": {"p": 1, "a": 1, "r": 1, "e": 2, "d": 1}, "window.ogg": {"j": 1, "a": 2, "n": 1, "e": 1, "l": 1}, "window_glass.ogg": {"v": 1, "i": 1, "d": 2, "r": 1, "o": 1, "a": 3, "j": 1, "n": 1, "e": 1, "l": 1}, "zoo.ogg": {"j": 1, "a": 1, "r": 1, "d": 1, "i": 2, "m": 1, "z": 1, "o": 3, "l": 1, "ó": 1, "g": 1, "c": 1}, "class.ogg": {"a": 2, "u": 1, "l": 1}}
    property int lessonIndex:17
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
