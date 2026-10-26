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

// Static information about the system (distribution, kernel, CPU cores).
QtObject {
    id: root

    property string distroName: "tux"
    property string distroId: "tux"
    property string distroVersion: ""
    property string kernelName: ""
    property string kernelVersion: ""
    property int cpuCores: 0

    property Plasma5Support.DataSource source: Plasma5Support.DataSource {
        engine: "executable"
        connectedSources: [Code.systemInfoCommand]

        onNewData: (sourceName, data) => {
            if (data["exit code"] !== undefined && data["stdout"]) {
                var info = Code.parseSystemInfo(data["stdout"])
                root.distroName = info.os.name || "tux"
                root.distroId = Code.resolveLogoId(info.os)
                root.distroVersion = info.os.version
                root.kernelName = info.kernel.name
                root.kernelVersion = info.kernel.version
                root.cpuCores = info.cpuCores
            }
            disconnectSource(sourceName)
        }
    }
}
