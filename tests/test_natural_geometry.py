#!/usr/bin/env python3
"""Real QML skin geometries at natural height and with 300px spare space."""
import os,pathlib,shutil,tempfile,time,unittest
os.environ.setdefault('QT_QPA_PLATFORM','offscreen')
os.environ.setdefault('QT_QUICK_BACKEND','software')
from PyQt6.QtCore import QPointF,QUrl
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQuick import QQuickView
ROOT=pathlib.Path(__file__).resolve().parents[1]
QML = r'''
import QtQuick
import "@PLASMOID@/contents/ui/skins" as Skins
Rectangle {
    id: harness
    width: 490; height: 1800; color: "#20242b"
    property bool natural: true
    property int temperatureCount: 6
    onTemperatureCountChanged: setTemps(temperatureCount)
    property bool showGpu: false
    onShowGpuChanged: setGpu(showGpu)
    property int testCount: 12
    onTestCountChanged: setCount(testCount)
    readonly property real skinHeight: loader.item ? loader.item.implicitHeight : 0
    property int skin: 0
    property bool compact: false
    property bool showLogo: true
    property int dateVisibility: 0
    property int timeVisibility: 0
    property bool showFreq: false
    property int cpuColumns: 1
    ListModel { id: cpus }
    ListModel { id: cores }
    ListModel { id: gpus }
    QtObject {
        id: data
        property int bgColor: 1
        property int logo: 1
        property string customLogo: ""
        property real logoScale: 1
        property bool logoEditMode: false
        property bool showLogo: harness.showLogo
        property bool showCpuFrequency: harness.showFreq
        property bool compactLayout: harness.compact
        property int dateVisibility: harness.dateVisibility
        property int timeVisibility: harness.timeVisibility
        property int cpuColumns: harness.cpuColumns
        property bool showGpuTemp: harness.showGpu
        property bool showSwap: true
        property bool showUptime: true
        property bool showNetwork: true
        property int netUnit: 0
        property int tempUnit: 0
        property int cpuHighTemp: 87
        property int cpuCritTemp: 105
        property bool coloredCpuLoad: true
        property bool flatCpuLoad: true
        property int indicatorHeight: 10
        property real updateInterval: 2
        property string distroName: "Very long Linux distribution name for visual checks"
        property string distroVersion: "26.04"
        property string distroKey: ""
        property string osLogoIcon: ""
        property string kernelName: "Linux"
        property string kernelVersion: "7.0.0"
        property real memFree: 8
        property real memTotal: 16
        property real memUsed: 8
        property real swapFree: 8
        property real swapTotal: 8
        property real swapUsed: 0
        property real netDown: 0
        property real netUp: 0
        property real netScale: 1
        property string netIface: ""
        property string netIp: ""
        property bool showPing: false
        property real pingMs: -1
        property real uptime: 100
        property real avgLoad: 25
        property real avgTemp: 48
        property bool hasAvgFrequency: true
        property real avgFrequencyHz: 2800000000
        property var cpuModel: cpus
        property var coreTempModel: cores
        property var gpuTempModel: gpus
    }
    function setCount(n) { cpus.clear(); for (var i=0;i<n;i++) cpus.append({cpuId:i,val:i % 100, frequencyHz:2400000000+i*1000000, hasFrequency:i % 2 === 0}) }
    function setGpu(enabled) { gpus.clear(); if (enabled) gpus.append({val:55, gpuIndex:0, gpuLabelStr:"GPU:", dataUnits:"°C"}) }
    function setTemps(n) { cores.clear(); for (var i=0;i<n;i++) cores.append({val:48,hasValue:true,coreLabelStr:"CPU "+i+":",dataUnits:"°C"}) }
    function reload() { loader.setSource(["@PLASMOID@/contents/ui/skins/DefaultSkin.qml","@PLASMOID@/contents/ui/skins/ColumnSkin.qml","@PLASMOID@/contents/ui/skins/MinimalisticSkin.qml"][skin], {engine: data}) }
    Component.onCompleted: { setCount(testCount); setTemps(temperatureCount); reload() }
    Loader { id: loader; objectName: "test_loader"; x: 5; y: 5; width: harness.width - 10; height: harness.natural ? implicitHeight : implicitHeight + 300 }
    onSkinChanged: reload()
}
'''

