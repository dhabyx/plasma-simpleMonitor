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

import QtQuick 2.0

ListView {
    id: coreTempList

    property int direction: Qt.LeftToRight
    LayoutMirroring.enabled: direction === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    implicitHeight: count * 25
    implicitWidth: 100

    interactive: false

    property int highTemp: 87
    property int criticalTemp : 105
    /* tempUnit
        used for change how to show temperature unit
        0=Celsius 1=Fahrenheit */
    property int tempUnit: 0

    delegate: Item {
        id: coreListTemp
        implicitHeight: 25
        implicitWidth: coreLabel.implicitWidth + unitLabel.implicitWidth
        width: parent.width
        Text {
            id: coreLabel
            anchors.left: parent.left
            text: i18n('Core %1:', model.index)
            font.bold: true
            font { family: doppioOneRegular.name; pointSize: 10 }
            color: "#ffdd55"
        }
        Text {
            id: unitLabel
            text: if (tempUnit === 0) Math.floor(val) + units
                  else Math.floor(val*9/5+32) + "°F"
            font.bold: true
            font.pointSize: 10
            color: "white"
            anchors.right: parent.right
        }

        Rectangle {
            id: rectValue
            height: 9
            width: Math.floor(val/coreTempList.criticalTemp*parent.width)
            color: if (val >= coreTempList.criticalTemp) "red"
                   else if (val >= coreTempList.highTemp) "#ffac2a"
                   else "#85a9ff"
            anchors.top: coreLabel.bottom
            anchors.right: parent.right
            anchors.topMargin: 1
        }
        ListView.onAdd: SequentialAnimation {
            PropertyAction { target: coreListTemp; property: "height"; value: 0 }
            NumberAnimation { target: coreListTemp; property: "height"; to: 25; duration: 250; easing.type: Easing.InOutQuad }
        }
    }

    FontLoader {
        id: doppioOneRegular
        source: "../../fonts/Doppio_One/DoppioOne-Regular.ttf"
    }
}
