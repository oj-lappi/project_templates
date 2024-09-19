cmake_minimum_required(VERSION 3.19)

if (${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.24.0")
  #CMP0135: A ``DOWNLOAD_EXTRACT_TIMESTAMP`` policy
  #Setting CMP0135=NEW breaks the OpenMPI autotools build through EP,
  #TODO: investigate if this could be set this to OLD only for the OpenMPI build?
  #
  #The policy confuses the OpenMPI makefile, which sees that
  #Makefile.am is newer than the Makefile, and tries to run automake,
  #which breaks due to no defined AUTOMAKE or version mismatches in the
  #two times automake has been run (by the dev, and now by us).
  cmake_policy(SET CMP0135 OLD)
endif()

project({{project_name}}_superbuild)

set(CMAKE_CXX_STANDARD 20)

# This CMakeLists.txt uses FFS to organize a "superbuild", aka a poor man's package manager.
# FFS is a custom tool that installs dependencies at build time using CMake's ExternalProject. 
# - Dependencies are declared using ffs_declare_external_pkg
#
# The project(s) that are part of this superbuild must also be CMake ExternalProjects.
# They live in subdirectories of the superbuild.
# - Projects are declared using ffs_declare_local_pkg




#[=[ FFS OPTIONS ]=]

option(DEBUG_FFS "Debug the ffs build process" OFF)
set(DOWNLOAD AUTO CACHE STRING
    "Policy for downloading dependencies, one of: NEVER, AUTO, ALWAYS")
set_property(CACHE DOWNLOAD PROPERTY STRINGS NEVER AUTO ALWAYS)

set(UPDATE NEVER CACHE STRING
    "Policy for updating dependencies, one of: NEVER, ALWAYS. ALWAYS is useful when working on a dependency at the same time (e.g. charon)")
set_property(CACHE UPDATE PROPERTY STRINGS NEVER ALWAYS)

#[=[ FFS BOILERPLATE ]=]

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(ffs)

ffs_global_cfg(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH})

if (DOWNLOAD)
  ffs_global_cfg(INSTALL_POLICY ${DOWNLOAD})
endif()
if (UPDATE)
  ffs_global_cfg(UPDATE_POLICY ${UPDATE})
endif()
if (FFS_USER_INSTALL_PREFIX)
  #TODO: this is not the preferred way, we should just use CMAKE_INSTALL_PREFIX instead, probably
  ffs_message(NOTICE "FFS install prefix override: ${FFS_USER_INSTALL_PREFIX}")
  ffs_global_cfg(INSTALL_PREFIX ${FFS_USER_INSTALL_PREFIX})
endif()
if (DEBUG_FFS)
  ffs_global_cfg(DEBUG)
endif()

#[=[ END FFS BOILERPLATE ]=]

# Dependencies

#[=[ OMPI : The default MPI dependency ]=]
# Any flavor of MPI should work, but OpenMPI will be downloaded & installed with EP
set(DOWNLOAD_URL_OMPI
    "https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.5.tar.gz"
    CACHE STRING "URL to OpenMPI release"
)

ffs_declare_external_pkg(MPI
  REQUIRED
  URL
    ${DOWNLOAD_URL_OMPI}
  EP_ARGS
    BUILD_IN_SOURCE
      1
    CONFIGURE_COMMAND
      ./configure --prefix=${FFS_GLOBAL_INSTALL_PREFIX} --disable-mpi-fortran
    BUILD_COMMAND
      make all
    INSTALL_COMMAND
      make all install
)

set(DOWNLOAD_URL_CHARON
    "https://version.helsinki.fi/lapposka/charon.git"
    CACHE STRING "URL to charon git repo")

#[=[ charon : MPI communication and utility library ]=]
ffs_declare_external_pkg(charon
    REQUIRED
    find_package_VERSION
      0.0.1
    GIT_REPOSITORY
      ${DOWNLOAD_URL_CHARON}
    CMAKE_ARGS
      -DBUILD_DEMOS=ON
      -DBUILD_TESTS=OFF
      -DBUILD_BENCHMARKS=OFF
      --no-warn-unused-cli
    DEPENDENCIES
      MPI
    EP_ARGS
      GIT_TAG
        v0.0.1
      INSTALL_COMMAND
        ":"
)


# {{project_name}} project
ffs_declare_local_pkg({{project_name}}
  SOURCE_DIR
    src
  FORWARD
    CMAKE_UNITY_BUILD
  CMAKE_ARGS
    --no-warn-unused-cli
  DEPENDENCIES
    charon
)

ffs_print_precheck_summary()
ffs_make_pkgs_available()
ffs_print_postcheck_summary()

#TODO: check that jq exists before running this
#It is annoying that jq is a dependency here...
add_custom_target(
    superbuild_compile_commands
    ALL
    COMMAND
        rm -f ${CMAKE_BINARY_DIR}/compile_commands.json
    COMMAND
        find ${CMAKE_BINARY_DIR} -name compile_commands.json | xargs jq '.[]' | jq -s > ${CMAKE_BINARY_DIR}/compile_commands.json
    BYPRODUCTS
        ${CMAKE_BINARY_DIR}/compile_commands.json
    WORKING_DIRECTORY
        ${CMAKE_BINARY_DIR}
)
