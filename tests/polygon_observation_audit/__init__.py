# SPDX-License-Identifier: GPL-3.0-or-later
"""Pure checks of public polygon scene observations, never authored answers."""
import math


def require(condition, message):
    if not condition:
        raise ValueError(message)


def number(value):
    require(isinstance(value, (int, float)) and not isinstance(value, bool)
            and math.isfinite(value), 'Expected finite scene coordinate')
    return value


def observed_vertices(state):
    """Project drawn scene centers onto the visible ten by ten lattice.

    Scene rectangles use center coordinates. The fixed 0.001 lattice tolerance
    covers serialization/Qt projection rounding, not geometric classification.
    Classification receives exact integers after this boundary.
    """
    grid = state['grid']
    gx, gy, width, height = [number(grid[k]) for k in ('x', 'y', 'width', 'height')]
    require(width > 0 and height > 0, 'Positive drawn grid required')
    result = []
    for point in state['points']:
        center = point['sceneCenter']
        x, y = number(center['x']), number(center['y'])
        lattice = ((x-gx+width/2)*10/width, (y-gy+height/2)*10/height)
        snapped = tuple(round(v) for v in lattice)
        require(all(0 <= v <= 10 and abs(v-n) <= .001 for v, n in zip(lattice, snapped)),
                'Point is outside or between visible lattice intersections')
        frame = point['frame']
        require(abs(number(frame['x'])-x) <= .001 and abs(number(frame['y'])-y) <= .001,
                'Point frame and projected center disagree')
        require(number(frame['width']) > 0 and number(frame['height']) > 0
                and number(point['radius']) > 0, 'Point must have drawn area')
        if 'grid' in point:
            require(len(point['grid']) == 2 and all(abs(number(v)-n) <= .001
                    for v, n in zip(point['grid'], snapped)), 'Reported grid differs from scene')
        result.append(snapped)
    require(len(set(result)) == len(result), 'Duplicate drawn vertices')
    return result


def exact_vertices(vertices):
    require(isinstance(vertices, list) and len(vertices) > 0, 'Nonempty candidate required')
    result = []
    for point in vertices:
        require(isinstance(point, (list, tuple)) and len(point) == 2
                and all(isinstance(v, int) and not isinstance(v, bool) and 0 <= v <= 10
                        for v in point), 'Candidate must use exact visible lattice integers')
        result.append(tuple(point))
    require(len(set(result)) == len(result), 'Duplicate candidate vertices')
    return result


def cyclic_equal(a, b):
    if len(a) != len(b):
        return False
    return any(a == sequence[i:]+sequence[:i] for sequence in (b, list(reversed(b)))
               for i in range(len(b)))


def validate_drawing(drawing):
    """Verify every creation step and the boundary drawn after closure."""
    requested = exact_vertices(drawing['requested'])
    require(len(drawing['steps']) == len(requested), 'Missing creation steps')
    for i, step in enumerate(drawing['steps'], 1):
        require(observed_vertices(step) == requested[:i], 'Open creation trace differs from clicks')
    closed = observed_vertices(drawing['closed'])
    require(cyclic_equal(closed, requested), 'Closed boundary differs from requested traversal')
    return closed


from polygon_geometry_oracle import InvalidPolygon, classify

# The visible Portuguese requests define properties, not answer coordinates.
INSTRUCTIONS = {
    'Desenha um polígono.': 'polygon',
    'Desenha um triângulo.': 'triangle',
    'Desenha um triângulo retângulo.': 'right_triangle',
    'Desenha um triângulo isósceles.': 'isosceles_triangle',
    'Desenha um quadrilátero.': 'quadrilateral',
    'Desenha um retângulo.': 'rectangle',
    'Desenha um quadrado.': 'square',
    'Desenha um paralelogramo que não seja um retângulo.': 'nonrectangular_parallelogram',
    'Desenha um losango que não seja um quadrado.': 'nonsquare_rhombus',
}


def property_for(instruction):
    require(instruction in INSTRUCTIONS, 'Unknown public Portuguese instruction')
    return INSTRUCTIONS[instruction]


def has_property(vertices, name):
    try:
        return name in classify(vertices)['properties']
    except InvalidPolygon:
        return False


def check_states(drawing, level, instruction, free=False, screenshots=None):
    vertices = validate_drawing(drawing)
    for state in drawing['steps']+[drawing['closed']]:
        require(state['level'] == level and state['publicLevels'] == (0 if free else 9),
                'Drawing belongs to a different mode or level')
        require(state['instruction'] == ('' if free else instruction), 'Drawn instruction changed')
        if free:
            require(state['okVisible'] is False, 'Free mode must not offer tutorial OK')
        if screenshots is not None:
            require(screenshots(state) is True, 'External snapshot pixel check failed')
    return vertices


