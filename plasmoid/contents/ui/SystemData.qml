/**
 * Copyright 2013-2016 Dhaby Xiloj, Konstantin Shtepa
 *
 * This file is part of plasma-simpleMonitor.
 *
 * plasma-simpleMonitor is free software: you can redistribute it
 * and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either
 * version 3 of the License, or any later version.
 *
 * plasma-simpleMonitor is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with plasma-simpleMonitor.  If not, see <http://www.gnu.org/licenses/>.
 **/

import QtQuick
import QtQml
import org.kde.plasma.plasmoid
import org.kde.ksysguard.sensors as Sensors
import org.kde.ksysguard.formatter as Formatter

import "components"
import "../code/code.js" as Code

// Collects every value shown by the skins and exposes it through simple
// properties and list models, so the skins don't depend on the sensors API.
QtObject {
    id: root

    property string autoFitIssue: ""

    // Configuration (mirrors Plasmoid.configuration).
    readonly property int skin:             Plasmoid.configuration.skin
    readonly property int bgColor:          Plasmoid.configuration.bgColor
    readonly property int logo:             Plasmoid.configuration.logo
    readonly property string customLogo:     Plasmoid.configuration.customLogo
    readonly property bool showDistroName: Plasmoid.configuration.showDistroName
    readonly property bool showDistroVersion: Plasmoid.configuration.showDistroVersion
    readonly property bool showDistroCodename: Plasmoid.configuration.showDistroCodename
    readonly property int distroLayout: Plasmoid.configuration.distroLayout
    readonly property bool showLogo:         Plasmoid.configuration.showLogo
    readonly property bool showCpuFrequency: Plasmoid.configuration.showCpuFrequency
    readonly property bool compactLayout:    Plasmoid.configuration.compactLayout
    readonly property int dateVisibility:   Plasmoid.configuration.dateVisibility
    readonly property int timeVisibility:   Plasmoid.configuration.timeVisibility
    readonly property int cpuColumns:       Plasmoid.configuration.cpuColumns
    readonly property bool showGpuTemp:     Plasmoid.configuration.showGpuTemp
    readonly property bool showSwap:        Plasmoid.configuration.showSwap
    readonly property bool showUptime:      Plasmoid.configuration.showUptime
    readonly property bool showNetwork:     Plasmoid.configuration.showNetwork
    readonly property int netUnit:          Plasmoid.configuration.netUnit
    readonly property bool showPing:        Plasmoid.configuration.showPing
    readonly property string pingHost:      Plasmoid.configuration.pingHost
    readonly property int tempUnit:         Plasmoid.configuration.tempUnit
    readonly property int cpuTempMode:      Plasmoid.configuration.cpuTempMode
    readonly property int cpuHighTemp:      Plasmoid.configuration.cpuHighTemp
    readonly property int cpuCritTemp:      Plasmoid.configuration.cpuCritTemp
    readonly property bool coloredCpuLoad:  Plasmoid.configuration.coloredCpuLoad
    readonly property bool flatCpuLoad:     Plasmoid.configuration.flatCpuLoad
    readonly property int indicatorHeight:  Plasmoid.configuration.indicatorHeight
    readonly property double updateInterval: Plasmoid.configuration.updateInterval

    property double logoScale: Plasmoid.configuration.logoScale
    onLogoScaleChanged: if (logoScale !== Plasmoid.configuration.logoScale)
                            Plasmoid.configuration.logoScale = logoScale

    // Toggled from the context menu of the widget: shows the resize handle on the logo.
    property bool logoEditMode: false

    // Operating system and kernel, from the sensors.
    property OsRelease osRelease: OsRelease {}
    readonly property string distroName: String(osNameSensor.value || osRelease.info.name || "")
    readonly property string distroVersion: String(osRelease.info.version || "")
    readonly property string distroCodename: String(osRelease.info.codename || "")
    readonly property string distroPrettyName: String(osPrettyNameSensor.value || "")
    // Icon name of the logo shipped by the distribution (LOGO= in os-release).
    readonly property string osLogoIcon:    String(osLogoSensor.value || "")
    readonly property string kernelName:    String(kernelNameSensor.value || "Linux")
    readonly property string kernelVersion: Code.shortKernelVersion(kernelVersionSensor.value)
    // Key of the bundled logo matching the distribution, "" if there is none.
    readonly property string distroKey: Code.detectDistro([osLogoIcon, distroName, distroPrettyName])

    // Memory, in GiB.
    property double memTotal: 0
    readonly property double memFree: Math.max(0, memTotal - memUsed)
    property double memUsed: 0
    property double swapTotal: 0
    readonly property double swapFree: Math.max(0, swapTotal - swapUsed)
    property double swapUsed: 0

    // Network rates, in bytes per second, and the scale of the bars: the recent
    // peak (slowly decaying), never below 1 MiB/s.
    property double netDown: 0
    property double netUp: 0
    property double netScale: 1048576
    readonly property string netIface: netInfo.iface
    readonly property string netIp: netInfo.ip
    readonly property double pingMs: netInfo.pingMs

    // Uptime, in seconds.
    property double uptime: 0

    // Models. Roles: cpuModel {val, frequencyHz, hasFrequency}, coreTempModel {val, dataUnits, coreLabelStr},
    // gpuTempModel {val, dataUnits, gpuLabelStr}.
    readonly property ListModel cpuModel: ListModel {}
    readonly property ListModel coreTempModel: ListModel {}
    readonly property ListModel gpuTempModel: ListModel {}

    // Averages used by the minimalistic skin, kept incrementally so a sensor
    // update costs O(1) instead of re-summing the whole model.
    property real avgLoad: 0
    property real avgFrequencyHz: 0
    readonly property bool hasAvgFrequency: _frequencyCount > 0
    property real _frequencySum: 0
    property int _frequencyCount: 0
    property real avgTemp: 0
    property real _loadSum: 0
    property real _tempSum: 0
    property int _validTempCount: 0
    property int tempGeneration: 0
    property var tempSensorModels: []

    readonly property int cpuCount: Math.max(0, Math.round(coreCountSensor.value || 0))
    // One representative online logical CPU per known physical core.
    readonly property var tempCpuIds: cpuInfo.cpuIds
    readonly property int tempCount: tempCpuIds.length
    onTempCpuIdsChanged: rebuildCoreTempModel()
    onCpuCountChanged: cpuInfo.refresh()

    // Highest GPU index probed (gpu/gpu0 ... gpu/gpuN). ksystemstats numbers
    // the GPUs after their DRM card, so the indices can have gaps.
    readonly property int gpuProbeCount: 8

    readonly property int intervalMs: Math.max(100, Math.round(updateInterval * 1000))

    readonly property int _bytesPerGiB: 1073741824

    function ensureRows(model, count, template) {
        while (model.count < count)
            model.append(template)
    }

    function setCpuLoad(index, value) {
        if (index < 0 || index >= cpuCount) return
        ensureRows(cpuModel, index + 1, { val: 0, frequencyHz: 0, hasFrequency: false })
        _loadSum += value - cpuModel.get(index).val
        cpuModel.setProperty(index, "val", value)
        avgLoad = _loadSum / cpuModel.count
    }

    // Frequency values are stored in Hz regardless of the sensor's unit.
    function setCpuFrequency(index, hz) {
        if (index < 0 || index >= cpuCount)
            return
        ensureRows(cpuModel, index + 1, { val: 0, frequencyHz: 0, hasFrequency: false })
        var row = cpuModel.get(index)
        if (row.hasFrequency) {
            _frequencySum -= row.frequencyHz
            _frequencyCount--
        }
        var valid = showCpuFrequency && isNumber(hz) && hz > 0
        cpuModel.setProperty(index, "frequencyHz", valid ? hz : 0)
        cpuModel.setProperty(index, "hasFrequency", valid)
        if (valid) {
            _frequencySum += hz
            _frequencyCount++
        }
        avgFrequencyHz = _frequencyCount > 0 ? _frequencySum / _frequencyCount : 0
    }

    function clearCpuFrequencies() {
        for (var i = 0; i < cpuModel.count; ++i) {
            cpuModel.setProperty(i, "frequencyHz", 0)
            cpuModel.setProperty(i, "hasFrequency", false)
        }
        _frequencySum = 0
        _frequencyCount = 0
        avgFrequencyHz = 0
    }

    onShowCpuFrequencyChanged: if (!showCpuFrequency) clearCpuFrequencies()

    function rebuildCoreTempModel() {
        // Invalidate callbacks before destroying old delegates, including when
        // a replacement happens to reuse the same row and processor ID.
        tempGeneration++
        tempSensorModels = []
        coreTempModel.clear()
        _tempSum = 0
        _validTempCount = 0
        avgTemp = 0
        if (cpuTempMode === 0) {
            var sensors = []
            for (var i = 0; i < tempCpuIds.length; ++i) {
                coreTempModel.append({ val: 0, hasValue: false, dataUnits: "°C",
                    coreLabelStr: i18n("CPU %1:", tempCpuIds[i]), cpuId: tempCpuIds[i] })
                sensors.push({ cpuId: tempCpuIds[i], generation: tempGeneration })
            }
            tempSensorModels = sensors
        } else {
            coreTempModel.append({ val: 0, hasValue: false, dataUnits: "°C",
                coreLabelStr: cpuTempMode === 1 ? i18n("CPU avg:") : i18n("CPU max:"), cpuId: -1 })
        }
    }

    function updateTempRow(index, value) {
        var row = coreTempModel.get(index)
        if (row.hasValue) { _tempSum -= row.val; _validTempCount-- }
        var valid = isNumber(value) && value > 0
        coreTempModel.setProperty(index, "val", valid ? value : 0)
        coreTempModel.setProperty(index, "hasValue", valid)
        if (valid) { _tempSum += value; _validTempCount++ }
        avgTemp = _validTempCount > 0 ? _tempSum / _validTempCount : 0
    }

    function setCoreTemp(index, value, cpuId, generation) {
        if (generation !== tempGeneration || cpuTempMode !== 0 || index < 0 || index >= coreTempModel.count ||
            coreTempModel.get(index).cpuId !== cpuId) return
        updateTempRow(index, value)
    }

    function setSingleTemp(value, mode) {
        if (cpuTempMode !== mode || coreTempModel.count !== 1) return
        updateTempRow(0, value)
    }

    onCpuTempModeChanged: rebuildCoreTempModel()

    function gpuRow(index) {
        for (var i = 0; i < gpuTempModel.count; ++i) {
            if (gpuTempModel.get(i).gpuIndex === index)
                return i
        }
        return -1
    }

    // Sets or removes (value is not a valid temperature) the row of a GPU.
    function setGpuTemp(index, value) {
        var row = gpuRow(index)
        var available = isNumber(value) && value > 0
        if (available && row >= 0) {
            gpuTempModel.setProperty(row, "val", value)
            return
        }
        if (available)
            gpuTempModel.append({ gpuIndex: index, val: value, dataUnits: "°C", gpuLabelStr: "" })
        else if (row >= 0)
            gpuTempModel.remove(row)
        else
            return
        updateGpuLabels()
    }

    function updateGpuLabels() {
        var single = gpuTempModel.count === 1
        for (var i = 0; i < gpuTempModel.count; ++i)
            gpuTempModel.setProperty(i, "gpuLabelStr", single ? i18n("GPU:") : i18n("GPU %1:", i))
    }

    function isNumber(value) {
        return typeof value === "number" && isFinite(value)
    }

    property CpuInfo cpuInfo: CpuInfo {
        id: cpuInfo
        enabled: root.cpuTempMode === 0
    }

    property NetInfo netInfo: NetInfo {
        id: netInfo
        enabled: root.showNetwork
        pingEnabled: root.showNetwork && root.showPing
        pingHost: root.pingHost
    }

    property Sensors.Sensor coreCountSensor: Sensors.Sensor {
        sensorId: "cpu/all/coreCount"
    }

    // CPU load, one sensor per logical CPU.
    property Instantiator cpuLoadSensors: Instantiator {
        model: root.cpuCount
        delegate: Sensors.Sensor {
            required property int index
            sensorId: "cpu/cpu" + index + "/usage"
            updateRateLimit: root.intervalMs
            onValueChanged: if (root.isNumber(value)) root.setCpuLoad(index, value)
        }
    }

    // No frequency Sensor objects or subscriptions exist while disabled.
    property Instantiator cpuFrequencySensors: Instantiator {
        model: root.showCpuFrequency ? root.cpuCount : 0
        delegate: Sensors.Sensor {
            id: frequencySensor
            required property int index
            sensorId: "cpu/cpu" + index + "/frequency"
            updateRateLimit: root.intervalMs
            function syncFrequency() {
                var hz = status === Sensors.Sensor.Ready
                    ? Code.frequencyHz(value, unit, [Formatter.Units.UnitHertz,
                        Formatter.Units.UnitKiloHertz, Formatter.Units.UnitMegaHertz,
                        Formatter.Units.UnitGigaHertz, Formatter.Units.UnitTeraHertz,
                        Formatter.Units.UnitPetaHertz]) : null
                root.setCpuFrequency(index, hz)
            }
            onValueChanged: syncFrequency()
            onStatusChanged: syncFrequency()
            onMetaDataChanged: syncFrequency()
            Component.onDestruction: root.setCpuFrequency(index, null)
        }
    }

    // CPU temperature sensors follow actual logical processor IDs, which may
    // be non-contiguous. Stale callbacks from removed delegates are ignored.
    property Instantiator cpuTempSensors: Instantiator {
        model: root.cpuTempMode === 0 ? root.tempSensorModels : []
        delegate: Sensors.Sensor {
            required property int index
            required property var modelData
            sensorId: "cpu/cpu" + modelData.cpuId + "/temperature"
            updateRateLimit: root.intervalMs
            function syncTemperature() {
                root.setCoreTemp(index, status === Sensors.Sensor.Ready ? value : null, modelData.cpuId, modelData.generation)
            }
            onValueChanged: syncTemperature()
            onStatusChanged: syncTemperature()
            Component.onDestruction: root.setCoreTemp(index, null, modelData.cpuId, modelData.generation)
        }
    }

    property Sensors.Sensor cpuAvgTempSensor: Sensors.Sensor {
        sensorId: "cpu/all/averageTemperature"
        enabled: root.cpuTempMode === 1
        updateRateLimit: root.intervalMs
        function syncTemperature() { root.setSingleTemp(status === Sensors.Sensor.Ready ? value : null, 1) }
        onValueChanged: syncTemperature()
        onStatusChanged: syncTemperature()
    }
    property Sensors.Sensor cpuMaxTempSensor: Sensors.Sensor {
        sensorId: "cpu/all/maximumTemperature"
        enabled: root.cpuTempMode === 2
        updateRateLimit: root.intervalMs
        function syncTemperature() { root.setSingleTemp(status === Sensors.Sensor.Ready ? value : null, 2) }
        onValueChanged: syncTemperature()
        onStatusChanged: syncTemperature()
    }

    // GPU temperatures.
    property Instantiator gpuTempSensors: Instantiator {
        model: root.showGpuTemp ? root.gpuProbeCount : 0
        delegate: Sensors.Sensor {
            required property int index
            sensorId: "gpu/gpu" + index + "/temperature"
            updateRateLimit: root.intervalMs
            onValueChanged: root.setGpuTemp(index, value)
            Component.onDestruction: root.setGpuTemp(index, NaN)
        }
    }

    // Operating system and kernel. They don't change while running.
    property Sensors.Sensor osNameSensor: Sensors.Sensor { sensorId: "os/system/name" }
    property Sensors.Sensor osVersionSensor: Sensors.Sensor { sensorId: "os/system/version" }
    property Sensors.Sensor osPrettyNameSensor: Sensors.Sensor { sensorId: "os/system/prettyName" }
    property Sensors.Sensor osLogoSensor: Sensors.Sensor { sensorId: "os/system/logo" }
    property Sensors.Sensor kernelNameSensor: Sensors.Sensor { sensorId: "os/kernel/name" }
    property Sensors.Sensor kernelVersionSensor: Sensors.Sensor { sensorId: "os/kernel/version" }

    property Sensors.Sensor memTotalSensor: Sensors.Sensor {
        sensorId: "memory/physical/total"
        enabled: root.memTotal === 0
        onValueChanged: if (root.isNumber(value)) root.memTotal = value / root._bytesPerGiB
    }
    property Sensors.Sensor memUsedSensor: Sensors.Sensor {
        sensorId: "memory/physical/used"
        updateRateLimit: root.intervalMs
        onValueChanged: if (root.isNumber(value)) root.memUsed = value / root._bytesPerGiB
    }
    property Sensors.Sensor swapTotalSensor: Sensors.Sensor {
        sensorId: "memory/swap/total"
        enabled: root.swapTotal === 0
        onValueChanged: if (root.isNumber(value)) root.swapTotal = value / root._bytesPerGiB
    }
    property Sensors.Sensor swapUsedSensor: Sensors.Sensor {
        sensorId: "memory/swap/used"
        enabled: root.showSwap
        updateRateLimit: root.intervalMs
        onValueChanged: if (root.isNumber(value)) root.swapUsed = value / root._bytesPerGiB
    }
    function updateNetScale() {
        netScale = Math.max(1048576, netDown, netUp, netScale * 0.98)
    }

    property Sensors.Sensor netDownSensor: Sensors.Sensor {
        sensorId: "network/all/download"
        enabled: root.showNetwork
        updateRateLimit: root.intervalMs
        onValueChanged: if (root.isNumber(value)) {
            root.netDown = value
            root.updateNetScale()
        }
    }
    property Sensors.Sensor netUpSensor: Sensors.Sensor {
        sensorId: "network/all/upload"
        enabled: root.showNetwork
        updateRateLimit: root.intervalMs
        onValueChanged: if (root.isNumber(value)) {
            root.netUp = value
            root.updateNetScale()
        }
    }

    property Sensors.Sensor uptimeSensor: Sensors.Sensor {
        sensorId: "os/system/uptime"
        enabled: root.showUptime
        updateRateLimit: root.intervalMs
        onValueChanged: if (root.isNumber(value)) root.uptime = value
    }
}
