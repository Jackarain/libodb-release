cmake_minimum_required(VERSION 3.10)

project(libsqlite3 C)

set(SQLITE3_SOURCES
    libsqlite3/sqlite3.c
)

add_library(libsqlite3 STATIC ${SQLITE3_SOURCES})

target_include_directories(libsqlite3 PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/libsqlite3
)

# Enable features required by ODB
target_compile_definitions(libsqlite3 PRIVATE
    SQLITE_ENABLE_COLUMN_METADATA
    SQLITE_ENABLE_UNLOCK_NOTIFY
    SQLITE_ENABLE_FTS4
    SQLITE_ENABLE_FTS5
    SQLITE_ENABLE_JSON1
)

set_target_properties(libsqlite3 PROPERTIES
    POSITION_INDEPENDENT_CODE ON
)
