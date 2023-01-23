add_executable(serialization_ubench main.cpp)
target_link_libraries(serialization_ubench
    PRIVATE
    {{project_name}}
        benchmark::benchmark
)
target_include_directories(serialization_ubench PRIVATE ../../3rd_party)
