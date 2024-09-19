#---------#
# Version #
# & Ident #
#---------#

set(FFS_VERSION "0.0.1")
set(FFS_PATH "${CMAKE_CURRENT_LIST_DIR}")

#---------#
# Helpers #
#---------#

function(ffs_print_var X)
    set(modes "FATAL_ERROR;SEND_ERROR;WARNING;AUTHOR_WARNING;DEPRECATION;NOTICE;STATUS;VERBOSE;DEBUG;TRACE")
   if ("${X}" IN_LIST modes)
     foreach(var ${ARGN})
       ffs_message("${X}" "${var} = ${${var}}")
     endforeach()
   else()
     ffs_message("${X} = ${${X}}")
     foreach(var ${ARGN})
       ffs_message("${var} = ${${var}}")
     endforeach()
   endif()
endfunction()

function(ffs_message X)
    set(modes "FATAL_ERROR;SEND_ERROR;WARNING;AUTHOR_WARNING;DEPRECATION;STATUS;VERBOSE;DEBUG;TRACE")
    if (FFS_GLOBAL_PREFIX_MESSAGES AND NOT _ffs_msg_prefix)
      set(_ffs_msg_prefix "FFS: ")
    endif()
    if ("${X}" IN_LIST modes)
        message(${X} ${_ffs_msg_prefix} ${ARGN})
    else()
        message(${_ffs_msg_prefix} ${X} ${ARGN})
    endif()
endfunction()

function(ffs_sourcing_message X)
    if (FFS_GLOBAL_PREFIX_MESSAGES)
      set(_ffs_msg_prefix "FFS PKG SOURCE: ")
    endif()
    ffs_message(${X} ${ARGN})
endfunction()

#-----------------#
#-----------------#
# ffs_graph_start #
#-----------------#
#-----------------#

# FFS graph API
#===============

# For use in, e.g., superbuilds where some packages could be found beforehand (but should be reusable)
# Currently only supports a single graph, might add namespaced variables later

# Issues:
# 1. Header-only libraries are different... if there is a chain of them, then even if the last in the chain is "force built"
# 2. Implement printing of the dependency graph
# 3. Maybe it's better that this file only handles the graph nature of things, and the force install/force find properties are kept in variables, not lists (?)

#Invariants (make sure this is checked in superbuild macros):
# 1. Nodes cannot be both force_built and force_find [X]
# 2. Force_built nodes can't have downstream found nodes [ ] (except maybe header-opnly ones)
#  2.1 Better make this one computed, don't actually change the graph (even though it's tempting)
#  Great, not an invariant we have to enforce in the variables!
# 4. No circular dependencies [X]

#TODO: change macros with return variables to functions with set PARENT_SCOPE (maybe?)

#-------#
# Nodes #
#-------#

# Add a node to the list of known nodes
macro(ffs_graph_add_node node)
    if (NOT ${node} IN_LIST FFS_GRAPH_NODES)
        list(APPEND FFS_GRAPH_NODES ${node})
    endif()
endmacro()

# If a node is terminal, then it's DIRECT_DOWNSTREAM is empty
macro(ffs_graph_node_is_terminal node varname)
    if (FFS_GRAPH_${node}_DIRECT_DOWNSTREAM)
        set(${varname} 0)
    else()
        set(${varname} 1)
    endif()
endmacro()

#--------------#
# List queries #
#--------------#
macro(ffs_graph_nodes_with_property varname namespace prop)
    foreach(node ${FFS_GRAPH_NODES})
        if (FFS_${namespace}_${node}_${prop})
	    list(APPEND ${varname} ${node})
        endif()
    endforeach()
endmacro()

macro(ffs_graph_nodes_without_property varname namespace prop)
    foreach(node ${FFS_GRAPH_NODES})
        if (NOT FFS_${namespace}_${node}_${prop})
	    list(APPEND ${varname} ${node})
        endif()
    endforeach()
endmacro()


# Find all terminal nodes
macro(ffs_graph_terminal_nodes varname)
    ffs_graph_nodes_without_property(${varname} GRAPH DIRECT_DOWNSTREAM)
endmacro()

# Find all upstream nodes
macro(ffs_graph_upstream_nodes varname)
    ffs_graph_nodes_without_property(${varname} GRAPH DIRECT_DEPS)
endmacro()

macro(ffs_graph_node_properties node varname)
    # Terminal/Not
    # Check dependencies
    if (NOT FFS_GRAPH_${node}_DIRECT_DOWNSTREAM)
        list(APPEND ${varname} "Terminal node")
    else()
        list(APPEND ${varname} "Dependency (not a terminal node)")
    endif()

    if (NOT FFS_GRAPH_${node}_DIRECT_DEPS)
        list(APPEND ${varname} "Root upstream node")
    else()
        list(APPEND ${varname} "Dependent (not a root upstream node)")
    endif()

endmacro()

#
function(ffs_graph_print_node node)
    #TODO: Provide more and less verbose versions
    ffs_graph_node_properties(${node} node_props)
    message(" ${node} ")
    foreach(prop ${node_props})
        message("   ${prop}")
    endforeach()
endfunction()

# Print nodes
function(ffs_graph_print_nodes)
    message("FFS: All nodes:")
    if (NOT FFS_GRAPH_NODES)
        message(" <EMPTY>")
        return()
    endif()
    foreach(node ${FFS_GRAPH_NODES})
        ffs_graph_print_node(${node})
    endforeach()
endfunction()

# Print terminal nodes
function(ffs_graph_print_terminal_nodes)
    message("FFS: Defined terminal nodes:")
    ffs_graph_terminal_nodes(term_nodes)
    foreach(node ${term_nodes})
        ffs_graph_print_node(${node})
    endforeach()
endfunction()

#--------------------#
# Dependencies/Graph #
#--------------------#

# add dependencies, first argument is the dependent node
macro(ffs_graph_add_dependencies node)
    ffs_graph_add_node(${node})
    foreach(dependency_mby_list ${ARGN})
      foreach(dependency ${dependency_mby_list})
        ffs_graph_add_node(${dependency})
        if (NOT ${dependency} IN_LIST FFS_GRAPH_${node}_DIRECT_DEPS)
            list(APPEND FFS_GRAPH_${node}_DIRECT_DEPS ${dependency})
            list(APPEND FFS_GRAPH_${dependency}_DIRECT_DOWNSTREAM ${node})
        endif()
      endforeach()
    endforeach()
endmacro()

