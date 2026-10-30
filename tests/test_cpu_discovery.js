const assert = require('assert');
const fs = require('fs'), vm = require('vm');
const c=vm.createContext({}); vm.runInContext(fs.readFileSync('plasmoid/contents/code/code.js','utf8').replace('.pragma library',''),c);
const ids=(p,k)=>Array.from(c.cpuSensorIds(p,k));
assert.deepStrictEqual(ids(['cpu/cpu7/usage','cpu/cpu0/usage','cpu/cpu2/usage','cpu/cpu2/usage','cpu/cpu1/frequency','cpu/all/usage','cpu/cpu1/usage/extra'],'usage'),[0,2,7]);
assert.deepStrictEqual(ids(['cpu/cpu7/temperature','cpu/cpu0/temperature','cpu/cpu2/usage'],'temperature'),[0,7]);
assert.deepStrictEqual(ids([],'usage'),[]);
console.log('cpu sensor discovery passed');
