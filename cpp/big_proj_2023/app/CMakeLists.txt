#Dependencies
find_package(fmt REQUIRED CONFIG)
if (USE_MPI)
    find_package(MPI REQUIRED COMPONENTS C)
endif()


#{{project_name}} command line tool
add_executable(
    {{project_name}}-bin
    main.cpp
    )
target_link_libraries({{project_name}}-bin LINK_PUBLIC {{project_name}})
target_link_libraries({{project_name}}-bin PRIVATE fmt::fmt-header-only)

if (USE_MPI)
    target_link_libraries({{project_name}}-bin LINK_PUBLIC {{project_name}} MPI::MPI_C)
endif()

set_target_properties({{project_name}}-bin PROPERTIES OUTPUT_NAME {{project_name}})
target_compile_options({{project_name}}-bin PRIVATE -Wall $<$<CONFIG:Debug>:-g>)
