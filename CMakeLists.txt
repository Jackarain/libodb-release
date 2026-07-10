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

set(BOOST_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/third_party/boost)

set(ODB_PGSQL_LIB_DIR  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/libodb-pgsql)
set(ODB_SQLITE_LIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third_party/libodb-sqlite)
set(ODB_BOOST_LIB_DIR  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/libodb-boost)
set(ODB_LIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third_party/libodb)

include(cmake/odb.cmake)

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
	"math"                   # 数学公式与特殊函数
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

set_property(TARGET boost_assert PROPERTY FOLDER "third_party/boost")
set_property(TARGET boost_container PROPERTY FOLDER "third_party/boost")
set_property(TARGET boost_atomic PROPERTY FOLDER "third_party/boost")
set_property(TARGET boost_chrono PROPERTY FOLDER "third_party/boost")
set_property(TARGET boost_core PROPERTY FOLDER "third_party/boost")
set_property(TARGET boost_date_time PROPERTY FOLDER "third_party/boost")
set_property(TARGET boost_exception PROPERTY FOLDER "third_party/boost")
set_property(TARGET boost_filesystem PROPERTY FOLDER "third_party/boost")
set_property(TARGET boost_json PROPERTY FOLDER "third_party/boost")
set_property(TARGET boost_url PROPERTY FOLDER "third_party/boost")
set_property(TARGET boost_nowide PROPERTY FOLDER "third_party/boost")
set_property(TARGET boost_program_options PROPERTY FOLDER "third_party/boost")
set_property(TARGET boost_system PROPERTY FOLDER "third_party/boost")
set_property(TARGET boost_thread PROPERTY FOLDER "third_party/boost")
set_property(TARGET boost_variant2 PROPERTY FOLDER "third_party/boost")
set_property(TARGET boost_unordered PROPERTY FOLDER "third_party/boost")
set_property(TARGET boost_optional PROPERTY FOLDER "third_party/boost")

# 构建主程序
add_subdirectory(main)
