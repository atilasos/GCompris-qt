# SPDX-License-Identifier: GPL-3.0-or-later
import copy
import unittest
from polygon_observation_audit import observed_vertices


def snapshot(vertices):
    return {'grid': {'x': 400, 'y': 350, 'width': 600, 'height': 600},
            'points': [{'sceneCenter': {'x': 100+x*60, 'y': 50+y*60},
                        'frame': {'x': 100+x*60, 'y': 50+y*60, 'width': 60, 'height': 60},
                        'radius': 60, 'grid': [x, y]} for x, y in vertices]}


class Observation(unittest.TestCase):
    def test_projects_scene_centers_instead_of_trusting_grid_field(self):
        value = snapshot([[2, 2], [7, 2], [4, 7]])
        self.assertEqual(observed_vertices(value), [(2, 2), (7, 2), (4, 7)])
        forged = copy.deepcopy(value)
        forged['points'][0]['sceneCenter']['x'] += 60
        with self.assertRaises(ValueError):
            observed_vertices(forged)

class Drawing(unittest.TestCase):
    def test_closed_boundary_accepts_rotation_and_reversal_but_not_sorted_crossing(self):
        from polygon_observation_audit import validate_drawing
        points = [[2, 2], [7, 2], [7, 7], [2, 7]]
        value = {'requested': points, 'steps': [snapshot(points[:i]) for i in range(1, 5)],
                 'closed': snapshot(points[2:]+points[:2])}
        self.assertEqual(validate_drawing(value), [(7, 7), (2, 7), (2, 2), (7, 2)])
        value['closed'] = snapshot(list(reversed(points)))
        validate_drawing(value)
        value['closed'] = snapshot([points[i] for i in [0, 2, 1, 3]])
        with self.assertRaises(ValueError):
            validate_drawing(value)

INSTRUCTIONS = [
 'Desenha um polígono.', 'Desenha um triângulo.', 'Desenha um triângulo retângulo.',
 'Desenha um triângulo isósceles.', 'Desenha um quadrilátero.', 'Desenha um retângulo.',
 'Desenha um quadrado.', 'Desenha um paralelogramo que não seja um retângulo.',
 'Desenha um losango que não seja um quadrado.']
SHAPES = [
 [[1,2],[6,1],[8,4],[6,7],[2,8]], [[1,1],[8,2],[3,8]], [[2,2],[8,2],[2,7]],
 [[2,2],[8,2],[5,7]], [[1,2],[8,2],[7,7],[2,7]], [[2,2],[8,2],[8,6],[2,6]],
 [[2,2],[7,2],[7,7],[2,7]], [[1,2],[5,2],[7,6],[3,6]], [[2,4],[4,1],[6,4],[4,7]]]


def drawing(vertices, level=1, free=False):
    def state(v):
        row = snapshot(v)
        row.update(level=level, publicLevels=0 if free else 9,
                   instruction='' if free else INSTRUCTIONS[level-1],
                   wins=0, losses=0, okVisible=not free)
        return row
    return {'requested': vertices, 'steps': [state(vertices[:i]) for i in range(1,len(vertices)+1)],
            'closed': state(vertices[1:]+vertices[:1])}


def tutorial():
    routes = []
    for level, shape in enumerate(SHAPES, 1):
        before = {'wins': level-1, 'losses': level-1, 'level': level}
        rejected = dict(before, losses=level)
        after = dict(rejected, wins=level, level=1 if level==9 else level+1)
        wrong, repair = drawing([[2,4],[5,4],[8,4]],level), drawing(shape,level)
        for state in wrong['steps']+[wrong['closed']]:
            state.update(wins=level-1, losses=level-1)
        for state in repair['steps']+[repair['closed']]:
            state.update(wins=level-1, losses=level)
        cleared = snapshot([])
        cleared.update(level=level,publicLevels=9,instruction=INSTRUCTIONS[level-1],
                       wins=level-1,losses=level,okVisible=False)
        routes.append({'level':level,'instruction':INSTRUCTIONS[level-1], 'pages':[{}],
                       'wrong':wrong,'repair':repair,'reload':cleared,
                       'rejection':{'before':before,'after':rejected,'observed':True},
                       'success':{'before':rejected,'after':after,'observed':True}})
    return {'failures':0,'passes':1,'evidence':{'routes':routes,'controls':[]}}


class Tutorial(unittest.TestCase):
    def test_nine_classes_and_natural_wrong_repair_feedback(self):
        from polygon_observation_audit import validate_tutorial
        case = tutorial()
        self.assertEqual(validate_tutorial(case)['tutorial_routes'],9)
        for mutation in ['geometry','feedback','instruction','missing','failure']:
            bad = copy.deepcopy(case)
            if mutation=='geometry':
                bad['evidence']['routes'][6]['repair'] = drawing(SHAPES[5],7)
            elif mutation=='feedback':
                bad['evidence']['routes'][0]['success']['after']['level']=1
            elif mutation=='instruction':
                bad['evidence']['routes'][0]['instruction']='Find a polygon.'
            elif mutation=='missing':
                bad['evidence']['routes'].pop()
            else:
                bad['failures']=1
            with self.subTest(mutation=mutation), self.assertRaises(ValueError):
                validate_tutorial(bad)


