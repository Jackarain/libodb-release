cmake_minimum_required(VERSION 3.10)

add_subdirectory(boost)
add_subdirectory(libsqlite3)
add_subdirectory(libodb)
# Windows 平台跳过 libodb-pgsql（需要 PostgreSQL）
if(NOT WIN32)
    add_subdirectory(libodb-pgsql)
endif()
add_subdirectory(libodb-sqlite)
add_subdirectory(libodb-boost)
