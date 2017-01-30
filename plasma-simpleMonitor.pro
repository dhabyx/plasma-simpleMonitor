TEMPLATE = app

QT += qml quick
CONFIG += c++11

SOURCES +=

RESOURCES +=

QML_IMPORT_PATH = /usr/lib64/qt5/qml/

DISTFILES += \
    plasmoid/contents/code/monitorActions.js \
    plasmoid/metadata.desktop \
    plasmoid/contents/fonts/Doppio_One/DoppioOne-Regular.ttf \
    plasmoid/contents/fonts/Michroma/Michroma.ttf \
    plasmoid/contents/fonts/Monda/Monda-Bold.ttf \
    plasmoid/contents/fonts/Monda/Monda-Regular.ttf \
    plasmoid/contents/fonts/Play/Play-Bold.ttf \
    plasmoid/contents/fonts/Play/Play-Regular.ttf \
    build.sh \
    plasmoid/contents/config/main.xml \
    plasmoid/contents/images/distro-kubuntu.png \
    plasmoid/contents/images/distro-slackware.png \
    plasmoid/contents/images/distro-tux.png \
    plasmoid/contents/images/distro-tuz.png \
    plasmoid/contents/images/distro-ubuntu.png \
    plasmoid/contents/images/distro-slackware.svg \
    plasmoid/contents/images/icon.svg \
    plasmoid/contents/fonts/Doppio_One/OFL.txt \
    plasmoid/contents/fonts/Michroma/OFL.txt \
    plasmoid/contents/fonts/Monda/OFL.txt \
    plasmoid/contents/fonts/Play/OFL.txt \
    COPYING \
    README.md \
    plasmoid/contents/ui/monitorWidgets/CoreTempList.qml \
    plasmoid/contents/ui/monitorWidgets/CpuWidget.qml \
    plasmoid/contents/ui/monitorWidgets/DatePicker.qml \
    plasmoid/contents/ui/monitorWidgets/HighlightCpu.qml \
    plasmoid/contents/ui/monitorWidgets/MemArea.qml \
    plasmoid/contents/ui/monitorWidgets/OsInfoItem.qml \
    plasmoid/contents/ui/monitorWidgets/UptimePicker.qml \
    plasmoid/contents/ui/main.qml

FORMS += \
    plasmoid/contents/ui/config.ui

