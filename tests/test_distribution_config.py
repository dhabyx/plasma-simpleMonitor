#!/usr/bin/env python3
"""Exercise the content settings and synthetic preview without a Plasma session."""
import os
os.environ.setdefault('QT_QPA_PLATFORM', 'offscreen')
import pathlib
import unittest
from PyQt6.QtCore import QObject, QUrl
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQml import QQmlComponent, QQmlEngine

ROOT = pathlib.Path(__file__).resolve().parents[1]
APP = QGuiApplication.instance() or QGuiApplication([])

class DistributionConfig(unittest.TestCase):
    def setUp(self):
        self.engine = QQmlEngine()
        self.engine.rootContext().setContextProperty('i18n', self.engine.evaluate('(function(s) { return s; })'))

    def component(self, name):
        component = QQmlComponent(self.engine, QUrl.fromLocalFile(str(ROOT / 'plasmoid/contents/ui/config' / name)))
        obj = component.create()
        self.assertIsNotNone(obj, [e.toString() for e in component.errors()])
        return obj

    def test_layout_disabled_without_resetting_choice(self):
        root = self.component('ConfigGeneral.qml')
        selector = root.findChild(QObject, 'distroLayoutSelector')
        self.assertIsNotNone(selector)
        root.setProperty('cfg_showDistroName', True)
        root.setProperty('cfg_showDistroVersion', True)
        root.setProperty('cfg_distroLayout', 1)
        APP.processEvents()
        self.assertTrue(selector.property('enabled'))
        root.setProperty('cfg_showDistroVersion', False)
        APP.processEvents()
        self.assertFalse(selector.property('enabled'))
        self.assertEqual(root.property('cfg_distroLayout'), 1)
        root.setProperty('cfg_showDistroCodename', True)
        APP.processEvents()
        self.assertTrue(selector.property('enabled'))
        self.assertEqual(selector.property('currentIndex'), 1)

    def test_auto_fit_control_tracks_setting(self):
        root = self.component('ConfigSkins.qml')
        checkbox = root.findChild(QObject, 'autoFitContentCheck')
        self.assertIsNotNone(checkbox)
        root.setProperty('cfg_autoFitContent', False)
        APP.processEvents()
        self.assertFalse(checkbox.property('checked'))
        root.setProperty('cfg_autoFitContent', True)
        APP.processEvents()
        self.assertTrue(checkbox.property('checked'))

    def test_preview_reflects_selection(self):
        root = self.component('Preview.qml')
        self.assertEqual(len(root.property('distroFields').toVariant()), 3)
        root.setProperty('showDistroName', False)
        root.setProperty('showDistroVersion', False)
        root.setProperty('showDistroCodename', False)
        APP.processEvents()
        self.assertEqual(len(root.property('distroFields').toVariant()), 0)
        root.setProperty('showDistroName', True)
        APP.processEvents()
        self.assertEqual(root.property('distroFields').toVariant(), ['Example Linux'])

if __name__ == '__main__': unittest.main()
