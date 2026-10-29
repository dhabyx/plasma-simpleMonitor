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

Item {
    id: root

    property real avgLoad: 0
    property real avgTemp: 0
    property int tempUnit: 0
    property int highTemp: 87
    property int criticalTemp: 105

    readonly property int load: Math.round(avgLoad)
    readonly property int temp: Math.round(avgTemp)

    implicitWidth: cpuColumn.implicitWidth
    implicitHeight: cpuColumn.implicitHeight

    FontLoader {
        id: doppioOneRegular
        source: "../../fonts/Doppio_One/DoppioOne-Regular.ttf"
    }

    ColumnLayout {
        id: cpuColumn

        spacing: 2
        anchors.fill: parent

        RowLayout {
            spacing: 3
            Text {
                text: i18n("CPU:")
                font { family: doppioOneRegular.name; pointSize: 12 }
                color: "#ffdd55"
            }
            Text {
                text: i18n("%1%", root.load)
                font { family: doppioOneRegular.name; pointSize: 12 }
                color: root.load < 80 ? "white" : "red"
            }
            Text {
                visible: root.temp > 0
                text: root.tempUnit ? Math.floor(root.temp * 9 / 5 + 32) + "°F" : root.temp + "°C"
                font { family: doppioOneRegular.name; pointSize: 12 }
                color: root.temp >= root.criticalTemp ? "red"
                     : root.temp >= root.highTemp ? "#ffcc00"
                     : "white"
            }
        }

        Rectangle {
            height: 5
            Layout.fillWidth: true
            color: "#7ec264"
            Rectangle {
                anchors.left: parent.left
                height: parent.height
                width: Math.min(root.load, 100) / 100 * parent.width
                color: "red"
            }
        }
    }
}