class NaturalGeometry(unittest.TestCase):
 @classmethod
 def setUpClass(cls):
  cls.app=QGuiApplication.instance() or QGuiApplication([])
  cls.temp=tempfile.TemporaryDirectory(prefix='simplemonitor-layout-')
  plasmoid=pathlib.Path(cls.temp.name)/'plasmoid'
  shutil.copytree(ROOT/'plasmoid',plasmoid)
  for name in ('DefaultSkin','ColumnSkin','MinimalisticSkin'):
   p=plasmoid/'contents/ui/skins'/f'{name}.qml'; s=p.read_text()
   for typ,tag in [('DistroBlock','test_distro'),('CoreTempList','test_temps'),('CpuColumns','test_cpus'),('MemArea','test_memory'),('NetArea','test_network')]:
    s=s.replace(typ+' {',typ+' {\n            objectName: "'+tag+'"')
   p.write_text(s)
  net=plasmoid/'contents/ui/monitorWidgets/NetArea.qml'; source=net.read_text()
  source=source.replace('Rectangle {\n            height: 4','Rectangle {\n            objectName: "test_netbar"\n            height: 4')
  net.write_text(source)
  qml=pathlib.Path(cls.temp.name)/'main.qml';qml.write_text(QML.replace('@PLASMOID@',plasmoid.as_uri()))
  cls.view=QQuickView();cls.view.engine().globalObject().setProperty('i18n',cls.view.engine().evaluate('(function(s){for(var i=1;i<arguments.length;i++)s=s.replace("%"+i,arguments[i]);return s})'))
  cls.view.setSource(QUrl.fromLocalFile(str(qml)));cls.view.show();cls.pump()
  if cls.view.status()!=QQuickView.Status.Ready: raise RuntimeError(str(cls.view.errors()))
  cls.root=cls.view.rootObject()
 @classmethod
 def pump(cls):
  for _ in range(12):cls.app.processEvents();time.sleep(.015)
 @classmethod
 def tearDownClass(cls):
  cls.view.close();cls.temp.cleanup()
 def item_positions(self):
  def walk(o):
   yield o
   for ch in o.childItems():yield from walk(ch)
  result={}
  for item in walk(self.root):
   tag=item.objectName()
   if tag.startswith('test_') and item.isVisible() and tag not in result:
    result[tag]=item.mapToScene(QPointF(0,0)).y()
  return result
 def set_options(self,**kwargs):
  for k,v in kwargs.items():self.root.setProperty(k,v)
  self.pump()
 def test_content_stays_at_top_with_extra_window_height(self):
  for skin in range(3):
   for scenario in ({'showFreq':False,'cpuColumns':1,'showLogo':True,'temperatureCount':6},
                    {'showFreq':True,'cpuColumns':1,'showLogo':True,'temperatureCount':6},
                    {'showFreq':False,'cpuColumns':2,'showLogo':False,'temperatureCount':1}):
    with self.subTest(skin=skin,scenario=scenario):
     self.set_options(skin=skin,natural=True,**scenario);natural=self.item_positions()
     self.set_options(natural=False);tall=self.item_positions()
     self.assertIn('test_distro',natural);self.assertIn('test_memory',natural)
     for name,y in natural.items():
      self.assertIn(name,tall)
      self.assertAlmostEqual(tall[name],y,delta=3,msg=f'{name} moved when window grew: {natural} -> {tall}')
 def test_natural_dimensions_follow_content(self):
  for skin in range(3):
   with self.subTest(skin=skin):
    self.set_options(skin=skin,natural=True,showFreq=False,cpuColumns=1,showLogo=True,temperatureCount=6)
    base=self.root.property('skinHeight')
    self.set_options(showFreq=True);with_frequency=self.root.property('skinHeight')
    self.assertGreaterEqual(with_frequency,base)
    self.set_options(showFreq=False,cpuColumns=2,showLogo=False,temperatureCount=1)
    self.assertLessEqual(self.root.property('skinHeight'),base)

 def test_network_bars_fit_when_gpu_arrives(self):
  def walk(o):
   yield o
   for ch in o.childItems(): yield from walk(ch)
  for skin in range(3):
   with self.subTest(skin=skin):
    self.set_options(skin=skin,natural=True,showGpu=False,showFreq=False,cpuColumns=1,showLogo=True,temperatureCount=6)
    self.set_options(showGpu=True)
    items=list(walk(self.root))
    loader=next(o for o in items if o.objectName()=='test_loader')
    bars=[o for o in items if o.objectName()=='test_netbar' and o.isVisible()]
    self.assertEqual(len(bars),2)
    for bar in bars:
     self.assertEqual(bar.height(),4)
     bottom=bar.mapToScene(QPointF(0,bar.height())).y()
     self.assertLessEqual(bottom,loader.mapToScene(QPointF(0,loader.height())).y()+0.5)

if __name__=='__main__':unittest.main()
