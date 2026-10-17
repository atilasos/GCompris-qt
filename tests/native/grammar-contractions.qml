// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
    name: "PortugueseContractionTokens"
    when: items.numberOfLevel > 0
    property int verified: 0

    function tokenIndex(code) {
        for (var i = 0; i < items.goalModel.count; i++)
            if (items.goalModel.get(i).code === code) return i;
        fail("Missing selectable token: " + code);
        return -1;
    }

    function assign(card, code) {
        var token = items.gridGoalTokens.children[tokenIndex(code)];
        mouseClick(token, token.width / 2, token.height / 2);
        var box = card.rowWords.children[0];
        mouseClick(box, box.width / 2, box.height / 2);
        tryVerify(function() { return !Activity.animRunning; }, 2000);
        compare(card.proposition, code === "eraser" ? "_" : code);
    }

    function test_contraction_tokens_and_layout() {
        wait(1800);
        activityBackground.forceActiveFocus();
        keyClick(Qt.Key_Return);
        tryCompare(tutorialScreen, "visible", false);
        var cases = [
            { group: "determiners-nouns", sentence: "A chuva cai no jardim.", word: "no", code: "dtm" },
            { group: "contractions", sentence: "A bola está na caixa.", word: "na", code: "pdt" },
            { group: "contractions-pronouns", sentence: "Eu preciso disto.", word: "disto", code: "ppr" },
            { group: "complete-analysis", sentence: "Nós gostamos disto e queremos participar.", word: "disto", code: "ppr" }
        ];
        for (var c = 0; c < cases.length; c++) {
            var fixture = cases[c];
            var level = Activity.datas.levels.findIndex(function(entry) { return entry.exercise === fixture.group; });
            verify(level >= 0);
            var exercise = Activity.datas.dataset[fixture.group].find(function(entry) { return entry.sentence === fixture.sentence; });
            verify(exercise !== undefined);
            items.currentLevel = level;
            items.currentExercise = 0;
            items.datasetModel.clear();
            items.datasetModel.append({ exercise: exercise });
            Activity.initLevel();
            wait(80);
            compare(items.errors.text, "");
            var target = null;
            for (var w = 0; w < items.rowAnswer.count; w++) {
                var card = items.rowAnswer.itemAt(w);
                if (!card.expected) continue;
                compare(card.boxModel.count, 1, card.wordText + " has one box");
                if (card.wordText === fixture.word) target = card;
            }
            verify(target !== null);
            compare(target.expected, fixture.code);
            assign(target, fixture.code);
            assign(target, "eraser");
            assign(target, fixture.code);
            var tokens = items.gridGoalTokens;
            verify(tokens.width <= activityBackground.width, "Class choices fit the window");
            for (var t = 0; t < items.goalModel.count; t++) {
                var image = tokens.children[t].imgSvg;
                if (items.goalModel.get(t).code !== "eraser")
                    tryCompare(image, "status", Image.Ready);
            }
            grabImage(activityBackground).save("__QA_OUTPUT__/" + fixture.group + ".png");
            verified++;
        }
    }

    function cleanupTestCase() {
        console.log("NATIVE_CONTRACTIONS_RESULT", JSON.stringify({
            failures: qtest_results.failCount, passes: qtest_results.passCount, verified: verified
        }));
    }
}
