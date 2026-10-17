// SPDX-License-Identifier: GPL-3.0-or-later
import * as Rules from "./faisca.mjs";
WorkerScript.onMessage = function(message) {
    var options = Rules.moves(message.cells, message.reserves[1], message.mandatory);
    var chosen = options[0], best = -Infinity;
    if (message.difficulty === 0) chosen = options[Math.floor(Math.random() * options.length)];
    else for (var i = 0; i < options.length; ++i) {
        var next = Rules.place(message.cells, message.reserves, 2, options[i]);
        var replies = Rules.moves(next.cells, next.reserves[0], next.mandatory);
        var value = -replies.length;
        if (!replies.length) value = 10000;
        else if (message.difficulty === 2) {
            value = Infinity;
            // At most twelve candidates and twelve replies, with no recursive search.
            for (var j = 0; j < replies.length; ++j) {
                var after = Rules.place(next.cells, next.reserves, 1, replies[j]);
                var count = Rules.moves(after.cells, after.reserves[1], after.mandatory).length;
                value = Math.min(value, count ? count : -10000);
            }
        }
        if (value > best) { best = value; chosen = options[i]; }
    }
    WorkerScript.sendMessage({move: chosen, generation: message.generation});
};
