ADD_ODB_INTERFACE(ODB_GENERATED ${CMAKE_CURRENT_SOURCE_DIR}/db.hpp ${CMAKE_CURRENT_BINARY_DIR} "" "sqlite")

include_directories(
	${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

file(GLOB sqlite_test_SRCS
	db.hpp
	main.cpp
	db_traits.hpp
	traits-sqlite.hpp
)

add_executable(sqlite_test ${sqlite_test_SRCS} ${ODB_GENERATED})

target_link_libraries(sqlite_test
	Boost::date_time
	Boost::multiprecision
	libodb
	libodb-sqlite
	libodb-boost
	libsqlite3
)
