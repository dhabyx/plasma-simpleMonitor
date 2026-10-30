/** Optional one-shot CPU grouping. SPDX-License-Identifier: GPL-3.0-or-later */
import QtQuick
import org.kde.plasma.plasma5support as Plasma5Support
import "cpu-grouping.js" as Grouping

QtObject {
    id: root
    property bool enabled: false
    // Set only after the sensor tree has produced its initial stable snapshot.
    property bool discoveryReady: false
    property var usageIds: []
    property var temperatureIds: []
    readonly property string command: "cat /proc/cpuinfo"
    property int queryCount: 0
    property bool pending: false
    property bool attempted: false
    property bool hasCache: false
    property bool stale: false
    property var baselineIds: []
    property var topology: ({records:{}, ids:[], incomplete:true})

    readonly property string state: {
        if (!enabled) return "disabled"
        if (!discoveryReady || !usageIds.length || pending || !attempted) return "loading"
        if (!hasCache) return "error"
        if (stale || !Grouping.sameIds(usageIds, baselineIds)) return "stale"
        if (topology.incomplete) return "incomplete"
        for (let i=0; i<usageIds.length; ++i)
            if (!topology.records[usageIds[i]]) return "incomplete"
        return "ready"
    }
    readonly property var representativeIds: {
        if (state === "ready" || state === "incomplete")
            return Grouping.representativeIds(topology, usageIds, temperatureIds)
        // An unavailable, untrusted or outdated map must not invent grouping.
        return temperatureIds.filter(function(id) { return usageIds.indexOf(id) >= 0 })
    }
    function maybeStart() {
        if (enabled && discoveryReady && usageIds.length && !attempted && !pending) refresh()
    }
    // Explicit user action may retry a failed or invalidated snapshot.
    function refresh() {
        if (!enabled || !discoveryReady || !usageIds.length || pending) return false
        attempted = true
        pending = true
        stale = false
        hasCache = false
        baselineIds = usageIds.slice()
        queryCount++
        source.connectSource(command)
        return true
    }
    onEnabledChanged: maybeStart()
    onDiscoveryReadyChanged: maybeStart()
    onUsageIdsChanged: {
        if (attempted && baselineIds.length && !Grouping.sameIds(usageIds, baselineIds)) stale = true
        maybeStart()
    }
    property Plasma5Support.DataSource source: Plasma5Support.DataSource {
        engine: "executable"
        onNewData: (name, data) => {
            if (name !== root.command) return
            disconnectSource(name)
            const parsed = Grouping.parseCpuInfo(data["stdout"] || "")
            root.topology = parsed
            root.hasCache = data["exit code"] === 0 && parsed.ids.length > 0
            root.pending = false
        }
    }
}
