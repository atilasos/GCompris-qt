// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name:"CompleteHangmanLessonPT"
    when:activity.visible
    property var expectedWords: {"faucet.ogg": "torneira", "air_horn.ogg": "buzina", "anchor.ogg": "âncora", "badge.ogg": "crachá", "bag.ogg": "mochila", "ball.ogg": "bola", "ball_soccer.ogg": "bola de futebol", "bell.ogg": "sino", "block.ogg": "bloco", "board.ogg": "tabuleta", "bomb.ogg": "bomba", "book.ogg": "livro", "box.ogg": "caixa", "bucket.ogg": "balde", "bulb.ogg": "lâmpada", "camera.ogg": "máquina fotográfica", "candle.ogg": "vela", "cane.ogg": "bengala", "canon.ogg": "canhão", "card.ogg": "postal", "cart.ogg": "carrinho de compras", "cash.ogg": "dinheiro", "chain.ogg": "corrente", "chalk.ogg": "giz", "cigar.ogg": "charuto", "clay.ogg": "barro", "cloth.ogg": "tecido", "clothes_hanger.ogg": "cabide", "coin.ogg": "moedas", "comb.ogg": "pente", "cone.ogg": "cone", "cork.ogg": "rolha", "cross.ogg": "cruz", "crown.ogg": "coroa", "cube.ogg": "cubo", "tire.ogg": "pneu", "dart_board.ogg": "jogo de dardos", "dishcloth.ogg": "pano da loiça", "doll.ogg": "boneca", "domino.ogg": "dominó", "drum.ogg": "tambor", "eraser.ogg": "borracha", "fire_extinguisher.ogg": "extintor", "flacon.ogg": "frasco", "flag.ogg": "bandeira", "fluff.ogg": "pano turco", "flute.ogg": "flauta", "game.ogg": "jogo", "gift.ogg": "prenda", "glasses.ogg": "óculos", "glue.ogg": "cola", "grill.ogg": "grelhador", "hair_dryer.ogg": "secador de cabelo", "handlebar.ogg": "guiador", "harp.ogg": "harpa", "hook.ogg": "gancho", "hose.ogg": "mangueira", "ink.ogg": "tinta", "jewel.ogg": "jóia", "keel.ogg": "tombar", "keyboard.ogg": "teclado", "kite.ogg": "papagaio", "knot.ogg": "nó", "lasso.ogg": "laço", "log.ogg": "lenha", "magnet.ogg": "íman", "magnifying_glass.ogg": "lupa", "mail.ogg": "correio", "map.ogg": "mapa", "marble.ogg": "berlinde", "mask.ogg": "máscara de mergulho", "mast.ogg": "mastro", "match.ogg": "fósforo", "medal.ogg": "medalha", "microphone.ogg": "microfone", "mirror.ogg": "espelho", "mixer.ogg": "batedeira", "necklace.ogg": "colar", "nest.ogg": "ninho", "net.ogg": "rede", "newspaper.ogg": "jornal", "notebook.ogg": "livro de apontamentos", "oar.ogg": "remo", "pacifier.ogg": "chucha", "page.ogg": "página", "pair.ogg": "par", "paper.ogg": "papel", "pearl.ogg": "pérola", "pen.ogg": "caneta", "pencil.ogg": "lápis", "phone.ogg": "telemóvel", "piano.ogg": "piano", "picture.ogg": "quadro", "pill.ogg": "comprimido", "pillow.ogg": "almofada", "pipe.ogg": "cachimbo", "pole.ogg": "varão", "prize.ogg": "prémio", "radio.ogg": "rádio", "rag.ogg": "trapo", "razor.ogg": "lâmina-de-barbear", "rifle.ogg": "espingarda", "robot.ogg": "robot", "rolling_pin.ogg": "rolo da massa", "rope.ogg": "corda-de-saltar", "saddle.ogg": "sela", "school_bag.ogg": "mochila da escola", "sign.ogg": "letreiro", "sleigh.ogg": "trenó", "slide.ogg": "escorrega", "slot.ogg": "ranhura", "soap.ogg": "sabão", "spark.ogg": "faúlha", "spinning_top.ogg": "pião", "spool.ogg": "carrinho-de-linhas", "squirt.ogg": "esguichador", "stack.ogg": "pilha", "stamp.ogg": "selo", "straw.ogg": "palhinha", "string.ogg": "fio", "suitcase.ogg": "mala de viagem", "tag.ogg": "etiqueta", "teddy.ogg": "ursinho-de-peluche", "thread.ogg": "linha", "ticket.ogg": "bilhete", "tissue.ogg": "lenço de papel", "torch.ogg": "tocha", "towel.ogg": "toalha", "toy.ogg": "brinquedo", "trap.ogg": "ratoeira", "tube.ogg": "tubo de batom", "umbrella.ogg": "guarda-chuva", "watch.ogg": "relógio de pulso", "wheel.ogg": "roda", "wig.ogg": "peruca", "wood.ogg": "madeira", "wreath.ogg": "grinalda", "ball_of_yarn.ogg": "novelo de lã", "foam.ogg": "espuma"}
    property int lessonIndex: 20
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
