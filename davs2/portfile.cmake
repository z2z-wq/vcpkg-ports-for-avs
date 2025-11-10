vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pkuvcl/davs2
    REF b41cf117452e2d73d827f02d3e30aa20f1c721ac
    SHA512 fac67ea3a5f8251212994a075c7e6236ca3a7b92b3763cfdfa8f696272263b8aa074aea5b2bc8536b2e17111da1fb89f00b0cc071113da6b04aa0eee6df46c25
    HEAD_REF master
    PATCHES
        bug_fix.patch
)


if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_find_acquire_program(NASM)
    get_filename_component(NASM_PATH "${NASM}" DIRECTORY)
    vcpkg_add_to_path("${NASM_PATH}")
else()
    vcpkg_find_acquire_program(YASM)
    get_filename_component(YASM_PATH "${YASM}" DIRECTORY)
    vcpkg_add_to_path("${YASM_PATH}")
endif()


if(VCPKG_HOST_IS_WINDOWS)
    vcpkg_acquire_msys(MSYS_ROOT PACKAGES automake)
    set(SHELL "${MSYS_ROOT}/usr/bin/bash.exe")
    list(APPEND prog_env "${MSYS_ROOT}/usr/bin")
else()
    find_program(SHELL bash)
endif()

message(STATUS "shell=" "${SHELL}")
#生成 common/version.h文件
vcpkg_execute_required_process(
    COMMAND "${SHELL}" version.sh
     WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME generate-version
)

file(COPY "${SOURCE_PATH}/version.h" 
    DESTINATION "${SOURCE_PATH}/source" 
    )

# 创建CMakeLists.txt
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
    DESTINATION 
    "${SOURCE_PATH}/" 
  )

file(COPY "${CMAKE_CURRENT_LIST_DIR}/x86/CMakeLists.txt"
    DESTINATION 
    "${SOURCE_PATH}/source/common/x86/" 
  )  
 file(COPY "${CMAKE_CURRENT_LIST_DIR}/vec/CMakeLists.txt"
    DESTINATION 
    "${SOURCE_PATH}/source/common/vec/" 
  ) 

file(COPY "${CMAKE_CURRENT_LIST_DIR}/davs2.pc.in"
    DESTINATION 
    "${SOURCE_PATH}/" 
  )



set(DAVS2_INCLUDE_PATH "/include")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPROJECT_VERSION=${VERSION}
    OPTIONS_DEBUG
        -DDAVS2_INCLUDE_PATH="/../include/"
    OPTIONS_RELEASE
        -DDAVS2_INCLUDE_PATH="/include/" 
)


vcpkg_cmake_build()
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME davs2)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" 
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" 
     RENAME copyright)