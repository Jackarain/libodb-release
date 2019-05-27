function(ADD_ODB_INTERFACE ODB_HEADERS)

if (NOT ARGN)
	message(SEND_ERROR "no header file")
endif()

get_filename_component(ODB_HEADER_BASE ${ARGV1} NAME_WE)

set(ODB_HEADER ${ARGV1})
set(OUT_DIR ${ARGV2})
set(EXTRA_ARGS ${ARG3})
#message(STATUS "ddd" ${ARGV1})

add_custom_command(OUTPUT ${OUT_DIR}/${ODB_HEADER_BASE}.sql
                   COMMAND ${ODB_COMPILER} ARGS
                              ${EXTRA_ARGS}
                              -d pgsql --std c++11 -p boost --generate-schema --generate-query --generate-schema-only --pgsql-server-version 9.6
#							  --hxx-prologue "#include \"db_traits.hpp\""
                              ${ODB_HEADER}
#                             -I ${ODB_EXTRA_INCLUDE_DIR}
                              -I ${ODB_LIB_DIR}
                              -I ${ODB_PGSQL_LIB_DIR}
                              -I ${ODB_BOOST_LIB_DIR}
                              -I ${BOOST_INCLUDE_DIRS}
                   MAIN_DEPENDENCY ${ODB_HEADER}
                   DEPENDS ${ODB_HEADER}
                   WORKING_DIRECTORY ${OUT_DIR}
                   COMMENT "generating SQL definations for ${ODB_HEADER_BASE}"
                   BYPRODUCTS  ${CMAKE_CURRENT_BINARY_DIR}/${ODB_HEADER_BASE}.sql
                   VERBATIM)

add_custom_command(OUTPUT
                          ${OUT_DIR}/${ODB_HEADER_BASE}-odb.cxx
                          ${OUT_DIR}/${ODB_HEADER_BASE}-odb.hxx
                          ${OUT_DIR}/${ODB_HEADER_BASE}-odb.ixx
                   COMMAND ${ODB_COMPILER} ARGS ${EXTRA_ARGS}
                              -d pgsql --std c++11 -p boost --generate-query --generate-schema --schema-format embedded --pgsql-server-version 9.6
#							  --hxx-prologue "#include \"db_traits.hpp\""
                              ${ODB_HEADER}
#                             -I ${ODB_EXTRA_INCLUDE_DIR}
                              -I ${ODB_LIB_DIR}
                              -I ${ODB_PGSQL_LIB_DIR}
                              -I ${ODB_BOOST_LIB_DIR}
                              -I ${BOOST_INCLUDE_DIRS}
                   MAIN_DEPENDENCY ${ODB_HEADER}
                   DEPENDS ${ODB_HEADER}
                   WORKING_DIRECTORY ${OUT_DIR}
                   COMMENT "generating ODB bindings for ${ODB_HEADER_BASE}"
                   BYPRODUCTS
                         ${CMAKE_CURRENT_BINARY_DIR}/${ODB_HEADER_BASE}-odb.cxx
                         ${CMAKE_CURRENT_BINARY_DIR}/${ODB_HEADER_BASE}-odb.hxx
                         ${CMAKE_CURRENT_BINARY_DIR}/${ODB_HEADER_BASE}-odb.ixx
                   VERBATIM)

set(${ODB_HEADERS})

set(${ODB_HEADERS}
	${OUT_DIR}/${ODB_HEADER_BASE}-odb.cxx
	${OUT_DIR}/${ODB_HEADER_BASE}-odb.hxx
	${OUT_DIR}/${ODB_HEADER_BASE}-odb.ixx PARENT_SCOPE)

endfunction(ADD_ODB_INTERFACE)

