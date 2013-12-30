import QtQuick 1.1

Rectangle {
    visible: false
    color: "#22ffffff"
    border.color: "#99ffffff"
    radius: 3
    Behavior on y { PropertyAnimation {} }
}
