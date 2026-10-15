// SPDX-License-Identifier: GPL-3.0-or-later
// Run: node --test tests/offline_datasets.test.mjs
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import vm from 'node:vm';
import test from 'node:test';

const root = new URL('../', import.meta.url);
const read = path => readFileSync(new URL(path, root), 'utf8');
function datasets(activity) {
    const metadata = read(`src/activities/${activity}/ActivityInfo.qml`);
    const folders = JSON.parse(metadata.match(/\blevels:\s*(\[[^\]]*\])/)[1]);
    return folders.flatMap(folder => {
        const qml = read(`src/activities/${activity}/resource/${folder}/Data.qml`);
        const expression = qml.slice(qml.indexOf('data:') + 5, qml.lastIndexOf(']') + 1);
        return vm.runInNewContext(`(${expression})`, { qsTr: text => text });
    });
}
function model() {
    return { rows: [], clear() { this.rows = []; }, append(row) { this.rows.push(row); },
        get(index) { return this.rows[index]; }, get count() { return this.rows.length; } };
}
function script(path, extras = {}) {
    const context = vm.createContext({ qsTr: text => text, Core: {
        getInitialLevel: () => 0, shuffle: values => values,
        getNextLevel: (level, total) => (level + 1) % total,
        getPreviousLevel: (level, total) => (level + total - 1) % total
    }, ...extras });
    vm.runInContext(read(path).replace(/^\.(?:pragma|import).*$/gm, ''), context);
    return context;
}

test('multiple-choice opens offline datasets and accepts/rejects single and multiple answers', () => {
    const game = script('src/activities/multiple_choice_questions/multiple_choice_questions.js');
    const feedback = [];
    const outcomes = [];
    const items = { levels: datasets('multiple_choice_questions'), errorRectangle: { resetState() {} },
        feedbackArea: { visible: false, display(success, text) { feedback.push({ success, text }); } },
        answerList: {}, score: { stopWinAnimation() {} }, instruction: {}, answerModel: model(),
        client: { startTiming() {}, sendToServer(success) { outcomes.push(success); } } };
    game.start(items);
    assert.equal(items.numberOfLevel, 3);
    assert.equal(items.instruction.text, 'Which number comes immediately after 2?');
    items.currentAnswerIndex = items.answerModel.rows.findIndex(row => row.content_ === '3');
    game.checkResult();
    assert.equal(feedback.at(-1).success, true);
    items.buttonsBlocked = false;
    items.currentAnswerIndex = items.answerModel.rows.findIndex(row => row.content_ === '1');
    game.checkResult();
    assert.equal(feedback.at(-1).success, false);
    game.nextLevel();
    assert.equal(items.mode, 'multipleAnswers');
    for (const row of items.answerModel.rows) row.checked_ = row.content_ === '1' || row.content_ === '2';
    game.checkResult();
    assert.equal(feedback.at(-1).success, true);
    items.buttonsBlocked = false;
    items.answerModel.rows.find(row => row.content_ === '3').checked_ = true;
    game.checkResult();
    assert.equal(feedback.at(-1).success, false);
    assert.deepEqual(outcomes, [true, false, true, false]);
    const expected = new Map([
        ['Which number comes immediately after 2?', ['3']],
        ['Which answer is a color?', ['yellow']],
        ['Which numbers are smaller than 3?', ['1', '2']],
        ['Which answers are animals?', ['cat', 'dog']],
        ['How many sides does a triangle have?', ['3']]
    ]);
    for (let level = 0; level < 3; ++level) {
        items.currentLevel = level;
        game.initLevel();
        for (let sublevel = 0; sublevel < items.numberOfSubLevel; ++sublevel) {
            items.currentSubLevel = sublevel;
            game.createLevel();
            const correct = expected.get(items.instruction.text);
            assert.ok(correct, items.instruction.text);
            assert.deepEqual(items.answerModel.rows.filter(row => row.isSolution_).map(row => row.content_), correct);
        }
    }
});

test('chronology opens three offline image sequences instead of an empty level list', () => {
    const game = script('src/activities/ordering_numbers/ordering.js');
    const items = { levels: datasets('ordering_chronology'), instruction: {},
        originListModel: model(), targetListModel: model() };
    game.start(items, 'chronology');
    assert.equal(items.numberOfLevel, 3);
    assert.match(items.instruction.text, /chronological order/);
    assert.equal(items.originListModel.count, 4);
    assert.deepEqual(Array.from(game.originalArrangement), [
        'qrc:/gcompris/src/activities/chronos/resource/images/garden-01.svg',
        'qrc:/gcompris/src/activities/chronos/resource/images/garden-02.svg',
        'qrc:/gcompris/src/activities/chronos/resource/images/garden-03.svg',
        'qrc:/gcompris/src/activities/chronos/resource/images/garden-04.svg'
    ]);
    for (const image of ['moon-01.svg', 'tuxtree-01.svg']) {
        game.nextLevel();
        assert.equal(items.originListModel.count, 4);
        assert.ok(game.originalArrangement[0].endsWith(image));
    }
});
