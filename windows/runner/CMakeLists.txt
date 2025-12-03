cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "Runner.rc"
  "runner.exe.manifest"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the build version.
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"${FLUTTER_VERSION}\"")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}")

# set(SINGBOX_EXE "${CMAKE_CURRENT_SOURCE_DIR}/resources/singbox.exe")
# file(COPY ${SINGBOX_EXE} DESTINATION ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})

set(SINGBOX_EXE "${CMAKE_CURRENT_SOURCE_DIR}/resources/singbox.exe")
set(GLOBAL_JSON "${CMAKE_CURRENT_SOURCE_DIR}/resources/global.xml")
set(AI_JSON "${CMAKE_CURRENT_SOURCE_DIR}/resources/ai.xml")
set(GEO_JSON_1 "${CMAKE_CURRENT_SOURCE_DIR}/resources/geoip-cn.srs")
set(GEO_JSON_2 "${CMAKE_CURRENT_SOURCE_DIR}/resources/geosite-cn.srs")
set(GEO_JSON_3 "${CMAKE_CURRENT_SOURCE_DIR}/resources/geosite-geolocation-!cn.srs")
set(GEO_JSON_4 "${CMAKE_CURRENT_SOURCE_DIR}/resources/geosite-geolocation-cn.srs")
add_custom_command(
    TARGET ${BINARY_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${SINGBOX_EXE}"
        "$<TARGET_FILE_DIR:${BINARY_NAME}>/singbox.exe"

    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${GLOBAL_JSON}"
        "$<TARGET_FILE_DIR:${BINARY_NAME}>/global.xml"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${AI_JSON}"
        "$<TARGET_FILE_DIR:${BINARY_NAME}>/ai.xml"

    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${GEO_JSON_1}"
        "$<TARGET_FILE_DIR:${BINARY_NAME}>/geoip-cn.srs"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${GEO_JSON_2}"
        "$<TARGET_FILE_DIR:${BINARY_NAME}>/geosite-cn.srs"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${GEO_JSON_3}"
        "$<TARGET_FILE_DIR:${BINARY_NAME}>/geosite-geolocation-!cn.srs"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${GEO_JSON_4}"
        "$<TARGET_FILE_DIR:${BINARY_NAME}>/geosite-geolocation-cn.srs"
)



# Disable Windows macros that collide with C++ standard library functions.
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")

# Add dependency libraries and include directories. Add any application-specific
# dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib")
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# Run the Flutter tool portions of the build. This must not be removed.
add_dependencies(${BINARY_NAME} flutter_assemble)