# remove dependencies, first argument is the dependent node
macro(ffs_graph_remove_dependencies node)
    ffs_graph_add_node(${node})
    foreach(dependency ${ARGN})
        list(REMOVE_ITEM FFS_GRAPH_${node}_DIRECT_DEPS ${dependency})
        list(REMOVE_ITEM FFS_GRAPH_${dependency}_DIRECT_DOWNSTREAM ${node})
    endforeach()
endmacro()

# Collect all dependencies of a node, including transitive ones into a variable
macro(ffs_graph_dependencies node varname)
    foreach(dependency ${FFS_GRAPH_${node}_DIRECT_DEPS})
        if (NOT ${dependency} IN_LIST ${varname})
            list(APPEND ${varname} ${dependency})
            ffs_graph_dependencies(${dependency} ${varname})
        endif()
    endforeach()
endmacro()

# Collect all downstream nodes
macro(ffs_graph_dependents node varname)
    foreach(downstream_node ${FFS_GRAPH_${node}_DIRECT_DOWNSTREAM})
        if (NOT ${downstream_node} IN_LIST ${varname})
            list(APPEND ${varname} ${downstream_node})
            ffs_graph_dependents(${downstream_node} ${varname})
        endif()
    endforeach()
endmacro()

# Print dependencies
function(ffs_graph_print_direct_dependencies node)
    message("FFS: Direct dependencies of ${node}:")
    foreach(dependency ${FFS_GRAPH_${node}_DIRECT_DEPS})
        message(" ${dependency}")
    endforeach()
endfunction()

# Print dependencies, including transitives
function(ffs_graph_print_dependencies node)
    message("FFS: All dependencies (including transitive ones) of ${node}:")
    ffs_graph_dependencies(${node} the_dependencies)
    foreach(dependency ${the_dependencies})
        message(" ${dependency}")
    endforeach()
endfunction()


# Print dependents
function(ffs_graph_print_direct_dependents node)
    message("FFS: Direct dependencies of ${node}:")
    foreach(dependent ${FFS_GRAPH_${node}_DIRECT_DOWNSTREAM})
        message(" ${dependent}")
    endforeach()
endfunction()

# Print dependents, including transitives
function(ffs_graph_print_dependents node)
    message("FFS: All dependents (including transitive ones) of ${node}:")
    ffs_graph_dependents(${node} the_dependents)
    foreach(dependent ${the_dependents})
        message(" ${dependent}")
    endforeach()
endfunction()


#---------------------------#
# Graph property invariants #
#---------------------------#

macro(ffs_graph_cycles varname)
    foreach(node ${OJL_NODES})
        ffs_graph_dependencies(${node} ffs_${node}_dependencies)
        if (${node} IN_LIST ffs_${node}_dependencies)
            list(APPEND ${varname} ${node})
        endif()
        unset(ffs_${node}_dependencies)
    endforeach()
endmacro()

# varname == 1 if invariants satisfied, 0 otherwise
macro(ffs_graph_errors prefix)
    ffs_graph_cycles(${prefix}_cycles)
endmacro()

function(ffs_graph_enforce_invariants)
    ffs_graph_errors(error)

    if ((NOT error_cycles))
        message(DEBUG "FFS: Dependency graph invariants satisfied")
        return()
    endif()

    foreach(node ${error_cycles})
        list(APPEND msgs "cycle: Node \"${node}\" depends on itself")
    endforeach()

    list(JOIN msgs "\n - " msg)

    message(FATAL_ERROR "FFS: Dependency graph invariants violated:\n - ${msg}")
endfunction()

#---------------#
#---------------#
# ffs_graph_end #
#---------------#
#---------------#

#----------------#
#----------------#
# ffs_global_cfg #
#----------------#
#----------------#

## Options (


#INSTALL_POLICY
# ALWAYS/NEVER/AUTO
#  Default policy to use for packages


#UPDATE POLICY
# ALWAYS/NEVER
#  Default update policy
#  ALWAYS -> EP_UPDATE_DISCONNECTED=FALSE
#  NEVER -> EP_UPDATE_DISCONNECTED=TRUE



#PKG_DEFAULT_REQUIRED
# (TODO: Not implemented): required is set by default

#DEBUG
# Print more messages

#PREFIX_MESSAGES
# Prefix ffs messages with FFS:

## Settings

#FFS_GLOBAL_INSTALL_PREFIX
if(NOT FFS_EXTERNAL_PROJECT AND NOT FFS_INSTALL)
    set(FFS_GLOBAL_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/ffs_install_prefix)

    #Logging
    if(NOT CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
        #TODO: check that this isn't ${CMAKE_BINARY_DIR}/ffs_install_prefix
        ffs_message("CMAKE_INSTALL_PREFIX set to \"${CMAKE_INSTALL_PREFIX}\", but ffs will install to ${FFS_GLOBAL_INSTALL_PREFIX}, because FFS_INSTALL=OFF")
    endif()
    #End logging
else()
    #TODO: also check environment variable CMAKE_INSTALL_PREFIX?
    #CMAKE 3.29 does respect CMAKE_INSTALL_PREFIX, but we support older versions as well
    if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT AND DEFINED ENV{CMAKE_INSTALL_PREFIX})
        ffs_message(STATUS "FFS: Overriding default CMAKE_INSTALL_PREFIX with value from environment variable")
        set(CMAKE_INSTALL_PREFIX $ENV{CMAKE_INSTALL_PREFIX} CACHE PATH "..." FORCE)
    endif()
    set(FFS_GLOBAL_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX})

    #Logging
    if(FFS_INSTALL)
        ffs_message(STATUS "FFS_INSTALL=ON, ffs will install packages during build time to=${FFS_GLOBAL_INSTALL_PREFIX}")
    elseif(FFS_EXTERNAL_PROJECT)
        ffs_message(STATUS "FFS_EXTERNAL_PROJECT=1, this is an ffs subbuild, ffs will install packages during build time to=${FFS_GLOBAL_INSTALL_PREFIX}")
    endif()
    #End logging

endif()
# Install prefix for installing external packages
# By default:
#  when superbuild: set to a directory in the build dir, change this along with CMAKE_INSTALL_PREFIX to install everything under the same prefix
#  when subbuild: set to CMAKE_INSTALL_PREFIX

#FFS_GLOBAL_EP_BASE
set(FFS_GLOBAL_EP_BASE ffs_external_project_tree)
#Set EP_BASE for ExternalProject_Add

