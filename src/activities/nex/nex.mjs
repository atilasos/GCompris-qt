// SPDX-License-Identifier: GPL-3.0-or-later
// Independent implementation of Nex rules. Cell index is x*11+y.
export function emptyBoard() { return Array(121).fill(0); }
export function connected(board, color) {
    const seen = new Set(), queue = [];
    for (let i=0;i<121;++i) if (board[i]===color && (color===1 ? i%11===0 : Math.floor(i/11)===0)) { queue.push(i); seen.add(i); }
    while (queue.length) {
        const i=queue.pop(), x=Math.floor(i/11), y=i%11;
        if (color===1 ? y===10 : x===10) return true;
        for (const [dx,dy] of [[1,0],[-1,0],[0,1],[0,-1],[1,-1],[-1,1]]) {
            const nx=x+dx, ny=y+dy, n=nx*11+ny;
            if(nx>=0&&nx<11&&ny>=0&&ny<11&&board[n]===color&&!seen.has(n)) { seen.add(n);queue.push(n); }
        }
    }
    return false;
}
export function apply(board, own, mode, selection) {
    if((own!==1&&own!==2)||(mode!==0&&mode!==1)) return null;
    const required=mode===0?2:3;
    if(selection.length!==required || new Set(selection).size!==required || selection.some(i=>!Number.isInteger(i)||i<0||i>=121)) return null;
    const expected=mode===0?[0,0]:[3,3,own];
    if(selection.some((i,k)=>board[i]!==expected[k])) return null;
    const next=board.slice();
    selection.forEach((i,k)=>next[i]=mode===0?(k===0?own:3):(k===2?3:own));
    return next;
}
// Resolve only the three specified terminal conventions, never generic lack of empties.
export function rare(board, own) {
    const empty=[], neutral=[];
    board.forEach((v,i)=>{ if(v===0) empty.push(i); else if(v===3) neutral.push(i); });
    if(!((empty.length===1&&neutral.length===0)||(empty.length===0&&neutral.length===1)||(empty.length===1&&neutral.length===1))) return null;
    const next=board.slice();
    if(empty.length) next[empty[0]]=own;
    if(neutral.length) next[neutral[0]]=empty.length?3-own:own;
    return {board:next, winner:connected(next,own)?own:connected(next,3-own)?3-own:3};
}
