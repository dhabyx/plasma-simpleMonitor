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

import "components"
import "../code/code.js" as Code

// Collects every value shown by the skins and exposes it through simple
// properties and list models, so the skins don't depend on the sensors API.
QtObject {
    id: root

    // Configuration (mirrors Plasmoid.configuration).
    readonly property int skin:             Plasmoid.configuration.skin
    readonly property int bgColor:          Plasmoid.configuration.bgColor
    readonly property int logo:             Plasmoid.configuration.logo
    readonly property bool showGpuTemp:     Plasmoid.configuration.showGpuTemp
    readonly property bool showSwap:        Plasmoid.configuration.showSwap
    readonly property bool showUptime:      Plasmoid.configuration.showUptime
    readonly property bool showNetwork:     Plasmoid.configuration.showNetwork
    readonly property int netUnit:          Plasmoid.configuration.netUnit
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
    readonly property string distroName:    String(osNameSensor.value || "")
    readonly property string distroVersion: String(osVersionSensor.value || "")
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

    // Uptime, in seconds.
    property double uptime: 0

    // Models. Roles: cpuModel {val}, coreTempModel {val, dataUnits, coreLabelStr},
    // gpuTempModel {val, dataUnits, gpuLabelStr}.
    readonly property ListModel cpuModel: ListModel {}
    readonly property ListModel coreTempModel: ListModel {}
    readonly property ListModel gpuTempModel: ListModel {}

    // Averages used by the minimalistic skin, kept incrementally so a sensor
    // update costs O(1) instead of re-summing the whole model.
    property real avgLoad: 0
    property real avgTemp: 0
    property real _loadSum: 0
    property real _tempSum: 0

    readonly property int cpuCount: Math.max(0, Math.round(coreCountSensor.value || 0))
    // Logical CPUs expose one temperature each; hyper-threading siblings
    // repeat the value of their core, so only show one entry per physical core.
    readonly property int tempCount: cpuInfo.cpuCores > 0 ? Math.min(cpuInfo.cpuCores, cpuCount) : cpuCount

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
        ensureRows(cpuModel, index + 1, { val: 0 })
        _loadSum += value - cpuModel.get(index).val
        cpuModel.setProperty(index, "val", value)
        avgLoad = _loadSum / cpuModel.count
    }

    function setCoreTemp(index, value) {
        ensureRows(coreTempModel, index + 1, { val: 0, dataUnits: "°C", coreLabelStr: "" })
        _tempSum += value - coreTempModel.get(index).val
        coreTempModel.setProperty(index, "val", value)
        avgTemp = _tempSum / coreTempModel.count
    }

    // Average/maximum modes show a single row that is fed by one sensor.
    function setSingleTemp(label, value) {
        ensureRows(coreTempModel, 1, { val: 0, dataUnits: "°C", coreLabelStr: "" })
        coreTempModel.setProperty(0, "val", value)
        coreTempModel.setProperty(0, "coreLabelStr", label)
        avgTemp = value
    }

    onCpuTempModeChanged: {
        coreTempModel.clear()
        _tempSum = 0
        avgTemp = 0
    }

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

    // CPU temperatures.
    property Instantiator cpuTempSensors: Instantiator {
        model: root.cpuTempMode === 0 ? root.tempCount : 0
        delegate: Sensors.Sensor {
            required property int index
            sensorId: "cpu/cpu" + index + "/temperature"
            updateRateLimit: root.intervalMs
            onValueChanged: if (root.isNumber(value) && value > 0) root.setCoreTemp(index, value)
        }
    }

    property Sensors.Sensor cpuAvgTempSensor: Sensors.Sensor {
        sensorId: "cpu/all/averageTemperature"
        enabled: root.cpuTempMode === 1
        updateRateLimit: root.intervalMs
        onValueChanged: if (root.cpuTempMode === 1 && root.isNumber(value) && value > 0)
                            root.setSingleTemp(i18n("CPU avg:"), value)
    }
    property Sensors.Sensor cpuMaxTempSensor: Sensors.Sensor {
        sensorId: "cpu/all/maximumTemperature"
        enabled: root.cpuTempMode === 2
        updateRateLimit: root.intervalMs
        onValueChanged: if (root.cpuTempMode === 2 && root.isNumber(value) && value > 0)
                            root.setSingleTemp(i18n("CPU max:"), value)
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
