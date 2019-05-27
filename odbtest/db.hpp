#pragma once

#include <vector>
#include <sstream>
#include <iostream>
#include <cstring> // std::memcpy

#include <odb/section.hxx>
#include <odb/nullable.hxx>

#include <boost/date_time/posix_time/ptime.hpp>

#ifdef _MSC_VER
#	pragma warning (push)
#	pragma warning (disable:4068)
#endif // _MSC_VER

#pragma db model version(1, 1, open)

#pragma db map type("numeric")			\
               as("TEXT")				\
               to("(?)::numeric")		\
               from("(?)::TEXT")

#pragma db map type("cidr")			\
               as("TEXT")			\
               to("(?)::cidr")		\
               from("(?)::TEXT")

#pragma db map type("INTEGER *\\[(\\d*)\\]") \
               as("TEXT")                    \
               to("(?)::INTEGER[$1]")        \
               from("(?)::TEXT")

#pragma db map type("NUMERIC *\\[(\\d*)\\]") \
               as("TEXT")                    \
               to("(?)::NUMERIC[$1]")        \
               from("(?)::TEXT")

#pragma db object
struct odbtest_config {
    #pragma db id
	std::string id_;

    std::string params;
};
