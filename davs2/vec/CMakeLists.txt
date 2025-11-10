cmake_minimum_required(VERSION 3.16)
project(vec LANGUAGES CXX)
set(CMAKE_C_STANDARD 11)
if(MSVC)
    # 移除可能的UTF-8选项
    string(REPLACE "/utf-8" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    string(REPLACE "/utf-8" "" CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
    
    # 添加GBK编码支持

    add_compile_options(/source-charset:gbk)
    add_compile_options(/execution-charset:utf-8)
    message(STATUS "Set MSVC to use GBK source charset")
endif()
set(SSE_SRC 
    intrinsic.cc
    intrinsic_alf.cc
    intrinsic_deblock.cc
    intrinsic_idct.cc
    intrinsic_idct_avx2.cc
    intrinsic_inter_pred.cc
    intrinsic_intra-filledge.cc
    intrinsic_intra-pred.cc
    intrinsic_pixel.cc
    intrinsic_sao.cc
)

set(AVX_SRC
   intrinsic_deblock_avx2.cc
   intrinsic_idct_avx2.cc
   intrinsic_inter_pred_avx2.cc
   intrinsic_intra-pred_avx2.cc
   intrinsic_pixel_avx.cc
   intrinsic_sao_avx2.cc
)

add_library(libdavs2_intrin_sse2 STATIC ${SSE_SRC})
add_library(libdavs2_intrin_avx STATIC ${AVX_SRC})
target_compile_definitions(libdavs2_intrin_sse2 PRIVATE 
    ARCH_X86_64=1
    BIT_DEPTH=8
    HIGH_BIT_DEPTH=0
)
target_compile_definitions(libdavs2_intrin_avx PRIVATE 
    ARCH_X86_64=1
    BIT_DEPTH=8
    HIGH_BIT_DEPTH=0
)
target_include_directories(libdavs2_intrin_sse2
    PUBLIC 
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}../../>
)
target_include_directories(libdavs2_intrin_avx
    PUBLIC 
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}../../>
)
