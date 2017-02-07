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
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import QtQuick.Controls 1.0

import "../code/code.js" as Code

Rectangle {
    id: root

    width: implicitWidth
    height: implicitHeight

    implicitWidth: loader.implicitWidth
    implicitHeight: loader.implicitHeight

    Layout.minimumWidth: implicitWidth
    Layout.minimumHeight: implicitHeight
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight

    Plasmoid.preferredRepresentation: plasmoid.fullRepresentation

    color: "black"

    // control for atk sensor
    property bool atkPresent: false

    Component.onCompleted: atkPresent = false

    QtObject {
        id: confEngine

        // cfg properties
        property int skin:          plasmoid.configuration.skin
        property int bgColor:       plasmoid.configuration.bgColor
        property int logo:          plasmoid.configuration.logo
        property bool showSwap:     plasmoid.configuration.showSwap
        property bool showUptime:   plasmoid.configuration.showUptime
        property int tempUnit:      plasmoid.configuration.tempUnit
        property int cpuHighTemp:   plasmoid.configuration.cpuHighTemp
        property int cpuCritTemp:   plasmoid.configuration.cpuCritTemp

        property string distroName: "tux"
        property string distroId: "tux"
        property string distroVersion: ""
        property string kernelName: ""
        property string kernelVersion: ""

        property int direction: Qt.LeftToRight

        onSkinChanged: {
            switch (skin) {
            default:
            case 0:
                loader.source = "skins/DefaultSkin.qml";
                root.Layout.maximumWidth = root.Layout.preferredWidth;
                root.Layout.maximumHeight = root.Layout.preferredHeight;
                root.Layout.maximumWidth = Number.POSITIVE_INFINITY;
                root.Layout.maximumHeight = Number.POSITIVE_INFINITY;
                break;
            case 1:
                loader.source = "skins/ColumnSkin.qml"
                root.Layout.maximumWidth = root.Layout.preferredWidth;
                root.Layout.maximumHeight = root.Layout.preferredHeight;
                root.Layout.maximumWidth = Number.POSITIVE_INFINITY;
                root.Layout.maximumHeight = Number.POSITIVE_INFINITY;
                break;
            }
        }

        onBgColorChanged: {
            switch (bgColor) {
            default:
            case 0:
                root.color = "black";
                plasmoid.backgroundHints = "StandardBackground";
                break;
            case 1:
                root.color = "transparent";
                plasmoid.backgroundHints = "NoBackground";
                break;
            case 2:
                root.color = "transparent";
                plasmoid.backgroundHints = "TranslucentBackground";
                break;
            }
        }

        Component.onCompleted: {
            Code.getDistroInfo(function(info) {
                distroName = info['name']
                distroId = info['id']
                distroVersion = info['version']
            }, this);

            Code.getKernelInfo(function(info){
                kernelName = info['name']
                kernelVersion = info['version']
            }, this);
        }
    }

    ListModel {
        id: cpuModel
    }

    ListModel {
        id: coreTempModel
    }

    PlasmaCore.DataSource {
        id: systemInfoDataSource
        engine: "systemmonitor"
        interval: 1000

        property alias delegate: loader.item

        function tryAddSource(source) {
            if (connectedSources.indexOf(source) !== -1)
                return;

            // connect to cpu load sources
            if (source.match("^cpu/cpu\\d+/TotalLoad")) {
                connectSource(source);
                return;
            }

            // connect to cpu temp sources
            if (source.match("^lmsensors/coretemp-isa-\\d+/Core_\\d+")) {
                connectSource(source);
                return;
            }
            if (source.match("^lmsensors/k\\d+temp-pci-.+/temp\\d+")) {
                /* if atk is present then not connect */
                if (!root.atkPresent)
                    connectSource(source);
                return;
            }
            /* Some AMD sensors works better with atk data*/
            if (source.match("^lmsensors/atk\\d+-acpi-\\d/CPU_Temperature")) {
                /* Remove k# temp sensors previously connected*/
                if (!root.atkPresent) {
                    for (i in connectedSources) {
                        if (i.match("^lmsensors/k\\d+temp-pci-.+/temp\\d+")) {
                            disconnectSource(i);
                            coreTempModel.clear();
                        }

                    }
                }
                root.atkPresent = true;
                connectSource(source);
                return;
            }

            // connect memory sources
            if (source.match("^mem/.*")) {
                connectSource(source);
                return;
            }

            // connect uptime source
            if (source.match("^system/uptime")) {
                connectSource(source);
                return;
            }
        }

        onSourceAdded: tryAddSource(source)

        onNewData: {
            if (data.value === undefined || delegate === undefined)
                return;

            // cpu load
            if (sourceName.match("^cpu/cpu\\d+/TotalLoad")) {
                var cpuNumber = sourceName.split('/')[1].match(/\d+/);
                if (cpuModel.count <= cpuNumber)
                    cpuModel.append({'val':data.value});
                else
                    cpuModel.set(cpuNumber,{'val':data.value});
                return;
            }

            // cpu temp
            if (sourceName.match("^lmsensors/coretemp-isa-\\d+/Core_\\d+")
                    || sourceName.match("^lmsensors/k\\d+temp-pci-.+/temp\\d+")
                    || sourceName.match("^lmsensors/atk\\d+-acpi-\\d/CPU_Temperature")) {
                var dataName = "0";
                if (root.atkPresent)
                    dataName=sourceName.replace(/^lmsensors\/atk\\d+-acpi-/i,"").replace(/\/CPU_Temperature/i,"");
                else
                    dataName=data.name.split(' ')[1];

                if (coreTempModel.count <= dataName)
                    coreTempModel.append({'val':data.value, 'units':data.units});
                else
                    coreTempModel.set(dataName,{'val':data.value, 'units':data.units});

                return;
            }

            // memory
            if (sourceName.match("^mem/physical/free")) {
                delegate.memFree=data.value/1048576;
                delegate.memTotal=data.max/1048576;
                return;
            }
            if (sourceName.match("^mem/physical/used")) {
                delegate.memUsed=data.value/1048576;
                return;
            }
            if (sourceName.match("^mem/physical/buf")) {
                delegate.memBuffers=data.value/1048576;
                return;
            }
            if (sourceName.match("^mem/physical/cached")) {
                delegate.memCached=data.value/1048576;
                return;
            }
            if (sourceName.match("^mem/swap/used")) {
                delegate.swapUsed=data.value/1048576;
                delegate.swapTotal=data.max/1048576;
                return;
            }
            if (sourceName.match("^mem/swap/free")) {
                delegate.swapFree=data.value/1048576;
                return;
            }

            // uptime
            if (sourceName.match("^system/uptime")) {
                delegate.uptime = data.value;
                return;
            }
        }

        Component.onCompleted: {
            for (var i in systemInfoDataSource.sources)
                systemInfoDataSource.tryAddSource(systemInfoDataSource.sources[i]);
        }

        Component.onDestruction: {
            for (var i = connectedSources.length; i > 0; --i)
                disconnectSource(connectedSources[i - 1]);
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
        source: "skins/DefaultSkin.qml"
    }
}
