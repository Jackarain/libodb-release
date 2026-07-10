# Windows 平台跳过 pg_test（需要 PostgreSQL 客户端库）
if(NOT WIN32)
    add_subdirectory(pg_test)
endif()
add_subdirectory(sqlite_test)
