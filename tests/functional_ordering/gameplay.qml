// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: 'OrderingVisibleLabels'
    when: true
    property var completed: []
    property int rejected: 0
    property int drags: 0
    property int reordered: 0
    property var phrases: [
        'O cão ladra.', 'A casa é vermelha.', 'O menino lê um livro.',
        'O meu amigo é fixe.', 'Que vista maravilhosa!', 'O João mergulha na piscina.',
        'A Joana quer um livro.', 'A mãe fez-me uma sandes.', 'Os tigres vivem nas florestas.',
        'O futebol joga-se em equipa.', 'O Sol brilha no céu azul.',
        'As crianças gostam de se divertir à noite.', 'Vais sair de casa para almoçar?',
        'A menina calçou os sapatos e saiu.', 'O José ficou doente depois de comer chocolates grandes.',
        'A nossa família passa férias na praia todos os anos.',
        'O tio Paulo deu-me um camião vermelho.', 'Quando terminares o arroz podes comer a sobremesa.',
        'A mãe pediu-me para brincar no quarto.', 'Penso que vamos ter um bom dia.'
    ]
    function find(root, predicate) {
        if (predicate(root)) return root;
        if (root.children) for (var child of root.children) { var found = find(child, predicate); if (found) return found; }
        return null;
    }
    function click(item) {
        verify(item !== null);
        var p = item.mapToItem(pageView, item.width / 2, item.height / 2);
        mouseClick(pageView, p.x, p.y, Qt.LeftButton, Qt.NoModifier, 0);
    }
    function cards(root, placeholder) {
        var result = [];
        function collect(item) {
            if (item.placeholderName === placeholder && typeof item.elementValue === 'string') {
                var label = find(item, function(child) { return child.text !== undefined && child.visible && String(child.text) !== ''; });
                verify(label !== null); result.push({item:item, label:String(label.text)}); return;
            }
            if (item.children) for (var child of item.children) collect(child);
        }
        collect(root); return result;
    }
    function drag(item, destination) {
        verify(item !== null);
        var start = item.mapToItem(pageView, item.width / 2, item.height / 2);
        var end = destination.mapToItem(pageView, destination.width - 25, destination.height - 25);
        mousePress(pageView, start.x, start.y, Qt.LeftButton, Qt.NoModifier, 0);
        mouseMove(pageView, start.x + 15, start.y + 15, 30);
        mouseMove(pageView, start.x + 30, start.y + 30, 30);
        mouseMove(pageView, end.x, end.y, 30);
        mouseRelease(pageView, end.x, end.y, Qt.LeftButton, Qt.NoModifier, 30);
        wait(600); drags++;
    }
    function oracle(labels) {
        if (activity.mode === 'numbers') {
            for (var label of labels) verify(/^\d+$/.test(label));
            labels.sort(function(a,b) { return Number(a)-Number(b); });
        } else if (activity.mode === 'alphabets') {
            var alphabet = 'abcdefghijklmnopqrstuvwxyz';
            for (var letter of labels) verify(letter.length === 1 && alphabet.indexOf(letter) >= 0);
            labels.sort(function(a,b) { return alphabet.indexOf(a)-alphabet.indexOf(b); });
        } else {
            // Whole Portuguese clauses authored from the observed shuffled bags.
            // Capitalisation, subject/verb and terminal punctuation anchor the order.
            var solutions = [];
            for (var phrase of phrases) {
                var pending = labels.slice(), ordered = [], rest = phrase;
                while (pending.length) {
                    var index = pending.findIndex(function(token) { return rest === token || rest.indexOf(token + ' ') === 0; });
                    if (index < 0) break;
                    var token = pending.splice(index, 1)[0]; ordered.push(token); rest = rest.substring(token.length).trim();
                }
                if (!pending.length && rest === '') solutions.push(ordered);
            }
            compare(solutions.length, 1, 'Unique independently authored phrase for visible bag ' + JSON.stringify(labels));
            return solutions[0];
        }
        console.log('ORDERING_INSTRUCTION',items.instruction.text);
        verify(items.instruction.text.indexOf('ascendente') >= 0 || items.instruction.text.indexOf('descendente') >= 0 || items.instruction.text.indexOf('alfabética') >= 0);
        if (items.instruction.text.indexOf('descendente') >= 0 || items.instruction.text.indexOf('inversa') >= 0) labels.reverse();
        return labels;
    }
    function arrange(order) {
        for (var index=0; index<order.length; index++) {
            var chosen = cards(originPlaceholder, 'origin').find(function(card) { return card.label === order[index]; });
            verify(chosen !== undefined); drag(chosen.item, targetPlaceholder);
            compare(items.targetListModel.count,index+1);
        }
        compare(items.originListModel.count,0); compare(ok.visible,true);
        compare(cards(targetPlaceholder,'target').map(function(card){return card.label;}), order);
    }
    function test_all_original_levels() {
        wait(1600);
        if (!activity.visible) { keyClick(Qt.Key_Return); tryCompare(activity,'visible',true,2500); wait(1100); }
        var totals = {numbers:8, alphabets:8, sentences:20};
        console.log('ORDERING_INITIAL',activity.mode,items.numberOfLevel,activity.numberOfLevel,items.currentLevel);
        compare(items.numberOfLevel,totals[activity.mode]); compare(activity.numberOfLevel,totals[activity.mode]);
        for (var level=0; level<totals[activity.mode]; level++) {
            tryCompare(bonus,'isPlaying',false,6000); wait(650); compare(items.currentLevel,level);
            var visible = cards(originPlaceholder,'origin').map(function(card){return card.label;});
            console.log('ORDERING_VISIBLE',JSON.stringify(visible),items.originListModel.count,items.currentLevel);
            verify(visible.length >= 3); compare(ok.visible,false);
            var ordered = oracle(visible.slice()), wrong = ordered.slice();
            var swap=wrong[0];wrong[0]=wrong[1];wrong[1]=swap;
            console.log('ORDERING_HEARTBEAT',activity.mode,level+1,JSON.stringify(visible));
            arrange(wrong);click(ok);compare(bonus.isWin,false);rejected++;
            compare(String(cards(targetPlaceholder,'target')[0].item.borderColor),'#d94444');
            compare(String(cards(targetPlaceholder,'target')[1].item.borderColor),'#d94444');
            tryCompare(bonus,'isPlaying',false,6000);compare(items.currentLevel,level);
            if(level===0) {
                grabImage(activityBackground).save('__QA_OUTPUT__/wrong.png');
                var targets=cards(targetPlaceholder,'target');
                drag(targets[1].item,targets[0].item);
                compare(cards(targetPlaceholder,'target').map(function(card){return card.label;}),ordered);
                reordered++;
            }
            while(items.targetListModel.count) drag(cards(targetPlaceholder,'target')[0].item,originPlaceholder);
            compare(items.originListModel.count,visible.length);compare(ok.visible,false);compare(targetPlaceholder.colorResetRequired,false);
            arrange(ordered);click(ok);compare(bonus.isWin,true);
            for(var card of cards(targetPlaceholder,'target')) compare(String(card.item.borderColor),'#62ba62');
            completed.push({level:level+1,visible:visible,ordered:ordered,rejected:wrong});
            if(level===0 || level===totals[activity.mode]-1)grabImage(activityBackground).save('__QA_OUTPUT__/level-'+(level+1)+'.png');
            tryCompare(items,'currentLevel',(level+1)%totals[activity.mode],9000);
        }
        compare(rejected,totals[activity.mode]);compare(completed.length,totals[activity.mode]);
    }
    function cleanupTestCase() {
        console.log('NATIVE_ORDERING_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,completed:completed,rejected:rejected,drags:drags,reordered:reordered}));
    }
}
