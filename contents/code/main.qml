import QtQuick 1.1
import org.kde.plasma.core 0.1 as PlasmaCore
import "monitorWidgets/js/monitorActions.js" as MonitorActions
import "monitorWidgets"

Rectangle {
    width: 360
    height: 360

    color: "transparent"
    property int minimumWidth: 240
    property int minimumHeight: 340
    //color: "black"

    FontLoader {
        id: mondaRegular
        source: "fonts/Monda/Monda-Regular.ttf"
    }

    FontLoader {
        id: doppioOneRegular
        source: "fonts/Doppio_One/DoppioOne-Regular.ttf"
    }

    Image {
        id: distroLogo
        source: "monitorWidgets/images/distro-tux.png"
        y: 73
        x: 0
    }

    DatePicker {
        id: datePicker
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 15
    }

    OsInfoItem {
        id: osInfoItem
        width: distroLogo.width
        anchors.top: distroLogo.bottom
        anchors.left: distroLogo.left
    }

    Rectangle {
        id: topBar
        color: "white"
        y: 102
        x: 108
        height: 3
        width: parent.width-x-5
    }

    UptimePicker {
        id: uptimePicker
        height: 15
        width: 115
        anchors.right: topBar.right
        anchors.bottom: topBar.top
        anchors.bottomMargin: 2
    }

    CpuWidget {
        id: cpuList
        width: 140
        height: 205
        anchors.right: parent.right
        anchors.top: topBar.bottom
        anchors.topMargin: 5
    }

    Rectangle {
        id: midBar
        color: "white"
        height: 206
        width: topBar.height
        anchors.right: cpuList.left
        anchors.top: topBar.bottom
        anchors.topMargin: 5
        anchors.rightMargin: 5
    }

    CoreTempList {
        id: coreTempList
        anchors.right: midBar.left
        anchors.rightMargin: 5
        anchors.top: topBar.bottom
        anchors.topMargin: 5
        model: coreTempModel
    }

    MemArea {
        id: memArea
        anchors.top: osInfoItem.bottom
        anchors.margins: 50
        anchors.left: parent.left
        anchors.leftMargin: 15
        anchors.right: midBar.left
        anchors.rightMargin: 5
    }

    MemArea {
        id: swapArea
        anchors.top: memArea.bottom
        anchors.margins: 50
        anchors.left: parent.left
        anchors.leftMargin: 15
        anchors.right: midBar.left
        anchors.rightMargin: 5
        memTypeLabel: qsTr("Swap:")
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
        onSourceAdded : {
            if (source.match("^cpu/cpu\\d+/TotalLoad")) {
                connectSource(source)
                return
            }
            if (source.match("^lmsensors/coretemp-isa-\\d+/Core_\\d+")) {
                connectSource(source)
                return
            }
            if (source.match("^mem/.*")) {
                connectSource(source)
                return
            }
            if (source.match("^system/uptime")) {
                connectSource(source)
                return
            }
        }
        onNewData: {
            if (data.value === undefined ) {return}
            if (sourceName.match("^cpu/cpu\\d+/TotalLoad")) {
                var cpuNumber = sourceName.split('/')[1].match(/\d+/)
                MonitorActions.modelAddData(cpuModel,cpuNumber,{'val':data.value})
                return
            }
            if (sourceName.match("^lmsensors/coretemp-isa-\\d+/Core_\\d+")) {
                MonitorActions.modelAddData(
                            coreTempModel,
                            data.name.split(' ')[1],
                            {'val':data.value, 'units':data.units}
                            )
                return
            }
            if (sourceName.match("^mem/physical/free")) {
                memArea.memFree=data.value/1048576
                memArea.memTotal=data.max/1048576
                return
            }
            if (sourceName.match("^mem/physical/used")) {
                memArea.memUsed=data.value/1048576
                return
            }
            if (sourceName.match("^mem/physical/buf")) {
                memArea.memBuffers=data.value/1048576
                return
            }
            if (sourceName.match("^mem/physical/cached")) {
                memArea.memCached=data.value/1048576
                return
            }
            if (sourceName.match("^mem/swap/used")) {
                swapArea.memUsed=data.value/1048576
                swapArea.memTotal=data.max/1048576
                return
            }
            if (sourceName.match("^mem/swap/free")) {
                swapArea.memFree=data.value/1048576
                return
            }
            if (sourceName.match("^system/uptime")) {
                var uptimeArray =[]
                uptimeArray['d'] = Math.floor(data.value/86400)
                uptimeArray['h'] = Math.floor(data.value/3600)-24*uptimeArray['d']
                uptimeArray['m'] = Math.floor(data.value/60)-60*uptimeArray['h']
                uptimePicker.uptime = uptimeArray['d']+'d '+uptimeArray['h']
                        +':'+MonitorActions.formatNumberLength(uptimeArray['m'],2)
                return
            }
        }
        Component.onDestruction: {
            interval = 0
            for (i in connectedSources) {
                console.log("discconect: "+connectedSources[0])
                disconnectSource(connectedSources[0])
            }
        }
    }
    Component.onCompleted: {
        if (MonitorActions.getLogoInfo() != "tux") {
            distroLogo.source = "monitorWidgets/images/distro-"+MonitorActions.getLogoInfo()+".png"
        }
        plasmoid.addEventListener('ConfigChanged', MonitorActions.configListener)
    }

}

