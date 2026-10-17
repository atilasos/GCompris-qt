// SPDX-License-Identifier: GPL-3.0-or-later
// Independent bounded teaching policies; legal actions use shared native rules.
import * as Rules from './atari_go.mjs';
WorkerScript.onMessage = function(message) {
    const options = [];
    for (let index = 0; index < 81; ++index) {
        const move = Rules.place(message.board, 2, index);
        if (move.error) continue;
        const liberties = Rules.group(move.board, index).liberties.length;
        let value = move.captured.length * 100000 + liberties;
        // Prefer putting adjacent groups in atari while keeping our group alive.
        for (const near of [index-9, index+9, index%9 ? index-1 : -1, index%9<8 ? index+1 : -1])
            if (near >= 0 && near < 81 && move.board[near] === 1)
                value += 8 / Math.max(1, Rules.group(move.board, near).liberties.length);
        options.push({index: index, board: move.board, value: value, captures: move.captured.length});
    }
    let chosen = options[0];
    if (message.difficulty === 0) chosen = options[Math.floor(Math.random() * options.length)];
    else {
        options.sort((a,b) => b.value-a.value);
        chosen = options[0];
        if (message.difficulty === 2) {
            // At most 12 candidates × 81 immediate replies, never a game tree.
            let best = -Infinity;
            for (const option of options.slice(0,12)) {
                let danger = 0;
                if (!option.captures) for (let reply = 0; reply < 81; ++reply) {
                    const next = Rules.place(option.board, 1, reply);
                    if (!next.error) danger = Math.max(danger, next.captured.length);
                }
                const value = option.value - danger * 10000;
                if (value > best) { best = value; chosen = option; }
            }
        }
    }
    WorkerScript.sendMessage({index: chosen ? chosen.index : -1, generation: message.generation});
};
