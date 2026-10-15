// SPDX-License-Identifier: GPL-3.0-or-later
import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
const data = JSON.parse(readFileSync(new URL('../../src/activities/wordsgame/resource/default-pt.json', import.meta.url)));
test('PT word deck retains three original fifteen-answer levels and 147 valid NFC spellings', () => {
    assert.equal(data.locale, 'pt');
    assert.equal(data.levels.length, 3);
    let count = 0;
    for (const [index, level] of data.levels.entries()) {
        assert.equal(Number(level.level), index + 1);
        assert.equal(Number(level.sublevels), 15);
        assert.ok(level.words.length >= 15);
        // Repeated entries are valid sampling weights, not invalid answers.
        for (const word of level.words) {
            assert.match(word, /^[a-zàáâãéêíóôõúç]+$/u);
            assert.equal(word.normalize('NFC'), word);
            count++;
        }
    }
    assert.equal(count, 147);
    assert.ok(data.levels[0].words.includes('peça'));
    assert.ok(data.levels[1].words.includes('dançar'));
    assert.ok(data.levels[2].words.includes('frigorífico'));
    const special = [...new Set(data.levels.flatMap(level => level.words).join('').replace(/[a-z]/g, ''))].sort();
    assert.deepEqual(special, ['ç', 'í', 'ú']);
    assert.ok(data.levels[2].words.includes('música'));
    assert.ok(!data.levels[2].words.includes('musica'));
});
