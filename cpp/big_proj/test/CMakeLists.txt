include(${CMAKE_SOURCE_DIR}/cmake/Testing.cmake)
find_catch2_and_define_test_target()

add_library(TestExternal INTERFACE)
target_link_libraries(TestExternal INTERFACE TestTarget)

target_include_directories(TestExternal INTERFACE ../3rd_party)
target_include_directories(TestExternal INTERFACE ../include)

include(Catch)
include(CTest)

add_subdirectory(serialization)
