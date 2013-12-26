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