#FFS_GLOBAL_CMAKE_MODULE_PATH
#CMAKE_MODULE_PATH for ExternalProject_Add
# unset by default


macro(_ffs_set_unset_options)
  foreach(var ${ffs_global_opts})
    if(_FFS_GLOBAL_${var})
      set(FFS_GLOBAL_${var} ${_FFS_GLOBAL_${var}})
    endif()
    unset(_FFS_GLOBAL_${var})
  endforeach()

  foreach(var ${ffs_global_args})
    if(DEFINED _FFS_GLOBAL_${var})
      set(FFS_GLOBAL_${var} ${_FFS_GLOBAL_${var}})
    endif()
    unset(_FFS_GLOBAL_${var})
  endforeach()
endmacro()

macro(_ffs_global_configure)
  if(DEFINED FFS_GLOBAL_EP_BASE)
    set_directory_properties(PROPERTIES EP_BASE ${FFS_GLOBAL_EP_BASE})
  endif()
  if(DEFINED FFS_GLOBAL_UPDATE_POLICY)
    if (${FFS_GLOBAL_UPDATE_POLICY} STREQUAL ALWAYS)
      set_directory_properties(PROPERTIES EP_UPDATE_DISCONNECTED FALSE)
    endif()
    if (${FFS_GLOBAL_UPDATE_POLICY} STREQUAL NEVER)
      set_directory_properties(PROPERTIES EP_UPDATE_DISCONNECTED TRUE)
    endif()
  endif()
endmacro()
_ffs_global_configure()

macro(ffs_global_cfg)
  set(ffs_global_opts
    DEBUG
    PREFIX_MESSAGES
    PKG_DEFAULT_REQUIRED
  )
  set(ffs_global_args
    INSTALL_PREFIX
    INSTALL_POLICY
    UPDATE_POLICY
    EP_BASE
    CMAKE_MODULE_PATH
  )
  cmake_parse_arguments(_FFS_GLOBAL
    "${ffs_global_opts}"
    "${ffs_global_args}"
    ""
    ${ARGN})

  _ffs_set_unset_options()

  if(NOT FFS_GLOBAL_INSTALL_POLICY)
    set(FFS_GLOBAL_INSTALL_POLICY AUTO)
  endif()


  if(NOT FFS_GLOBAL_INSTALL_POLICY)
    set(FFS_GLOBAL_UPDATE_POLICY ALWAYS)
  endif()

  if(FFS_GLOBAL_DEBUG)
    set(FFS_GLOBAL_PREFIX_MESSAGES 1)
    ffs_print_var(
      FFS_GLOBAL_DEBUG
      FFS_GLOBAL_PKG_DEFAULT_REQUIRED

      FFS_GLOBAL_INSTALL_PREFIX
      FFS_GLOBAL_INSTALL_POLICY
      FFS_GLOBAL_UPDATE_POLICY
      FFS_GLOBAL_EP_BASE
      FFS_GLOBAL_CMAKE_MODULE_PATH
    )
    set(CMAKE_MESSAGE_LOG_LEVEL DEBUG)
    set(FFS_GLOBAL_EXTRA_EP_ARGS LOG_DOWNLOAD 1)
    set(FFS_GLOBAL_EXTRA_EP_ARGS LOG_UPDATE 1)
    set(FFS_GLOBAL_EXTRA_EP_ARGS LOG_PATCH 1)
    set(FFS_GLOBAL_EXTRA_EP_ARGS LOG_CONFIGURE 1)
    set(FFS_GLOBAL_EXTRA_EP_ARGS LOG_BUILD 1)
    set(FFS_GLOBAL_EXTRA_EP_ARGS LOG_INSTALL 1)
    set(FFS_GLOBAL_EXTRA_EP_ARGS LOG_TEST 1)
    set(FFS_GLOBAL_EXTRA_EP_ARGS LOG_OUTPUT_ON_FAILURE 1)
  endif()

  _ffs_global_configure()
endmacro()

#----------------#
#----------------#
# ffs_global_end #
#----------------#
#----------------#



#---------------#
#---------------#
# ffs_pkg_start #
#---------------#
#---------------#

include(ExternalProject)

# TODO: check all variables in macro scopes have been unset
# TODO: handle CUSTOM_EXTERNAL_PROJECT_FILE
# TODO: handle REQUIRED for EP projects, do we even need REQUIRED there?
# TODO: less typing if instead of LOCATION_TYPE and LOCATION, we use URL, GIT_REPOSITORY, SOURCE_DIR directly!
# TODO: still, interface could change, so maybe keep location type and set it using the above?

#TODO: formatting, find longest name among packages

#----------------------#
#                      #
# Option documentation #
#                      #
#----------------------#

#TODO: refactor ALWAYS and NEVER to something else, especially force_install is hard to understand
#TODO: always possible to set INSTALL_COMMAND ":", but perhaps this should be made easier with a NO_INSTALL option/similar
set(FFS_DECL_PKG_OPTIONS "REQUIRED;USE_CUSTOM_EP_FILE")
#TODO: is this a bug, shouldn't it be the same as above?
set(FFS_DECL_LOCAL_PKG_OPTIONS "USE_CUSTOM_EP_FILE")
# REQUIRED
#  - this package is required

# ALWAYS
#  - set force install property for this pkg in the dependency graph
#  - don't try find_package in the find phase

# NEVER
#  - set force find property for this pkg in the dependency graph
#  - fail if find_package does not work
#  - don't try to external_package this one

# USE_CUSTOM_EP_FILE
#  - call ExternalProject_Add from a file in cmake/external_projects/<pkg>/CMakeLists.txt (or one defined in CUSTOM_EP_FILEPATH)

set(FFS_DECL_PKG_ONE_ARGS "find_package_VERSION;LOCATION;LOCATION_TYPE;URL;GIT_REPOSITORY;SOURCE_DIR;CUSTOM_EP_FILEPATH;INSTALL_POLICY")
set(FFS_DECL_LOCAL_PKG_ONE_ARGS "SOURCE_DIR")
# find_package_VERSION
#  - version compatibility for find_package

# LOCATION
#  - a URL/file path pointing to the package for ExternalProject

# LOCATION_TYPE
#  - URL, GIT_REPOSITORY, SOURCE_DIR, etc., for ExternalProject to use

# URL/GIT_REPOSITORY/SOURCE_DIR
#  - Less typing if you use these directly

#INSTALL_POLICY
# NEVER/ALWAYS (Can't specify AUTO for a package, only globally)
#  Defines when ffs will decide to call ExternalProject_Add for this package

