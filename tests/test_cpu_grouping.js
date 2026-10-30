const assert=require('assert'),fs=require('fs'),vm=require('vm');
const c=vm.createContext({});vm.runInContext(fs.readFileSync('plasmoid/contents/ui/components/cpu-grouping.js','utf8').replace('.pragma library',''),c);
function block(id,pkg,core,die) { return 'processor : '+id+'\n'+(pkg===null?'':'physical id : '+pkg+'\n')+(core===null?'':'core id : '+core+'\n')+(die===null?'':'die id : '+die+'\n')+'\n'; }
function result(text,usages,temps) { return Array.from(c.representativeIds(c.parseCpuInfo(text),usages,temps)); }
let interleaved=block(7,0,1,null)+block(0,0,0,null)+block(2,1,0,null)+block(6,0,0,null)+block(1,0,1,null)+block(8,1,0,null);
assert.deepStrictEqual(result(interleaved,[0,1,2,6,7,8],[0,1,2,6,7,8]),[0,1,2]);
assert.deepStrictEqual(result(interleaved,[0,1,2,6,7,8],[1,6,7,8]),[1,6,8]);
let sparse=block(2,0,0,null)+block(9,0,0,null)+block(15,2,0,null)+block(21,null,0,null)+block(23,null,0,null);
assert.deepStrictEqual(result(sparse,[2,9,15,21,23],[2,9,15,21,23]),[2,15,21,23]);
let die=block(0,0,1,0)+block(1,0,1,1)+block(2,0,1,0)+block(3,0,1,null)+block(4,0,1,null);
assert.deepStrictEqual(result(die,[0,1,2,3,4],[0,1,2,3,4]),[0,1,3,4]);
assert.deepStrictEqual(result('',[0,1],[0,1]),[0,1]);
assert(c.sameIds([2,0,7],[7,0,2]));assert(!c.sameIds([0,2],[0,2,7]));
console.log('CPU grouping parser passed');