def case_evidence(case_result):
    require(case_result['failures'] == 0 and case_result['passes'] > 0, 'Native case did not pass')
    return case_result['evidence']


def feedback(value, level, correct):
    require(value['observed'] is True, 'Natural feedback was not observed')
    before, after = value['before'], value['after']
    for state in (before, after):
        require(all(isinstance(state[k], int) and not isinstance(state[k], bool)
                    and state[k] >= 0 for k in ('wins','losses','level')),
                'Invalid feedback counters')
    require(before['level'] == level, 'Feedback starts at wrong level')
    require(after['wins'] == before['wins']+int(correct)
            and after['losses'] == before['losses']+int(not correct), 'Wrong natural Bonus')
    require(after['level'] == ((level % 9)+1 if correct else level),
            'Wrong natural continuation')


def validate_tutorial(case_result, screenshots=None):
    """Require all nine observed tutorial routes, independent of authored answers.

    Optional screenshots is a pure callback(state) -> True, allowing the caller
    to bind scene pixel checks without this module reading a capsule or Qt.
    Without it, the result proves reported scene geometry, not screenshot pixels.
    """
    evidence = case_evidence(case_result)
    routes = evidence['routes']
    require(len(routes) == 9 and [r['level'] for r in routes] == list(range(1,10)),
            'Exactly nine distinct tutorial levels required')
    require([r['instruction'] for r in routes] == list(INSTRUCTIONS),
            'Nine actual public instructions required in level order')
    previous = {'wins':0, 'losses':0, 'level':1}
    for route in routes:
        level, instruction = route['level'], route['instruction']
        name = property_for(instruction)
        require(len(route['pages']) > 0, 'Missing public introduction')
        wrong = check_states(route['wrong'],level,instruction,screenshots=screenshots)
        require(not has_property(wrong,name), 'Rejected candidate satisfies public request')
        repair = check_states(route['repair'],level,instruction,screenshots=screenshots)
        require(has_property(repair,name), 'Repaired drawn geometry violates public request')
        feedback(route['rejection'],level,False)
        feedback(route['success'],level,True)
        require(route['rejection']['before'] == previous, 'Feedback sequence is discontinuous')
        require(route['success']['before'] == route['rejection']['after'],
                'Repair does not follow rejection')
        for drawing, start in ((route['wrong'],route['rejection']['before']),
                               (route['repair'],route['success']['before'])):
            for state in drawing['steps']+[drawing['closed']]:
                require(state['wins']==start['wins'] and state['losses']==start['losses'],
                        'Progress changed while drawing')
        cleared = route['reload']
        require(not observed_vertices(cleared) and cleared['level']==level
                and cleared['wins']==route['rejection']['after']['wins']
                and cleared['losses']==route['rejection']['after']['losses'],
                'Reload did not clear geometry without progression')
        if screenshots is not None:
            require(screenshots(cleared) is True, 'Reload pixel check failed')
        previous = route['success']['after']
    return {'tutorial_routes':9,'rejections':9,'natural_successes':9,
            'geometry':'exact integer lattice after scene projection',
            'screenshot_pixels_checked':screenshots is not None}


def unchanged_boundary(a, b):
    require(cyclic_equal(a,b), 'Closed geometry changed unexpectedly')


def single_move(before, after, keyboard=False):
    old, new = set(before)-set(after), set(after)-set(before)
    require(len(before)==len(after) and len(old)==len(new)==1, 'Exactly one point must move')
    p,q=next(iter(old)),next(iter(new))
    if keyboard:
        require(abs(p[0]-q[0])+abs(p[1]-q[1])==1, 'Keyboard move must be one lattice step')
    replacement=[q if value==p else value for value in before]
    unchanged_boundary(replacement,after)


def single_delete(before, after):
    require(len(before)==len(after)+1 and set(after)<set(before), 'Exactly one point must be deleted')
    unchanged_boundary([v for v in before if v in set(after)],after)


