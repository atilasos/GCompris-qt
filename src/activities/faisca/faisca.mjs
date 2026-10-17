// SPDX-License-Identifier: GPL-3.0-or-later
// Independent implementation of the published Faísca rules.
export function emptyBoard() { return Array(30).fill(null); }
export function destination(start, distance, direction) {
    if (start < 0 || start >= 30) return -1;
    var row = Math.floor(start / 6), column = start % 6;
    row += [-1, 0, 1, 0][direction] * distance;
    column += [0, 1, 0, -1][direction] * distance;
    return row >= 0 && row < 5 && column >= 0 && column < 6 ? row * 6 + column : -1;
}
export function legal(board, reserves, start, mandatory, distance, direction) {
    if (start < 0 || board[start] || (mandatory >= 0 && start !== mandatory) || reserves[distance - 1] <= 0) return false;
    var end = destination(start, distance, direction);
    return end >= 0 && !board[end];
}
export function hasMove(board, reserves, mandatory) {
    for (var distance = 1; distance <= 3; ++distance)
        for (var direction = 0; direction < 4; ++direction)
            if (legal(board, reserves, mandatory, mandatory, distance, direction)) return true;
    return false;
}
export function moves(board, reserves, mandatory) {
    var options = [];
    for (var start = mandatory < 0 ? 0 : mandatory; start < (mandatory < 0 ? 30 : mandatory + 1); ++start)
        for (var distance = 1; distance <= 3; ++distance)
            for (var direction = 0; direction < 4; ++direction)
                if (legal(board, reserves, start, mandatory, distance, direction))
                    options.push({start: start, distance: distance, direction: direction});
    return options;
}
export function place(board, reserves, player, move) {
    var cells = board.slice(), stock = [reserves[0].slice(), reserves[1].slice()];
    cells[move.start] = {player: player, distance: move.distance, direction: move.direction};
    stock[player - 1][move.distance - 1]--;
    return {cells: cells, reserves: stock, mandatory: destination(move.start, move.distance, move.direction)};
}
