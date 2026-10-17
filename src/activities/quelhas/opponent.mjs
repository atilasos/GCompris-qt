// SPDX-License-Identifier: GPL-3.0-or-later
// Independently authored, bounded teaching policies; shared match rules.
import * as Rules from './quelhas.mjs';
WorkerScript.onMessage = function(message) {
    if (message.swapAvailable && message.difficulty === 2) {
        WorkerScript.sendMessage({swap: true, generation: message.generation}); return;
    }
    // Participant 2 is horizontal before swap and vertical afterwards.
    var vertical = message.swapped;
    var options = Rules.options(message.board, vertical), chosen = options[0];
    if (message.difficulty === 0) chosen = options[Math.floor(Math.random() * options.length)];
    else {
        var best = -Infinity;
        // At most 30 candidates and 20 replies. Complete segments remain legal.
        var stride = Math.max(1, Math.ceil(options.length / 30));
        for (var i = 0; i < options.length; i += stride) {
            var after = Rules.place(message.board, options[i]);
            var replies = Rules.options(after, !vertical);
            // Misère: leaving the next participant without a move LOSES.
            var value = replies.length ? Rules.pairs(after, !vertical) - Rules.pairs(after, vertical) : -10000;
            if (message.difficulty === 2 && replies.length) {
                value = Infinity;
                var step = Math.max(1, Math.ceil(replies.length / 20));
                for (var j = 0; j < replies.length; j += step) {
                    var next = Rules.place(after, replies[j]);
                    value = Math.min(value, !Rules.hasMove(next, vertical) ? 10000 : Rules.pairs(next, !vertical) - Rules.pairs(next, vertical));
                }
            }
            if (value > best) { best = value; chosen = options[i]; }
        }
    }
    WorkerScript.sendMessage({move: chosen, generation: message.generation});
};
