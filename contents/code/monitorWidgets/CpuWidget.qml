import QtQuick 1.1
import org.kde.plasma.components 0.1 as PlasmaWidgets
import org.kde.plasma.core 0.1 as PlasmaCore

ListView {
    id: cpuListView
    property string direction: "right"
    model: cpuModel
    FontLoader {
        id: doppioOneRegular
        source: "../fonts/Doppio_One/DoppioOne-Regular.ttf"
    }
    boundsBehavior: Flickable.StopAtBounds
    highlight: highlightCpu
    highlightFollowsCurrentItem: false
    delegate: Item {
        width: parent.width
        height: cpuListItem.height+1
        Column {
            id: cpuListItem
            width: parent.width
            Row {
                Text {
                    id: cpuLabel
                    text: 'CPU'+model.index+':'
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
                    if (direction === "right")
                        anchors.right =parent.right
                }
            }
            Rectangle {
                id: progressBar
                height: 8
                color: "transparent"
                clip: true
                width: parent.width
                Rectangle {
                    width: parent.width+2
                    height: parent.height+1
                    y:-1
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
                    border.color: "#55ffffff"
                }

                Rectangle {
                    id: rectValue
                    height: parent.height
                    color: "transparent"
                    clip: true
                    border.color: "white"
                    width: Math.floor(val/100*(parent.width))
                    Rectangle {
                        height: progressBar.width
                        width: progressBar.height
                        anchors.centerIn: parent
                        rotation: 270
                        gradient: Gradient {
                            GradientStop {
                                position: 0.00;
                                color: "seagreen";
                            }
                            GradientStop {
                                position: 1.00;
                                color: "greenyellow";
                            }
                        }
                    }
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

    HighlightCpu {
        id: highlightCpu
        width: cpuListView.width
        height: cpuListView.currentItem.height
        y: cpuListView.currentItem.y
    }

}
