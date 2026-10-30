/**
 * Copyright 2013-2016 Dhaby Xiloj, Konstantin Shtepa
 *
 * This file is part of plasma-simpleMonitor.
 *
 * plasma-simpleMonitor is free software: you can redistribute it
 * and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or any later version.
 *
 * plasma-simpleMonitor is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with plasma-simpleMonitor.  If not, see <http://www.gnu.org/licenses/>.
 **/

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import "components"
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root

    readonly property var skinSources: [
        "skins/DefaultSkin.qml",
        "skins/ColumnSkin.qml",
        "skins/MinimalisticSkin.qml"
    ]

    property string autoFitIssue: ""

    preferredRepresentation: fullRepresentation

    Plasmoid.backgroundHints: {
        switch (sys.bgColor) {
        case 0:  return PlasmaCore.Types.StandardBackground
        case 2:  return PlasmaCore.Types.TranslucentBackground
        default: return PlasmaCore.Types.NoBackground
        }
    }

    SystemData {
        id: sys
        autoFitIssue: root.autoFitIssue
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Refresh CPU grouping")
            icon.name: "view-refresh"
            enabled: sys.groupCpuTemperatures && sys.cpuTempMode === 0
            onTriggered: sys.cpuGrouping.refresh()
        },
        PlasmaCore.Action {
            text: i18n("Retry fitting size to content")
            icon.name: "view-refresh"
            enabled: Plasmoid.configuration.autoFitContent
            onTriggered: if (root.fullRepresentationItem) root.fullRepresentationItem.requestAutoFit()
        },
        PlasmaCore.Action {
            text: sys.logoEditMode ? i18n("Lock image scaling") : i18n("Unlock image scaling")
            icon.name: sys.logoEditMode ? "object-locked" : "transform-scale"
            onTriggered: sys.logoEditMode = !sys.logoEditMode
        }
    ]

    fullRepresentation: Rectangle {
        id: background

        readonly property int skinIndex: sys.skin >= 0 && sys.skin < root.skinSources.length ? sys.skin : 0

        implicitWidth: loader.implicitWidth
        implicitHeight: loader.implicitHeight

        Layout.minimumWidth: implicitWidth
        Layout.minimumHeight: implicitHeight
        Layout.preferredWidth: implicitWidth
        Layout.preferredHeight: implicitHeight

        color: sys.bgColor === 0 ? "black" : "transparent"

        onSkinIndexChanged: loadSkin()
        Component.onCompleted: loadSkin()

        function loadSkin() {
            loader.setSource(root.skinSources[skinIndex], { engine: sys })
        }

        property var desktopFit: null
        function requestAutoFit() {
            if (!Plasmoid.configuration.autoFitContent) { root.autoFitIssue = ""; return }
            if (windowFit.supported) { root.autoFitIssue = ""; windowFit.requestFit(); return }
            if (Qt.application.name !== "plasmashell") { root.autoFitIssue = "unsupported"; return }
            if (!desktopFit) {
                const component = Qt.createComponent("components/DesktopAutoFit.qml")
                if (component.status === Component.Ready) desktopFit = component.createObject(background, {appletItem: root})
            }
            if (!desktopFit || !desktopFit.supported) { root.autoFitIssue = "unsupported"; return }
            if (!desktopSettle.running) desktopSettle.start()
        }
        Timer {
            id: desktopSettle
            interval: 750
            onTriggered: {
                if (!Plasmoid.configuration.autoFitContent || !background.desktopFit) return
                background.desktopFit.targetWidth = background.implicitWidth
                background.desktopFit.targetHeight = background.implicitHeight
                background.desktopFit.apply()
                const status = background.desktopFit.result
                root.autoFitIssue = status === "no-space" ? "no-space" : (status === "unsupported" ? "unsupported" : "")
            }
        }
        Connections {
            target: background.desktopFit
            ignoreUnknownSignals: true
            function onRetryRequested() { background.requestAutoFit() }
            function onSupportedChanged() { background.requestAutoFit() }
        }
        Connections {
            target: Plasmoid.configuration
            function onAutoFitContentChanged() { background.requestAutoFit() }
        }
        onImplicitWidthChanged: if (Qt.application.name === "plasmashell") requestAutoFit()
        onImplicitHeightChanged: if (Qt.application.name === "plasmashell") requestAutoFit()
        Component.onDestruction: root.autoFitIssue = ""
        Timer { interval: 1200; running: true; onTriggered: background.requestAutoFit() }

        AutoFitWindow {
            id: windowFit
            enabled: Plasmoid.configuration.autoFitContent
            applicationName: Qt.application.name
            targetWindow: background.Window.window
            ownerWindow: root.Window.window
            contentWidth: background.implicitWidth
            contentHeight: background.implicitHeight
        }

        Loader {
            id: loader
            anchors.fill: parent
        }
    }
}
