// SPDX-License-Identifier: GPL-3.0-or-later
// Original bounded local policies. Shared graph and connection rules.
import * as Rules from './y.mjs';
function value(cells, index, color) {
    const next = cells.slice(); next[index] = color;
    const group = Rules.groupAt(next, index), mask = Rules.sides(group);
    return (mask === 7 ? 100000 : [0,1,1,2,1,2,2,3][mask] * 100) + group.length;
}
WorkerScript.onMessage = function(message) {
    // A strong corner opening is worth adopting; the participant stays Tux.
    if (message.swap && message.difficulty > 0 && message.cells.some((c,i) => c && value(message.cells, i, 1) >= 200)) {
        WorkerScript.sendMessage({swap:true, generation:message.generation}); return;
    }
    const options = [];
    for (let i = 0; i < 93; i++) if (!message.cells[i])
        options.push({index:i, value:value(message.cells,i,message.color)});
    let chosen = options[Math.floor(Math.random() * options.length)];
    if (message.difficulty > 0) {
        options.sort((a,b) => b.value-a.value);
        chosen = options[0];
        if (message.difficulty === 2) {
            // At most 12 candidates × 93 one-move replies, no recursive tree.
            let best = -Infinity;
            for (const option of options.slice(0,12)) {
                const next = message.cells.slice(); next[option.index] = message.color;
                let danger = 0;
                if (option.value < 100000) for (let reply=0; reply<93; reply++) if (!next[reply])
                    danger = Math.max(danger, value(next,reply,3-message.color));
                const score = option.value - danger;
                if (score > best) {best=score; chosen=option;}
            }
        }
    }
    WorkerScript.sendMessage({index:chosen ? chosen.index : -1,generation:message.generation});
};
