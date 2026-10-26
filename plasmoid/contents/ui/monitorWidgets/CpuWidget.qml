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
    id: cpuListView

    property int direction: Qt.LeftToRight
    LayoutMirroring.enabled: direction === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property bool coloredCpuLoad: true
    property bool flatCpuLoad: true
    property int indicatorHeight: 10

    implicitWidth: 100
    implicitHeight: contentHeight

    interactive: false

    FontLoader {
        id: doppioOneRegular
        source: "../../fonts/Doppio_One/DoppioOne-Regular.ttf"
    }

    delegate: Item {
        id: itemElement

        required property int index
        required property real val

        width: ListView.view.width
        height: 20 + cpuListView.indicatorHeight + 1

        Column {
            id: cpuListItem
            width: parent.width
            height: 20 + cpuListView.indicatorHeight

            Item {
                width: parent.width
                height: cpuLabel.implicitHeight

                Text {
                    id: cpuLabel
                    anchors.left: parent.left
                    text: i18n("CPU %1:", itemElement.index)
                    font.bold: true
                    font { family: doppioOneRegular.name; pointSize: 10 }
                    color: "#ffdd55"
                }
                Text {
                    anchors.right: parent.right
                    text: Math.floor(itemElement.val) + "%"
                    font.bold: true
                    font.pointSize: 10
                    color: "white"
                }
            }

            Item {
                id: progressBar
                width: parent.width
                height: 10

                Rectangle {
                    // Clear background.
                    anchors.fill: parent
                    visible: !cpuListView.flatCpuLoad
                    radius: 2
                    gradient: Gradient {
                        GradientStop { position: 0.00; color: "#99000000" }
                        GradientStop { position: 0.25; color: "#55555555" }
                        GradientStop { position: 1.00; color: "transparent" }
                    }
                    border.color: "#33ffffff"
                }

                Rectangle {
                    id: rectValue
                    // Rectangle with value change and crop.
                    anchors.left: parent.left
                    height: parent.height
                    color: "transparent"
                    clip: true
                    border.color: "#33ffffff"
                    width: Math.max(0, cpuListView.flatCpuLoad
                                       ? Math.floor(itemElement.val / 100 * parent.width)
                                       : Math.floor(itemElement.val / 100 * (parent.width - 5)))

                    Rectangle {
                        // Load colour gradient spanning the whole bar; rectValue crops it.
                        // Gradient stops don't follow LayoutMirroring, so mirror them by hand.
                        id: bgGradient
                        readonly property bool mirrored: LayoutMirroring.enabled
                        anchors.left: parent.left
                        height: progressBar.height
                        width: progressBar.width
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: bgGradient.mirrored ? 0.00 : 1.00; color: cpuListView.coloredCpuLoad ? "#7ec264" : "#4dffffff" }
                            GradientStop { position: bgGradient.mirrored ? 0.40 : 0.60; color: cpuListView.coloredCpuLoad ? "#7ec264" : "#4dffffff" }
                            GradientStop { position: bgGradient.mirrored ? 0.65 : 0.35; color: cpuListView.coloredCpuLoad ? "#ffdd55" : "#4dffffff" }
                            GradientStop { position: bgGradient.mirrored ? 0.90 : 0.10; color: cpuListView.coloredCpuLoad ? "red"     : "#4dffffff" }
                            GradientStop { position: bgGradient.mirrored ? 1.00 : 0.00; color: cpuListView.coloredCpuLoad ? "red"     : "#993de515" }
                        }
                    }

                    Rectangle {
                        // Shadow overlay.
                        anchors.left: parent.left
                        height: progressBar.height
                        width: progressBar.width
                        visible: !cpuListView.flatCpuLoad
                        gradient: Gradient {
                            GradientStop { position: 0.00; color: "#99000000" }
                            GradientStop { position: 0.25; color: "#55555555" }
                            GradientStop { position: 0.88; color: "transparent" }
                            GradientStop { position: 1.00; color: "#eeffffff" }
                        }
                    }
                }

                Rectangle {
                    height: progressBar.height + 4
                    width: 5
                    radius: 2
                    anchors.left: rectValue.right
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#88ffffff"
                    visible: !cpuListView.flatCpuLoad
                }
            }
        }
    }
}
