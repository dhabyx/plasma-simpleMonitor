#!/usr/bin/env python3
"""Exercise the actual temperature model in an isolated Plasma instance.

Requires plasmawindowed, dbus-run-session, ksystemstats and access to a private
session bus. The timeout is intentional: plasmawindowed has no Qt.quit receiver.
"""
import os
import pathlib
import shutil
import subprocess
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
INSTRUMENT = r'''
    property int tempTestFailures: 0
    function checkTemp(name, ok) {
        console.log("TEMP_TEST " + name + " " + ok)
        if (!ok) tempTestFailures++
    }
    Timer { interval: 2500; running: true; onTriggered: {
        Plasmoid.configuration.cpuTempMode = 0
        sys.cpuInfo.enabled = false
        checkTemp("waiting_for_topology", sys.coreTempModel.count === 0)
        sys.cpuInfo.cpuIds = [0,1,2,3,4,5,6,7,8,9,10,11]
        for (let i=0; i<12; ++i) sys.setCoreTemp(i,40+i,i,sys.tempGeneration)
        checkTemp("initial_12", sys.coreTempModel.count === 12 && sys.avgTemp === 45.5)
        sys.cpuInfo.cpuIds = [0,1,2,3,4,5]
        checkTemp("shrink_and_reset", sys.coreTempModel.count === 6 && sys._validTempCount === 0 && sys.avgTemp === 0)
        sys.setCoreTemp(0,50,0,sys.tempGeneration); sys.setCoreTemp(1,60,1,sys.tempGeneration)
        checkTemp("mean_valid_only", sys._validTempCount === 2 && sys.avgTemp === 55)
        sys.setCoreTemp(1,null,1,sys.tempGeneration)
        checkTemp("invalid_clears", sys._validTempCount === 1 && sys.avgTemp === 50 && !sys.coreTempModel.get(1).hasValue)
        sys.setCoreTemp(-1,90,0,sys.tempGeneration); sys.setCoreTemp(9,90,9,sys.tempGeneration); sys.setCoreTemp(0,90,99,sys.tempGeneration)
        checkTemp("old_callbacks_ignored", sys.avgTemp === 50 && sys.coreTempModel.count === 6)
        const oldGeneration = sys.tempGeneration
        sys.cpuInfo.cpuIds = [2,6,10]
        sys.setCoreTemp(0,45,2,sys.tempGeneration); sys.setCoreTemp(1,65,6,sys.tempGeneration)
        checkTemp("non_contiguous_ids", sys.coreTempModel.count === 3 && sys.coreTempModel.get(2).cpuId === 10 && sys.avgTemp === 55)
        sys.setCoreTemp(0,99,2,oldGeneration)
        checkTemp("old_generation_ignored", sys.avgTemp === 55)
        const sameIdOldGeneration = sys.tempGeneration
        sys.cpuInfo.cpuIds = [2,6,11]
        sys.setCoreTemp(0,45,2,sys.tempGeneration)
        sys.setCoreTemp(0,99,2,sameIdOldGeneration)
        checkTemp("reused_index_and_id_reject_old_generation", sys.avgTemp === 45)
        Plasmoid.configuration.cpuTempMode = 1
        sys.setSingleTemp(64,1)
        checkTemp("average_mode", sys.coreTempModel.count === 1 && sys.avgTemp === 64)
        Plasmoid.configuration.cpuTempMode = 2
        sys.setSingleTemp(81,2); sys.setSingleTemp(30,1)
        checkTemp("maximum_mode", sys.coreTempModel.count === 1 && sys.avgTemp === 81)
        Plasmoid.configuration.cpuTempMode = 0
        sys.cpuInfo.enabled = false; sys.cpuInfo.cpuIds = [2,6,10]
        checkTemp("back_to_per_core", sys.coreTempModel.count === 3 && sys.avgTemp === 0)
        console.log("TEMP_TEST_DONE failures=" + tempTestFailures)
    }}
'''

class TemperatureRuntime(unittest.TestCase):
    def test_model_lifecycle(self):
        with tempfile.TemporaryDirectory(prefix='simplemonitor-temp-test-') as tmp:
            tmp = pathlib.Path(tmp)
            shutil.copytree(ROOT / 'plasmoid', tmp / 'plasmoid')
            main = tmp / 'plasmoid/contents/ui/main.qml'
            source = main.read_text()
            end = source.rfind('}')
            main.write_text(source[:end] + INSTRUMENT + '\n' + source[end:])
            env = dict(os.environ, QT_QPA_PLATFORM='offscreen', QT_QUICK_BACKEND='software',
                       XDG_CONFIG_HOME=str(tmp / 'config'), XDG_DATA_HOME=str(tmp / 'data'),
                       XDG_CACHE_HOME=str(tmp / 'cache'))
            log = tmp / 'runtime.log'
            with log.open('w') as output:
                result = subprocess.run(['dbus-run-session', '--', 'timeout', '6s', 'plasmawindowed', str(tmp / 'plasmoid')],
                                        env=env, stdout=output, stderr=subprocess.STDOUT, timeout=12)
            text = log.read_text()
            self.assertEqual(result.returncode, 124, text)
            self.assertIn('TEMP_TEST_DONE failures=0', text)
            self.assertNotIn('TEMP_TEST waiting_for_topology false', text)
            self.assertNotIn('TypeError', text)
            self.assertNotIn('ReferenceError', text)

if __name__ == '__main__': unittest.main()
