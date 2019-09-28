cmake_minimum_required(VERSION 3.1)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
project(odbtest)

include(CheckCXXCompilerFlag)
include(CheckLibraryExists)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${PROJECT_SOURCE_DIR}" "${PROJECT_SOURCE_DIR}/cmake")

if (MSVC)
	set(CompilerFlags
			CMAKE_CXX_FLAGS_DEBUG
			CMAKE_CXX_FLAGS_RELEASE
			CMAKE_CXX_FLAGS_MINSIZEREL
			CMAKE_CXX_FLAGS_RELWITHDEBINFO
			CMAKE_C_FLAGS_DEBUG
			CMAKE_C_FLAGS_RELEASE
			CMAKE_C_FLAGS_MINSIZEREL
			CMAKE_C_FLAGS_RELWITHDEBINFO
		)

	foreach(CompilerFlag ${CompilerFlags})
		string(REPLACE "/MD" "/MT" ${CompilerFlag} "${${CompilerFlag}}")
	endforeach()

	add_definitions(-D_CRT_SECURE_NO_WARNINGS)
	add_definitions(-D_SCL_SECURE_NO_WARNINGS)
	add_definitions(-D_WIN32_WINNT=0x0601)
	add_definitions(-DBOOST_ALL_STATIC_LINK)
	add_definitions(-DBOOST_THREAD_USE_LIB)
	add_definitions(-DBOOST_FILESYSTEM_STATIC_LINK)
	add_definitions(-DBOOST_USE_WINAPI_VERSION=0x0601)
	add_definitions(-DWIN32_LEAN_AND_MEAN)
	add_definitions(-DNOMINMAX)
	add_definitions(-D_SILENCE_ALL_CXX17_DEPRECATION_WARNINGS)

	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP /bigobj")
	set(CMAKE_CXX_STACK_SIZE "20000000")

	if (MSVC_VERSION GREATER_EQUAL "1900")
		CHECK_CXX_COMPILER_FLAG("/std:c++latest" HAS_CPP_LATEST_FLAG)
		if (HAS_CPP_LATEST_FLAG)
			add_compile_options("/std:c++latest")
		endif()
	endif()
endif()

CHECK_CXX_COMPILER_FLAG(-fvisibility-inlines-hidden COMPILER_HAS_VISIBILITY_INLINE_HIDDEN)
CHECK_CXX_COMPILER_FLAG(-fvisibility=hidden COMPILER_HAS_VISIBILITY_HIDDEN)
CHECK_CXX_COMPILER_FLAG(-std=c++14 LIBCXX_HAS_STDCXX14_FLAG)
CHECK_CXX_COMPILER_FLAG(-std=c++17 LIBCXX_HAS_STDCXX17_FLAG)
CHECK_CXX_COMPILER_FLAG(-std=c++20 LIBCXX_HAS_STDCXX20_FLAG)
CHECK_CXX_COMPILER_FLAG(-fdiagnostics-color=always COMPILER_HAS_COLOR)

if (${COMPILER_HAS_VISIBILITY_INLINE_HIDDEN})
	SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility-inlines-hidden")
endif()

if (${COMPILER_HAS_VISIBILITY_HIDDEN})
	SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=hidden")
endif()

if (${COMPILER_HAS_COLOR})
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fdiagnostics-color=always")
endif()

if (NOT MSVC)
	if(NOT APPLE)
		set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static-libstdc++ -static-libgcc")
	endif()
	if (ANDROID)
		set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fPIE -pie")
	endif()
	if(LIBCXX_HAS_STDCXX20_FLAG)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++20 -O3")
		add_definitions(-DUSE_STD_STRING_VIEW)
	elseif(LIBCXX_HAS_STDCXX17_FLAG)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -O3")
		add_definitions(-DUSE_STD_STRING_VIEW)
	elseif(LIBCXX_HAS_STDCXX14_FLAG)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14 -O3")
	else()
		message(FATAL_ERROR "need at least GCC 5 or clang 5")
	endif()
endif(NOT MSVC)

if (WIN32)
	add_subdirectory(third_party/libpq)
	set(PostgreSQL_LIBRARY libpq)
	set(POSTGRESQL_LIBRARY libpq)
	set(PostgreSQL_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third_party/libpq/include)
	set(POSTGRESQL_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third_party/libpq/include)
	include_directories(${PostgreSQL_INCLUDE_DIR})

else()
	find_package(PostgreSQL REQUIRED)
endif()

if(WIN32)
	set(ODB_COMPILER ${CMAKE_CURRENT_SOURCE_DIR}/third_party/odb-2.5.0-x86_64-windows/bin/odb.exe)
	include_directories(${CMAKE_CURRENT_SOURCE_DIR}/third_party/odb-2.5.0-x86_64-windows/include)
else()
	set(ODB_COMPILER ${CMAKE_CURRENT_SOURCE_DIR}/third_party/odb-2.5.0-x86_64-linux-gnu/bin/odb)
	include_directories(${CMAKE_CURRENT_SOURCE_DIR}/third_party/odb-2.5.0-x86_64-linux-gnu/include)
endif()

set(ODB_PGSQL_LIB_DIR  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/libodb-pgsql)
set(ODB_BOOST_LIB_DIR  ${CMAKE_CURRENT_SOURCE_DIR}/third_party/libodb-boost)
set(ODB_LIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third_party/libodb)
include(cmake/odb.cmake)

add_subdirectory(third_party/libodb)
add_subdirectory(third_party/libodb-pgsql)
add_subdirectory(third_party/libodb-boost)

set(Boost_USE_STATIC_LIBS	ON)
set(Boost_USE_STATIC_RUNTIME	ON)

find_package(Threads)
link_libraries(${CMAKE_THREAD_LIBS_INIT})

set(BOOST_INCLUDE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/third_party/boost)

add_definitions(-DBOOST_LOCALE_HIDE_AUTO_PTR)
add_definitions(-DBOOST_COROUTINES_NO_DEPRECATION_WARNING)
add_subdirectory(third_party/boost)

add_subdirectory(third_party/soci)
set(SOCI_INCLUDE_DIRS
       ${CMAKE_CURRENT_SOURCE_DIR}/third_party/soci/src/
       ${CMAKE_CURRENT_SOURCE_DIR}/third_party/soci/src/core/
       ${CMAKE_CURRENT_SOURCE_DIR}/third_party/soci/include/private
       ${CMAKE_CURRENT_SOURCE_DIR}/third_party/soci/include/
       ${CMAKE_BINARY_DIR}/third_party/soci/include/
)

set(SOCI_LIBRARY soci_core_static soci_postgresql_static)

include_directories(${SOCI_INCLUDE_DIRS})

link_libraries(
		Boost::date_time
		libodb
		libodb-pgsql
		libodb-boost
		${PostgreSQL_LIBRARY}
		${SOCI_LIBRARY}
)

if (WIN32)
	link_libraries(
		Secur32.lib
	)
endif()

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

if (WIN32)
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/bin/debug)
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/bin/release)
endif()

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/odbtest)
add_subdirectory(odbtest)
