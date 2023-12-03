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
import org.kde.plasma.components 2.0 as PlasmaComponents

import "../monitorWidgets"
import "../components"
import "../../code/code.js" as Code

BaseSkin {
    id: root

    implicitWidth: mainLayout.implicitWidth + mainLayout.anchors.leftMargin + mainLayout.anchors.rightMargin
    implicitHeight: mainLayout.implicitHeight + mainLayout.anchors.topMargin + mainLayout.anchors.bottomMargin

    GridLayout {
        id: mainLayout

        anchors.fill: parent
        anchors.margins: 5 * units.devicePixelRatio
        columns: 4
        rows: 8
        columnSpacing: 0
        rowSpacing: 0

        DatePicker {
            id: datePicker

            Layout.columnSpan: 4
            Layout.alignment: Qt.AlignLeft
            Layout.leftMargin: 10 * units.devicePixelRatio
            Layout.minimumWidth: implicitWidth
            Layout.minimumHeight: implicitHeight
            Layout.maximumHeight: implicitHeight
        }

        ColumnLayout {
            id: distroInfo

            Layout.rowSpan: 3
            Layout.topMargin: 5 * units.devicePixelRatio
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: implicitWidth
            Layout.minimumHeight: implicitHeight
            Layout.preferredWidth: implicitWidth
            Layout.preferredHeight: implicitHeight

            LogoImage {
                id: distroLogo
                Layout.minimumWidth: (implicitWidth < implicitHeight) ? 100*implicitWidth/implicitHeight : 100 * units.devicePixelRatio
                Layout.minimumHeight: (implicitHeight < implicitWidth) ? 100*implicitHeight/implicitWidth : 100 * units.devicePixelRatio
                Layout.preferredWidth: (Layout.fillWidth) ? Layout.minimumWidth : height * implicitWidth/implicitHeight
                Layout.preferredHeight: (Layout.fillHeight) ? Layout.minimumHeight : width * implicitHeight/implicitWidth
//                Layout.fillWidth: (implicitWidth < implicitHeight) ? false: true
                Layout.fillWidth: true
                Layout.fillHeight: !Layout.fillWidth
                Layout.alignment: Qt.AlignCenter

                image.source: "../" + Code.getStandardLogo(logo, osInfoItem.distroId)

                fillScale: plasmoid.configuration.logoScale
                onFillScaleChanged: if (fillScale !== plasmoid.configuration.logoScale) plasmoid.configuration.logoScale = fillScale

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    onClicked: logoPopup.open(mouse.x, mouse.y)
                }

                PlasmaComponents.ContextMenu {
                    id: logoPopup

                    PlasmaComponents.MenuItem {
                        text: distroLogo.editMode ? i18n("Lock image scaling") : i18n("Unlock image scaling")
                        onClicked: distroLogo.editMode = !distroLogo.editMode
                    }
                }
            }

            OsInfoItem {
                id: osInfoItem

                distroName: root.distroName
                distroId: root.distroId
                distroVersion: root.distroVersion
                kernelName: root.kernelName
                kernelVersion: root.kernelVersion

                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                Layout.topMargin: 2 * units.devicePixelRatio
                Layout.minimumHeight: implicitHeight
                Layout.maximumHeight: implicitHeight
                Layout.minimumWidth: implicitWidth
                Layout.preferredWidth: implicitWidth
                Layout.preferredHeight: implicitHeight
            }
        }

        TimePicker {
            id: timePicker

            Layout.columnSpan: 2
            Layout.alignment: Qt.AlignLeft
            Layout.leftMargin: 10 * units.devicePixelRatio
            Layout.bottomMargin: 5 * units.devicePixelRatio
            Layout.minimumHeight: implicitHeight
            Layout.maximumHeight: implicitHeight
            Layout.preferredWidth: implicitWidth
            Layout.preferredHeight: implicitHeight
        }

        UptimePicker {
            id: uptimePicker

            visible: showUptime
            uptime: root.uptime

            Layout.alignment: Qt.AlignRight | Qt.AlignBottom
            Layout.bottomMargin: 2 * units.devicePixelRatio
            Layout.minimumHeight: height
            Layout.preferredWidth: implicitWidth
            Layout.preferredHeight: implicitHeight
        }

        Rectangle {
            color: "white"

            Layout.columnSpan: 3
            Layout.fillWidth: true
            Layout.minimumHeight: 3 * units.devicePixelRatio
            Layout.maximumHeight: 3 * units.devicePixelRatio
            Layout.preferredHeight: 3 * units.devicePixelRatio
            Layout.leftMargin: 2 * units.devicePixelRatio
        }

        ColumnLayout {
            id: tempLayout

            Layout.leftMargin: 5 * units.devicePixelRatio
            Layout.rightMargin: 5 * units.devicePixelRatio
            Layout.topMargin: 5 * units.devicePixelRatio
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: implicitWidth
            Layout.minimumHeight: implicitHeight
            Layout.preferredWidth: implicitWidth
            Layout.preferredHeight: implicitHeight

            CoreTempList {
                id: coreTempList

                model: coreTempModel
                highTemp: cpuHighTemp
                criticalTemp: cpuCritTemp
                tempUnit: root.tempUnit
                direction: root.direction

                Layout.leftMargin: 5 * units.devicePixelRatio
                Layout.rightMargin: 5 * units.devicePixelRatio
                Layout.topMargin: 5 * units.devicePixelRatio
                Layout.fillWidth: true
                Layout.fillHeight: false
                Layout.minimumWidth: implicitWidth
                Layout.minimumHeight: implicitHeight
                Layout.preferredWidth: implicitWidth
                Layout.preferredHeight: implicitHeight
            }

            GpuTempList {
                id: gpuTempList

                model: gpuTempModel
                highTemp: cpuHighTemp
                criticalTemp: cpuCritTemp
                tempUnit: root.tempUnit
                direction: root.direction

                Layout.leftMargin: 5 * units.devicePixelRatio
                Layout.rightMargin: 5 * units.devicePixelRatio
                Layout.topMargin: 1 * units.devicePixelRatio
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: implicitWidth
                Layout.minimumHeight: implicitHeight
                Layout.preferredWidth: implicitWidth
                Layout.preferredHeight: implicitHeight
            }
        }

        Rectangle {
            color: "white"

            Layout.rowSpan: 5
            Layout.minimumWidth: 3 * units.devicePixelRatio
            Layout.maximumWidth: 3 * units.devicePixelRatio
            Layout.preferredWidth: 3 * units.devicePixelRatio
            Layout.fillHeight: true
            Layout.topMargin: 5 * units.devicePixelRatio
        }

        CpuWidget {
            id: cpuList

            direction: root.direction

            Layout.rowSpan: 5
            Layout.leftMargin: 5 * units.devicePixelRatio
            Layout.topMargin: 5 * units.devicePixelRatio
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: implicitWidth
            Layout.minimumHeight: implicitHeight
            Layout.preferredWidth: implicitWidth
            Layout.preferredHeight: implicitHeight
        }

        Rectangle {
            color: "white"

            Layout.columnSpan: 2
            Layout.fillWidth: true
            Layout.minimumHeight: 3 * units.devicePixelRatio
            Layout.maximumHeight: 3 * units.devicePixelRatio
            Layout.preferredHeight: 3 * units.devicePixelRatio
            Layout.topMargin: 5 * units.devicePixelRatio
            Layout.rightMargin: 5 * units.devicePixelRatio
        }

        MemArea {
            id: memArea

            memFree: root.memFree
            memTotal: root.memTotal
            memCached: root.memCached
            memUsed: root.memUsed
            memBuffers: root.memBuffers

            Layout.columnSpan: 2
            Layout.topMargin: 2 * units.devicePixelRatio
            Layout.leftMargin: 10 * units.devicePixelRatio
            Layout.rightMargin: 5 * units.devicePixelRatio
            Layout.fillWidth: true
            Layout.minimumWidth: implicitWidth
            Layout.minimumHeight: implicitHeight
            Layout.preferredWidth: implicitWidth
            Layout.maximumHeight: implicitHeight
        }

        Rectangle {
            visible: showSwap
            color: "white"

            Layout.columnSpan: 2
            Layout.fillWidth: true
            Layout.minimumHeight: 3 * units.devicePixelRatio
            Layout.maximumHeight: 3 * units.devicePixelRatio
            Layout.preferredHeight: 3 * units.devicePixelRatio
            Layout.topMargin: 5 * units.devicePixelRatio
            Layout.rightMargin: 5 * units.devicePixelRatio
        }

        MemArea {
            id: swapArea

            visible: showSwap
            memTypeLabel: i18n("Swap:")
            memFree: root.swapFree
            memTotal: root.swapTotal
            memUsed: root.swapUsed

            Layout.columnSpan: 2
            Layout.topMargin: 2 * units.devicePixelRatio
            Layout.leftMargin: 10 * units.devicePixelRatio
            Layout.rightMargin: 5 * units.devicePixelRatio
            Layout.fillWidth: true
            Layout.minimumWidth: implicitWidth
            Layout.minimumHeight: implicitHeight
            Layout.preferredWidth: implicitWidth
            Layout.maximumHeight: implicitHeight
        }
    }
}
