cmake_minimum_required(VERSION 3.10)

project(libodb-pgsql CXX)

set(LIBODB_PGSQL_SOURCES
    odb/pgsql/auto-handle.cxx
    odb/pgsql/connection.cxx
    odb/pgsql/connection-factory.cxx
    odb/pgsql/database.cxx
    odb/pgsql/error.cxx
    odb/pgsql/exceptions.cxx
    odb/pgsql/prepared-query.cxx
    odb/pgsql/query.cxx
    odb/pgsql/query-const-expr.cxx
    odb/pgsql/query-dynamic.cxx
    odb/pgsql/simple-object-statements.cxx
    odb/pgsql/statement.cxx
    odb/pgsql/statements-base.cxx
    odb/pgsql/tracer.cxx
    odb/pgsql/traits.cxx
    odb/pgsql/transaction.cxx
    odb/pgsql/transaction-impl.cxx
    # Use pregenerated options (from consumption build mode)
    odb/pgsql/details/pregenerated/odb/pgsql/details/options.cxx
)

add_library(libodb-pgsql STATIC ${LIBODB_PGSQL_SOURCES})

target_include_directories(libodb-pgsql PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# The pregenerated headers should come first so they shadow the non-existent
# generated ones (this matches the consumption build mode).
target_include_directories(libodb-pgsql PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/odb/pgsql/details/pregenerated
)

target_compile_definitions(libodb-pgsql PUBLIC
    -DLIBODB_PGSQL_STATIC_BUILD
    -DLIBODB_PGSQL_STATIC
)

target_link_libraries(libodb-pgsql PUBLIC
    libodb
    PostgreSQL::PostgreSQL
)

set_target_properties(libodb-pgsql PROPERTIES
    POSITION_INDEPENDENT_CODE ON
)
set_target_properties(libodb-pgsql PROPERTIES FOLDER "third_party")
set_target_properties(libodb-pgsql PROPERTIES OUTPUT_NAME odb-pgsql PREFIX "lib" CLEAN_DIRECT_OUTPUT 1)
