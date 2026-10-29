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
    id: coreTempList

    property int direction: Qt.LeftToRight
    LayoutMirroring.enabled: direction === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int highTemp: 80
    property int criticalTemp: 95
    property int indicatorHeight: 10
    /* tempUnit
        used for change how to show temperature unit
        0=Celsius 1=Fahrenheit */
    property int tempUnit: 0

    implicitHeight: contentHeight
    implicitWidth: 100

    interactive: false

    FontLoader {
        id: doppioOneRegular
        source: "../../fonts/Doppio_One/DoppioOne-Regular.ttf"
    }

    delegate: Item {
        id: coreListTemp

        required property int index
        required property real val
        required property string dataUnits
        required property string coreLabelStr

        implicitWidth: coreLabel.implicitWidth + unitLabel.implicitWidth
        width: ListView.view.width
        height: 20 + coreTempList.indicatorHeight

        Text {
            id: coreLabel
            anchors.left: parent.left
            text: coreListTemp.coreLabelStr === "" ? i18n("CPU %1:", coreListTemp.index)
                                                    : coreListTemp.coreLabelStr
            font.bold: true
            font { family: doppioOneRegular.name; pointSize: 10 }
            color: "#ffdd55"
        }
        Text {
            id: unitLabel
            anchors.right: parent.right
            text: coreTempList.tempUnit === 0 ? Math.floor(coreListTemp.val) + coreListTemp.dataUnits
                                               : Math.floor(coreListTemp.val * 9 / 5 + 32) + "°F"
            font.bold: true
            font.pointSize: 10
            color: "white"
        }

        Rectangle {
            // Cropped view of the temperature gradient; grows from the start edge.
            id: tempBar
            anchors.top: coreLabel.bottom
            anchors.topMargin: 1
            anchors.left: parent.left
            height: 11
            width: Math.max(0, Math.min(parent.width, Math.floor(coreListTemp.val / coreTempList.criticalTemp * parent.width)))
            color: "transparent"
            clip: true

            Rectangle {
                // Blue to red gradient spanning the whole bar; tempBar crops it.
                // Gradient stops don't follow LayoutMirroring, so mirror them by hand.
                id: tempGradient
                readonly property bool mirrored: LayoutMirroring.enabled
                anchors.left: parent.left
                height: tempBar.height
                width: coreListTemp.width
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: tempGradient.mirrored ? 1.00 : 0.00; color: "#85a9ff" }
                    GradientStop { position: tempGradient.mirrored ? 0.00 : 1.00; color: "red" }
                }
            }
        }
    }
}
