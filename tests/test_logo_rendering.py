#!/usr/bin/env python3
"""Optional Qt 6 runtime check: run with /usr/bin/python3 when PyQt6 is installed."""
import os
import pathlib
import tempfile
import time
import unittest

os.environ.setdefault('QT_QPA_PLATFORM', 'offscreen')
os.environ.setdefault('QT_QUICK_BACKEND', 'software')
from PyQt6.QtCore import QUrl
from PyQt6.QtGui import QGuiApplication, QIcon, QImage, QColor
from PyQt6.QtQuick import QQuickView

ROOT = pathlib.Path(os.environ.get('SIMPLEMONITOR_ROOT', pathlib.Path(__file__).resolve().parents[1]))

class LogoRendering(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.app = QGuiApplication.instance() or QGuiApplication([])
        QIcon.setThemeSearchPaths(['/usr/share/icons'])
        QIcon.setThemeName('breeze')
        cls.temp = tempfile.TemporaryDirectory()
        cls.qml = pathlib.Path(cls.temp.name) / 'main.qml'
        component = (ROOT / 'plasmoid/contents/ui/components').as_uri()
        image = (ROOT / 'plasmoid/contents/images/distro-linuxmint.svg').as_uri()
        cls.qml.write_text('''import QtQuick
import "%s" as Components
Rectangle {
    id: root
    width: 180; height: 100
    property url chosenSource: "%s"
    property string chosenIcon: ""
    readonly property bool iconInUse: logo.useIcon
    property alias logo: logo
    readonly property real loadedWidth: logo.image.implicitWidth
    readonly property real paintedWidth: logo.image.paintedWidth
    readonly property real paintedHeight: logo.image.paintedHeight
    Components.LogoImage { id: logo; width: 180; height: 100
        iconName: root.chosenIcon
        image.source: root.chosenSource
    }
}''' % (component, image))
        cls.view = QQuickView()
        cls.view.setSource(QUrl.fromLocalFile(str(cls.qml)))
        cls.view.show()
        for _ in range(40):
            cls.app.processEvents()
            time.sleep(.025)
        if cls.view.status() != QQuickView.Status.Ready:
            raise RuntimeError(str(cls.view.errors()))
        cls.logo = cls.view.rootObject().property('logo')
        cls.root = cls.view.rootObject()

    @classmethod
    def tearDownClass(cls):
        cls.view.close()
        cls.temp.cleanup()

    def setUp(self):
        self.logo.setProperty('fillScale', 1.0)
        self.root.setProperty('chosenIcon', '')
        self.root.setProperty('chosenSource', QUrl.fromLocalFile(str(ROOT / 'plasmoid/contents/images/distro-linuxmint.svg')))
        for _ in range(10):
            self.app.processEvents()
            time.sleep(.025)

    def test_small_intrinsic_svg_is_rasterized_sharp(self):
        # Linux Mint's SVG has a 24x24 viewBox; display must not stretch a
        # 24-pixel raster to 100 px. PreserveAspectFit still draws it at 100 px.
        self.assertGreaterEqual(self.root.property('loadedWidth'), 200)
        self.assertAlmostEqual(self.root.property('paintedWidth'), 100, delta=1)
        self.assertAlmostEqual(self.root.property('paintedHeight'), 100, delta=1)

    def test_custom_raster_and_theme_icon(self):
        png = pathlib.Path(self.temp.name) / 'custom.png'
        picture = QImage(640, 320, QImage.Format.Format_ARGB32)
        picture.fill(QColor('#d25722'))
        self.assertTrue(picture.save(str(png)))
        self.root.setProperty('chosenSource', QUrl.fromLocalFile(str(png)))
        for _ in range(20):
            self.app.processEvents()
            time.sleep(.025)
        self.assertAlmostEqual(self.root.property('paintedWidth'), 180, delta=1)
        self.assertAlmostEqual(self.root.property('paintedHeight'), 90, delta=1)
        self.assertFalse(QIcon.fromTheme('application-x-executable').isNull(), 'test requires the installed Breeze icon')
        self.root.setProperty('chosenIcon', 'application-x-executable')
        for _ in range(20):
            self.app.processEvents()
            time.sleep(.025)
        self.assertTrue(self.root.property('iconInUse'))
        self.root.setProperty('chosenIcon', 'definitely-missing-icon-xyz')
        for _ in range(20):
            self.app.processEvents()
            time.sleep(.025)
        self.assertFalse(self.root.property('iconInUse'))
        self.root.setProperty('chosenIcon', '')
        self.root.setProperty('chosenSource', QUrl.fromLocalFile(str(ROOT / 'plasmoid/contents/images/distro-linuxmint.svg')))
        for _ in range(10):
            self.app.processEvents()
            time.sleep(.025)

    def test_scale_is_respected(self):
        self.logo.setProperty('fillScale', 0.5)
        self.app.processEvents()
        self.assertAlmostEqual(self.root.property('paintedWidth'), 50, delta=1)
        self.assertAlmostEqual(self.root.property('paintedHeight'), 50, delta=1)
        self.logo.setProperty('fillScale', 1.0)

class WideLogoLayout(unittest.TestCase):
    def test_wide_custom_logo_uses_available_width(self):
        app = QGuiApplication.instance() or QGuiApplication([])
        with tempfile.TemporaryDirectory() as folder:
            folder = pathlib.Path(folder)
            svg = folder / 'wide.svg'
            svg.write_text('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 100"><rect width="400" height="100" fill="red"/></svg>')
            component = (ROOT / 'plasmoid/contents/ui/components').as_uri()
            qml = folder / 'layout.qml'
            qml.write_text('''import QtQuick
import "%s" as Components
Rectangle {
    width: 180; height: 180
    QtObject { id: data
        property int logo: 26
        property string customLogo: "%s"
        property string distroKey: ""
        property string osLogoIcon: ""
        property bool logoEditMode: false
        property real logoScale: 1
        property string distroName: "Test"
        property string distroVersion: ""
        property string kernelName: "Linux"
        property string kernelVersion: "1"
    }
    Components.DistroBlock { id: block; width: 180; height: 180; engine: data }
    readonly property var logoItem: block.children.find(child => child.image !== undefined)
    readonly property real paintedWidth: logoItem.image.paintedWidth
    readonly property real paintedHeight: logoItem.image.paintedHeight
}
''' % (component, svg.as_uri()))
            view = QQuickView()
            view.setSource(QUrl.fromLocalFile(str(qml)))
            view.show()
            for _ in range(40):
                app.processEvents()
                time.sleep(.025)
            self.assertEqual(view.status(), QQuickView.Status.Ready, str(view.errors()))
            self.assertAlmostEqual(view.rootObject().property('paintedWidth'), 160, delta=1)
            self.assertAlmostEqual(view.rootObject().property('paintedHeight'), 40, delta=1)
            view.close()

if __name__ == '__main__':
    unittest.main()
