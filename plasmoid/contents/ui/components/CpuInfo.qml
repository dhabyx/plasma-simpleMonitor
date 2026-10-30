/**
 * CPU topology discovery for Simple Monitor.
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support
import "../../code/code.js" as Code

// KSystemStats uses the logical processor ID in each cpu/cpuN sensor path.
// A representative online processor is selected for each known physical core.
QtObject {
    id: root
    property bool enabled: true
    property var cpuIds: []
    property bool pending: false

    function refresh() {
        if (!enabled || pending) return
        pending = true
        source.connectSource(Code.cpuTopologyCommand)
    }
    onEnabledChanged: {
        if (enabled) refresh()
        else {
            source.disconnectSource(Code.cpuTopologyCommand)
            pending = false
            cpuIds = []
        }
    }
    Component.onCompleted: refresh()

    property Timer pollTimer: Timer {
        interval: 30000
        repeat: true
        running: root.enabled
        onTriggered: root.refresh()
    }
    property Plasma5Support.DataSource source: Plasma5Support.DataSource {
        engine: "executable"
        onNewData: (sourceName, data) => {
            disconnectSource(sourceName)
            root.pending = false
            if (!root.enabled) return
            var ids = Code.parseCpuTopology(data["stdout"] || "")
            if (JSON.stringify(ids) !== JSON.stringify(root.cpuIds)) root.cpuIds = ids
        }
    }
}