def validate_controls(case_result, screenshots=None):
    """Validate the finite free-mode and control observations, not all free drawings."""
    evidence=case_evidence(case_result)
    routes=evidence['routes']
    require(len(routes)==9 and [r['instructionReference'] for r in routes]==list(INSTRUCTIONS),
            'Nine distinct free-class examples required')
    checked=[]
    def free_state(state):
        points=observed_vertices(state)
        require(state['publicLevels']==0 and state['instruction']=='' and state['okVisible'] is False,
                'Free editor has artificial tutorial state')
        require(state['wins']==state['losses']==0, 'Free drawing must not produce Bonus')
        if screenshots is not None:
            require(screenshots(state) is True, 'External free snapshot pixel check failed')
        checked.append(state)
        return points
    for route in routes:
        require(route['kind']=='free-class', 'Unexpected free route')
        name=property_for(route['instructionReference'])
        require(route['property']==name, 'Claimed class differs from public reference')
        drawn=check_states(route['drawing'],route['drawing']['closed']['level'],
                           route['instructionReference'],free=True)
        require(has_property(drawn,name), 'Drawn free example violates geometric class')
        for state in route['drawing']['steps']+[route['drawing']['closed']]:
            free_state(state)
    controls=evidence['controls']
    def rows(kind):
        return [row for row in controls if row['kind']==kind]
    def one(kind):
        candidates=rows(kind)
        require(len(candidates)==1,'Exactly one '+kind+' observation required')
        return candidates[0]
    navigation=one('navigation')
    require(navigation['before']==1 and [s['level'] for s in navigation['steps']]==[9,1],
            'Level navigation did not wrap')
    reload=one('partial-reload')
    require(len(observed_vertices(reload['before']))==2 and not observed_vertices(reload['after']),
            'Partial reload did not clear vertices')
    if screenshots is not None:
        for state in (reload['before'],reload['after']):
            require(screenshots(state) is True,'Reload snapshot pixel check failed')
    helps=rows('help')
    require(len(helps)==2 and all(h['title']=='Polígonos' and h['content'] for h in helps),
            'Tutorial/free Portuguese help missing')
    require(one('mode-before')['text']!='Modo Livre', 'Control case must change to free mode')
    require('Modo Livre' in [v['text'] for v in one('mode-offer')['texts']],
            'Free mode was not offered')
    edit=one('mouse-and-keyboard-edit')
    initial=validate_drawing(edit['initial'])
    for state in edit['initial']['steps']+[edit['initial']['closed']]:
        free_state(state)
    after=free_state(edit['closedRefusesNewPoint']);unchanged_boundary(initial,after)
    dragged=free_state(edit['dragged']);single_move(after,dragged)
    deleted=free_state(edit['doubleClickDeleted']);single_delete(dragged,deleted)
    moved=free_state(edit['keyboardMoved']);single_move(deleted,moved,keyboard=True)
    final=free_state(edit['keyboardDeleted']);single_delete(moved,final)
    keyboard=one('keyboard-created-triangle')
    require(len(keyboard['steps'])==3, 'Three keyboard creation steps required')
    previous=[]
    for step in keyboard['steps']:
        points=free_state(step)
        require(len(points)==len(previous)+1 and points[:-1]==previous,
                'Keyboard creation must add one point at a time')
        previous=points
    closed=free_state(keyboard['closed']);unchanged_boundary(previous,closed)
    require(has_property(closed,'triangle'),'Keyboard-created geometry is not a triangle')
    trails=rows('keyboard-cursor')
    require(len(trails)==3 and [row['label'] for row in trails]==['create-0','create-1','create-2'],
            'Keyboard cursor observations for all three targets required')
    for index,route in enumerate(trails):
        trail=[exact_vertices([p['point']])[0] for p in route['trail']]
        require(len(trail)>0 and trail[-1]==previous[index],'Cursor did not reach creation target')
        grid=keyboard['closed']['grid']
        for record,point in zip(route['trail'],trail):
            frame=record['frame']
            projected=((number(frame['x'])-grid['x']+grid['width']/2)*10/grid['width'],
                       (number(frame['y'])-grid['y']+grid['height']/2)*10/grid['height'])
            require(all(abs(v-n)<=.001 for v,n in zip(projected,point)),
                    'Keyboard cursor frame disagrees with claimed lattice position')
        for a,b in zip(trail,trail[1:]):
            require(abs(a[0]-b[0])+abs(a[1]-b[1])==1,
                    'Cursor skipped lattice points without offered keyboard steps')
    require(one('stable-menu')['launchAutoQuitDisabled'] is True, 'Stable menu observation missing')
    return {'free_routes':9,'mouse_moves':1,'mouse_deletes':1,'keyboard_moves':1,
            'keyboard_deletes':1,'keyboard_created_triangles':1,
            'observed_free_snapshots':len(checked),'screenshot_pixels_checked':screenshots is not None}
