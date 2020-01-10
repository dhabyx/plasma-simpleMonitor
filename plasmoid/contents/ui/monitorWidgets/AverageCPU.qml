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

    property double avgLoad: cpuModel.count > 0 ? (cpuModel
                .getAll()
                .map(it => parseInt(it.val))
                .reduce((sum, curr) => sum + curr, 0) / cpuModel.count)
                .toFixed(0) : 0

    property double avgTemp: coreTempModel.count > 0 ? (coreTempModel
            .getAll()
            .map(it => parseInt(it.val))
            .reduce((sum, curr) => sum + curr, 0) / coreTempModel.count)
            .toFixed(0) : 0

    property int highTemp: 87
    property int criticalTemp : 105

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
                text: i18n("CPU:")
                font { family: doppioOneRegular.name; pointSize: 12 }
                color: "#ffdd55"
            }
            Text {
                text: i18n("%1%", avgLoad)
                font { family: doppioOneRegular.name; pointSize: 12 }
                color: avgLoad < 80 ? "white" : "red"
            }
            Text {
                text:  (tempUnit ? Math.floor((avgTemp * 9/5)+32) : avgTemp) + (tempUnit ? "ºF" : "ºC")
                font { family: doppioOneRegular.name; pointSize: 12 }
                color: avgTemp >= highTemp ? "red" : avgTemp >= criticalTemp ? "#ffcc00" : "white"
            }
        }

        Rectangle {
            id: rectTotalCPU
            height: 5
            Layout.fillWidth: true
            color: "#7ec264"
            Rectangle {
                id: rectUsedCPU
                anchors.left: parent.left
                height: parent.height
                width: (avgLoad)/100*parent.width
                color: "red"
            }
        }
    }
}
