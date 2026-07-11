function(ADD_ODB_INTERFACE ODB_HEADERS)

if (NOT ARGN)
	message(SEND_ERROR "no header file")
endif()

get_filename_component(ODB_HEADER_BASE ${ARGV1} NAME_WE)

set(ODB_HEADER ${ARGV1})
set(OUT_DIR ${ARGV2})
set(EXTRA_ARGS ${ARG3})
set(ODB_DB_TYPE ${ARGV4})
if (NOT ODB_DB_TYPE)
	set(ODB_DB_TYPE "pgsql")
endif()

# Database-specific options.
if (ODB_DB_TYPE STREQUAL "pgsql")
	set(ODB_DB_OPTIONS "--pgsql-server-version" "9.6")
	set(ODB_INC_DIRS
		-I ${ODB_LIB_DIR}
		-I ${ODB_PGSQL_LIB_DIR}
		-I ${ODB_BOOST_LIB_DIR})
elseif (ODB_DB_TYPE STREQUAL "sqlite")
	set(ODB_DB_OPTIONS "")
	set(ODB_INC_DIRS
		-I ${ODB_LIB_DIR}
		-I ${ODB_SQLITE_LIB_DIR}
		-I ${ODB_BOOST_LIB_DIR})
else()
	message(SEND_ERROR "unsupported database type: ${ODB_DB_TYPE}")
endif()

foreach(dir IN LISTS BOOST_INCLUDE_DIRS)
    list(APPEND ODB_INC_DIRS "-I${dir}")
endforeach()

add_custom_command(OUTPUT ${OUT_DIR}/${ODB_HEADER_BASE}.sql
					COMMAND ${ODB_COMPILER} ARGS
					${EXTRA_ARGS}
					-d ${ODB_DB_TYPE} --std c++11 -p boost --generate-schema-only --schema-format sql ${ODB_DB_OPTIONS} --hxx-prologue "#include \"db_traits.hpp\""
					${ODB_HEADER}
					${ODB_INC_DIRS}
					MAIN_DEPENDENCY ${ODB_HEADER}
					DEPENDS ${ODB_HEADER}
					WORKING_DIRECTORY ${OUT_DIR}
					COMMENT "generating SQL definations for ${ODB_HEADER_BASE}"
					VERBATIM)

add_custom_command(OUTPUT
					${OUT_DIR}/${ODB_HEADER_BASE}-odb.cxx
					${OUT_DIR}/${ODB_HEADER_BASE}-odb.hxx
					${OUT_DIR}/${ODB_HEADER_BASE}-odb.ixx
					COMMAND ${ODB_COMPILER} ARGS ${EXTRA_ARGS}
					-d ${ODB_DB_TYPE} --std c++11 -p boost --generate-query --generate-schema --schema-format embedded ${ODB_DB_OPTIONS} --hxx-prologue "#include \"db_traits.hpp\""
					${ODB_HEADER}
					${ODB_INC_DIRS}
					MAIN_DEPENDENCY ${ODB_HEADER}
					DEPENDS ${ODB_HEADER}
					WORKING_DIRECTORY ${OUT_DIR}
					COMMENT "generating ODB bindings for ${ODB_HEADER_BASE}"
					VERBATIM)

set(${ODB_HEADERS}
	${OUT_DIR}/${ODB_HEADER_BASE}-odb.cxx
	${OUT_DIR}/${ODB_HEADER_BASE}-odb.hxx
	#${OUT_DIR}/${ODB_HEADER_BASE}-odb.ixx # 不向外暴露该 .ixx 文件，原因是 msvc 会将 .ixx 当成模块文件处理而导致出错.
	PARENT_SCOPE
)

endfunction(ADD_ODB_INTERFACE)
