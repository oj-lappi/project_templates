include(${CMAKE_SOURCE_DIR}/cmake/Testing.cmake)
find_catch2_and_define_test_target()

add_library(TestInternal INTERFACE)
target_link_libraries(TestInternal INTERFACE TestDependencies)

target_include_directories(TestInternal INTERFACE .. )
target_include_directories(TestInternal INTERFACE ../../3rd_party )
target_include_directories(TestInternal INTERFACE ../../test/test_utils)

include(Catch)
include(CTest)
