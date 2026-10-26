cmake_minimum_required(VERSION 3.16)

file(GLOB_RECURSE MO_FILES RELATIVE ${CMAKE_CURRENT_LIST_DIR} "*.mo")

foreach(_mo ${MO_FILES})
    get_filename_component(_langLocation ${_mo} DIRECTORY)
    install(FILES ${_mo} DESTINATION ${KDE_INSTALL_LOCALEDIR}/${_langLocation})
endforeach()
