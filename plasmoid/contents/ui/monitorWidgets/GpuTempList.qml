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

ListView {
    id: gpuTempList

    property int direction: Qt.LeftToRight
    LayoutMirroring.enabled: direction === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int highTemp: 80
    property int criticalTemp: 95
    property int maxTemp: 100
    property int indicatorHeight: 10
    property bool showGpuTemp: true
    /* tempUnit
        used for change how to show temperature unit
        0=Celsius 1=Fahrenheit */
    property int tempUnit: 0

    implicitHeight: showGpuTemp ? contentHeight : 0
    implicitWidth: 100
    visible: showGpuTemp

    interactive: false

    FontLoader {
        id: doppioOneRegular
        source: "../../fonts/Doppio_One/DoppioOne-Regular.ttf"
    }

    delegate: Item {
        id: gpuListTemp

        required property int index
        required property real val
        required property string dataUnits
        required property string gpuLabelStr

        implicitWidth: gpuLabel.implicitWidth + unitLabel.implicitWidth
        width: ListView.view.width
        height: 20 + gpuTempList.indicatorHeight

        Text {
            id: gpuLabel
            anchors.left: parent.left
            text: gpuListTemp.gpuLabelStr === "" ? i18n("GPU %1:", gpuListTemp.index)
                                                  : gpuListTemp.gpuLabelStr
            font.bold: true
            font { family: doppioOneRegular.name; pointSize: 10 }
            color: "#ffdd55"
        }
        Text {
            id: unitLabel
            anchors.right: parent.right
            text: gpuTempList.tempUnit === 0 ? Math.round(gpuListTemp.val) + gpuListTemp.dataUnits
                                              : Math.round(gpuListTemp.val * 9 / 5 + 32) + "°F"
            font.bold: true
            font.pointSize: 10
            color: "white"
        }

        Rectangle {
            anchors.top: gpuLabel.bottom
            anchors.topMargin: 1
            anchors.right: parent.right
            height: gpuTempList.indicatorHeight
            width: Math.max(0, Math.min(parent.width, Math.round(gpuListTemp.val / gpuTempList.maxTemp * parent.width)))
            color: Math.round(gpuListTemp.val) >= gpuTempList.criticalTemp ? "red"
                 : Math.round(gpuListTemp.val) >= gpuTempList.highTemp ? "#ffac2a"
                 : "#85a9ff"
        }
    }
}
