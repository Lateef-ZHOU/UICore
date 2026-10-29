add_executable(module_smoke smoke.cpp)
target_link_libraries(module_smoke PRIVATE Lidar::UICore)
target_link_libraries(module_smoke PRIVATE LidarUICoreplugin)
add_test(NAME module_smoke COMMAND module_smoke)
set_tests_properties(module_smoke PROPERTIES TIMEOUT 30
    ENVIRONMENT "QT_QPA_PLATFORM=offscreen;QSG_RHI_BACKEND=null"
    ENVIRONMENT_MODIFICATION "PATH=path_list_prepend:$<TARGET_FILE_DIR:Qt6::Core>")

find_package(Qt6 6.11.2 REQUIRED COMPONENTS QuickTest)
add_executable(choice_popup choice_popup.cpp)
target_link_libraries(choice_popup PRIVATE Lidar::UICore LidarUICoreplugin Qt6::QuickTest)
foreach(target module_smoke choice_popup)
    if(MSVC)
        target_compile_options(${target} PRIVATE /W4 /WX /utf-8)
    else()
        target_compile_options(${target} PRIVATE -Wall -Wextra -Wpedantic -Werror)
    endif()
endforeach()
add_test(NAME choice_popup COMMAND choice_popup -input "${CMAKE_CURRENT_SOURCE_DIR}/qml" -o -,txt)
set_tests_properties(choice_popup PROPERTIES TIMEOUT 30
    ENVIRONMENT "QT_QPA_PLATFORM=offscreen;QT_QUICK_BACKEND=software;QT_QUICK_CONTROLS_STYLE=Basic;QT_FORCE_STDERR_LOGGING=1"
    ENVIRONMENT_MODIFICATION "PATH=path_list_prepend:$<TARGET_FILE_DIR:Qt6::Core>")
if(WIN32)
    set_property(TEST choice_popup APPEND PROPERTY ENVIRONMENT "QT_QPA_FONTDIR=$ENV{WINDIR}/Fonts")
    add_test(NAME choice_popup_fluent COMMAND choice_popup -input "${CMAKE_CURRENT_SOURCE_DIR}/qml" -o -,txt)
    set_tests_properties(choice_popup_fluent PROPERTIES TIMEOUT 30
        ENVIRONMENT "QT_QPA_PLATFORM=offscreen;QT_QUICK_BACKEND=software;QT_QUICK_CONTROLS_STYLE=FluentWinUI3;QT_FORCE_STDERR_LOGGING=1;QT_QPA_FONTDIR=$ENV{WINDIR}/Fonts"
        ENVIRONMENT_MODIFICATION "PATH=path_list_prepend:$<TARGET_FILE_DIR:Qt6::Core>")
endif()
