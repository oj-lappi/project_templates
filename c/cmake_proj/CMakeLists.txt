cmake_minimum_required(VERSION 3.18)
project({{project_name}} C)


add_compile_options(-Wall -Wextra -Wpedantic)

include_directories(include)

add_executable(${PROJECT_NAME} src/main.c)
