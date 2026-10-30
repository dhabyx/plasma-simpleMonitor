import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Window
import "cpu-layout.js" as CpuLayout

// One vertical sequence per column; only this viewport scrolls on tall systems.
Item {
    id: root
    property var model
    property bool coloredCpuLoad: true
    property bool flatCpuLoad: true
    property int indicatorHeight: 10
    property bool showCpuFrequency: false
    property int requestedColumns: 1
    property int direction: Qt.LeftToRight
    readonly property int count: model ? model.count : 0
    readonly property real availableScreenWidth: Screen.width > 0 ? Screen.width : 1280
    readonly property real availableScreenHeight: Screen.height > 0 ? Screen.height : 900
    readonly property int columns: CpuLayout.columnCount(count, requestedColumns, availableScreenWidth)
    readonly property int rows: CpuLayout.rowCount(count, columns)
    readonly property int rowHeight: 21 + indicatorHeight + (showCpuFrequency ? 18 : 0)
    readonly property real maximumHeight: availableScreenHeight * 0.6
    implicitWidth: columns * 100
    implicitHeight: Math.min(rows * rowHeight, maximumHeight)
    LayoutMirroring.enabled: direction === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    Flickable {
        id: scroll
        objectName: "cpuScroll"
        anchors.fill: parent
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        contentWidth: width
        contentHeight: root.rows * root.rowHeight
        interactive: contentHeight > height
        activeFocusOnTab: interactive || activeFocus
        Keys.onPressed: event => {
            const limit = Math.max(0, contentHeight - height)
            if (event.key === Qt.Key_Home) contentY = 0
            else if (event.key === Qt.Key_End) contentY = limit
            else if (event.key === Qt.Key_PageDown) contentY = Math.min(limit, contentY + height)
            else if (event.key === Qt.Key_PageUp) contentY = Math.max(0, contentY - height)
            else if (event.key === Qt.Key_Down) contentY = Math.min(limit, contentY + root.rowHeight)
            else if (event.key === Qt.Key_Up) contentY = Math.max(0, contentY - root.rowHeight)
            else return
            event.accepted = true
        }
        QQC2.ScrollBar.vertical: QQC2.ScrollBar { policy: scroll.interactive ? QQC2.ScrollBar.AsNeeded : QQC2.ScrollBar.AlwaysOff }
        Item {
            width: scroll.width
            height: scroll.contentHeight
            Repeater {
                model: root.model
                delegate: CpuCoreDelegate {
                    required property int index
                    objectName: "cpu_" + index
                    required property real val
                    required property real frequencyHz
                    required property bool hasFrequency
                    x: CpuLayout.columnFor(index, root.rows) * parent.width / root.columns
                    y: CpuLayout.rowFor(index, root.rows) * root.rowHeight
                    width: parent.width / root.columns
                    height: root.rowHeight
                    cpuIndex: index
                    loadValue: val
                    frequencyValue: frequencyHz
                    frequencyAvailable: hasFrequency
                    showFrequency: root.showCpuFrequency
                    coloredCpuLoad: root.coloredCpuLoad
                    flatCpuLoad: root.flatCpuLoad
                    indicatorHeight: root.indicatorHeight
                }
            }
        }
    }
}
