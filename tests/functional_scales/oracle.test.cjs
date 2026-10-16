// SPDX-License-Identifier: GPL-3.0-or-later
const fs = require('node:fs');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const math = vm.runInNewContext(fs.readFileSync(__dirname + '/oracle.js', 'utf8'));
assert.equal(math.parse('1 kg'), 1000);
assert.equal(math.parse('2,2 kg'), 2200);
assert.equal(math.parse('1 lb'), 16);
assert.equal(math.parse('3 oz'), 3);
assert.equal(math.parse('7'), 7);
assert.throws(() => math.parse('7 bananas'));
const left = math.plans(['2', '3', '7'], false);
assert.equal(JSON.stringify(left.map(row => row.sum)), '[2,3,5,7,9,10,12]');
assert.equal(left.some(row => row.positions.includes(-1)), false);
const signed = math.plans(['6 g', '9 g', '2 g'], true);
const four = signed.find(row => row.sum === 4);
assert(four);
assert.equal(four.positions[0] * 6 + four.positions[1] * 9 + four.positions[2] * 2, 4);
assert(four.positions.includes(-1));
assert.equal(math.entry(2200, 'Indica o peso do presente em gramas: '), 2200);
assert.equal(math.entry(3000, 'Indica o peso do presente em quilogramas: '), 3);
assert.equal(math.entry(32, 'Indica o peso do presente em libras: '), 2);
assert.equal(math.entry(32, 'Indica o peso do presente em onças: '), 32);
console.log('scales independent unit/plan examples passed');
const gameplay = fs.readFileSync(__dirname + '/gameplay.qml', 'utf8');
assert(!/\b(?:giftWeight|currentTargets)\b|question\.answer|\.targets\b|\.weight\b/.test(gameplay),
       'The interaction case must not read hidden target masses or answers');
