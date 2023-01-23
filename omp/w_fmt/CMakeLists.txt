cmake_minimum_required(VERSION 3.18)
project({{project_name}} CXX)
add_compile_options(-Wall -Wextra -Wpedantic)

find_package(fmt REQUIRED CONFIG)
find_package(OpenMP REQUIRED)
include_directories(include)

add_executable(${PROJECT_NAME} src/main.cpp)

target_link_libraries(${PROJECT_NAME} fmt::fmt)
target_link_libraries(${PROJECT_NAME} OpenMP::OpenMP_CXX)
