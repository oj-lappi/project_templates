cmake_minimum_required(VERSION 3.10)

#Do we need this?
project({{project_name}} Fortran)

enable_language(Fortran)
set(CMAKE_Fortran_COMPILER "gfortran")


add_executable(${PROJECT_NAME} src/main.f90)
