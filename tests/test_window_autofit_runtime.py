#!/usr/bin/env python3
"""Real PlasmaWindowed auto-fit with isolated settings and display."""
import json, os, pathlib, re, shutil, subprocess, tempfile, unittest
ROOT=pathlib.Path(__file__).resolve().parents[1]
INSTRUMENT=r'''
        property int noise: 0
        Timer { interval: 100; repeat: true; running: Plasmoid.configuration.autoFitContent; onTriggered: background.noise = 1 - background.noise }
        property int testStep: 0
        Timer { interval: 1700; repeat: true; running: true; onTriggered: {
          console.log("AUTO_WINDOW " + JSON.stringify({step: background.testStep, enabled: Plasmoid.configuration.autoFitContent,
             supported: windowFit.supported, skin: sys.skin, width: background.Window.window.width,
             height: background.Window.window.height, idealHeight: background.implicitHeight}))
          if (background.testStep === 0) { background.Window.window.width = 500; background.Window.window.height = 650 }
          if (background.testStep === 1) Plasmoid.configuration.skin = 2
          if (background.testStep === 2) Plasmoid.configuration.autoFitContent = true
          if (background.testStep === 4) Plasmoid.configuration.skin = 0
          if (background.testStep === 6) { Plasmoid.configuration.autoFitContent = false; background.Window.window.height = 700 }
          if (background.testStep === 7) Plasmoid.configuration.skin = 2
          background.testStep++
        }}
'''
class WindowFit(unittest.TestCase):
 def test_window_fit_and_manual(self):
  for p in ('xvfb-run','dbus-run-session','timeout','plasmawindowed'):
   if not shutil.which(p): self.skipTest(p+' missing')
  with tempfile.TemporaryDirectory(prefix='window-autofit-') as t:
   d=pathlib.Path(t); app=d/'plasmoid'; shutil.copytree(ROOT/'plasmoid',app)
   main=app/'contents/ui/main.qml'; s=main.read_text().replace('implicitWidth: loader.implicitWidth', 'implicitWidth: loader.implicitWidth + background.noise').replace('        Loader {\n            id: loader', INSTRUMENT+'\n        Loader {\n            id: loader'); main.write_text(s)
   env=os.environ.copy(); env['QT_QPA_PLATFORM']='xcb'
   for n in ('CONFIG','DATA','CACHE'):
    path=d/n.lower(); path.mkdir(); env['XDG_'+n+'_HOME']=str(path)
   p=subprocess.run(['xvfb-run','-a','dbus-run-session','--','timeout','19s','plasmawindowed',str(app)],env=env,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=40)
   self.assertEqual(p.returncode,124,p.stdout)
   rows={x['step']:x for x in (json.loads(m) for m in re.findall(r'AUTO_WINDOW (\{[^\n]+\})',p.stdout))}
   self.assertTrue(all(i in rows for i in (1,2,3,4,5,6,7,8)),p.stdout)
   self.assertTrue(rows[1]['supported']); self.assertFalse(rows[2]['enabled'])
   self.assertEqual(rows[2]['height'],650)
   self.assertTrue(rows[4]['enabled']); self.assertEqual(rows[4]['height'],rows[4]['idealHeight'])
   self.assertEqual(rows[6]['height'],rows[6]['idealHeight']); self.assertGreater(rows[6]['height'],rows[4]['height'])
   self.assertFalse(rows[8]['enabled']); self.assertEqual(rows[8]['height'],700)
if __name__=='__main__': unittest.main()
