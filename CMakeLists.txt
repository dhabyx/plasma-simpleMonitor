cmake_minimum_required(VERSION 2.8.12)

project(plasma-simpleMonitor)

find_package(ECM 1.4.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${ECM_KDE_MODULE_DIR} ${CMAKE_MODULE_PATH})
# set(QML_IMPORT_PATH "/usr/lib64/qt5/qml/")

find_package(KF5Plasma REQUIRED)

add_subdirectory(translations)

plasma_install_package(plasmoid org.kde.simpleMonitor)
