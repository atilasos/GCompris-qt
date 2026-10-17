// SPDX-License-Identifier: GPL-3.0-or-later
// Independent, bounded teaching opponent. Shares the match rule implementation.
import * as Rules from "./gatos_caes.mjs";

function moves(board, player) {
    var result = [];
    for (var i = 0; i < 64; ++i)
        if (Rules.legal(board, i, player)) result.push(i);
    return result;
}
WorkerScript.onMessage = function(message) {
    var options = moves(message.board, 2);
    var chosen = options.length ? options[0] : -1;
    if (message.difficulty === 0 && options.length)
        chosen = options[Math.floor(Math.random() * options.length)];
    else {
        var best = -Infinity;
        // At most 64 candidates x 12 replies, never an unbounded search.
        for (var i = 0; i < options.length; ++i) {
            var next = Rules.place(message.board, options[i], 2);
            var replies = moves(next, 1);
            var value = moves(next, 2).length - replies.length;
            if (!replies.length) value = 10000;
            else if (message.difficulty === 2) {
                value = Infinity;
                for (var j = 0; j < Math.min(12, replies.length); ++j) {
                    var after = Rules.place(next, replies[j], 1);
                    value = Math.min(value, moves(after, 2).length ? moves(after, 2).length - moves(after, 1).length : -10000);
                }
            }
            if (value > best) { best = value; chosen = options[i]; }
        }
    }
    WorkerScript.sendMessage({move: chosen, generation: message.generation});
};
