#command line tool
add_executable({{project_name}}-app main.cpp)

target_link_libraries({{project_name}}-app LINK_PUBLIC {{project_name}})
set_target_properties({{project_name}}-app PROPERTIES OUTPUT_NAME {{project_name}})