set(FFS_DECL_PKG_MULTI_ARGS "DEPENDENCIES;EP_ARGS;find_package_ARGS;CMAKE_ARGS;CMAKE_ARGS_DOWNSTREAM;FORWARD_DOWNSTREAM;FORWARD")
# DEPENDENCIES
#  - list of dependencies


# EP_ARGS
#  - extra args to EP

# find_package_ARGS
#  - extra args to find_package
#TODO: IMPLEMENT



# CMAKE_ARGS
#  - list of CMAKE args for building this project using ExternalProject
# CMAKE_ARGS_DOWNSTREAM
#  - list of CMAKE args to be passed to downstream packages
#    WILL ONLY BE ADDED if this package was installed using EP
#    Rationale: find_package uses HINTS you can pass, those can be forwarded using FORWARD_DOWNSTREAM
#     and a user can give those as -D options to the superbuild

# FORWARD_DOWNSTREAM
#  - downstream packages calling ExternalProject_Add will forwarded these variables, e.g. hints for find modules to this package
# FORWARD
#  - ExternalProject_Add will be forwarded these vars/env vars (as cache vars)


#-------------------#
# Defining projects #
#-------------------#

#TODO: rename, refactor: ffs_declare_pkg_common
macro(ffs_set_derived_variables pkg)
  if (FFS_PKG_${pkg}_URL OR FFS_PKG_${pkg}_GIT_REPOSITORY OR FFS_PKG_${pkg}_SOURCE_DIR)
      if((FFS_PKG_${pkg}_LOCATION_TYPE OR FFS_PKG_${pkg}_LOCATION)
       OR
      (FFS_PKG_${pkg}_URL AND FFS_PKG_${pkg}_GIT_REPOSITORY)
       OR
      (FFS_PKG_${pkg}_URL AND FFS_PKG_${pkg}_SOURCE_DIR)
       OR
      (FFS_PKG_${pkg}_GIT_REPOSITORY AND FFS_PKG_${pkg}_SOURCE_DIR))
      ffs_message(FATAL_ERROR
        "Can only define one of URL, GIT_REPOSITORY, SOURCE_DIR, "
        "or the combination LOCATION+LOCATION_TYPE.")
    endif()
  endif()

  if (FFS_PKG_${pkg}_URL)
    set(FFS_PKG_${pkg}_LOCATION_TYPE URL)
    set(FFS_PKG_${pkg}_LOCATION ${FFS_PKG_${pkg}_URL})
  elseif(FFS_PKG_${pkg}_GIT_REPOSITORY)
    set(FFS_PKG_${pkg}_LOCATION_TYPE GIT_REPOSITORY)
    set(FFS_PKG_${pkg}_LOCATION ${FFS_PKG_${pkg}_GIT_REPOSITORY})
  elseif(FFS_PKG_${pkg}_SOURCE_DIR)
    set(FFS_PKG_${pkg}_LOCATION_TYPE SOURCE_DIR)
    set(FFS_PKG_${pkg}_LOCATION ${FFS_PKG_${pkg}_SOURCE_DIR})
  endif()

  if (FFS_PKG_${pkg}_CUSTOM_EP_FILEPATH)
    set(FFS_PKG_${pkg}_USE_CUSTOM_EP_FILE 1)
  endif()

  if (FFS_PKG_${pkg}_INSTALL_POLICY STREQUAL AUTO)
    #Nuh-uh
    ffs_message(WARNING "Package ${pkg} install policy was explicitly set to AUTO. Only ALWAYS or NEVER are allowed. AUTO is legal as a global install policy.")
    unset(FFS_PKG_${pkg}_INSTALL_POLICY)
  endif()

endmacro()

#TODO: the bottom half of these macros are equivalent, refactor (see above comment on ffs_set_derived_variables)
macro(ffs_declare_external_pkg NAME)
  ffs_message(DEBUG "Registered external package \"${NAME}\"")
  cmake_parse_arguments(FFS_PKG_${NAME}
      "${FFS_DECL_PKG_OPTIONS}"
      "${FFS_DECL_PKG_ONE_ARGS}"
      "${FFS_DECL_PKG_MULTI_ARGS}"
      ${ARGN})

  ffs_set_derived_variables(${NAME})

  if(FFS_GLOBAL_DEBUG)
    ffs_print_pkg_details(${NAME})
  endif()
  if(NOT FFS_PKG_${NAME}_LOCATION_TYPE)
    set(FFS_PKG_${NAME}_LOCATION_TYPE GIT_REPOSITORY)
  endif()

  #Allow no location if package set explicitly to NEVER
  if(NOT FFS_PKG_${NAME}_LOCATION AND (NOT ${FFS_PKG_${NAME}_INSTALL_POLICY} STREQUAL NEVER))
      ffs_message(FATAL_ERROR "No LOCATION defined for external package \"${NAME}\"")
  endif()

  if(FFS_PKG_${NAME}_INSTALL_POLICY)
    set(FFS_PKG_${NAME}_INSTALL_POLICY_REASON package)
  endif()

  ffs_graph_add_dependencies(${NAME} ${FFS_PKG_${NAME}_DEPENDENCIES})
endmacro()

macro(ffs_declare_local_pkg NAME)
  ffs_message(DEBUG "Registered local package \"${NAME}\"")
  cmake_parse_arguments(FFS_PKG_${NAME}
      "${FFS_DECL_LOCAL_PKG_OPTIONS}"
      "${FFS_DECL_LOCAL_PKG_ONE_ARGS}"
      "${FFS_DECL_PKG_MULTI_ARGS}"
      ${ARGN})

  ffs_set_derived_variables(${NAME})

  set(FFS_PKG_${NAME}_INSTALL_POLICY ALWAYS)
  set(FFS_PKG_${NAME}_INSTALL_POLICY_REASON package)
  set(FFS_PKG_${NAME}_LOCAL TRUE)


  if(FFS_GLOBAL_DEBUG)
    ffs_print_pkg_details(${NAME})
  endif()

  if(NOT FFS_PKG_${NAME}_SOURCE_DIR)
    ffs_message(FATAL_ERROR "No SOURCE_DIR defined for local package \"${NAME}\"")
  endif()

  ffs_graph_add_dependencies(${NAME} ${FFS_PKG_${NAME}_DEPENDENCIES})
endmacro()


#--------------------------------------#
# Policy propagation and determination #
#--------------------------------------#

