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
    id: root
    property string distroName: "tux"
    property string distroId: "tux"
    property string distroVersion: ""

    property string kernelName: ""
    property string kernelVersion: ""

    implicitWidth: infoColumn.implicitWidth
    implicitHeight: infoColumn.implicitHeight

    FontLoader {
        id: mondaRegular
        source: "../../fonts/Monda/Monda-Regular.ttf"
    }

    ColumnLayout {
        id: infoColumn

        spacing: 1
        anchors.fill: parent

        Text {
            id: distroInfo
            text: (distroVersion.indexOf(',') >= 0) ?
                      distroName + " "
                      + distroVersion.substring(0,distroVersion.indexOf(','))
                      + '\n'
                      + distroVersion.substring(distroVersion.indexOf(',')+2, distroVersion.length)
                    : distroName + " " + distroVersion
            color: "white"

            lineHeight: 0.6
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            font { family: mondaRegular.name; pointSize: 9 }
        }
        
        Text {
            id: kernelInfo
            text: kernelName + " " + kernelVersion
            color: "white"
            Layout.alignment: Qt.AlignHCenter
//            lineHeight: 0.6
            horizontalAlignment: Text.AlignHCenter
            font { family: mondaRegular.name; pointSize: 9 }
        }
    }
}
