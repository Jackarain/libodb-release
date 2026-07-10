cmake_minimum_required(VERSION 3.10)

list(APPEND LIBODB_SOURCES
	odb/boost/date-time/exceptions.cxx
)

add_library(libodb-boost STATIC ${LIBODB_SOURCES})

target_include_directories(libodb-boost PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
# Windows 平台不定义 LIBODB_PGSQL_STATIC_LIB（未编译 libodb-pgsql）
if(WIN32)
    target_compile_definitions(libodb-boost PUBLIC -DLIBODB_STATIC_LIB -DLIBODB_BOOST_STATIC_LIB)
else()
    target_compile_definitions(libodb-boost PUBLIC -DLIBODB_STATIC_LIB -DLIBODB_BOOST_STATIC_LIB -DLIBODB_PGSQL_STATIC_LIB)
endif()
target_link_libraries(libodb-boost PUBLIC libodb Boost::date_time)
set_target_properties(libodb-boost PROPERTIES FOLDER "third_party")
set_target_properties(libodb-boost PROPERTIES OUTPUT_NAME odb-boost PREFIX "lib" CLEAN_DIRECT_OUTPUT 1)
