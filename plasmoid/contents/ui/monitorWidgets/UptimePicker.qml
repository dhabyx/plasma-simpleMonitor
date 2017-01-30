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
    property alias uptime: uptimeLabel.text
    Row {
        anchors.right: parent.right
        spacing: 3
        Text {
            text: qsTr("Uptime:")
            color: "#b3b3b3"
        }
        Text {
            id: uptimeLabel
            text: "0d 0:00"
            color: "white"
        }
    }
}
