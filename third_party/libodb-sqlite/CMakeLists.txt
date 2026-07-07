cmake_minimum_required(VERSION 3.10)

project(libodb-sqlite CXX)

set(LIBODB_SQLITE_SOURCES
    odb/sqlite/connection.cxx
    odb/sqlite/connection-factory.cxx
    odb/sqlite/database.cxx
    odb/sqlite/error.cxx
    odb/sqlite/exceptions.cxx
    odb/sqlite/prepared-query.cxx
    odb/sqlite/query.cxx
    odb/sqlite/query-const-expr.cxx
    odb/sqlite/query-dynamic.cxx
    odb/sqlite/simple-object-statements.cxx
    odb/sqlite/statement.cxx
    odb/sqlite/statements-base.cxx
    odb/sqlite/stream.cxx
    odb/sqlite/tracer.cxx
    odb/sqlite/traits.cxx
    odb/sqlite/transaction.cxx
    odb/sqlite/transaction-impl.cxx
    # Use pregenerated options (from consumption build mode)
    odb/sqlite/details/pregenerated/odb/sqlite/details/options.cxx
)

add_library(libodb-sqlite STATIC ${LIBODB_SQLITE_SOURCES})

target_include_directories(libodb-sqlite PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# The pregenerated headers should come first so they shadow the non-existent
# generated ones (this matches the consumption build mode).
target_include_directories(libodb-sqlite PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/odb/sqlite/details/pregenerated
)

target_compile_definitions(libodb-sqlite PUBLIC
    -DLIBODB_SQLITE_STATIC_BUILD
    -DLIBODB_SQLITE_STATIC
)

target_link_libraries(libodb-sqlite PUBLIC
    libodb
    libsqlite3
)

set_target_properties(libodb-sqlite PROPERTIES
    POSITION_INDEPENDENT_CODE ON
)
set_target_properties(libodb-sqlite PROPERTIES FOLDER "third_party")
set_target_properties(libodb-sqlite PROPERTIES OUTPUT_NAME odb-sqlite PREFIX "lib" CLEAN_DIRECT_OUTPUT 1)
