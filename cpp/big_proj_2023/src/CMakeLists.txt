#The {{project_name}}
#####################

add_library({{project_name}})

target_compile_options({{project_name}}
	PUBLIC
		$<$<CXX_COMPILER_ID:GNU>:-fconcepts>
		-frecord-gcc-switches
	PRIVATE
		-Wall
		$<$<CONFIG:Debug>:-gdwarf-4>
	)


target_include_directories({{project_name}}
    PUBLIC
      ../include
    PRIVATE
     ${CMAKE_CURRENT_LIST_DIR}
     ../3rd_party
)

##################################################################
# Special build options for debugging and performance evaluation #
##################################################################

if (ENABLE_ADDRESS_SANITIZER)
	target_compile_options({{project_name}}
		INTERFACE
			$<$<CXX_COMPILER_ID:GNU>:-fsanitize=address>
			$<$<CXX_COMPILER_ID:Clang>:-fsanitize=address>
	)

	target_link_options({{project_name}}
		INTERFACE
			$<$<CXX_COMPILER_ID:GNU>:-fsanitize=address>
			$<$<CXX_COMPILER_ID:Clang>:-fsanitize=address>
	)
endif()

if (ENABLE_PERFORMANCE_TRACES)
	target_compile_options({{project_name}}
		INTERFACE
                    -fno-omit-frame-pointer
	)
endif()

##################
#  Dependencies  #
##################

find_package(Boost REQUIRED)
target_link_libraries({{project_name}} PRIVATE Boost::boost)

find_package(fmt REQUIRED CONFIG)
target_link_libraries({{project_name}} PRIVATE fmt::fmt-header-only)

find_package(Threads REQUIRED)
target_link_libraries({{project_name}} PRIVATE Threads::Threads)

if (USE_OPENMP)
    target_compile_definitions({{project_name}} PUBLIC USE_OPENMP)
    find_package(OpenMP REQUIRED)
    target_link_libraries({{project_name}} PRIVATE OpenMP::OpenMP_CXX)
endif()

if (USE_MPI)
    target_compile_definitions({{project_name}} PUBLIC USE_MPI OMPI_SKIP_MPICXX)
    set(MPI_CXX_SKIP_MPICXX ON)
    find_package(MPI REQUIRED COMPONENTS C)
    target_link_libraries({{project_name}} PUBLIC MPI::MPI_C)
endif()
#TODO: add generator expressions to separate BUILD and INSTALL concerns

#################
#  Source dirs  #
#################

add_subdirectory(internal)
add_subdirectory(misc)

add_subdirectory(test)

####################################
# Add version information to {{project_name}} #
####################################

target_compile_definitions({{project_name}}
        PUBLIC
	    {{project_name}}_MAJOR_VERSION=${CMAKE_PROJECT_VERSION_MAJOR}
	    {{project_name}}_MINOR_VERSION=${CMAKE_PROJECT_VERSION_MINOR}
	    {{project_name}}_PATCH_VERSION=${CMAKE_PROJECT_VERSION_PATCH}
        )
message("Version set to ${CMAKE_PROJECT_VERSION}")
