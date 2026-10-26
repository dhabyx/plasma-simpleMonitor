cmake_minimum_required(VERSION 3.16)

project(plasma-simpleMonitor)

find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

find_package(Plasma REQUIRED)
include(KDEInstallDirs)

add_subdirectory(translations)

plasma_install_package(plasmoid org.kde.simpleMonitor)

install(FILES plasmoid/contents/images/simpleMonitor_icon.svg
        DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
