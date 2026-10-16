// SPDX-License-Identifier: GPL-3.0-or-later
function rectangles(root) {
    return allVisible(root).filter(o=>o.color!==undefined && o.border!==undefined && o.border.width>0 && o.width>5 && o.height>5);
}
function expectedTotal() {
    var name=activity.activityInfo.shortName();
    ensure(name==='redraw' || name==='redraw_symmetrical','Public redraw activity mode');
    return name==='redraw_symmetrical'?21:38;
}
function publicMirror() { return activityName==='redraw_symmetrical'; }
function questionObjects() { return rectangles(imageArea); }
function answerObjects() { return rectangles(drawingArea); }
function paletteObjects() {
    return publicImages(colorSelector).filter(o=>String(o.source).startsWith('qrc:/gcompris/src/activities/redraw/resource/'));
}
function renderedSignature(item) { return String(item.color); }
function isRenderedReady(item) { return true; }
function paletteSignature(item) {
    var samples=registry.palette_samples && registry.palette_samples[activityName];
    ensure(Array.isArray(samples),'Physically calibrated palette samples exist for this public mode');
    var matches=samples.filter(sample=>sample.id===String(item.source));
    check(matches.length,1,'Current public palette URI has one actual pointer calibration');
    ensure(typeof matches[0].signature==='string','Calibration preserves the actual QtColorString');
    return matches[0].signature;
}
