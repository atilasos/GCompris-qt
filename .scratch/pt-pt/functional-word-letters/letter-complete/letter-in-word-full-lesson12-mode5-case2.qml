// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteLetterInWordLessonPT"
    when:activity.visible
    property var expectedWords:{"bread.ogg": "pão", "bun.ogg": "pão de forma", "butter.ogg": "manteiga", "cake.ogg": "bolo", "candy.ogg": "rebuçado", "cereal.ogg": "cereal", "cheese.ogg": "queijo", "chocolate.ogg": "chocolate", "coffee.ogg": "café", "cookie.ogg": "bolacha", "crepe.ogg": "crepe", "crumb.ogg": "migalha", "crust.ogg": "crosta", "dessert.ogg": "sobremesa", "doughnut.ogg": "donut", "drink.ogg": "bebida", "egg.ogg": "ovo", "feast.ogg": "festa", "flour.ogg": "farinha", "fries.ogg": "batatas fritas", "fudge.ogg": "caramelo", "gum.ogg": "pastilha elástica", "ham.ogg": "presunto", "hamburger.ogg": "hambúrguer", "hot_dog.ogg": "cachorro-quente", "ice.ogg": "gelo", "jam.ogg": "compota", "jelly.ogg": "gelatina", "juice.ogg": "sumo", "lemonade.ogg": "limonada", "lunch.ogg": "almoço", "mashed_potatoes.ogg": "puré de batata", "meal.ogg": "refeição", "meat.ogg": "carne", "milk.ogg": "leite", "pepper.ogg": "pimenta", "pie.ogg": "tarte", "pizza.ogg": "pizza", "popcorn.ogg": "pipocas", "rice.ogg": "arroz", "roast.ogg": "assado", "sandwich.ogg": "sanduíche", "sauce.ogg": "molho", "sausage.ogg": "salsicha", "snack.ogg": "lanche", "soup.ogg": "sopa", "spaghetti.ogg": "esparguete", "spice.ogg": "especiarias", "sprinkle.ogg": "pepitas", "stew.ogg": "guisado", "sugar.ogg": "açúcar", "treat.ogg": "guloseima", "yogurt.ogg": "iogurte"}
    property var incidence:{"m": ["bun.ogg", "butter.ogg", "crumb.ogg", "dessert.ogg", "fudge.ogg", "hamburger.ogg", "jam.ogg", "juice.ogg", "lemonade.ogg", "lunch.ogg", "pepper.ogg", "sauce.ogg", "treat.ogg"], "r": ["bun.ogg", "candy.ogg", "cereal.ogg", "crepe.ogg", "crust.ogg", "dessert.ogg", "flour.ogg", "fries.ogg", "fudge.ogg", "ham.ogg", "hamburger.ogg", "hot_dog.ogg", "mashed_potatoes.ogg", "meal.ogg", "meat.ogg", "pie.ogg", "rice.ogg", "spaghetti.ogg", "spice.ogg", "sugar.ogg", "yogurt.ogg"], "u": ["candy.ogg", "cheese.ogg", "doughnut.ogg", "ham.ogg", "hamburger.ogg", "hot_dog.ogg", "juice.ogg", "mashed_potatoes.ogg", "sandwich.ogg", "spaghetti.ogg", "stew.ogg", "treat.ogg", "yogurt.ogg"], "q": ["cheese.ogg", "hot_dog.ogg"], "-": ["hot_dog.ogg"], "á": ["gum.ogg"], "t": ["butter.ogg", "chocolate.ogg", "crust.ogg", "doughnut.ogg", "feast.ogg", "fries.ogg", "gum.ogg", "ham.ogg", "hot_dog.ogg", "jam.ogg", "jelly.ogg", "mashed_potatoes.ogg", "milk.ogg", "pepper.ogg", "pie.ogg", "spaghetti.ogg", "sprinkle.ogg", "yogurt.ogg"], "í": ["sandwich.ogg"], "d": ["bun.ogg", "candy.ogg", "doughnut.ogg", "drink.ogg", "lemonade.ogg", "mashed_potatoes.ogg", "roast.ogg", "sandwich.ogg", "stew.ogg"], "i": ["butter.ogg", "cheese.ogg", "crumb.ogg", "drink.ogg", "flour.ogg", "fries.ogg", "gum.ogg", "jelly.ogg", "lemonade.ogg", "meal.ogg", "milk.ogg", "pepper.ogg", "pizza.ogg", "popcorn.ogg", "sausage.ogg", "spice.ogg", "sprinkle.ogg", "stew.ogg", "treat.ogg", "yogurt.ogg"], "ç": ["candy.ogg", "lunch.ogg", "meal.ogg", "sugar.ogg"], "l": ["cake.ogg", "cereal.ogg", "chocolate.ogg", "cookie.ogg", "crumb.ogg", "fudge.ogg", "gum.ogg", "ice.ogg", "jelly.ogg", "lemonade.ogg", "lunch.ogg", "milk.ogg", "sauce.ogg", "sausage.ogg", "snack.ogg", "treat.ogg"], "j": ["cheese.ogg"], "ú": ["hamburger.ogg", "sugar.ogg"], "a": ["bun.ogg", "butter.ogg", "candy.ogg", "cereal.ogg", "chocolate.ogg", "coffee.ogg", "cookie.ogg", "crumb.ogg", "crust.ogg", "dessert.ogg", "drink.ogg", "feast.ogg", "flour.ogg", "fries.ogg", "fudge.ogg", "gum.ogg", "hamburger.ogg", "hot_dog.ogg", "jam.ogg", "jelly.ogg", "lemonade.ogg", "lunch.ogg", "mashed_potatoes.ogg", "meat.ogg", "pepper.ogg", "pie.ogg", "pizza.ogg", "popcorn.ogg", "rice.ogg", "roast.ogg", "sandwich.ogg", "sausage.ogg", "snack.ogg", "soup.ogg", "spaghetti.ogg", "spice.ogg", "sprinkle.ogg", "stew.ogg", "sugar.ogg", "treat.ogg"], "p": ["bread.ogg", "bun.ogg", "crepe.ogg", "gum.ogg", "ham.ogg", "jam.ogg", "mashed_potatoes.ogg", "pepper.ogg", "pizza.ogg", "popcorn.ogg", "soup.ogg", "spaghetti.ogg", "spice.ogg", "sprinkle.ogg"], "h": ["chocolate.ogg", "cookie.ogg", "crumb.ogg", "flour.ogg", "gum.ogg", "hamburger.ogg", "hot_dog.ogg", "sandwich.ogg", "sauce.ogg", "sausage.ogg", "snack.ogg"], "n": ["butter.ogg", "doughnut.ogg", "flour.ogg", "ham.ogg", "hot_dog.ogg", "jelly.ogg", "lemonade.ogg", "meat.ogg", "pepper.ogg", "sandwich.ogg", "snack.ogg"], "g": ["butter.ogg", "crumb.ogg", "hamburger.ogg", "ice.ogg", "jelly.ogg", "spaghetti.ogg", "stew.ogg", "treat.ogg", "yogurt.ogg"], "z": ["pizza.ogg", "rice.ogg"], "é": ["coffee.ogg", "mashed_potatoes.ogg"], "s": ["crust.ogg", "dessert.ogg", "feast.ogg", "fries.ogg", "gum.ogg", "ham.ogg", "juice.ogg", "popcorn.ogg", "roast.ogg", "sandwich.ogg", "sausage.ogg", "soup.ogg", "spaghetti.ogg", "spice.ogg", "sprinkle.ogg", "stew.ogg", "treat.ogg"], "o": ["bread.ogg", "bun.ogg", "cake.ogg", "candy.ogg", "cheese.ogg", "chocolate.ogg", "cookie.ogg", "crust.ogg", "dessert.ogg", "doughnut.ogg", "egg.ogg", "fudge.ogg", "ham.ogg", "hot_dog.ogg", "ice.ogg", "jam.ogg", "juice.ogg", "lemonade.ogg", "lunch.ogg", "meal.ogg", "popcorn.ogg", "rice.ogg", "roast.ogg", "sauce.ogg", "soup.ogg", "stew.ogg", "treat.ogg", "yogurt.ogg"], "c": ["cereal.ogg", "chocolate.ogg", "coffee.ogg", "cookie.ogg", "crepe.ogg", "crust.ogg", "fudge.ogg", "gum.ogg", "hot_dog.ogg", "jam.ogg", "meat.ogg", "popcorn.ogg", "sandwich.ogg", "sausage.ogg", "snack.ogg", "spice.ogg", "sugar.ogg"], "f": ["bun.ogg", "coffee.ogg", "feast.ogg", "flour.ogg", "fries.ogg", "meal.ogg"], "e": ["bun.ogg", "butter.ogg", "candy.ogg", "cereal.ogg", "cheese.ogg", "chocolate.ogg", "crepe.ogg", "dessert.ogg", "drink.ogg", "feast.ogg", "fudge.ogg", "gum.ogg", "ham.ogg", "hamburger.ogg", "hot_dog.ogg", "ice.ogg", "jelly.ogg", "mashed_potatoes.ogg", "meal.ogg", "meat.ogg", "milk.ogg", "pepper.ogg", "pie.ogg", "sandwich.ogg", "snack.ogg", "spaghetti.ogg", "spice.ogg", "sprinkle.ogg", "treat.ogg", "yogurt.ogg"], "b": ["cake.ogg", "candy.ogg", "cookie.ogg", "dessert.ogg", "drink.ogg", "fries.ogg", "hamburger.ogg", "mashed_potatoes.ogg"], "v": ["egg.ogg"], "ã": ["bread.ogg", "bun.ogg", "meal.ogg"]}
    property var counts:{"bread.ogg": {"p": 1, "ã": 1, "o": 1}, "bun.ogg": {"p": 1, "ã": 1, "o": 2, "d": 1, "e": 1, "f": 1, "r": 1, "m": 1, "a": 1}, "butter.ogg": {"m": 1, "a": 2, "n": 1, "t": 1, "e": 1, "i": 1, "g": 1}, "cake.ogg": {"b": 1, "o": 2, "l": 1}, "candy.ogg": {"r": 1, "e": 1, "b": 1, "u": 1, "ç": 1, "a": 1, "d": 1, "o": 1}, "cereal.ogg": {"c": 1, "e": 2, "r": 1, "a": 1, "l": 1}, "cheese.ogg": {"q": 1, "u": 1, "e": 1, "i": 1, "j": 1, "o": 1}, "chocolate.ogg": {"c": 2, "h": 1, "o": 2, "l": 1, "a": 1, "t": 1, "e": 1}, "coffee.ogg": {"c": 1, "a": 1, "f": 1, "é": 1}, "cookie.ogg": {"b": 1, "o": 1, "l": 1, "a": 2, "c": 1, "h": 1}, "crepe.ogg": {"c": 1, "r": 1, "e": 2, "p": 1}, "crumb.ogg": {"m": 1, "i": 1, "g": 1, "a": 2, "l": 1, "h": 1}, "crust.ogg": {"c": 1, "r": 1, "o": 1, "s": 1, "t": 1, "a": 1}, "dessert.ogg": {"s": 2, "o": 1, "b": 1, "r": 1, "e": 2, "m": 1, "a": 1}, "doughnut.ogg": {"d": 1, "o": 1, "n": 1, "u": 1, "t": 1}, "drink.ogg": {"b": 2, "e": 1, "i": 1, "d": 1, "a": 1}, "egg.ogg": {"o": 2, "v": 1}, "feast.ogg": {"f": 1, "e": 1, "s": 1, "t": 1, "a": 1}, "flour.ogg": {"f": 1, "a": 2, "r": 1, "i": 1, "n": 1, "h": 1}, "fries.ogg": {"b": 1, "a": 4, "t": 3, "s": 2, "f": 1, "r": 1, "i": 1}, "fudge.ogg": {"c": 1, "a": 2, "r": 1, "m": 1, "e": 1, "l": 1, "o": 1}, "gum.ogg": {"p": 1, "a": 3, "s": 2, "t": 2, "i": 2, "l": 2, "h": 1, "e": 1, "á": 1, "c": 1}, "ham.ogg": {"p": 1, "r": 1, "e": 1, "s": 1, "u": 1, "n": 1, "t": 1, "o": 1}, "hamburger.ogg": {"h": 1, "a": 1, "m": 1, "b": 1, "ú": 1, "r": 2, "g": 1, "u": 1, "e": 1}, "hot_dog.ogg": {"c": 2, "a": 1, "h": 1, "o": 2, "r": 2, "-": 1, "q": 1, "u": 1, "e": 2, "n": 1, "t": 1}, "ice.ogg": {"g": 1, "e": 1, "l": 1, "o": 1}, "jam.ogg": {"c": 1, "o": 2, "m": 1, "p": 1, "t": 1, "a": 1}, "jelly.ogg": {"g": 1, "e": 1, "l": 1, "a": 2, "t": 1, "i": 1, "n": 1}, "juice.ogg": {"s": 1, "u": 1, "m": 1, "o": 1}, "lemonade.ogg": {"l": 1, "i": 1, "m": 1, "o": 1, "n": 1, "a": 2, "d": 1}, "lunch.ogg": {"a": 1, "l": 1, "m": 1, "o": 2, "ç": 1}, "mashed_potatoes.ogg": {"p": 1, "u": 1, "r": 1, "é": 1, "d": 1, "e": 1, "b": 1, "a": 3, "t": 2}, "meal.ogg": {"r": 1, "e": 2, "f": 1, "i": 1, "ç": 1, "ã": 1, "o": 1}, "meat.ogg": {"c": 1, "a": 1, "r": 1, "n": 1, "e": 1}, "milk.ogg": {"l": 1, "e": 2, "i": 1, "t": 1}, "pepper.ogg": {"p": 1, "i": 1, "m": 1, "e": 1, "n": 1, "t": 1, "a": 1}, "pie.ogg": {"t": 2, "a": 1, "r": 1, "e": 1}, "pizza.ogg": {"p": 1, "i": 1, "z": 2, "a": 1}, "popcorn.ogg": {"p": 2, "i": 1, "o": 1, "c": 1, "a": 1, "s": 1}, "rice.ogg": {"a": 1, "r": 2, "o": 1, "z": 1}, "roast.ogg": {"a": 2, "s": 2, "d": 1, "o": 1}, "sandwich.ogg": {"s": 1, "a": 1, "n": 1, "d": 1, "u": 1, "í": 1, "c": 1, "h": 1, "e": 1}, "sauce.ogg": {"m": 1, "o": 2, "l": 1, "h": 1}, "sausage.ogg": {"s": 2, "a": 2, "l": 1, "i": 1, "c": 1, "h": 1}, "snack.ogg": {"l": 1, "a": 1, "n": 1, "c": 1, "h": 1, "e": 1}, "soup.ogg": {"s": 1, "o": 1, "p": 1, "a": 1}, "spaghetti.ogg": {"e": 3, "s": 1, "p": 1, "a": 1, "r": 1, "g": 1, "u": 1, "t": 1}, "spice.ogg": {"e": 2, "s": 2, "p": 1, "c": 1, "i": 2, "a": 2, "r": 1}, "sprinkle.ogg": {"p": 2, "e": 1, "i": 1, "t": 1, "a": 1, "s": 1}, "stew.ogg": {"g": 1, "u": 1, "i": 1, "s": 1, "a": 1, "d": 1, "o": 1}, "sugar.ogg": {"a": 2, "ç": 1, "ú": 1, "c": 1, "r": 1}, "treat.ogg": {"g": 1, "u": 1, "l": 1, "o": 1, "s": 1, "e": 1, "i": 1, "m": 1, "a": 1}, "yogurt.ogg": {"i": 1, "o": 1, "g": 1, "u": 1, "r": 1, "t": 1, "e": 1}}
    property int lessonIndex:11
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
