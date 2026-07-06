ADD_ODB_INTERFACE(ODB_GENERATED ${CMAKE_CURRENT_SOURCE_DIR}/db.hpp ${CMAKE_CURRENT_BINARY_DIR})

include_directories(
	${CMAKE_CURRENT_BINARY_DIR}
)

file(GLOB odbtest_SRCS
	db.hpp
	main.cpp
)

# Filter out .ixx files from ODB_GENERATED because .ixx is treated as
# C++20 module interface by CMake/compilers, but ODB uses .ixx for
# inline header files that are #included from the .hxx header.
list(FILTER ODB_GENERATED EXCLUDE REGEX "\\.ixx$")

add_executable(odbtest ${odbtest_SRCS} ${ODB_GENERATED})
