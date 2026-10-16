// SPDX-License-Identifier: GPL-3.0-or-later
function expectedTotal() {
    check(activity.activityInfo.shortName(),'mosaic','Public mosaic activity');
    return 22;
}
function publicMirror() { return false; }
function questionObjects() { return publicImages(question); }
function answerObjects() { return publicImages(answer); }
function isRenderedReady(item) { return item.status===Image.Ready; }
function paletteObjects() { return publicImages(selector); }
function renderedSignature(item) {
    var uri=String(item.source),entry=registry.images && registry.images[uri];
    ensure(entry!==undefined && typeof entry.signature==='string','Current public image has a physical RGBA signature');
    return entry.signature;
}
function paletteSignature(item) { return renderedSignature(item); }
