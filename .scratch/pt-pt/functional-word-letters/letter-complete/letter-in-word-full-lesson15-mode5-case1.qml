// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteLetterInWordLessonPT"
    when:activity.visible
    property var expectedWords:{"bay.ogg": "baía", "beach.ogg": "praia", "canyon.ogg": "desfiladeiro", "cave.ogg": "gruta", "cavern.ogg": "caverna", "cliff.ogg": "penhasco", "cloud.ogg": "nuvem", "cloudy.ogg": "nublado", "coast.ogg": "costa", "cold.ogg": "frio", "creek.ogg": "estuário", "crystal.ogg": "cristal", "desert.ogg": "deserto", "diamond.ogg": "diamante", "dirt.ogg": "lama", "drip.ogg": "pingo", "dune.ogg": "duna", "earth.ogg": "terra", "fall_season.ogg": "Outono", "fire.ogg": "fogueira", "flame.ogg": "fogo", "forest.ogg": "floresta", "garden.ogg": "jardim", "gem.ogg": "gema", "ground.ogg": "chão", "heat.ogg": "calor", "hill.ogg": "monte", "hole.ogg": "buraco", "iceberg.ogg": "icebergue", "island.ogg": "ilha", "lake.ogg": "lago", "land.ogg": "terreno", "lava.ogg": "lava", "ledge.ogg": "saliência", "lightning.ogg": "relâmpago", "moon.ogg": "lua", "mountain.ogg": "montanha", "mud.ogg": "lama", "night.ogg": "noite", "ocean.ogg": "oceano", "path.ogg": "caminho", "peak.ogg": "penhasco", "planet.ogg": "planeta", "pond.ogg": "lagoa", "rain.ogg": "chuva", "river.ogg": "rio", "rock.ogg": "rocha", "sand.ogg": "areia", "sea.ogg": "mar", "shadow.ogg": "sombra", "shore.ogg": "costa", "sky.ogg": "céu", "slope.ogg": "encosta", "smoke.ogg": "fumo", "snow.ogg": "neve", "spider_web.ogg": "teia de aranha", "spring_season.ogg": "Primavera", "star.ogg": "estrela", "steam.ogg": "vapor", "stone.ogg": "pedra", "stream.ogg": "ribeiro", "summer.ogg": "Verão", "summit.ogg": "topo", "sun.ogg": "sol", "time.ogg": "tempo", "top.ogg": "topo", "trail.ogg": "caminho", "water.ogg": "água", "wave.ogg": "onda", "wind.ogg": "vento", "winter.ogg": "Inverno", "world.ogg": "mundo", "vapor.ogg": "vapor"}
    property var incidence:{"m": ["cloud.ogg", "diamond.ogg", "dirt.ogg", "garden.ogg", "gem.ogg", "hill.ogg", "lightning.ogg", "mountain.ogg", "mud.ogg", "path.ogg", "sea.ogg", "shadow.ogg", "smoke.ogg", "spring_season.ogg", "time.ogg", "trail.ogg", "world.ogg"], "r": ["beach.ogg", "canyon.ogg", "cave.ogg", "cavern.ogg", "cold.ogg", "creek.ogg", "crystal.ogg", "desert.ogg", "earth.ogg", "fire.ogg", "forest.ogg", "garden.ogg", "heat.ogg", "hole.ogg", "iceberg.ogg", "land.ogg", "lightning.ogg", "river.ogg", "rock.ogg", "sand.ogg", "sea.ogg", "shadow.ogg", "spider_web.ogg", "spring_season.ogg", "star.ogg", "steam.ogg", "stone.ogg", "stream.ogg", "summer.ogg", "winter.ogg", "vapor.ogg"], "u": ["cave.ogg", "cloud.ogg", "cloudy.ogg", "creek.ogg", "dune.ogg", "fall_season.ogg", "fire.ogg", "hole.ogg", "iceberg.ogg", "moon.ogg", "rain.ogg", "sky.ogg", "smoke.ogg", "water.ogg", "world.ogg"], "á": ["creek.ogg", "water.ogg"], "t": ["cave.ogg", "coast.ogg", "creek.ogg", "crystal.ogg", "desert.ogg", "diamond.ogg", "earth.ogg", "fall_season.ogg", "forest.ogg", "hill.ogg", "land.ogg", "mountain.ogg", "night.ogg", "planet.ogg", "shore.ogg", "slope.ogg", "spider_web.ogg", "star.ogg", "summit.ogg", "time.ogg", "top.ogg", "wind.ogg"], "í": ["bay.ogg"], "d": ["canyon.ogg", "cloudy.ogg", "desert.ogg", "diamond.ogg", "dune.ogg", "garden.ogg", "spider_web.ogg", "stone.ogg", "wave.ogg", "world.ogg"], "V": ["summer.ogg"], "i": ["beach.ogg", "canyon.ogg", "cold.ogg", "creek.ogg", "crystal.ogg", "diamond.ogg", "drip.ogg", "fire.ogg", "garden.ogg", "iceberg.ogg", "island.ogg", "ledge.ogg", "night.ogg", "path.ogg", "river.ogg", "sand.ogg", "spider_web.ogg", "spring_season.ogg", "stream.ogg", "trail.ogg"], "â": ["lightning.ogg"], "l": ["canyon.ogg", "cloudy.ogg", "crystal.ogg", "dirt.ogg", "forest.ogg", "heat.ogg", "island.ogg", "lake.ogg", "lava.ogg", "ledge.ogg", "lightning.ogg", "moon.ogg", "mud.ogg", "planet.ogg", "pond.ogg", "star.ogg", "sun.ogg"], "j": ["garden.ogg"], "a": ["bay.ogg", "beach.ogg", "canyon.ogg", "cave.ogg", "cavern.ogg", "cliff.ogg", "cloudy.ogg", "coast.ogg", "crystal.ogg", "diamond.ogg", "dirt.ogg", "dune.ogg", "earth.ogg", "fire.ogg", "forest.ogg", "garden.ogg", "gem.ogg", "heat.ogg", "hole.ogg", "island.ogg", "lake.ogg", "lava.ogg", "ledge.ogg", "lightning.ogg", "moon.ogg", "mountain.ogg", "mud.ogg", "ocean.ogg", "path.ogg", "peak.ogg", "planet.ogg", "pond.ogg", "rain.ogg", "rock.ogg", "sand.ogg", "sea.ogg", "shadow.ogg", "shore.ogg", "slope.ogg", "spider_web.ogg", "spring_season.ogg", "star.ogg", "steam.ogg", "stone.ogg", "trail.ogg", "water.ogg", "wave.ogg", "vapor.ogg"], "O": ["fall_season.ogg"], "p": ["beach.ogg", "cliff.ogg", "drip.ogg", "lightning.ogg", "peak.ogg", "planet.ogg", "steam.ogg", "stone.ogg", "summit.ogg", "time.ogg", "top.ogg", "vapor.ogg"], "h": ["cliff.ogg", "ground.ogg", "island.ogg", "mountain.ogg", "path.ogg", "peak.ogg", "rain.ogg", "rock.ogg", "spider_web.ogg", "trail.ogg"], "I": ["winter.ogg"], "n": ["cavern.ogg", "cliff.ogg", "cloud.ogg", "cloudy.ogg", "diamond.ogg", "drip.ogg", "dune.ogg", "fall_season.ogg", "hill.ogg", "land.ogg", "ledge.ogg", "mountain.ogg", "night.ogg", "ocean.ogg", "path.ogg", "peak.ogg", "planet.ogg", "slope.ogg", "snow.ogg", "spider_web.ogg", "trail.ogg", "wave.ogg", "wind.ogg", "winter.ogg", "world.ogg"], "g": ["cave.ogg", "drip.ogg", "fire.ogg", "flame.ogg", "gem.ogg", "iceberg.ogg", "lake.ogg", "lightning.ogg", "pond.ogg", "water.ogg"], "P": ["spring_season.ogg"], "é": ["sky.ogg"], "s": ["canyon.ogg", "cliff.ogg", "coast.ogg", "creek.ogg", "crystal.ogg", "desert.ogg", "forest.ogg", "ledge.ogg", "peak.ogg", "shadow.ogg", "shore.ogg", "slope.ogg", "star.ogg", "sun.ogg"], "o": ["canyon.ogg", "cliff.ogg", "cloudy.ogg", "coast.ogg", "cold.ogg", "creek.ogg", "desert.ogg", "drip.ogg", "fall_season.ogg", "fire.ogg", "flame.ogg", "forest.ogg", "ground.ogg", "heat.ogg", "hill.ogg", "hole.ogg", "lake.ogg", "land.ogg", "lightning.ogg", "mountain.ogg", "night.ogg", "ocean.ogg", "path.ogg", "peak.ogg", "pond.ogg", "river.ogg", "rock.ogg", "shadow.ogg", "shore.ogg", "slope.ogg", "smoke.ogg", "steam.ogg", "stream.ogg", "summer.ogg", "summit.ogg", "sun.ogg", "time.ogg", "top.ogg", "trail.ogg", "wave.ogg", "wind.ogg", "winter.ogg", "world.ogg", "vapor.ogg"], "c": ["cavern.ogg", "cliff.ogg", "coast.ogg", "crystal.ogg", "ground.ogg", "heat.ogg", "hole.ogg", "iceberg.ogg", "ledge.ogg", "ocean.ogg", "path.ogg", "peak.ogg", "rain.ogg", "rock.ogg", "shore.ogg", "sky.ogg", "slope.ogg", "trail.ogg"], "f": ["canyon.ogg", "cold.ogg", "fire.ogg", "flame.ogg", "forest.ogg", "smoke.ogg"], "e": ["canyon.ogg", "cavern.ogg", "cliff.ogg", "cloud.ogg", "creek.ogg", "desert.ogg", "diamond.ogg", "earth.ogg", "fire.ogg", "forest.ogg", "gem.ogg", "hill.ogg", "iceberg.ogg", "land.ogg", "lightning.ogg", "night.ogg", "ocean.ogg", "peak.ogg", "planet.ogg", "sand.ogg", "slope.ogg", "snow.ogg", "spider_web.ogg", "spring_season.ogg", "star.ogg", "stone.ogg", "stream.ogg", "summer.ogg", "time.ogg", "wind.ogg", "winter.ogg"], "b": ["bay.ogg", "cloudy.ogg", "hole.ogg", "iceberg.ogg", "shadow.ogg", "stream.ogg"], "v": ["cavern.ogg", "cloud.ogg", "lava.ogg", "rain.ogg", "snow.ogg", "spring_season.ogg", "steam.ogg", "wind.ogg", "winter.ogg", "vapor.ogg"], "ã": ["ground.ogg", "summer.ogg"], "ê": ["ledge.ogg"]}
    property var counts:{"bay.ogg": {"b": 1, "a": 2, "í": 1}, "beach.ogg": {"p": 1, "r": 1, "a": 2, "i": 1}, "canyon.ogg": {"d": 2, "e": 2, "s": 1, "f": 1, "i": 2, "l": 1, "a": 1, "r": 1, "o": 1}, "cave.ogg": {"g": 1, "r": 1, "u": 1, "t": 1, "a": 1}, "cavern.ogg": {"c": 1, "a": 2, "v": 1, "e": 1, "r": 1, "n": 1}, "cliff.ogg": {"p": 1, "e": 1, "n": 1, "h": 1, "a": 1, "s": 1, "c": 1, "o": 1}, "cloud.ogg": {"n": 1, "u": 1, "v": 1, "e": 1, "m": 1}, "cloudy.ogg": {"n": 1, "u": 1, "b": 1, "l": 1, "a": 1, "d": 1, "o": 1}, "coast.ogg": {"c": 1, "o": 1, "s": 1, "t": 1, "a": 1}, "cold.ogg": {"f": 1, "r": 1, "i": 1, "o": 1}, "creek.ogg": {"e": 1, "s": 1, "t": 1, "u": 1, "á": 1, "r": 1, "i": 1, "o": 1}, "crystal.ogg": {"c": 1, "r": 1, "i": 1, "s": 1, "t": 1, "a": 1, "l": 1}, "desert.ogg": {"d": 1, "e": 2, "s": 1, "r": 1, "t": 1, "o": 1}, "diamond.ogg": {"d": 1, "i": 1, "a": 2, "m": 1, "n": 1, "t": 1, "e": 1}, "dirt.ogg": {"l": 1, "a": 2, "m": 1}, "drip.ogg": {"p": 1, "i": 1, "n": 1, "g": 1, "o": 1}, "dune.ogg": {"d": 1, "u": 1, "n": 1, "a": 1}, "earth.ogg": {"t": 1, "e": 1, "r": 2, "a": 1}, "fall_season.ogg": {"O": 1, "u": 1, "t": 1, "o": 2, "n": 1}, "fire.ogg": {"f": 1, "o": 1, "g": 1, "u": 1, "e": 1, "i": 1, "r": 1, "a": 1}, "flame.ogg": {"f": 1, "o": 2, "g": 1}, "forest.ogg": {"f": 1, "l": 1, "o": 1, "r": 1, "e": 1, "s": 1, "t": 1, "a": 1}, "garden.ogg": {"j": 1, "a": 1, "r": 1, "d": 1, "i": 1, "m": 1}, "gem.ogg": {"g": 1, "e": 1, "m": 1, "a": 1}, "ground.ogg": {"c": 1, "h": 1, "ã": 1, "o": 1}, "heat.ogg": {"c": 1, "a": 1, "l": 1, "o": 1, "r": 1}, "hill.ogg": {"m": 1, "o": 1, "n": 1, "t": 1, "e": 1}, "hole.ogg": {"b": 1, "u": 1, "r": 1, "a": 1, "c": 1, "o": 1}, "iceberg.ogg": {"i": 1, "c": 1, "e": 3, "b": 1, "r": 1, "g": 1, "u": 1}, "island.ogg": {"i": 1, "l": 1, "h": 1, "a": 1}, "lake.ogg": {"l": 1, "a": 1, "g": 1, "o": 1}, "land.ogg": {"t": 1, "e": 2, "r": 2, "n": 1, "o": 1}, "lava.ogg": {"l": 1, "a": 2, "v": 1}, "ledge.ogg": {"s": 1, "a": 2, "l": 1, "i": 2, "ê": 1, "n": 1, "c": 1}, "lightning.ogg": {"r": 1, "e": 1, "l": 1, "â": 1, "m": 1, "p": 1, "a": 1, "g": 1, "o": 1}, "moon.ogg": {"l": 1, "u": 1, "a": 1}, "mountain.ogg": {"m": 1, "o": 1, "n": 2, "t": 1, "a": 2, "h": 1}, "mud.ogg": {"l": 1, "a": 2, "m": 1}, "night.ogg": {"n": 1, "o": 1, "i": 1, "t": 1, "e": 1}, "ocean.ogg": {"o": 2, "c": 1, "e": 1, "a": 1, "n": 1}, "path.ogg": {"c": 1, "a": 1, "m": 1, "i": 1, "n": 1, "h": 1, "o": 1}, "peak.ogg": {"p": 1, "e": 1, "n": 1, "h": 1, "a": 1, "s": 1, "c": 1, "o": 1}, "planet.ogg": {"p": 1, "l": 1, "a": 2, "n": 1, "e": 1, "t": 1}, "pond.ogg": {"l": 1, "a": 2, "g": 1, "o": 1}, "rain.ogg": {"c": 1, "h": 1, "u": 1, "v": 1, "a": 1}, "river.ogg": {"r": 1, "i": 1, "o": 1}, "rock.ogg": {"r": 1, "o": 1, "c": 1, "h": 1, "a": 1}, "sand.ogg": {"a": 2, "r": 1, "e": 1, "i": 1}, "sea.ogg": {"m": 1, "a": 1, "r": 1}, "shadow.ogg": {"s": 1, "o": 1, "m": 1, "b": 1, "r": 1, "a": 1}, "shore.ogg": {"c": 1, "o": 1, "s": 1, "t": 1, "a": 1}, "sky.ogg": {"c": 1, "é": 1, "u": 1}, "slope.ogg": {"e": 1, "n": 1, "c": 1, "o": 1, "s": 1, "t": 1, "a": 1}, "smoke.ogg": {"f": 1, "u": 1, "m": 1, "o": 1}, "snow.ogg": {"n": 1, "e": 2, "v": 1}, "spider_web.ogg": {"t": 1, "e": 2, "i": 1, "a": 4, "d": 1, "r": 1, "n": 1, "h": 1}, "spring_season.ogg": {"P": 1, "r": 2, "i": 1, "m": 1, "a": 2, "v": 1, "e": 1}, "star.ogg": {"e": 2, "s": 1, "t": 1, "r": 1, "l": 1, "a": 1}, "steam.ogg": {"v": 1, "a": 1, "p": 1, "o": 1, "r": 1}, "stone.ogg": {"p": 1, "e": 1, "d": 1, "r": 1, "a": 1}, "stream.ogg": {"r": 2, "i": 2, "b": 1, "e": 1, "o": 1}, "summer.ogg": {"V": 1, "e": 1, "r": 1, "ã": 1, "o": 1}, "summit.ogg": {"t": 1, "o": 2, "p": 1}, "sun.ogg": {"s": 1, "o": 1, "l": 1}, "time.ogg": {"t": 1, "e": 1, "m": 1, "p": 1, "o": 1}, "top.ogg": {"t": 1, "o": 2, "p": 1}, "trail.ogg": {"c": 1, "a": 1, "m": 1, "i": 1, "n": 1, "h": 1, "o": 1}, "water.ogg": {"á": 1, "g": 1, "u": 1, "a": 1}, "wave.ogg": {"o": 1, "n": 1, "d": 1, "a": 1}, "wind.ogg": {"v": 1, "e": 1, "n": 1, "t": 1, "o": 1}, "winter.ogg": {"I": 1, "n": 2, "v": 1, "e": 1, "r": 1, "o": 1}, "world.ogg": {"m": 1, "u": 1, "n": 1, "d": 1, "o": 1}, "vapor.ogg": {"v": 1, "a": 1, "p": 1, "o": 1, "r": 1}}
    property int lessonIndex:14
    property int configuredMode:5
    property int configuredCase:1
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