macro(ffs_propagate_force_install_recursive curr_node)
    if(FFS_PKG_${curr_node}_INSTALL_POLICY STREQUAL ALWAYS)
        set(_FFS_PROPAGATE_ALWAYS 1)
    endif()
    if(${_FFS_PROPAGATE_ALWAYS})
        if (FFS_PKG_${curr_node}_INSTALL_POLICY STREQUAL NEVER)
          # TODO: store the chain of force-installed downstream packages for better error msg
          ffs_message(FATAL_ERROR "Package policy conflict, ${curr_node} explicitly marked as NEVER, but an upstream package is explicitly marked as ALWAYS")
        endif()
        set(FFS_PKG_${curr_node}_INSTALL_POLICY ALWAYS)
        if (NOT FFS_PKG_${curr_node}_INSTALL_POLICY_REASON)
            set(FFS_PKG_${curr_node}_INSTALL_POLICY_REASON propagated)
        endif()
    endif()
    foreach(downstream_node ${FFS_GRAPH_${curr_node}_DIRECT_DOWNSTREAM})
        set(_FFS_PROPAGATE_ALWAYS "${FFS_PKG_${curr_node}_ALWAYS_PROPAGATED}")
	ffs_propagate_force_install_recursive(${downstream_node})
    endforeach()
endmacro()

macro(ffs_set_pkg_policy_variables_from pkg)
    if (FFS_PKG_${pkg}_INSTALL_POLICY)
        set(_ffs_pkg_policy ${FFS_PKG_${pkg}_INSTALL_POLICY})
        set(_ffs_pkg_${_ffs_pkg_policy} 1)
        set(_ffs_pkg_policy_reason ${FFS_PKG_${pkg}_INSTALL_POLICY_REASON})
    elseif(FFS_GLOBAL_INSTALL_POLICY)
        set(_ffs_pkg_policy ${FFS_GLOBAL_INSTALL_POLICY})
        set(_ffs_pkg_${_ffs_pkg_policy} 1)
        set(_ffs_pkg_policy_reason global)
    endif()
    #If no policy, then this is an auto package
endmacro()

macro(ffs_unset_pkg_policy_variables)
    unset(_ffs_pkg_policy_reason)
    unset(_ffs_pkg_${_ffs_pkg_policy})
    unset(_ffs_pkg_policy)
endmacro()

#------------------#
# Finding projects #
#------------------#

#MUST MACRO: calls find_package
macro(ffs_find_package_recursive pkg)

    # stop here if already FOUND and the package is not LOCAL (probably redundant, but better to be redundant than make bad assumptions)
    if(NOT FFS_PKG_${pkg}_find_package_traversed AND ((NOT ${pkg}_FOUND) OR FFS_PKG_${pkg}_LOCAL))
        set(FFS_PKG_${pkg}_find_package_traversed 1)

        # TODO: COMPONENTS

        #Determine policy to use
        ffs_set_pkg_policy_variables_from(${pkg})

        #Either require or not
        #TODO: version could be EXACT, check that the expansion works correctly (it should)
        if (_ffs_pkg_NEVER AND FFS_PKG_${pkg}_REQUIRED)
          ffs_sourcing_message(DEBUG "Package \"${pkg}\" must be made available using find_package "
                                      "(REQUIRED due to ${_ffs_pkg_policy_reason} policy), trying now")
          find_package(${pkg}
              ${FFS_PKG_${pkg}_find_package_VERSION}
              REQUIRED
              ${FFS_PKG_${pkg}_find_package_ARGS}
              )
        elseif(NOT _ffs_pkg_ALWAYS)
          ffs_message(VERBOSE "Trying to find ${pkg} on the system")
          find_package(${pkg}
              ${FFS_PKG_${pkg}_find_package_VERSION}
              QUIET
              ${FFS_PKG_${pkg}_find_package_ARGS}
              )
	endif()

	# If _FOUND is not set, try find_package on dependents
        if(NOT ${pkg}_FOUND)
            if(_ffs_pkg_NEVER)
                ffs_sourcing_message(WARNING
                  "Package \"${pkg}\", with policy NEVER, "
                  "could not be made available using find_package "
                  "=> package will not be available for build"
                )
            elseif(NOT _ffs_pkg_ALWAYS)
                ffs_sourcing_message(DEBUG
                  "Package \"${pkg}\" could not be "
                  "made available using find_package"
                )
            else()
                ffs_message(VERBOSE
                  "${pkg} is set as force-installed due to a "
                  "${_ffs_pkg_policy_reason} policy -> not calling find_package"
                )
            endif()

            # Clean up temporary variables
            ffs_unset_pkg_policy_variables()

            foreach(child ${FFS_GRAPH_${pkg}_DIRECT_DEPS})
		ffs_find_package_recursive(${child})
	    endforeach()
	else()
          ffs_sourcing_message(DEBUG
            "${pkg} available @config-time: find_package. VERSION: ${${pkg}_VERSION}"
          )
          set(FFS_PKG_${pkg}_PROVIDED_BY "find_package")
	endif()

    endif()
    ffs_unset_pkg_policy_variables()

endmacro()

