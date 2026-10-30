const assert = require('assert');
const fs = require('fs');
const vm = require('vm');
const path = require('path');
const code = fs.readFileSync(path.join(__dirname, '../plasmoid/contents/code/code.js'), 'utf8').replace('.pragma library', '');
const c = vm.createContext({}); vm.runInContext(code, c);
assert.strictEqual(typeof c.parseOsRelease, 'function', 'os-release parser must exist');
const parse = text => JSON.parse(JSON.stringify(c.parseOsRelease(text)));
assert.deepStrictEqual(parse('NAME="Ubuntu"\nVERSION_ID="26.04"\nVERSION="26.04.1 LTS (Resolute Raccoon)"\nVERSION_CODENAME=resolute\n'), {name:'Ubuntu', version:'26.04', codename:'Resolute Raccoon'});
assert.deepStrictEqual(parse('NAME=Debian\nVERSION_ID="12"\nVERSION="12 (bookworm)"\nVERSION_CODENAME=bookworm\n'), {name:'Debian',version:'12',codename:'bookworm'});
assert.deepStrictEqual(parse('NAME=Fedora\nVERSION_ID=41\nVERSION="41 (Workstation Edition)"\n'), {name:'Fedora',version:'41',codename:''});
assert.deepStrictEqual(parse('NAME="Example \\"Distro\\""\nVERSION_CODENAME=rolling\n'), {name:'Example "Distro"',version:'',codename:'rolling'});
assert.deepStrictEqual(parse('NAME=Fedora\nVERSION="41 (Workstation Edition)"\nVERSION_CODENAME=fortyone\n'), {name:'Fedora',version:'',codename:'fortyone'});
assert.deepStrictEqual(parse('NAME=Minimal\n'), {name:'Minimal',version:'',codename:''});
assert.deepStrictEqual(parse('NAME="$(touch /tmp/nope)"\nUBUNTU_CODENAME=noble\nVERSION_CODENAME=other\n'), {name:'$(touch /tmp/nope)',version:'',codename:'noble'});
assert.deepStrictEqual(parse('NAME=Other\nVERSION="1 (x) suffix"\nVERSION_CODENAME=fallback\n'), {name:'Other',version:'',codename:'fallback'});
console.log('os-release parsing passed');
// Exercise the fixed selection command with temporary substitutes for the two
// system paths: /etc wins, and /usr/lib is used only when /etc is absent.
const os = require('os');
const cp = require('child_process');
const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'simplemonitor-release-test-'));
try {
  const etc = path.join(temp, 'etc-release'), lib = path.join(temp, 'lib-release');
  fs.writeFileSync(etc, 'NAME=Preferred\n'); fs.writeFileSync(lib, 'NAME=Fallback\n');
  const qml = fs.readFileSync(path.join(__dirname, '../plasmoid/contents/ui/components/OsRelease.qml'), 'utf8');
  const command = qml.match(/readonly property string command: "([^"]+)"/)[1]
    .replaceAll('/etc/os-release', etc).replaceAll('/usr/lib/os-release', lib);
  const read = () => parse(cp.execFileSync('/bin/sh', ['-c', command], {encoding: 'utf8'}));
  assert.strictEqual(read().name, 'Preferred');
  fs.unlinkSync(etc);
  assert.strictEqual(read().name, 'Fallback');
  fs.unlinkSync(lib);
  assert.strictEqual(read().name, '');
} finally { fs.rmSync(temp, {recursive:true, force:true}); }
console.log('os-release path fallback passed');
