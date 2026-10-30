#!/usr/bin/env python3
"""Exercise actual Qt Quick CPU delegates, placement and scroll bounds."""
import os
import pathlib
import tempfile
import time
import unittest
os.environ.setdefault('QT_QPA_PLATFORM', 'offscreen')
os.environ.setdefault('QT_QUICK_BACKEND', 'software')
from PyQt6.QtCore import QObject, QUrl, Qt
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQuick import QQuickView
from PyQt6.QtTest import QTest
ROOT = pathlib.Path(__file__).resolve().parents[1]

class CpuColumnsTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.app = QGuiApplication.instance() or QGuiApplication([])
        cls.tmp = tempfile.TemporaryDirectory()
        cls.qml = pathlib.Path(cls.tmp.name) / 'cpu.qml'
        cls.qml.write_text('''import QtQuick
import "%s" as Components
Rectangle {
    id: root
    width: 1200; height: 800
    property int countWanted: 1
    property int columnsWanted: 1
    property bool frequencyWanted: false
    readonly property int columnsActual: list.columns
    readonly property int rowsActual: list.rows
    readonly property real maxHeight: list.maximumHeight
    readonly property real listHeight: list.height
    ListModel { id: cpus }
    function fill() { cpus.clear(); for (var i=0;i<countWanted;++i) cpus.append({cpuId:i*2, val:i%%100, frequencyHz:2400000000, hasFrequency:i%%2===0}) }
    onCountWantedChanged: fill()
    Component.onCompleted: fill()
    Components.CpuColumns {
        id: list; width: implicitWidth; height: implicitHeight
        model: cpus; requestedColumns: root.columnsWanted; showCpuFrequency: root.frequencyWanted
    }
}''' % (ROOT / 'plasmoid/contents/ui/components').as_uri())
        cls.view = QQuickView()
        cls.view.engine().globalObject().setProperty('i18n', cls.view.engine().evaluate('(function(s){ for(var i=1;i<arguments.length;i++)s=s.replace("%%"+i,arguments[i]);return s })'))
        cls.view.setSource(QUrl.fromLocalFile(str(cls.qml)))
        cls.view.show()
        cls.pump()
        if cls.view.status() != QQuickView.Status.Ready:
            raise RuntimeError(str(cls.view.errors()))
        cls.root = cls.view.rootObject()

    @classmethod
    def pump(cls):
        for _ in range(10): cls.app.processEvents(); time.sleep(.02)

    @classmethod
    def tearDownClass(cls):
        cls.view.close(); cls.tmp.cleanup()

    def test_order_count_and_scroll(self):
        for count in (1,4,12,40,64,128):
            for requested in (0,1,4,8):
                with self.subTest(count=count, columns=requested):
                    self.root.setProperty('countWanted',count)
                    self.root.setProperty('columnsWanted',requested)
                    self.pump()
                    cols=self.root.property('columnsActual')
                    rows=self.root.property('rowsActual')
                    def visual_items(item):
                        yield item
                        for child in item.childItems():
                            yield from visual_items(child)
                    items=list(visual_items(self.root))
                    delegates={int(o.objectName()[4:]):o for o in items if o.objectName().startswith('cpu_')}
                    self.assertEqual(set(delegates),set(range(count)))
                    for index,obj in delegates.items():
                        self.assertEqual(obj.property('cpuIndex'), index * 2)
                        self.assertAlmostEqual(obj.property('y'), (index % rows)*obj.property('height'), delta=.01)
                        self.assertAlmostEqual(obj.property('x'), (index // rows)*obj.property('width'), delta=.01)
                    self.assertLessEqual(self.root.property('listHeight'),self.root.property('maxHeight'))
                    scroll=next(o for o in items if o.objectName() == 'cpuScroll')
                    self.assertEqual(scroll.property('interactive'),scroll.property('contentHeight') > scroll.property('height'))
                    if scroll.property('interactive'):
                        scroll.forceActiveFocus()
                        QTest.keyClick(self.view, Qt.Key.Key_End)
                        self.assertGreater(scroll.property('contentY'),0)
                        QTest.keyClick(self.view, Qt.Key.Key_Home)
                        self.assertEqual(scroll.property('contentY'),0)
                    self.assertLessEqual(cols,8)

if __name__ == '__main__': unittest.main()
