cmake_minimum_required(VERSION 3.10)

project(odbtest C CXX)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PROJECT_SOURCE_DIR}" "${PROJECT_SOURCE_DIR}/cmake")

# 查找 Boost（libodb 需要 Boost::date_time）
# find_package(Boost 1.71 REQUIRED COMPONENTS date_time)

# Windows 平台跳过 PostgreSQL 查找（pg_test 不参与编译）
if(NOT WIN32)
    find_package(PostgreSQL REQUIRED)
endif()
# 根据平台选择 ODB 编译器
if(WIN32)
    set(ODB_COMPILER ${CMAKE_CURRENT_SOURCE_DIR}/third_party/odb-2.5.0-x86_64-windows/bin/odb.exe)
else()
    set(ODB_COMPILER ${CMAKE_CURRENT_SOURCE_DIR}/third_party/odb-2.5.0-x86_64-linux-gnu/bin/odb)
endif()

# C++ 标准
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 全局编译选项
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Boost 配置
set(Boost_USE_STATIC_LIBS ON)
set(Boost_USE_STATIC_RUNTIME ON)

set(BOOST_IOSTREAMS_ENABLE_ZSTD OFF)
set(BOOST_IOSTREAMS_ENABLE_LZMA OFF)
set(BOOST_IOSTREAMS_ENABLE_BZIP2 OFF)
set(BOOST_IOSTREAMS_ENABLE_ZLIB OFF)

set(BOOST_ASIO_BUILD_CONTEXT OFF)
set(BOOST_EXCLUDE_LIBRARIES
    "charconv"               # 字符转换
    "cobalt"                 # 协程框架
    "context"                # 上下文切换
    "contract"               # 契约编程
    "coroutine"              # 协程库
    #"date_time"              # 日期时间
    "fiber"                  # 用户态线程
    #"filesystem"             # 文件系统
    "graph"                  # 图论算法
    "graph_parallel"         # 并行图算法
    "iostreams"              # 流式输入输出扩展
    #"json"                   # JSON 解析
    "locale"                 # 本地化与多语言支持
    "log"                    # 日志框架
    #"math"                   # 数学公式与特殊函数
    "mpi"                    # 消息传递接口(分布式计算)
    #"nowide"                 # Windows UTF-8 兼容库
    "process"                # 进程管理
    #"program_options"        # 命令行参数解析
    "python"                 # Python 绑定支持
    #"regex"                  # 正则表达式
    "serialization"          # 序列化库
    "stacktrace"             # 堆栈回溯
    "test"                   # 单元测试框架
    "type_erasure"           # 类型擦除
    #"url"                    # URL 解析库
    "wave"                   # C++ 预处理器解析器
)

# 构建第三方库
add_subdirectory(third_party)

# 设置 libsqlite3 的 FOLDER 属性
if(TARGET libsqlite3)
    set_property(TARGET libsqlite3 PROPERTY FOLDER "third_party")
endif()

# 设置 Boost 库相关配置
set(boost_libs
    boost_assert
    boost_beast
    boost_container
    boost_atomic
    boost_chrono
    boost_core
    boost_date_time
    boost_exception
    boost_filesystem
    boost_json
    boost_url
    boost_nowide
    boost_program_options
    boost_system
    boost_thread
    boost_variant2
    boost_unordered
    boost_optional
    boost_timer
    boost_random
    boost_openmethod
    boost_math
    boost_json_regenerate_printers
    boost_interprocess
    boost_bloom
)

# 设置 Boost 库的 FOLDER 属性
foreach(lib IN LISTS boost_libs)
    set_property(TARGET ${lib} PROPERTY FOLDER "third_party/boost")
endforeach()

# 收集所有 Boost 的 include 目录，主要用于 ODB 编译器命令中的 include 目录设置
set(BOOST_INCLUDE_DIRS "")

foreach(lib IN LISTS boost_libs)
    if(TARGET ${lib})
        # 获取 INTERFACE_LINK_LIBRARIES（依赖的其他 target）
        get_target_property(link_libs ${lib} INTERFACE_LINK_LIBRARIES)

        # 获取自身的 include 目录
        get_target_property(inc_dirs ${lib} INTERFACE_INCLUDE_DIRECTORIES)

        if(inc_dirs)
            if(inc_dirs MATCHES [[^\$<BUILD_INTERFACE:(.+)?>;.*$]])
                set(match "${CMAKE_MATCH_1}")
                if(match)
                    list(APPEND BOOST_INCLUDE_DIRS "-I ${match}")
                endif()
            endif()
        endif()

        # 如果有依赖，也尝试收集依赖的 include 目录
        if(link_libs AND NOT link_libs STREQUAL "link_libs-NOTFOUND")
            foreach(dep IN LISTS link_libs)
                if(TARGET ${dep})
                    get_target_property(dep_inc ${dep} INTERFACE_INCLUDE_DIRECTORIES)
                    if(dep_inc)
                        if(dep_inc MATCHES [[^\$<BUILD_INTERFACE:(.+)?>;.*$]])
                            set(match "${CMAKE_MATCH_1}")
                            if(match)
                                list(APPEND BOOST_INCLUDE_DIRS "-I ${match}")
                            endif()
                        endif()
                    endif()
                endif()
            endforeach()
        endif()
    endif()
endforeach()

# 去重并排序
list(SORT BOOST_INCLUDE_DIRS)
list(REMOVE_DUPLICATES BOOST_INCLUDE_DIRS)

#message(STATUS "=== Boost unique include directories ===")
#foreach(dir IN LISTS BOOST_INCLUDE_DIRS)
#    message(STATUS "  ${dir}")
#endforeach()

set(ODB_PGSQL_LIB_DIR  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/libodb-pgsql)
set(ODB_SQLITE_LIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third_party/libodb-sqlite)
set(ODB_BOOST_LIB_DIR  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/libodb-boost)

set(ODB_LIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third_party/libodb)

include(cmake/odb.cmake)

# 构建主程序
add_subdirectory(main)
