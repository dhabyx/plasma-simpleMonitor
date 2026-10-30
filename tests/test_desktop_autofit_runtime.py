#!/usr/bin/env python3
"""Plasma 6 private desktop grid adapter with real applet and two containers.

Run under an isolated session; Xvfb, Plasma and a private session bus required.
No installed package or user Plasma session is modified.
"""
import json, os, pathlib, re, shutil, subprocess, tempfile, unittest
ROOT = pathlib.Path(__file__).resolve().parents[1]
INSTRUMENT = r'''
    Component { id: layoutFactory; CL.AppletsLayout {
      width: 1100; height: 800; cellWidth: 10; cellHeight: 10; configKey: "testAutoFitGeometry"
      containment: root.plasmoid.containment
      CL.AppletContainer { objectName: "neighbour"; x: 700; y: 10; width: 200; height: 200 }
    }}
    Timer { interval: 3000; running: true; onTriggered: {
      let grid = layoutFactory.createObject(root.parent)
      let box = root.parent
      let neighbour = null
      for (let child of grid.children) if (child.objectName === "neighbour") neighbour = child
      box.leftPadding=8; box.rightPadding=8; box.topPadding=8; box.bottomPadding=8
      let adapter = Qt.createComponent("components/DesktopAutoFit.qml").createObject(root,{appletItem:root,targetWidth:750,targetHeight:180})
      let old = {x:box.x,y:box.y,w:box.width,h:box.height}
      let collision = adapter.apply(); let collisionResult = adapter.result
      let unchanged = box.x === old.x && box.y === old.y && box.width === old.w && box.height === old.h
      let neighbourOccupied = !grid.isRectAvailable(neighbour.x,neighbour.y,neighbour.width,neighbour.height)
      box.editMode=true; adapter.targetWidth=221; adapter.targetHeight=181; let editing=adapter.apply(); let editResult=adapter.result; box.editMode=false
      let applied=adapter.apply(); let again=adapter.apply()
      let ownOccupied = !grid.isRectAvailable(box.x,box.y,box.width,box.height)
      console.log("AUTOFIT_TEST",JSON.stringify({collision,collisionResult,unchanged,neighbourOccupied,editing,editResult,supported:adapter.supported,applied,again,result:adapter.result,width:box.width,height:box.height,x:box.x,y:box.y,neighbourWidth:neighbour.width,neighbourHeight:neighbour.height,neighbourX:neighbour.x,neighbourY:neighbour.y,ownOccupied}))
    }}
'''
class DesktopAutoFit(unittest.TestCase):
 def test_real_grid(self):
  for program in ('xvfb-run','dbus-run-session','plasmawindowed','timeout'):
   if not shutil.which(program): self.skipTest(program+' unavailable')
  with tempfile.TemporaryDirectory(prefix='desktop-autofit-') as tmp:
   d=pathlib.Path(tmp); p=d/'plasmoid'; shutil.copytree(ROOT/'plasmoid',p)
   f=p/'contents/ui/main.qml'; s=f.read_text().replace('import QtQuick.Layouts','import QtQuick.Layouts\nimport org.kde.plasma.private.containmentlayoutmanager as CL'); s=s.replace('    SystemData {',INSTRUMENT+'\n    SystemData {',1); f.write_text(s)
   env=os.environ.copy()
   for name in ('CONFIG','DATA','CACHE'):
    path=d/name.lower(); path.mkdir(); env['XDG_'+name+'_HOME']=str(path)
   env['QT_QPA_PLATFORM']='xcb'
   run=subprocess.run(['xvfb-run','-a','dbus-run-session','--','timeout','7s','plasmawindowed',str(p)],env=env,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=35)
   self.assertEqual(run.returncode,124,run.stdout)
   m=re.search(r'AUTOFIT_TEST (\{[^\n]+\})',run.stdout); self.assertIsNotNone(m,run.stdout)
   a=json.loads(m.group(1))
   for key in ('unchanged','neighbourOccupied','supported','applied','again','ownOccupied'): self.assertTrue(a[key],(key,a))
   self.assertFalse(a['collision']); self.assertEqual(a['collisionResult'],'no-space'); self.assertFalse(a['editing']); self.assertEqual(a['editResult'],'editing'); self.assertEqual(a['result'],'ok')
   self.assertEqual((a['width'],a['height'],a['x'],a['y']),(240,200,0,0)); self.assertEqual((a['neighbourWidth'],a['neighbourHeight'],a['neighbourX'],a['neighbourY']),(200,200,700,10))
   self.assertRegex((d/'config/plasmawindowed-appletsrc').read_text(),r'testAutoFitGeometry=.*:0,0,240,200,0;')
if __name__=='__main__': unittest.main()
