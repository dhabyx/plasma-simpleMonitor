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
    function checkTemp(name, ok) { console.log("TEMP_TEST " + name + " " + ok); if (!ok) tempTestFailures++ }
    Timer { interval: 2500; running: true; onTriggered: {
        if (!sys.cpuDiscovery) { checkTemp("native_sensor_discovery_exists", false); console.log("TEMP_TEST_DONE failures=" + tempTestFailures); return }
        Plasmoid.configuration.cpuTempMode = 0
        Plasmoid.configuration.showCpuFrequency = true
        sys.cpuDiscovery.usageIds = [0,2,7]; sys.cpuDiscovery.temperatureIds = [0,2,7]; sys.cpuDiscovery.frequencyIds = [0,2,7]
        checkTemp("discontinuous_cpu_ids", sys.cpuModel.count === 3 && sys.cpuModel.get(0).cpuId === 0 && sys.cpuModel.get(1).cpuId === 2 && sys.cpuModel.get(2).cpuId === 7)
        checkTemp("discontinuous_temp_ids", sys.coreTempModel.count === 3 && sys.coreTempModel.get(0).cpuId === 0 && sys.coreTempModel.get(1).cpuId === 2 && sys.coreTempModel.get(2).cpuId === 7)
        sys.setCoreTemp(0,40,0,sys.tempGeneration); sys.setCoreTemp(1,60,2,sys.tempGeneration); sys.setCoreTemp(2,null,7,sys.tempGeneration)
        checkTemp("valid_only", sys._validTempCount === 2 && sys.avgTemp === 50 && !sys.coreTempModel.get(2).hasValue)
        sys.setCoreTemp(1,null,2,sys.tempGeneration)
        checkTemp("invalid_clears", sys._validTempCount === 1 && sys.avgTemp === 40 && !sys.coreTempModel.get(1).hasValue)
        const oldTemp = sys.tempGeneration, oldCpu = sys.cpuGeneration, oldFreq = sys.freqGeneration
        sys.cpuDiscovery.usageIds = [0,7]; sys.cpuDiscovery.temperatureIds = [0,7]; sys.cpuDiscovery.frequencyIds = [0,7]
        checkTemp("removal_shrinks_models", sys.cpuModel.count === 2 && sys.coreTempModel.count === 2 && sys.cpuModel.get(1).cpuId === 7 && sys.coreTempModel.get(1).cpuId === 7 && sys._validTempCount === 0)
        sys.setCoreTemp(0,45,0,sys.tempGeneration); sys.setCoreTemp(0,99,0,oldTemp); sys.setCoreTemp(1,99,2,sys.tempGeneration)
        checkTemp("stale_temperature_ignored", sys.avgTemp === 45 && !sys.coreTempModel.get(1).hasValue)
        sys.setCpuLoad(0,22,0,sys.cpuGeneration); sys.setCpuLoad(0,99,0,oldCpu); sys.setCpuLoad(1,99,2,sys.cpuGeneration)
        checkTemp("stale_load_ignored", sys.cpuModel.get(0).val === 22 && sys.cpuModel.get(1).val !== 99)
        sys.setCpuFrequency(0,2200000000,0,sys.cpuGeneration,sys.freqGeneration); sys.setCpuFrequency(0,9900000000,0,oldCpu,oldFreq)
        checkTemp("frequency_roles_stale", sys.cpuModel.get(0).hasFrequency && sys.cpuModel.get(0).frequencyHz === 2200000000)
        sys.setCpuFrequency(0,null,0,sys.cpuGeneration,sys.freqGeneration)
        checkTemp("frequency_missing", !sys.cpuModel.get(0).hasFrequency)
        Plasmoid.configuration.showCpuFrequency = false
        checkTemp("frequency_unsubscribed", sys.cpuFrequencySensors.count === 0 && !sys.cpuModel.get(0).hasFrequency)
        Plasmoid.configuration.cpuTempMode = 1; sys.setSingleTemp(64,1)
        checkTemp("average_sensor", sys.coreTempModel.count === 1 && sys.avgTemp === 64)
        Plasmoid.configuration.cpuTempMode = 2; sys.setSingleTemp(81,2); sys.setSingleTemp(30,1)
        checkTemp("maximum_sensor", sys.coreTempModel.count === 1 && sys.avgTemp === 81)
        Plasmoid.configuration.cpuTempMode = 0
        checkTemp("restore_discovered_rows", sys.coreTempModel.count === 2 && sys.coreTempModel.get(1).cpuId === 7)
        const beforeInsertCpu = sys.cpuGeneration, beforeInsertTemp = sys.tempGeneration
        sys.cpuDiscovery.usageIds = [0,2,7]; sys.cpuDiscovery.temperatureIds = [0,2,7]
        sys.setCpuLoad(1,99,7,beforeInsertCpu); sys.setCoreTemp(1,99,7,beforeInsertTemp)
        checkTemp("addition_reorders_and_rejects_old_callbacks", sys.cpuModel.count === 3 && sys.coreTempModel.count === 3 && sys.cpuModel.get(1).cpuId === 2 && sys.coreTempModel.get(2).cpuId === 7 && sys.cpuModel.get(1).val !== 99 && !sys.coreTempModel.get(1).hasValue)
        sys.cpuDiscovery.usageIds = []; sys.cpuDiscovery.temperatureIds = []
        checkTemp("all_removed", sys.cpuModel.count === 0 && sys.coreTempModel.count === 0 && sys._validTempCount === 0)
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
