import QtQuick 1.1
import "js/monitorActions.js" as MonitorActions

Item {

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: -8
        Text {
            id: distroInfo
            text: "Distro "
            color: "white"
            anchors.horizontalCenter: parent.horizontalCenter
            font { family: mondaRegular.name; pointSize: 10 }
            Component.onCompleted: {
                var xhr = new XMLHttpRequest;
                xhr.open("GET", "/etc/os-release");
                xhr.onreadystatechange = function() {
                    if (xhr.readyState == XMLHttpRequest.DONE) {
                        var osInfo = MonitorActions.parseOsRelease(xhr.responseText)
                        text = osInfo.name+" "+osInfo.version
                    }
                }
                xhr.send();
            }
        }
        
        Text {
            id: kernelInfo
            text:"Kernel"
            color: "white"
            anchors.horizontalCenter: parent.horizontalCenter
            font { family: mondaRegular.name; pointSize: 10 }
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