#MUST MACRO: calls ExternalProject_Add
macro(ffs_external_project_add_recursive pkg)
    ffs_message(DEBUG " [ffs_external_project_add_recursive ${pkg}]")
    ffs_set_pkg_policy_variables_from(${pkg})

    if (NOT ${pkg}_FOUND AND NOT _ffs_pkg_NEVER AND NOT TARGET ${pkg}_external)
        ffs_unset_pkg_policy_variables()

        # TODO: How do we handle REQUIRED in EP???
        if (FFS__PKG_${pkg}_REQUIRED)
        endif()

        # Log sourcing method
        if (FFS_PKG_${pkg}_USE_CUSTOM_EP_FILE)
          if (FFS_PKG_${pkg}_CUSTOM_EP_FILEPATH)
            set(_ffs_ep_file ${FFS_PKG_${pkg}_CUSTOM_EP_FILEPATH})
          else()
            #TODO: document this special filepath
            set(_ffs_ep_file ${CMAKE_SOURCE_DIR}/cmake/external_projects/${pkg}/CMakeLists.txt)
          endif()
          ffs_sourcing_message(DEBUG
              "${pkg} @build-time: Custom ExternalProject call defined in \"${_ffs_ep_file}\"")
        elseif(FFS_PKG_${pkg}_LOCAL)
            ffs_sourcing_message(DEBUG
              "${pkg} @build-time: ExternalProject (local pkg method)")
        else()
            ffs_sourcing_message(DEBUG
              "${pkg} @build-time: ExternalProject (external pkg method)")
        endif()


        # Set module path if configured
        if (FFS_GLOBAL_CMAKE_MODULE_PATH)
            #TODO: escape semicolons in FFS_GLOBAL_CMAKE_MODULE_PATH
            list(APPEND _ffs_forwarded_args "-DCMAKE_MODULE_PATH=${FFS_GLOBAL_CMAKE_MODULE_PATH}")
        endif()

        # Dependency propagation from find_package -> EP
        foreach(ffs_dep ${FFS_GRAPH_${pkg}_DIRECT_DEPS})

            ffs_message(DEBUG "   propagating arguments from ${ffs_dep} to ${pkg}")
            # For cmake configs, set -D${pkg}_DIR for each dependency
            # Assume all local packages produce a cmake config
            if (${ffs_dep}_DIR)
                list(APPEND _ffs_forwarded_args "-D${ffs_dep}_DIR:PATH=${${ffs_dep}_DIR}")
                ffs_sourcing_message(DEBUG " - forwarding var \"${ffs_dep}_DIR\" (${${ffs_dep}_DIR}) to ${pkg}")
            elseif(DEFINED ENV{${ffs_dep}_DIR})
                list(APPEND _ffs_forwarded_args "-D${ffs_dep}_DIR:PATH=$ENV{${ffs_dep}_DIR}")
                ffs_sourcing_message(DEBUG " - forwarding env var \"${ffs_dep}_DIR\" ($ENV{${ffs_dep}_DIR}) to ${pkg}")
            endif()

            # For find modules, it's a bit more complicated, any variables
            # pointing cmake to the find module or pointing the find module
            # to the package should be forwarded. These vary by project, so the
            # user must specify them per dependency.

            # E.g. FindBoost has a few hints it uses:
            #  https://cmake.org/cmake/help/latest/module/FindBoost.html

            # This dependency wants the superbuild to forward these variables
            foreach(var ${FFS_PKG_${ffs_dep}_FORWARD_DOWNSTREAM})
              if(DEFINED ${var})
                ffs_sourcing_message(DEBUG " - forwarding var \"${var}\" (${${var}}) to ${pkg}")
                list(APPEND _ffs_forwarded_args "-D${var}=${${var}}")
              elseif(DEFINED ENV{${var}})
                ffs_sourcing_message(DEBUG " - forwarding env var \"${var}\" (${${var}}) to ${pkg}, due to dependency ${ffs_dep}")
                list(APPEND _ffs_forwarded_args "-D${var}=$ENV{${var}}")
              endif()
            endforeach()

            # This dependency wants the superbuild to set these cmake args
            if (NOT ${ffs_dep}_FOUND)
              foreach(arg ${FFS_PKG_${ffs_dep}_CMAKE_ARGS_DOWNSTREAM})
                ffs_sourcing_message(DEBUG " - forwarding cmake arg \"${arg}\" to ${pkg}, due to dependency ${ffs_dep}")
                list(APPEND _ffs_forwarded_args ${arg})
              endforeach()
            endif()

        endforeach()

        # The package wants these variables forwarded to it
        # E.g. maybe CMAKE_MODULE_PATH? Not always a good idea, but I can see cases for it
        foreach(var ${FFS_PKG_${pkg}_FORWARD})
          ffs_sourcing_message(DEBUG " ${pkg} @config forwarding cmake arg \"${var}\" from superbuild context due to FORWARD argument")
          if(DEFINED ${var})
            ffs_sourcing_message(DEBUG " - found cmake variable ${var}=${${var}}")
            list(APPEND _ffs_forwarded_args "-D${var}=${${var}}")
          elseif(DEFINED ENV{${var}})
            ffs_sourcing_message(DEBUG " - found env variable ${var}=${${var}}")
            list(APPEND _ffs_forwarded_args "-D${var}=$ENV{${var}}")
          endif()
        endforeach()



        if (FFS_PKG_${pkg}_USE_CUSTOM_EP_FILE)
          include(${_ffs_ep_file})
          set(FFS_PKG_${pkg}_PROVIDED_BY "CUSTOM_EP")
          unset(_ffs_ep_file)
        elseif (FFS_PKG_${pkg}_LOCAL)
            # Local projects will be built under the superbuild root binary directory
            # in a directory with the same name as the source dir
            # NOTE: impossible to build in the root binary directory itself, because
            # both the superbuild and the local build would have the same binary dir

            #TODO: instead of forwarding a specific hardcoded set of CMAKE_ARGS, set a global FFS_GLOBAL_FORWARDED_CMAKE_ARGS
            #Much easier to configure and avoid unused variable warnings (or we could even set the --no-warn-unused-cli setting globally, instead of per-project as it it now...)

            ExternalProject_Add(
                ${pkg}_external
                ${FFS_GLOBAL_EXTRA_EP_ARGS}
                SOURCE_DIR
                  "${CMAKE_SOURCE_DIR}/${FFS_PKG_${pkg}_LOCATION}"
                BINARY_DIR
                  "${CMAKE_BINARY_DIR}/${FFS_PKG_${pkg}_LOCATION}"
                ${FFS_PKG_${pkg}_EP_ARGS}
                BUILD_ALWAYS
                  1
                CMAKE_ARGS
                  -DFFS_EXTERNAL_PROJECT=1
                  -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                  -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
                  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                  "-DCMAKE_PREFIX_PATH=${_ffs_cmake_prefix_path}"
                  -DCMAKE_INSTALL_PREFIX=${FFS_GLOBAL_INSTALL_PREFIX}
                  ${FFS_PKG_${pkg}_CMAKE_ARGS}
                  ${_ffs_forwarded_args}
            )
            set(FFS_PKG_${pkg}_PROVIDED_BY "EP")
        else()

            ExternalProject_Add(
                ${pkg}_external
                ${FFS_GLOBAL_EXTRA_EP_ARGS}
                ${FFS_PKG_${pkg}_EP_ARGS}
                "${FFS_PKG_${pkg}_LOCATION_TYPE}"
                  "${FFS_PKG_${pkg}_LOCATION}"
                CMAKE_ARGS
                  -DFFS_EXTERNAL_PROJECT=1
                  -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                  -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
                  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                  "-DCMAKE_PREFIX_PATH=${_ffs_cmake_prefix_path}"
                  -DCMAKE_INSTALL_PREFIX=${FFS_GLOBAL_INSTALL_PREFIX}
                  ${FFS_PKG_${pkg}_CMAKE_ARGS}
                  ${_ffs_forwarded_args}
            )
            set(FFS_PKG_${pkg}_PROVIDED_BY "EP")
	endif()
        unset(_ffs_forwarded_args)


        # Dependency propagation from EP -> EP
        #  declare a configure time dependency using EP's own API
        foreach(ffs_dep ${FFS_GRAPH_${pkg}_DIRECT_DEPS})
	  if (NOT ${ffs_dep}_FOUND)
            ExternalProject_Add_StepDependencies(
	      ${pkg}_external configure ${ffs_dep}_external
	    )
	    ffs_external_project_add_recursive(${ffs_dep})
          endif()
	endforeach()
    endif()
    ffs_unset_pkg_policy_variables()
