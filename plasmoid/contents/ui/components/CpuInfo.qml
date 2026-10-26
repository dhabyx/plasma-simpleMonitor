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
import org.kde.plasma.plasma5support as Plasma5Support

import "../../code/code.js" as Code

// Number of physical CPU cores. The sensors only report logical CPUs, so
// hyper-threading siblings can't be told apart without /proc/cpuinfo.
QtObject {
    id: root

    // Nothing is run while disabled.
    property bool enabled: true
    property int cpuCores: 0

    property Plasma5Support.DataSource source: Plasma5Support.DataSource {
        engine: "executable"
        connectedSources: root.enabled ? [Code.cpuCoresCommand] : []

        onNewData: (sourceName, data) => {
            if (data["stdout"])
                root.cpuCores = Code.parseCpuCores(data["stdout"])
            disconnectSource(sourceName)
        }
    }
}
