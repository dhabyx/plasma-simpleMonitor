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
import QtQuick.Controls as QQC2

import "../monitorWidgets"
import "../components"

BaseSkin {
    id: root

    implicitWidth: mainLayout.implicitWidth + mainLayout.anchors.leftMargin + mainLayout.anchors.rightMargin
    implicitHeight: mainLayout.implicitHeight + mainLayout.anchors.topMargin + mainLayout.anchors.bottomMargin

    RowLayout {
        id: mainLayout

        // Keep natural vertical spacing when the host allocates extra height.
        // The host still controls its own size, including manual resizing.
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: root.blockMargin }
        spacing: 0

        DistroBlock {
            engine: root.engine
            blockSpacing: root.blockSpacing

            Layout.topMargin: root.blockMargin

            DatePicker {
                visible: root.dateVisibility === 1
                Layout.alignment: Qt.AlignCenter
            }
            TimePicker {
                visible: root.timeVisibility === 1
                Layout.alignment: Qt.AlignCenter
            }
            UptimePicker {
                visible: root.showUptime
                uptime: root.uptime

                Layout.alignment: Qt.AlignCenter
                Layout.bottomMargin: 2
                Layout.minimumHeight: height
                Layout.preferredWidth: implicitWidth
                Layout.preferredHeight: implicitHeight
            }
        }

        Rectangle {
            color: "white"

            Layout.minimumWidth: 3
            Layout.maximumWidth: 3
            Layout.preferredWidth: 3
            Layout.fillHeight: true
            Layout.topMargin: root.blockMargin
        }

        ColumnLayout {
            spacing: 0

            AverageCPU {
                avgLoad: root.engine.avgLoad
                avgTemp: root.engine.avgTemp
                tempUnit: root.tempUnit
                highTemp: root.cpuHighTemp
                criticalTemp: root.cpuCritTemp

                Layout.topMargin: 2
                Layout.leftMargin: 10
                Layout.rightMargin: root.blockMargin
                Layout.fillWidth: true
                Layout.minimumWidth: implicitWidth
                Layout.minimumHeight: implicitHeight
                Layout.preferredWidth: implicitWidth
                Layout.maximumHeight: implicitHeight
            }

            Text {
                visible: root.showCpuFrequency
                text: i18n("Average frequency: %1", root.engine.hasAvgFrequency ? (root.engine.avgFrequencyHz / 1e9).toFixed(2) + " GHz" : "—")
                color: "white"
                font.pointSize: 9
                Layout.leftMargin: 10
                Layout.fillWidth: true
                elide: Text.ElideRight
                QQC2.ToolTip.visible: averageFrequencyHover.containsMouse && !root.engine.hasAvgFrequency
                QQC2.ToolTip.text: i18n("Frequency unavailable")
                MouseArea { id: averageFrequencyHover; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
            }

            Rectangle {
                color: "white"

                Layout.fillWidth: true
                Layout.minimumHeight: 3
                Layout.maximumHeight: 3
                Layout.preferredHeight: 3
                Layout.topMargin: root.blockMargin
                Layout.rightMargin: root.blockMargin
            }

            MemArea {
                memFree: root.memFree
                memTotal: root.memTotal
                memUsed: root.memUsed

                Layout.topMargin: 2
                Layout.leftMargin: 10
                Layout.rightMargin: root.blockMargin
                Layout.fillWidth: true
                Layout.minimumWidth: implicitWidth
                Layout.minimumHeight: implicitHeight
                Layout.preferredWidth: implicitWidth
                Layout.maximumHeight: implicitHeight
            }

            Rectangle {
                visible: root.showSwap
                color: "white"

                Layout.fillWidth: true
                Layout.minimumHeight: 3
                Layout.maximumHeight: 3
                Layout.preferredHeight: 3
                Layout.topMargin: root.blockMargin
                Layout.rightMargin: root.blockMargin
            }

            MemArea {
                visible: root.showSwap
                memTypeLabel: i18n("Swap:")
                memFree: root.swapFree
                memTotal: root.swapTotal
                memUsed: root.swapUsed

                Layout.topMargin: 2
                Layout.leftMargin: 10
                Layout.rightMargin: root.blockMargin
                Layout.fillWidth: true
                Layout.minimumWidth: implicitWidth
                Layout.minimumHeight: implicitHeight
                Layout.preferredWidth: implicitWidth
                Layout.maximumHeight: implicitHeight
            }

            Rectangle {
                visible: root.showNetwork
                color: "white"

                Layout.fillWidth: true
                Layout.minimumHeight: 3
                Layout.maximumHeight: 3
                Layout.preferredHeight: 3
                Layout.topMargin: root.blockMargin
                Layout.rightMargin: root.blockMargin
            }

            NetArea {
                visible: root.showNetwork
                down: root.netDown
                iface: root.netIface
                ip: root.netIp
                showPing: root.showPing
                pingMs: root.pingMs
                up: root.netUp
                scale: root.netScale
                unit: root.netUnit

                Layout.topMargin: 2
                Layout.leftMargin: 10
                Layout.rightMargin: root.blockMargin
                Layout.fillWidth: true
                Layout.minimumWidth: implicitWidth
                Layout.minimumHeight: implicitHeight
                Layout.preferredWidth: implicitWidth
                Layout.maximumHeight: implicitHeight
            }
        }
    }
}
