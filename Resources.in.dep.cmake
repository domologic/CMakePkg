set(RESOURCES_DEBUG       "@RESOURCES_DEBUG@")
set(RESOURCES_RELEASE     "@RESOURCES_RELEASE@")
set(RESOURCES_ALL         "@RESOURCES_ALL@")

set(RESOURCE_DIRS_DEBUG   "@RESOURCE_DIRS_DEBUG@")
set(RESOURCE_DIRS_RELEASE "@RESOURCE_DIRS_RELEASE@")
set(RESOURCE_DIRS_ALL     "@RESOURCE_DIRS_ALL@")

if (NOT "${RESOURCES_DEBUG}" STREQUAL "")
  install(
    FILES
      ${RESOURCES_DEBUG}
    CONFIGURATIONS
      Debug
    DESTINATION
      ${OUTPUT_DIRECTORY}
  )
endif()

if (NOT "${RESOURCES_RELEASE}" STREQUAL "")
  install(
    FILES
      ${RESOURCES_RELEASE}
    CONFIGURATIONS
      Release
    DESTINATION
      ${OUTPUT_DIRECTORY}
  )
endif()

if (NOT "${RESOURCES_ALL}" STREQUAL "")
  install(
    FILES
      ${RESOURCES_ALL}
    DESTINATION
      ${OUTPUT_DIRECTORY}
  )
endif()

if (NOT "${RESOURCE_DIRS_DEBUG}" STREQUAL "")
  foreach (RESOURCE_DIR ${RESOURCE_DIRS_DEBUG})
    install(
      DIRECTORY
        ${RESOURCE_DIR}
      CONFIGURATIONS
        Debug
      DESTINATION
        ${OUTPUT_DIRECTORY}
    )
  endforeach()
endif()

if (NOT "${RESOURCE_DIRS_RELEASE}" STREQUAL "")
  foreach (RESOURCE_DIR ${RESOURCE_DIRS_RELEASE})
    install(
      DIRECTORY
        ${RESOURCE_DIR}
      CONFIGURATIONS
        Release
      DESTINATION
        ${OUTPUT_DIRECTORY}
    )
  endforeach()
endif()

if (NOT "${RESOURCE_DIRS_ALL}" STREQUAL "")
  foreach (RESOURCE_DIR ${RESOURCE_DIRS_ALL})
    install(
      DIRECTORY
        ${RESOURCE_DIR}
      DESTINATION
        ${OUTPUT_DIRECTORY}
    )
  endforeach()
endif()