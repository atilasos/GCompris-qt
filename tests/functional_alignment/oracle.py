# SPDX-License-Identifier: GPL-3.0-or-later
"""Geometric alignment and gravity, independent of either activity engine."""
from functools import cache

def outcome(board,columns,rows,length):
    if len(board)!=columns*rows or any(value not in [0,1,2] for value in board):raise ValueError('Invalid board')
    winners=set()
    for y in range(rows):
        for x in range(columns):
            for dx,dy in [(1,0),(0,1),(1,1),(1,-1)]:
                if not (0<=x+(length-1)*dx<columns and 0<=y+(length-1)*dy<rows):continue
                cells=[board[(y+i*dy)*columns+x+i*dx] for i in range(length)]
                if cells[0] and len(set(cells))==1:winners.add(cells[0])
    if len(winners)>1:raise ValueError('Both players cannot win in a legal finished game')
    return next(iter(winners)) if winners else None if 0 in board else 0


def play(board,location,player,columns,rows,gravity):
    if player not in [1,2]:raise ValueError('Invalid player')
    if gravity:
        if not 0<=location<columns:raise ValueError('Invalid column')
        possible=[row*columns+location for row in reversed(range(rows)) if board[row*columns+location]==0]
        if not possible:raise ValueError('Full column')
        cell=possible[0]
    else:
        cell=location
        if not 0<=cell<len(board) or board[cell]:raise ValueError('Occupied square')
    result=board.copy();result[cell]=player;return result


def draw_route():
    """Construct a public 42-move draw from a literal no-line target pattern."""
    target=[[1,1,2,2,1,1,2],[2,2,1,1,2,2,1]]*3
    assert outcome([value for row in target for value in row],7,6,4)==0
    @cache
    def search(heights):
        if sum(heights)==42:return ()
        player=1+sum(heights)%2
        for column,height in enumerate(heights):
            if height==6 or target[5-height][column]!=player:continue
            updated=list(heights);updated[column]+=1;rest=search(tuple(updated))
            if rest is not None:return (column,*rest)
        return None
    route=search((0,)*7)
    if route is None:raise ValueError('Draw target has no legal interleaving')
    return list(route)