endmacro()

#MUST MACRO: calls find_package and external_project
macro(ffs_make_pkgs_available)

    ffs_message(DEBUG "Making packages available")
    ffs_graph_enforce_invariants()

    # Get upstream packages (packages without any dependencies)
    ffs_graph_upstream_nodes(_ffs_upstream_pkgs)

    # Propagate force install flag downstream
    foreach(pkg ${_ffs_upstream_pkgs})
        unset(_FFS_PROPAGATE_ALWAYS)
	ffs_propagate_force_install_recursive(${pkg})
    endforeach()
    unset(_FFS_PROPAGATE_ALWAYS)

    # Get downstream packages (the final build products)
    ffs_graph_terminal_nodes(_ffs_downstream_pkgs)


    # First: try find_package on the subtrees rooted at each downstream package
    ffs_message(DEBUG "Trying find_package for dependencies...")
    foreach(pkg ${_ffs_downstream_pkgs})
	ffs_find_package_recursive(${pkg})
    endforeach()


    # Second: try ExternalProject_Add on the subtrees rooted at each downstream package
    ffs_message(DEBUG "Adding missing dependencies and local pkgs as ExternalProjects...")

    #Note: setting CMAKE_PREFIX_PATH here makes the magic work
    set(_ffs_cmake_prefix_path ${CMAKE_PREFIX_PATH})
    list(APPEND _ffs_cmake_prefix_path $ENV{CMAKE_PREFIX_PATH})
    list(PREPEND _ffs_cmake_prefix_path ${FFS_GLOBAL_INSTALL_PREFIX})
    string(REPLACE ";" "$<SEMICOLON>" _ffs_cmake_prefix_path "${_ffs_cmake_prefix_path}")

    #Note: should we also forward other CMAKE prefix paths? like FRAMEWORK or APPBUNDLE ?

    foreach(pkg ${_ffs_downstream_pkgs})
      ffs_external_project_add_recursive(${pkg})
    endforeach()

    unset(_ffs_cmake_prefix_path)
    unset(_ffs_downstream_pkgs)

    # TODO: we set this every time now, we COULD check if there are NO installs before setting it, but what's the harm?
    set(${CMAKE_PREFIX_PATH} ${FFS_GLOBAL_INSTALL_PREFIX})

endmacro()

#--------------------#
# Debug/print macros #
#--------------------#

#Prints the ffs version 
function(ffs_print_version)
    ffs_message(STATUS "FFS VERSION: ${FFS_VERSION}")
    ffs_message(STATUS "FFS PATH:    ${FFS_PATH}")
endfunction()

#Prints the ffs version 
function(ffs_print_config)
    ffs_message(STATUS "FFS global config:")
    ffs_message(STATUS "   FFS_GLOBAL_INSTALL PREFIX=${FFS_GLOBAL_INSTALL_PREFIX}")
    ffs_message(STATUS "          FFS_GLOBAL_EP_BASE=${FFS_GLOBAL_EP_BASE}")
    ffs_message(STATUS "FFS_GLOBAL_CMAKE_MODULE_PATH=${FFS_GLOBAL_CMAKE_MODULE_PATH}")
    ffs_message(STATUS "   FFS_GLOBAL_INSTALL_POLICY=${FFS_GLOBAL_INSTALL_POLICY}")

    ffs_message(STATUS "FFS cache vars:")
    ffs_message(STATUS "                FFS_INSTALL=${FFS_INSTALL}")
    ffs_message(STATUS "       FFS_EXTERNAL_PROJECT=${FFS_EXTERNAL_PROJECT}")
endfunction()

#Prints external vs local packages
function(ffs_print_registered_pkg_summary)
    ffs_graph_nodes_with_property(_ffs_local_pkgs PKG LOCAL)
    ffs_graph_nodes_without_property(_ffs_nonlocal_pkgs PKG LOCAL)
    list(JOIN _ffs_local_pkgs ", " _ffs_local_pkg_string)
    list(JOIN _ffs_nonlocal_pkgs ", " _ffs_nonlocal_pkg_string)
    ffs_message(STATUS "External packages: ${_ffs_nonlocal_pkg_string}")
    ffs_message(STATUS "Local packages: ${_ffs_local_pkg_string}")
    #Terminal nodes
endfunction()

#Prints local packages
function(ffs_print_local_pkg_summary)
    ffs_graph_nodes_with_property(_ffs_local_pkgs PKG LOCAL)
    list(JOIN _ffs_local_pkgs ", " _ffs_local_pkg_string)
    ffs_message(STATUS "Local sub-projects: ${_ffs_local_pkg_string}")
    #Terminal nodes
endfunction()

