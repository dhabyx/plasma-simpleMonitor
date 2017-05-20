cmake_minimum_required(VERSION 2.8.12)

set(_trDir locales)
set(catalogName plasma_applet_org.kde.simpleMonitor)

find_program(GETTEXT_MSGFMT_EXEC msgfmt)

add_custom_target(translations-plasmoid ALL)

if(NOT GETTEXT_MSGFMT_EXEC)
  message(WARNING "-- msgfmt: not found. Translations will *not* be installed")
else()
  file(GLOB_RECURSE PO_FILES RELATIVE ${CMAKE_CURRENT_LIST_DIR} "${catalogName}.po")
  message(${CMAKE_CURRENT_LIST_DIR})

  foreach(_PO ${PO_FILES})
    # message("file: ${_PO}")
    set(_MO ${CMAKE_CURRENT_BINARY_DIR}/${_trDir}/${_langLocation}/${catalogName}.mo)
    get_filename_component(_langLocation ${_PO} DIRECTORY)
    # message("path: ${_MO}")
    get_filename_component(_moLocation ${_MO} DIRECTORY)
    file(MAKE_DIRECTORY ${_moLocation})
    add_custom_command(TARGET translations-plasmoid
                        COMMAND ${GETTEXT_MSGFMT_EXEC} --check -o ${_MO} ${CMAKE_CURRENT_LIST_DIR}/${_PO}
                        DEPENDS ${_PO})
    install(FILES ${_MO}
    DESTINATION ${LOCALE_INSTALL_DIR}/${KF5_LOCALE_PREFIX}/${_langLocation}/)
  endforeach(_PO ${PO_FILES})
endif()
