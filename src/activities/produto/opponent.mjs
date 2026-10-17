// SPDX-License-Identifier: GPL-3.0-or-later
// Original bounded local policies. The shared rules alone validate full turns.
import * as Rules from './produto.mjs';
WorkerScript.onMessage = function(message) {
    var board = message.board, empty = [];
    for (var i = 0; i < 61; ++i) if (!board[i]) empty.push(i);
    var move = [], evaluated = 0;
    if (empty.length >= 2) {
        if (message.difficulty === 0) {
            var first = Math.floor(Math.random() * empty.length);
            var a = empty.splice(first, 1)[0];
            move = [{index:a,color:Math.random()<0.5?1:2}, {index:empty[Math.floor(Math.random()*empty.length)],color:Math.random()<0.5?1:2}];
        } else {
            // Sample across the whole board, with a hard cap independent of game depth.
            var cap = message.difficulty === 1 ? 24 : 96, best = -Infinity;
            var started = Date.now();
            for (var k = 0; k < cap && Date.now()-started < 350; ++k) {
                var ia = k % empty.length;
                var ib = (ia + 1 + Math.floor(k / empty.length)) % empty.length;
                if (ia === ib) continue;
                var pair = message.difficulty === 1 ? 3 : Math.floor(k / 2) % 4;
                var candidate = [{index:empty[ia],color:(pair & 1)+1}, {index:empty[ib],color:((pair>>1)&1)+1}];
                var next = Rules.apply(board,message.turn,candidate);
                if (!next) continue;
                ++evaluated;
                var own = Rules.summary(next,2), other = Rules.summary(next,1);
                var value = own.score - (message.difficulty === 2 ? other.score : 0);
                var result = Rules.result(next);
                if (result) value = result === 2 ? 100000 : -100000;
                // Smaller groups matter when both products are still zero.
                value += 0.01*(own.second-other.second);
                if (value > best) { best=value; move=candidate; }
            }
        }
    }
    WorkerScript.sendMessage({generation:message.generation,move:move,evaluated:evaluated});
};
