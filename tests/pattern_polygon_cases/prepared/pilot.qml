// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 id:qa
 name:'PolygonPilotCollinearRejectionAndIndependentRepair'
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
  return {requested:vertices,steps:trace,closed:closed};
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

 function test_pilot() {
  wait(1500);compare(activity.numberOfLevel,9);compare(bar.level,1);
  var route={level:1,pages:introductions('pilot'),instruction:instruction()};evidence.routes.push(route);
  compare(route.instruction,proposals[0].instruction);
  route.wrong=draw([[2,4],[5,4],[8,4]],'pilot-collinear');
  route.rejection=submit('pilot-collinear',false);
  route.reload=reload('pilot-cleared');
  route.repair=draw(proposals[0].vertices,'pilot-independent');
  route.success=submit('pilot-independent',true);
 }
 function cleanupTestCase() {finish();}
}
