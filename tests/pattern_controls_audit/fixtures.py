# SPDX-License-Identifier: GPL-3.0-or-later
"""Worked literal UI observations; no production planner or validator is called."""
from copy import deepcopy as cp

RED = ['#33ffffff','#000000','#ff0000','#00ff00','#0000ff','#ffff00','#00ffff']
PHOTO = ['rgba160-sha256:'+digit*64 for digit in '012345678']
QXY = [(5,5),(15,5),(5,15),(15,15)]
AXY = [(105,105),(125,105),(105,125),(125,125)]


def frame(x,y,width=20,height=20):
    return {'x':x,'y':y,'width':width,'height':height,'visible':True,'opacity':1}


def event(value):
    return {'frame':cp(value),'click':{'x':value['x'],'y':value['y']}}


def result(activity='redraw'):
    mosaic=activity=='mosaic';s=PHOTO if mosaic else RED
    ids={i:'qrc:/gcompris/public/'+name+'.svg' for i,name in enumerate(['empty','ibis','cedar','opal','moss','kite','oak','fern','leaf'])}
    palette=[{'id':ids[i],'signature':s[i],'frame':frame(50,20+12*i,8,8)}
             for i in (range(1,9) if mosaic else range(7))]
    def sample(index):return cp(next(p for p in palette if p['signature']==s[index]))
    def row(index,paint=0,question=False):
        x,y=(QXY if question else AXY)[index]
        value={'frame':frame(x,y,10 if question else 20,10 if question else 20),'signature':s[paint]}
        if mosaic:value.update(source=ids[paint],status=1)
        else:value['color']=s[paint]
        return value
    def state(paints=(0,0,0,0)):return [row(i,p) for i,p in enumerate(paints)]
    question=[row(i,p,True) for i,p in enumerate([1,2,3,4] if mosaic else [1,2,3,0])]
    target_indices=[1,0,3,2] if activity=='redraw_symmetrical' else [0,1,2,3]
    placements=[{'question_frame':cp(question[i]['frame']),'target_frame':cp(state()[j]['frame']),
                 'signature':question[i]['signature'],'palette_id':ids[([1,2,3,4] if mosaic else [1,2,3,0])[i]]}
                for i,j in enumerate(target_indices)]
    plan={'rows':2,'columns':2,'placements':placements}
    def pointer(index,before,after,role):
        paint=sample(after);f=state()[index]['frame']
        return {'role':role,'target':cp(f),'expected_signature':s[after],'palette':paint,
                'selection':{'x':paint['frame']['x'],'y':paint['frame']['y']},
                'click':{'x':f['x'],'y':f['y']},'before':row(index,before),'after':row(index,after)}
    def cursor(index):
        f=cp(state()[index]['frame'])
        if mosaic:f.update(x=f['x']+0.5,y=f['y']+0.5,width=25,height=25)
        return f
    arrows=[{'key':name,'before':cursor(a),'after':cursor(b)} for name,a,b in
            [('Right',0,1),('Left',1,0),('Down',0,2),('Up',2,0)]]
    def keyboard(label):
        k={'label':label,'before':state(),'arrows':cp(arrows),'actions':[]}
        if mosaic:
            for name,before,after in [('Space',0,2),('Return',2,3),('Enter',3,4)]:
                k['actions'].append({'key':name,'selected':sample(after),'before':row(0,before),
                                     'after':row(0,after),'expected_question_signature':s[1]})
            k['after']=state((4,0,0,0))
        else:
            offered=[{'digit':str(i),'frame':cp(sample(i)['frame']),'palette':sample(i)} for i in range(7)]
            k.update(offeredDigits=offered,selectedDigit=cp(offered[1]),digits=[])
            k['actions'].append(pointer(0,0,1,'numeric-shortcut-seed'))
            for i in range(7):
                k['digits'].append({'shortcut':cp(offered[i]),'before':row(0,1 if i==0 else i-1),'after':row(0,i)})
            for name,remove in [('Space','Delete'),('Return','Backspace'),('Enter','Delete')]:
                k['actions'].append({'key':name,'before':row(0,0),'after':row(0,1),'signature':s[1]})
                k['actions'].append({'key':remove,'after':row(0,0),'expected_blank':s[0]})
            k['after']=state()
        return k
    total={'redraw':38,'redraw_symmetrical':21,'mosaic':22}[activity]
    level={'redraw':15,'redraw_symmetrical':20,'mosaic':7}[activity]
    initial={'level':level,'total':total,'question':cp(question),'answer':state(),'palette':cp(palette)}
    search=[{'level':i,'rows':1 if mosaic else 2,'columns':2,'palette':cp(palette[:2])} for i in range(1,level)]
    search.append({'level':level,'rows':2,'columns':2,'palette':cp(palette)})
    def nav(before,after):return {'before':before,'after':after,'total':total,'event':event(frame(600,450,30,30))}
    drag=None
    if not mosaic:
        guard_paint=1 if activity=='redraw_symmetrical' else 0
        guard=pointer(2,0,guard_paint,'drag-guard')
        drag={'actions':[cp(guard)],'before':state(),'guard':guard,'selection':event(sample(1)['frame']),
              'drag':{'from':cp(state()[0]['frame']),'to':cp(state()[1]['frame']),'signature':s[1],
                      'before':[row(0),row(1)],'after':[row(0,1),row(1,1)]},
              'after':state((1,1,guard_paint,0))}
    before_restart=state((4,0,0,0)) if mosaic else cp(drag['after'])
    restart={'method':'offered next/previous level controls','before':before_restart,
             'next':nav(level-1,level),'previous':nav(level,level-1),
             'after':state(),'initial_blank':s[0],'questionAfter':cp(question)}
    title={'redraw':'Voltar a desenhar a imagem atual','redraw_symmetrical':'Espelho da imagem indicada','mosaic':'Reconstruir o mosaico'}[activity]
    manual='<b>Controlos do teclado:</b> Espaço e Enter para pintar.'
    help_view={'opened':event(frame(40,450,30,30)),'title':title,'content':manual,'manual':manual,'depth':3,'closedDepth':2}
    labels=['Grelha pequena','Grelha média','Grelha grande','Grelha extra'][:4 if mosaic else 3]
    levels={'redraw':[8,12,18],'redraw_symmetrical':[5,7,9],'mosaic':[4,4,6,8]}[activity]
    datasets=[]
    for i,label in enumerate(labels):
        datasets.append({'labels':[{'text':text,'checked':j==i,'frame':frame(400,100+40*j,200,30)} for j,text in enumerate(labels)],
                         'save':event(frame(600,450,80,30)),'levels':levels[i],'currentLevel':0,
                         'question':cp(question),'answer':state(),'palette':cp(palette)})
    index=target_indices[0];edit=pointer(index,0,2,'partial-before-menu');paints=[0]*4;paints[index]=2
    partial={'actions':[cp(edit)],'question':cp(question),'answerBefore':state(),'plan':plan,'palette':cp(palette),
             'edit':edit,'answerAfter':state(paints)}
    keys=[]
    for phase in range(2):
        keys.extend(['Right','Left','Down','Up'])
        if mosaic:
            keys.append('Right to expose keyboard cursor')
            for name in ['Space','Return','Enter']:
                keys.extend(['Tab to selector',name+' select image','Tab to answer',name+' paint target'])
        else:
            for i in range(7):keys.extend(['Digit '+str(i),'Space after digit '+str(i)])
            keys.extend(['Delete after numeric shortcuts','Digit 1','Space','Delete','Return','Backspace','Enter','Delete'])
        if phase==0:keys.append('Escape close help')
    evidence={'keys':keys,'levelSearch':search,'configScroll':[],'initial':initial,
              'keyboardBeforeHelp':keyboard('before-help'),'keyboardAfterHelp':keyboard('after-help'),
              'restart':restart,'help':help_view,'datasets':datasets,'partialBeforeMenu':partial,
              'home':event(frame(80,450,30,30)),
              'menuDuringActivity':{'depth':1,'busy':False,'isMenu':True}}
    if drag:evidence['drag']=drag
    return {'failures':0,'passes':2,'activity':activity,'wins':0,
            'pointerPaintActions':1 if mosaic else 4,'evidence':evidence,
            'scope':'Literal worked controls example; no native execution'}
