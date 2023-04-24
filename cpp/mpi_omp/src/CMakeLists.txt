#The {{project_name}} library
add_library({{project_name}})

target_compile_options({{project_name}}
	PUBLIC
		$<$<CXX_COMPILER_ID:GNU>:-fconcepts>
	PRIVATE
		-Wall
		#$<$<CONFIG:Debug>:-g>
		-g
	)


target_include_directories({{project_name}}
    PUBLIC
     ${CMAKE_CURRENT_LIST_DIR}/../include
    PRIVATE
     ${CMAKE_CURRENT_LIST_DIR}
     ${CMAKE_CURRENT_LIST_DIR}/../3rd_party
)

# Enable sanitizers

option(ENABLE_ADDRESS_SANITIZER "Turn on -fsanitize=address" OFF)
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

find_package(fmt REQUIRED CONFIG)
target_link_libraries({{project_name}} PRIVATE fmt::fmt)


set(MPI_CXX_SKIP_MPICXX ON)
find_package(MPI REQUIRED COMPONENTS C)
target_compile_definitions({{project_name}} PUBLIC OMPI_SKIP_MPICXX)
target_link_libraries({{project_name}} PRIVATE MPI::MPI_C)


find_package(OpenMP REQUIRED)
target_link_libraries({{project_name}} PRIVATE OpenMP::OpenMP_CXX)

target_sources({{project_name}} PRIVATE
	{{project_name}}.cpp
)