def controls():
    routes=[]
    for instruction, shape in zip(INSTRUCTIONS,SHAPES):
        routes.append({'kind':'free-class','instructionReference':instruction,
                       'property':None,'drawing':drawing(shape,free=True)})
    from polygon_observation_audit import INSTRUCTIONS as mapping
    for route in routes:
        route['property']=mapping[route['instructionReference']]
    def state(vertices):
        value=snapshot(vertices)
        value.update(level=1,publicLevels=0,instruction='',wins=0,losses=0,okVisible=False)
        return value
    base=SHAPES[0]
    dragged=[base[0],[7,2],*base[2:]]
    deleted=[dragged[0],dragged[1],*dragged[3:]]
    moved=[[2,2],*deleted[1:]]
    keyboard_deleted=moved[1:]
    triangle=[[2,2],[7,2],[4,7]]
    return {'failures':0,'passes':1,'evidence':{'routes':routes,'controls':[
        {'kind':'navigation','before':1,'steps':[{'level':9},{'level':1}]},
        {'kind':'partial-reload','before':snapshot([[2,2],[7,2]]),'after':snapshot([])},
        {'kind':'help','title':'Polígonos','content':'Desenha polígonos.'},
        {'kind':'help','title':'Polígonos','content':'Desenha polígonos.'},
        {'kind':'mode-before','text':'Modo Tutorial'},
        {'kind':'mode-offer','texts':[{'text':'Modo Livre'}]},
        {'kind':'mouse-and-keyboard-edit','initial':drawing(base,free=True),
         'closedRefusesNewPoint':state(base),'dragged':state(dragged),
         'doubleClickDeleted':state(deleted),'keyboardMoved':state(moved),
         'keyboardDeleted':state(keyboard_deleted)},
        {'kind':'keyboard-created-triangle','steps':[state(triangle[:i]) for i in range(1,4)],
         'closed':state(triangle[1:]+triangle[:1])},
        *[{'kind':'keyboard-cursor','label':'create-'+str(i),
           'trail':[{'point':[p[0]-1,p[1]],'frame':snapshot([[p[0]-1,p[1]]])['points'][0]['frame']},
                    {'point':p,'frame':snapshot([p])['points'][0]['frame']}]}
          for i,p in enumerate(triangle)],
        {'kind':'stable-menu','launchAutoQuitDisabled':True}]}}


class Controls(unittest.TestCase):
    def test_finite_free_geometry_editing_and_keyboard_creation(self):
        from polygon_observation_audit import validate_controls
        case=controls()
        self.assertEqual(validate_controls(case)['free_routes'],9)
        for mutation in ['bonus','duplicate','no-delete','bad-keyboard','hidden-ok']:
            bad=copy.deepcopy(case)
            if mutation=='bonus':
                bad['evidence']['routes'][0]['drawing']['closed']['wins']=1
            elif mutation=='duplicate':
                bad['evidence']['routes'][-1]=copy.deepcopy(bad['evidence']['routes'][0])
            elif mutation=='no-delete':
                edit=bad['evidence']['controls'][6]
                edit['doubleClickDeleted']=copy.deepcopy(edit['dragged'])
            elif mutation=='bad-keyboard':
                bad['evidence']['controls'][8]['trail'][1]['point']=[5,2]
            else:
                bad['evidence']['routes'][0]['drawing']['closed']['okVisible']=True
            with self.subTest(mutation=mutation),self.assertRaises(ValueError):
                validate_controls(bad)

class Classes(unittest.TestCase):
    def test_keyboard_trace_requires_each_creation_target(self):
        from polygon_observation_audit import validate_controls
        case=controls()
        case['evidence']['controls'].pop(9)
        with self.assertRaises(ValueError):
            validate_controls(case)

    def test_inclusive_classes_accept_square_as_rectangle_but_honor_exclusions(self):
        from polygon_observation_audit import validate_tutorial
        case=tutorial()
        route=case['evidence']['routes'][5]
        route['repair']=drawing(SHAPES[6],6)
        for state in route['repair']['steps']+[route['repair']['closed']]:
            state.update(wins=5,losses=6)
        validate_tutorial(case)
        bad=copy.deepcopy(case)
        route=bad['evidence']['routes'][7]
        route['repair']=drawing(SHAPES[5],8)
        for state in route['repair']['steps']+[route['repair']['closed']]:
            state.update(wins=7,losses=8)
        with self.assertRaises(ValueError):
            validate_tutorial(bad)

    def test_geometrically_correct_wrong_candidate_is_not_rejection_proof(self):
        from polygon_observation_audit import validate_tutorial
        case=tutorial()
        case['evidence']['routes'][0]['wrong']=drawing(SHAPES[0],1)
        with self.assertRaises(ValueError):
            validate_tutorial(case)

class Boundaries(unittest.TestCase):
    def test_projection_rejects_nan_off_grid_duplicate_and_forged_frames(self):
        for mutation in ['nan','off-grid','duplicate','frame']:
            value=snapshot([[2,2],[7,2],[4,7]])
            if mutation=='nan':
                value['points'][0]['sceneCenter']['x']=float('nan')
            elif mutation=='off-grid':
                value['points'][0]['sceneCenter']['x']+=3
            elif mutation=='duplicate':
                value['points'][1]=copy.deepcopy(value['points'][0])
            else:
                value['points'][0]['frame']['x']+=60
            with self.subTest(mutation=mutation),self.assertRaises(ValueError):
                observed_vertices(value)

    def test_optional_pixel_checker_is_called_and_can_reject(self):
        from polygon_observation_audit import validate_tutorial
        seen=[]
        result=validate_tutorial(tutorial(),lambda state: seen.append(state) is None)
        self.assertTrue(result['screenshot_pixels_checked'])
        # 9 wrong traces x 4 + 34 repaired clicks + 9 closures + 9 reloads.
        self.assertEqual(len(seen),88)
        with self.assertRaises(ValueError):
            validate_tutorial(tutorial(),lambda state: False)
