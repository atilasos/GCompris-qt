// SPDX-License-Identifier: GPL-3.0-or-later
(function() {
    function parse(label) {
        var match = String(label).trim().match(/^(\d+(?:[,.]\d+)?)\s*(kg|g|lb|oz)?$/);
        if(!match) throw new Error('Unknown visible mass label: ' + label);
        var factor = {kg:1000, g:1, lb:16, oz:1};
        return Math.round(Number(match[1].replace(',', '.')) * (match[2] ? factor[match[2]] : 1));
    }
    function cost(positions) {
        return positions.filter(function(side) {return side !== 0;}).length;
    }
    function plans(labels, both) {
        var values = labels.map(parse), bySum = {};
        function visit(index, sum, positions) {
            if(index === values.length) {
                if(sum <= 0) return;
                var previous = bySum[sum];
                var usesRight = positions.indexOf(-1) >= 0;
                var previousRight = previous && previous.positions.indexOf(-1) >= 0;
                if(!previous || (usesRight && !previousRight) ||
                   (usesRight === previousRight && cost(positions) < cost(previous.positions)))
                    bySum[sum] = {sum:sum, positions:positions};
                return;
            }
            for(var side = both ? -1 : 0; side <= 1; side++)
                visit(index + 1, sum + side * values[index], positions.concat([side]));
        }
        visit(0, 0, []);
        return Object.keys(bySum).map(function(key) {return bySum[key];}).sort(function(a,b) {return a.sum-b.sum;});
    }
    function entry(canonical, prompt) {
        if(prompt.indexOf('quilogram') >= 0) return canonical / 1000;
        if(prompt.indexOf('libras') >= 0) return canonical / 16;
        if(prompt.indexOf('gramas') >= 0 || prompt.indexOf('onças') >= 0 ||
           prompt.indexOf('peso do presente:') >= 0) return canonical;
        throw new Error('Unknown visible answer unit: ' + prompt);
    }
    return {parse:parse, plans:plans, entry:entry};
})()
