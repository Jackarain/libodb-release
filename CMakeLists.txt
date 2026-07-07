cmake_minimum_required(VERSION 3.10)

project(odbtest C CXX)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PROJECT_SOURCE_DIR}" "${PROJECT_SOURCE_DIR}/cmake")

# 查找 Boost（libodb 需要 Boost::date_time）
# find_package(Boost 1.71 REQUIRED COMPONENTS date_time)

find_package(PostgreSQL REQUIRED)

set(ODB_COMPILER ${CMAKE_CURRENT_SOURCE_DIR}/third_party/odb-2.5.0-x86_64-linux-gnu/bin/odb)

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

# 构建第三方库
add_subdirectory(third_party)

# 构建主程序
add_subdirectory(main)
