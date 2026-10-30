#!/usr/bin/env python3
"""Check the actual one-shot os-release reader inside an isolated Plasma applet."""
import os
import pathlib
import shutil
import subprocess
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
INSTRUMENT = r'''
    Timer { interval: 2500; running: true; onTriggered: {
        console.log("OS_RELEASE_TEST name=" + sys.distroName + " version=" + sys.distroVersion + " codename=" + sys.distroCodename)
        console.log("OS_RELEASE_TEST_DONE " + (sys.distroName.length > 0 && sys.distroVersion.length > 0))
    }}
'''

class OsReleaseRuntime(unittest.TestCase):
    def test_local_release(self):
        with tempfile.TemporaryDirectory(prefix='simplemonitor-os-release-') as tmp:
            tmp = pathlib.Path(tmp)
            shutil.copytree(ROOT / 'plasmoid', tmp / 'plasmoid')
            main = tmp / 'plasmoid/contents/ui/main.qml'
            src = main.read_text(); end = src.rfind('}')
            main.write_text(src[:end] + INSTRUMENT + '\n' + src[end:])
            env = dict(os.environ, QT_QPA_PLATFORM='offscreen', QT_QUICK_BACKEND='software',
                       XDG_CONFIG_HOME=str(tmp / 'config'), XDG_DATA_HOME=str(tmp / 'data'),
                       XDG_CACHE_HOME=str(tmp / 'cache'))
            log = tmp / 'runtime.log'
            with log.open('w') as output:
                result = subprocess.run(['dbus-run-session', '--', 'timeout', '6s', 'plasmawindowed', str(tmp / 'plasmoid')],
                                        env=env, stdout=output, stderr=subprocess.STDOUT, timeout=12)
            text = log.read_text()
            self.assertEqual(result.returncode, 124, text)
            self.assertIn('OS_RELEASE_TEST_DONE true', text)
            self.assertNotIn('TypeError', text)
            self.assertNotIn('ReferenceError', text)
            print(next(line for line in text.splitlines() if 'OS_RELEASE_TEST name=' in line))

if __name__ == '__main__': unittest.main()
