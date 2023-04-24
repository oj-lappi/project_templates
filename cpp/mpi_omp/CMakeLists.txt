cmake_minimum_required( VERSION 3.10.1 )
include(${CMAKE_SOURCE_DIR}/cmake/DefaultCompilers.cmake)
project({{project_name}})

set(CMAKE_CXX_STANDARD 20)

if(NOT CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE "Debug")
endif()

include(${CMAKE_SOURCE_DIR}/cmake/BuildOptimization.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/StaticAnalysis.cmake)

enable_testing()

add_subdirectory(src)
add_subdirectory(app)
