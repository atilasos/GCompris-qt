// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 id:qa
 name:'PolygonTutorialControlsAndFiniteFreeModeBehaviours'
 when:activity.visible&&activity.numberOfLevel>0
 property int wins: 0
 property int losses: 0
 property var evidence: ({routes:[],controls:[]})
 property var proposals: [{"instruction":"Desenha um polígono.","property":"polygon","vertices":[[1,2],[6,1],[8,4],[6,7],[2,8]]},{"instruction":"Desenha um triângulo.","property":"triangle","vertices":[[1,1],[8,2],[3,8]]},{"instruction":"Desenha um triângulo retângulo.","property":"right_triangle","vertices":[[2,2],[8,2],[2,7]]},{"instruction":"Desenha um triângulo isósceles.","property":"isosceles_triangle","vertices":[[2,2],[8,2],[5,7]]},{"instruction":"Desenha um quadrilátero.","property":"quadrilateral","vertices":[[1,2],[8,2],[7,7],[2,7]]},{"instruction":"Desenha um retângulo.","property":"rectangle","vertices":[[2,2],[8,2],[8,6],[2,6]]},{"instruction":"Desenha um quadrado.","property":"square","vertices":[[2,2],[7,2],[7,7],[2,7]]},{"instruction":"Desenha um paralelogramo que não seja um retângulo.","property":"nonrectangular_parallelogram","vertices":[[1,2],[5,2],[7,6],[3,6]]},{"instruction":"Desenha um losango que não seja um quadrado.","property":"nonsquare_rhombus","vertices":[[2,4],[4,1],[6,4],[4,7]]}]
 Connections {
  target: bonus
  function onWin() {qa.wins++;}
  function onLoose() {qa.losses++;}
 }
 function all(root) {
  var result=[];
  if(!root)return result;
  result.push(root);
  if(root.children)for(var child of root.children)result=result.concat(all(child));
  return result;
 }
 function drawn(o) {
  if(!o||o.width<=0||o.height<=0)return false;
  for(var a=o;a;a=a.parent)if(a.visible===false||a.opacity===0)return false;
  var p=o.mapToItem(pageView,o.width/2,o.height/2);
  if(p.x<0||p.y<0||p.x>=pageView.width||p.y>=pageView.height)return false;
  for(var ancestor=o.parent;ancestor&&ancestor!==pageView;ancestor=ancestor.parent)if(ancestor.clip){
   var local=o.mapToItem(ancestor,o.width/2,o.height/2);
   if(local.x<0||local.y<0||local.x>=ancestor.width||local.y>=ancestor.height)return false;
  }
  return true;
 }
 function pose(o) {
  var p=o.mapToItem(pageView,o.width/2,o.height/2);
  return {x:p.x,y:p.y,width:o.width,height:o.height};
 }
 function shot(name) {grabImage(pageView).save('__QA_OUTPUT__/'+name+'.png');}
 function one(root,predicate) {
  var choices=all(root).filter(function(o){return drawn(o)&&predicate(o);});
  verify(choices.length>0,'Rendered control exists');
  return choices[0];
 }
 function click(o) {
  verify(drawn(o),'Click is in rendered scene');
  var p=pose(o);mouseClick(pageView,p.x,p.y);wait(220);
 }
 function icon(name) {
  click(one(bar,function(o){return o.source!==undefined&&String(o.source).endsWith('/'+name);}));
  wait(1900);
 }
 function button(root,label) {
  click(one(root,function(o){return o.clicked!==undefined&&o.text!==undefined&&String(o.text)===label;}));
 }
 function texts(root) {
  return all(root).filter(function(o){return drawn(o)&&o.font!==undefined&&o.text!==undefined&&String(o.text).length>0;}).map(function(o){return {text:String(o.text),frame:pose(o)};});
 }
 function instruction() {
  verify(drawn(instructionPanel.textItem),'Question is actually drawn');
  return String(instructionPanel.textItem.text);
 }
 function introductions(label) {
  var pages=[];
  for(var page=0;tutorialInstruction.visible&&page<15;page++) {
   pages.push({texts:texts(tutorialInstruction),illustration:String(tutorialImage.source)});
   shot(label+'-intro-'+page);
   var following=all(tutorialInstruction).filter(function(o){return drawn(o)&&o.clicked!==undefined&&o.text!==undefined&&String(o.text)==='Seguinte';});
   if(following.length)click(following[0]);else button(tutorialInstruction,'Iniciar');
   wait(500);
  }
  verify(!tutorialInstruction.visible,'Finite intro completed by real controls');
  return pages;
 }
 function snapshot(label) {
  var points=all(canvasContainer).filter(function(o){return drawn(o)&&o.centerX!==undefined&&o.centerY!==undefined&&o.radius!==undefined;}).map(function(o){
   var center=o.mapToItem(pageView,o.width/2,o.height/2);
   return {centerX:o.centerX,centerY:o.centerY,radius:o.radius,frame:pose(o),color:String(o.color),opacity:o.opacity,grid:[o.centerX/o.radius,o.centerY/o.radius],sceneCenter:{x:center.x,y:center.y}};
  });
  var row={label:label,level:bar.level,publicLevels:activity.numberOfLevel,instruction:instructionPanel.visible?String(instructionPanel.textItem.text):'',grid:pose(sceneGrid),points:points,okVisible:drawn(okButton),wins:wins,losses:losses};
  shot(label);return row;
 }
 function pointKey(p) {return Math.round(p[0]*1000)+','+Math.round(p[1]*1000);}
 function keys(points) {return points.map(pointKey).sort();}
 function assertPoints(record,expected) {
  var observed=record.points.map(function(p){return p.grid;});
  compare(JSON.stringify(keys(observed)),JSON.stringify(keys(expected)),'Rendered vertex geometry matches actual UI input');
  for(var p of record.points)verify(p.radius>0&&Math.abs(p.grid[0]-Math.round(p.grid[0]))<.001&&Math.abs(p.grid[1]-Math.round(p.grid[1]))<.001,'Point is drawn on the visible lattice');
 }
 function gridClick(point) {
  verify(point[0]>=0&&point[0]<=10&&point[1]>=0&&point[1]<=10);
  mouseClick(sceneGrid,sceneGrid.width*point[0]/10,sceneGrid.height*point[1]/10);wait(250);
 }
 function draw(vertices,label) {
  var trace=[];
  for(var i=0;i<vertices.length;i++) {
   gridClick(vertices[i]);var state=snapshot(label+'-point-'+i);
   assertPoints(state,vertices.slice(0,i+1));trace.push(state);
  }
  gridClick(vertices[0]);wait(300);var closed=snapshot(label+'-closed');
  assertPoints(closed,vertices);
  return {requested:JSON.parse(JSON.stringify(vertices)),steps:trace,closed:closed};
 }
 function submit(label,good,input) {
  var before={wins:wins,losses:losses,level:bar.level};
  verify(drawn(okButton)&&okButton.enabled,'Drawn OK accepts a real click');
  if(input==='key')keyClick(Qt.Key_Return);else click(okButton);shot(label+'-reaction');
  var observed=false;
  for(var tick=0;tick<150;tick++) {
   if(wins!==before.wins||losses!==before.losses||bar.level!==before.level){observed=true;break;}
   wait(100);
  }
  var result={before:before,after:{wins:wins,losses:losses,level:bar.level},observed:observed};
  evidence.controls.push({kind:'submit',label:label,outcome:result});shot(label+'-after-feedback');
  verify(observed,'Natural Bonus feedback completed, no timer changes');
  if(good) {
   compare(wins,before.wins+1,'Natural successful Bonus');compare(losses,before.losses);
   compare(bar.level,before.level===9?1:before.level+1,'Natural continuation');
  } else {
   compare(wins,before.wins,'No successful Bonus for rejected geometry');
   compare(losses,before.losses+1,'Natural rejection feedback');compare(bar.level,before.level,'No progression for rejected geometry');
   wait(1000);compare(bar.level,before.level);compare(wins,before.wins);
  }
  return result;
 }
 function reload(label) {icon('bar_reload.svg');var state=snapshot(label);assertPoints(state,[]);return state;}
 function finish() {
  if(qtest_results.failCount)shot('failure-scene');
  console.log('NATIVE_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));
 }
 function helpAndEscape(label) {
  var depth=pageView.depth;
  icon('bar_help.svg');tryCompare(pageView,'depth',depth+1);
  evidence.controls.push({kind:'help',title:String(pageView.currentItem.title),content:String(pageView.currentItem.content)});
  compare(String(pageView.currentItem.title),'Polígonos');shot(label+'-help');
  keyClick(Qt.Key_Escape);tryCompare(pageView,'depth',depth);wait(1900);
  activity.Window.window.requestActivate();wait(300);shot(label+'-help-return');
 }
 function homeAfterWork(label) {
  // Harness launch configuration only. It prevents --launch quitting at Home.
  // No activity progress or game state is changed here.
  ActivityInfoTree.startingActivity='';
  icon('bar_home.svg');tryCompare(pageView,'depth',1);verify(pageView.currentItem.isMenu);
  wait(1500);verify(pageView.currentItem.isMenu);shot(label);
  evidence.controls.push({kind:'stable-menu',launchAutoQuitDisabled:true});
 }

 function combo() {
  return one(dialogActivityConfig,function(o){return o.currentText!==undefined&&o.currentIndex!==undefined&&o.label!==undefined&&String(o.label)==='Selecionar o modo';});
 }
 function chooseFree() {
  icon('bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true);wait(700);
  var mode=combo();evidence.controls.push({kind:'mode-before',text:String(mode.currentText)});
  click(one(mode,function(o){return o.font!==undefined&&o.text!==undefined&&String(o.text)===String(mode.currentText);}));wait(700);
  evidence.controls.push({kind:'mode-offer',texts:texts(dialogActivityConfig)});shot('mode-offer');
  click(one(dialogActivityConfig,function(o){return o.font!==undefined&&o.text!==undefined&&String(o.text)==='Modo Livre';}));wait(700);
  compare(String(mode.currentText),'Modo Livre');button(dialogActivityConfig,'Gravar');tryCompare(dialogActivityConfig,'visible',false);wait(1900);
  compare(activity.numberOfLevel,0,'Free mode has no artificial levels');verify(!drawn(okButton));
  icon('bar_activity_config.svg');tryCompare(dialogActivityConfig,'visible',true);wait(700);
  compare(String(combo().currentText),'Modo Livre');shot('mode-persisted');button(dialogActivityConfig,'Cancelar');tryCompare(dialogActivityConfig,'visible',false);wait(1900);
 }
 function renderedPoint(at) {
  return one(canvasContainer,function(o){return o.centerX!==undefined&&o.centerY!==undefined&&o.radius!==undefined&&pointKey([o.centerX/o.radius,o.centerY/o.radius])===pointKey(at);});
 }
 function dragPoint(before,after) {
  var target=renderedPoint(before),start=pose(target),end=sceneGrid.mapToItem(pageView,sceneGrid.width*after[0]/10,sceneGrid.height*after[1]/10);
  mousePress(pageView,start.x,start.y);
  for(var step=1;step<=10;step++)mouseMove(pageView,start.x+(end.x-start.x)*step/10,start.y+(end.y-start.y)*step/10,30,Qt.LeftButton);
  mouseRelease(pageView,end.x,end.y);wait(400);
 }
 function cursorAt(o) {
  var p=o.mapToItem(sceneGrid,o.width/2,o.height/2);
  return [Math.round(10*p.x/sceneGrid.width),Math.round(10*p.y/sceneGrid.height)];
 }
 function moveKeyboard(target,label) {
  if(drawn(selectedPointCursor)){keyClick(Qt.Key_Space);wait(200);verify(!drawn(selectedPointCursor));}
  var trail=[];
  for(var step=0;step<40;step++) {
   var p=cursorAt(keyboardCursor);trail.push({point:p,frame:pose(keyboardCursor)});
   if(pointKey(p)===pointKey(target))break;
   keyClick(p[0]!==target[0]?(p[0]<target[0]?Qt.Key_Right:Qt.Key_Left):(p[1]<target[1]?Qt.Key_Down:Qt.Key_Up));wait(120);
  }
  compare(pointKey(cursorAt(keyboardCursor)),pointKey(target));
  evidence.controls.push({kind:'keyboard-cursor',label:label,trail:trail});
 }
 function run_controls_and_free() {
  wait(1500);activity.Window.window.requestActivate();wait(300);
  compare(activity.numberOfLevel,9);introductions('controls-initial');
  var initial={kind:'navigation',before:bar.level,steps:[]};
  icon('bar_previous.svg');compare(bar.level,9);initial.steps.push({level:bar.level,pages:introductions('controls-previous-wrap')});
  icon('bar_next.svg');compare(bar.level,1);initial.steps.push({level:bar.level,pages:introductions('controls-next-wrap')});evidence.controls.push(initial);
  gridClick([2,2]);gridClick([7,2]);var partial=snapshot('partial-before-reload');assertPoints(partial,[[2,2],[7,2]]);
  evidence.controls.push({kind:'partial-reload',before:partial,after:reload('partial-after-reload')});
  helpAndEscape('tutorial-controls');chooseFree();
  var baseline={wins:wins,losses:losses};
  for(var i=0;i<proposals.length;i++) {
   reload('free-'+i+'-blank');var route={kind:'free-class',instructionReference:proposals[i].instruction,property:proposals[i].property};evidence.routes.push(route);
   route.drawing=draw(proposals[i].vertices,'free-'+i);verify(!drawn(okButton));wait(700);
   compare(wins,baseline.wins);compare(losses,baseline.losses);
  }
  reload('mouse-edit-blank');var expected=proposals[0].vertices.map(function(p){return p.slice();});
  var editing={kind:'mouse-and-keyboard-edit',initial:draw(expected,'mouse-edit')};evidence.controls.push(editing);
  gridClick([9,9]);editing.closedRefusesNewPoint=snapshot('closed-no-new-point');assertPoints(editing.closedRefusesNewPoint,expected);
  dragPoint([6,1],[7,2]);expected[1]=[7,2];editing.dragged=snapshot('dragged-point');assertPoints(editing.dragged,expected);
  var remove=pose(renderedPoint([8,4]));mouseDoubleClickSequence(pageView,remove.x,remove.y);wait(350);expected=expected.filter(function(p){return pointKey(p)!==pointKey([8,4]);});
  editing.doubleClickDeleted=snapshot('double-click-deleted');assertPoints(editing.doubleClickDeleted,expected);
  for(var tab=0;tab<3&&!drawn(selectedPointCursor);tab++){keyClick(Qt.Key_Tab);wait(250);}
  verify(drawn(selectedPointCursor),'Selection ring is actually visible');var selected=cursorAt(selectedPointCursor),moved=[selected[0]+(selected[0]>=8?-1:1),selected[1]];
  verify(keys(expected).indexOf(pointKey(selected))>=0);keyClick(selected[0]>=8?Qt.Key_Left:Qt.Key_Right);wait(300);
  expected=expected.map(function(p){return pointKey(p)===pointKey(selected)?moved:p;});editing.keyboardMoved=snapshot('keyboard-moved');assertPoints(editing.keyboardMoved,expected);
  keyClick(Qt.Key_Delete);wait(300);expected=expected.filter(function(p){return pointKey(p)!==pointKey(moved);});editing.keyboardDeleted=snapshot('keyboard-deleted');assertPoints(editing.keyboardDeleted,expected);
  reload('keyboard-create-blank');keyClick(Qt.Key_Right);wait(250);verify(drawn(keyboardCursor));
  var triangle=[[2,2],[7,2],[4,7]],steps=[];
  for(var vertex=0;vertex<triangle.length;vertex++) {
   moveKeyboard(triangle[vertex],'create-'+vertex);keyClick(Qt.Key_Return);wait(300);
   var state=snapshot('keyboard-create-'+vertex);assertPoints(state,triangle.slice(0,vertex+1));steps.push(state);
  }
  gridClick(triangle[0]);var closed=snapshot('keyboard-triangle-closed');assertPoints(closed,triangle);
  evidence.controls.push({kind:'keyboard-created-triangle',steps:steps,closed:closed});
  helpAndEscape('free-controls');var afterHelp=snapshot('free-after-help');assertPoints(afterHelp,triangle);
  compare(wins,baseline.wins);compare(losses,baseline.losses);compare(activity.numberOfLevel,0);
  homeAfterWork('free-menu-after-creation');
 }
 function test_controls_and_free(){try{run_controls_and_free();}catch(error){evidence.failure={message:String(error),stack:error.stack};throw error;}}
 function cleanupTestCase() {finish();}
}
