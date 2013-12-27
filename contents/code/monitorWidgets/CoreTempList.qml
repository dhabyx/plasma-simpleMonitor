import QtQuick 1.1

ListView {
    id: coreTempList
    width: 100
    height: 100

    property int highTemp: 87
    property int criticalTemp : 105

    FontLoader {
        id: doppioOneRegular
        source: "../fonts/Doppio_One/DoppioOne-Regular.ttf"
    }
    delegate: Item {
        id: coreListTemp
        implicitHeight: 25
        width: parent.width
        Text {
            id: coreLabel
            text: 'Core '+model.index+':'
            font.bold: true
            font { family: doppioOneRegular.name; pointSize: 10 }
            color: "#ffdd55"
        }
        Text {
            text: Math.floor(val)+units
            font.bold: true
            font.pointSize: 10
            color: "white"
            anchors.right: parent.right
        }
        
        Rectangle {
            id: rectValue
            height: 9
            width: Math.floor(val/coreTempList.criticalTemp*parent.width)
            color: if (val>=coreTempList.criticalTemp) "red"
                   else if (val>=coreTempList.highTemp) "#ffac2a"
                   else "#85a9ff"
            anchors.top: coreLabel.bottom
            anchors.right: parent.right
            anchors.topMargin: 1
        }
        ListView.onAdd: SequentialAnimation {
            PropertyAction { target: coreListTemp; property: "height"; value: 0 }
            NumberAnimation { target: coreListTemp; property: "height"; to: 25; duration: 250; easing.type: Easing.InOutQuad }
        }
    }
}
