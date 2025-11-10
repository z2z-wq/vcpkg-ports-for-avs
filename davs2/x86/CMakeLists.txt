
cmake_minimum_required(VERSION 3.16)
project(libdavs2_asm LANGUAGES ASM_NASM)

# 启用汇编语言
enable_language(ASM_NASM)

# 配置 NASM
find_program(NASM_EXECUTABLE nasm REQUIRED)

if(WIN32)
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(NASM_FORMAT win64)
        set(NASM_DEFINES -DWIN64 -DARCH_X86_64=1 -DBIT_DEPTH=10 -DHIGH_BIT_DEPTH=0 -DSTACK_ALIGNMENT=32)
    else()
        set(NASM_FORMAT win32)
        set(NASM_DEFINES -DWIN32 -DARCH_X86_64=0 -DBIT_DEPTH=10 -DHIGH_BIT_DEPTH=0 -DSTACK_ALIGNMENT=32)
    endif()
    if(CMAKE_AR MATCHES "lib\\.exe")
        set(CMAKE_ASM_NASM_CREATE_STATIC_LIBRARY
            "<CMAKE_AR> /OUT:<TARGET> <LINK_FLAGS> <OBJECTS>"
        )
    endif()
elseif(APPLE)
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(NASM_FORMAT macho64)
        set(NASM_DEFINES -DMACOS -DMACHO64)
    else()
        set(NASM_FORMAT macho32)
        set(NASM_DEFINES -DMACOS -DMACHO32)
    endif()
else()  # Linux
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(NASM_FORMAT elf64)
        set(NASM_DEFINES -DLINUX -DELF64)
    else()
        set(NASM_FORMAT elf32)
        set(NASM_DEFINES -DLINUX -DELF32)
    endif()
endif()



set(ASM_SOURCES
    blockcopy8.asm
    const-a.asm
    cpu-a.asm
    dct8.asm
    mc-a2.asm
    pixeladd8.asm
    quant8.asm
    # x86inc.asm
    # x86util.asm
)


if(NOT WIN32)
    list(APPEND ASM_SOURCES ipfilter8.asm)
endif()

add_library(libdavs2_asm STATIC ${ASM_SOURCES})



target_compile_definitions(libdavs2_asm PRIVATE 
    ARCH_X86_64=1
    BIT_DEPTH=8
    HIGH_BIT_DEPTH=0
)

set_target_properties(libdavs2_asm PROPERTIES
    ASM_NASM_OBJECT_FORMAT ${NASM_FORMAT}
)

foreach(ASM_FILE ${ASM_SOURCES})
    set_source_files_properties(${ASM_FILE}
        PROPERTIES
        COMPILE_OPTIONS "-Xvc;-f;${NASM_FORMAT};${NASM_DEFINES}"
    )
endforeach()

target_include_directories(libdavs2_asm
    PUBLIC 
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../vec>
)

