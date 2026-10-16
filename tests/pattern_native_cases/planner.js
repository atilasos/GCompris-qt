// SPDX-License-Identifier: GPL-3.0-or-later
// Pure, current-widget geometry. No QML engine state or authored models.
function demand(value, message) {
    if (!value) throw new Error(message);
}
function opaqueKey(value) {
    if (value === null) return 'null';
    if (typeof value === 'string' || typeof value === 'boolean') return JSON.stringify(value);
    if (typeof value === 'number') {
        demand(Number.isFinite(value), 'Nonfinite signature');
        return JSON.stringify(value);
    }
    if (Array.isArray(value)) return '[' + value.map(opaqueKey).join(',') + ']';
    demand(typeof value === 'object', 'Signature must be finite JSON');
    return '{' + Object.keys(value).sort().map(k=>JSON.stringify(k)+':'+opaqueKey(value[k])).join(',') + '}';
}
function clone(value) { return JSON.parse(JSON.stringify(value)); }
function median(values) {
    var sorted = values.slice().sort((a,b)=>a-b), n = sorted.length;
    return n % 2 ? sorted[(n-1)/2] : (sorted[n/2-1]+sorted[n/2])/2;
}
function gridAxis(values, size) {
    var tolerance = size * 1e-6, groups = [];
    values.slice().sort((a,b)=>a-b).forEach(value=>{
        if (!groups.length || value-groups[groups.length-1][0] > tolerance) groups.push([value]);
        else groups[groups.length-1].push(value);
    });
    var centers = groups.map(median), steps = [];
    for (var i=1;i<centers.length;i++) steps.push(centers[i]-centers[i-1]);
    if (steps.length) {
        var step = median(steps);
        demand(steps.every(s=>s+tolerance>=size), 'Overlapping visible cells');
        demand(steps.every(s=>Math.abs(s-step)<=2*tolerance), 'Irregular visible grid');
    }
    return centers;
}
function visibleGrid(cells) {
    demand(Array.isArray(cells) && cells.length>0, 'Empty visible grid');
    cells.forEach(cell=>{
        demand(cell && cell.frame, 'Nested public frame required');
        ['x','y','width','height'].forEach(key=>demand(typeof cell.frame[key]==='number' && Number.isFinite(cell.frame[key]),'Nonfinite visible frame'));
        demand(cell.frame.width>0 && cell.frame.height>0,'Nonpositive visible frame');
    });
    var width=median(cells.map(c=>c.frame.width)), height=median(cells.map(c=>c.frame.height));
    demand(cells.every(c=>Math.abs(c.frame.width-width)<=width*1e-6 && Math.abs(c.frame.height-height)<=height*1e-6),'Inconsistent visible cell dimensions');
    var xs=gridAxis(cells.map(c=>c.frame.x),width), ys=gridAxis(cells.map(c=>c.frame.y),height), indexed=Object.create(null);
    cells.forEach(cell=>{
        var columns=[],rows=[];
        xs.forEach((x,i)=>{if(Math.abs(x-cell.frame.x)<=width*1e-6)columns.push(i);});
        ys.forEach((y,i)=>{if(Math.abs(y-cell.frame.y)<=height*1e-6)rows.push(i);});
        demand(columns.length===1 && rows.length===1,'Ambiguous visible cell membership');
        var key=rows[0]+':'+columns[0];demand(indexed[key]===undefined,'Duplicate visible cell');indexed[key]=cell;
    });
    demand(cells.length===xs.length*ys.length,'Incomplete visible rectangle');
    return {xs:xs,ys:ys,cells:indexed};
}
function visiblePlan(question, answer, palette, mirror) {
    demand(typeof mirror==='boolean','Explicit public mirror mode required');
    demand(Array.isArray(palette)&&palette.length>0,'Empty calibrated palette');
    var paints=Object.create(null),ids=Object.create(null);
    palette.forEach(sample=>{
        var signature=opaqueKey(sample.signature),id=opaqueKey(sample.id);
        demand(paints[signature]===undefined && ids[id]===undefined,'Duplicate palette signature or id');
        paints[signature]=sample;ids[id]=true;
    });
    var q=visibleGrid(question),a=visibleGrid(answer),placements=[];
    demand(q.xs.length===a.xs.length && q.ys.length===a.ys.length,'Visible grid dimensions differ');
    for(var row=0;row<q.ys.length;row++)for(var column=0;column<q.xs.length;column++) {
        var cell=q.cells[row+':'+column],key=opaqueKey(cell.signature),paint=paints[key];
        demand(paint!==undefined,'Observed signature has no calibrated palette');
        placements.push({question_frame:clone(cell.frame),target_frame:clone(a.cells[row+':'+(mirror?q.xs.length-1-column:column)].frame),signature:clone(cell.signature),palette_id:clone(paint.id)});
    }
    return {rows:q.ys.length,columns:q.xs.length,placements:placements,
            diagnostics:{method:'visible regular grid and calibrated signatures',mirror:mirror,toleranceFraction:1e-6}};
}
