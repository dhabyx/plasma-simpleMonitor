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
import QtQuick.Layouts 1.1

Item {
    property double memFree: 0.0
    property double memTotal: 0.0
    property double memCached: 0.0
    property double memUsed: 0.0
    property double memBuffers: 0.0
    property alias memTypeLabel : memType.text

    implicitWidth: memColumn.implicitWidth
    implicitHeight: memColumn.implicitHeight

    FontLoader {
        id: doppioOneRegular
        source: "../../fonts/Doppio_One/DoppioOne-Regular.ttf"
    }

    ColumnLayout {
        id: memColumn

        spacing: 2
        anchors.fill: parent

        RowLayout {
            spacing: 3
            Text {
                id: memType
                text: i18n("Mem:")
                font { family: doppioOneRegular.name; pointSize: 12 }
                color: "#ffdd55"
            }
            Text {
                text: i18n("%1 GiB", memTotal.toFixed(2))
                font { family: doppioOneRegular.name; pointSize: 12 }
                color: "white"
            }
        }

        RowLayout {
            id: memoryInfoLabels
            spacing: 3
            property int fontSize : 8
            Text {
                text: i18n("Used:")
                color: "red"
                font.pointSize: memoryInfoLabels.fontSize
            }
            Text {
                id: memUsedText
                text: i18n("%1 GiB", (memUsed-(memBuffers+memCached)).toFixed(2))
                color: "white"
                font.pointSize: memoryInfoLabels.fontSize
            }
            Text {
                text: i18n("Free:")
                color: "#7ec264"
                font.pointSize: memoryInfoLabels.fontSize
            }
            Text {
                id: memFreeText
                text: i18n("%1 GiB", (memFree+(memBuffers+memCached)).toFixed(2))
                color: "white"
                font.pointSize: memoryInfoLabels.fontSize
            }
        }

        Rectangle {
            id: rectTotalMemory
            height: 5
            Layout.fillWidth: true
            color: "#7ec264"
            Rectangle {
                id: rectUsedMemory
                anchors.left: parent.left
                height: parent.height
                width: (memUsed-(memBuffers+memCached))/memTotal*parent.width
                color: "red"
            }
        }
    }
}
