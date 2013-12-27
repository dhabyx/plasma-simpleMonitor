import QtQuick 1.1

ListView {
    id: cpuListView
    model: cpuModel
    FontLoader {
        id: doppioOneRegular
        source: "../fonts/Doppio_One/DoppioOne-Regular.ttf"
    }
    delegate: Item {
        id: cpuListItem
        implicitHeight: 25
        width: parent.width
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
            anchors.left: cpuLabel.right
            anchors.leftMargin: 2
        }

        Rectangle {
            id: rectValue
            height: 9
            width: Math.floor(val/100*parent.width)
            color: if (val>80) "#7ec264"
                   else if (val>50) "#d1d468"
                   else "#85a9ff"
            anchors.top: cpuLabel.bottom
            anchors.topMargin: 2
            /*Behavior on width {
                     NumberAnimation {
                         id: bouncebehavior
                         easing {
                             type: Easing.OutElastic
                             amplitude: 5.0
                             period: 0.5

                         }
                     }
                 }
            */
        }
        ListView.onAdd: SequentialAnimation {
                         PropertyAction { target: cpuListItem; property: "height"; value: 0 }
                         NumberAnimation { target: cpuListItem; property: "height"; to: 25; duration: 250; easing.type: Easing.InOutQuad }
                     }
    }

}
