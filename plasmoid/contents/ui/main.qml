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
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root

    readonly property var skinSources: [
        "skins/DefaultSkin.qml",
        "skins/ColumnSkin.qml",
        "skins/MinimalisticSkin.qml"
    ]

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
    }

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

        Loader {
            id: loader
            anchors.fill: parent
        }
    }
}
