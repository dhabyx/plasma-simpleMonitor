find_package(Gettext REQUIRED)
set(translation_domain plasma_applet_org.kde.simpleMonitor)
file(GLOB po_files CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/*/LC_MESSAGES/${translation_domain}.po")
foreach(po IN LISTS po_files)
    get_filename_component(messages_dir "${po}" DIRECTORY)
    get_filename_component(language_dir "${messages_dir}" DIRECTORY)
    get_filename_component(language "${language_dir}" NAME)
    set(mo "${CMAKE_CURRENT_BINARY_DIR}/${language}/LC_MESSAGES/${translation_domain}.mo")
    add_custom_command(OUTPUT "${mo}"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${CMAKE_CURRENT_BINARY_DIR}/${language}/LC_MESSAGES"
        COMMAND "${GETTEXT_MSGFMT_EXECUTABLE}" --check -o "${mo}" "${po}"
        DEPENDS "${po}" VERBATIM)
    list(APPEND mo_files "${mo}")
    install(FILES "${mo}" DESTINATION "${KDE_INSTALL_LOCALEDIR}/${language}/LC_MESSAGES")
endforeach()
add_custom_target(translations ALL DEPENDS ${mo_files})
