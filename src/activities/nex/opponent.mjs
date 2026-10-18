// SPDX-License-Identifier: GPL-3.0-or-later
// Independently authored bounded local policies; shared legality and connections.
import * as Rules from './nex.mjs';
WorkerScript.onMessage = function(message) {
    const board=message.board,own=message.own,level=message.difficulty;
    if(message.swap && level>0) {
        const first=board.findIndex(v=>v===3-own);
        if(first>=0 && Math.abs(Math.floor(first/11)-5)<=2 && Math.abs(first%11-5)<=2) {
            WorkerScript.sendMessage({generation:message.generation,swap:true}); return;
        }
    }
    const actions=Rules.candidates(board,own,level);
    let best=null,bestScore=-Infinity;
    for(const action of actions) {
        const next=Rules.apply(board,own,action.mode,action.selection);
        // Easy explores first legal placement; Medium shortens its own route;
        // Hard also blocks the opposing route. At most 54 candidates, no recursion.
        let score=level===0?0:-Rules.distance(next,own)*10;
        if(level===2) score+=Math.min(20,Rules.distance(next,3-own))*4;
        if(Rules.connected(next,own)) score+=10000;
        // Prefer placement on equal scores; once full, substitution consumes neutrals.
        if(action.mode===0) score+=0.1;
        if(score>bestScore) {bestScore=score;best=action;}
        if(level===0) break;
    }
    WorkerScript.sendMessage({generation:message.generation,action:best});
};
