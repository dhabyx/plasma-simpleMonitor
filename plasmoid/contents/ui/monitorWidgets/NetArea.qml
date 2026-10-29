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

    // Rates in bytes per second.
    property double down: 0.0
    property double up: 0.0
    // Rate that fills a bar completely.
    property double scale: 1048576
    // 0 = bytes per second, 1 = bits per second.
    property int unit: 0
    // Interface in use and its IPv4 address; empty when offline.
    property string iface: ""
    property string ip: ""
    // Round-trip time in milliseconds, -1 without a reply.
    property bool showPing: false
    property double pingMs: -1

    implicitWidth: netColumn.implicitWidth
    implicitHeight: netColumn.implicitHeight

    function format(bytesPerSecond) {
        if (unit === 1) {
            var bits = bytesPerSecond * 8
            if (bits >= 1e9) return i18n("%1 Gbit/s", (bits / 1e9).toFixed(2))
            if (bits >= 1e6) return i18n("%1 Mbit/s", (bits / 1e6).toFixed(2))
            if (bits >= 1e3) return i18n("%1 kbit/s", (bits / 1e3).toFixed(1))
            return i18n("%1 bit/s", Math.round(bits))
        }
        if (bytesPerSecond >= 1073741824) return i18n("%1 GiB/s", (bytesPerSecond / 1073741824).toFixed(2))
        if (bytesPerSecond >= 1048576) return i18n("%1 MiB/s", (bytesPerSecond / 1048576).toFixed(2))
        if (bytesPerSecond >= 1024) return i18n("%1 KiB/s", (bytesPerSecond / 1024).toFixed(1))
        return i18n("%1 B/s", Math.round(bytesPerSecond))
    }

    FontLoader {
        id: doppioOneRegular
        source: "../../fonts/Doppio_One/DoppioOne-Regular.ttf"
    }

    ColumnLayout {
        id: netColumn

        spacing: 2
        anchors.fill: parent

        RowLayout {
            spacing: 6
            Text {
                text: i18n("Net:")
                font { family: doppioOneRegular.name; pointSize: 12 }
                color: "#ffdd55"
            }
            Text {
                text: root.iface === "" ? i18n("offline") : root.iface + "  " + root.ip
                color: "#aaffffff"
                font.pointSize: 8
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            Text {
                visible: root.showPing
                text: i18n("Ping:")
                font { family: doppioOneRegular.name; pointSize: 12 }
                color: "#ffdd55"
            }
            Text {
                visible: root.showPing
                text: root.pingMs < 0 ? i18n("no reply") : i18n("%1 ms", Math.round(root.pingMs))
                color: root.pingMs < 0 ? "#ff6655" : "white"
                font.pointSize: 8
            }
        }

        RowLayout {
            spacing: 3
            Text {
                text: i18n("Down:")
                color: "#7ec264"
                font.pointSize: 8
            }
            Text {
                text: root.format(root.down)
                color: "white"
                font.pointSize: 8
                Layout.minimumWidth: downMetrics.width
                TextMetrics { id: downMetrics; font.pointSize: 8; text: root.format(1000 * 1048576) }
            }
            Text {
                text: i18n("Up:")
                color: "#ffac2a"
                font.pointSize: 8
            }
            Text {
                text: root.format(root.up)
                color: "white"
                font.pointSize: 8
            }
        }

        Rectangle {
            height: 4
            Layout.fillWidth: true
            color: "#33ffffff"
            Rectangle {
                anchors.left: parent.left
                height: parent.height
                width: Math.min(root.down / root.scale, 1) * parent.width
                color: "#7ec264"
            }
        }

        Rectangle {
            height: 4
            Layout.fillWidth: true
            color: "#33ffffff"
            Rectangle {
                anchors.left: parent.left
                height: parent.height
                width: Math.min(root.up / root.scale, 1) * parent.width
                color: "#ffac2a"
            }
        }
    }
}
