vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

# 获取源码
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uavs3/uavs3d
    REF 1fd04917cff50fac72ae23e45f82ca6fd9130bd8
    SHA512 6ca92391401755175a50ffe405e31b7d68ef6a95956f92f6c08bdc82567e1bda1881047f9dc35fcd96225e3962cd60758ecb1cc37880df4aaabc91fb82f4fe60
    HEAD_REF master
    PATCHES
        fix_ver_cmake.patch
)

# 检查汇编支持
set(ENABLE_ASM OFF)
if("asm" IN_LIST FEATURES)
    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_find_acquire_program(NASM)
        get_filename_component(NASM_PATH "${NASM}" DIRECTORY)
        vcpkg_add_to_path("${NASM_PATH}")
        set(ENABLE_ASM ON)
        message(STATUS "Found NASM: ${NASM}")
    elseif(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
        vcpkg_find_acquire_program(YASM)
        get_filename_component(YASM_PATH "${YASM}" DIRECTORY)
        vcpkg_add_to_path("${YASM_PATH}")
        set(ENABLE_ASM ON)
        message(STATUS "Found YASM: ${YASM}")
    endif()
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

file(COPY "${CMAKE_CURRENT_LIST_DIR}/uavs3d.pc.in"
    DESTINATION 
    "${SOURCE_PATH}/" 
  )


# 设置构建选项
set(BUILD_TOOLS OFF)
if("tools" IN_LIST FEATURES)
    set(BUILD_TOOLS ON)
endif()

# 配置CMake
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCOMPILE_10BIT=ON
        -DENABLE_ASM=${ENABLE_ASM}
        -DBUILD_SHARED_LIBS=OFF
        -DBUILD_TOOLS=${BUILD_TOOLS}
        -DPROJECT_VERSION=${VERSION}
    OPTIONS_DEBUG
        -DUAVS3D_INCLUDE="/../include/"
    OPTIONS_RELEASE
        -DUAVS3D_INCLUDE="/include/"

)

# 构建
vcpkg_cmake_build()

# 安装
vcpkg_cmake_install()

# 修复CMake配置
vcpkg_cmake_config_fixup(PACKAGE_NAME uavs3d)

# 处理工具
if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES uavs3dec
        AUTO_CLEAN
    ) 
endif()

# # 清理
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# 安装许可证
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")


