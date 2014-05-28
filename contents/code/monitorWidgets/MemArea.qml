/**
 * Copyright 2013-2014 Dhaby Xiloj
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

import QtQuick 1.1

Item {
    property double memFree: 0.0
    property double memTotal: 0.0
    property double memCached: 0.0
    property double memUsed: 0.0
    property double memBuffers: 0.0
    property alias memTypeLabel : memType.text
    FontLoader {
        id: doppioOneRegular
        source: "../fonts/Doppio_One/DoppioOne-Regular.ttf"
    }
    Column {
        anchors.fill: parent
        Rectangle {
            id: topMemArea
            height: 3
            width: parent.width
            color: "white"
        }
        Row {
            spacing: 3
            Text {
                id: memType
                text: qsTr("Mem:")
                font { family: doppioOneRegular.name; pointSize: 12 }
                color: "#ffdd55"
            }
            Text {
                text: memTotal.toFixed(2)+" GiB"
                font { family: doppioOneRegular.name; pointSize: 12 }
                color: "white"
            }
        }
        
        Row {
            id: memoryInfoLabels
            spacing: 3
            property int fontSize : 8
            Text {
                text: qsTr("Used:")
                color: "red"
                font.pointSize: memoryInfoLabels.fontSize
            }
            Text {
                id: memUsedText
                text: (memUsed-(memBuffers+memCached)).toFixed(2) +" GiB"
                color: "white"
                font.pointSize: memoryInfoLabels.fontSize
            }
            Text {
                text: qsTr("Free")
                color: "#7ec264"
                font.pointSize: memoryInfoLabels.fontSize
            }
            Text {
                id: memFreeText
                text: (memFree+(memBuffers+memCached)).toFixed(2)+" GiB"
                color: "white"
                font.pointSize: memoryInfoLabels.fontSize
            }
        }
        
        Rectangle {
            id: rectTotalMemory
            height: 5
            width: parent.width
            color: "#7ec264"
            Rectangle {
                id: rectUsedMemory
                height: parent.height
                width: (memUsed-(memBuffers+memCached))/memTotal*parent.width
                color: "red"
            }
        }
    }
}
