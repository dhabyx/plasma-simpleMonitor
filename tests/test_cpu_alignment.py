import os,re,tempfile,time
from pathlib import Path
os.environ['QT_QPA_PLATFORM']='offscreen';os.environ['QT_QUICK_BACKEND']='software'
from PyQt6.QtCore import QUrl
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQuick import QQuickView
repo=Path(__file__).resolve().parents[1]
app=QGuiApplication([])
for name in ['DefaultSkin','ColumnSkin']:
 s=(repo/('plasmoid/contents/ui/skins/'+name+'.qml')).read_text();start=s.index('        CpuColumns {');end=s.index('\n        }',start)+10
 block=s[start:end]
 qml='''import QtQuick
import QtQuick.Layouts
import "%s"
Item { id: root; width:500; height:750
property int cpuColumns:1
property bool showCpuFrequency:false
property bool coloredCpuLoad:true
property bool flatCpuLoad:true
property int indicatorHeight:10
property int direction:Qt.LeftToRight
property int blockMargin:5
property alias cpuModel: cpus
ListModel { id:cpus }
Component.onCompleted: { for(var i=0;i<12;i++)cpus.append({cpuId:i,val:20,frequencyHz:3000000000,hasFrequency:true}) }
GridLayout { anchors.fill:parent; columns:2
Item { Layout.rowSpan:7; Layout.minimumHeight:700; Layout.minimumWidth:200 }
%s
}
}'''%((repo/'plasmoid/contents/ui/components').as_uri(),block)
 with tempfile.TemporaryDirectory() as t:
  p=Path(t)/'test.qml';p.write_text(qml)
  v=QQuickView();v.engine().globalObject().setProperty('i18n',v.engine().evaluate('(function(s){return s})'));v.setSource(QUrl.fromLocalFile(str(p)));v.show()
  assert not v.errors(),v.errors()
  def walk(item):
   yield item
   for c in item.childItems():yield from walk(c)
  for enabled in [False,True,False]:
   v.rootObject().setProperty('showCpuFrequency',enabled)
   for _ in range(5):app.processEvents();time.sleep(.03)
   cpu=next(o for o in walk(v.rootObject()) if o.property('requestedColumns') is not None)
   print(name,enabled,'y=',cpu.y(),flush=True)
   assert cpu.y()<=6, 'CPU list must align with top margin'
  v.close()
