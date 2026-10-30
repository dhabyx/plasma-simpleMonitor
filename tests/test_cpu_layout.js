// Layout contract, independent of sensor availability.
const fs = require('fs');
const vm = require('vm');
const assert = require('assert');
const path = require('path');
const script = fs.readFileSync(path.join(__dirname, '../plasmoid/contents/ui/components/cpu-layout.js'), 'utf8').replace('.pragma library', '');
const m = {};
vm.runInNewContext(script, m);
for (const n of [1, 4, 12, 40, 64, 128]) {
    for (const requested of [0, 1, 2, 8]) {
        const columns = m.columnCount(n, requested, 1920);
        const rows = m.rowCount(n, columns);
        const cells = new Set();
        for (let i = 0; i < n; i++) {
            const column = m.columnFor(i, rows);
            const row = m.rowFor(i, rows);
            assert(column < columns && row < rows);
            assert(!cells.has(`${column},${row}`));
            cells.add(`${column},${row}`);
        }
        assert.equal(cells.size, n);
        if (requested === 0) assert(columns <= Math.floor(1920 * 0.8 / 100));
    }
}
assert.equal(m.columnCount(128, 0, 320), 2);
assert.equal(m.columnCount(128, 0, 1920), 8);
console.log('CPU layout contracts passed');
