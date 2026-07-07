cmake_minimum_required(VERSION 3.10)

set(LIBODB_SOURCES
	odb/exceptions.cxx
	odb/database.cxx
	odb/vector-impl.cxx
	odb/connection.cxx
	odb/prepared-query.cxx
	odb/query-dynamic.cxx
	odb/result.cxx
	odb/schema-catalog.cxx
	odb/section.cxx
	odb/session.cxx
	odb/statement.cxx
	odb/statement-processing.cxx
	odb/tracer.cxx
	odb/transaction.cxx
	odb/details/buffer.cxx
	odb/details/thread.cxx
	odb/details/shared-ptr/base.cxx
)

add_library(libodb STATIC ${LIBODB_SOURCES})

target_include_directories(libodb PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_compile_definitions(libodb PUBLIC -DLIBODB_STATIC_LIB -DLIBODB_BOOST_STATIC_LIB -DLIBODB_PGSQL_STATIC_LIB)
target_link_libraries(libodb Boost::date_time)
set_target_properties(libodb PROPERTIES FOLDER "third_party")
set_target_properties(libodb PROPERTIES OUTPUT_NAME odb PREFIX "lib" CLEAN_DIRECT_OUTPUT 1)
