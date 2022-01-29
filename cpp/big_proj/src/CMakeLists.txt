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

#TODO: add generator expressions to separate BUILD and INSTALL concerns

add_subdirectory(utils)
add_subdirectory(test)
