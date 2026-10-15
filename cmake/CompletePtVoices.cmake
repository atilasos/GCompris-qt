# SPDX-License-Identifier: BSD-3-Clause
# Resource inspection executes on the build host, never the target device.
function(gcompris_complete_pt_voices assets_target)
  if(NOT COMPRESSED_AUDIO STREQUAL "ogg" OR CMAKE_CROSSCOMPILING)
    return()
  endif()
  add_executable(pt_audio_rcc_inventory EXCLUDE_FROM_ALL
    tools/pt-pt-audio/rcc_inventory.cpp)
  target_link_libraries(pt_audio_rcc_inventory PRIVATE ${QT_MAJOR}::Core)
  add_dependencies(${assets_target} pt_audio_rcc_inventory)
  add_custom_command(TARGET ${assets_target} POST_BUILD
    COMMAND python3 "${CMAKE_SOURCE_DIR}/tools/pt-pt-audio/complete_voices.py"
      --voices-dir "${GCOMPRIS_ASSETS_DIR}/data3/voices-ogg"
      --inventory-tool "$<TARGET_FILE:pt_audio_rcc_inventory>"
      --rcc-tool "$<TARGET_FILE:${QT_MAJOR}::rcc>"
      --if-present
    VERBATIM)
endfunction()
