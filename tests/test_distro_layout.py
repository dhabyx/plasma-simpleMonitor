#!/usr/bin/env python3
"""Exercise actual distro text layout, including an empty selection."""
import os, pathlib, tempfile, unittest, time
os.environ.setdefault('QT_QPA_PLATFORM', 'offscreen')
os.environ.setdefault('QT_QUICK_BACKEND', 'software')
from PyQt6.QtCore import QUrl, QPointF
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQuick import QQuickView
ROOT = pathlib.Path(__file__).resolve().parents[1]
QML = '''import QtQuick\nOsInfoItem { width: 180; height: implicitHeight; distroName: "Ubuntu"; distroVersion: "26.04"; distroCodename: "Resolute Raccoon"; kernelName: "Linux"; kernelVersion: "7.0" }'''
class DistroLayout(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  cls.app = QGuiApplication.instance() or QGuiApplication([])
  cls.tmp = tempfile.TemporaryDirectory()
  src=(ROOT/'plasmoid/contents/ui/monitorWidgets/OsInfoItem.qml').read_text().replace('../../fonts/Monda/Monda-Regular.ttf', (ROOT/'plasmoid/contents/fonts/Monda/Monda-Regular.ttf').as_uri()).replace('id: distroInfo', 'id: distroInfo\n            objectName: "distro"').replace('id: kernelInfo', 'id: kernelInfo\n            objectName: "kernel"').replace('text: "⚠"', 'objectName: "warning"\n            text: "⚠"')
  (pathlib.Path(cls.tmp.name)/'OsInfoItem.qml').write_text(src)
  (pathlib.Path(cls.tmp.name)/'main.qml').write_text(QML.replace('@PATH@',cls.tmp.name))
  cls.view=QQuickView(); cls.view.rootContext().setContextProperty('i18n', cls.view.engine().evaluate('(function(s) { return s; })')); cls.view.setSource(QUrl.fromLocalFile(cls.tmp.name+'/main.qml')); cls.view.show(); cls.app.processEvents()
  cls.root=cls.view.rootObject()
  if cls.root is None: raise RuntimeError('QML component failed to load')
 def test_selections(self):
  item=self.root; distro=item.findChild(type(item),'distro'); kernel=item.findChild(type(item),'kernel')
  for selection, expected in [((True,True,True),'Ubuntu 26.04 Resolute Raccoon'),((True,False,False),'Ubuntu'),((False,True,False),'26.04'),((False,False,True),'Resolute Raccoon'),((False,False,False),'')]:
   for key,value in zip(('showDistroName','showDistroVersion','showDistroCodename'),selection): self.assertTrue(item.setProperty(key,value))
   item.setProperty('distroLayout',0); self.app.processEvents(); time.sleep(.05); self.app.processEvents()
   self.assertEqual(distro.property('text'),expected)
   self.assertEqual(distro.property('visible'),bool(expected))
   self.assertLessEqual(kernel.y()+kernel.height(),item.height())
  emptyHeight=item.property('implicitHeight')
  item.setProperty('showDistroName',True); item.setProperty('showDistroVersion',True); item.setProperty('showDistroCodename',True); item.setProperty('distroLayout',1); self.app.processEvents(); time.sleep(.05); self.app.processEvents()
  self.assertEqual(distro.property('text'),'Ubuntu\n26.04\nResolute Raccoon')
  self.assertGreater(item.property('implicitHeight'),emptyHeight)
  self.assertLessEqual(kernel.y()+kernel.height(),item.height())
  warning=item.findChild(type(item),'warning'); self.assertFalse(warning.property('visible'))
  item.setProperty('autoFitIssue','no-space'); self.app.processEvents(); time.sleep(.05); self.app.processEvents()
  self.assertTrue(warning.property('visible')); self.assertLessEqual(warning.mapToItem(item, QPointF(warning.width(), warning.height())).y(),item.height())
  item.setProperty('autoFitIssue',''); self.app.processEvents(); self.assertFalse(warning.property('visible'))
if __name__=='__main__': unittest.main()
