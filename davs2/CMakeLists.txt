
cmake_minimum_required(VERSION 3.16)
project(davs2 LANGUAGES C CXX)

set(CMAKE_C_STANDARD 11)
set(PROJECT_VERSION "${PROJECT_VERSION}" CACHE STRING "Project version")


# 源文件
file(GLOB DAVS2_SOURCES 
    source/common/*.c
    source/common/*.cc
    source/common/*.h
    source/configw.h
)

file(GLOB DAVS2_HEADERS
    source/davs2.h
)


# 创建库
add_library(davs2  ${DAVS2_SOURCES} )

if(MSVC)
    # 移除可能的UTF-8选项
    string(REPLACE "/utf-8" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    string(REPLACE "/utf-8" "" CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
    
    # 添加GBK编码支持
    target_compile_definitions(davs2 PRIVATE "/source-charset:gbk")
    target_compile_definitions(davs2 PRIVATE "/execution-charset:utf-8")
    # add_compile_options(/execution-charset:utf-8)
    message(STATUS "Set MSVC to use GBK source charset")
endif()

add_subdirectory(source/common/vec)
add_subdirectory(source/common/x86)


# 编译定义
target_compile_definitions(davs2 PRIVATE
    BIT_DEPTH=8
    ARCH_X86_64=1
    HIGH_BIT_DEPTH=0
    DAVS2_EXPORTS
)

# 包含目录
target_include_directories(davs2 
    PUBLIC 
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/source/common>
        $<INSTALL_INTERFACE:include>
    PRIVATE
        source/common
        source
)

target_link_libraries(davs2 
    PRIVATE 
        libdavs2_asm
        libdavs2_intrin_sse2
        libdavs2_intrin_avx
)

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/davs2.pc.in
    ${CMAKE_CURRENT_BINARY_DIR}/davs2.pc
    @ONLY
)

# 安装
install(TARGETS davs2
    EXPORT davs2-targets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(FILES ${DAVS2_HEADERS}
    DESTINATION include/davs2
)

install(EXPORT davs2-targets
    FILE davs2-config.cmake
    DESTINATION share/davs2
)

install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/davs2.pc
    DESTINATION lib/pkgconfig
)

