import QtQuick 1.1

Item {
    property double memFree: 0.0
    property double memTotal: 0.0
    property double memCached: 0.0
    property double memUsed: 0.0
    property double memBuffers: 0.0
    property alias memTypeLabel : memType.text
    Column {
        anchors.fill: parent
        Rectangle {
            id: topMemArea
            height: 3
            width: parent.width
            color: "white"
        }
        Row {
            spacing: 3
            Text {
                id: memType
                text: qsTr("Mem:")
                font { family: doppioOneRegular.name; pointSize: 12 }
                color: "#ffdd55"
            }
            Text {
                text: memTotal.toFixed(2)+" GiB"
                font { family: doppioOneRegular.name; pointSize: 12 }
                color: "white"
            }
        }
        
        Row {
            id: memoryInfoLabels
            spacing: 3
            property int fontSize : 8
            Text {
                text: qsTr("Used:")
                color: "red"
                font.pointSize: memoryInfoLabels.fontSize
            }
            Text {
                id: memUsedText
                text: (memUsed-(memBuffers+memCached)).toFixed(2) +" GiB"
                color: "white"
                font.pointSize: memoryInfoLabels.fontSize
            }
            Text {
                text: qsTr("Free")
                color: "#7ec264"
                font.pointSize: memoryInfoLabels.fontSize
            }
            Text {
                id: memFreeText
                text: (memFree+(memBuffers+memCached)).toFixed(2)+" GiB"
                color: "white"
                font.pointSize: memoryInfoLabels.fontSize
            }
        }
        
        Rectangle {
            id: rectTotalMemory
            height: 5
            width: parent.width
            color: "#7ec264"
            Rectangle {
                id: rectUsedMemory
                height: parent.height
                width: (memUsed-(memBuffers+memCached))/memTotal*parent.width
                color: "red"
            }
        }
    }
}
