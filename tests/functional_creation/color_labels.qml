TestCase {
 name:'EverySharedColorSelectorLabelIsEuropeanPortuguese'
 when:activity.visible&&canvasArea.width>0
 property var evidence: ({})
__VISIBLE__
 function test_labels(){wait(2500);activity.Window.window.requestActivate();wait(400);ensure(!ApplicationInfo.useSoftwareRenderer);if('__APP__'==='sketch')click(colorsPanel.icon2);else click(colorButton);wait(500);var root=__ROOT__;evidence.labels=all(root,function(o){return drawn(o)&&o.font!==undefined&&o.text!==undefined;}).map(function(o){return String(o.text);});shot('color-selector');evidence.expected=['Paleta de cores','Repor paleta','Cor selecionada','Matiz','Saturação','Luminosidade','Repor cor'];for(var label of evidence.expected)ensure(evidence.labels.indexOf(label)>=0,'Visible PT label: '+label);}
 function cleanupTestCase(){console.log('NATIVE_CREATION_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,evidence:evidence}));}
}
