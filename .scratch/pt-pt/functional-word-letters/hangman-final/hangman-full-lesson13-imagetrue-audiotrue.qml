// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteHangmanLessonPT"
    when:activity.visible
    property var expectedWords: {"alligator.ogg": "jacaré", "animal.ogg": "animal", "ant.ogg": "formiga", "anteater.ogg": "papa-formigas", "antelope.ogg": "antílope", "bait.ogg": "isco", "bat.ogg": "morcego", "bear.ogg": "urso", "beaver.ogg": "castor", "bee.ogg": "abelha", "beetle.ogg": "escaravelho", "bird.ogg": "pássaro", "blackbird.ogg": "melro", "buffalo.ogg": "búfalo", "bug.ogg": "besouro", "bull.ogg": "bói", "butterfly.ogg": "borboleta", "camel.ogg": "camelo", "canary.ogg": "canário", "cat.ogg": "gato", "caterpillar.ogg": "lagarta", "cat_female.ogg": "gata", "centipede.ogg": "centopeia", "chameleon.ogg": "camaleão", "chick.ogg": "pinto", "chicken.ogg": "galinha", "chimp.ogg": "chimpanzé", "clam.ogg": "concha", "claw.ogg": "garra", "cobra.ogg": "cobra", "cod.ogg": "bacalhau", "colt.ogg": "potro", "cow.ogg": "vaca", "crab.ogg": "caranguejo", "crocodile.ogg": "crocodilo", "crow.ogg": "corvo", "deer.ogg": "veado", "den.ogg": "aninhar", "doe.ogg": "corsa", "dog.ogg": "cão", "dolphin.ogg": "golfinho", "dove.ogg": "pomba", "dragon.ogg": "dragão", "dragonfly.ogg": "libelinha", "duck.ogg": "pato", "duck_mother.ogg": "mãe do pato", "eagle.ogg": "águia", "elk.ogg": "alce", "fawn.ogg": "corso", "feather.ogg": "pena", "fin.ogg": "barbatana", "fish.ogg": "peixe", "flamingo.ogg": "flamingo", "flies.ogg": "moscas", "fox.ogg": "raposa", "frog.ogg": "sapo", "fur.ogg": "pêlo", "giraffe.ogg": "girafa", "goat.ogg": "cabra", "goose.ogg": "ganso", "gorilla.ogg": "gorila", "guinea_pig.ogg": "porquinho-da-índia", "hedgehog.ogg": "porco-espinho", "hen.ogg": "galinha", "herd.ogg": "rebanho", "hippopotamus.ogg": "hipopótamo", "hive.ogg": "colmeia", "horse.ogg": "cavalo", "hound.ogg": "cão-de-caça", "hummingbird.ogg": "beija-flor", "hyena.ogg": "hiena", "iguana.ogg": "iguana", "jaguar.ogg": "jaguar", "jay.ogg": "gaio", "jellyfish.ogg": "alforreca", "kangaroo.ogg": "canguru", "kitten.ogg": "gato", "koala.ogg": "coala", "ladybug.ogg": "joaninha", "lama.ogg": "lama", "lamb.ogg": "cordeiro", "lemur.ogg": "lémur", "leopard.ogg": "leopardo", "lion.ogg": "leão", "lion_cub.ogg": "cria de leão", "lizard.ogg": "lagarto", "lobster.ogg": "lagosta", "magpie.ogg": "pega", "mane.ogg": "juba", "mice.ogg": "ratos", "mole.ogg": "toupeira", "moose.ogg": "alce", "mosquito.ogg": "mosquito", "mouse.ogg": "rato", "mule.ogg": "mula", "opossum.ogg": "gambá", "ostrich.ogg": "avestruz", "otter.ogg": "lontra", "owl.ogg": "coruja", "ox.ogg": "boi", "oyster.ogg": "ostra", "panda.ogg": "panda", "panther.ogg": "pantera", "parakeet.ogg": "periquito", "parrot.ogg": "papagaio", "paw.ogg": "pata", "peacock.ogg": "pavão", "pelican.ogg": "pelicano", "pet.ogg": "animal de estimação", "pig.ogg": "porco", "pigeon.ogg": "pombo", "piranha.ogg": "piranha", "pony.ogg": "pónei", "pug.ogg": "buldogue", "puppy.ogg": "cachorro", "rabbit.ogg": "coelho", "rabbit_baby.ogg": "coelho bebé", "rat.ogg": "rato", "reptile.ogg": "réptil", "rhinoceros.ogg": "rinoceronte", "salamander.ogg": "salamandra", "salmon.ogg": "salmão", "scorpion.ogg": "escorpião", "shark.ogg": "tubarão", "sheep.ogg": "ovelha", "shell.ogg": "búzio", "shrimp.ogg": "camarão", "skunk.ogg": "doninha", "slime.ogg": "viscoso", "sloth.ogg": "preguiça", "slug.ogg": "lesma", "snail.ogg": "caracol", "snake.ogg": "cobra", "sole.ogg": "solha", "sparrow.ogg": "pardal", "spider.ogg": "aranha", "spike.ogg": "espinhoso", "squid.ogg": "lula", "squirrel.ogg": "esquilo", "starfish.ogg": "estrela-do-mar", "swan.ogg": "cisne", "tadpole.ogg": "girino", "tail.ogg": "cauda", "tick.ogg": "piolho", "tiger.ogg": "tigre", "toad.ogg": "sapo", "turkey.ogg": "peru", "turtle.ogg": "tartaruga", "tusk.ogg": "tromba", "viper.ogg": "víbora", "vulture.ogg": "abutre", "wasp.ogg": "vespa", "whale.ogg": "baleia", "wing.ogg": "asa", "wolf.ogg": "lobo", "zebra.ogg": "zebra"}
    property int lessonIndex: 12
    property bool externalWords: true
    property bool imageHint: true
    property bool audioHint: true
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
