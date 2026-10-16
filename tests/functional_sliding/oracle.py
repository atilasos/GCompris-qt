# SPDX-License-Identifier: GPL-3.0-or-later
"""Independent 4×4 geometry, applied only to visible board observations."""
def slide(board,index):
    empty=board.index(0)
    if not 0<=index<16 or abs(empty//4-index//4)+abs(empty%4-index%4)!=1:raise ValueError('Tile is not adjacent to blank')
    result=board.copy();result[empty],result[index]=result[index],result[empty];return result


def rotate(board,direction,index):
    if direction not in 'LTRB' or not 0<=index<4:raise ValueError('Invalid visible arrow')
    cells=[index*4+i for i in range(4)] if direction in 'LR' else [index+i*4 for i in range(4)]
    result=board.copy();delta=-1 if direction in 'LT' else 1
    for i,cell in enumerate(cells):result[cells[(i+delta)%4]]=board[cell]
    return result


def solved(board,mode):return board==(list(range(1,16))+[0] if mode=='fifteen' else list(range(1,17)))
