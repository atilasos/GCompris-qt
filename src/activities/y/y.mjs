// SPDX-License-Identifier: GPL-3.0-or-later
// Independent native rules. board.mjs contains separately attributed facts.
import { nodes, edges } from './board.mjs';
export const adjacency = nodes.map(() => []);
export const indices = {};
for (let i = 0; i < nodes.length; i++) indices[nodes[i][0]] = i;
for (const edge of edges) {
    const a = indices[edge[0]], b = indices[edge[1]];
    adjacency[a].push(b); adjacency[b].push(a);
}
export function groupAt(board, start) {
    if (!board[start]) return [];
    const group = [start], seen = {};
    seen[start] = true;
    for (let j = 0; j < group.length; j++) {
        for (const next of adjacency[group[j]]) {
            if (!seen[next] && board[next] === board[start]) {
                seen[next] = true; group.push(next);
            }
        }
    }
    return group;
}
export function sides(group) {
    let mask = 0;
    for (const i of group) mask |= nodes[i][3];
    return mask;
}
