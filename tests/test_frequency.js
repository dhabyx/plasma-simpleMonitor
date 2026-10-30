// Run with node; executes the project's actual QML-compatible JavaScript.
const assert = require('assert');
const fs = require('fs');
const vm = require('vm');
const path = require('path');
const source = fs.readFileSync(path.join(__dirname, '../plasmoid/contents/code/code.js'), 'utf8').replace('.pragma library', '');
const context = vm.createContext({});
vm.runInContext(source, context);
const units = [300, 301, 302, 303, 304, 305]; // KSysGuard frequency enum values in the fixture
assert.strictEqual(context.frequencyHz(2200, 302, units), 2200000000);
assert.strictEqual(context.frequencyHz(2.3, 303, units), 2300000000);
assert.strictEqual(context.frequencyHz(800000, 301, units), 800000000);
assert.strictEqual(context.frequencyHz(1, 300, units), 1);
assert.strictEqual(context.frequencyHz(0, 302, units), null);
assert.strictEqual(context.frequencyHz(-1, 302, units), null);
assert.strictEqual(context.frequencyHz(NaN, 302, units), null);
assert.strictEqual(context.frequencyHz(123, 999, units), null);
console.log('Frequency unit conversions passed');
