const assert = require('assert');
const fs = require('fs'); const vm = require('vm');
const ctx=vm.createContext({}); vm.runInContext(fs.readFileSync('plasmoid/contents/ui/components/autofit-policy.js','utf8').replace('.pragma library',''),ctx);
assert(ctx.isWindowed('plasmawindowed','PlasmaWindowedView(0x123)',true));
for (const [app,window,owner] of [['plasmashell','PlasmaWindowedView(0x123)',true],['plasmawindowed','QQuickWindow(0x123)',true],['other','PlasmaWindowedView(0x123)',true],['plasmawindowed','PlasmaWindowedView(0x123)',false]]) assert(!ctx.isWindowed(app,window,owner));
assert(ctx.shouldAdjustWidth(424,392));
assert(!ctx.shouldAdjustWidth(392,386));
assert(ctx.shouldAdjustWidth(386,392));
console.log('auto fit policy passed');
