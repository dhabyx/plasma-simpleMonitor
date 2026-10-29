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

// Base of every skin. `engine` is the SystemData object created by main.qml.
Item {
    id: base

    property QtObject engine

    readonly property int bgColor:           engine.bgColor
    readonly property int logo:              engine.logo
    readonly property bool showGpuTemp:      engine.showGpuTemp
    readonly property bool showSwap:         engine.showSwap
    readonly property bool showUptime:       engine.showUptime
    readonly property bool showNetwork:      engine.showNetwork
    readonly property int netUnit:           engine.netUnit
    readonly property int tempUnit:          engine.tempUnit
    readonly property int cpuHighTemp:       engine.cpuHighTemp
    readonly property int cpuCritTemp:       engine.cpuCritTemp
    readonly property bool coloredCpuLoad:   engine.coloredCpuLoad
    readonly property bool flatCpuLoad:      engine.flatCpuLoad
    readonly property int indicatorHeight:   engine.indicatorHeight
    readonly property double updateInterval: engine.updateInterval

    readonly property string distroName:     engine.distroName
    readonly property string distroVersion:  engine.distroVersion
    readonly property string kernelName:     engine.kernelName
    readonly property string kernelVersion:  engine.kernelVersion

    readonly property double memFree:        engine.memFree
    readonly property double memTotal:       engine.memTotal
    readonly property double memUsed:        engine.memUsed

    readonly property double swapFree:       engine.swapFree
    readonly property double swapTotal:      engine.swapTotal
    readonly property double swapUsed:       engine.swapUsed

    readonly property double netDown:        engine.netDown
    readonly property double netUp:          engine.netUp
    readonly property double netScale:       engine.netScale
    readonly property string netIface:       engine.netIface
    readonly property string netIp:          engine.netIp
    readonly property bool showPing:         engine.showPing
    readonly property double pingMs:         engine.pingMs

    readonly property double uptime:         engine.uptime

    readonly property ListModel cpuModel:      engine.cpuModel
    readonly property ListModel coreTempModel: engine.coreTempModel
    readonly property ListModel gpuTempModel:  engine.gpuTempModel

    property int direction: Qt.LeftToRight
    LayoutMirroring.enabled: direction === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true
}
