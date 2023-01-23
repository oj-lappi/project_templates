#Macro to handle different Catch2 versions
macro(find_catch2_and_define_test_target)
    if (TARGET TestDependencies)
	    set(TestDependencies_EXISTS 1)
    endif()

    if(NOT Catch2_FOUND)
	    message("Loading Catch2 and defining test targets for ${CMAKE_CURRENT_LIST_DIR}")
        find_package(Catch2 REQUIRED)
            if(NOT TestDependencies_EXISTS)
                add_library(TestDependencies INTERFACE)
            endif()
        if(Catch2_FOUND)
	    message("  found Catch2, version: ${Catch2_VERSION}")
            if(NOT TARGET Catch2::Catch2WithMain)
                message(SEND_ERROR
                    "This project's tests depend on Catch2::Catch2WithMain, but Catch2 was built without "
                    "it. To fix this, build Catch2 with CATCH_BUILD_STATIC_LIBRARY=ON\n"
                    "(see: https://github.com/catchorg/Catch2/releases/tag/v2.13.5)")
            endif()

            if(NOT TestDependencies_EXISTS)
                    target_link_libraries(TestDependencies INTERFACE {{project_name}} Catch2::Catch2WithMain fmt::fmt-header-only)
                if(NOT ${Catch2_VERSION} VERSION_GREATER_EQUAL "3")
                    target_compile_definitions(TestDependencies INTERFACE CATCH2_USE_OLD_HEADER=1)
                endif()
            endif()
        endif()
    endif()
endmacro()
