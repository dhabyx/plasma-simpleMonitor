import QtQuick 1.1

ListView {
    id: cpuListView
    property int direction: Qt.RightToLeft
    property color progressColor: "#993de515"
    model: cpuModel
    FontLoader {
        id: doppioOneRegular
        source: "../fonts/Doppio_One/DoppioOne-Regular.ttf"
    }
    HighlightCpu {
        id: highlightCpu
        width: cpuListView.width
        height: if (cpuListView.currentItem) cpuListView.currentItem.height; else 0
        y: if (cpuListView.currentItem) cpuListView.currentItem.y; else 0
    }

    boundsBehavior: Flickable.StopAtBounds
    highlight: highlightCpu
    highlightFollowsCurrentItem: false
    delegate: Item {
        id: itemElement
        width: parent.width
        height: cpuListItem.height+1
        property color finalColor : progressColor
        Column {
            id: cpuListItem
            width: parent.width
            Row {
                Text {
                    id: cpuLabel
                    text: 'CPU '+model.index+':'
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
                Component.onCompleted: {
                    if (direction === Qt.RightToLeft)
                        anchors.right = parent.right
                }
            }
            Rectangle {
                id: progressBar
                height: 8
                color: "transparent"
                //clip: true
                width: parent.width
                property color finalColor : itemElement.finalColor
                Rectangle {
                    // clear background
                    width: parent.width
                    height: parent.height
                    y:0
                    anchors.horizontalCenter: parent.horizontalCenter
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
                    height: parent.height
                    color: "transparent"
                    clip: true
                    border.color: "#33ffffff"
                    width: Math.floor(val/100*(parent.width-5))
                    Rectangle {
                        id: bgGradient
                        // rectangle of color, in background for less cpu load
                        height: progressBar.width
                        width: progressBar.height
                        property color finalColor: progressBar.finalColor
                        gradient: Gradient {
                            GradientStop {
                                position: 1.00;
                                color: "#4dffffff";
                            }
                            GradientStop {
                                position: 0.00;
                                color: bgGradient.finalColor;
                            }
                        }
                        transform: [
                            Rotation { origin.x:0; origin.y:0; angle:90 },
                            Translate { x: width } ]

                    }
                    Rectangle {
                        // rectangle of shadow, in background for less cpu load
                        height: progressBar.height
                        width: progressBar.width
                        anchors.left: parent.left
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
                highlightCpu.visible = true
            }
            onExited: {
                highlightCpu.visible = false
            }
        }

        ListView.onAdd: SequentialAnimation {
            PropertyAction { target: cpuListItem; property: "height"; value: 0 }
            NumberAnimation { target: cpuListItem; property: "height"; to: 25; duration: 250; easing.type: Easing.InOutQuad }
        }
    }

}
