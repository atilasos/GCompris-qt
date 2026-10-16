// SPDX-License-Identifier: GPL-3.0-or-later
// Evaluate only the static trusted QML data arrays; qsTr is the Qt boundary.
const fs = require('fs');
const vm = require('vm');
const input = JSON.parse(fs.readFileSync(0, 'utf8'));
const context = vm.createContext({translations: input.translations});
vm.runInContext('String.prototype.arg=function(value){return this.replace(/%1/g,String(value));}; function qsTr(source){return translations[source]===undefined?source:translations[source];}', context);
const reports = input.files.map(({path,text}) => {
    const clean=text.replace(/\/\*[\s\S]*?\*\//g,'').replace(/\/\/[^\n]*/g,'');
    const expression=clean.slice(clean.indexOf('data:')+5,clean.lastIndexOf(']')+1);
    return {path,levels:vm.runInContext('('+expression+')',context)};
});
process.stdout.write(JSON.stringify(reports));
