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

ListView {
    id: cpuListView

    property int direction: Qt.LeftToRight
    LayoutMirroring.enabled: direction === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property color progressColor: "#993de515"

    implicitWidth: 100
    implicitHeight: childrenRect.height

    model: cpuModel
    interactive: false

    /* No higlights on CPU, temporarily until next release*/
    highlightFollowsCurrentItem: true
    highlight: HighlightCpu {
        id: highlightCpu
        width: cpuListView.width
        height: (cpuListView.currentItem) ? cpuListView.currentItem.height : 0
        y: (cpuListView.currentItem) ? cpuListView.currentItem.y : 0
    }

    delegate: Item {
        id: itemElement
        width: cpuListView.width
        height: cpuListItem.height + 1
        Column {
            id: cpuListItem
            width: parent.width
            Row {
                spacing: 5
                anchors.left: parent.left
                Text {
                    id: cpuLabel
                    text: i18n('CPU %1:', model.index)
                    font.bold: true
                    font { family: doppioOneRegular.name; pointSize: 10 }
                    color: "#ffdd55"
                }
                Text {
                    text: Math.floor(val)+'%'
                    font.bold: true
                    font.pointSize: 10
                    color: "white"
                }
            }
            Item {
                id: progressBar
                height: 8
                //clip: true
                width: parent.width
                Rectangle {
                    // clear background
                    anchors.fill: parent
                    radius: 2
                    gradient: Gradient {
                        GradientStop {
                            position: 0.00;
                            color: "#99000000";
                        }
                        GradientStop {
                            position: 0.25;
                            color: "#55555555";
                        }
                        GradientStop {
                            position: 1.00;
                            color: "transparent";
                        }
                    }
                    border.color: "#33ffffff"
                }

                Rectangle {
                    id: rectValue
                    // rectangle whit value change and crop
                    anchors.left: parent.left
                    height: parent.height
                    color: "transparent"
                    clip: true
                    border.color: "#33ffffff"
                    width: Math.floor(val/100*(parent.width-5))
                    Rectangle {
                        id: bgGradient
                        // rectangle of color, in background for less cpu load
                        anchors.left: parent.left
                        height: progressBar.width
                        width: progressBar.height
                        gradient: Gradient {
                            GradientStop {
                                position: 1.00;
                                color: "#4dffffff";
                            }
                            GradientStop {
                                position: 0.00;
                                color: progressColor;
                            }
                        }
                        transform: [
                            Rotation { id: colorRotation; origin.x:0; origin.y:0; angle:0 },
                            Translate { id: colorTraslation; x: 0; y:0 } ]
                        Component.onCompleted: {
                            if (LayoutMirroring.enabled) {
                                colorRotation.angle = 270
                                colorTraslation.y = Qt.binding(function() { return width });
                                colorTraslation.x = Qt.binding(function() { return -height + width });
                            }
                            else {
                                colorRotation.angle = 90
                                colorTraslation.x = Qt.binding(function() { return height });
                            }
                        }

                    }
                    Rectangle {
                        // rectangle of shadow, in background for less cpu load
                        anchors.left: parent.left
                        height: progressBar.height
                        width: progressBar.width
                        gradient: Gradient {
                            GradientStop {
                                position: 0.00;
                                color: "#99000000";
                            }
                            GradientStop {
                                position: 0.25;
                                color: "#55555555";
                            }
                            GradientStop {
                                position: 0.88;
                                color: "transparent";
                            }
                            GradientStop {
                                position: 1.00;
                                color: "#eeffffff";
                            }
                        }
                    }
                }
                Rectangle {
                    height: progressBar.height+4
                    width: 5
                    radius: 2
                    anchors.left: rectValue.right
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#88ffffff"
                }
            }
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                cpuListView.currentIndex = index
//                highlightCpu.visible = true
            }
//            onExited: {
//                highlightCpu.visible = false
//            }
        }

        ListView.onAdd: SequentialAnimation {
            PropertyAction { target: cpuListItem; property: "height"; value: 0 }
            NumberAnimation { target: cpuListItem; property: "height"; to: 25; duration: 250; easing.type: Easing.InOutQuad }
        }
    }

    FontLoader {
        id: doppioOneRegular
        source: "../../fonts/Doppio_One/DoppioOne-Regular.ttf"
    }

}
