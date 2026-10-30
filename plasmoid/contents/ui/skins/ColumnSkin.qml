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

import "../monitorWidgets"
import "../components"

BaseSkin {
    id: root

    implicitWidth: mainLayout.implicitWidth + mainLayout.anchors.leftMargin + mainLayout.anchors.rightMargin
    implicitHeight: mainLayout.implicitHeight + mainLayout.anchors.topMargin + mainLayout.anchors.bottomMargin

    ColumnLayout {
        id: mainLayout

        // Keep natural vertical spacing when the host allocates extra height.
        // The host still controls its own size, including manual resizing.
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: root.blockMargin }
        spacing: 0

        Item {
            visible: root.dateVisibility !== 2 || root.showUptime
            implicitHeight: Math.max(datePicker.visible ? datePicker.implicitHeight : 0, uptimePicker.visible ? uptimePicker.implicitHeight : 0)
            implicitWidth: datePicker.implicitWidth

            Layout.fillWidth: true
            Layout.minimumHeight: implicitHeight
            Layout.minimumWidth: implicitWidth

            DatePicker {
                id: datePicker
                visible: root.dateVisibility !== 2

                anchors { left: parent.left; leftMargin: 10 }
            }

            UptimePicker {
                id: uptimePicker
                anchors { top: parent.top; right: parent.right }
                visible: root.showUptime
                uptime: root.uptime
            }
        }

        GridLayout {
            columns: 2
            rows: 3
            columnSpacing: 0
            rowSpacing: 0

            Layout.fillWidth: true
            Layout.topMargin: root.blockMargin

            DistroBlock {
                engine: root.engine
            blockSpacing: root.blockSpacing

                Layout.rowSpan: 3
            }

            TimePicker {
                visible: root.timeVisibility !== 2
                Layout.alignment: Qt.AlignLeft
                Layout.topMargin: -5
                Layout.leftMargin: 10
                Layout.bottomMargin: 5
                Layout.minimumHeight: implicitHeight
                Layout.maximumHeight: implicitHeight
                Layout.preferredWidth: implicitWidth
                Layout.preferredHeight: implicitHeight
            }

            Rectangle {
                visible: root.timeVisibility !== 2
                color: "white"

                Layout.leftMargin: 2
                Layout.fillWidth: true
                Layout.minimumHeight: 3
                Layout.maximumHeight: 3
                Layout.preferredHeight: 3
            }

            ColumnLayout {
                spacing: 0

                Layout.leftMargin: root.blockMargin
                Layout.rightMargin: root.blockMargin
                Layout.topMargin: root.blockMargin
                Layout.fillWidth: true
                Layout.fillHeight: true

                CoreTempList {
                    model: root.coreTempModel
                    highTemp: root.cpuHighTemp
                    criticalTemp: root.cpuCritTemp
                    tempUnit: root.tempUnit
                    indicatorHeight: root.indicatorHeight
                    direction: root.direction

                    Layout.fillWidth: true
                    Layout.minimumWidth: implicitWidth
                    Layout.minimumHeight: implicitHeight
                    Layout.preferredWidth: implicitWidth
                    Layout.preferredHeight: implicitHeight
                }

                GpuTempList {
                    model: root.gpuTempModel
                    highTemp: root.cpuHighTemp
                    criticalTemp: root.cpuCritTemp
                    tempUnit: root.tempUnit
                    indicatorHeight: root.indicatorHeight
                    showGpuTemp: root.showGpuTemp
                    direction: root.direction

                    Layout.topMargin: 1
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumWidth: implicitWidth
                    Layout.minimumHeight: implicitHeight
                    Layout.preferredWidth: implicitWidth
                    Layout.preferredHeight: implicitHeight
                }
            }
        }

        Rectangle {
            color: "white"

            Layout.fillWidth: true
            Layout.minimumHeight: 3
            Layout.maximumHeight: 3
            Layout.preferredHeight: 3
            Layout.topMargin: root.blockMargin
        }

        CpuColumns {
            model: root.cpuModel
            requestedColumns: root.cpuColumns
            showCpuFrequency: root.showCpuFrequency
            coloredCpuLoad: root.coloredCpuLoad
            flatCpuLoad: root.flatCpuLoad
            indicatorHeight: root.indicatorHeight
            direction: root.direction

            Layout.leftMargin: root.blockMargin
            Layout.topMargin: root.blockMargin
            Layout.maximumWidth: root.cpuColumns === 0 ? Math.max(100, availableScreenWidth * 0.8) : Infinity
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            Layout.minimumWidth: implicitWidth
            Layout.minimumHeight: implicitHeight
            Layout.maximumHeight: implicitHeight
            Layout.preferredWidth: implicitWidth
            Layout.preferredHeight: implicitHeight
        }

        Rectangle {
            color: "white"

            Layout.fillWidth: true
            Layout.minimumHeight: 3
            Layout.maximumHeight: 3
            Layout.preferredHeight: 3
            Layout.topMargin: root.blockMargin
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
