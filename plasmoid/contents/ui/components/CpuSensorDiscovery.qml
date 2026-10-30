/** Discover logical CPU sensor IDs through KSystemStats. SPDX-License-Identifier: GPL-3.0-or-later */
import QtQuick
import org.kde.ksysguard.sensors as Sensors
import org.kde.kitemmodels as KItemModels
import "../../code/code.js" as Code

QtObject {
    id: root
    property bool ready: false
    property var usageIds: []
    property var temperatureIds: []
    property var frequencyIds: []
    function refresh() {
        const paths = []
        for (let row = 0; row < flat.rowCount(); ++row) {
            const index = flat.index(row, 0)
            const path = flat.data(index, Sensors.SensorTreeModel.SensorId)
            if (path) paths.push(path)
        }
        function update(name, kind) {
            const next = Code.cpuSensorIds(paths, kind)
            if (JSON.stringify(root[name]) !== JSON.stringify(next)) root[name] = next
        }
        update("usageIds", "usage")
        update("temperatureIds", "temperature")
        update("frequencyIds", "frequency")
        if (usageIds.length > 0) ready = true
    }
    property Sensors.SensorTreeModel tree: Sensors.SensorTreeModel { id: tree }
    property KItemModels.KDescendantsProxyModel flat: KItemModels.KDescendantsProxyModel {
        id: flat
        model: tree
        onRowsInserted: settle.restart()
        onRowsRemoved: settle.restart()
        onModelReset: settle.restart()
    }
    property Timer settle: Timer { id: settle; interval: 100; onTriggered: root.refresh() }
    Component.onCompleted: settle.start()
}