#Prints the policy of each package
function(ffs_print_install_policy_summary)

    set(_ffs_global_policy "AUTO")
    if (FFS_GLOBAL_INSTALL_POLICY)
      set(_ffs_global_policy ${FFS_GLOBAL_INSTALL_POLICY})
    endif()
    ffs_message(STATUS "Default install policy: ${_ffs_global_policy}")

    set(_ffs_never_install_pkgs)
    set(_ffs_auto_pkgs)
    set(_ffs_always_install_pkgs)

    # TODO: print policy reasons?
    foreach(pkg ${FFS_GRAPH_NODES})
      if (NOT FFS_PKG_${pkg}_LOCAL)
        ffs_set_pkg_policy_variables_from(${pkg})
        if (_ffs_pkg_policy STREQUAL NEVER)
           list(APPEND _ffs_never_install_pkgs ${pkg})
        elseif(_ffs_pkg_policy STREQUAL ALWAYS)
           list(APPEND _ffs_always_install_pkgs ${pkg})
        else()
           list(APPEND _ffs_auto_pkgs ${pkg})
        endif()
        ffs_unset_pkg_policy_variables()
      endif()
    endforeach()

    #Print always find pkgs
    if (_ffs_never_install_pkgs)
      list(JOIN _ffs_never_install_pkgs ", " _ffs_never_install_string)
      ffs_message(STATUS "Dependencies with install policy NEVER (forced find_package):")
      ffs_message(STATUS " ${_ffs_never_install_string}")
    endif()

    #Print auto pkgs
    if (_ffs_auto_pkgs)
      list(JOIN _ffs_auto_pkgs ", " _ffs_auto_string)
      ffs_message(STATUS "Dependencies with install policy AUTO (try find_package, then install):")
      ffs_message(STATUS " ${_ffs_auto_string}")
    endif()

    #Print always download pkgs
    if (_ffs_always_install_pkgs)
      list(JOIN _ffs_always_install_pkgs ", " _ffs_always_install_string)
      ffs_message(STATUS "Dependencies with install policy ALWAYS:")
      ffs_message(STATUS " ${_ffs_always_install_string}\n")
    endif()
endfunction()

function(ffs_print_precheck_summary)
    ffs_print_version()
    ffs_print_config()
    ffs_print_install_policy_summary()
    #ffs_print_local_pkg_summary()
endfunction()

#Helper used by below function
#FROM: https://stackoverflow.com/questions/12521452/get-a-list-of-variables-with-a-specified-prefix
function (_ffs_getListOfVarsStartingWith _prefix _varResult)
    get_cmake_property(_vars VARIABLES)
    string (REGEX MATCHALL "(^|;)${_prefix}[A-Za-z0-9_]*" _matchedVars "${_vars}")
    set (${_varResult} ${_matchedVars} PARENT_SCOPE)
endfunction()

#Prints the source of each package
function(ffs_print_postcheck_summary)
    foreach(pkg ${FFS_GRAPH_NODES})
      #LOCAL packages also...
      if(FFS_PKG_${pkg}_LOCAL)
        list(APPEND _ffs_local_pkgs ${pkg})
      elseif(FFS_PKG_${pkg}_PROVIDED_BY STREQUAL find_package)
        list(APPEND _ffs_find_package_pkgs ${pkg})
      elseif(FFS_PKG_${pkg}_PROVIDED_BY STREQUAL EP)
        list(APPEND _ffs_EP_pkgs ${pkg})
      elseif(FFS_PKG_${pkg}_PROVIDED_BY STREQUAL CUSTOM_EP)
        list(APPEND _ffs_CUSTOM_EP_pkgs ${pkg})
      else()
        list(APPEND _ffs_UNAVAILABLE_pkgs ${pkg})
      endif()
    endforeach()

    #Print find pkg external packages (and version)

    #TODO: when we implement COMPONENT propagation, replace CXX_FOO with LANG_COMPONENT_FOO
    set(_ffs_find_package_vars
        _DIR
        _ROOT_DIR
        _LIBRARY
        _LIBRARY_DIRS
        _INCLUDE_DIR
        _RUNTIME_LIBRARY_DIRS
        _CXX_FLAGS
        _CXX_INCLUDE_DIRS
    )
    ffs_message(STATUS "Dependencies found on system")
    foreach(pkg ${_ffs_find_package_pkgs})
        string(LENGTH ${pkg} FFS_PKG_${pkg}_strlen)
        if (${pkg}_VERSION)
          ffs_message(STATUS " ${pkg}: version ${${pkg}_VERSION}")
        else()
          ffs_message(STATUS " ${pkg}: version ?.?.?")
        endif()
        if (${pkg}_DIR)
          ffs_message(STATUS "  │${pkg}_DIR=${${pkg}_DIR}")
        else()
          foreach(suffix ${_ffs_find_package_vars})
            if (${pkg}${suffix})
              list(JOIN ${pkg}${suffix} ", " _ffs_pkg_var_val)
              ffs_message(STATUS "  │${pkg}${suffix}=${_ffs_pkg_var_val}")
              unset(_ffs_pkg_var_val)
            endif()
          endforeach()
        endif()
    endforeach()
    unset(_ffs_find_package_vars)

    #Print EP external packages (and version)
    ffs_message(STATUS "Will be downloaded and installed at build time")
    foreach(pkg ${_ffs_EP_pkgs})
      ffs_message(STATUS " ${pkg}, ${FFS_PKG_${pkg}_LOCATION_TYPE}: ${FFS_PKG_${pkg}_LOCATION}")
    endforeach()

    #Print Custom EP external packages (and version)
    foreach(pkg ${_ffs_CUSTOM_EP_pkgs})
        ffs_message(STATUS " ${pkg}: Custom logic to install")
    endforeach()

    #Print local packages, and project versions
    ffs_message(STATUS "Local sub-projects")
    foreach(pkg ${_ffs_local_pkgs})
        ffs_message(STATUS " ${pkg}: ")
    endforeach()
endfunction()


function(ffs_print_pkg_details NAME)
    if (${ARGC} GREATER 1)
        set(MODE ${ARG1})
    endif()
    ffs_message(${MODE} "${NAME}")
    foreach(opt ${FFS_DECL_PKG_OPTIONS})
        set(val "${FFS_PKG_${NAME}_${opt}}")
	if(val)
            ffs_message(${MODE} "  ${opt}: ${val}")
	else()
            ffs_message(${MODE} "  ${opt}: <NOT SET>")
        endif()
    endforeach()

    foreach(arg ${FFS_DECL_PKG_ONE_ARGS})
        set(val "${FFS_PKG_${NAME}_${arg}}")
	if(val)
            ffs_message(${MODE} "  ${arg}: ${val}")
	else()
            ffs_message(${MODE} "  ${arg}: <NOT SET>")
        endif()
    endforeach()
    foreach(arg ${FFS_DECL_PKG_MULTI_ARGS})
        set(val "${FFS_PKG_${NAME}_${arg}}")
	if(val)
            ffs_message(${MODE} "  ${arg}: (list)")
            foreach(it ${FFS_PKG_${NAME}_${arg}})
              ffs_message(${MODE} "    ${it}")
            endforeach()
	else()
            ffs_message(${MODE} "  ${arg}: <NOT SET>")
        endif()
    endforeach()
    #TODO: add graph property prints, e.g. terminal/upstream/middle node
endfunction()
