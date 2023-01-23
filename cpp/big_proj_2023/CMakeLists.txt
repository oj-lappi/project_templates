cmake_minimum_required( VERSION 3.19 )

project({{project_name}} VERSION 0.0.0)

#################
# Documentation #
#################

option(DOCUMENTATION_ONLY "Only build documentation" OFF)

find_package(Doxygen)
if (DOXYGEN_FOUND)
    #set(DOXYGEN_PROJECT_LOGO "${PROJECT_SOURCE_DIR}/doc/logo.png")
    set(DOXYGEN_GENERATE_LATEX YES)
    set(DOXYGEN_LATEX_CMD_NAME lualatex)
    doxygen_add_docs(doxygen
	${PROJECT_SOURCE_DIR}/doc/mainpage.dox
        ${PROJECT_SOURCE_DIR}/src
        ${PROJECT_SOURCE_DIR}/include
        ${PROJECT_SOURCE_DIR}/doc
        )
    #Generate pdf from latex
    add_custom_command(
        TARGET doxygen
        POST_BUILD
        COMMAND "make"
        WORKING_DIRECTORY ${PROJECT_BINARY_DIR}/latex
        )

    message("Doxygen target generated, run\n"
            "    make doxygen\n"
            "to build documentation.")
else()
    message(WARNING "Doxygen not found, can't build documentation")
endif()

if(DOCUMENTATION_ONLY)
    message("Option DOCUMENTATION_ONL =ON.\n"
            "Doxygen files generated, not generating C++ build files.\n"
            )
    return()
endif()

################
# Build proper #
################

#This option is necessary on LUMI and Mahti, because of differences in g++ vs. clang++
add_compile_options(-fpermissive)

set(CMAKE_CXX_STANDARD 20)

if(NOT CMAKE_BUILD_TYPE)
    set(
        CMAKE_BUILD_TYPE "Debug"
        CACHE STRING
        "Choose the type of build, options are: Debug Release RelWithDebInfo MinSizeRel."
        FORCE
        )
endif()

#################
# Build options #
#################

option(USE_OPENMP "Use OpenMP" ON)
option(USE_MPI "Use MPI" ON)

# Debugging

set(VERBOSITY 0 CACHE STRING "{{project_name}} verbosity. Higher values, more debug printing")
set_property(CACHE VERBOSITY PROPERTY STRINGS 0 1 2)
add_compile_definitions({{project_name}}_VERBOSITY=${VERBOSITY})

# Microbenchmarks

option(BUILD_BENCHMARKS "Build the microbenchmarks in \"benchmarks\"" OFF)

##################################################################
# Special build options for debugging and performance evaluation #
##################################################################

#Generic profiling/debugging

option(ENABLE_ADDRESS_SANITIZER "Turn on -fsanitize=address" OFF)
option(ENABLE_PERFORMANCE_TRACES "Set -fno-omit-frame-pointer for readable labels" OFF)

# Specific profilers
option(GPROF_PROFILING "Build with -pg for a general performance profile" OFF)
if(GPROF_PROFILING)
	add_compile_options(-g -pg)
	add_link_options(-pg)
endif()

option(MPIP_PROFILING "Link with mpiP for MPI profiling" OFF)
set(MPIP "" CACHE FILEPATH "Linker reference for libmpiP.so")

if(MPIP_PROFILING)
	#mpiP_DIR must be set, or -DMPIP=/path/to/libmpip.so
	message("mpiP: MPIP_PROFILING is ON")
	if(NOT MPIP)
		message("  MPIP not set, checking environment variable mpiP_DIR=$ENV{mpiP_DIR}")
		if (DEFINED ENV{mpiP_DIR})
			message("  Setting MPIP RPATH to " $ENV{mpiP_DIR}/libmpiP.so)
                        set(MPIP "$ENV{mpiP_DIR}/libmpiP.so" CACHE FILEPATH "Linker reference to libmpiP.so" FORCE)
		else()
			message(WARNING
				"  MPIP_PROFILING is turned ON, but MPIP is not defined, nor is ENV{mpiP_DIR}\n"
				"   => libmpiP.so must be on the linkers search path both now and at runtime\n"
				"   Use LD_LIBRARY_PATH or LD_PRELOAD if mpiP is in a non-standard location\n\n"
				"   Alternatively, you could set MPIP to point to the shared object,\n"
			        "   or set the environment variable mpiP_DIR to the directory containing it.")
                        set(MPIP "-lmpiP" CACHE FILEPATH "Linker reference to libmpiP.so" FORCE)
		endif()
	endif()
endif()

################################################
# Build optimization and static analysis stuff #
################################################

include(${CMAKE_SOURCE_DIR}/cmake/BuildOptimization.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/StaticAnalysis.cmake)

enable_testing()

####################
# Subdirectories   #
####################

add_subdirectory(src)
add_subdirectory(app)
add_subdirectory(test)

if(BUILD_MICROBENCHMARKS)
    add_subdirectory(benchmarks)
endif()
