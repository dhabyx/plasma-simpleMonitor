#!/usr/bin/env python3
"""Configuration presents KDE's logical CPU semantics and preserves indices."""
import os, pathlib, unittest, xml.etree.ElementTree as ET
os.environ.setdefault('QT_QPA_PLATFORM', 'offscreen')
from PyQt6.QtCore import QObject, QUrl
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQml import QQmlComponent, QQmlEngine
ROOT=pathlib.Path(__file__).resolve().parents[1]
APP=QGuiApplication.instance() or QGuiApplication([])
class TemperatureSettings(unittest.TestCase):
 def test_logical_cpu_label_and_help(self):
  engine=QQmlEngine(); engine.rootContext().setContextProperty('i18n',engine.evaluate('(function(s) { return s; })'))
  component=QQmlComponent(engine,QUrl.fromLocalFile(str(ROOT/'plasmoid/contents/ui/config/ConfigMisc.qml')))
  root=component.create(); self.assertIsNotNone(root,[e.toString() for e in component.errors()])
  items=root.findChildren(QObject)
  combos=[]
  for item in items:
   model=item.property('model')
   if model is not None and hasattr(model,'toVariant'): model=model.toVariant()
   if isinstance(model,list) and 'Average' in model and 'Maximum' in model: combos.append(model)
  self.assertTrue(combos)
  self.assertTrue(all(model == ['Per logical CPU','Average','Maximum'] for model in combos))
  self.assertTrue(any(item.property('text') == 'Some logical CPUs may share a temperature sensor.' for item in items))
 def test_grouping_default_and_mode_dependency(self):
  schema=ET.parse(ROOT/'plasmoid/contents/config/main.xml')
  entry=schema.find('.//{http://www.kde.org/standards/kcfg/1.0}entry[@name="groupCpuTemperatures"]')
  self.assertIsNotNone(entry)
  self.assertEqual(entry.get('type'),'Bool')
  self.assertEqual(entry.findtext('{http://www.kde.org/standards/kcfg/1.0}default'),'false')
  engine=QQmlEngine(); engine.rootContext().setContextProperty('i18n',engine.evaluate('(function(s) { return s; })'))
  component=QQmlComponent(engine,QUrl.fromLocalFile(str(ROOT/'plasmoid/contents/ui/config/ConfigMisc.qml')))
  root=component.create(); self.assertIsNotNone(root,[e.toString() for e in component.errors()])
  group=root.findChild(QObject,'groupCpuTemperaturesCheck'); self.assertIsNotNone(group)
  root.setProperty('cfg_groupCpuTemperatures',True); root.setProperty('cfg_cpuTempMode',0); APP.processEvents()
  self.assertTrue(group.property('enabled')); self.assertTrue(group.property('checked'))
  root.setProperty('cfg_cpuTempMode',1); APP.processEvents()
  self.assertFalse(group.property('enabled')); self.assertTrue(group.property('checked'))
  root.setProperty('cfg_cpuTempMode',2); APP.processEvents()
  self.assertFalse(group.property('enabled')); self.assertTrue(root.property('cfg_groupCpuTemperatures'))
  root.setProperty('cfg_cpuTempMode',0); APP.processEvents()
  self.assertTrue(group.property('enabled')); self.assertTrue(group.property('checked'))
if __name__ == '__main__': unittest.main()
