cmake_minimum_required(VERSION 3.3)

set(LIBODB_PGSQL_SOURCES
	auto-handle.cxx
	connection.cxx
	connection-factory.cxx
	database.cxx
	error.cxx
	exceptions.cxx
	prepared-query.cxx
	query.cxx
	query-dynamic.cxx
	query-const-expr.cxx
	simple-object-statements.cxx
	statement.cxx
	statements-base.cxx
	tracer.cxx
	traits.cxx
	transaction.cxx
	transaction-impl.cxx
	details/endian-traits.cxx
	details/options.cxx
)

add_library(libodb-pgsql STATIC ${LIBODB_PGSQL_SOURCES})
target_include_directories(libodb-pgsql PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../..)
target_link_libraries(libodb-pgsql libodb)
set_target_properties(libodb-pgsql PROPERTIES FOLDER "third_party")
