cmake_minimum_required(VERSION 3.10)

#Do we need this?
project({{project_name}} Fortran)

enable_language(Fortran)
set(CMAKE_Fortran_COMPILER "gfortran")

find_package(OpenMP REQUIRED)


add_executable(${PROJECT_NAME} src/main.f95)
set_target_properties(${PROJECT_NAME} PROPERTIES
			COMPILE_FLAGS "${OpenMP_Fortran_FLAGS}"	LINK_FLAGS "${OpenMP_Fortran_FLAGS}")
