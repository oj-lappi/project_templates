cmake_minimum_required(VERSION 3.19)
project({{project_name}} VERSION 0.0.0)

set(CMAKE_CXX_STANDARD 20)

#[=[ Dependency target ]=]
add_library({{project_name}}_dependencies INTERFACE)

#[=[ dependencies ]=]

#[==[ MPI ]==]
target_compile_definitions({{project_name}}_dependencies INTERFACE OMPI_SKIP_MPICXX)
set(MPI_CXX_SKIP_MPICXX ON)
find_package(MPI REQUIRED COMPONENTS C)
target_link_libraries({{project_name}}_dependencies INTERFACE MPI::MPI_C)

#[==[ charon ]==]
find_package(charon REQUIRED 0.0.1)
target_link_libraries({{project_name}}_dependencies INTERFACE $<BUILD_INTERFACE:charon::charon>)

#[=[ dependencies end ]=]

add_executable({{project_name}} main.cpp)
target_link_libraries({{project_name}} PUBLIC {{project_name}}_dependencies)
target_include_directories({{project_name}} PUBLIC ../include)
target_compile_options({{project_name}} PRIVATE -Wall -Wextra -Wpedantic)
