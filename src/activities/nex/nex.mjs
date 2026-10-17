// SPDX-License-Identifier: GPL-3.0-or-later
// Independent implementation of Nex rules. Cell index is x*11+y.
const neighbors = Array.from({length:121}, (_, i) => {
    const x=Math.floor(i/11), y=i%11;
    return [[1,0],[-1,0],[0,1],[0,-1],[1,-1],[-1,1]]
        .map(([dx,dy]) => [x+dx,y+dy])
        .filter(([nx,ny]) => nx>=0&&nx<11&&ny>=0&&ny<11)
        .map(([nx,ny]) => nx*11+ny);
});
export function emptyBoard() { return Array(121).fill(0); }
export function connected(board, color) {
    const seen = new Set(), queue = [];
    for (let i=0;i<121;++i) if (board[i]===color && (color===1 ? i%11===0 : Math.floor(i/11)===0)) { queue.push(i); seen.add(i); }
    while (queue.length) {
        const i=queue.pop(), x=Math.floor(i/11), y=i%11;
        if (color===1 ? y===10 : x===10) return true;
        for (const n of neighbors[i]) {
            if(board[n]===color&&!seen.has(n)) { seen.add(n);queue.push(n); }
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
export function resolveSpecialEnding(board, own) {
    const empty=[], neutral=[];
    board.forEach((v,i)=>{ if(v===0) empty.push(i); else if(v===3) neutral.push(i); });
    if(!((empty.length===1&&neutral.length===0)||(empty.length===0&&neutral.length===1)||(empty.length===1&&neutral.length===1))) return null;
    const next=board.slice();
    if(empty.length) next[empty[0]]=own;
    if(neutral.length) next[neutral[0]]=empty.length?3-own:own;
    return {board:next, winner:connected(next,own)?own:connected(next,3-own)?3-own:3};
}
// Minimum number of non-owned cells along a route; opponent stones block it.
// Used for learning feedback and bounded local policy evaluation, not game endings.
export function distance(board, own) {
    const costs=Array(121).fill(999), seen=Array(121).fill(false);
    for(let i=0;i<121;++i) if((own===1?i%11===0:Math.floor(i/11)===0)&&board[i]!==3-own) costs[i]=board[i]===own?0:1;
    for(let step=0;step<121;++step) {
        let at=-1;
        for(let i=0;i<121;++i) if(!seen[i]&&(at<0||costs[i]<costs[at])) at=i;
        if(at<0||costs[at]===999) break;
        if(own===1?at%11===10:Math.floor(at/11)===10) return costs[at];
        seen[at]=true;
        for(const n of neighbors[at]) {
            if(board[n]===3-own) continue;
            costs[n]=Math.min(costs[n],costs[at]+(board[n]===own?0:1));
        }
    }
    return 999;
}
// A small deterministic legal candidate set. No exhaustive pair/triple expansion.
export function candidates(board, own, level) {
    const empty=[],neutral=[],owned=[];
    board.forEach((v,i)=>{(v===0?empty:v===3?neutral:v===own?owned:[]).push(i);});
    function local(i) {
        const x=Math.floor(i/11),y=i%11;
        let value=0;
        for(const n of neighbors[i]) {
            value+=board[n]===own?5:board[n]===3-own?1:0;
        }
        return value-Math.abs((own===1?x:y)-5)*0.1;
    }
    if(level>0) {empty.sort((a,b)=>local(b)-local(a)||a-b);neutral.sort((a,b)=>local(b)-local(a)||a-b);owned.sort((a,b)=>local(a)-local(b)||a-b);}
    const result=[];
    if(empty.length>=2) {
        // At most 12 own placements × 3 neutral choices = 36 candidates.
        for(const a of empty.slice(0,level===0?1:12)) {
            const targets=empty.filter(b=>b!==a).reverse().slice(0,level===0?1:3);
            for(const b of targets) result.push({mode:0,selection:[a,b]});
        }
    }
    if(neutral.length>=2&&owned.length && (level>0||empty.length<2)) {
        // At most 6 neutral pairs × 3 own sacrifices = 18 candidates.
        const n=neutral.slice(0,level===0?2:4);
        for(let a=0;a<n.length;++a) for(let b=a+1;b<n.length;++b)
            for(const c of owned.slice(0,level===0?1:3)) result.push({mode:1,selection:[n[a],n[b],c]});
    }
    return result.filter(action=>apply(board,own,action.mode,action.selection));
}
