import QtQuick
import QtQuick.Controls as QQC2

Item {
    id: root
    property int cpuIndex: 0
    property real loadValue: 0
    property real frequencyValue: 0
    property bool frequencyAvailable: false
    property bool showFrequency: false
    property bool coloredCpuLoad: true
    property bool flatCpuLoad: true
    property int indicatorHeight: 10
    FontLoader { id: font; source: "../../fonts/Doppio_One/DoppioOne-Regular.ttf" }
    Column {
        width: parent.width
        Item {
            width: parent.width; height: cpuLabel.implicitHeight
            Text { id: cpuLabel; anchors.left: parent.left; text: i18n("CPU %1:", root.cpuIndex); font { family: font.name; pointSize: 10; bold: true } color: "#ffdd55" }
            Text { anchors.right: parent.right; text: Math.floor(root.loadValue) + "%"; font { pointSize: 10; bold: true } color: "white" }
        }
        Item {
            width: parent.width; height: root.indicatorHeight
            Item {
                id: progressBar
                width: parent.width; height: 10
                Rectangle {
                    anchors.fill: parent
                    visible: !root.flatCpuLoad
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
                    anchors.left: parent.left
                    height: parent.height
                    color: "transparent"
                    clip: true
                    border.color: "#33ffffff"
                    width: Math.max(0, root.flatCpuLoad
                                    ? Math.floor(root.loadValue / 100 * parent.width)
                                    : Math.floor(root.loadValue / 100 * (parent.width - 5)))
                    Rectangle {
                        id: bgGradient
                        readonly property bool mirrored: LayoutMirroring.enabled
                        anchors.left: parent.left
                        height: progressBar.height
                        width: progressBar.width
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: bgGradient.mirrored ? 1.00 : 0.00; color: root.coloredCpuLoad ? "#7ec264" : "#993de515" }
                            GradientStop { position: 0.50; color: root.coloredCpuLoad ? "#ffdd55" : "#4dffffff" }
                            GradientStop { position: bgGradient.mirrored ? 0.00 : 1.00; color: root.coloredCpuLoad ? "red" : "#4dffffff" }
                        }
                    }
                    Rectangle {
                        anchors.left: parent.left
                        height: progressBar.height
                        width: progressBar.width
                        visible: !root.flatCpuLoad
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
                    visible: !root.flatCpuLoad
                }
            }
        }
        Text {
            id: frequencyLabel
            visible: root.showFrequency
            width: parent.width; height: visible ? 18 : 0
            text: root.frequencyAvailable ? (root.frequencyValue / 1e9).toFixed(2) + " GHz" : "—"
            color: "white"; font.pointSize: 9
            QQC2.ToolTip.visible: frequencyHover.containsMouse && !root.frequencyAvailable
            QQC2.ToolTip.text: i18n("Frequency unavailable")
            MouseArea { id: frequencyHover; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
        }
    }
}
