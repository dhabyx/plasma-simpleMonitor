#!/usr/bin/env python3
"""Exercise one-shot grouping against real cpuinfo and an isolated Plasma bus."""
import os,pathlib,shutil,subprocess,tempfile,unittest
ROOT=pathlib.Path(__file__).resolve().parents[1]
INSTRUMENT=r'''
    property int groupStep: 0
    property int groupFailures: 0
    property var savedUsage: []
    function checkGroup(name,ok) { console.log("GROUP_TEST " + name + " " + ok); if (!ok) groupFailures++ }
    CpuGrouping { id: groupTest; enabled: false; discoveryReady: true }
    Timer { interval: 1400; repeat: true; running: true; onTriggered: {
      if (root.groupStep === 0) {
        root.savedUsage = sys.cpuDiscovery.usageIds.slice()
        groupTest.usageIds = root.savedUsage
        groupTest.temperatureIds = sys.cpuDiscovery.temperatureIds.slice()
        checkGroup("disabled_no_read", groupTest.queryCount === 0 && groupTest.state === "disabled" && root.savedUsage.length > 0)
        groupTest.enabled = true
      } else if (root.groupStep === 1) {
        checkGroup("one_read", groupTest.queryCount === 1 && !groupTest.pending && (groupTest.state === "ready" || groupTest.state === "incomplete"))
        checkGroup("representative_bound", groupTest.representativeIds.length > 0 && groupTest.representativeIds.length <= groupTest.temperatureIds.length)
        groupTest.enabled = false; groupTest.enabled = true
        checkGroup("toggle_cache", groupTest.queryCount === 1)
      } else if (root.groupStep === 2) {
        groupTest.usageIds = root.savedUsage.slice(1)
        checkGroup("stale_fallback", groupTest.state === "stale" && groupTest.queryCount === 1 && groupTest.representativeIds.length === groupTest.usageIds.length)
        groupTest.enabled = false; groupTest.enabled = true
        checkGroup("stale_toggle_no_read", groupTest.queryCount === 1 && groupTest.state === "stale")
        checkGroup("manual_refresh", groupTest.refresh() && groupTest.queryCount === 2)
      } else if (root.groupStep === 3) {
        checkGroup("manual_finish", !groupTest.pending && (groupTest.state === "ready" || groupTest.state === "incomplete") && groupTest.queryCount === 2)
        console.log("GROUP_TEST_DONE failures="+root.groupFailures); running=false
      }
      root.groupStep++
    }}
'''
class Grouping(unittest.TestCase):
 def test_one_shot(self):
  with tempfile.TemporaryDirectory(prefix='simplemonitor-group-') as path:
   d=pathlib.Path(path); app=d/'plasmoid'; shutil.copytree(ROOT/'plasmoid',app)
   main=app/'contents/ui/main.qml'; s=main.read_text(); p=s.rfind('}'); main.write_text(s[:p]+INSTRUMENT+'\n'+s[p:])
   env=dict(os.environ, QT_QPA_PLATFORM='offscreen', QT_QUICK_BACKEND='software', XDG_CONFIG_HOME=str(d/'config'), XDG_DATA_HOME=str(d/'data'), XDG_CACHE_HOME=str(d/'cache'))
   log=d/'run.log'
   with log.open('w') as output:
    run=subprocess.run(['dbus-run-session','--','timeout','8s','plasmawindowed',str(app)],env=env,stdout=output,stderr=subprocess.STDOUT,timeout=15)
   text=log.read_text()
   self.assertEqual(run.returncode,124,text)
   self.assertIn('GROUP_TEST_DONE failures=0',text)
   self.assertNotIn('TypeError',text); self.assertNotIn('ReferenceError',text)
if __name__ == '__main__': unittest.main()
