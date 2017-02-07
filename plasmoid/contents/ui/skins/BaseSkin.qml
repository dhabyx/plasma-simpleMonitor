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

import QtQuick 2.0

Item {
    property int bgColor:       confEngine.bgColor
    property int logo:          confEngine.logo
    property bool showSwap:     confEngine.showSwap
    property bool showUptime:   confEngine.showUptime
    property int tempUnit:      confEngine.tempUnit
    property int cpuHighTemp:   confEngine.cpuHighTemp
    property int cpuCritTemp:   confEngine.cpuCritTemp

    property string distroName:     confEngine.distroName
    property string distroId:       confEngine.distroId
    property string distroVersion:  confEngine.distroVersion
    property string kernelName:     confEngine.kernelName
    property string kernelVersion:  confEngine.kernelVersion

    property double memFree
    property double memTotal
    property double memUsed
    property double memBuffers
    property double memCached

    property double swapFree
    property double swapTotal
    property double swapUsed

    property int uptime

    property int direction: confEngine.direction
    LayoutMirroring.enabled: direction === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true
}
