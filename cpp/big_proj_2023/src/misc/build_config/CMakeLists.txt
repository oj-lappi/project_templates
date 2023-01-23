target_sources({{project_name}}
    PRIVATE
     ${CMAKE_CURRENT_LIST_DIR}/queries.cpp
  )

##############################
# Bake git state into binary #
##############################

#Get the git hash and store it in 5 separate uint32 values
execute_process(
        COMMAND git rev-parse HEAD
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_COMMIT_HASH
        OUTPUT_STRIP_TRAILING_WHITESPACE)

string(SUBSTRING ${GIT_COMMIT_HASH}  0 8 GIT_HASH_1)
string(SUBSTRING ${GIT_COMMIT_HASH}  8 8 GIT_HASH_2)
string(SUBSTRING ${GIT_COMMIT_HASH} 16 8 GIT_HASH_3)
string(SUBSTRING ${GIT_COMMIT_HASH} 24 8 GIT_HASH_4)
string(SUBSTRING ${GIT_COMMIT_HASH} 32 8 GIT_HASH_5)
message("Git commit hash is ${GIT_COMMIT_HASH}")

execute_process(
        COMMAND git status --porcelain=v1
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        OUTPUT_VARIABLE GIT_UNSTAGED_FILES
        OUTPUT_STRIP_TRAILING_WHITESPACE)

if(GIT_UNSTAGED_FILES)
    message(" there are unstaged files used in the build")
    set(GIT_UNSTAGED_FILES 1)
else()
    set(GIT_UNSTAGED_FILES 0)
endif()

set_property(
    SOURCE ${CMAKE_CURRENT_LIST_DIR}/queries.cpp
    TARGET_DIRECTORY {{project_name}}
    PROPERTY COMPILE_DEFINITIONS
        {{project_name}}_GIT_HASH_1=0x${GIT_HASH_1}
        {{project_name}}_GIT_HASH_2=0x${GIT_HASH_2}
        {{project_name}}_GIT_HASH_3=0x${GIT_HASH_3}
        {{project_name}}_GIT_HASH_4=0x${GIT_HASH_4}
        {{project_name}}_GIT_HASH_5=0x${GIT_HASH_5}
        {{project_name}}_GIT_UNSTAGED_FILES=${GIT_UNSTAGED_FILES}
    )
