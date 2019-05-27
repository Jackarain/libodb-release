ADD_ODB_INTERFACE(ODB_GENERATED ${CMAKE_CURRENT_SOURCE_DIR}/db.hpp ${CMAKE_CURRENT_BINARY_DIR})

include_directories(
	${CMAKE_CURRENT_BINARY_DIR}
)

file(GLOB odbtest_SRCS
	db.hpp
	main.cpp
)

add_executable(odbtest ${odbtest_SRCS} ${ODB_GENERATED})
