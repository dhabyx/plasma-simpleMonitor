import QtQuick 1.1
import "js/monitorActions.js" as MonitorActions

Item {
    property string distroName : "tux"
    FontLoader {
        id: mondaRegular
        source: "../fonts/Monda/Monda-Regular.ttf"
    }

    Column {
        spacing: 1
        anchors.fill: parent
        Text {
            id: distroInfo
            text: "Distro "
            color: "white"
            width: parent.width
            lineHeight: 0.6
            horizontalAlignment: Text.AlignHCenter
            font { family: mondaRegular.name; pointSize: 9 }
            Component.onCompleted: {
                var xhr = new XMLHttpRequest;
                xhr.open("GET", "/etc/os-release");
                xhr.onreadystatechange = function() {
                    if (xhr.readyState == XMLHttpRequest.DONE) {
                        var osInfo = MonitorActions.parseOsRelease(xhr.responseText)
                        if (osInfo.version.indexOf(',')>=0) {
                            var distroStr=osInfo.name+" "
                            distroStr +=osInfo.version.substring(0,osInfo.version.indexOf(','))+'\n'
                            distroStr +=osInfo.version.substring(
                                        osInfo.version.indexOf(',')+2,
                                        osInfo.version.length)
                            text = distroStr
                        } else
                            text = osInfo.name+" "+osInfo.version
                        distroName = osInfo.name
                    }
                }
                xhr.send();
            }
        }
        
        Text {
            id: kernelInfo
            text:"Kernel"
            color: "white"
            width: parent.width
            lineHeight: 0.6
            horizontalAlignment: Text.AlignHCenter
            font { family: mondaRegular.name; pointSize: 9 }
            Component.onCompleted: {
                var xhr = new XMLHttpRequest;
                xhr.open("GET", "/proc/version");
                xhr.onreadystatechange = function() {
                    if (xhr.readyState == XMLHttpRequest.DONE) {
                        var kernelInfoArray = MonitorActions.parseKernelRelease(xhr.responseText)
                        text = kernelInfoArray.name+" "+kernelInfoArray.version
                    }
                }
                xhr.send();
            }
        }
    }
}
