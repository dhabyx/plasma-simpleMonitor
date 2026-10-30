/** Synthetic settings preview; never subscribes to sensors. SPDX-License-Identifier: GPL-3.0-or-later */
import QtQuick
import QtQuick.Layouts
import "../components"
import "../../code/code.js" as Code

Rectangle {
    id: root
    property int skin: 0
    property int bgColor: 1
    property int logo: 0
    property string customLogo: ""
    property string distroKey: ""
    property string osLogoIcon: ""
    property bool compact: false
    property int columns: 1
    property bool showLogo: true
    property bool showFrequency: false
    property bool showDistroName: true
    property bool showDistroVersion: true
    property bool showDistroCodename: true
    property int distroLayout: 0
    readonly property var distroFields: [showDistroName ? i18n("Example Linux") : "", showDistroVersion ? "26.04" : "", showDistroCodename ? i18n("Example Release") : ""].filter(function(value) { return value.length > 0 })
    property bool showGpu: true
    property bool showSwap: true
    property bool showUptime: true
    property bool showNetwork: true
    property int dateVisibility: 0
    property int timeVisibility: 0
    property bool colored: true
    readonly property bool showDate: dateVisibility === 1 || (dateVisibility === 0 && skin !== 2)
    readonly property bool showTime: timeVisibility === 1 || (timeVisibility === 0 && skin !== 2)
    readonly property int shownColumns: columns === 0 ? 1 : Math.max(1, Math.min(columns, 8))
    implicitWidth: 310
    implicitHeight: skin === 2 ? 155 : 225
    width: implicitWidth
    height: implicitHeight
    color: bgColor === 0 ? "#000000" : (bgColor === 2 ? "#444955" : "#242830")
    radius: 4
    clip: true

    // Draw a representative layout using synthetic values only. The preview
    // remains independent of SystemData and the widget's live configuration.
    Component {
        id: cpuRows
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 3
                Repeater {
                    model: root.shownColumns
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: root.compact ? 1 : 2
                        property int columnIndex: index
                        Repeater {
                            model: Math.ceil(8 / root.shownColumns)
                            ColumnLayout {
                                required property int index
                                readonly property int cpuNumber: parent.columnIndex * Math.ceil(8 / root.shownColumns) + index
                                visible: cpuNumber < 8
                                Layout.fillWidth: true
                                spacing: 0
                                Text { text: "CPU " + parent.cpuNumber + (root.showFrequency ? " 3.20 GHz" : ""); color: "white"; font.pixelSize: 8; elide: Text.ElideRight; Layout.fillWidth: true }
                                Rectangle { Layout.fillWidth: true; implicitHeight: 3; color: root.colored ? "#80c868" : "#d9d9d9" }
                            }
                        }
                        Item { Layout.fillHeight: true }
                    }
                }
            }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.compact ? 5 : 9
        spacing: root.compact ? 2 : 5
        RowLayout {
            Layout.fillWidth: true
            spacing: root.compact ? 3 : 7
            LogoImage {
                visible: root.showLogo
                implicitWidth: 30; implicitHeight: 30
                Layout.preferredWidth: 30; Layout.preferredHeight: 30
                readonly property bool custom: root.logo === Code.logos.length + 1
                readonly property string file: Code.logoFile(custom ? 0 : root.logo, root.distroKey)
                iconName: root.logo === 0 ? root.osLogoIcon : ""
                image.source: custom ? (root.customLogo.indexOf("file://") === 0 ? root.customLogo : "") : Qt.resolvedUrl("../../images/" + (file || "distro-tux.svg"))
                fallbackSource: Qt.resolvedUrl("../../images/" + (file || "distro-tux.svg"))
            }
            ColumnLayout {
                spacing: 0
                Text {
                    visible: root.distroFields.length > 0
                    text: root.distroFields.join(root.distroLayout === 1 ? "\n" : " ")
                    color: "white"; font.pixelSize: 10
                    wrapMode: Text.WordWrap
                    Layout.maximumWidth: 110
                }
                Text { text: "Linux 6.0"; color: "#c8c8c8"; font.pixelSize: 9 }
            }
            Item { Layout.fillWidth: true }
            ColumnLayout {
                spacing: 0
                Text { visible: root.showDate; text: i18n("Mon 12 May"); color: "white"; font.pixelSize: 10 }
                Text { visible: root.showTime; text: "12:34"; color: "white"; font.pixelSize: 10 }
                Text { visible: root.showUptime; text: i18n("Uptime: 2 h"); color: "#c8c8c8"; font.pixelSize: 9 }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: root.compact ? 3 : 7
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: root.compact ? 1 : 3
                Text { text: root.skin === 2 ? i18n("CPU: 42%") : i18n("CPU temperature: 54 °C"); color: "white"; font.pixelSize: 9 }
                Text { visible: root.showFrequency && root.skin === 2; text: i18n("Average frequency: 3.20 GHz"); color: "white"; font.pixelSize: 9 }
                Text { visible: root.showGpu && root.skin !== 2; text: i18n("GPU: 48 °C"); color: "white"; font.pixelSize: 9 }
                Text { text: i18n("Memory: 8 / 16 GiB"); color: "white"; font.pixelSize: 9 }
                Text { visible: root.showSwap; text: i18n("Swap: 1 / 4 GiB"); color: "white"; font.pixelSize: 9 }
                Text { visible: root.showNetwork; text: i18n("Network: ↓ 2.4 MB/s"); color: "white"; font.pixelSize: 9 }
                Item { Layout.fillHeight: true }
            }
            Loader {
                visible: root.skin === 0
                Layout.fillWidth: true
                Layout.fillHeight: true
                sourceComponent: root.skin === 0 ? cpuRows : null
            }
        }
        Loader {
            visible: root.skin === 1
            Layout.fillWidth: true
            sourceComponent: root.skin === 1 ? cpuRows : null
        }
    }
}
