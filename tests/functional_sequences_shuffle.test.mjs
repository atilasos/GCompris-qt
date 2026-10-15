// SPDX-License-Identifier: GPL-3.0-or-later
// Deterministic chronology shuffle/restart at the real game and Core JS seam.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import vm from 'node:vm';
import test from 'node:test';
const root = new URL('../', import.meta.url);
const read = file => readFileSync(new URL(file, root), 'utf8');
const plain = source => source.replace(/^\.(?:pragma|import).*$/gm, '');
function model() {
    return { rows: [], get count() { return this.rows.length; }, clear() { this.rows = []; },
        append(row) { this.rows.push(row); }, get(i) { return this.rows[i]; },
        remove(i) { this.rows.splice(i, 1); },
        move(from, to, count) { this.rows.splice(to, 0, ...this.rows.splice(from, count)); } };
}

test('real chronology + Core shuffle preserves every image, source data and answer checking after restart', () => {
    let random = 0;
    const math = Object.create(Math);
    math.random = () => random;
    const core = vm.createContext({ Math: math, GCompris: { ActivityInfoTree: { startingLevel: -1 } } });
    vm.runInContext(plain(read('src/core/core.js')), core);
    const game = vm.createContext({ Core: core, qsTr: text => text });
    vm.runInContext(plain(read('src/activities/ordering_numbers/ordering.js')), game);
    const levels = ['1', '2', '3'].flatMap(folder => {
        const source = read(`src/activities/ordering_chronology/resource/${folder}/Data.qml`);
        return vm.runInNewContext('(' + source.slice(source.indexOf('data:') + 5, source.lastIndexOf(']') + 1) + ')');
    });
    const original = JSON.stringify(levels);
    const results = [];
    const items = { levels, instruction: {}, originListModel: model(), targetListModel: model(),
        targetPlaceholder: { colorResetRequired: false }, bonus: { good: () => results.push('good'), bad: () => results.push('bad') } };
    const names = () => items.originListModel.rows.map(row => row.elementValue.split('/').at(-1));
    game.start(items, 'chronology');
    assert.deepEqual(names(), ['garden-02.svg', 'garden-03.svg', 'garden-04.svg', 'garden-01.svg']);
    for (const prefix of ['garden', 'moon', 'tuxtree']) {
        for (const n of [2, 1, 3, 4]) {
            const index = items.originListModel.rows.findIndex(row => row.elementValue.endsWith(`${prefix}-0${n}.svg`));
            game.dropElement({ index, elementValue: items.originListModel.get(index).elementValue }, 'target');
        }
        game.checkOrder();
        assert.equal(results.at(-1), 'bad');
        assert.equal(items.targetListModel.get(0).borderColor, '#D94444');
        game.moveFromTargetList(0, 1, 1);
        game.targetColorReset();
        assert.ok(items.targetListModel.rows.every(row => row.borderColor === '#808080'));
        game.checkOrder();
        assert.equal(results.at(-1), 'good');
        assert.ok(items.targetListModel.rows.every(row => row.borderColor === '#62BA62'));
        game.nextLevel();
    }
    assert.equal(items.currentLevel, 0);
    random = 0.999999;
    game.start(items, 'chronology');
    assert.deepEqual(names(), ['garden-01.svg', 'garden-02.svg', 'garden-03.svg', 'garden-04.svg']);
    assert.equal(items.targetListModel.count, 0);
    assert.equal(JSON.stringify(levels), original, 'Restart must not shuffle the declared chronological solution');
    assert.deepEqual(results, ['bad', 'good', 'bad', 'good', 'bad', 'good']);
});
