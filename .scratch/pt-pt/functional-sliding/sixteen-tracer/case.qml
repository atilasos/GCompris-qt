// SPDX-License-Identifier: GPL-3.0-or-later
TestCase {
 name:'VisibleSlidingTracer'
 when:activity.visible&&items.numberOfLevel>0
 property var observations: []
    function ensure(value,message){if(!value){console.log('SLIDING_ASSERT',message,new Error().stack);grabImage(pageView).save('__QA_OUTPUT__/failure.png');}verify(value,message||'');}
    function find(root,predicate){if(predicate(root))return root;if(root.children)for(var child of root.children){var value=find(child,predicate);if(value)return value;}return null;}
    function drawn(item){var alpha=1;for(var node=item;node&&node!==pageView;node=node.parent){if(!node.visible)return false;if(node.opacity!==undefined)alpha*=node.opacity;}return alpha>0.9&&item.width>0&&item.height>0;}
    function click(item){ensure(item!==null);var point=item.mapToItem(pageView,item.width/2,item.height/2);mouseClick(pageView,point.x,point.y,Qt.LeftButton,Qt.NoModifier,0);}
    function board(){var result=new Array(16),tiles=[];for(var i=0;i<repeater.count;i++){
        var tile=repeater.itemAt(i);ensure(drawn(tile),'Visible board tile');var position=tile.mapToItem(puzzleArea,0,0),column=Math.round(position.x/tile.width),row=Math.round(position.y/tile.height),cell=row*4+column;
        ensure(cell>=0&&cell<16&&Math.abs(position.x-column*tile.width)<1&&Math.abs(position.y-row*tile.height)<1,'Stable drawn grid cell');
        var image=find(tile,function(item){return item.source!==undefined&&item.fillMode!==undefined;});ensure(image!==null);var source=String(image.source),value=0,crop=null;
        if(source){ensure(/\/(Fishing_Boat_Scene|Coastal_Path)\.svg$/.test(source),'Actual scene image');tryCompare(image,'status',1,2000);ensure(image.transform.length===1);var x=-image.transform[0].x/tile.width,y=-image.transform[0].y/tile.height;ensure(x>=0&&x<=3&&y>=0&&y<=3&&Math.abs(x-Math.round(x))<0.001&&Math.abs(y-Math.round(y))<0.001,'Drawn image crop');value=Math.round(y)*4+Math.round(x)+1;crop={column:x,row:y};}
        var label=find(tile,function(item){return item.text!==undefined&&drawn(item)&&/^\d+$/.test(String(item.text));});if(label)compare(Number(label.text),value,'Visible number agrees with rendered crop');
        ensure(result[cell]===undefined,'Distinct drawn cells');result[cell]=value;tiles.push({cell:cell,value:value,source:source,crop:crop,text:label?String(label.text):'',x:position.x,y:position.y,width:tile.width,height:tile.height});
    }ensure(result.length===16&&result.every(function(v){return v!==undefined;}));ensure(new Set(result).size===16);return {values:result,tiles:tiles};}
    function same(a,b){return JSON.stringify(a)===JSON.stringify(b);}
    function target(){var value=[];for(var i=1;i<=16;i++)value.push(i===16&&mode==='fifteen'?0:i);return value;}
    function neighbors(cell){var out=[];for(var i=0;i<16;i++)if(Math.abs(i%4-cell%4)+Math.abs(Math.floor(i/4)-Math.floor(cell/4))===1)out.push(i);return out;}
    function plan(initial){var state=initial.slice(),empty=state.indexOf(0),locked={},moves=[];
        function place(values,goals){var start=[empty];for(var value of values)start.push(state.indexOf(value));var queue=[start],parents={};parents[start.join(',')]=null;var found=null;
            for(var head=0;head<queue.length;head++){var current=queue[head],key=current.join(',');if(goals.every(function(goal,index){return current[index+1]===goal;})){found=key;break;}
                for(var next of neighbors(current[0])){if(locked[next])continue;var node=current.slice();node[0]=next;for(var k=1;k<node.length;k++)if(node[k]===next)node[k]=current[0];var code=node.join(',');if(parents[code]===undefined){parents[code]={before:key,tile:next};queue.push(node);}}
            }ensure(found!==null,'Independent abstract BFS reaches stage');var path=[];while(parents[found]!==null){path.push(parents[found].tile);found=parents[found].before;}path.reverse();for(var cell of path){state[empty]=state[cell];state[cell]=0;empty=cell;moves.push(cell);}for(var goal of goals)locked[goal]=true;
        }
        place([1],[0]);place([2],[1]);place([3,4],[2,3]);place([5],[4]);place([6],[5]);place([7,8],[6,7]);place([9,13],[8,12]);place([10,14],[9,13]);place([11,12,15],[10,11,14]);ensure(same(state,target()),'Independent final plan');return moves;
    }
    function tileAt(cell){return find(puzzleArea,function(item){if(!item.clip||item.width!==pieceSize||item.height!==pieceSize)return false;var p=item.mapToItem(puzzleArea,0,0);return Math.round(p.y/pieceSize)*4+Math.round(p.x/pieceSize)===cell;});}
    function slideMove(before,cell,input){var empty=before.values.indexOf(0),expected=before.values.slice();ensure(neighbors(empty).indexOf(cell)>=0,'Legal tile adjacency');expected[empty]=expected[cell];expected[cell]=0;var tile=tileAt(cell);ensure(tile!==null);
        if(input==='key'){var difference=empty-cell;keyClick(difference===1?Qt.Key_Right:difference===-1?Qt.Key_Left:difference===4?Qt.Key_Down:Qt.Key_Up);}
        else if(input==='drag'){var from=tile.mapToItem(pageView,tile.width/2,tile.height/2),end=tileAt(empty).mapToItem(pageView,tile.width/2,tile.height/2);mouseDrag(pageView,from.x,from.y,end.x-from.x,end.y-from.y,Qt.LeftButton,Qt.NoModifier,200);}
        else click(tile);
        wait(310);var after=board();ensure(same(after.values,expected),'Actual tile transition');return {before:before,after:after,cell:cell,input:input};
    }
    function arrow(direction,index){return (direction==='L'?leftArrowsRepeater:direction==='R'?rightArrowsRepeater:direction==='T'?topArrowsRepeater:bottomArrowsRepeater).itemAt(index);}
    function visualHint(){var hits=[];for(var d of ['L','R','T','B'])for(var i=0;i<4;i++){var button=arrow(d,i),light=find(button,function(item){return item.color!==undefined&&drawn(item)&&String(item.color)==='#804280ff';});if(light)hits.push({direction:d,index:i,color:String(light.color)});}ensure(hits.length===1,'Exactly one visibly highlighted hint');return hits[0];}
    function rotateExpected(before,direction,index){var result=before.slice(),cells=[];for(var i=0;i<4;i++)cells.push(direction==='L'||direction==='R'?index*4+i:index+4*i);var step=direction==='L'||direction==='T'?-1:1;for(var j=0;j<4;j++)result[cells[(j+step+4)%4]]=before[cells[j]];return result;}
    function rotateMove(before,direction,index,input){var expected=rotateExpected(before.values,direction,index);if(input==='key')keyClick(Qt.Key_Space);else click(arrow(direction,index));wait(310);var after=board();ensure(same(after.values,expected),'Actual row/column rotation');return {before:before,after:after,direction:direction,index:index,input:input};}
    function icon(suffix){wait(1800);var image=find(bar,function(item){return item.source!==undefined&&String(item.source).endsWith(suffix)&&drawn(item);});ensure(image!==null,'Visible bar icon '+suffix);click(image);wait(1800);}

 function test_first_board(){wait(1800);var first=board();grabImage(pageView).save('__QA_OUTPUT__/first.png');if(mode==='fifteen'){var route=plan(first.values);console.log('SLIDING_PLAN',route.length);for(var cell of route){var move=slideMove(first,cell,'click');observations.push(move);first=move.after;}}else{icon('bar_hint.svg');for(var count=0;count<30&&!same(first.values,target());count++){var hint=visualHint(),move=rotateMove(first,hint.direction,hint.index,'click');move.hint=hint;observations.push(move);first=move.after;}}ensure(same(first.values,target()));tryCompare(bonus,'isPlaying',true,1000);tryCompare(items,'currentLevel',1,9000);}
 function cleanupTestCase(){console.log('NATIVE_SLIDING_RESULT',JSON.stringify({failures:qtest_results.failCount,passes:qtest_results.passCount,observations:observations}));}
}
