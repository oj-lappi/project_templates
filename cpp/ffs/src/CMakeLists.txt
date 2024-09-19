cmake_minimum_required(VERSION 3.19)
project({{project_name}} CXX)

add_executable({{project_name}} src/main.cpp)
target_include_directories({{project_name}} PUBLIC ../include)
target_compile_options({{project_name}} PRIVATE -Wall -Wextra -Wpedantic)
